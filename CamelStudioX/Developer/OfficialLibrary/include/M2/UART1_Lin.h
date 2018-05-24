/*--------------------------------------------------------------------
 * TITLE: M2 Hardware Definition
 * AUTHOR: Astro
 * DATE CREATED: 2017/11/1
 * FILENAME: UART1_Lin.h
 * PROJECT: M2Library
 * COPYRIGHT: Camel Microelectronics, Ltd.
 * DESCRIPTION:
 *--------------------------------------------------------------------*/
#ifndef __UART1_Lin_h__
#define __UART1_Lin_h__

#include "mcu.h"
#include "UART1.h"
/************** Value define *************/
#define NormalBreak     0x0
#define ExtremeBreak    0x1
/*************** UART1 Setup***************/
// set UART1_Lin on
#define RT_UART1_LinSyncOn()       MemoryOr32(UART1_CTL,0x8)               // auto Linsync on
// set UART1_Lin off
#define RT_UART1_LinSyncOff()      MemoryAnd32(UART1_CTL,~0x8)             // auto Linsync off
// set UART1_Lin normal break
#define RT_UART1_LinBreakNormal()  MemoryAnd32(UART1_CTL,~0x20)            // 13-bit Lin break
// set UART1_Lin extreme break
#define RT_UART1_LinBreakExtreme() MemoryOr32(UART1_CTL,0x20)              // 26-bit Lin break
// set UART1_Lin master send break
#define RT_UART1_LinSendBreak()    MemoryWrite32(UART1_LIN_BREAK,0x0)      // send Lin break
// check UART1_Lin irq flag
#define RT_UART1_LinCheckIrq()     (MemoryRead32(UART1_CTL)&0x4)>>3        // check Lin irq
// get brp value
#define RT_UART1_GetBrp()          MemoryRead32(UART1_BRP)                 // get brp value
// Set UART1_Lin slave mode
#define RT_UART1_LinSlave()        UART1_LinSyncOn()                       // Lin slave mode
// Set UART1_Lin master mode
void RT_UART1_LinMaster(char pattern);                                     // Lin master mode
#endif
