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
#ifndef __WDT_TC4_H__
#define __WDT_TC4_H__
#include "mcu.h"

/*********** Hardware addesses ***********/
// this is Watch dog timer
#define WDT_T4_CTL0_REG      0x1f800b00  // WDT/T4 control
#define T4_CLK0_REF0_REG     0x1f800b01  // T4 ref number and clk div for PWM0 buz
#define T4_CLK1_REF1_REG     0x1f800b02  // T4 ref number and clk div for PWM1 fast
#define WDT_CLR_REG          0x1f800b03  // WDT clr reg
#define WDT_READ_REG         0x1f800b04  // WDT read reg

/*************** WDT Setup***************/
//********************************************************//
// void RT_WDT_Set(n, irq, rst);          			      //
//                                                        //
// Description:                                           //
// This function set the WDT app    				      //
// n:   the number of 1/8s   n=1~256                       //
// irq: trigger interrupt						          //
// reset: reset the system						          //
//********************************************************//

#define RT_WDT_Set(n, irq, rst, en) 	MemoryWrite32(WDT_T4_CTL0_REG, (n<<8 | irq<<2 | rst<<1 | en))
#define RT_WDT_Clr()				MemoryWrite32(WDT_CLR_REG, 1)
/**************** WDT End****************/


/***** Timer4 clr stop and flag Setup******/
#define RT_T4_Stop() 		MemoryAnd32(WDT_T4_CTL0_REG, ~(0x11<<4))
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

#define RT_T4_PWM(pwm0_en, div0, ref0, pwm1_en, div1, ref1)	{MemoryWrite32(T4_CLK0_REF0_REG, ((div0<<8) | ref0));	\
	MemoryWrite32(T4_CLK1_REF0_REG, ((div1<<8) | ref1));	\
	MemoryAnd32(WDT_T4_CTL0_REG, ~(0x3<<4));		\
	MemoryOr32(T4_CTL0_REG, ((pwm0_en + pwm1_en<<1)<<4));}
/*********** Timer4 PWM End***************/

#endif //__WDT_TC4_H__
