#include "Decoder_core.h"

//#define USE_OLD_GENERATOR

static unsigned Get_primitive_polynomial(void);
static void Generate_exp_table(fec_sym Table[FEC_N]);
static void Generate_log_table(fec_sym Table[FEC_N]);
static void Generate_invert_table(fec_sym Table[FEC_N]);

/* Addition modulo (number of symbols - 1) */
static fec_sym Modulo_add(fec_sym X, fec_sym Y)
{
#pragma HLS inline
  unsigned Sum = X + Y;
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
  return X != 0 && Y != 0 ? GF_exp(Modulo_add(GF_log(X), GF_log(Y))) : 0;
}

static fec_sym GF_slow_invert(fec_sym X)
{
  fec_sym Product = 1;
  for (unsigned i = 0; i < FEC_N - 2; i++)
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
        Matrix[i][j] = GF_slow_multiply(j + 1, Matrix[i - 1][j]);

  for (unsigned k = 0; k < FEC_MAX_H; k++)
  {
    for (unsigned i = 0; i < FEC_MAX_H; i++)
    {
      fec_sym Value = Matrix[i][FEC_MAX_N - 1 - k];
      if (Value != 0)
      {
        fec_sym Reciprocal = GF_slow_invert(Value);
        for (unsigned j = 0; j < FEC_MAX_N; j++)
          Matrix[i][j] = GF_slow_multiply(Matrix[i][j], Reciprocal);
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
    fec_sym Reciprocal = GF_slow_invert(Matrix[i][FEC_MAX_N - 1 - i]);
    for (unsigned j = 0; j < FEC_MAX_K; j++)
      Generator[i][j] = GF_slow_multiply(Matrix[i][j], Reciprocal);
  }
}

void Lookup_coefficients(fec_sym Coefficients[FEC_MAX_K], unsigned k, unsigned h,
    unsigned Output_packet, unsigned Missing_packet)
{
#include "Matrices.h"
  if (k == 5 && h == 1)
  {
    for (unsigned Input_packet = 0; Input_packet < FEC_MAX_K; Input_packet++)
    {
#pragma HLS pipeline
      fec_sym Value = Matrices_k_5_h_1[Missing_packet][Output_packet][Input_packet];
      Coefficients[Input_packet] = Input_packet < 5 ? Value : 0;
    }
  }
  else if (k == 50 && h == 1)
  {
    for (unsigned Input_packet = 0; Input_packet < FEC_MAX_K; Input_packet++)
    {
#pragma HLS pipeline
      fec_sym Value = Matrices_k_50_h_1[Missing_packet][Output_packet][Input_packet];
      Coefficients[Input_packet] = Input_packet < 50 ? Value : 0;
    }
  }
  else
    for (unsigned Input_packet = 0; Input_packet < FEC_MAX_K; Input_packet++)
    {
#pragma HLS pipeline
      Coefficients[Input_packet] = 0;
    }
}

static fec_sym Matrix_multiply(fec_sym Input[FEC_MAX_K], fec_sym Coefficients[FEC_MAX_K],
    unsigned k)
{
  fec_sym Output = 0;
  for (unsigned Input_packet = 0; Input_packet < FEC_MAX_K; Input_packet++)
    if (Input_packet < k)
      Output = GF_add(Output, GF_multiply(Input[Input_packet], Coefficients[Input_packet]));
  return Output;
}

data_word Matrix_multiply_word(data_word Input[FEC_MAX_K], fec_sym Coefficients[FEC_MAX_K],
    unsigned k)
{
  data_word Output = 0;
  for (int i = 0; i < FEC_AXI_BUS_WIDTH / FEC_M; i++)
  {
    fec_sym Input_symbols[FEC_MAX_K];
    for (unsigned j = 0; j < FEC_MAX_K; j++)
      Input_symbols[j] = (Input[j] << (FEC_M * i)).range(FEC_AXI_BUS_WIDTH - 1,
      FEC_AXI_BUS_WIDTH - FEC_M);
    fec_sym Output_symbol = Matrix_multiply(Input_symbols, Coefficients, k);
    Output = (Output, Output_symbol);
  }
  return Output;
}
