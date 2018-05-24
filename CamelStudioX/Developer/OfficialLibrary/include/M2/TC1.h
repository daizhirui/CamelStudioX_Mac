/*--------------------------------------------------------------------
 * TITLE: M2 Hardware Definition
 * AUTHOR: Astro
 * DATE CREATED: 2017/11/2
 * FILENAME: TC1.h
 * PROJECT: M2Library
 * COPYRIGHT: Camel Microelectronics, Ltd.
 * DESCRIPTION:
 *--------------------------------------------------------------------*/
#ifndef __TC1_h__
#define __TC1_h__

#include "mcu.h"

#define T1_CTL0_REG       0x1f800200  // Timer1 (32-bit)control and base
#define T1_REF_REG        0x1f800201  // Timer1 ref number for PWM(1)
#define T1_READ_REG       0x1f800202  // Timer1 value
#define T1_CLRIRQ_REG     0x1f800203  // Timer1 clear IRQ
#define T1_CLK_REG        0x1f800204  // Timer1 clk div
#define T1_CLRCNT_REG     0x1f800205  // Timer1 clear counter content (and PWM)

/***** Timer clr stop and flag Setup******/
#define RT_TC1_Stop() MemoryWrite32(T1_CTL0_REG, 0)
#define RT_TC1_ClearIrq() MemoryWrite32(T1_CLRIRQ_REG, 0)
#define RT_TC1_ClearCnt() MemoryWrite32(T1_CLRCNT_REG, 0)
#define RT_TC1_ClearAll()  \
    {                   \
        RT_TC1_ClearIrq(); \
        RT_TC1_ClearCnt(); \
    }
#define RT_TC1_TcIrqOn() MemoryOr32(T1_CTL0_REG, 1 << 7)
#define RT_TC1_TcIrqOff() MemoryAnd32(T1_CTL0_REG, ~(1 << 7))
#define RT_TC1_PWMIrqOn() MemoryOr32(T1_CTL0_REG, 1 << 6)
#define RT_TC1_PWMIrqOff() MemoryAnd32(T1_CTL0_REG, ~(1 << 6))
#define RT_TC1_CheckTcFlag() ((MemoryRead32(T1_CTL0_REG) & 0x80000000) >> 31)
#define RT_TC1_CheckPWMFlag() ((MemoryRead32(T1_CTL0_REG) & 0x40000000) >> 30)
/****************** end*******************/
/****************** Timer ******************/
#define RT_TC1_TimerOn() MemoryOr32(T1_CTL0_REG, 1 << 1)
#define RT_TC1_TimerOff() MemoryAnd32(T1_CTL0_REG, ~(1 << 1))
/**
 * @brief 
 * This function sets the timer function of TC1
 * @param T         the target time to reach
 * @param irq       when ON, the interrupt is enabled; when OFF, disabled
 * @return          void
 */
#define RT_TC1_TimerSet1us(T, irq)                        \
    {                                                  \
        MemoryAnd32(T1_CTL0_REG, ~(1 << 7));           \
        MemoryWrite32(T1_CLK_REG, T / 81);             \
        MemoryWrite32(T1_REF_REG, 243 * T / (T + 81)); \
        MemoryOr32(T1_CTL0_REG, (0x02 | (irq << 7)));  \
        MemoryOr32(SYS_CTL0_REG, irq);                 \
    }
/**
 * @brief 
 * This function sets the frequency counter of TC1
 * The base frequency of the counter is 45Hz
 * @param n     times of 45Hz
 * @return      void
 */
#define RT_TC1_SetCounter(n)                    \
    {                                        \
        MemoryAnd32(T1_CTL0_REG, ~(1 << 7)); \
        MemoryWrite32(T1_CLK_REG, n);        \
        MemoryWrite32(T1_REF_REG, 0x0);      \
        MemoryOr32(T1_CTL0_REG, (0x02));     \
    }

/****************** ECNT *******************/
#define RT_TC1_EcntOn() MemoryOr32(T1_CTL0_REG, 1)
#define RT_TC1_EcntOff() MemoryAnd32(T1_CTL0_REG, ~1)
/**
 * @brief 
 * This function sets the ECNT function of TC1
 * @param n         the target value to reach
 * @param trigger   the trigger mode, RISING or FALLING
 * @param irq       when ON, the interrupt is enabled; when OFF, disabled
 * @return          void
 */
#define RT_TC1_SetEcnt(n, trigger, irq)                                  \
    {                                                                 \
        MemoryAnd32(T1_CTL0_REG, ~((0x1 << 7) + (0x1 << 2)));         \
        MemoryOr32(T1_CTL0_REG, ((trigger << 2) | (irq << 7) | 0x1)); \
        MemoryWrite32(T1_REF_REG, n);                                 \
        MemoryOr32(SYS_CTL0_REG, irq);                                \
    }
/****************** PWM *******************/
#define RT_TC1_PWMOn() MemoryOr32(T1_CTL0_REG, 1 << 4)
#define RT_TC1_PWMOff() MemoryAnd32(T1_CTL0_REG, ~(1 << 4))
/**
 * @brief 
 * This function sets the PWM function of TC1
 * @param div       the clock freq divider
 * @param ref       0-255, the clock high length
 * @param irq       when ON, the interrupt is enabled; when OFF, disabled
 * @return          void 
 */
#define RT_TC1_SetPWM(div, ref, irq)                                  \
    {                                                              \
        MemoryAnd32(T1_CTL0_REG, ~(0x3 << 6));                     \
        MemoryWrite32(T1_CLK_REG, div);                            \
        MemoryWrite32(T1_REF_REG, ref);                            \
        MemoryOr32(T1_CTL0_REG, (0x10 | (irq << 6) | (irq << 7))); \
    }

/****************** PWMM ******************/
#define RT_TC1_PWMMOn() MemoryOr32(T1_CTL0_REG, 1 << 3)
#define RT_TC1_PWMMOff() MemoryAnd32(T1_CTL0_REG, ~(1 << 3))
#define RT_TC1_PWMMTriggerMode(mode)            \
    {                                        \
        MemoryAnd32(T1_CTL0_REG, ~(1 << 2)); \
        MemoryOr32(T1_CTL0_REG, mode << 2);  \
    }
/**
 * @brief 
 * This function sets the Pulse width measure for TC1
 * @param trigger   the trigger mode, RISING or FALLING
 * @param irq       when ON, the interrupt is enabled; when OFF, disabled
 * @return          void 
 */
#define RT_TC1_SetPWMM(trigger, irq)                                   \
    {                                                               \
        MemoryAnd32(T1_CTL0_REG, ~((0x1 << 7) + (0x1 << 2)));       \
        MemoryOr32(T1_CTL0_REG, (0x18 | (irq << 7) | (rise << 2))); \
        MemoryOr32(SYS_CTL0_REG, irq);                              \
    }
/*************** Timer0 Read ***************/
#define RT_TC1_ReadCnt() MemoryRead32(T1_READ_REG)

#endif