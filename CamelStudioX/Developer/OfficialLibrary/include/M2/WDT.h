/**
* @file WDT.h
* @author John & Jack, Zhirui Dai
* @date 16 Jun 2018
* @copyright 2018 Zhirui
* @brief Watchdog Library for M2.
*/
#ifndef __M2_WDT_h__
#define __M2_WDT_h__

#include "mcu.h"

/**
 * @brief       This function set the WDT app
 * @param n     the number of 1/8s   n=1~16
 * @param irq   trigger interrupt, ON or oFF
 * @param rst   whether reset the system, ON or OFF
 * @return      void
 */
#define RT_WatchDog_Setup(n, irq, rst)                                   \
    {                                                                    \
        MemoryWrite32(WDT_CTL0_REG, (n << 4 | irq << 2 | rst << 1 | 1)); \
        MemoryOr32(SYS_CTL0_REG, irq);                                   \
    }

/**
* @brief  Clear Watchdog.
* @return void
*/
#define RT_WatchDog_Clear() MemoryWrite32(WDT_CLR_REG, 1)

/**
* @brief            Read watchdog value.
* @return uint4_t   The number of 1/8s.
*/
#define RT_WatchDog_ReadValue() MemoryRead32(WDT_READ_REG)
/**************** WDT End****************/

#endif //__M2_WDT_H__
