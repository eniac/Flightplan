#include "Configuration.h"
#include "rse.h"

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
void Incremental_encode(fec_sym Data, fec_sym Parity[FEC_MAX_H], int Packet_index, int h, int Clear)
{
#pragma HLS inline
  static fec_sym Generator[FEC_MAX_H][FEC_MAX_K];
#pragma HLS ARRAY_PARTITION variable=Generator complete dim=0
  Generate_generator(Generator);

  for (int i = 0; i < FEC_MAX_H; i++)
    if (i < h)
      Parity[i] = GF_add(Clear ? 0 : Parity[i], GF_multiply(Data, Generator[i][Packet_index]));
}
