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
#ifndef __SPI_H__
#define __SPI_H__
#include "mcu.h"

/*********** Hardware addesses ***********/

// SPI
#define SPI_WRITE_REG         0x1f800d02
#define SPI_READ_REG          0x1f800d00  // snoop read
#define SPI_DATA_RDY_REG      0x1f800d05
#define SPI_CTL_REG         0x1f800d04
#define SPI_IRQ_ACK_REG       0x1f800d03  // clear IRQ when wt
#define SPI_BUSY_REG          0x1f800d01

/*************** SPI Setup***************/

#define RT_SPI_ModeSet(MorS)	{if (MorS == 0) MemoryWrite32(SPI_CTL_REG, 0x0);	\
						 else		MemoryWrite32(SPI_CTL_REG, 0x6); 	\
				 MemoryWrite(0x1f800804, 0x10);}
#define RT_SPI_Write(val)	MemoryWrite32(SPI_WRITE_REG, val)
#define RT_SPI_DataRdy()	(*(volatile unsigned*)SPI_DATA_RDY_REG)
#define RT_SPI_Read()		(*(volatile unsigned long*)SPI_READ_REG)
#define RT_SPI_Busy()		MemoryRead32(SPI_BUSY_REG)
#define RT_SPI_Clr()		MemoryWrite32(SPI_IRQ_ACK_REG, 0x1)
#define RT_SPI_CSOff()          MemoryWrite32(SPI_CTL_REG, 0x0);
/**************** SPI End****************/

#endif //__SPI_H__
