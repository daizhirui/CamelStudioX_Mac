/*--------------------------------------------------------------------
 * TITLE: M2 Hardware Definition
 * AUTHOR: Astro
 * DATE CREATED: 2017/10/31
 * FILENAME: SPI.h
 * PROJECT: M2Library
 * COPYRIGHT: Camel Microelectronics, Ltd.
 * DESCRIPTION:
 *--------------------------------------------------------------------*/
#ifndef __SPI_h__
#define __SPI_h__

#include "mcu.h"
#include "UART1.h"

/************** Value define *************/
#define MASTER 0x1
#define SLAVE 0x0
/*************** SPI Setup***************/
#define RT_SPI_ClearState() MemoryWrite32(SPI_IRQ_ACK_REG, 0x6)
#define RT_SPI_Modeset(MorS)             \
    {                                    \
        RT_UART1_Off();                  \
        if (MorS)                        \
            MemoryWrite32(SPI_CTL, 0x4); \
        else                             \
            MemoryWrite32(SPI_CTL, 0x0); \
        RT_SPI_ClearState();             \
    }
#define RT_SPI_ChipSelect() MemoryWrite32(SPI_CTL_REG, 0x6)
#define RT_SPI_ChipRelease() MemoryWrite32(SPI_CTL_REG, 0x4)
#define RT_SPI_Busy() MemoryRead32(SPI_BUSY_REG)
#define RT_SPI_Write_(val) MemoryWrite32(SPI_WRITE_REG, val)
#define RT_SPI_Write(val)     \
    {                         \
        while (RT_SPI_Busy()) \
            ;                 \
        RT_SPI_Write_(val);   \
        while (RT_SPI_Busy()) \
            ;                 \
    }
#define RT_SPI_DataReady() MemoryRead32(SPI_DATA_RDY_REG)
#define RT_SPI_Read_() MemoryRead32(SPI_READ_REG)
/**
 * @brief This function returns 1 byte from SPI
 * 
 * @return unsigned char 1-byte data from SPI
 */
unsigned char RT_SPI_Read();
/**
 * @brief This function transfers data when M2's SPI works as Master
 * 
 * @param c     1-byte data to send
 * @return unsigned char 1-byte data received
 */
unsigned char RT_SPI_MasterTransfer(unsigned char c);
/**
 * @brief This function transfers data when M2's SPI works as Slave
 * 
 * @param c     1-byte data to send
 * @return unsigned char 1-byte data received
 */
unsigned char RT_SPI_SlaveTransfer(unsigned char c);
#define RT_SPI_Off() MemoryOr32(SPI_CTL_REG, 0x8)
#define RT_SPI_On() MemoryAnd32(SPI_CTL_REG, ~0x8)
void RT_SPI_delay();
#endif
