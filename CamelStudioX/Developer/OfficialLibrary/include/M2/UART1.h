/**
* @file UART1.h
* @author Zhirui Dai
* @date 31 Oct 2017
* @copyright 2018 Zhirui
* @brief Uart1 Library for M2
*/
#ifndef __UART1_h__
#define __UART1_h__

#include "mcu.h"
#include "SPI.h"
/*********** Hardware addesses ***********/
#define UART1_READ      0x1f800800
#define UART1_BUSY      0x1f800801
#define UART1_WRITE     0x1f800802
#define UART1_IRQ_ACK   0x1f800803
#define UART1_CTL       0x1f800804
#define UART1_DATA_RDY  0x1f800805
#define UART1_LIN_BREAK 0x1f800806
#define UART1_BRP       0x1f800807
/*************** UART1 Setup***************/
#define RT_UART1_Off()             MemoryOr32(UART1_CTL_REG,0x10)                  // UART1 off
#define RT_UART1_On()              {RT_SPI_Off();MemoryAnd32(UART1_CTL_REG,~0x10);}   // UART1 on
#define RT_UART1_Busy()            MemoryRead32(UART1_BUSY_REG)                    // check tx busy
#define RT_UART1_Write(val)        MemoryWrite32(UART1_WRITE_REG,val)              // send the data
#define RT_UART1_DataReady()       MemoryRead32(UART1_DATA_RDY_REG)                // check data ready
#define RT_UART1_Read()            MemoryRead32(UART1_READ_REG)                    // read the data

#define RT_UART1_IrqOn()   MemoryOr32(UART1_CTL_REG,1)
#define RT_UART1_IrqOff()  MemoryAnd32(UART1_CTL_REG,~1)

/**
 * @brief This function sets UART1 compare irq on
 *
 * @return  void
 */
#define RT_UART1_CompareOn()       MemoryOr32(UART1_CTL_REG,0x2)                   // UART1 compare irq on
/**
 * @brief This function sets UART1 compare irq off
 *
 * @return  void
 */
#define RT_UART1_CompareOff()      MemoryAnd32(UART1_CTL_REG,~0x2)                 // UART1 compare irq off
/**
 * @brief This function sets UART1 compare value
 *
 * @return  void
 */
#define RT_UART1_SetCompare(val)   MemoryOr32(UART1_CTL_REG,val<<8)                // set irq compare bits
#define RT_UART1_ClearIrq()        MemoryWrite32(UART1_IRQ_ACK_REG,0x0)            // clear irq
#define RT_UART1_RaiseIrq()        MemoryOr32(UART1_CTL_REG,0x1)                   // raise irq manually
#define RT_UART1_CheckIrq()        MemoryBitAt(UART1_CTL_REG,0)                    // Check irq
/**
 * @brief This function sends 1-byte data by UART1
 *
 * @param c     1-byte data to send
 */
void RT_UART1_putchar(unsigned char c);
/**
 * @brief This function sends a string by UART1
 *
 * @param string    the string to send
 */
void RT_UART1_puts(unsigned char *s);
/**
 * @brief This function returns 1-byte data from UART1
 *
 * @return unsigned char    1-byte data from UART1
 */
unsigned char RT_UART1_getchar();
#endif
