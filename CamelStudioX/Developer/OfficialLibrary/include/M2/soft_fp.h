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

/*! \cond PRIVATE */
// #define assert(A) if((A)==0){puts("\r\nAssert");}
typedef union {
    float       floatValue;
    uint32_t    uint32Value;
} float32_container;
typedef union {
    double      doubleValue;
    uint32_t    uint32Value[2];
} float64_container;

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
#define fp_float64_add          __adddf3
#define fp_float64_sub          __subdf3
#define fp_float64_mult         __muldf3
#define fp_float64_div          __divdf3
/*! \endcond */

/*! fp_float32_abs */
#define abs     fp_float32_abs

/*! fp_float32_sqrt */
#define sqrt    fp_float32_sqrt

/*! fp_float32_cos */
#define cos     fp_float32_cos

/*! fp_float32_sin */
#define sin     fp_float32_sin

/*! fp_float32_atan */
#define atan    fp_float32_atan

/*! fp_float32_atan2 */
#define atan2   fp_float32_atan2

/*! fp_float32_exp */
#define exp     fp_float32_exp

/*! fp_float32_log */
#define log     fp_float32_log

/*! fp_float32_pow */
#define pow     fp_float32_pow

/**
 * @brief Calculate the negative value of a_fp.
 * @param a_fp The value to calculate.
 * @return The negative value of a_fp.
 */
float fp_float32_neg(float a_fp);

/**
 * @brief           Calculate absolute value.
 * @param a_fp      The value to calculate absolute value.
 * @return float    The absolute value of a_fp.
 */
float fp_float32_abs(float a_fp);

/**
 * @brief Add arithmetic operation.
 * @param a_fp Number 1 to add.
 * @param b_fp Number 2 to add.
 * @return The sum of a_fp and b_fp.
 */
float fp_float32_add(float a_fp, float b_fp);

/**
 * @brief Subtraction arithmetic operation.
 * @param a_fp The minuend.
 * @param b_fp The subtrahend.
 * @return The result.
 */
float fp_float32_sub(float a_fp, float b_fp);

/**
 * @brief Multiplication.
 * @param a_fp The number 1 to multiply.
 * @param b_fp The number 2 to multiply.
 * @return The product.
 */
float fp_float32_mult(float a_fp, float b_fp);

/**
 * @brief Float Division.
 *
 * @param a_fp Dividend.
 * @param b_fp Divisor.
 * @return float Quotient.
 */
float fp_float32_div(float a_fp, float b_fp);

/**
 * @brief Convert float to signed long.
 *
 * @param a_fp float to be converted to long.
 * @return long the long integer.
 */
long fp_float32_to_int32(float a_fp);

/**
 * @brief Convert signed long to float.
 *
 * @param af long value to be converted to float.
 * @return float the float.
 */
float fp_int32_to_float32(long af);

/**
 * @brief Convert unsigned long to float.
 *
 * @param af unsigned long value to be converted to float.
 * @return float the float.
 */
float fp_uint32_to_float32(unsigned long af);

/*! \cond PRIVATE */
double fp_float32_to_float64(float a_fp);
float fp_float64_to_float32(double a_dfp);
/*! \endcond */

/**
 * @brief Compare two float value.
 *
 * @param a_fp float value a.
 * @param b_fp float value b.
 * @return int  0 if a==b; 1 if a>b; -1 if a<b;
 */
int fp_float32_cmp(float a_fp, float b_fp);

/*! \cond PRIVATE */
double fp_float64_add(double a_dfp, double b_dfp);
double fp_float64_sub(double a_dfp, double b_dfp);
double fp_float64_mult(double a_dfp, double b_dfp);
double fp_float64_div(double a_dfp, double b_dfp);
/*! \endcond */

/**
 * @brief Returns the square root of x.
 *
 * @param x Value whose square root is computed.
 * @return float Square root of x.If x < 0, return 0.
 */
float fp_float32_sqrt(float a);

/**
 * @brief Returns the cosine of an angle of x radians.
 *
 * @param rad Value representing an angle expressed in radians.
 * @return float Cosine of x radians.
 */
float fp_float32_cos(float rad);

/**
 * @brief Returns the sine of an angle of x radians.
 *
 * @param rad Value representing an angle expressed in radians.
 * @return float Sine of x radians.
 */
float fp_float32_sin(float rad);

/**
 * @brief Returns the principal value of the arc tangent of x, expressed in radians.
 *
 * @param x Value whose arc tangent is computed.
 * @return float Principal arc tangent of x, in the interval [-pi/2,+pi/2] radians.One radian is equivalent to 180/PI degrees.
 */
float fp_float32_atan(float x);

/**
 * @brief Returns the principal value of the arc tangent of y/x, expressed in radians.
 *
 * @param y Value representing the proportion of the y-coordinate.
 * @param x Value representing the proportion of the x-coordinate.
 * @return float Principal arc tangent of y/x, in the interval [-pi,+pi] radians.
 One radian is equivalent to 180/PI degrees.
 If x is zero, return 0.
 */
float fp_float32_atan2(float y, float x);

/**
 * @brief Returns the base-e exponential function of x, which is e raised to the power x.
 *
 * @param x   Value of the exponent.
 * @return float  Exponential value of x.
 */
float fp_float32_exp(float x);

/**
 * @brief The natural logarithm is the base-e logarithm: the inverse of the natural exponential function (fp_float32_exp).
 *
 * @param x  Value whose logarithm is calculated.
 * @return float Natural logarithm of x. If x <= 0, return 0.
 */

float fp_float32_log(float x);

/**
 * @brief Compute power.
 *
 * @param x  Base value.
 * @param y  Exponent value.
 * @return float  The result of raising base to the power exponent.
 */
float fp_float32_pow(float x, float y);

/*! Keyword PI. */
#define PI              ((float)3.1415926)
/**
 * @brief   Keyword HALF_PI, PI/2.0.
 */
#define HALF_PI         ((float)(PI/2.0))
/**
 * @brief   Keyword EIGHTH_PI, PI/8.0.
 */
#define EIGHTH_PI       ((float)(PI/8.0))
/**
 * @brief   Keyword TWO_PI, 2 * PI.
 */
#define TWO_PI          ((float)(PI*2.0))
/**
 * @brief   Keyword ATAN_EIGHTH_PI, atan(PI/8.0).
 */
#define ATAN_EIGHTH_PI  ((float)0.37419668)
/**
 * @brief   Keyword E_SQUARE, e^2.
 */
#define E_SQUARE        ((float)7.38905609)     // e^2
/**
 * @brief   Keyword INV_E_SQUARE, the reciprocal of e^2, 1/e^2.
 */
#define INV_E_SQUARE    ((float)0.13533528)     // 1/e^2
/**
 * @brief   Keyword LN_2, ln(2).
 */
#define LN_2            ((float)0.69314718)     // ln(2)

#endif
