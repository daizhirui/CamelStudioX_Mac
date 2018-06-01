/**
* @file soft_fp.h
* @author Zhirui Dai
* @date 1 Jun 2018
* @copyright 2018 Zhirui
* @brief Soft float library
*/
#include <stdint.h>

#ifndef __SOFT_FP_H__
#define __SOFT_FP_H__ 1

// #define assert(A) if((A)==0){puts("\r\nAssert");}
#define assert(A) if((A)==0){}

#define fp_float32_neg          __negsf2
#define fp_float32_add          __addsf3
#define fp_float32_sub          __subsf3
#define fp_float32_mult         __mulsf3
#define fp_float32_div          __divsf3
#define fp_float32_to_int32     __fixsfsi
#define fp_int32_to_float32     __floatsisf
#define fp_uint32_to_float32    __floatunsisf
#define fp_float32_to_float64   __extendsfdf2
#define fp_float64_to_float32   __truncdfsf2
#define abs     fp_float32_abs
#define sqrt    fp_float32_sqrt
#define cos     fp_float32_cos
#define sin     fp_float32_sin
#define atan    fp_float32_atan
#define atan2   fp_float32_atan2
#define exp     fp_float32_exp
#define log     fp_float32_log
#define pow     fp_float32_pow

float fp_float32_neg(float a_fp);
float fp_float32_abs(float a_fp);
float fp_float32_add(float a_fp, float b_fp);
float fp_float32_sub(float a_fp, float b_fp);
float fp_float32_mult(float a_fp, float b_fp);
float fp_float32_div(float a_fp, float b_fp);
long fp_float32_to_int32(float a_fp);
float fp_int32_to_float32(long af);
float fp_uint32_to_float32(unsigned long af);
double fp_float32_to_float64(float a_fp);
float fp_float64_to_float32(double a_dfp);
int fp_float32_cmp(float a_fp, float b_fp);

float fp_float32_sqrt(float a);
float fp_float32_cos(float rad);
float fp_float32_sin(float rad);
float fp_float32_atan(float x);
float fp_float32_atan2(float y, float x);
float fp_float32_exp(float x);
float fp_float32_log(float x);
float fp_float32_pow(float x, float y);

#define PI              ((float)3.1415926)
#define HALF_PI         ((float)(PI/2.0))
#define EIGHTH_PI       ((float)(PI/8.0))
#define TWO_PI          ((float)(PI*2.0))
#define ATAN_EIGHTH_PI  ((float)0.37419668)
#define E_SQUARE        ((float)7.38905609)     // e^2
#define INV_E_SQUARE    ((float)0.13533528)     // 1/e^2
#define LN_2            ((float)0.69314718)     // ln(2)

#endif
