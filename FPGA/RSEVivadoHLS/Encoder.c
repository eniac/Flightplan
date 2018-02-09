#include "rse.h"

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

/* Exponentiate in Galois Field */
static fec_sym GF_exp(fec_sym X)
{
#pragma HLS inline
  static fec_sym Table[FEC_N];
  Generate_exp_table(Table);
  return Table[X];
}

/* Logarithm in Galois Field */
static fec_sym GF_log(fec_sym X)
{
#pragma HLS inline
  static fec_sym Table[FEC_N];
  Generate_log_table(Table);
  return Table[X];
}

/* Multiply in Galois Field */
static fec_sym GF_multiply(fec_sym X, fec_sym Y)
{
#pragma HLS inline
  return X > 0 && Y > 0 ? GF_exp(Modulo_add(GF_log(X), GF_log(Y))) : 0;
}

/* Reciprocal in Galois Field */
static fec_sym GF_invert(fec_sym X)
{
#pragma HLS inline
  static fec_sym Table[FEC_N];
  Generate_invert_table(Table);
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

static void Generate_generator(fec_sym Generator[FEC_MAX_H][FEC_MAX_N])
{
  for (int i = 0; i < FEC_MAX_H; i++)
    for (int j = 0; j < FEC_MAX_N; j++)
      if (j == 0 || i == 0)
        Generator[i][j] = 1;
      else
        Generator[i][j] = GF_multiply(j + 1, Generator[i - 1][j]);
  //Generator[i][j] = GF_exp((i * j) % FEC_N);

  for (int k = 0; k < FEC_MAX_H; k++)
  {
    for (int i = 0; i < FEC_MAX_H; i++)
    {
      fec_sym Value = Generator[i][FEC_MAX_N - 1 - k];
      if (Value != 0)
      {
        fec_sym Reciprocal = GF_invert(Value);
        for (int n = FEC_MAX_N - 1; n >= 0; n--)
          Generator[i][n] = GF_multiply(Generator[i][n], Reciprocal);
      }
    }

    for (int i = 0; i < FEC_MAX_H; i++)
      if (i != k && Generator[i][FEC_MAX_N - 1 - k] != 0)
      {
        for (int j = FEC_MAX_N - 1; j >= 0; j--)
          Generator[i][j] = GF_add(Generator[i][j], Generator[k][j]);
      }
  }

  for (int i = 0; i < FEC_MAX_H - 1; i++)
  {
    fec_sym Reciprocal = GF_invert(Generator[i][FEC_MAX_N - 1 - i]);
    for (int n = FEC_MAX_N - 1; n >= 0; n--)
      Generator[i][n] = GF_multiply(Generator[i][n], Reciprocal);
  }
}

/*
 * This function performs the matrix multiplication that is at the core of the encoder.  It
 * multiplies an h x k generator matrix with a k-element vector with data symbols that are at the
 * same position, say i, in the k input packets.  The results is an h-element vector with parity
 * symbols that belong at position i in the parity packets.  In a more graphic representation:
 *
 *        k
 *      <--->
 *
 *   A  G G G     D  A       P  A
 * h |  G G G  X  D  | k  =  P  | h
 *   V  G G G     D  V       P  V
 */
void Matrix_multiply_HW(fec_sym Data[FEC_MAX_K], fec_sym Parity[FEC_MAX_H], int k, int h)
{
#pragma HLS ARRAY_PARTITION variable=Data complete dim=1
#pragma HLS ARRAY_PARTITION variable=Parity complete dim=1

  static fec_sym Generator[FEC_MAX_H][FEC_MAX_K] = { {76, 103, 149, 51, 248, 170, 97, 54}, {196,
      162, 35, 228, 235, 41, 35, 47}, {214, 46, 79, 120, 78, 110, 150, 125}, {95, 234, 248, 174, 92,
      236, 213, 101}};
#pragma HLS ARRAY_PARTITION variable=Generator complete dim=0
// Generate_generator(Generator);

  for (int i = 0; i < FEC_MAX_H; i++)
  {
    if (i < h)
    {
      int Result = 0;
      for (int j = 0; j < FEC_MAX_K; j++)
        if (j < k)
          Result = GF_add(Result, GF_multiply(Data[j], Generator[i][j]));
      Parity[i] = Result;
    }
  }
}

void Incremental_encode(fec_sym Data, fec_sym Parity[FEC_MAX_H], int Packet_index, int h, int Clear)
{
#pragma HLS inline
  static fec_sym Generator[FEC_MAX_H][FEC_MAX_K] = { {45, 174, 8, 13, 12, 220, 93, 128}, {154, 88,
      85, 104, 102, 162, 127, 210}, {104, 134, 120, 92, 84, 75, 183, 245}, {222, 113, 36, 56, 63,
      52, 148, 166}};
#pragma HLS ARRAY_PARTITION variable=Generator complete dim=0
// Generate_generator(Generator);

  for (int i = 0; i < FEC_MAX_H; i++)
    if (i < h)
      Parity[i] = GF_add(Clear ? 0 : Parity[i], GF_multiply(Data, Generator[i][Packet_index]));
}
