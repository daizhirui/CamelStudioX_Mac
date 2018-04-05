/*--------------------------------------------------------------------
 * TITLE: ADC block define
 * AUTHOR: yuchun
 * DATE CREATED: 2016-9-15
 * FILENAME: AFE.h
 * PROJECT: m3
 * COPYRIGHT: Camel Microelectronics, Inc.
 * DESCRIPTION:
 *    driver for the OPO and ADC module
 *--------------------------------------------------------------------*/
#ifndef __AFE_H__
#define __AFE_H__
#include "mcu.h"

// this is ADC/analog
#define A_SDV2P_CTL_REG       0x1f800600  // SD and V2P control (16-bit)
#define A_OPO_CTL_REG         0x1f800601  // OPO0 control (16-bit)
#define A_SD_READ_REG         0x1f800602  // SD value read (16-bit)
#define A_CLR_REG             0x1f800603  // AD clear reg (16-bit)
#define A_OPO1_CTL_REG        0x1f800604  // OPO1 control (16-bit)
#define A_OPO_CHAN_REG        0x1f800605  // OPO0, OPO1 chan control (16-bit)
#define A_CMP_CTL_REG         0x1f800606  // Comparator control (16-bit)
#define A_SAR_CTL_REG         0x1f800607  // SAR control (16-bit)
#define A_PWR_DAC_REG	      0x1f800608  // PWR/DAC control 
#define A_PWR_TRM_REG         0x1f800609  // PWR trim 
#define A_CALI_REG	      0x1f80060a  // PWR/OSC cali reg
	

/***** OPO, ADC and SAR setup******/
//chose to use OPO0 or not
#define RT_OPO_SetEn(en) 	{if (en)	MemoryOr32(A_OPO_CTL_REG, 1);	\
	else 		MemoryAnd32(A_OPO_CTL_REG, ~1);}

//chose to use OPO1 or not
#define RT_OPO1_SetEn(en) 	{if (en)	MemoryOr32(A_OPO1_CTL_REG, 1);	\
	else 		MemoryAnd32(A_OPO1_CTL_REG, ~1);}

//select the AIN for OPO0 P-side input, n for AIN number, i.g. 0,1,2,3
#define RT_OPO_PAin(n)	MemoryOr32(A_OPO_CHAN_REG, n<<2);	

//select the AIN for OPO0 N-side input, n for AIN number, i.g. 0,1,2,3
#define RT_OPO_NAin(n)	MemoryOr32(A_OPO_CHAN_REG, n);	

//select the AIN for OPO1 P-side input, n for AIN number, i.g. 4,5,6,7
#define RT_OPO1_PAin(n)	MemoryOr32(A_OPO_CHAN_REG, n<<10);	

//select the AIN for OPO1 N-side input, n for AIN number, i.g. 4,5,6,7
#define RT_OPO1_NAin(n)	MemoryOr32(A_OPO_CHAN_REG, n<<8);	

//select the opo0 resistor and amplification factor for both p side and n side
#define RT_OPO_SetAmp(pres, nres, pamp, namp) 	{MemoryAnd32(A_OPO_CTL_REG, ~(0xff<<8)); 	\
	MemoryOr32(AD_OPO_REG, (((pres<<7) + (pamp<<4) + (nres<<3) + namp)<<8));}

//select the opo1 resistor and amplification factor for both p side and n side
#define RT_OPO1_SetAmp(pres, nres, pamp, namp) 	{MemoryAnd32(A_OPO1_CTL_REG, ~(0xff<<8)); 	\
	MemoryOr32(AD_OPO_REG, (((pres<<7) + (pamp<<4) + (nres<<3) + namp)<<8));}

//select amp feedback to be single side  or both side , 0 for both side (normal use), 1 for single side (only n side has feedback)
#define RT_OPO_SetAmpMode(mode) 	{if (mode)	MemoryOr32(A_OPO_CTL_REG, (3<<3));	\
	else 		MemoryAnd32(AD_OPO_REG, ~(1<<3));}

//select amp feedback to be single side  or both side , 0 for both side (normal use), 1 for single side (only n side has feedback)
#define RT_OPO1_SetAmpMode(mode) 	{if (mode)	MemoryOr32(A_OPO1_CTL_REG, (3<<3));	\
	else 		MemoryAnd32(AD_OPO_REG, ~(1<<3));}

//select opo0 input to be single-ended or differential-ended, 1 differential-ended, 0 for single-ended(opo p-side input is vref)
#define RT_OPO_SetInputMode(mode)	{if (mode)  MemoryOr32(A_OPO_CHAN_REG, (1<<7);	\
	else MemoryAnd32(A_OPO_CHAN_REG, ~(1<<7);}

// select opo1 input to be single-ended or differential-ended, 1 differential-ended, 0 for single-ended(opo p-side input is vref)
#define RT_OPO1_SetInputMode(mode)	{if (mode)  MemoryOr32(A_OPO_CHAN_REG, (1<<15);	\
	else MemoryAnd32(A_OPO_CHAN_REG, ~(1<<15);}

//1 for short opo0 inn and inp
#define RT_OPO_SetShort(mode) 	{if (mode) MemoryOr32(A_OPO_CTL_REG, (1<<1));	\
	else MemoryAnd32(AD_OPO_REG, ~(1<<1));}

//1 for short opo1 inn and inp
#define RT_OPO1_SetShort(mode) 	{if (mode) MemoryOr32(A_OPO1_CTL_REG, (1<<1));	\
	else MemoryAnd32(AD_OPO_REG, ~(1<<1));}

//choose v2p, 1 for on, 0 for off
#define RT_V2P_SetMode(mode) 	{MemoryAnd32(A_SDV2P_CTL_REG, ~(1<<8)); 	\
	if (mode) 	MemoryOr32(A_SDV2P_CTL_REG, (1<<8));}
	
//select the V2P input source, 2 for ain bypass, 1 for opo1, 0 for opo0
#define RT_V2P_SetInSource(src) 	{MemoryAnd32(A_SDV2P_CTL_REG, ~(0x3<<5);		\
	MemoryOr32(A_SDV2P_CTL_REG, src<<5);

//set the resistor for v2p, 0 -> 220k, 1 -> 256k, 2 -> 291k, 3 -> 185k
#define RT_V2P_SetV2PRes(res) 	{MemoryAnd32(A_SDV2P_CTL_REG, ~(0x3<<9)); 	\
	MemoryOr32(A_SDV2P_CTL_REG, (res<<9));}

//choose the ADC, 1 for on, 0 for off
#define RT_ADC_SetMode(mode) 	{MemoryAnd32(A_SDV2P_CTL_REG, ~1);	\
	if (mode)	MemoryOr32(A_SDV2P_CTL_REG, 1);}
	
//select the ADC input source, 2 for ain bypass, 1 for opo1, 0 for opo0
#define RT_ADC_SetInSource(src) 	{MemoryAnd32(A_SDV2P_CTL_REG, ~(0x3<<13));		\
	MemoryOr32(A_SDV2P_CTL_REG, src<<13);	}
	
//set the measurement sampling rate, mode = 0, 1, 2, 3, --> 3M, 1.5M, 780K, 390K
#define RT_ADC_SetSampleRate(mode) 	{MemoryAnd32(A_SDV2P_CTL_REG, ~(0x3<<3));	\
        MemoryOr32(A_SDV2P_CTL_REG, (mode<<3));}

//set the digital filter clock freq, 0 for 1KHz, 1 for 512Hz, 2 for 256Hz, 3 for 128Hz
#define RT_ADC_SetFilterCLK(freq) 	{MemoryAnd32(A_SDV2P_CTL_REG, ~(0x3<<1));	\
	MemoryOr32(A_SDV2P_CTL_REG, (freq<<1));}

//choose the SAR, 1 for on, 0 for off
#define RT_SAR_SetMode(mode) 	{MemoryAnd32(A_SAR_CTL_REG, ~1);	\
	if (mode)	MemoryOr32(A_SAR_CTL_REG, 1);}

//select the channels for SAR ADC to be used, 1 for use, 0 for not use
#define RT_SAR_SetCh(ch0, ch1, ch2, ch3) 	{MemoryAnd32(A_SAR_CTL_REG, ~(0xf<<4)); 	\
        MemoryOr32(A_SAR_CTL_REG, ((ch0<<4) + (ch1<<5) + (ch2<<6) + (ch3<<7)));}

//set the negative reference voltage source for SAR, 1 for using external vrefn, 0 for using internal vrefn
#define RT_SAR_SetVrefn(mode) 	{MemoryAnd32(A_SAR_CTL_REG, ~(1<<11));	\
	if (mode)	MemoryOr32(A_SAR_CTL_REG, 1<<11);}

//set SAR resolution, 0 for 8-bit, 1 for 12-bit
#define RT_SAR_SetResolution(res) 	{MemoryAnd32(A_SAR_CTL_REG, ~(1<<1));	\
	if (mode)	MemoryOr32(A_SAR_CTL_REG, 1<<1);}

//set SAR run mode, 0 for continuous run, 1 for run one time
#define RT_SAR_SetRunTime(mode) 	{MemoryAnd32(A_SAR_CTL_REG, ~(1<<2));	\
	if (mode)	MemoryOr32(A_SAR_CTL_REG, 1<<2);}

//set the SAR triggle source, 0 for cs trigger, 1 for pwm trigger
#define RT_SAR_SetTrigger(mode) 	{MemoryAnd32(A_SAR_CTL_REG, ~(1<<3));	\
	if (mode)	MemoryOr32(A_SAR_CTL_REG, 1<<3);}
/***** End of OPO, ADC and SAR setup *****/

/***** COMPARATOR setup******/
//choose the CMP0, 1 for on, 0 for off
#define RT_CMP0_SetMode(mode) 	{MemoryAnd32(A_CMP_CTL_REG, ~1);	\
	if (mode)	MemoryOr32(A_CMP_CTL_REG, 1);}

//choose the CMP1, 1 for on, 0 for off
#define RT_CMP1_SetMode(mode) 	{MemoryAnd32(A_CMP_CTL_REG, ~(1<<1));	\
	if (mode)	MemoryOr32(A_CMP_CTL_REG, (1<<1));}

//choose the CMP2, 1 for on, 0 for off
#define RT_CMP2_SetMode(mode) 	{MemoryAnd32(A_CMP_CTL_REG, ~(1<<2));	\
	if (mode)	MemoryOr32(A_CMP_CTL_REG, (1<<2));}

//select cmp input to be single-ended or differential-ended, 1 differential-ended, 0 for single-ended(n-side input is vref)
#define RT_CMP_SetInputMode(mode)	{if (mode)  MemoryOr32(A_CMP_CTL_REG, (1<<3);	\
	else MemoryAnd32(A_CMP_CTL_REG, ~(1<<3);}

//set reference voltage for single-ended cmp. 0 for 1.5v*(13/16), 1 for 1.5v*(14/16), 2 for 1.5v*(15/16), 3 for 1.5v
#define RT_CMP_SetVref(mode)	MemoryOr32(A_CMP_CTL_REG, n<<4);
/***** End of COMPARATOR setup******/

int RT_ADC_Read();
int RT_V2P_Read();
#define RT_SAR_Read() 	(MemoryRead32(A_CLR_REG)&0xfff);
#define RT_CMP_Read()	((MemoryRead32(A_CLR_REG)&0xE000)>>13);

#endif
