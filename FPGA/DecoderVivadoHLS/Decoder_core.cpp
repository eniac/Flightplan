#include "Decoder_core.h"

//#define USE_OLD_GENERATOR

static int Get_primitive_polynomial(void);
static void Generate_exp_table(fec_sym Table[FEC_N]);
static void Generate_log_table(fec_sym Table[FEC_N]);
static void Generate_invert_table(fec_sym Table[FEC_N]);

/* Addition modulo (number of symbols - 1) */
static fec_sym Modulo_add(fec_sym X, fec_sym Y)
{
#pragma HLS inline
  int Sum = X + Y;
  return Sum > FEC_N - 1 ? Sum - (FEC_N - 1) : Sum;
}

/* Add in Galois Field */
static fec_sym GF_add(fec_sym X, fec_sym Y)
{
#pragma HLS inline
  return X ^ Y;
}

/* Substract in Galois Field */
static fec_sym GF_substract(fec_sym X, fec_sym Y)
{
#pragma HLS inline
  return X ^ Y;
}

/* Exponentiate in Galois Field */
static fec_sym GF_exp(fec_sym X)
{
#pragma HLS inline
  static fec_sym Table[FEC_N];
#ifdef IN_SOFTWARE
  static int Initialized = 0;
  if (!Initialized)
  {
    Generate_exp_table(Table);
    Initialized = 1;
  }
#else
  Generate_exp_table(Table);
#endif
  return Table[X];
}

/* Logarithm in Galois Field */
static fec_sym GF_log(fec_sym X)
{
#pragma HLS inline
  static fec_sym Table[FEC_N];
#ifdef IN_SOFTWARE
  static int Initialized = 0;
  if (!Initialized)
  {
    Generate_log_table(Table);
    Initialized = 1;
  }
#else
  Generate_log_table(Table);
#endif
  return Table[X];
}

static fec_sym GF_slow_multiply(fec_sym X, fec_sym Y)
{
  fec_sym Primitive = Get_primitive_polynomial();

  fec_sym Product = 0;
  while (X > 0 && Y > 0)
  {
    if ((Y & 1) != 0)
      Product ^= X;

    if ((X & (FEC_N >> 1)) != 0)
      X = (X << 1) ^ Primitive;
    else
      X <<= 1;

    Y >>= 1;
  }

  return Product;
}

/* Multiply in Galois Field */
static fec_sym GF_multiply(fec_sym X, fec_sym Y)
{
#pragma HLS inline
  return X > 0 && Y > 0 ? GF_exp(Modulo_add(GF_log(X), GF_log(Y))) : 0;
}

static fec_sym GF_slow_invert(fec_sym X)
{
  fec_sym Product = 1;
  for (int i = 0; i < FEC_N - 2; i++)
    Product = GF_slow_multiply(Product, X);

  return Product;
}

/* Reciprocal in Galois Field */
static fec_sym GF_invert(fec_sym X)
{
#pragma HLS inline
  static fec_sym Table[FEC_N];
#ifdef IN_SOFTWARE
  static int Initialized = 0;
  if (!Initialized)
  {
    Generate_invert_table(Table);
    Initialized = 1;
  }
#else
  Generate_invert_table(Table);
#endif
  return Table[X];
}

static int Get_primitive_polynomial(void)
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
  int Primitive = Get_primitive_polynomial();

  Table[0] = 1;
  for (int i = 1; i < FEC_N; i++)
  {
    int Value = 2 * Table[i - 1];
    if (Value >= FEC_N)
      Value = Value ^ Primitive;
    Table[i] = Value;
  }
}

static void Generate_log_table(fec_sym Table[FEC_N])
{
  fec_sym Exp_table[FEC_N];
  Generate_exp_table(Exp_table);

  for (int i = 1; i < FEC_N; i++)
    Table[Exp_table[i]] = i;
}

static void Generate_invert_table(fec_sym Table[FEC_N])
{
  for (int i = 0; i < FEC_N; i++)
    Table[GF_exp(FEC_N - 1 - GF_log(i))] = i;
}

static void Generate_generator(fec_sym Generator[FEC_MAX_H][FEC_MAX_K])
{
  fec_sym Matrix[FEC_MAX_H][FEC_MAX_N];

  for (int i = 0; i < FEC_MAX_H; i++)
    for (int j = 0; j < FEC_MAX_N; j++)
      if (j == 0 || i == 0)
        Matrix[i][j] = 1;
      else
        Matrix[i][j] = GF_slow_multiply(j + 1, Matrix[i - 1][j]);

  for (int k = 0; k < FEC_MAX_H; k++)
  {
    for (int i = 0; i < FEC_MAX_H; i++)
    {
      fec_sym Value = Matrix[i][FEC_MAX_N - 1 - k];
      if (Value != 0)
      {
        fec_sym Reciprocal = GF_slow_invert(Value);
        for (int n = FEC_MAX_N - 1; n >= 0; n--)
          Matrix[i][n] = GF_slow_multiply(Matrix[i][n], Reciprocal);
      }
    }

    for (int i = 0; i < FEC_MAX_H; i++)
      if (i != k && Matrix[i][FEC_MAX_N - 1 - k] != 0)
      {
        for (int j = FEC_MAX_N - 1; j >= 0; j--)
          Matrix[i][j] = GF_substract(Matrix[i][j], Matrix[k][j]);
      }
  }

  for (int i = 0; i < FEC_MAX_H; i++)
  {
    fec_sym Reciprocal = GF_slow_invert(Matrix[i][FEC_MAX_N - 1 - i]);
    for (int j = FEC_MAX_K - 1; j >= 0; j--)
      Generator[i][j] = GF_slow_multiply(Matrix[i][j], Reciprocal);
  }
}

template<int k> void Invert_matrix(fec_sym Matrix[k][k])
{
  fec_sym Result[k][k];

  for (int i = 0; i < k; i++)
    for (int j = 0; j < k; j++)
      Result[i][j] = i == j ? 1 : 0;

  for (int l = 0; l < k; l++)
  {
    int Pivot_row;
    for (Pivot_row = l; Pivot_row < k; Pivot_row++)
      if (Matrix[Pivot_row][l] != 0)
        break;

    for (int i = 0; i < k; i++)
    {
      fec_sym Temp = Matrix[l][i];
      Matrix[l][i] = Matrix[Pivot_row][i];
      Matrix[Pivot_row][i] = Temp;
      Temp = Result[l][i];
      Result[l][i] = Result[Pivot_row][i];
      Result[Pivot_row][i] = Temp;
    }

    fec_sym Reciprocal = GF_slow_invert(Matrix[l][l]);
    for (int i = 0; i < k; i++)
    {
      Matrix[l][i] = GF_slow_multiply(Matrix[l][i], Reciprocal);
      Result[l][i] = GF_slow_multiply(Result[l][i], Reciprocal);
    }

    for (int i = 0; i < k; i++)
    {
      fec_sym Factor = Matrix[i][l];
      for (int j = 0; j < k; j++)
        if (i != l)
        {
          Matrix[i][j] = GF_substract(Matrix[i][j], GF_slow_multiply(Factor, Matrix[l][j]));
          Result[i][j] = GF_substract(Result[i][j], GF_slow_multiply(Factor, Result[l][j]));
        }
    }
  }

  for (int i = 0; i < k; i++)
    for (int j = 0; j < k; j++)
      Matrix[i][j] = Result[i][j];
}

template<int k> void Precompute_matrices_h_1(fec_sym Matrices[k + 1][FEC_MAX_K][FEC_MAX_K])
{
  fec_sym Generator[FEC_MAX_H][FEC_MAX_K];
  Generate_generator(Generator);

  for (int i = 0; i < k + 1; i++)
  {
    fec_sym Matrix[k][k];
    for (int j = 0; j < k; j++)
      for (int l = 0; l < k; l++)
      {
        int Row = j < i ? j : j + 1;
        if (Row < k)
          Matrix[j][l] = Row == l ? 1 : 0;
        else
          Matrix[j][l] = Generator[0][l];
      }

    Invert_matrix(Matrix);

    for (int j = 0; j < FEC_MAX_K; j++)
      for (int l = 0; l < FEC_MAX_K; l++)
        if (j < k && l < k)
          Matrices[i][j][l] = Matrix[j][l];
        else
          Matrices[i][j][l] = 0;
  }
}

static fec_sym Matrix_multiply(fec_sym Input[FEC_MAX_K], fec_sym Matrix[FEC_MAX_K][FEC_MAX_K],
    int Packet, int k)
{
  fec_sym Output = 0;
  for (int j = 0; j < FEC_MAX_K; j++)
    if (j < k)
      Output = GF_add(Output, GF_multiply(Input[j], Matrix[Packet][j]));
  return Output;
}

data_word Matrix_multiply_word(data_word Input[FEC_MAX_K], fec_sym Matrix[FEC_MAX_K][FEC_MAX_K],
    int Packet, int k)
{
  data_word Output = 0;
  unsigned Mask = (1 << FEC_M) - 1;
  for (int i = FEC_AXI_BUS_WIDTH / FEC_M - 1; i >= 0; i--)
  {
    fec_sym Input_symbols[FEC_MAX_K];
    for (int j = 0; j < FEC_MAX_K; j++)
      Input_symbols[j] = (Input[j] >> (FEC_M * i)) & Mask;
    fec_sym Output_symbol = Matrix_multiply(Input_symbols, Matrix, Packet, k);
    Output = (Output << FEC_M) | Output_symbol;
  }
  return Output;
}

void Lookup_matrix(fec_sym Matrix[FEC_MAX_K][FEC_MAX_K], packet_index Packet_indices[FEC_MAX_K])
{
  // This works only for k = 5 and h = 1.
  int Index = 0;
  for (int i = 0; i < 5; i++)
    if (Packet_indices[i] == i)
      Index = i + 1;

  static fec_sym Matrices[6][FEC_MAX_K][FEC_MAX_K];
  Precompute_matrices_h_1<5>(Matrices);

  for (int i = 0; i < FEC_MAX_K; i++)
	for (int j = 0; j < FEC_MAX_K; j++)
	  Matrix[i][j] = Matrices[Index][i][j];
}
