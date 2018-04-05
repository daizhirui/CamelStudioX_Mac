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
#ifndef __TC1_H__
#define __TC1_H__
#include "mcu.h"

/*********** Hardware addesses ***********/

#define T1_CTL0_REG       0x1f800200  // Timer1 (32-bit)control and base
#define T1_REF_REG        0x1f800201  // Timer1 ref number for PWM(4, 32bit)
#define T1_READ_REG       0x1f800202  // Timer1 value
#define T1_CLRIRQ_REG     0x1f800203  // Timer1 clear IRQ
#define T1_CLK_REG        0x1f800204  // Timer1 clk div
#define T1_CLRCNT_REG     0x1f800205  // Timer1 clear counter content (and PWM)
#define T1_PHASE_REG      0x1f800206  // Timer1 PWM phase reg (32b, 4 pwm)
#define T1_CLRPWM_REG	    0x1f800207  // Timer1 PWM clear counter

/***** Timer clr stop and flag Setup******/
#define RT_T1_Stop()		MemoryWrite32(T1_CTL0_REG, 0)
#define RT_T1_Clr()		{MemoryWrite32(T1_CLRIRQ_REG, 0); MemoryWrite32(T1_CLRCNT_REG, 0);}
#define RT_T1_Flag() 		((MemoryRead32(T1_CTL0_REG)&0x80000000)>>31)
/****************** end*******************/

/*********** Timer1 cnt Setup*************/
//********************************************************//
// void RT_T1_Set1u(int n£¬ int irq)                      //
// Description:                                           //
// This function set the cnt function of tc1              //
// "n" is times of 1us for timer to count                 //
// When "irq" = 1, enable the event count interrupt       // 
//********************************************************//

#define RT_T1_Set1u(n, irq)	{MemoryAnd32(T1_CTL0_REG, ~(1<<7)); 	\
	MemoryWrite32(T1_CLK_REG, 3);	\
	MemoryWrite32(T1_REF_REG, n);	\
	MemoryOr32(T1_CTL0_REG, (0x02 | (irq << 7)));}

//********************************************************//
// void RT_T1_Set100u(int n£¬ int irq)                    //
// Description:                                           //
// This function set the cnt function of tc1              //
// "n" is times of 100us for timer to count               //
// When "irq" = 1, enable the event count interrupt       // 
//********************************************************//

#define RT_T1_Set100u(n, irq)	{MemoryAnd32(T1_CTL0_REG, ~(1<<7)); 	\
	MemoryWrite32(T1_CLK_REG, 0xff);	\
	MemoryWrite32(T1_REF_REG, n);		\
	MemoryOr32(T1_CTL0_REG, (0x02 | (irq << 7)));}

/************Timer1 cnt End***************/

/*********** Timer1 PWM Setup*************/
//******************************************************************//
// void RT_T1_PWM(int div, int ref, int phase, int pwm0, int pwm13) //
//                                                                  //
// Description:                                                     //
// This function set the PWM function of tc2                        //
// Note: no IRQ in T1 PWM mode                                      //
//                                                                  //
// div: the clock freq divider                                      //
// ref: 255-0, the clock high length                                //
// phase: 255-0, the relative phase among 4 pwm                     //
//        8-bit for each pwm                                        //
//        [31:24] pwm3                                              //
//        [23:16] pwm2                                              //
//        [15:8]  pwm1                                              //
//        [7:0]   pwm0                                              //
// pwm0 : 1 -- enable PWM0  ,  0 --- disable PWM0                   // 
// pwm13: 1 -- enable PWM1-3,  0 --- disable PWM1-3                 // 
//******************************************************************//

#define RT_T1_PWM(div, ref0, ref1, ref2, ref3, phase0, phase1, phase2, phase3, pwm0, pwm13)  	{MemoryAnd32(T1_CTL0_REG, ~(0x3<<4)); 	\
	  MemoryOr32(T1_CTL0_REG, ((pwm0 << 4) | (pwm13 <<5)));	\
        MemoryWrite32(T1_CLK_REG, div);	\
        MemoryWrite32(T1_REF_REG, (ref0 + (ref1<<8) + (ref2<<16) + (ref3<<24)));	\
        MemoryWrite32(T1_PHASE_REG, (phase0 + (phase1<<8) + (phase2<<16) + (phase3<<24)));}

/*********** Timer1 PWM End***************/

/*********** Timer1 ECM Setup*************/
//********************************************************//
// void RT_T1_Ecnt(int n£¬int pos,int irq)                //
// Description:                                           //
// This function set the ecm function of tc1              //
// "n" is count value, "pos" is set to count when posedge //
// When "irq" = 1, enable the event count interrupt       // 
//********************************************************//

#define RT_T1_Ecnt(n,pos, irq)	{MemoryAnd32(T1_CTL0_REG, ~((0x1<<7)+(0x1<<2))); 	\
	MemoryOr32(T1_CTL0_REG, ((pos << 2) | (irq << 7)|0x1));	\
	MemoryWrite32(T1_REF_REG, n);}

/*********** Timer1 ECM End***************/

/*********** Timer1 PWMM Setup*************/
//********************************************************//
// void RT_T1_PulseWidth(int rise, int irq)               //
//                                                        //
// Description:                                           //
// This function set the Pulse width measure for T1       //
//                                                        //
// rise: 1:= positive pulse  0:= negative pulse           //
// irq: when 1, the interrupt is enabled; when 0, disabled// 
//********************************************************//

#define RT_T1_PulseWidth(rise, irq)	{MemoryAnd32(T1_CTL0_REG, ~((0x1<<7)+(0x1<<2))); 	\
	MemoryOr32(T1_CTL0_REG, (0x8 | (irq << 7) | (rise << 2)));}  

#define RT_T1_ReadCnt() 	MemoryRead32(T1_READ_REG)
/*********** Timer2 PWMM End***************/

#endif //__T1_H__
