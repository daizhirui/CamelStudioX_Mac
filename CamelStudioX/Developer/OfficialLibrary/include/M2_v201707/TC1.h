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

#define T1_CTL0_REG       0x1f800200  // Timer1 (32-bit)control and base
#define T1_REF_REG        0x1f800201  // Timer1 ref number for PWM(1)
#define T1_READ_REG       0x1f800202  // Timer1 value
#define T1_CLRIRQ_REG     0x1f800203  // Timer1 clear IRQ
#define T1_CLK_REG        0x1f800204  // Timer1 clk div
#define T1_CLRCNT_REG     0x1f800205  // Timer1 clear counter content (and PWM)

/***** Timer clr stop and flag Setup******/
#define RT_T1_Stop()		MemoryWrite32(T1_CTL0_REG, 0)
#define RT_T1_Clr()		{MemoryWrite32(T1_CLRIRQ_REG, 0); MemoryWrite32(T1_CLRCNT_REG, 0);}
#define RT_T1_SetIRQ(state)	MemoryWrite32(T1_CLRIRQ_REG, state)
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


/*********** Timer1 cnt End***************/

/*********** Timer1 PWM Setup*************/
//********************************************************//
// void RT_T1_PWM(int div, int ref, int irq)              //
//                                                        //
// Description:                                           //
// This function set the PWM function of tc1              //
// div: the clock freq divider                            //
// ref: 255-0, the clock high length                      //
// irq: when 1, the interrupt is enabled; when 0, disabled// 
//********************************************************//

#define RT_T1_PWM(div, ref, irq)	{MemoryAnd32(T1_CTL0_REG, ~(0x3<<6)); 	\
	MemoryWrite32(T1_CLK_REG, div);	\
	MemoryWrite32(T1_REF_REG, ref);	\
	MemoryOr32(T1_CTL0_REG,  (0x10 | (irq << 6)|(irq << 7)));}
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
/*********** Timer1 PWMM End***************/

#endif
