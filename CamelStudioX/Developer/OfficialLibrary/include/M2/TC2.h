/**
* @file TC2.h
* @author Zhirui Dai
* @date 16 Jun 2018
* @copyright 2018 Zhirui
* @brief Timer2 Library for M2
*/
#ifndef __TC2_h__
#define __TC2_h__

#include "mcu.h"

/***** Timer clr stop and flag Setup******/

/**
 * @brief       Stop TC2
 * @return      void
 */
#define RT_TC2_Stop() MemoryWrite32(T2_CTL0_REG, 0)

/**
 * @brief       Clear TC2 TC-IRQ and PWM-IRQ
 * @return      void
 */
#define RT_TC2_ClearIrq() MemoryWrite32(T2_CLRIRQ_REG, 0)

/**
 * @brief       Clear TC2 Counter value
 * @return      void
 */
#define RT_TC2_ClearCnt() MemoryWrite32(T2_CLRCNT_REG, 0)

/**
 * @brief       Clear TC2 TC-IRQ, PWM-IRQ and Counter value
 * @return      void
 */
#define RT_TC2_ClearAll()                   \
    {                                    \
        MemoryWrite32(T2_CLRIRQ_REG, 0); \
        MemoryWrite32(T2_CLRCNT_REG, 0); \
    }

/**
 * @brief       Turn on TC2 TC-IRQ
 * @return      void
 */
#define RT_TC2_TcIrqOn() MemoryOr32(T2_CTL0_REG, 1 << 7)

/**
 * @brief       Turn off TC2 TC-IRQ
 * @return      void
 */
#define RT_TC2_TcIrqOff() MemoryAnd32(T2_CTL0_REG, ~(1 << 7))

/**
 * @brief       Turn on TC2 PWM-IRQ
 * @return      void
 */
#define RT_TC2_PWM0IrqOn() MemoryOr32(T2_CTL0_REG, 1 << 6)

/**
 * @brief       Turn off TC2 PWM-IRQ
 * @return      void
 */
#define RT_TC2_PWM0IrqOff() MemoryAnd32(T2_CTL0_REG, ~(1 << 6))

/**
 * @brief       Read TC2 TC-flag
 * @return int  TC-flag
 */
#define RT_TC2_CheckTcFlag() ((MemoryRead32(T2_CTL0_REG) & 0x80000000) >> 31)

/**
 * @brief       Read TC2 PWM-flag
 * @return int  PWM-flag
 */
#define RT_TC2_CheckPWM0Flag() ((MemoryRead32(T2_CTL0_REG) & 0x40000000) >> 30)
/****************** end*******************/

/****************** Timer ******************/

/**
 * @brief       Turn on TC2 Timer
 * @return      void
 */
#define RT_TC2_TimerOn() MemoryOr32(T2_CTL0_REG, 1 << 1)

/**
 * @brief       Turn off TC2 Timer
 * @return      void
 */
#define RT_TC2_TimerOff() MemoryAnd32(T2_CTL0_REG, ~(1 << 1))

/**
 * @brief
 * This function sets the timer function of TC0
 * @param T         the target time to reach, the uint is us.
 * @param irqEn     when #ON, the interrupt is enabled; when #OFF, disabled
 * @return          void
 */
extern inline void RT_TC2_TimerSet1us(uint32_t T, switch_t irqEn)
{
    // [T2_CLK_REG] = 3 * T / [T2_REF_REG] - 1
    // Let [T2_REF_REG] = 255, get [T2_CLK_REG]
    uint32_t clk = T / 81 - 1;
    if (clk < 1) clk = 1;
    uint32_t ref = 30 * T / clk;
    if (ref % 10 >= 5) ref = ref / 10 + 1;  // ensure the interval is bigger than T
    else ref /= 10;
    MemoryAnd32(T2_CTL0_REG, ~(1 << 7));    // turn off irq
    MemoryWrite32(T2_CLK_REG, clk);
    MemoryWrite32(T2_REF_REG, ref);
    MemoryOr32(T2_CTL0_REG, (0x02 | (irqEn << 7)));
    MemoryOr32(SYS_CTL0_REG, irqEn);
}

/****************** Counter ******************/
/**
 * @brief
 * This function sets the frequency counter of TC2
 * The base frequency of the counter is 45Hz
 * @param n     times of 45Hz
 * @return      void
 */
#define RT_TC2_SetCounter(n)                    \
    {                                        \
        MemoryAnd32(T2_CTL0_REG, ~(1 << 7)); \
        MemoryWrite32(T2_CLK_REG, n);        \
        MemoryWrite32(T2_REF_REG, 0x0);      \
        MemoryOr32(T2_CTL0_REG, (0x02));     \
    }

/****************** ECNT *******************/

/**
 * @brief       Turn on TC2 Event Counter
 * @return      void
 */
#define RT_TC2_EcntOn() MemoryOr32(T2_CTL0_REG, 1)

/**
 * @brief       Turn off TC2 Event Counter
 * @return      void
 */
#define RT_TC2_EcntOff() MemoryAnd32(T2_CTL0_REG, ~1)

/**
 * @brief
 * This function sets the ECNT function of TC2
 * @param n         the target value to reach
 * @param trigger   the trigger mode, RISING or FALLING
 * @param irq       when ON, the interrupt is enabled; when OFF, disabled
 * @return          void
 */
#define RT_TC2_SetEcnt(n, trigger, irq)                                  \
    {                                                                 \
        MemoryAnd32(T2_CTL0_REG, ~((0x1 << 7) + (0x1 << 2)));         \
        MemoryOr32(T2_CTL0_REG, ((trigger << 2) | (irq << 7) | 0x1)); \
        MemoryWrite32(T2_REF_REG, n);                                 \
        MemoryOr32(SYS_CTL0_REG, irq);                                \
    }
/*********** Timer2 ECM End***************/

/****************** PWM *******************/

/**
 * @brief       Turn on TC2 PWM0
 * @return      void
 */
#define RT_TC2_PWM0On() MemoryOr32(T2_CTL0_REG, 1 << 4)

/**
 * @brief       Turn off TC2 PWM0
 * @return      void
 */
#define RT_TC2_PWM0Off() MemoryAnd32(T2_CTL0_REG, ~(1 << 4))

/**
 * @brief       Turn on TC2 PWM1-3
 * @return      void
 */
#define RT_TC2_PWM1to3On() MemoryOr32(T2_CTL0_REG, 1 << 5)

/**
 * @brief       Turn off TC2 PWM1-3
 * @return      void
 */
#define RT_TC2_PWM1to3Off() MemoryAnd32(T2_CTL0_REG, ~(1 << 5))

/**
 * @brief
 * This function sets the PWM function of TC2
 * @param div       the clock freq divider
 * @param duty0     2-255, the duty of pwm0
 * @param duty1     2-255, the duty of pwm1
 * @param duty2     2-255, the duty of pwm2
 * @param duty3     2-255, the duty of pwm3
 * @param phase0    0-255, pwm0's relative phase among 4 pwm
 * @param phase1    0-255, pwm1's relative phase among 4 pwm
 * @param phase2    0-255, pwm2's relative phase among 4 pwm
 * @param phase3    0-255, pwm3's relative phase among 4 pwm
 * @param pwm0      the switch of pwm0, ON or OFF
 * @param pwm13     the switch of pwm13, ON or OFF
 * @return          void
 */
#define RT_TC2_SetAllPWM(div, duty0, duty1, duty2, duty3, phase0, phase1, phase2, phase3, pwm0, pwm13) \
    {                                                                                               \
        MemoryAnd32(T2_CTL0_REG, ~(0x3 << 4));                                                      \
        MemoryOr32(T2_CTL0_REG, ((pwm0 << 4) | (pwm13 << 5)));                                      \
        MemoryWrite32(T2_CLK_REG, div);                                                             \
        MemoryWrite32(T2_REF_REG, (duty0 + (duty1 << 8) + (duty2 << 16) + (duty3 << 24)));          \
        MemoryWrite32(T2_PHASE_REG, (phase0 + (phase1 << 8) + (phase2 << 16) + (phase3 << 24)));    \
    }
/*********** Timer2 PWM End***************/

/*********** Timer2 PWMM Setup*************/

/**
 * @brief       Turn on TC2 Pulse Width Measurement
 * @return      void
 */
#define RT_TC2_PWMMOn() MemoryOr32(T2_CTL0_REG, 1 << 3)

/**
 * @brief       Turn off TC2 Pulse Width Measurement
 * @return      void
 */
#define RT_TC2_PWMMOff() MemoryAnd32(T2_CTL0_REG, ~(1 << 3))

/**
 * @brief       Set TC2 Trigger Mode of Pulse Width Measurement
 * @param mode  Trigger mode, optional values: #RISING_TRIGGER, #FALLING_TRIGGER
 * @return      void
 */
#define RT_TC2_PWMMTriggerMode(mode)            \
    {                                        \
        MemoryAnd32(T2_CTL0_REG, ~(1 << 2)); \
        MemoryOr32(T2_CTL0_REG, mode << 2);  \
    }
/**
 * @brief
 * This function sets the Pulse width measure for TC2
 * @param trigger   the trigger mode, RISING or FALLING
 * @param irq       when ON, the interrupt is enabled; when OFF, disabled
 * @return          void
 */
#define RT_TC2_SetPWMM(trigger, irq)                                   \
    {                                                               \
        MemoryAnd32(T2_CTL0_REG, ~((0x1 << 7) + (0x1 << 2)));       \
        MemoryOr32(T2_CTL0_REG, (0x18 | (irq << 7) | (rise << 2))); \
        MemoryOr32(SYS_CTL0_REG, irq);                              \
    }
/*************** Timer2 Read ***************/

/**
 * @brief       Read TC2 Counter Register Value
 * @return int  TC0 Counter Register Value
 */
#define RT_TC2_ReadCnt() MemoryRead32(T2_READ_REG)

#endif
