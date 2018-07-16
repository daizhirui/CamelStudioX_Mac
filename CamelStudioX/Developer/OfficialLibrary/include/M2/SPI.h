/**
* @file SPI.h
* @author Zhirui Dai
* @date 16 Jun 2018
* @copyright 2018 Zhirui
* @brief SPI Library for M2
*/
#ifndef __SPI_h__
#define __SPI_h__

#include "mcu.h"
#include "UART.h"

/**
 * @brief	Keyword MASTER
 */
#define MASTER 0x1

/**
 * @brief	Keyword SLAVE
 */
#define SLAVE 0x0
/*************** SPI Setup***************/

/**
 * @brief       Clear SPI internal
 * @return      void
 */
#define RT_SPI_ClearState()         MemoryWrite32(SPI_IRQ_ACK_REG, 0x6)

/**
 * @brief       SPI mode: master or slave
 * @param MorS  Optional value: #MASTER, #SLAVE
 * @return      void
 */
#define RT_SPI_Modeset(MorS)             \
    {                                    \
        RT_UART_Off(UART1);              \
        if (MorS)                        \
            MemoryWrite32(SPI_CTL, 0x4); \
        else                             \
            MemoryWrite32(SPI_CTL, 0x0); \
        RT_SPI_ClearState();             \
    }

/**
 * @brief       SPI CS on
 * @return      void
 */
#define RT_SPI_ChipSelect()         MemoryWrite32(SPI_CTL_REG, 0x6)

/**
 * @brief       SPI CS off, remain master mode
 * @return      void
 */
#define RT_SPI_ChipRelease()        MemoryWrite32(SPI_CTL_REG, 0x4)

/**
 * @brief       Read SPI Tx busy status
 * @return int  1=busy  0=idle
 */
#define RT_SPI_Busy()               MemoryRead32(SPI_BUSY_REG)

/**
 * @brief       Send a byte to SPI tx, start sending
 * @param  val  byte to send
 * @return      void
 */
#define RT_SPI_Write_(val)          MemoryWrite32(SPI_WRITE_REG, val)

/**
 * @brief       SPI byte tx procedure: wait when SPI is busy, return after the sending is completed.
 * @param val   byte to send
 * @return      void
 */
#define RT_SPI_Write(val)     \
    {                         \
        while (RT_SPI_Busy()) \
            ;                 \
        RT_SPI_Write_(val);   \
        while (RT_SPI_Busy()) \
            ;                 \
    }

/**
 * @brief       Check if SPI Rx has received a byte
 * @return int  1=data_ready  0=no_data
 */
#define RT_SPI_DataReady()          MemoryRead32(SPI_DATA_RDY_REG)

/**
 * @brief       Read SPI Rx recived byte
 * @note        Before useing this function, RT_SPI_DataReady() should be used to
                check if data is ready. Recommend RT_SPI_Read().
 * @return int  received Rx data
 */
#define RT_SPI_Read_()              MemoryRead32(SPI_READ_REG)

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
 * @brief       This function transfers data when M2's SPI works as Slave
 *
 * @param c     1-byte data to send
 * @return unsigned char 1-byte data received
 */
unsigned char RT_SPI_SlaveTransfer(unsigned char c);

/**
 * @brief       Turn off SPI
 * @return      void
 */
#define RT_SPI_Off() MemoryOr32(SPI_CTL_REG, 0x8)

/**
 * @brief       Turn on SPI
 * @return      void
 */
#define RT_SPI_On()                     \
    {                                   \
        RT_UART_Off(UART1);             \
        MemoryAnd32(SPI_CTL_REG, ~0x8); \
    }

/**
 * @brief   Insert 2 cycle delay
 * @note    This function is used only when the other SPI device is not fast enough.
 * @return  void
 */
void RT_SPI_Delay();

#endif
