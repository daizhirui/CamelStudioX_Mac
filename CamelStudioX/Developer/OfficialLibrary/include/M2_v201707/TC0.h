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
#ifndef __TC0_H__
#define __TC0_H__
#include "mcu.h"

#define T0_CTL0_REG       0x1f800100  // Timer0 (32-bit)control and base
#define T0_REF_REG        0x1f800101  // Timer0 ref number for PWM(1)
#define T0_READ_REG       0x1f800102  // Timer0 value
#define T0_CLRIRQ_REG     0x1f800103  // Timer0 clear IRQ
#define T0_CLK_REG        0x1f800104  // Timer0 clk div
#define T0_CLRCNT_REG     0x1f800105  // Timer0 clear counter content (and PWM)

/***** Timer clr stop and flag Setup******/
#define RT_T0_Stop()		MemoryWrite32(T0_CTL0_REG, 0)
#define RT_T0_Clr()		{MemoryWrite32(T0_CLRIRQ_REG, 0); MemoryWrite32(T0_CLRCNT_REG, 0);}
#define RT_T0_SetIRQ(state)	MemoryWrite32(T0_CLRIRQ_REG, state)
#define RT_T0_Flag() 		((MemoryRead32(T0_CTL0_REG)&0x80000000)>>31)

/****************** end*******************/

/*********** Timer0 cnt Setup*************/
//********************************************************//
// void RT_T0_Set1u(int n£¬ int irq)                      //
// Description:                                           //
// This function set the cnt function of tc1              //
// "n" is times of 1us for timer to count                 //
// When "irq" = 1, enable the event count interrupt       // 
//********************************************************//

#define RT_T0_Set1u(n, irq)	{MemoryAnd32(T0_CTL0_REG, ~(1<<7)); 	\
	MemoryWrite32(T0_CLK_REG, 3);	\
	MemoryWrite32(T0_REF_REG, n);	\
	MemoryOr32(T0_CTL0_REG, (0x02 | (irq << 7)));}

//********************************************************//
// void RT_T0_Set100u(int n£¬ int irq)                    //
// Description:                                           //
// This function set the cnt function of tc1              //
// "n" is times of 100us for timer to count               //
// When "irq" = 1, enable the event count interrupt       // 
//********************************************************//

#define RT_T0_Set100u(n, irq)	{MemoryAnd32(T0_CTL0_REG, ~(1<<7)); 	\
	MemoryWrite32(T0_CLK_REG, 0xff);	\
	MemoryWrite32(T0_REF_REG, n);		\
	MemoryOr32(T0_CTL0_REG, (0x02 | (irq << 7)));}

/*********** Timer0 cnt End***************/

/*********** Timer0 PWM Setup*************/
//********************************************************//
// void RT_T0_PWM(int div, int ref, int irq)              //
//                                                        //
// Description:                                           //
// This function set the PWM function of tc0              //
// div: the clock freq divider                            //
// ref: 255-0, the clock high length                      //
// irq: when 1, the interrupt is enabled; when 0, disabled// 
//********************************************************//

#define RT_T0_PWM(div, ref, irq)	{MemoryAnd32(T0_CTL0_REG, ~(0x3<<6)); 	\
	MemoryWrite32(T0_CLK_REG, div);	\
	MemoryWrite32(T0_REF_REG, ref);	\
	MemoryOr32(T0_CTL0_REG,  (0x10 | (irq << 6)|(irq << 7)));}
/*********** Timer0 PWM End***************/

/*********** Timer0 ECM Setup*************/
//********************************************************//
// void RT_T0_Ecnt(int n£¬int pos,int irq)                //
// Description:                                           //
// This function set the ecm function of tc1              //
// "n" is count value, "pos" is set to count when posedge //
// When "irq" = 1, enable the event count interrupt       // 
//********************************************************//

#define RT_T0_Ecnt(n,pos, irq)	{MemoryAnd32(T0_CTL0_REG, ~((0x1<<7)+(0x1<<2))); 	\
	MemoryOr32(T0_CTL0_REG, ((pos << 2) | (irq << 7)|0x1));	\
	MemoryWrite32(T0_REF_REG, n);}

/*********** Timer0 ECM End***************/

/*********** Timer0 PWMM Setup*************/
//********************************************************//
// void RT_T0_PulseWidth(int rise, int irq)               //
//                                                        //
// Description:                                           //
// This function set the Pulse width measure for T0       //
//                                                        //
// rise: 1:= positive pulse  0:= negative pulse           //
// irq: when 1, the interrupt is enabled; when 0, disabled// 
//********************************************************//

#define RT_T0_PulseWidth(rise, irq)	{MemoryAnd32(T0_CTL0_REG, ~((0x1<<7)+(0x1<<2))); 	\
	MemoryOr32(T0_CTL0_REG, (0x8 | (irq << 7) | (rise << 2)));}  

#define RT_T0_ReadCnt() 	MemoryRead32(T0_READ_REG)

/*********** Timer0 PWMM End***************/

#endif
