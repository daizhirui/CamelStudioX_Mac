/*--------------------------------------------------------------------
 * TITLE: ADC block define
 * AUTHOR: Bill
 * DATE CREATED: 2015-11-4
 * FILENAME: AFE.h
 * PROJECT: m2
 * COPYRIGHT: Camel Microelectronics, Inc.
 * DESCRIPTION:
 *    driver for the OPO and ADC module
 *--------------------------------------------------------------------*/
#ifndef __AFE_H__
#define __AFE_H__
#include "mcu.h"

// this is ADC/analog
#define AD_CTL0_REG       0x1f800600  // SD and V2P control (16-bit)
#define AD_CLR_REG        0x1f800603  // SD ADC clear reg
#define AD_OPO_REG        0x1f800601  // OPO and Chan control (16-bit)
#define AD_READ_REG       0x1f800602  // SD df read (16-bit)


/***** OPO and ADC setup******/
//chose to use OPO or not
#define RT_OPO_SetEn(en) 	{if (en)	MemoryOr32(AD_OPO_REG, 1);	\
	else 		MemoryAnd32(AD_OPO_REG, ~1);}

//select the channels to be used, 1 for use, 0 for not use
#define RT_OPO_SetCh(ch0, ch1, ch2, ch3) 	{MemoryAnd32(AD_OPO_REG, ~(0xf<<4)); 	\
        MemoryOr32(AD_OPO_REG, ((ch0<<4) + (ch1<<5) + (ch2<<6) + (ch3<<7)));}

//select the amplify resistor and amplification factor for both p side and n side
#define RT_OPO_SetAmp(pres, nres, pamp, namp) 	{MemoryAnd32(AD_OPO_REG, ~(0xff<<8)); 	\
	MemoryOr32(AD_OPO_REG, (((pres<<7) + (pamp<<4) + (nres<<3) + namp)<<8));}

//select amp feedback to be single side  or both side , 0 for both side (normal use), 1 for single side (only n side has feedback)
#define RT_OPO_SetAmpMode(mode) 	{if (mode)	MemoryOr32(AD_OPO_REG, (1<<3));	\
	else 		MemoryAnd32(AD_OPO_REG, ~(1<<3));}
	
//1 for inn and inp switch, 0 for not (normal use)
#define RT_OPO_SetInMode(mode) 	{if(mode)	MemoryOr32(AD_OPO_REG, (1<<2));	\
	else 		MemoryAnd32(AD_OPO_REG, ~(1<<2));}

//1 for short inn and inp
#define RT_OPO_SetShort(mode) 	{if (mode) {MemoryAnd32(AD_OPO_REG, ~(0xf<<4)); 	\
		MemoryOr32(AD_OPO_REG, (1<<1));	\
	} else MemoryAnd32(AD_OPO_REG, ~(1<<1));}

//select the filter resistor, 1 for 50k and 0 for 100k
#define RT_OPO_SetFilter(res) 	{int state = MemoryRead32(AD_CTL0_REG);	\
	if (res)	MemoryOr32(AD_CTL0_REG, (1<<15));	\
	else 	MemoryAnd32(AD_CTL0_REG, ~(1<<15));}

//choose the ADC, 1 for on, 0 for off
#define RT_ADC_SetMode(mode) 	{MemoryAnd32(AD_CTL0_REG, ~1);	\
	if (mode)	MemoryOr32(AD_CTL0_REG, 1);}
	
//choose v2p, 1 for on, 0 for off
#define RT_V2P_SetMode(mode) 	{MemoryAnd32(AD_CTL0_REG, ~(1<<8)); 	\
	if (mode) 	MemoryOr32(AD_CTL0_REG, (1<<8));}

//set the measurement sampling rate, mode = 0, 1, 2, 3, --> 3M, 1.5M, 780K, 390K
#define RT_ADC_SetSampleRate(mode) 	{MemoryAnd32(AD_CTL0_REG, ~(0x3<<3));	\
        MemoryOr32(AD_CTL0_REG, (mode<<3));}

//set the digital filter clock freq, 0 for 1KHz, 1 for 512Hz, 2 for 256Hz, 3 for 128Hz
#define RT_ADC_SetFilterCLK(freq) 	{MemoryAnd32(AD_CTL0_REG, ~(0x3<<1));	\
	MemoryOr32(AD_CTL0_REG, (freq<<1));}

//set the resistor for v2p, 0 -> 220k, 1 -> 256k, 2 -> 291k, 3 -> 185k
#define RT_V2P_SetV2PRes(res) 	{MemoryAnd32(AD_CTL0_REG, ~(0x3<<9)); 	\
	MemoryOr32(AD_CTL0_REG, (res<<9));}
	
// clear AD result
#define RT_ADC_Clr()	{MemoryWrite32(AD_CLR_REG, 1);}

// start ADC accumulate
#define RT_ADC_Start()	{MemoryWrite32(AD_READ_REG, 1);}
/***** End of OPO and ADC setup *****/
int RT_ADC_Read();
int RT_V2P_Read();

#endif
