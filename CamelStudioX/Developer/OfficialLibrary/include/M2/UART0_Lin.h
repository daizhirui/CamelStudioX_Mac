/*--------------------------------------------------------------------
 * TITLE: M2 Hardware Definition
 * AUTHOR: Astro
 * DATE CREATED: 2017/11/1
 * FILENAME: UART0_Lin.h
 * PROJECT: M2Library
 * COPYRIGHT: Camel Microelectronics, Ltd.
 * DESCRIPTION:
 *--------------------------------------------------------------------*/
#ifndef __UART0_Lin_h__
#define __UART0_Lin_h__

#include "mcu.h"
#include "UART0.h"
/*************** UART0 Setup***************/
// Set UART0_Lin on
#define RT_UART0_LinSyncOn()       MemoryOr32(UART1_CTL,0x8)               // auto Linsync on
// Set UART0_Lin off
#define RT_UART0_LinSyncOff()      MemoryAnd32(UART1_CTL,~0x8)             // auto Linsync off
// Set UART0_Lin normal break
#define RT_UART0_LinBreakNormal()  MemoryAnd32(UART1_CTL,~0x20)            // 13-bit Lin break
// Set UART0_Lin extreme break
#define RT_UART0_LinBreakExtreme() MemoryOr32(UART1_CTL,0x20)              // 26-bit Lin break
// Set UART0_Lin master send break
#define RT_UART0_LinSendBreak()    MemoryWrite32(UART1_LIN_BREAK,0x0)      // send Lin break
// Check UART0_Lin irq flag
#define RT_UART0_LinCheckIrq()     (MemoryRead32(UART1_CTL)&0x4)>>3        // check Lin irq
// Get Brp value
#define RT_UART0_GetBrp()          MemoryRead32(UART1_BRP)                 // get brp value
// Set UART0_Lin Slave Mode
#define RT_UART0_LinSlave()        UART0_LinSyncOn()                       // Lin slave mode
// Set UART0_Lin Master Mode
void RT_UART0_LinMaster(char pattern);                                     // Lin master mode
#endif
