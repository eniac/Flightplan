#include <iostream>
#include <fstream>
#include <sstream>
#include <cmath>

#include "rse.h"

static unsigned Get_primitive_polynomial(void);
static void Generate_exp_table(fec_sym Table[FEC_N]);
static void Generate_log_table(fec_sym Table[FEC_N]);
static void Generate_invert_table(fec_sym Table[FEC_N]);

static fec_sym Exp_table[FEC_N];
static fec_sym Log_table[FEC_N];
static fec_sym Invert_table[FEC_N];

/* Addition modulo (number of symbols - 1) */
static fec_sym Modulo_add(fec_sym X, fec_sym Y)
{
  unsigned Sum = X + Y;
  return Sum > FEC_N - 1 ? Sum - (FEC_N - 1) : Sum;
}

/* Add in Galois Field */
static fec_sym GF_add(fec_sym X, fec_sym Y)
{
  return X ^ Y;
}

/* Substract in Galois Field */
static fec_sym GF_substract(fec_sym X, fec_sym Y)
{
  return X ^ Y;
}

/* Exponentiate in Galois Field */
static fec_sym GF_exp(fec_sym X)
{
  return Exp_table[X];
}

/* Logarithm in Galois Field */
static fec_sym GF_log(fec_sym X)
{
  return Log_table[X];
}

/* Multiply in Galois Field */
static fec_sym GF_multiply(fec_sym X, fec_sym Y)
{
  return X != 0 && Y != 0 ? GF_exp(Modulo_add(GF_log(X), GF_log(Y))) : 0;
}

/* Reciprocal in Galois Field */
static fec_sym GF_invert(fec_sym X)
{
  return Invert_table[X];
}

static unsigned Get_primitive_polynomial(void)
{
  switch (FEC_M)
  {
    case 3:
      return 0xB;
    case 4:
      return 0x13;
    case 5:
      return 0x25;
    case 6:
      return 0x43;
    case 7:
      return 0x89;
    case 8:
      return 0x11D;
    case 16:
      return 0x1100B;
    default:
      return 0;
  }
}

static void Generate_exp_table(fec_sym Table[FEC_N])
{
  unsigned Primitive = Get_primitive_polynomial();

  Table[0] = 1;
  for (unsigned i = 1; i < FEC_N; i++)
  {
    unsigned Value = 2 * Table[i - 1];
    if (Value >= FEC_N)
      Value = Value ^ Primitive;
    Table[i] = Value;
  }
}

static void Generate_log_table(fec_sym Table[FEC_N])
{
  fec_sym Exp_table[FEC_N];
  Generate_exp_table(Exp_table);

  for (unsigned i = 1; i < FEC_N; i++)
    Table[Exp_table[i]] = i;
}

static void Generate_invert_table(fec_sym Table[FEC_N])
{
  for (unsigned i = 0; i < FEC_N; i++)
    Table[GF_exp(FEC_N - 1 - GF_log(i))] = i;
}

static void Generate_generator(fec_sym Generator[FEC_MAX_H][FEC_MAX_K])
{
  fec_sym Matrix[FEC_MAX_H][FEC_MAX_N];

  for (unsigned i = 0; i < FEC_MAX_H; i++)
    for (unsigned j = 0; j < FEC_MAX_N; j++)
      if (j == 0 || i == 0)
        Matrix[i][j] = 1;
      else
        Matrix[i][j] = GF_multiply(j + 1, Matrix[i - 1][j]);

  for (unsigned k = 0; k < FEC_MAX_H; k++)
  {
    for (unsigned i = 0; i < FEC_MAX_H; i++)
    {
      fec_sym Value = Matrix[i][FEC_MAX_N - 1 - k];
      if (Value != 0)
      {
        fec_sym Reciprocal = GF_invert(Value);
        for (unsigned j = 0; j < FEC_MAX_N; j++)
          Matrix[i][j] = GF_multiply(Matrix[i][j], Reciprocal);
      }
    }

    for (unsigned i = 0; i < FEC_MAX_H; i++)
      if (i != k && Matrix[i][FEC_MAX_N - 1 - k] != 0)
      {
        for (unsigned j = 0; j < FEC_MAX_N; j++)
          Matrix[i][j] = GF_substract(Matrix[i][j], Matrix[k][j]);
      }
  }

  for (unsigned i = 0; i < FEC_MAX_H; i++)
  {
    fec_sym Reciprocal = GF_invert(Matrix[i][FEC_MAX_N - 1 - i]);
    for (unsigned j = 0; j < FEC_MAX_K; j++)
      Generator[i][j] = GF_multiply(Matrix[i][j], Reciprocal);
  }
}

static fec_sym * * Allocate_matrix(unsigned Size)
{
  fec_sym * * Matrix = new fec_sym * [Size];
  for (int i = 0; i < Size; i++)
    Matrix[i] = new fec_sym[Size];
  return Matrix;
}

static void Free_matrix(fec_sym * * Matrix, unsigned Size)
{
  for (int i = 0; i < Size; i++)
    delete[] Matrix[i];
  delete[] Matrix;
}

static void Invert_matrix(fec_sym * * Matrix, unsigned k)
{
  fec_sym * * Result = Allocate_matrix(k);

  for (unsigned i = 0; i < k; i++)
    for (unsigned j = 0; j < k; j++)
      Result[i][j] = i == j ? 1 : 0;

  for (unsigned l = 0; l < k; l++)
  {
    int Pivot_row;
    for (unsigned i = l; i < k; i++)
      if (Matrix[i][l] != 0)
        Pivot_row = i;

    for (unsigned i = 0; i < k; i++)
    {
      fec_sym Temp = Matrix[l][i];
      Matrix[l][i] = Matrix[Pivot_row][i];
      Matrix[Pivot_row][i] = Temp;
      Temp = Result[l][i];
      Result[l][i] = Result[Pivot_row][i];
      Result[Pivot_row][i] = Temp;
    }

    fec_sym Reciprocal = GF_invert(Matrix[l][l]);
    for (unsigned i = 0; i < k; i++)
    {
      Matrix[l][i] = GF_multiply(Matrix[l][i], Reciprocal);
      Result[l][i] = GF_multiply(Result[l][i], Reciprocal);
    }

    for (unsigned i = 0; i < k; i++)
    {
      fec_sym Factor = Matrix[i][l];
      for (unsigned j = 0; j < k; j++)
        if (i != l)
        {
          Matrix[i][j] = GF_substract(Matrix[i][j], GF_multiply(Factor, Matrix[l][j]));
          Result[i][j] = GF_substract(Result[i][j], GF_multiply(Factor, Result[l][j]));
        }
    }
  }

  for (unsigned i = 0; i < k; i++)
    for (unsigned j = 0; j < k; j++)
      Matrix[i][j] = Result[i][j];

  Free_matrix(Result, k);
}

static void Precompute_matrices_h_1(fec_sym * * * Matrices, unsigned k)
{
  fec_sym Generator[FEC_MAX_H][FEC_MAX_K];
  Generate_generator(Generator);

  for (unsigned i = 0; i < k + 1; i++)
  {
    for (unsigned j = 0; j < k; j++)
      for (unsigned l = 0; l < k; l++)
      {
        unsigned Row = j < i ? j : j + 1;
        if (Row < k)
          Matrices[i][j][l] = Row == l ? 1 : 0;
        else
          Matrices[i][j][l] = Generator[0][l];
      }

    Invert_matrix(Matrices[i], k);
  }
}

static void Output_matrices(std::ostream & Stream, unsigned k)
{
  fec_sym * * * Matrices;
  Matrices = new fec_sym * * [k + 1];
  for (unsigned i = 0; i <= k; i++)
    Matrices[i] = Allocate_matrix(k);

  Precompute_matrices_h_1(Matrices, k);

  int Size = 1 << static_cast<int>(ceil(log(k) / log(2)));

  Stream << "static fec_sym Matrices_k_" << k << "_h_1[" << k + 1 << "][" << Size << "][" << Size << "] =\n{\n";
  for (unsigned i = 0; i <= k; i++)
  {
    Stream << "  {\n";
    for (unsigned j = 0; j < Size; j++)
    {
      Stream << "    {";
      for (unsigned l = 0; l < Size; l++)
      {
        unsigned Value = (j < k && l < k) ? Matrices[i][j][l] : 0;
        Stream << Value << (l != Size - 1 ? ", " : "}");
      }
      Stream << (j < Size - 1 ? ",\n" : "\n");
    }
    Stream << "  }" << (i < k ? "," : "") << "\n";
  }
  Stream << "};\n";

  for (unsigned i = 0; i <= k; i++)
    Free_matrix(Matrices[i], k);
  delete[] Matrices;
}

int main(int Count, char * Parameters[])
{
  Generate_exp_table(Exp_table);
  Generate_log_table(Log_table);
  Generate_invert_table(Invert_table);

  if (Count == 1)
  {
    std::cout << "Usage: " << Parameters[0] << " <Values for k>\n";
    return 1;
  }

  std::ofstream File("Matrices.h");
  for (unsigned i = 1; i < Count; i++)
  {
    std::istringstream Stream(Parameters[i]);
    unsigned k;
    Stream >> k;
    Output_matrices(File, k);
    if (i != Count - 1)
      File << '\n';
  }

  return 0;
}

