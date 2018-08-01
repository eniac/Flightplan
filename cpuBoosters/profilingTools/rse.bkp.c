/*
 * RSE.C
 * Forward Erasure Correction encoder and decoder
 *
 * Developed for DARPA (#DABT63-95-C) by 
 * A. McAuley, Bellcore (mcauley@bellcore.com)
 *
 * Modifications for High speed:
 * 	9/1997   Vinh Lam (for NRL)
 *
 * Modifications for dynamic addition of parity
 *  10/2017   A. McAuley, Vencore (amcauley@vencorelabs.com)
 *
 * For description and more detailed revision history see README_RDE.txt
 */

#include "rse.h"
#include <stdlib.h>

#ifdef VERIFY_HLS
#include "RSE_core_test.h"
#endif


#include "../cpuBoosters/profilingTools/perfCounterInterface.h"

/***************************************************************************/
/* Global variables ... ugly but fast and easy (including GF Match Tables) */
/***************************************************************************/
struct fec_block    fbk[MAX_FEC_BLOCKS];        /* paralle FEC blocks */
struct fec_matrices fcm;                /* H x H+1 FEC encode/decode store */

fec_sym	fec_2_log[FEC_N];                       /* index->power table */
fec_sym	fec_2_exp[FEC_N];                       /* power->index table */
fec_sym	fec_invefec[FEC_N];                     /* multiplicative inverse */
fec_sym	fec_weights[FEC_MAX_H][FEC_MAX_N];      /* FEC weight table */

#ifdef FEC_MAC_LOOKUP                         

/* putting lookup table on heap instead may speed up access */
fec_sym gf_mult_table[FEC_N][FEC_N];            /* Multiplication table */

#endif

/***************************************************************************/
/* GF MATH: MULTIPLY & ACCUMULATE (p = p + a.b) (heart of coder, so macro) */
/***************************************************************************/

#ifdef FEC_MAC_LOOKUP		/* do 1 lookup in a size n.n table */

#define FEC_MAC(a,b,p)\
{\
  if (a && b) \
    p ^= (fec_sym)(*((fec_sym *)gf_mult_table + (a << FEC_M) + b));\
}

#else				/* do 3 lookups into a size n table */

#define FEC_MAC(a,b,p)\
{\
  if (a && b) \
     {\
     if ((fec_2_log[a]+fec_2_log[b]) > FEC_N-1) \
        p ^= fec_2_exp[((fec_2_log[a]+fec_2_log[b])-(FEC_N-1))];\
     else \
        p ^= fec_2_exp[(fec_2_log[a]+fec_2_log[b])];\
     }\
}

#endif

/* GF multiply only (no accumulate) */

#define FEC_GF_MULT(a,b) ((a && b) ? (((fec_2_log[a]+fec_2_log[b]) > FEC_N-1) ? (fec_2_exp[((fec_2_log[a]+fec_2_log[b])-(FEC_N-1))]) : (fec_2_exp[(fec_2_log[a]+fec_2_log[b])])) : 0)


/***************************************************************************/
/* GF Math: 1xN Tables for Log, Exp, Inverse. Optional NxN Multiply table  */
/***************************************************************************/
/*
 * Find irred. polynomial for Modulus
 * NB: Modulus is one bit bigger than fec_sym so use integers
 */
int gf_math_find_mod(void)
{
    int	modulus;
    
    switch (FEC_M) {
        case   3: modulus = 0xb; break;
        case   4: modulus = 0x13; break;
        case   5: modulus = 0x25; break;
        case   6: modulus = 0x43; break;
        case   7: modulus = 0x89; break;
        case   8: modulus = 0x11d; break;
        case  16: modulus = 0x1100b; break;
        default:
            D0(fprintf(stderr, "Don't know mod FEC_M=%d\n", FEC_M));
            return (FEC_ERR_MOD_NOT_FOUND);
    }
    return (modulus);
}

/*
 * Display Log and Inversion Tables
 */
#ifdef FEC_DBG_MATH_TABLES
void gf_math_log_tables_display(void)
{
    int		i, mod;

    mod = gf_math_find_mod();
    fprintf(stderr, "\n%d-bit Symbol Operations in GF(%d)\n", FEC_M, FEC_N);
    fprintf(stderr, "num  2_exp 2_log  invefec  (mod=0x%x)\n", mod);
    fprintf(stderr, " i    2^i  log(i) 1/i\n");
    for (i=0; i<FEC_N; i++) {
        fprintf(stderr, "%2x    %2x    ", i, fec_2_exp[i]);
        fprintf(stderr, "%2x    %2x\n", fec_2_log[i], fec_invefec[i]);
        if (i >= MAX_PRINT_COLUMNS)  {
            fprintf(stderr, "... (%d of %d)\n",MAX_PRINT_COLUMNS, FEC_N);
            break;
        }
    }
}
#endif

/*
 * Generate index<->power and invefec tables
 *   a) index, bits of the polynomial representation
 *   b) power of the primitive element "1"
 *   c) invefec (a.b=1)
 */
void gf_math_log_tables_generate(void) {

    int   mod;
    int   temp;			/* use temp to prevent overflow */
    int   i;

    mod = gf_math_find_mod();
    /* i = LOG (index) of the polynomial number (POLY): POLY = g^i   */
    for (i=0; i<FEC_N; i++) {
        if (i==0)
            /* g^0 = 1 */
            fec_2_exp[i] = 1;
        else {
            /* ASSUMES 2 is a primitive element of the field */
            /* SHOULD use diffent polynomical or different primitive element if not true */
            /* Use GF generator (primitive element) g = 2: g^i = g^(i-1) * 2 */
            temp = fec_2_exp[i-1]<<1;
            /* If carry, XOR with GF irreducible polynomial (mod) */
            if (temp>=FEC_N) fec_2_exp[i] = temp^mod;
            else             fec_2_exp[i] = temp;
        }
        
        fec_2_log[fec_2_exp[i]] = i;		/* 0'th index is not used */
    }
  for (i=0; i<FEC_N; i++) fec_invefec[fec_2_exp[FEC_N-1-fec_2_log[i]]]=i;
#ifdef FEC_DBG_MATH_TABLES
    gf_math_log_tables_display();
#endif
}

#ifdef FEC_MAC_LOOKUP
#ifdef FEC_DBG_MATH_TABLES
/*
 * Print contents of Multiplication Table
 */
void gf_math_mult_tables_print(fec_sym gf_table[FEC_N][FEC_N]) {
    int i=0, j=0, mod, cols_max;
    char s[4] = "";
    fec_sym tt;
    
    mod = gf_math_find_mod();
    fprintf(stderr, "\nMultiplication Table in GF(2^%d) mod=0x%x (using %lu Bytes of RAM)\n", FEC_M, mod, (sizeof(tt))*FEC_N*FEC_N/2);
    
    cols_max = FEC_N;
    if (FEC_N > MAX_PRINT_COLUMNS ) {
        cols_max = MAX_PRINT_COLUMNS;
        strcpy(s, "...");
    }
    
    fprintf(stderr, "     ");
    for (i=0; i < cols_max; i++) {
        fprintf(stderr, "%04x ", i);
    }
    if (FEC_N > MAX_PRINT_COLUMNS ) fprintf(stderr, "... (%d of %d)", MAX_PRINT_COLUMNS, FEC_N);
    fprintf(stderr, "\n");
    for (i=0; i < cols_max; i++) {
        fprintf(stderr, "%04x ", i);
        for (j=0; j < cols_max; j++) {
            fprintf(stderr, "%04x ", gf_table[i][j]);
        }
        fprintf(stderr, "%s\n", s);
    }
    if (FEC_N > MAX_PRINT_COLUMNS ) fprintf(stderr, "... (%d of %d)", MAX_PRINT_COLUMNS, FEC_N);
    fprintf(stderr, "\n");
}
#endif   /* DBG_MATH_TABLES */

/*
 * GF Multiplication Table
 */
void gf_math_mult_tables_generate(fec_sym gf_table[FEC_N][FEC_N]) {
    int i=0, j=0;
    
    for (i=0; i < FEC_N; i++) {
        for (j=0; j < FEC_N; j++) {
            gf_table[i][j] = FEC_GF_MULT(i,j);
        }
    }
#ifdef FEC_DBG_MATH_TABLES
    gf_math_mult_tables_print(gf_table);
#endif
}
#endif   /* FEC_MAC_LOOKUP */

/***************************************************************************/
/* Matrix Solver                                                           */
/***************************************************************************/
/*
 * Display 2D Matrix
 */
#ifdef FEC_DBG_LEVEL_0
void matrix_display(fec_sym *p, fec_sym rows_max, fec_sym cols_max, fec_sym cols_in_array) {

    int i, j;
    char s[4] = "";

//    fprintf(stderr, "(%p)\n", p);
    
    if (cols_max > MAX_PRINT_COLUMNS ) {
        cols_max = MAX_PRINT_COLUMNS;
        strcpy(s, "...");
    }
    
    if (cols_max > MAX_PRINT_COLUMNS ) cols_max = MAX_PRINT_COLUMNS;
    for (i=0; i<rows_max; i++) {
        fprintf(stderr, "%s ", s);
        for (j=cols_max-1; j>=0; j--) {
            fprintf(stderr, " %4x", *(p+(i*cols_in_array)+j));
//            fprintf(stderr, " (%p) ", (p+(i*cols_in_array)+j));
        }
        fprintf(stderr, "  ... eq%1x ", i);
        fprintf(stderr, "\n");
    }
}
#endif

/*
 * Transform matrix p, so leftmost part is the Identity Matrix
 * Number of Columns (cols_max) >= Number of Rows (rows_max)
 *
 * Tranform rows_max by cols_max in Matrix p (where cols_max > rows_max)
 *   When cols_max = rows_max + 1 it solves row_max simultaneous equations
 *   (with row_max unknowns)
 *   Normally, cols_in_array = cols_max, however p can have more than
 *   cols_max columns, as specified by cols_in_array value
 *
 * Example for transforming Reed Sololmon Codeword Matrix:
 *    c6 c5 c4 c3 c2 c1 c0   c6 c5 c4 c3 c2 c1 c0
 *    p0 p1 p2 d3 d2 d1 d0   p0 p1 p2 d3 d2 d1 d0
 *    1  1  1  1  1  1  1    1  0  0  6  1  6  7 ... eq0
 *    5  7  6  3  4  2  1 -> 0  1  0  4  1  5  5 ... eq1
 *    7  3  2  5  6  4  1    0  0  1  3  1  2  3 ... eq2
 *
 * Example of solving simultaneous equestions with two unknowns
 * (rows_max=2, cols_max=3, cols_in_array=5)
 *    xx xx 07 01 00 -> xx xx 01 00 03
 *    xx xx 05 01 06    xx xx 00 01 02
 * Solution is column 2 = 03  and column 1 = 02.
 */
int matrix_solve(fec_sym *p, fec_sym rows_max, fec_sym cols_max, fec_sym cols_in_array) {

    fec_sym	*n, *m, *q, *r, inv;
    fec_sym	i, j, k, v;
    
#ifdef FEC_DBG_MATRIX_TRANS
    fprintf(stderr, "Transform %d by %d Matrix (with %d coluns) {%p}\n",  rows_max, cols_max, cols_in_array, p);
    matrix_display(p, rows_max, cols_max, cols_in_array);
#endif
    for (k=0; k<rows_max; k++) {            /* k = column index - from right (Loop 1) */
#ifdef FEC_DBG_MATRIX_TRANS
        fprintf(stderr, "Step 1a) col-%d (from left) set to 1's and 0's, by multiplying each row\n", k);
#endif
        for (i=0; i<rows_max; i++) {              /* i = row index - from top (Loop 2) */
            m = p+(i*cols_in_array);     /* rightmost column index in row i */
            q = m + cols_max - 1;        /* leftmost  column index in row i */
            v = *(q-k);                           /* Value of entry in k'th from left column */
#ifdef FEC_DBG_MATRIX_TRANS
            fprintf(stderr, "Pointers[%p - %p] Value[%x]  ", q, m, v);
#endif
            if (v != 0) {
                inv = fec_invefec[*(q-k)];        /* invert value */
                for (n=q; n>=m; n--)               /* n = index to cells in row i (Loop 3) */
                    *n = FEC_GF_MULT(*n, inv);    /* Multiply by inverse */
#ifdef FEC_DBG_MATRIX_TRANS
                fprintf(stderr, "row-%d %x inv=%x, ", i, *n, inv);
#endif
            }
        }

#ifdef FEC_DBG_MATRIX_TRANS
        fprintf(stderr, "\n");
        matrix_display(p, rows_max, cols_max, cols_in_array);
        fprintf(stderr, "Step 1b) Add row-%d to all rows (except for row-%d)\n", k, k);
#endif
        r = (p+(k*cols_in_array)+cols_max-1);	     	/* leftmost (last) column in k row */
        for (i=0; i<rows_max; i++) {                    /* for all rows, except k'th */
            if (i!=k) {
                q = (p+(i*cols_in_array)+cols_max-1);   /* Get last leftmost (last) column */
                if (*(q-k) != 0) {                      /* Do not add if already 0 */
                    for (j=0; j<cols_max; j++)
                        *(q-j) = *(q-j) ^ (*(r-j));     /* add k'th row to each (for all columns */
                }
            }
        }
#ifdef FEC_DBG_MATRIX_TRANS
        matrix_display(p, rows_max, cols_max, cols_in_array);
#endif
    }
    
#ifdef FEC_DBG_MATRIX_TRANS
    fprintf(stderr, "Step 2) Multiply each row by inverse make elements in triangle 1's\n");
#endif
    for (i=0; i<rows_max-1; i++) {                      /* for all rows, except bottom (last) */
        q = (p+(i*cols_in_array)+cols_max-1);           /* leftmost (last) column in row i */
        m = q - cols_max;                               /* righmost (first) + 1 column in row i */
        inv = fec_invefec[*(q-i)];                      /* inverse for row i */
#ifdef FEC_DBG_MATRIX_TRANS
        fprintf(stderr, "row-%d inv=%2x, ", i, inv);
#endif
        for (n=q; n>m; n--)                             /* For all columns (left to right) */
            *n = FEC_GF_MULT(*n, inv);
    }

#ifdef FEC_DBG_MATRIX_TRANS
    fprintf(stderr, "\n");
    matrix_display(p, rows_max, cols_max, cols_in_array);
#endif
    
    return (0);
}

/***************************************************************************/
/* FEC Codework Generation (only done once per run)                        */
/***************************************************************************/

#if defined(FEC_DBG_LEVEL_1) || defined(FEC_DBG_PRINT_RS)
void codewords_print_header(fec_sym rows_max, fec_sym cols_max) {

    int i, j=0;
    char s[4] = "";
    
    if (cols_max > MAX_PRINT_COLUMNS ) {
        cols_max = MAX_PRINT_COLUMNS;
        strcpy(s, "...");
    }
    
    fprintf(stderr, "%s ", s);
    /* Print codeword symbol headers */
    for (i=cols_max-1; i>=0; i--) {
        fprintf(stderr, " c%03x", i);
    }
    fprintf(stderr, "\n%s ", s);
    /* Print parity and data symbol headers */
    for (i=cols_max-1; i>=0; i--) {
        if (i < FEC_MAX_K) {
            fprintf(stderr, " d%03x", i);
        }
        else {
            fprintf(stderr, " p%03x", j);
            j++;
        }
    }
    fprintf(stderr, "\n");
}
#endif

/*
 * Generate Weight matrix
 */
int codewords_generate(void) {

    int rc;
    fec_sym i, j;

    /* fec_weights[i][j] = j ^ i = j * w[i, j-1] (if j=0, then w = 1) */
    for (i=0; i<FEC_MAX_H; i++)                                 /* rows */
        for (j=0; j<FEC_MAX_N; j++) {                           /* columns */
            if ((j==0) || (i==0))  fec_weights[i][j] = 1;
            else                   fec_weights[i][j] = FEC_GF_MULT(j+1, fec_weights[i-1][j]);
//SEP2017 Version            fec_weights[i][j] = fec_2_exp[(i*j%FEC_N)];         /* FEC 1 */
        }
#ifdef FEC_DBG_PRINT_RS
    fprintf(stderr, "Systematic Reed-Solomom h x n (%d x %d) equations:\n", FEC_MAX_H, FEC_MAX_N);
    codewords_print_header(FEC_MAX_H, FEC_MAX_N);
    matrix_display((fec_sym *)fec_weights, FEC_MAX_H, FEC_MAX_N, FEC_MAX_N); 		/* debug */
#endif

    if ((rc = matrix_solve((fec_sym *)fec_weights, FEC_MAX_H, FEC_MAX_N, FEC_MAX_N)) != 0 ) return (rc);

    D1(fprintf(stderr, "\nStep 0) Generated Modified Reed-Solomom code of h equations with n words each (%d x %d matrix):\n", FEC_MAX_H, FEC_MAX_N));
    D1(codewords_print_header(FEC_MAX_H, FEC_MAX_N));
    D1(matrix_display((fec_sym *)fec_weights, FEC_MAX_H, FEC_MAX_N, FEC_MAX_N));

    return (0);
}

/*
 * Check FEC block parameters are reasonable
 */
int codewords_check_bounds(void) {
    fec_sym i;
    int64_t  j;         //    Used to be long long int, but got wanrings
    
    if (FEC_MAX_N > FEC_N) {
        D0(fprintf (stderr, "\n FEC_MAX_N (%d) > FEC_N (%d)\n", FEC_MAX_N, FEC_N));
        return (FEC_ERR_INVALID_PARAMS);
    }
    if (FEC_EXTRA_COLS >= FEC_MAX_COLS) {
        D0(fprintf (stderr, "\n FEC_EXTRA_COLS (%d) >= FEC_MAX_COLS (%d)\n", FEC_EXTRA_COLS, FEC_MAX_COLS));
        return (FEC_ERR_INVALID_PARAMS);
    }
    if (FEC_EXTRA_COLS > 0) {
          j = (int64_t) 2 << (FEC_M * FEC_EXTRA_COLS - 1);

        if (FEC_MAX_COLS >= j) {
            D0(fprintf (stderr, "\n FEC_EXTRA_COLS (%d) can only store packets of length %lu, not FEC_MAX_COLS (%d)\n", FEC_EXTRA_COLS, (unsigned long) j-1, FEC_MAX_COLS));
            return (FEC_ERR_INVALID_PARAMS);
        }
    }
    
    if (FEC_MAX_COLS < 1) {
        D0(fprintf (stderr, "\n FEC_MAX_COLS (%d) < 1\n", FEC_MAX_COLS));
        return (FEC_ERR_INVALID_PARAMS);
    }
    if (sizeof(i) < (FEC_M/8)) {
        D0(fprintf (stderr, "\n fec_sym typedef has too few bytes (%lu) to store (FEC_M = %d bit) FEC symbol\n", sizeof(i), FEC_M));
        return (FEC_ERR_INVALID_PARAMS);
    }
    return (0);
}

int rse_init(void) {
    int rc;

    if ((rc = codewords_check_bounds()))  return (rc);
    gf_math_log_tables_generate();
#ifdef FEC_MAC_LOOKUP
    gf_math_mult_tables_generate(gf_mult_table);
#endif
    if ((rc = codewords_generate()))  return (rc);
    return (0);
}

/***************************************************************************/
/* Utilities */
/***************************************************************************/
/*
 * 1) Calculate delta from last time called and
 * 2) Print (if tag > 0 and label >= FEC_SPEED_TEST)
 */
#ifdef FEC_SPEED_TEST
unsigned long fec_get_time_delta(int label, int tag) {
    
    struct    timeval           tp;
    unsigned  long              t_old;
    static    unsigned  long    t_new[10]={0};
    
    if (gettimeofday(&tp, NULL) < 0) {
        fprintf (stderr, "Could not get time \n");
        exit (1);
    }
    t_old = t_new[label];
    t_new[label] = (1000000*tp.tv_sec)+tp.tv_usec;
    if ((tag > 0) && (label >= FEC_SPEED_TEST)) fprintf(stderr, "delta %d-%d = %lu μs\n", label, tag, t_new[label]-t_old);
    return (t_new[label]-t_old);
}
#endif

/***************************************************************************/
/* FEC Block - Basic: referred by global pointer fb (structure in rse.h)   */
/***************************************************************************/
/*
 * Print FEC Block extras (status flag)
 */
void fec_block_print_packet_extras(struct fec_block fb, int i) {
    switch(fb.pstat[i]) {
        case FEC_FLAG_NULL :
            fprintf(stderr, "Null\n");
            break;
        case FEC_FLAG_KNOWN :
            fprintf(stderr, "Known\n");
            break;
        case FEC_FLAG_WANTED :
            fprintf(stderr, "Wanted\n");
            break;
        case FEC_FLAG_IGNORE :
            fprintf(stderr, "Ignore\n");
            break;
        case FEC_FLAG_GENNED :
            fprintf(stderr, "Generated\n");
            break;
        case FEC_FLAG_GENOLD :
            fprintf(stderr, "Gen (old)\n");
            break;
        default :
            fprintf(stderr, "????\n");
    }
}

/*
 * Print FEC Block
 */
void fec_block_print(int fb_index) {
    
    fec_sym i;
    int j;
    char pkt_want[10] = "????", pkt_short[10]="----";
    
    fprintf(stderr, "FEC Block n=%d c=%d+%d (parities start at cbi-%02x)\n", fbk[fb_index].block_N, fbk[fb_index].block_C-FEC_EXTRA_COLS, FEC_EXTRA_COLS, FEC_MAX_K);
    
    /* Shorten (put spaces) in what is printed if fec_sym is just one character */
    if (sizeof(i) < 2) {
        for (i=0; i<2; i++) {
            pkt_want[i]=' ';
            pkt_short[i]=' ';
        }
    }

    for (i=0; i<fbk[fb_index].block_N; i++) {                    /* All rows in FEC Block (data and Parity) */
//fprintf(stderr, "** %p (%x) ** ", fbk[fb_index].pdata[i], *fbk[fb_index].pdata[i]);
        if (fbk[fb_index].pstat[i] != FEC_FLAG_IGNORE ) {
            fprintf(stderr, "fbi-%02x cbi-%02x: ", i, fbk[fb_index].cbi[i]);
            if (fbk[fb_index].cbi[i] < FEC_MAX_K)   fprintf(stderr, "d-%02x ", i);
            else     fprintf(stderr, "p-%02x ", FEC_MAX_N - fbk[fb_index].cbi[i] - 1);
            fprintf(stderr, "(ptr=%p) ", (void *) fbk[fb_index].pdata[i]);
            fprintf(stderr, "len=%d: ", fbk[fb_index].plen[i]);
            for (j=fbk[fb_index].block_C-1; j>=0; j--) {         /* All Symbols (Coumns) in packet */
              switch (fbk[fb_index].pstat[i]) {
                case FEC_FLAG_WANTED:   fprintf(stderr, "%s  ", pkt_want);
                                        break;
                case FEC_FLAG_KNOWN:
                case FEC_FLAG_GENOLD:
                case FEC_FLAG_GENNED:   if (fbk[fb_index].plen[i] > j)
                                            fprintf(stderr, "%4x  ",*(fbk[fb_index].pdata[i]+j));
                                        else
                                            fprintf(stderr, "%s  ", pkt_short);
                                        break;
                case FEC_FLAG_IGNORE:   fprintf(stderr, "%s  ", pkt_want);
                                        break;
                default:                fprintf(stderr, "^^^^^^^^^^");
                                        break;
              }
              if (j < fbk[fb_index].block_C-MAX_PRINT_COLUMNS + 1)  {
                  fprintf(stderr, "... (%d of %d) ",MAX_PRINT_COLUMNS, fbk[fb_index].block_C);
                  break;
              }
            }
            fec_block_print_packet_extras(fbk[fb_index], i);
        }
    }
    fprintf(stderr, "\n");
}
#ifdef FEC_DBG_LEVEL_0
#endif

/*
 * Delete Packets from FEC Block with given FEC block indices (fbis)
 * Until delete_fbis[i]=FEC_MAX_N (end of list marker)
 */
void fec_block_delete(int fb_index, int *delete_fbis) {
    int i;
    fec_sym fbi=0, cbi;
    
//    fprintf (stderr, "Parity cbi start = %d (STOP at %d)\n", FEC_MAX_K, FEC_N-1);
    for (i=0; delete_fbis[i]<FEC_MAX_N; i++) {
        fbi = (fec_sym) delete_fbis[i];
        cbi = fbk[fb_index].cbi[fbi];
//        fprintf (stderr, "fbi=%d cbi=%d\n", fbi, cbi);
        if (cbi < FEC_MAX_K) {
            fbk[fb_index].pstat[fbi] = FEC_FLAG_WANTED;
        }
        else {
            fbk[fb_index].pstat[fbi] = FEC_FLAG_IGNORE;
        }
        fbk[fb_index].plen[fbi]=0;
    }
    
    /* Marked generated parity packet as Known */
    for (i=0; i<fbk[fb_index].block_N; i++) {             /* All rows in FEC Block (data and Parity) */
        if ((fbk[fb_index].cbi[i] >= FEC_MAX_K) && ((fbk[fb_index].pstat[i] == FEC_FLAG_GENNED) || (fbk[fb_index].pstat[i] == FEC_FLAG_GENOLD))) {
            fbk[fb_index].pstat[i] = FEC_FLAG_KNOWN;
        }
    }
}

/*
 * Check FEC block parameters are reasonable
 */
int fec_block_check(int fb_index) {

    if (((int) fbk[fb_index].block_N >= FEC_N) || ((int) fbk[fb_index].block_C > FEC_MAX_COLS) ||
      (fbk[fb_index].block_N < 1) || (fbk[fb_index].block_C < 1)) {
        D0(fprintf (stderr, "FEC block parameters out of bound: "));
        D0(fprintf (stderr, "(0 <= n (%d) < FEC_MAX_N (%d))\n", fbk[fb_index].block_N, FEC_N));
        D0(fprintf (stderr, "(0 <  c (%d) < FEC_MAX_COLS (%d)) ", fbk[fb_index].block_C, FEC_MAX_COLS));
        return (FEC_ERR_INVALID_PARAMS);
    }
    return (0);
}

/***************************************************************************/
/* FEC Block - Packet Types (using a) COUNT_XX and b) fbi array INDEX_XX)  */
/***************************************************************************/
/*
 * Check if k KNOWN, p PARITIES and h WANTED packets are
 * a) Enough to allow coding
 * b) Within code range
 */
int fec_block_types_check(fec_sym COUNT_KNOW, fec_sym COUNT_WANT, fec_sym COUNT_PARI) {
//    fec_sym data_packet_count;
    
    if ((COUNT_KNOW < 1) || (COUNT_WANT < 1) || (COUNT_PARI < COUNT_WANT) ) {
        D0(fprintf(stderr, "a) To code must have: number PARI (%d) >= WANT (%d) (and WANT and KNOW (%d) > 0)\n", COUNT_PARI, COUNT_WANT, COUNT_KNOW));
        return (FEC_ERR_ENC_MISSING_DATA);
    }
    if ((COUNT_PARI > FEC_MAX_H)) {
        D0(fprintf(stderr, "b) number parity packets (%d) > FEC_MAX_H (%d)\n", COUNT_PARI, FEC_MAX_H));
        return (FEC_ERR_ENC_MISSING_DATA);
    }
    return (0);
}

/*
 * Print fec block and codeword indices stored in matrix INDEX (of size COUNT)
 */
#ifdef FEC_DBG_LEVEL_2
void  fec_block_types_print_indices(int fb_index, const char *string, fec_sym COUNT, fec_sym *INDEX) {
    fec_sym i;
    
    fprintf(stderr, "%s%d fbi {cbi}: ", string, COUNT);
    for (i=0; i<COUNT; i++)
    fprintf(stderr, "%d {%02x}, ", INDEX[i], fbk[fb_index].cbi[INDEX[i]]);
    fprintf(stderr, "\n");
}
#endif

/*
 * Put fec block indices of packet's status (known, wanted and parity)
 * into 3 matricies (e.g. INDEX_KNOW[]).
 * Also return how many packets are of each type (e.g. COUNT_KNOW)
 */
int fec_block_types_find(int fb_index, fec_sym *INDEX_KNOW, fec_sym *INDEX_WANT, fec_sym *INDEX_PARI, fec_sym *COUNT_KNOW, fec_sym *COUNT_WANT, fec_sym *COUNT_PARI) {
    
    fec_sym i;
    
    for (i=0; i<fbk[fb_index].block_N; i++) {
        if (fbk[fb_index].pstat[i] == FEC_FLAG_WANTED) {
            INDEX_WANT[*COUNT_WANT] = i;
            (*COUNT_WANT)++;
        }
        if ((fbk[fb_index].pstat[i] == FEC_FLAG_KNOWN) || (fbk[fb_index].pstat[i] == FEC_FLAG_GENNED))
        {
            INDEX_KNOW[*COUNT_KNOW] = i;
            (*COUNT_KNOW)++;
        }
        if ((fbk[fb_index].cbi[i] >= FEC_MAX_K ) && (fbk[fb_index].pstat[i] != FEC_FLAG_IGNORE) && (fbk[fb_index].pstat[i] != FEC_FLAG_GENOLD))
        {
            INDEX_PARI[*COUNT_PARI] = i;
            (*COUNT_PARI)++;
        }
    }
    D2(fec_block_types_print_indices(fb_index, "Know k=", *COUNT_KNOW, INDEX_KNOW));
    D2(fec_block_types_print_indices(fb_index, "Want h=", *COUNT_WANT, INDEX_WANT));
    D2(fec_block_types_print_indices(fb_index, "Pari p=", *COUNT_PARI, INDEX_PARI));
    return (fbk[fb_index].block_C);
}

void fec_block_add_packet(int fb_index, fec_sym *p, fec_sym fbi, fec_sym cbi, int length, char flag) {
    fbk[fb_index].pdata[fbi] = p;
    fbk[fb_index].cbi[fbi]   = cbi;
    fbk[fb_index].plen[fbi]  = length;
    fbk[fb_index].pstat[fbi] = flag;
    if (length > fbk[fb_index].block_C)  fbk[fb_index].block_C = length;
}

/*
 * Write information about a single packet into an FEC block (index = fb_index)
 *    Wrtten into entry FEC BLock Index = Code Block Index = fbi
 */
int fec_block_add_data_packet(int fb_index, fec_sym *p, fec_sym fbi, int length, char flag) {
    int     vlen;
    
    fec_block_add_packet(fb_index, p, fbi, fbi, length, flag);
    vlen = length + FEC_EXTRA_COLS;
    if (vlen > fbk[fb_index].block_C)  fbk[fb_index].block_C = vlen;
    return (fbk[fb_index].block_C);                 /* Return length of longest packet */
}

/*
 * Write information about a single packet into an FEC block (index = fbi)
 *    Wrtten into entry FEC Block Index, fbi = k + parity_index
 *    Code Block Index, cbi = FEC_MAX_N - 1 - parity_index - offset
 */
int fec_block_add_parity_packet(int fb_index, fec_sym *p, fec_sym parity_index, fec_sym k, fec_sym offset, int length, char flag) {
    fec_sym     cbi, fbi;
    
    cbi = FEC_MAX_N - offset - parity_index - 1;            /* Codeword Block index */
    fbi = k + parity_index;                                 /* FEC Block index */
    fec_block_add_packet(fb_index, p, fbi, cbi, length, flag);   /* add packet to fb */
    return fbk[fb_index].block_C;                           /* Return length of longest packet */
}

/*
 * Write information about a single WANTED packet into an FEC block (index = fbi)
 */
int fec_block_add_wanted_packet(int fb_index, fec_sym *p, fec_sym fbi, fec_sym k, fec_sym offset, int length) {
    fec_sym cbi;
    
    if (fbi < k)    cbi = fbi;
    else            cbi = FEC_MAX_N - offset - 1 + k - fbi;
    fec_block_add_packet(fb_index, p, fbi, cbi, length, FEC_FLAG_WANTED);   /* add packet to fb */
    
    return (fbk[fb_index].plen[fbi]);
}

/*
 * Get information about size (symbols) of the packet in FEC block[fb_index] with index = fbi
 */
int fec_block_get_len(int fb_index, fec_sym fbi) {
    return (fbk[fb_index].plen[fbi]);
}

/*
 * Get information about combined size (bits) of packet in FEC block[fb_index]
 */
unsigned long fec_block_number_of_data_bits(int fb_index) {
    fec_sym i;
    unsigned  long     symbol_count=0;
    
    for (i=0; i<fbk[fb_index].block_N; i++) {
        if (fbk[fb_index].cbi[i] < FEC_MAX_K) {
            symbol_count += fbk[fb_index].plen[i];
            //            fprintf(stderr, "Symbol %d = %d bits\n", fbk[fb_index].cbi[i], fbk[fb_index].plen[i]);
        }
    }
    return (symbol_count * sizeof(i) * 8);
}


/*
 * Initialize FEC block so:
 *     k data packets are marked as "data_flag" (normally FEC_FLAG_WANTED)
 *     h parity packets are maked as "parity_flag" (encoder = WANTED, decoder = IGNORE)
 *        (Do not change flag if input is FEC_FLAG_NULL)
 *     Sets the Packet length and all pointers to 0
 */
void fec_block_init(int fb_index, fec_sym k, fec_sym h, char data_flag, char parity_flag) {
    fec_sym index;

    if (data_flag != FEC_FLAG_NULL) {        /* Not regenerating additional parity */
        for (index=0; index < k; index++) {
            fec_block_add_data_packet(fb_index, 0, index, 0, data_flag);
        }
    }
    if (parity_flag != FEC_FLAG_NULL) {        /* Not currently used - but left in case */
        for (index=0; index < h; index++) {
            fec_block_add_parity_packet(fb_index, 0, index, k, 0, 0, parity_flag);
        }
    }
    fbk[fb_index].block_C = 0;
    fbk[fb_index].block_N = k + h;
}

/*
 * Add 'count' additional parity packets to an FEC Block (index=fb_index)
 */
fec_sym fec_block_add(int fb_index, int count) {
    fec_sym fbi;
    int  i;
    
    fbi = fbk[fb_index].block_N;            /* Old number of packets */
    for (i=0; i<fbi; i++) {
        if (fbk[fb_index].pstat[i] == FEC_FLAG_GENNED)  fbk[fb_index].pstat[i] = FEC_FLAG_GENOLD; // FEC_FLAG_KNOWN;
    }
    fbk[fb_index].block_N += count;         /* New number of packets */
    return (fbi);
}

/***************************************************************************/
/* Code Matices Operations (using global structure fcm)                    */
/***************************************************************************/
/*
 * Print the "pari" equations in "want" unknowns
 *  Stored as a matrix in the FEC Matrices (fcm) with FEC_MAX_H+1 columns
 *  (column 0 has the accumulated sums - hence the want+1 columns to dispay)
 */
#if defined (FEC_DBG_LEVEL_1) || defined (FEC_DBG_LEVEL_3)
void code_equation_print(char type, fec_sym pari, fec_sym want) {
    fec_sym *p;
    
    if (type != 'e') {
        fprintf(stderr, "Duplicate Equation:\n");
        p=fcm.d[0];
    }
    else {
        fprintf(stderr, "Equation:\n");
        p=fcm.e[0];
    }
    matrix_display(p, pari, want+1, FEC_MAX_H+1);
}
#endif

/*
 * Duplicate contents of h-row x (h+1)-column Equation matrix
 */
void code_equations_duplicate(fec_sym size) {
    fec_sym row, col;
    
    for (row=0; row < size; row++)
        for (col=0; col<=size; col++)
            fcm.d[row][col] = fcm.e[row][col];
}

/*
 * Create the Matrix Equations to solve from the fec_weights matrix:
 *    Columns correspond to the unknown (WANteD) variables
 *    Rows for encode and decode = PARITIES
 */
void code_equations_generate(int fb_index, fec_sym COUNT_WANT, fec_sym *INDEX_WANT, fec_sym COUNT_PARI, fec_sym *INDEX_PARI) {
    fec_sym i, j, q, z, row;
    
    for (i=0; i < COUNT_PARI ; i++) {
        row = FEC_MAX_N - fbk[fb_index].cbi[INDEX_PARI[i]] - 1;    /* Codework Row where we have PARI */
        for (j=0; j<COUNT_WANT; j++) {
            q = fbk[fb_index].cbi[INDEX_WANT[j]];               /* Codework Column we WANT */
            z = COUNT_WANT - j;
//            fprintf(stderr, "Row (r=%d -> i=%d) Column (q=%x -> z=%d [j=%d])\n", row, i, q, z, j);
            fcm.e[i][z] = fec_weights[row][q];
        }
    }
}

/***************************************************************************/
/* Encode or Decode Main Functions                                         */
/***************************************************************************/
/*
 * Matric Mulitply k KNOWN Data values with the h known Parity rows of fec_weights
 */
void matrix_multiply(int fb_index, fec_sym COUNT_KNOW, fec_sym *INDEX_KNOW, fec_sym COUNT_PARI, fec_sym *INDEX_PARI, int c) {
    
    fec_sym i, j, data, q, cq, row;
    fec_sym *ptr;
    int     which_symbol_of_integer_length, shift;

        for (i=0; i<COUNT_KNOW; i++) {
            q = INDEX_KNOW[i];                          /* fb Columns which we KNOW */
            cq =fbk[fb_index].cbi[INDEX_KNOW[i]];                  /* cw columns which we KNOW */
//            fprintf(stderr, "i=%d len=%d c=%d\n", i, fbk[fb_index].plen[q], c);
            ptr = fbk[fb_index].pdata[q]+c;                        /* point to data (with no shift) */
            D2(fprintf(stderr, "c%d fbi-%d data=", c, q));

            /* A) For packets smaller than largest packet, fill end with zeros */
            if ( fbk[fb_index].plen[q] > c ) {
                data = *((fec_sym *)ptr);               /* Packet Data symbol value */
            }
            else {
                data = 0;                               /* if packet has < c symbols */
            }
            
            /* B) Last FEC_EXTRA_COLS (fbk[fb_index].block_C-1, fbk[fb_index].block_C-2,...) holds packet length */
            if ((c >= fbk[fb_index].block_C - FEC_EXTRA_COLS) && (cq < FEC_MAX_K)) {
                /* length of packet (an integer) is split into fec_sym sized pieces */
                which_symbol_of_integer_length = fbk[fb_index].block_C-c-1;
                shift=8*sizeof(i)*which_symbol_of_integer_length;
                data = (fec_sym) (fbk[fb_index].plen[INDEX_KNOW[i]] >> shift);   /* Use length as data */
#ifdef FEC_DBG_CODE_LENGTH
                fprintf(stderr, "Encode Length into Last FEC_EXTRA_COLS: index=%d (c=%d len=%d shift=%d) d-%02x = %d\n", which_symbol_of_integer_length, c, fbk[fb_index].plen[INDEX_KNOW[i]], shift, INDEX_KNOW[i], data);
#endif
            }
            D2(fprintf(stderr, "%04x  ", data));

            /* C) Multiply (j is row index, selecting codeword rows for given column) */
            for (j=0; j<COUNT_PARI; j++) {
                row = FEC_MAX_N - fbk[fb_index].cbi[INDEX_PARI[j]] - 1;    /* Rows where we have PARI */
//                fprintf(stderr, "j=%d, fbi=%x cbi=%x row=%d col=%d\n", j, INDEX_PARI[j], fbk[fb_index].cbi[INDEX_PARI[j]], row, cq);
//                fprintf(stderr, "[%04x * %04x += %04x] ",fec_weights[row][cq], data, fcm.d[j][0]);
//                fprintf(stderr, "MULT=%04x\n", gf_mult_table[0xbdfb][0xc4f5]);
                FEC_MAC(fec_weights[row][cq], data, fcm.d[j][0]);
                D2(fprintf(stderr, "r%d [%04x * %04x += %04x] ", row, fec_weights[row][cq], data, fcm.d[j][0]));
            }
            D2(fprintf(stderr, "\n"));
        }
}

/*
 * Write results (fcm.d[j][0]) into fec block for symbol c -
 * and change status to KNOWN (if code_mode is not 0)
 */
void write_accumulated_sum_into_wanted_packets(int fb_index, fec_sym *INDEX_WANT, fec_sym want, int c, char code_mode) {
    
    fec_sym j, q;
    int     which_symbol_of_integer_length, shift, data;

    D2(fprintf(stderr, "Write symbols of accumulated sum into %d wanted packets (c=%d)\n\n", want, c));
    for (j=0; j<want; j++) {
        q = INDEX_WANT[j];
        
        /* a) Write data fir packet q into FEC block */
        fbk[fb_index].pdata[q][c] = fcm.d[j][0];
        
        /* b) Write flag and length if last column */
        if (c==fbk[fb_index].block_C - 1) {
            if ( (code_mode == 'd') || (code_mode == 'e') )    fbk[fb_index].pstat[q] = FEC_FLAG_GENNED;
            if (FEC_EXTRA_COLS == 0) fbk[fb_index].plen[q]  = fbk[fb_index].block_C;
        }
        
        /* c) Recalculate length value of each data packet using its last FEC_EXTRA_COLS */
        if (fbk[fb_index].cbi[q] < FEC_MAX_K) {
            if (c == 0)  fbk[fb_index].plen[q]=0;          /* Initialize length calculation */
            if (c >= fbk[fb_index].block_C - FEC_EXTRA_COLS) {
                which_symbol_of_integer_length = fbk[fb_index].block_C-c-1;
                shift=8*sizeof(j)*which_symbol_of_integer_length;
                data = (int) fcm.d[j][0] << shift;
                fbk[fb_index].plen[q]+=data;
#ifdef FEC_DBG_CODE_LENGTH
                fprintf(stderr, "Recover Length from Last FEC_EXTRA_COLS: index=%d (c=%d len=%d shift=%d) d-%02x = %d\n", which_symbol_of_integer_length, c, fbk[fb_index].plen[q], shift, q, data);
#endif
            }
        }
    }
}

/*
 * Encode or Decode an FEC block (fb)
 */
int rse_code(int fb_index, char code_mode) {
    int perfCounterFd;
    long long perfCounterValue;

    int perfFdSolve;
    long long perfCounterSolve = 0;
    long long perfCounterMult = 0;

    // perfCounterFd = startCounter(PERF_COUNT_HW_REF_CPU_CYCLES);
    
    int rc, c;
    fec_sym want=0, know=0, pari=0, parities_to_use;
//    fec_sym INDEX_WANT[fbk[fb_index].block_N], INDEX_KNOW[fbk[fb_index].block_N], INDEX_PARI[fbk[fb_index].block_N];
    fec_sym INDEX_WANT[FEC_MAX_N], INDEX_KNOW[FEC_MAX_N], INDEX_PARI[FEC_MAX_N];

    
#ifdef FEC_SPEED_TEST
    fec_get_time_delta(0, 0);
#endif
    D1(fprintf(stderr, "\nStep 1) Load FEC Block into Coder\n"); fec_block_print(fb_index));
    if ((rc=fec_block_check(fb_index)) != 0 )  return (rc);
    fec_block_types_find(fb_index, INDEX_KNOW, INDEX_WANT, INDEX_PARI, &know, &want, &pari);
    if ((rc=fec_block_types_check(know, want, pari)) != 0 )  return (rc);
#ifdef FEC_SPEED_TEST
    fec_get_time_delta(0, 1);
#endif
    parities_to_use=pari; if (pari > want) parities_to_use=want;    /* ignore extra parities */
    code_equations_generate(fb_index, want, INDEX_WANT, parities_to_use, INDEX_PARI);
    D1(fprintf(stderr, "Step 2) Generate %d equations for %d wanted packets\n", parities_to_use, want));
    D1(code_equation_print('e', parities_to_use, want));
#ifdef FEC_SPEED_TEST
    fec_get_time_delta(0, 2);
#endif
    
    D1(fprintf(stderr, "\nStep 3) For %d packet symbols, a) Calculate Constants, b) Solve Equations, and c) Store\n", fbk[fb_index].block_C));
    for (c=0; c < fbk[fb_index].block_C; c++) {
        code_equations_duplicate(parities_to_use);

#ifdef HANS_ENCODER
        encode_matrix(fb_index, know, pari, c);
#else
        perfFdSolve = startCounter(PERF_COUNT_HW_REF_CPU_CYCLES);
        matrix_multiply(fb_index, know, INDEX_KNOW, parities_to_use, INDEX_PARI, c);
        perfCounterMult += stopCounter(perfFdSolve);

#ifdef VERIFY_HLS
        Verify_matrix_multiply(fb_index, know, parities_to_use, c);
#endif // VERIFY_HLS
#endif // HANS_ENCODER


        D3(fprintf(stderr, "\nStep 3-%d: Multiply %d known packets by %d codewords, to create:\n", c, know, parities_to_use));
        D3(fprintf(stderr, "Input ");  code_equation_print('d', parities_to_use, want));

        perfFdSolve = startCounter(PERF_COUNT_HW_REF_CPU_CYCLES);

        if ( (code_mode == 'd') || (code_mode == 'D') ) {           /* if decode */
            if ((rc = matrix_solve((fec_sym *)fcm.d, parities_to_use, want+1, FEC_MAX_H+1)) != 0 ) {
                perfCounterMult += stopCounter(perfFdSolve);
                return (rc);
            }
        }
        perfCounterSolve += stopCounter(perfFdSolve);
    
        D3(fprintf(stderr, "Trans ");  code_equation_print('d', parities_to_use, want));
        write_accumulated_sum_into_wanted_packets(fb_index, INDEX_WANT, want, c, code_mode);
//        fflush(stdout);
    }
    printf("mult: %lli\n",perfCounterMult);
    printf("solve: %lli\n",perfCounterSolve);

    // perfCounterValue = stopCounter(perfCounterFd);
    // printf("rse_code time: %lli\n",perfCounterValue);

#ifdef FEC_SPEED_TEST
    fec_get_time_delta(0, 3);
#endif
    return (0);
}
