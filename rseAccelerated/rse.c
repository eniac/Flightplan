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
 * Modifications for dynamic addition of parity and Harware Implementation:
 *  9/28/2017   A. McAuley, Vencore (amcauley@vencorelabs.com)
 *
 * For usage see README.txt
 */

#include "rseAcceleratedTest.h"
#include "rse.h"
#include <stdlib.h>

/***************************************************************************/
/* Pre-computed GF Tables (Global variables ... ugly but fast and easy)    */
/***************************************************************************/
fec_sym	fec_2_log[FEC_N];                       /* index->power table */
fec_sym	fec_2_exp[FEC_N];                       /* power->index table */
fec_sym	fec_invefec[FEC_N];                     /* multiplicative inverse */
fec_sym	fec_weights[FEC_MAX_H][FEC_MAX_N];        /* FEC weight table */

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
            fprintf(stderr, "Don't know mod FEC_M=%d\n", FEC_M);
            return (FEC_ERR_MOD_NOT_FOUND);
    }
    return (modulus);
}

/*
 * Display Log and Inversion Tables
 */
void gf_math_log_tables_display(void)
{
    int		i, mod;

    mod = gf_math_find_mod();
    fprintf(stderr, "\n%d-bit Symbol Operations in GF(%d)\n", FEC_M, FEC_N);
    fprintf(stderr, "num  2_exp 2_log  invefec  (mod=0x%x)\n", mod);
    fprintf(stderr, " i    2^i  log(i) 1/i\n");
    for (i=0; i<MAX_PRINT_COLUMNS; i++) {
        fprintf(stderr, "%2x    %2x    ", i, fec_2_exp[i]);
        fprintf(stderr, "%2x    %2x\n", fec_2_log[i], fec_invefec[i]);
    }
    if (FEC_N > MAX_PRINT_COLUMNS)  fprintf(stderr, "... (%d of %d)\n",MAX_PRINT_COLUMNS, FEC_N - 1);
}

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
            fec_2_exp[i] = i+1;
        else {
            /* Use GF generator (primitive element) g = 2: g^i = g^(i-1) * 2 */
            temp = fec_2_exp[i-1]<<1;
            /* If carry, XOR with GF irreducible polynomial (mod) */
            if (temp>=FEC_N) fec_2_exp[i] = temp^mod;
            else             fec_2_exp[i] = temp;
        }
        
        fec_2_log[fec_2_exp[i]] = i;		/* 0'th index is not used */
    }
  for (i=0; i<FEC_N; i++) fec_invefec[fec_2_exp[FEC_N-1-fec_2_log[i]]]=i;
#ifdef FEC_DBG_PRINT_TABLES
    gf_math_log_tables_display();
#endif
}

#ifdef FEC_MAC_LOOKUP
/*
 * Print contents of Multiplication Table
 */
void gf_math_mult_tables_print(fec_sym gf_table[FEC_N][FEC_N]) {
    int i=0, j=0, mod;

    mod = gf_math_find_mod();
    fprintf(stderr, "\nMultiplication Table in GF(2^%d) mod=0x%x\n", FEC_M, mod);
    fprintf(stderr, "   ");
    for (i=0; i < FEC_N; i++) {
        fprintf(stderr, "%2x ", i);
    }
    fprintf(stderr, "\n");
    for (i=0; i < FEC_N; i++) {
        fprintf(stderr, "%2x ", i);
        for (j=0; j < FEC_N; j++) {
            fprintf(stderr, "%2x ", gf_table[i][j]);
        }
        fprintf(stderr, "\n");
    }
    fprintf(stderr, "\n");
}

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
#ifdef FEC_DBG_PRINT_TABLES
    gf_math_mult_tables_print(gf_table);
#endif
}
#endif

/***************************************************************************/
/* Matrix Solver                                                           */
/***************************************************************************/

/*
 * Display 2D Matrix
 */
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
//    fprintf(stderr, "\n");
}

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
    
#ifdef FEC_DBG_PRINT_TRANS
    fprintf(stderr, "Transform %d by %d Matrix (with %d coluns) {%p}\n",  rows_max, cols_max, cols_in_array, p);
    matrix_display(p, rows_max, cols_max, cols_in_array);
#endif
    for (k=0; k<rows_max; k++) {            /* k = column index - from right (Loop 1) */
#ifdef FEC_DBG_PRINT_TRANS
        fprintf(stderr, "Step 1a) col-%d (from left) set to 1's and 0's, by multiplying each row\n", k);
#endif
        for (i=0; i<rows_max; i++) {              /* i = row index - from top (Loop 2) */
            m = p+(i*cols_in_array);     /* rightmost column index in row i */
            q = m + cols_max - 1;        /* leftmost  column index in row i */
            v = *(q-k);                           /* Value of entry in k'th from left column */
#ifdef FEC_DBG_PRINT_TRANS
            fprintf(stderr, "Pointers[%p - %p] Value[%x]  ", q, m, v);
#endif
            if (v != 0) {
                inv = fec_invefec[*(q-k)];        /* invert value */
                for (n=q; n>=m; n--)               /* n = index to cells in row i (Loop 3) */
                    *n = FEC_GF_MULT(*n, inv);    /* Multiply by inverse */
#ifdef FEC_DBG_PRINT_TRANS
                fprintf(stderr, "row-%d %x inv=%x, ", i, *n, inv);
#endif
            }
        }

#ifdef FEC_DBG_PRINT_TRANS
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
#ifdef FEC_DBG_PRINT_TRANS
        matrix_display(p, rows_max, cols_max, cols_in_array);
#endif
    }
    
#ifdef FEC_DBG_PRINT_TRANS
    fprintf(stderr, "Step 2) Multiply each row by inverse make elements in triangle 1's\n");
#endif
    for (i=0; i<rows_max-1; i++) {                      /* for all rows, except bottom (last) */
        q = (p+(i*cols_in_array)+cols_max-1);           /* leftmost (last) column in row i */
        m = q - cols_max;                               /* righmost (first) + 1 column in row i */
        inv = fec_invefec[*(q-i)];                      /* inverse for row i */
#ifdef FEC_DBG_PRINT_TRANS
        fprintf(stderr, "row-%d inv=%2x, ", i, inv);
#endif
        for (n=q; n>m; n--)                             /* For all columns (left to right) */
            *n = FEC_GF_MULT(*n, inv);
    }

#ifdef FEC_DBG_PRINT_TRANS
    fprintf(stderr, "\n");
    matrix_display(p, rows_max, cols_max, cols_in_array);
#endif
    
    return (0);
}

/***************************************************************************/
/* FEC Codework Generation (only done once per run)                        */
/***************************************************************************/

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

/*
 * Generate Weight matrix
 */
int codewords_generate(void) {

    int rc;
    fec_sym i, j;

    for (i=0; i<FEC_MAX_H; i++)                                 /* rows */
        for (j=0; j<FEC_MAX_N; j++)                             /* columns */
            fec_weights[i][j] = fec_2_exp[(i*j%FEC_N)];         /* FEC 1 */
#ifdef FEC_DBG_PRINT_WEIGHTS
    fprintf(stderr, "Systematic Reed-Solomom h x n (%d x %d) equations:\n", FEC_MAX_H, FEC_MAX_N);
    codewords_print_header(FEC_MAX_H, FEC_MAX_N);
    matrix_display((fec_sym *)fec_weights, FEC_MAX_H, FEC_MAX_N, FEC_MAX_N); 		/* debug */
#endif

    if ((rc = matrix_solve((fec_sym *)fec_weights, FEC_MAX_H, FEC_MAX_N, FEC_MAX_N)) != 0 ) return (rc);

#ifdef FEC_DBG_LEVEL_1
    fprintf(stderr, "\nStep 0) Generated Modified Reed-Solomom h x n (%d x %d) equations:\n", FEC_MAX_H, FEC_MAX_N);
    codewords_print_header(FEC_MAX_H, FEC_MAX_N);
    matrix_display((fec_sym *)fec_weights, FEC_MAX_H, FEC_MAX_N, FEC_MAX_N);
#endif

    return (0);
}

/*
 * Check FEC block parameters are reasonable
 */
int codewords_check_bounds(void) {
    fec_sym i;
    
    if (FEC_MAX_N > FEC_N) {
        fprintf (stderr, "\n FEC_MAX_N (%d) > FEC_N (%d)\n", FEC_MAX_N, FEC_N);
        return (FEC_ERR_INVALID_PARAMS);
    }
    if (FEC_EXTRA_COLS > 1) {
        fprintf (stderr, "\n FEC_EXTRA_COLS (%d) > 1\n", FEC_EXTRA_COLS);
        fprintf (stderr, "Allowed, but not implemented: modify rse.c near FEC_EXTRA_COLS\n");
        return (FEC_ERR_INVALID_PARAMS);
    }
    if (FEC_MAX_COLS < 1) {
        fprintf (stderr, "\n FEC_MAX_COLS (%d) < 1\n", FEC_MAX_COLS);
        return (FEC_ERR_INVALID_PARAMS);
    }
    if (sizeof(i) < (FEC_M/8)) {
        fprintf (stderr, "\n fec_sym typedef has too few bytes (%lu) to store (FEC_M = %d bit) FEC symbol\n", sizeof(i), FEC_M);
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
 * Print delta from last time called (with label) - but only if label is > 0
 */
unsigned long fec_get_time_delta(int label) {
    
    struct    timeval           tp;
    unsigned  long              t_old;
    static    unsigned  long    t_new=0;
    
    if (gettimeofday(&tp, NULL) < 0) {
        fprintf (stderr, "Could not get time \n");
        exit (1);
    }
    t_old = t_new;
    t_new = (1000000*tp.tv_sec)+tp.tv_usec;
    if (label > 0)    fprintf(stderr, "delta%d = %lu μs\n", label, t_new-t_old);
    return (t_new-t_old);
}

/***************************************************************************/
/* FEC Block - Basic: referred by global pointer fb (structure in rse.h)   */
/***************************************************************************/
/*
 * Print FEC Block extras (status flag)
 */
void fec_block_print_packet_extras(int i) {
    switch(fb.pstat[i]) {
        case FEC_FLAG_KNOWN :
            fprintf(stderr, "Known\n");
            break;
        case FEC_FLAG_WANTED :
            fprintf(stderr, "Wanted\n");
            break;
        case FEC_FLAG_IGNORE :
            fprintf(stderr, "Ignore\n");
            break;
        default :
            fprintf(stderr, "????\n");
    }
}

/*
 * Print FEC Block
 */
void fec_block_print() {
    
    fec_sym i;
    int j;
    char pkt_want[10] = "????", pkt_short[10]="----";
    
    fprintf(stderr, "FEC Block n=%d c=%d+%d (parities from cbi-%02x)\n", fb.block_N, fb.block_C-FEC_EXTRA_COLS, FEC_EXTRA_COLS, FEC_MAX_K);
    
    /* Shorten (put spaces) in what is printed if fec_sym is just one character */
    if (sizeof(i) < 2) {
        for (i=0; i<2; i++) {
            pkt_want[i]=' ';
            pkt_short[i]=' ';
        }
    }

    for (i=0; i<fb.block_N; i++) {                    /* All rows in FEC Block (data and Parity) */
        fprintf(stderr, "fbi-%02x cbi-%02x: ", i, fb.cbi[i]);
        if (fb.cbi[i] < FEC_MAX_K) {
            fprintf(stderr, "data d-%02x ", i);
        }
        else {
            fprintf(stderr, "pari p-%02x ", FEC_MAX_N - fb.cbi[i] - 1);
        }
        fprintf(stderr, "(len=%d): ", fb.plen[i]);
        for (j=fb.block_C-1; j>=0; j--) {         /* All Symbols (Coumns) in packet */
            switch (fb.pstat[i]) {
                case FEC_FLAG_WANTED:   fprintf(stderr, "%s  ", pkt_want);
                                        break;
                case FEC_FLAG_KNOWN:    if (fb.plen[i] > j)
                                            fprintf(stderr, "%4x  ",*(fb.pdata[i]+j));
                                        else
                                            fprintf(stderr, "%s  ", pkt_short);
                                        break;
                case FEC_FLAG_IGNORE:   fprintf(stderr, "%s  ", pkt_want);
                                        break;
                default:                fprintf(stderr, "^^^^^^^^^^");
                                        break;
            }
        }
        fec_block_print_packet_extras(i);
    }
    fprintf(stderr, "\n");
}

/*
 * Delete Packet from FEC Block with given FEC block indices (fbis)
 */
void fec_block_delete(int *delete_fbis) {
    int i;
    fec_sym fbi=0, cbi;
    
//    fprintf (stderr, "Parity cbi start = %d (STOP at %d)\n", FEC_MAX_K, FEC_N-1);
    for (i=0; delete_fbis[i]<FEC_MAX_N; i++) {
        fbi = (fec_sym) delete_fbis[i];
        cbi = fb.cbi[fbi];
//        fprintf (stderr, "fbi=%d cbi=%d\n", fbi, cbi);
        if (cbi < FEC_MAX_K) {
            fb.pstat[fbi] = FEC_FLAG_WANTED;
        }
        else {
            fb.pstat[fbi] = FEC_FLAG_IGNORE;
        }
        fb.plen[fbi]=0;
    }
}

/*
 * Check FEC block parameters are reasonable
 */
int fec_block_check(void) {

    if (((int) fb.block_N >= FEC_N) || ((int) fb.block_C > FEC_MAX_COLS) ||
      (fb.block_N < 1) || (fb.block_C < 1)) {
        fprintf (stderr, "FEC block parameters out of bound: ");
        fprintf (stderr, "(0 <= n (%d) < FEC_MAX_N (%d))\n", fb.block_N, FEC_N);
        fprintf (stderr, "(0 <  c (%d) < FEC_MAX_COLS (%d)) ", fb.block_C, FEC_MAX_COLS);
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
        fprintf(stderr, "a) To code must have: number PARI (%d) >= WANT (%d) (and WANT and KNOW (%d) > 0)\n", COUNT_PARI, COUNT_WANT, COUNT_KNOW);
        return (FEC_ERR_ENC_MISSING_DATA);
    }
//    data_packet_count = fb.block_N - COUNT_PARI;
    if ((COUNT_PARI > FEC_MAX_H)) {
        fprintf(stderr, "b) number parity packets (%d) > FEC_MAX_H (%d)\n", COUNT_PARI, FEC_MAX_H);
        return (FEC_ERR_ENC_MISSING_DATA);
    }
    return (0);
}

/*
 * Print fec block and codeword indices stored in matrix INDEX (of size COUNT)
 */
void  fec_block_types_print_indices(char *string, fec_sym COUNT, fec_sym *INDEX) {
    fec_sym i;
    
    fprintf(stderr, "%s%d fbi {cbi}: ", string, COUNT);
    for (i=0; i<COUNT; i++)
    fprintf(stderr, "%d {%02x}, ", INDEX[i], fb.cbi[INDEX[i]]);
    fprintf(stderr, "\n");
}

/*
 * Put fec block indices of packet's status/type (known, wanted and parity)
 * into 3 matricies (e.g. INDEX_KNOW[]).
 * Also return how many packets are of each type (e.g. COUNT_KNOW)
 */
void fec_block_types_find(fec_sym *INDEX_KNOW, fec_sym *INDEX_WANT, fec_sym *INDEX_PARI, fec_sym *COUNT_KNOW, fec_sym *COUNT_WANT, fec_sym *COUNT_PARI) {
    
    fec_sym i;
    
    for (i=0; i<fb.block_N; i++) {
        if (fb.pstat[i] == FEC_FLAG_WANTED) {
            INDEX_WANT[*COUNT_WANT] = i;
            (*COUNT_WANT)++;
        }
        if (fb.pstat[i] == FEC_FLAG_KNOWN)
        {
            INDEX_KNOW[*COUNT_KNOW] = i;
            (*COUNT_KNOW)++;
        }
        if ((fb.pstat[i] != FEC_FLAG_IGNORE) && (fb.cbi[i] >= FEC_MAX_K ))
        {
            INDEX_PARI[*COUNT_PARI] = i;
            (*COUNT_PARI)++;
        }
    }
}

/***************************************************************************/
/* Code Equations Matices in an FEC Block (fb)                           */
/***************************************************************************/
/*
 * Print the "pari" equations in "want" unknowns
 *  Stored as a matrix in the FEC BLock (fb) with FEC_MAX_H+1 columns
 *  (column 0 has the accumulated sums - hence the want+1 columns to dispay)
 */
void code_equation_print(char type, fec_sym pari, fec_sym want) {
    fec_sym *p;
    
    if (type != 'e') {
        fprintf(stderr, "Duplicate Equation:\n");
        p=fb.d[0];
    }
    else {
        fprintf(stderr, "Equation:\n");
        p=fb.e[0];
    }
    matrix_display(p, pari, want+1, FEC_MAX_H+1);
}

/*
 * Duplicate contents of h-row x (h+1)-column Equation matrix
 */
void code_equations_duplicate(fec_sym size) {
    fec_sym row, col;
    
    for (row=0; row < size; row++)
        for (col=size; col<FEC_N -2; col--)
            fb.d[row][col] = fb.e[row][col];
}

/*
 * Create the Decode Equations with a row for each Parity Packet we receive
 *    The columns correspond to the unknown (WANteD) variables
 */
void code_equations_generate(fec_sym COUNT_WANT, fec_sym *INDEX_WANT, fec_sym COUNT_PARI, fec_sym *INDEX_PARI) {
    fec_sym i, j, q, z, row;
    
    for (i=0; i < COUNT_PARI ; i++) {
        row = FEC_MAX_N - fb.cbi[INDEX_PARI[i]] - 1;        /* Codework Row where we have PARI */
        for (j=0; j<COUNT_WANT; j++) {
            q = fb.cbi[INDEX_WANT[j]];                  /* Codework Column we WANT */
            z = COUNT_WANT - j;
//            fprintf(stderr, "i=%d j=%d r=%d q=%d z=%d\n", i, j, row, q, z);
            fb.e[i][z] = fec_weights[row][q];
        }
    }
}

/***************************************************************************/
/* Encode or Decode Main Functions                                         */
/***************************************************************************/
/*
 * Matric Mulitply k KNOWN Data values with the h known Parity rows of fec_weights
 */
void matrix_multiply(fec_sym COUNT_KNOW, fec_sym *INDEX_KNOW, fec_sym COUNT_PARI, fec_sym *INDEX_PARI, int c) {
    
    fec_sym i, j, data, q, cq, row;
    fec_sym *ptr;

        for (i=0; i<COUNT_KNOW; i++) {
            q = INDEX_KNOW[i];                          /* fb Columns which we KNOW */
            cq =fb.cbi[INDEX_KNOW[i]];                  /* cw columns which we KNOW */
//            fprintf(stderr, "len=%d c=%d\n", fb.plen[q], c);
            ptr = fb.pdata[q]+c;                        /* point to data (with no shift) */
#ifdef FEC_DBG_LEVEL_2
            fprintf(stderr, "c%d fbi-%d data=", c, q);
#endif

            /* A) For Variable length packets fill end with zeros */
            if ( fb.plen[q] > c ) {
                data = *((fec_sym *)ptr);               /* Packet Data symbol value */
            }
            else {
                data = 0;                               /* if packet has < c symbols */
            }
            /* B) leave room to code length */
            if ((c == fb.block_C - 1) && (cq < FEC_MAX_K) && (FEC_EXTRA_COLS > 0)) {
                data = fb.plen[INDEX_KNOW[i]];            /* Use lenght as data */
            }
#ifdef FEC_DBG_LEVEL_2
            fprintf(stderr, "%02x  ", data);
#endif

            /* C) Multiply (j is row index, selecting codeword rows for given column) */
            for (j=0; j<COUNT_PARI; j++) {
                row = FEC_MAX_N - fb.cbi[INDEX_PARI[j]] - 1;    /* Rows where we have PARI */

                FEC_MAC(fec_weights[row][cq], data, fb.d[j][0]);
#ifdef FEC_DBG_LEVEL_2
                fprintf(stderr, "r%d [%02x * %02x += %02x] ", row, fec_weights[row][cq], data, fb.d[j][0]);
#endif
            }
#ifdef FEC_DBG_LEVEL_2
            fprintf(stderr, "\n");
#endif
        }
}

/*
 * Write results (fb.d[j][0]) into fec block for symbol c - and change status to KNOWN
 */
void write_accumulated_sum_into_wanted_packets(fec_sym *INDEX_WANT, fec_sym want, int c, int mode_flag) {
    
    fec_sym j, q;
    
#ifdef FEC_DBG_LEVEL_2
    fprintf(stderr, "Write symbols of accumulated sum into %d wanted packets (c=%d)\n\n", want, c);
#endif
    for (j=0; j<want; j++) {
        q = INDEX_WANT[j];
        fb.pdata[q][c] = fb.d[j][0];
        if ( (c==fb.block_C - 1) && (mode_flag != 0) ){
            fb.pstat[q] = FEC_FLAG_KNOWN;           /* If last packet symbol: a) Add flag */
            if (fb.cbi[q] < FEC_MAX_K) {            /* b) Put length value into FEC block */
                if (FEC_EXTRA_COLS > 0) fb.plen[q]=fb.d[j][0];
                else                    fb.plen[q]=fb.block_C;
            }
        }
    }
}

/*
 * Encode or Decode an FEC block (fb)
 */
int rse_code(int mode_flag) {
    
    int rc, c;
    fec_sym want=0, know=0, pari=0;
    fec_sym INDEX_WANT[fb.block_N], INDEX_KNOW[fb.block_N], INDEX_PARI[fb.block_N];
#ifdef FEC_SPEED_TEST
    fec_get_time_delta(0);
#endif
#ifdef FEC_DBG_LEVEL_1
    fprintf(stderr, "\nStep 1) Load FEC Block into Coder\n");
    fec_block_print();
#endif
    if ((rc=fec_block_check()) != 0 )  return (rc);
    fec_block_types_find(INDEX_KNOW, INDEX_WANT, INDEX_PARI, &know, &want, &pari);
#ifdef FEC_DBG_LEVEL_2
    fec_block_types_print_indices("Know k=", know, INDEX_KNOW);
    fec_block_types_print_indices("Want h=", want, INDEX_WANT);
    fec_block_types_print_indices("Pari p=", pari, INDEX_PARI);
#endif
    if ((rc=fec_block_types_check(know, want, pari)) != 0 )  return (rc);
#ifdef FEC_SPEED_TEST
    fec_get_time_delta(1);
#endif
    
    code_equations_generate(want, INDEX_WANT, pari, INDEX_PARI);
#ifdef FEC_DBG_LEVEL_1
    fprintf(stderr, "Step 2) Generate %d equations for %d WANTED packets\n", pari, want);
    code_equation_print('e', pari, want);
#endif
#ifdef FEC_SPEED_TEST
    fec_get_time_delta(2);
#endif
    
#ifdef FEC_DBG_LEVEL_1
    fprintf(stderr, "\nStep 3) For %d packet symbols, a) Calculate Constants, b) Solve Equations, and c) Store\n", fb.block_C);
#endif
    for (c=0; c < fb.block_C; c++) {
        code_equations_duplicate(pari);
        matrix_multiply(know, INDEX_KNOW, pari, INDEX_PARI, c);
        Verify_matrix_multiply(know, pari, c);
#ifdef FEC_DBG_PRINT_STEP3
        fprintf(stderr, "\nStep 3-%d: Multiply %d known packets by %d codewords, to create:\n", c, know, pari);
        fprintf(stderr, "Input ");  code_equation_print('d', pari, want);
#endif
        if ((rc = matrix_solve((fec_sym *)fb.d, pari, want+1, FEC_MAX_H+1)) != 0 ) return (rc);
#ifdef FEC_DBG_PRINT_STEP3
        fprintf(stderr, "Trans ");  code_equation_print('d', pari, want);
#endif
        write_accumulated_sum_into_wanted_packets(INDEX_WANT, want, c, mode_flag);
//        fflush(stdout);
    }
#ifdef FEC_SPEED_TEST
    fec_get_time_delta(3);
#endif
    return (0);
}
