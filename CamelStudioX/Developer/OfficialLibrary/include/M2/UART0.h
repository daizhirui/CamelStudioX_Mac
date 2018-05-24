/*--------------------------------------------------------------------
 * TITLE: M2 Hardware Definition
 * AUTHOR: Astro
 * DATE CREATED: 2017/10/31
 * FILENAME: UART0.h
 * PROJECT: M2Library
 * COPYRIGHT: Camel Microelectronics, Ltd.
 * DESCRIPTION:
 *--------------------------------------------------------------------*/
#ifndef __UART0_h__
#define __UART0_h__

#include "mcu.h"
#include "SPI.h"
/*********** Hardware addesses ***********/
#define UART0_READ      0x1f800000
#define UART0_BUSY      0x1f800001
#define UART0_WRITE     0x1f800002
#define UART0_IRQ_ACK   0x1f800003
#define UART0_CTL       0x1f800004
#define UART0_DATA_RDY  0x1f800005
#define UART0_LIN_BREAK 0x1f800006
#define UART0_BRP       0x1f800007
/*************** UART0 Setup***************/
#define RT_UART0_Off()             MemoryOr32(UART0_CTL,0x10)                  // UART0 off
#define RT_UART0_On()              {RT_SPI_Off();MemoryAnd32(UART0_CTL,~0x10);}   // UART0 on
#define RT_UART0_Busy()            MemoryRead32(UART0_BUSY)                // check tx busy
#define RT_UART0_Write(val)        MemoryWrite32(UART0_WRITE,val)              // send the data
#define RT_UART0_DataReady()       MemoryRead32(UART0_DATA_RDY)                // check data ready
#define RT_UART0_Read()            MemoryRead32(UART0_READ)                  // read the data

#define RT_UART0_IrqOn()   MemoryOr32(UART0_CTL,1)
#define RT_UART0_IrqOff()  MemoryAnd32(UART0_CTL,~1)
/**
 * @brief This function sets UART1 compare irq on
 * 
 * @return  void
 */
#define RT_UART0_CompareOn()       MemoryOr32(UART0_CTL,0x2)                   // UART0 compare irq on
/**
 * @brief This function sets UART1 compare irq off
 * 
 * @return  void
 */
#define RT_UART0_CompareOff()      MemoryAnd32(UART0_CTL,~0x2)                 // UART0 compare irq off
/**
 * @brief This function sets UART1 compare value
 * 
 * @return  void
 */
#define RT_UART0_SetCompare(val)   MemoryOr32(UART0_CTL,val<<8)                // set irq compare bits
#define RT_UART0_ClearIrq()        MemoryWrite32(UART0_IRQ_ACK,0x0)            // clear irq
#define RT_UART0_RaiseIrq()        MemoryOr32(UART0_CTL,0x1)                   // raise irq manually
/**
 * @brief This function sends 1-byte data by UART0
 * 
 * @param c     1-byte data to send
 */
void RT_UART0_putchar(unsigned char c);
/**
 * @brief This function sends a string by UART0
 * 
 * @param string    the string to send
 */
void RT_UART0_puts(unsigned char *string);
/**
 * @brief This function returns 1-byte data from UART0
 * 
 * @return unsigned char    1-byte data from UART0
 */
unsigned char RT_UART0_getchar();
#endif
