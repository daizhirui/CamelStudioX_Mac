/*--------------------------------------------------------------------
 * TITLE: M2 Hardware Defines
 * AUTHOR: John & Jack 
 * DATE CREATED: 2013/10/10
 * FILENAME: WDT.h
 * PROJECT: M2Library
 * COPYRIGHT: Small World, Inc.
 * DESCRIPTION:
 *    M2 Hardware Defines
 *    
 *    2017-11-04: update function names, add into M2Library project
 *    2014-03-17: added sd adc, opo, v2p; sys reg modified
 *    2014-01-11: added sd adc, opo, v2p; sys reg modified
 *    2013-12-18: misc edit
 *    2013-12-15: uart reg back to m1
 *    2012-10-16: modified base on m2 new design
 *    2012-10-10: modified base on s0.h
 *--------------------------------------------------------------------*/
#ifndef __WDT_h__
#define __WDT_h__

#include "mcu.h"

/*********** Hardware addesses ***********/
// this is Watch dog timer
#define WDT_CTL0_REG    0x1f800b00  // WDT control
#define WDT_CLR_REG     0x1f800b03  // WDT clear reg
#define WDT_READ_REG    0x1f800b02  // WDT read reg

/*************** WDT Setup***************/
/**
 * @brief This function set the WDT app
 * 
 * @param n     the number of 1/8s   n=1~16
 * @param irq   trigger interrupt, ON or oFF
 * @param rst   whether reset the system, ON or OFF
 * @return      void
 */
#define RT_WatchDog_Setup(n, irq, rst)                                      \
    {                                                                    \
        MemoryWrite32(WDT_CTL0_REG, (n << 4 | irq << 2 | rst << 1 | 1)); \
        MemoryOr32(SYS_CTL0_REG, irq);                                   \
    }
// clear Watchdog
#define RT_WatchDog_Clear() MemoryWrite32(WDT_CLR_REG, 1)
// read watchdog value
#define RT_WatchDog_ReadValue() MemoryRead32(WDT_READ_REG)
/**************** WDT End****************/

#endif //__WDT_H__
