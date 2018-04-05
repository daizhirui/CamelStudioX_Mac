/*--------------------------------------------------------------------
 * TITLE: M2 Hardware Definition
 * AUTHOR: Astro
 * DATE CREATED: 2017/11/3
 * FILENAME: TC4.h
 * PROJECT: M2Library
 * COPYRIGHT: Camel Microelectronics, Ltd.
 * DESCRIPTION:
 *--------------------------------------------------------------------*/
#ifndef __TC4_h__
#define __TC4_h__

#include "mcu.h"

/*********** Hardware addesses ***********/

// this is PWM/Bz unit, has two PWMs
#define T4_CTL0_REG 0x1f800a00 // Timer8-4 (2-bit) enable control
#define T4_REF0_REG 0x1f800a01 // Timer8-4 ref number for PWM0 buz(8-bit)
#define T4_CLK0_REG 0x1f800a02 // Timer8-4 clk div for PWM0 (8-bit)
#define T4_REF1_REG 0x1f800a03 // Timer8-4 ref number for PWM1 fast(4-bit)
#define T4_CLK1_REG 0x1f800a04 // Timer8-4 clk div for PWM1 (8-bit)

/***** Timer clr stop and flag Setup******/
#define RT_TC4_AllPWM_On() MemoryWrite32(T4_CTL0_REG, 3)
#define RT_TC4_AllPWM_Off() MemoryWrite32(T4_CTL0_REG, 0)
#define RT_TC4_PWM_On(n) MemoryOr32(T4_CLK0_REG, 1 << n)
#define RT_TC4_PWM_Off(n) MemoryAnd32(T4_CTL0_REG, ~(1 << n))
/****************** end*******************/

/*********** Timer4 PWM Setup*************/
/**
 * @brief 
 * This function sets all the PWM function of TC4
 * @param pwm0_en   the switch of TC4-pwm0, ON or OFF
 * @param div0      the clock freq divider of TC4-pwm0
 * @param ref0      15-0, the duty of TC4-pwm0
 * @param pwm1_en   the switch of TC4-pwm1, On or OFF
 * @param div1      the clock freq divider of TC4-pwm1
 * @param ref1      15-0, the duty of TC4-pwm1
 * @return          void
 */
#define RT_TC4_SetAllPWM(pwm0_en, div0, ref0, pwm1_en, div1, ref1) \
    {                                                           \
        MemoryWrite32(T4_CLK0_REG, div0);                       \
        MemoryWrite32(T4_REF0_REG, ref0);                       \
        MemoryWrite32(T4_CLK1_REG, div1);                       \
        MemoryWrite32(T4_REF1_REG, ref1);                       \
        MemoryAnd32(T4_CTL0_REG, ~(0x3));                       \
        MemoryOr32(T4_CTL0_REG, (pwm0_en | pwm1_en << 1));      \
    }
/**
 * @brief 
 * This function sets single pwm of TC4
 * @param n         the number of pwm, 0 or 1
 * @param pwm_en    the switch of the pwm, ON or OFF
 * @param div       the clock freq divider of pwm
 * @param ref       the duty of pwm
 * @return          void
 */
#define RT_TC4_SetPWM(n, pwm_en, div, ref)          \
    {                                            \
        MemoryWrite32(T4_CLK0_REG + 2 * n, div); \
        MemoryWrite32(T4_REF0_REG + 2 * n, ref); \
        MemoryAnd32(T4_CTL0_REG, ~(1 << n));     \
        MemoryOr32(T4_CTL0_REG, pwm_en << n);    \
    }
/*********** Timer4 PWM End***************/

#endif