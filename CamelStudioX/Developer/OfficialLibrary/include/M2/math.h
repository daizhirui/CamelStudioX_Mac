/*--------------------------------------------------------------------
 * TITLE: Math defines
 * AUTHOR: John, Hongyan Zhao, Zhirui Dai
 * DATE CREATED: 8/10/2017
 * FILENAME: math.h
 * PROJECT: m2/m3/c2
 * DESCRIPTION:
 *    math defines
 *    1. Subset of the ANSI C library
 *    2. Math C library
 *--------------------------------------------------------------------*/
#ifndef __MATH_H__
#define __MATH_H__

// Typedefs
typedef unsigned int   uint32;
typedef unsigned short uint16;
typedef unsigned char  uint8;

// #define assert(A) if((A)==0){puts("\r\nAssert");}
#define assert(A) if((A)==0){}

/***************** Math ******************/
//IEEE single precision floating point math
#ifndef WIN32
#define FP_Neg     __negsf2
#define FP_Add     __addsf3
#define FP_Sub     __subsf3
#define FP_Mult    __mulsf3
#define FP_Div     __divsf3
#define FP_ToLong  __fixsfsi
#define FP_ToFloat __floatsisf
#define FP_UnsignedToFloat __floatunsisf
#define sqrt FP_Sqrt
#define cos  FP_Cos
#define sin  FP_Sin
#define atan FP_Atan
#define log  FP_Log
#define exp  FP_Exp
#endif

float FP_Neg(float a_fp);
float FP_Abs(float a_fp);
float FP_Add(float a_fp, float b_fp);
float FP_Sub(float a_fp, float b_fp);
float FP_Mult(float a_fp, float b_fp);
float FP_Div(float a_fp, float b_fp);
long  FP_ToLong(float a_fp);
float FP_ToFloat(long af);
int   FP_Cmp(float a_fp, float b_fp);
float FP_Sqrt(float a);
float FP_Cos(float rad);
float FP_Sin(float rad);
float FP_Atan(float x);
float FP_Atan2(float y, float x);
float FP_Exp(float x);
float FP_Log(float x);
float FP_Pow(float x, float y);

#define PI ((float)3.1415926)           // pi
#define PI_2 ((float)(PI/2.0))          // pi/2
#define PI_8 ((float)(PI/8.0))          // pi/8
#define PI2 ((float)(PI*2.0))           // 2pi
#define ATAN_PI_8 ((float)0.37419668)   // atan(pi/8)
#define E2  ((float)7.38905609)         // e^2
#define INV_E2  ((float)0.13533528)     // 1/e^2
#define LN_2   ((float)0.69314718)      // ln(2)

#endif //__MATH_H__


