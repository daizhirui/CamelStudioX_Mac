
#ifndef __UARTx_h__
#define __UARTx_h__

// UARTPORT should be defined in the module which uses this library.
// If UARTPORT is not defined in advance, compiler will use UART0 as default.
int UARTPORT=1;

#include "mcu.h"
#include "SPI.h"

#define UART1   1
#define UART0   0
/*********** Hardware addesses ***********/
#define UARTx_READ       0x1f800800+0x800*UARTPORT
#define UARTx_BUSY       0x1f800801+0x800*UARTPORT
#define UARTx_WRITE      0x1f800802+0x800*UARTPORT
#define UARTx_IRQ_ACK    0x1f800803+0x800*UARTPORT
#define UARTx_CTL        0x1f800804+0x800*UARTPORT
#define UARTx_DATA_RDY   0x1f800805+0x800*UARTPORT
#define UARTx_LIN_BREAK  0x1f800806+0x800*UARTPORT
#define UARTx_BRP        0x1f800807+0x800*UARTPORT

/*************** UART Setup***************/
#define RT_UART_Off()             MemoryOr32(UARTx_CTL,0x10)                  // UART off
#define RT_UART_On()              {SPI_Off();MemoryAnd32(UARTx_CTL,~0x10);}   // UART on
#define RT_UART_Busy()            MemoryRead32(UARTx_DATA_RDY)                // check tx busy
#define RT_UART_Write(val)        MemoryWrite32(UARTx_WRITE,val)              // send the data
#define RT_UART_DataReady()       MemoryRead32(UARTx_DATA_RDY)                // check data ready
#define RT_UART_Read()            MemoryRead32(UARTx_READ)                    // read the data
/**
 * @brief This function sets UART1 compare irq on
 * 
 * @return  void
 */
#define RT_UART_CompareOn()       MemoryOr32(UARTx_CTL,0x2)                   // UART compare irq on
/**
 * @brief This function sets UART1 compare irq off
 * 
 * @return  void
 */
#define RT_UART_CompareOff()      MemoryAnd32(UARTx_CTL,~0x2)                 // UART compare irq off
/**
 * @brief This function sets UART1 compare value
 * 
 * @return  void
 */
#define RT_UART_SetCompare(val)   MemoryOr32(UARTx_CTL,val<<8)                // set irq compare bits
#define RT_UART_ClearIrq()        MemoryWrite32(UARTx_IRQ_ACK,0x0)            // clear irq
#define RT_UART_RaiseIrq()        MemoryOr32(UARTx_CTL,0x1)                   // raise irq manually
/**
 * @brief This function sends 1-byte data by UART
 * 
 * @param c     1-byte data to send
 */
void RT_UART_putchar(unsigned char c);
/**
 * @brief This function sends a string by UART
 * 
 * @param string    the string to send
 */
void RT_UART_puts(unsigned char *string);
/**
 * @brief This function returns 1-byte data from UART
 * 
 * @return unsigned char    1-byte data from UART
 */
unsigned char RT_UART_getchar();

#endif