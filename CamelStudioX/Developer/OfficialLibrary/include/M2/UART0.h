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

/*************** UART0 Setup***************/
#define RT_UART0_Off()             MemoryOr32(UART0_CTL_REG,0x10)                  // UART0 off
#define RT_UART0_On()              {MemoryAnd32(UART0_CTL_REG,~0x10);}          // UART0 on
#define RT_UART0_Busy()            MemoryRead32(UART0_BUSY_REG)                // check tx busy
#define RT_UART0_Write(val)        MemoryWrite32(UART0_WRITE_REG,val)              // send the data
#define RT_UART0_DataReady()       MemoryRead32(UART0_DATA_RDY_REG)                // check data ready
#define RT_UART0_Read()            MemoryRead32(UART0_READ_REG)                  // read the data

#define RT_UART0_IrqOn()   MemoryOr32(UART0_CTL_REG,1)
#define RT_UART0_IrqOff()  MemoryAnd32(UART0_CTL_REG,~1)
/**
 * @brief This function sets UART1 compare irq on
 * 
 * @return  void
 */
#define RT_UART0_CompareOn()       MemoryOr32(UART0_CTL_REG,0x2)                   // UART0 compare irq on
/**
 * @brief This function sets UART1 compare irq off
 * 
 * @return  void
 */
#define RT_UART0_CompareOff()      MemoryAnd32(UART0_CTL_REG,~0x2)                 // UART0 compare irq off
/**
 * @brief This function sets UART1 compare value
 * 
 * @return  void
 */
#define RT_UART0_SetCompare(val)   MemoryOr32(UART0_CTL_REG,val<<8)                // set irq compare bits
#define RT_UART0_ClearIrq()        MemoryWrite32(UART0_IRQ_ACK_REG,0x0)            // clear irq
#define RT_UART0_RaiseIrq()        MemoryOr32(UART0_CTL_REG,0x1)                   // raise irq manually
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
