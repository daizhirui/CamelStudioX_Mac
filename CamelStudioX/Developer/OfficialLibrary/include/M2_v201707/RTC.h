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
#ifndef __RTC_H__
#define __RTC_H__
#include "mcu.h"

/*********** Hardware addesses ***********/

// RTC
#define RTC_CTL_REG       0x1f800f00
#define RTC_TIME_REG      0x1f800f01  // time
#define RTC_CLR_REG       0x1f800f03
#define RT_RTC_Init12() 	{MemoryWrite32(RTC_CTL_REG,0x00000001); MemoryWrite32(RTC_TIME_REG,0x00420000);}
#define RT_RTC_Init24() 	{MemoryWrite32(RTC_CTL_REG,0x00000003); MemoryWrite32(RTC_TIME_REG,0x00420000);}
#define RT_RTC_Set(year, mon, day, hour, min, sec) MemoryWrite32(RTC_TIME_REG, year<<26+mon<<22+day<<17+hour<<12+min<<6+sec)
#define RT_RTC_Read32() 	MemoryRead32(RTC_TIME_REG)

extern void RT_RTC_Read(unsigned char *d_year,unsigned char *d_mon,unsigned char *d_day,unsigned char *d_hour,unsigned char *d_min,unsigned char *d_sec);


#endif //__RTC_H__
