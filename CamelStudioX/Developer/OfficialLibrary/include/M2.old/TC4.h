/*--------------------------------------------------------------------
 * TITLE: m2 Hardware Defines
 * AUTHOR: John & Jack 
 * DATE CREATED: 2013/10/10
 * FILENAME: m2.h
 * PROJECT: m2
 * COPYRIGHT: Small World, Inc.
 * DESCRIPTION:
 *    m2 Hardware Defines
 *
 *    2014-03-17: added sd adc, opo, v2p; sys reg modified
 *    2014-01-11: added sd adc, opo, v2p; sys reg modified
 *    2013-12-18: misc edit
 *    2013-12-15: uart reg back to m1
 *    2012-10-16: modified base on m2 new design
 *    2012-10-10: modified base on s0.h
 *--------------------------------------------------------------------*/
#ifndef __TC4_H__
#define __TC4_H__
#include "mcu.h"

/*********** Hardware addesses ***********/

// this is PWM/Bz unit, has two PWMs
#define T4_CTL0_REG       0x1f800a00  // Timer8-4 (2-bit) enable control 
#define T4_REF0_REG       0x1f800a01  // Timer8-4 ref number for PWM0 buz(8-bit)
#define T4_CLK0_REG       0x1f800a02  // Timer8-4 clk div for PWM0 (8-bit)
#define T4_REF1_REG       0x1f800a03  // Timer8-4 ref number for PWM1 fast(4-bit)
#define T4_CLK1_REG       0x1f800a04  // Timer8-4 clk div for PWM1 (8-bit)

/***** Timer clr stop and flag Setup******/
#define RT_T4_Stop() 		MemoryWrite32(T4_CTL0_REG, 0)
/****************** end*******************/

/*********** Timer4 PWM Setup*************/
//********************************************************//
// void RT_T4_PWM(int div0, int ref0, 
//                int div1, int ref1, int val)            //
//                                                        //
// Description:                                           //
// This function set the PWM function of tc4              //
// div0: the clock freq divider of t4_pwm0                //
// ref0: 15-0, the clock high length of t4_pwm0           //
// div1: the clock freq divider of t4_pwm1                //
// ref1: 15-0, the clock high length of t4_pwm1           //
// val : 0,  disable t4_pwm0, disable t4_pwm1             //
//       1,  enable  t4_pwm0, disable t4_pwm1             //
//       2,  disable t4_pwm0, enable  t4_pwm1             //
//       3,  enable  t4_pwm0, enable  t4_pwm1             //
//********************************************************//

#define RT_T4_PWM(pwm0_en, div0, ref0, pwm1_en, div1, ref1)	{MemoryWrite32(T4_CLK0_REG, div0);	\
	MemoryWrite32(T4_REF0_REG, ref0);	\
	MemoryWrite32(T4_CLK1_REG, div1);	\
	MemoryWrite32(T4_REF1_REG, ref1);	\
	MemoryAnd32(T4_CTL0_REG, ~(0x3));	\ 
	MemoryOr32(T4_CTL0_REG, (pwm0_en + pwm1_en<<1));}
/*********** Timer4 PWM End***************/

#endif //__T4_H__
