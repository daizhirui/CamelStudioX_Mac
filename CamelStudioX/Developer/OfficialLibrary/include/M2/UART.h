/**
* @file UART.h
* @author Zhirui Dai
* @date 31 Oct 2017
* @copyright 2018 Zhirui
* @brief UART Library for M2
*/
#ifndef __UART_h__
#define __UART_h__

#include "mcu.h"

/**
* @brief Keyword UART0
*/
#define UART0   0x0
/**
* @brief Keyword UART0
*/
#define UART1   0x1
/**
* @brief Keyword EXTREME_BREAK
*/
#define EXTREME_BREAK   0x1
/**
* @brief Keyword NORMAL_BREAK
*/
#define NORMAL_BREAK    0x0

/*! \cond PRIVATE */
#define UART_CTL_REG(port)          (port? UART1_CTL_REG : UART0_CTL_REG)
#define UART_BUSY_REG(port)         (port? UART1_BUSY_REG : UART0_BUSY_REG)
#define UART_WRITE_REG(port)        (port? UART1_WRITE_REG : UART0_WRITE_REG)
#define UART_DATA_RDY_REG(port)     (port? UART1_DATA_RDY_REG : UART0_DATA_RDY_REG)
#define UART_READ_REG(port)         (port? UART1_READ_REG : UART0_READ_REG)
#define UART_IRQ_ACK_REG(port)      (port? UART1_IRQ_ACK_REG : UART0_IRQ_ACK_REG)
#define UART_LIN_BREAK_REG(port)    (port? UART1_LIN_BREAK_REG : UART0_LIN_BREAK_REG)
#define UART_BRP_REG(port)          (port? UART1_BRP_REG : UART0_BRP_REG)
/*! \endcond */

/**
 * @brief       Turn off Uart
 * @param port  Port to use, optional value: #UART0, #UART1
 * @return      void
 */
#define RT_UART_Off(port)             MemoryOr32(UART_CTL_REG(port),0x10)               // UART off

/**
 * @brief       Turn on Uart
 * @param port  Port to use, optional value: #UART0, #UART1
 * @return      void
 */
#define RT_UART_On(port)              {MemoryAnd32(UART_CTL_REG(port),~0x10);}          // UART on

/*! Keyword BAUDRATE_9600. */
#define BAUDRATE_9600   (0x0<<12)

/*! Keyword BAUDRATE_19200. */
#define BAUDRATE_19200  (0x1<<12)

/*! Keyword BAUDRATE_38400. */
#define BAUDRATE_38400  (0x3<<12)

/**
* @brief        Set the baudrate of UART.
* @param mode   Baudrate to set, optional value: #BAUDRATE_9600, #BAUDRATE_19200, #BAUDRATE_38400
* @return void
*/
#define RT_UART_SetBaudrate(mode)   RT_MCU_SetSystemClock(mode)

/**
 * @brief       Check if Uart Tx is busy
 * @param port  Port to use, optional value: #UART0, #UART1
 * @return int  1 = Uart Tx busy   0 = Uart Tx not busy
 */
#define RT_UART_Busy(port)            MemoryRead32(UART_BUSY_REG(port))                // check tx busy

/**
 * @brief       Sent data via Uart Tx
 * @param port  Port to use, optional value: #UART0, #UART1
 * @param val   data to Tx
 * @return      void
 */
#define RT_UART_Write(port, val)      MemoryWrite32(UART_WRITE_REG(port),val)              // send the data

/**
 * @brief       Check if Uart Rx has received data
 * @param port  Port to use, optional value: #UART0, #UART1
 * @return int  1=ready  0=not ready
 */
#define RT_UART_DataReady(port)       MemoryRead32(UART_DATA_RDY_REG(port))                // check data ready

/**
 * @brief       Read Uart Rx data
 * @param port  Port to use, optional value: #UART0, #UART1
 * @return int  Rx data
 */
#define RT_UART_Read(port)            MemoryRead32(UART_READ_REG(port))                  // read the data

/**
 * @brief       Turn on Uart Irq enable
 * @param port  Port to use, optional value: #UART0, #UART1
 * @return      void
 */
#define RT_UART_IrqOn(port)         MemoryOr32(UART_CTL_REG(port),1)

/**
 * @brief       Turn off Uart Irq (interrupt)
 * @param port  Port to use, optional value: #UART0, #UART1
 * @return      void
 */
#define RT_UART_IrqOff(port)        MemoryAnd32(UART_CTL_REG(port),~1)

/**
 * @brief       Set UART compare irq on, irq flag will be raised when the port
                receives a byte the same as the compare value.
 * @param port  Port to use, optional value: #UART0, #UART1
 * @return      void
 */
#define RT_UART_CompareOn(port)       MemoryOr32(UART_CTL_REG(port),0x2)                // UART compare irq on

/**
 * @brief       This function sets UART compare irq off
 * @param port  Port to use, optional value: #UART0, #UART1
 * @return      void
 */
#define RT_UART_CompareOff(port)      MemoryAnd32(UART_CTL_REG(port),~0x2)             // UART compare irq off

/**
 * @brief       Set UART port's compare value
 * @param port  Port to use, optional value: #UART0, #UART1
 * @param val   Value to be compared.
 * @return      void
 */
#define RT_UART_SetCompare(port, val)   MemoryOr32(UART_CTL_REG(port),val<<8)                // set irq compare bits

/**
 * @brief       Clear Uart Irq (interrupt)
 * @param port  Port to use, optional value: #UART0, #UART1
 * @return      void
 */
#define RT_UART_ClearIrq(port)        MemoryWrite32(UART_IRQ_ACK_REG(port),0x0)            // clear irq

/**
 * @brief       Turn on Uart Irq enable
 * @param port  Port to use, optional value: #UART0, #UART1
 * @return      void
 */
#define RT_UART_RaiseIrq(port)        MemoryOr32(UART_CTL_REG(port),0x1)                   // raise irq manually

/**
 * @brief       Check if Uart Irq enable
 * @param port  Port to use, optional value: #UART0, #UART1
 * @return int  1=enable  0=disable
 */
#define RT_UART_CheckIrq(port)        MemoryBitAt(UART_CTL_REG(port),0)                  // Check irq

/**
 * @brief       Turn on LIN sync
 * @param port  Port to use, optional value: #UART0, #UART1
 * @return      void
 */
#define RT_UART_LinSyncOn(port)         MemoryOr32(UART_CTL_REG(port),0x8)               // auto Linsync on

/**
 * @brief       Turn off LIN sync
 * @param port  Port to use, optional value: #UART0, #UART1
 * @return      void
 */
#define RT_UART_LinSyncOff(port)        MemoryAnd32(UART_CTL_REG(port),~0x8)             // auto Linsync off

/**
 * @brief       Turn on LIN break normal length (13-bit)
 * @param port  Port to use, optional value: #UART0, #UART1
 * @return      void
 */
#define RT_UART_LinBreakNormal(port)    MemoryAnd32(UART_CTL_REG(port),~0x20)            // 13-bit Lin break

/**
 * @brief       Turn on LIN break extra long length (26-bit)
 * @param port  Port to use, optional value: #UART0, #UART1
 * @return      void
 */
#define RT_UART_LinBreakExtreme(port)   MemoryOr32(UART_CTL_REG(port),0x20)              // 26-bit Lin break

/**
 * @brief       Send LIN break
 * @param port  Port to use, optional value: #UART0, #UART1
 * @return      void
 */
#define RT_UART_LinSendBreak(port)      MemoryWrite32(UART_LIN_BREAK_REG(port),0x0)      // send Lin break

/**
 * @brief       Check LIN irq enable
 * @param port  Port to use, optional value: #UART0, #UART1
 * @return int  1=enable  0=disable
 */
#define RT_UART_LinCheckIrq(port)       ((MemoryRead32(UART_CTL_REG(port))&0x4)>>3)        // check Lin irq

/**
 * @brief       Read Uart Brp value
 * @param port  Port to use, optional value: #UART0, #UART1
 * @return int  brp value
 */
#define RT_UART_GetBrp(port)            MemoryRead32(UART_BRP_REG(port))                 // get brp value

/**
 * @brief       Set LIN slave mode
 * @param port  Port to use, optional value: #UART0, #UART1
 * @return      void
 */
#define RT_UART_LinSlave(port)          UART_LinSyncOn(port)                       // Lin slave mode

/**
 * @brief       Send a character via Uart, to print via UART0, putchar() is recommended.
 * @param port  Port to use, optional value: #UART0, #UART1
 * @param c     character
 * @return      void
 */
void RT_UART_putchar(uint32_t port, unsigned char c);

/**
 * @brief           Send a string via Uart, to print via UART0, puts() is recommended.
 * @param port      Port to use, optional value: #UART0, #UART1
 * @param string    string
 * @return          void
 */
void RT_UART_puts(uint32_t port, unsigned char *string);

/**
 * @brief       Get a character via Uart, to get a byte via UART0, getchar() is recommended.
 * @param port  Port to use, optional value: #UART0, #UART1
 * @return char 1-byte data from Uart
 */
unsigned char RT_UART_getchar(uint32_t port);

/**
 * @brief           Send LIN break mode
 * @param port      Port to use, optional value: #UART0, #UART1
 * @param pattern   The length of the break, optional value: #NORMAL_BREAK, #EXTREME_BREAK
 * @return          void
 */
void RT_UART_LinMaster(uint32_t port, char pattern);
#endif
