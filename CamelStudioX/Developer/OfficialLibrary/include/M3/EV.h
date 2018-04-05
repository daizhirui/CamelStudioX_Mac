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
#ifndef __EV_H__
#define __EV_H__
#include "mcu.h"

#define EV_PWM_CTL0_REG     0x1f800400	// EV-CCU6 (16-bit) control and base
#define EV_PWM_OUTCTL		0x1f800401	// EV-CCU6 (16-bit) PWM output control 
#define EV_PWM_CLRIRQ_REG   0x1f800403	// EV-CCU6 clear IRQ
#define EV_PWM_MODULA_REG   0x1f800404
#define EV_PWM_CONF_REG     0x1f800405
#define EV_PWM_REF0_REG     0x1f800408
#define EV_PWM_REF1_REG     0x1f800409
#define EV_PWM_REF2_REG     0x1f80040a
#define EV_PWM_REF3_REG     0x1f80040b
#define EV_PWM_REF4_REG     0x1f80040c
#define EV_PWM_REF5_REG     0x1f80040d
#define EV_PWM_DT10_REG     0x1f80040e
#define SYS_GPIO1_REG       0x1f800706
#define A_CMP_CTL_REG   	0x1f800606
#define A_CLR_REG		    0x1f800603
#define EV_T0_CTL0_REG		0x1f800300
#define EV_T0_REFMSK_REG	0x1f800301
#define EV_T0_READ_REG		0x1f800302
#define EV_T0_CLRIRQ_REG	0x1f800303
#define EV_T0_CLK_REG		0x1f800304
#define EV_T0_CLRCNT_REG	0x1f800305
#define EV_T0_CPREG_REG		0x1f800306
#define EV_T0_QTTIMER_REG	0x1f800307
#define EV_T0_CAP0_REG		0x1f800308
#define EV_T0_CAP1_REG		0x1f800309
#define EV_T0_CAP2_REG		0x1f80030a

/***************QT function***********************************************/
// choose to use qt, 1 for on, 0 for off
#define RT_QT_SetMode(mode)		{MemoryAnd32(EV_T0_CTL0_REG, ~(1<<5));	\
	if (mode)	MemoryOr32(EV_T0_CTL0_REG, 1<<5);}	
	
// select x4/x1 mode, 1 for x4 mode, 0 for x1 mode
#define RT_QT_SetX4(mode)		{MemoryAnd32(EV_T0_CTL0_REG, ~(1<<14));	\
	if (mode)	MemoryOr32(EV_T0_CTL0_REG, 1<<14);}
	
// read count direction 
#define RT_QT_ReadUpOrDown()		((MemoryRead32(EV_T0_QTTIMER_REG))&0x80000000)>>31;

// read QT count
#define RT_QT_ReadCnt()		(MemoryRead32(EV_T0_QTTIMER_REG))&0xffff;
/**************End of QT function****************************************/
#endif
