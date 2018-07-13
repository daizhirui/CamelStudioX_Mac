/**
 * @file TC1.h
 * @author Zhirui Dai
 * @date 16 Jun 2018
 * @copyright 2018 Zhirui
 * @brief Timer1 Library for M2
 */
#ifndef __TC1_h__
#define __TC1_h__

#include "mcu.h"

/***** Timer clr stop and flag Setup******/

/**
 * @brief       Stop TC1
 * @return      void
 */
#define RT_TC1_Stop() MemoryWrite32(T1_CTL0_REG, 0)

/**
 * @brief       Clear TC1 TC-IRQ and PWM-IRQ
 * @return      void
 */
#define RT_TC1_ClearIrq() MemoryWrite32(T1_CLRIRQ_REG, 0)

/**
 * @brief       Clear TC1 Counter value
 * @return      void
 */
#define RT_TC1_ClearCnt() MemoryWrite32(T1_CLRCNT_REG, 0)

/**
 * @brief       Clear TC1 TC-IRQ, PWM-IRQ and Counter value
 * @return      void
 */
#define RT_TC1_ClearAll()  \
    {                   \
        RT_TC1_ClearIrq(); \
        RT_TC1_ClearCnt(); \
    }

/**
 * @brief       Turn on TC1 TC-IRQ
 * @return      void
 */
#define RT_TC1_TcIrqOn() MemoryOr32(T1_CTL0_REG, 1 << 7)

/**
 * @brief       Turn off TC1 TC-IRQ
 * @return      void
 */
#define RT_TC1_TcIrqOff() MemoryAnd32(T1_CTL0_REG, ~(1 << 7))

/**
 * @brief       Turn on TC1 PWM-IRQ
 * @return      void
 */
#define RT_TC1_PWMIrqOn() MemoryOr32(T1_CTL0_REG, 1 << 6)

/**
 * @brief       Turn off TC1 PWM-IRQ
 * @return      void
 */
#define RT_TC1_PWMIrqOff() MemoryAnd32(T1_CTL0_REG, ~(1 << 6))

/**
 * @brief       Read TC1 TC-flag
 * @return int  TC-flag
 */
#define RT_TC1_CheckTcFlag() ((MemoryRead32(T1_CTL0_REG) & 0x80000000) >> 31)

/**
 * @brief       Read TC1 PWM-flag
 * @return int  PWM-flag
 */
#define RT_TC1_CheckPWMFlag() ((MemoryRead32(T1_CTL0_REG) & 0x40000000) >> 30)
/****************** end*******************/
/****************** Timer ******************/

/**
 * @brief       Turn on TC1 Timer
 * @return      void
 */
#define RT_TC1_TimerOn() MemoryOr32(T1_CTL0_REG, 1 << 1)

/**
 * @brief       Turn off TC1 Timer
 * @return      void
 */
#define RT_TC1_TimerOff() MemoryAnd32(T1_CTL0_REG, ~(1 << 1))

/**
 * @brief
 * This function sets the timer function of TC0
 * @param T         the target time to reach, the uint is us.
 * @param irqEn     when #ON, the interrupt is enabled; when #OFF, disabled
 * @return          void
 */
inline void RT_TC1_TimerSet1us(uint32_t T, switch_t irqEn)
{
    // [T1_CLK_REG] = 3 * T / [T1_REF_REG] - 1
    // Let [T1_REF_REG] = 255, get [T1_CLK_REG]
    uint32_t clk = T / 81 - 1;
    if (clk < 1) clk = 1;
    uint32_t ref = 30 * T / clk;
    if (ref % 10 >= 5) ref = ref / 10 + 1;  // ensure the interval is bigger than T
    else ref /= 10;
    MemoryAnd32(T1_CTL0_REG, ~(1 << 7));    // turn off irq
    MemoryWrite32(T1_CLK_REG, clk);
    MemoryWrite32(T1_REF_REG, ref);
    MemoryOr32(T1_CTL0_REG, (0x02 | (irqEn << 7)));
    MemoryOr32(SYS_CTL0_REG, irqEn);
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

/**
 * @brief       Turn on TC1 Event Counter
 * @return      void
 */
#define RT_TC1_EcntOn() MemoryOr32(T1_CTL0_REG, 1)

/**
 * @brief       Turn off TC1 Event Counter
 * @return      void
 */
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

/**
 * @brief       Turn on TC1 PWM
 * @return      void
 */
#define RT_TC1_PWMOn() MemoryOr32(T1_CTL0_REG, 1 << 4)

/**
 * @brief       Turn off TC1 PWM
 * @return      void
 */
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

/**
 * @brief       Turn on TC1 Pulse Width Measurement
 * @return      void
 */
#define RT_TC1_PWMMOn() MemoryOr32(T1_CTL0_REG, 1 << 3)

/**
 * @brief       Turn off TC1 Pulse Width Measurement
 * @return      void
 */
#define RT_TC1_PWMMOff() MemoryAnd32(T1_CTL0_REG, ~(1 << 3))

/**
 * @brief       Set TC1 Trigger Mode of Pulse Width Measurement
 * @param mode  Trigger mode, optional values: #RISING_TRIGGER, #FALLING_TRIGGER
 * @return      void
 */
inline void RT_TC1_PWMMTriggerMode(trigger_mode_t mode)
{
    MemoryAnd32(T1_CTL0_REG, ~(1 << 2));
    MemoryOr32(T1_CTL0_REG, mode << 2);
}
/**
 * @brief
 * This function sets the Pulse width measure for TC1
 * @param trigger   the trigger mode, #RISING_TRIGGER, #FALLING_TRIGGER
 * @param irq       when ON, the interrupt is enabled; when OFF, disabled
 * @return          void
 */
inline void RT_TC1_SetPWMM(trigger_mode_t mode, switch_t irq)
{
    MemoryAnd32(T1_CTL0_REG, ~((0x1 << 7) + (0x1 << 2)));
    MemoryOr32(T1_CTL0_REG, (0x18 | (irq << 7) | (mode << 2)));
    MemoryOr32(SYS_CTL0_REG, irq);
}
/*************** Timer0 Read ***************/

/**
 * @brief       Read TC1 Counter Register Value
 * @return int  TC0 Counter Register Value
 */
#define RT_TC1_ReadCnt() MemoryRead32(T1_READ_REG)

#endif
