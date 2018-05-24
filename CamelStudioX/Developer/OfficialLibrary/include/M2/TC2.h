/*--------------------------------------------------------------------
 * TITLE: M2 Hardware Definition
 * AUTHOR: Astro
 * DATE CREATED: 2017/11/2
 * FILENAME: TC2.h
 * PROJECT: M2Library
 * COPYRIGHT: Camel Microelectronics, Ltd.
 * DESCRIPTION:
 *--------------------------------------------------------------------*/
#ifndef __TC2_h__
#define __TC2_h__

#include "mcu.h"
/*********** Hardware addesses ***********/
#define T2_CTL0_REG 0x1f800400   // Timer2 (32-bit)control and base
#define T2_REF_REG 0x1f800401    // Timer2 ref number for PWM(4, 32bit)
#define T2_READ_REG 0x1f800402   // Timer2 value
#define T2_CLRIRQ_REG 0x1f800403 // Timer2 clear IRQ
#define T2_CLK_REG 0x1f800404    // Timer2 clk div
#define T2_CLRCNT_REG 0x1f800405 // Timer2 clear counter content (and PWM)
#define T2_PHASE_REG 0x1f800406  // Timer2 PWM phase reg (32b, 4 pwm)

/***** Timer clr stop and flag Setup******/
#define RT_TC2_Stop() MemoryWrite32(T2_CTL0_REG, 0)
#define RT_TC2_ClearIrq() MemoryWrite32(T2_CLRIRQ_REG, 0)
#define RT_TC2_ClearCnt() MemoryWrite32(T2_CLRCNT_REG, 0)
#define RT_TC2_ClearAll()                   \
    {                                    \
        MemoryWrite32(T2_CLRIRQ_REG, 0); \
        MemoryWrite32(T2_CLRCNT_REG, 0); \
    }
#define RT_TC2_TcIrqOn() MemoryOr32(T2_CTL0_REG, 1 << 7)
#define RT_TC2_TcIrqOff() MemoryAnd32(T2_CTL0_REG, ~(1 << 7))
#define RT_TC2_PWM0IrqOn() MemoryOr32(T2_CTL0_REG, 1 << 6)
#define RT_TC2_PWM0IrqOff() MemoryAnd32(T2_CTL0_REG, ~(1 << 6))
#define RT_TC2_CheckTcFlag() ((MemoryRead32(T2_CTL0_REG) & 0x80000000) >> 31)
#define RT_TC2_CheckPWM0Flag() ((MemoryRead32(T2_CTL0_REG) & 0x40000000) >> 30)
/****************** end*******************/

/****************** Timer ******************/
#define RT_TC2_TimerOn() MemoryOr32(T2_CTL0_REG, 1 << 1)
#define RT_TC2_TimerOff() MemoryAnd32(T2_CTL0_REG, ~(1 << 1))
/**
 * @brief 
 * This function sets the timer function of TC2
 * @param T         the target time to reach
 * @param irq       when ON, the interrupt is enabled; when OFF, disabled
 * @return          void
 */
#define RT_TC2_TimerSet1us(T, irq)                        \
    {                                                  \
        MemoryAnd32(T2_CTL0_REG, ~(1 << 7));           \
        MemoryWrite32(T2_CLK_REG, T / 81);             \
        MemoryWrite32(T2_REF_REG, 243 * T / (T + 81)); \
        MemoryOr32(T2_CTL0_REG, (0x02 | (irq << 7)));  \
        MemoryOr32(SYS_CTL0_REG, irq);                 \
    }

/****************** Counter ******************/
//??????????????????????????????????????????????
// What is counter? frequency counter? --Astro, 2017/11/3
//??????????????????????????????????????????????
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
#define RT_TC2_EcntOn() MemoryOr32(T2_CTL0_REG, 1)
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
#define RT_TC2_PWM0On() MemoryOr32(T2_CTL0_REG, 1 << 4)
#define RT_TC2_PWM0Off() MemoryAnd32(T2_CTL0_REG, ~(1 << 4))
#define RT_TC2_PWM1to3On() MemoryOr32(T2_CTL0_REG, 1 << 5)
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
#define RT_TC2_PWMMOn() MemoryOr32(T2_CTL0_REG, 1 << 3)
#define RT_TC2_PWMMOff() MemoryAnd32(T2_CTL0_REG, ~(1 << 3))
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
#define RT_TC2_ReadCnt() MemoryRead32(T2_READ_REG)

#endif