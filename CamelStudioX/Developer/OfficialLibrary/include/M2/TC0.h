/*--------------------------------------------------------------------
 * TITLE: M2 Hardware Definition
 * AUTHOR: Astro
 * DATE CREATED: 2017/11/2
 * FILENAME: TC0.h
 * PROJECT: M2Library
 * COPYRIGHT: Camel Microelectronics, Ltd.
 * DESCRIPTION:
 *--------------------------------------------------------------------*/
#ifndef __TC0_h__
#define __TC0_h__

#include "mcu.h"

#define T0_CTL0_REG 0x1f800100   // T0 (32-bit)control and base
#define T0_REF_REG 0x1f800101    // T0 ref number for PWM(1)
#define T0_READ_REG 0x1f800102   // T0 value
#define T0_CLRIRQ_REG 0x1f800103 // T0 clear IRQ
#define T0_CLK_REG 0x1f800104    // T0 clk div
#define T0_CLRCNT_REG 0x1f800105 // T0 clear counter content (and PWM)

/***** Timer clr stop and flag Setup******/
#define RT_TC0_Stop() MemoryWrite32(T0_CTL0_REG, 0)
#define RT_TC0_ClearIrq() MemoryWrite32(T0_CLRIRQ_REG, 0)
#define RT_TC0_ClearCnt() MemoryWrite32(T0_CLRCNT_REG, 0)
#define RT_TC0_ClearAll()  \
    {                   \
        RT_TC0_ClearIrq(); \
        RT_TC0_ClearCnt(); \
    }
#define RT_TC0_TcIrqOn() MemoryOr32(T0_CTL0_REG, 1 << 7)
#define RT_TC0_TcIrqOff() MemoryAnd32(T0_CTL0_REG, ~(1 << 7))
#define RT_TC0_PWMIrqOn() MemoryOr32(T0_CTL0_REG, 1 << 6)
#define RT_TC0_PWMIrqOff() MemoryAnd32(T0_CTL0_REG, ~(1 << 6))
#define RT_TC0_CheckTcFlag() ((MemoryRead32(T0_CTL0_REG) & 0x80000000) >> 31)
#define RT_TC0_CheckPWMFlag() ((MemoryRead32(T0_CTL0_REG) & 0x40000000) >> 30)
/****************** end*******************/

/****************** Timer ******************/
#define TC0_TimerOn() MemoryOr32(T0_CTL0_REG, 1 << 1)
#define TC0_TimerOff() MemoryAnd32(T0_CTL0_REG, ~(1 << 1))
/**
 * @brief 
 * This function sets the timer function of TC0
 * @param T         the target time to reach
 * @param irq       when ON, the interrupt is enabled; when OFF, disabled
 * @return          void
 */
#define RT_TC0_TimerSet1us(T, irq)                        \
    {                                                  \
        MemoryAnd32(T0_CTL0_REG, ~(1 << 7));           \
        MemoryWrite32(T0_CLK_REG, T / 81);             \
        MemoryWrite32(T0_REF_REG, 243 * T / (T + 81)); \
        MemoryOr32(T0_CTL0_REG, (0x02 | (irq << 7)));  \
        MemoryOr32(SYS_CTL0_REG, irq);                 \
    }
/****************** Counter ******************/
//??????????????????????????????????????????????
// What is counter? frequency counter? --Astro, 2017/11/3
//??????????????????????????????????????????????
/**
 * @brief 
 * This function sets the frequency counter of TC0
 * The base frequency of the counter is 45Hz
 * @param n     times of 45Hz
 * @return      void
 */
#define RT_TC0_SetCounter(n)                    \
    {                                        \
        MemoryAnd32(T0_CTL0_REG, ~(1 << 7)); \
        MemoryWrite32(T0_CLK_REG, n);        \
        MemoryWrite32(T0_REF_REG, 0x0);      \
        MemoryOr32(T0_CTL0_REG, (0x02));     \
    }

/****************** ECNT *******************/
#define RT_TC0_EcntOn() MemoryOr32(T0_CTL0_REG, 1)
#define RT_TC0_EcntOff() MemoryAnd32(T0_CTL0_REG, ~1)
/**
 * @brief 
 * This function sets the ECNT function of TC0
 * @param n         the target value to reach
 * @param trigger   the trigger mode, RISING or FALLING
 * @param irq       when ON, the interrupt is enabled; when OFF, disabled
 * @return          void
 */
#define RT_TC0_SetEcnt(n, trigger, irq)                                  \
    {                                                                 \
        MemoryAnd32(T0_CTL0_REG, ~((0x1 << 7) + (0x1 << 2)));         \
        MemoryOr32(T0_CTL0_REG, ((trigger << 2) | (irq << 7) | 0x1)); \
        MemoryWrite32(T0_REF_REG, n);                                 \
        MemoryOr32(SYS_CTL0_REG, irq);                                \
    }
/****************** PWM *******************/
#define RT_TC0_PWMOn() MemoryOr32(T0_CTL0_REG, 1 << 4)
#define RT_TC0_PWMOff() MemoryAnd32(T0_CTL0_REG, ~(1 << 4))
/**
 * @brief 
 * This function sets the PWM function of TC0
 * @param div       the clock freq divider
 * @param ref       0-255, the clock high length
 * @param irq       when ON, the interrupt is enabled; when OFF, disabled
 * @return          void 
 */
#define RT_TC0_SetPWM(div, ref, irq)                                  \
    {                                                              \
        MemoryAnd32(T0_CTL0_REG, ~(0x3 << 6));                     \
        MemoryWrite32(T0_CLK_REG, div);                            \
        MemoryWrite32(T0_REF_REG, ref);                            \
        MemoryOr32(T0_CTL0_REG, (0x10 | (irq << 6) | (irq << 7))); \
    }

/****************** PWMM ******************/
#define RT_TC0_PWMMOn() MemoryOr32(T0_CTL0_REG, 1 << 3)
#define RT_TC0_PWMMOff() MemoryAnd32(T0_CTL0_REG, ~(1 << 3))
#define RT_TC0_PWMMTriggerMode(mode)            \
    {                                        \
        MemoryAnd32(T0_CTL0_REG, ~(1 << 2)); \
        MemoryOr32(T0_CTL0_REG, mode << 2);  \
    }
/**
 * @brief 
 * This function sets the Pulse width measure for TC0
 * @param trigger   the trigger mode, RISING or FALLING
 * @param irq       when ON, the interrupt is enabled; when OFF, disabled
 * @return          void 
 */
#define RT_TC0_SetPWMM(trigger, irq)                                   \
    {                                                               \
        MemoryAnd32(T0_CTL0_REG, ~((0x1 << 7) + (0x1 << 2)));       \
        MemoryOr32(T0_CTL0_REG, (0x18 | (irq << 7) | (rise << 2))); \
        MemoryOr32(SYS_CTL0_REG, irq);                              \
    }
/*************** Timer0 Read ***************/
#define RT_TC0_ReadCnt() MemoryRead32(T0_READ_REG)

#endif