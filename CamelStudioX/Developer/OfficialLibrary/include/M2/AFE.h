/*--------------------------------------------------------------------
 * TITLE: M2 Hardware Definition
 * AUTHOR: Astro
 * DATE CREATED: 2017/11/2
 * FILENAME: AFE.h
 * PROJECT: M2Library
 * COPYRIGHT: Camel Microelectronics, Ltd.
 * DESCRIPTION:
 * 		Analog Module Library
 * 		2017/11/3	updated from V2017.07.15
 *--------------------------------------------------------------------*/
#ifndef __AFE_h__
#define __AFE_h__

#include "mcu.h"
/********* AD Register Address *********/
#define AD_CTL0_REG 0x1f800600 // SD and V2P control (16-bit)
#define AD_OPO_REG 0x1f800601  // OPO and Chan control (16-bit)
#define AD_READ_REG 0x1f800602 // SD df read (16-bit)
#define AD_CLR_REG 0x1f800603  // SD ADC clear reg
/*********** Value Definition ************/
// This part aims to make coding easier.
// A starting level learner just needs to use following key words.
//>> OPO P-Side and N-Side Key Words
#define OPO_PSIDE 0x0
#define OPO_NSIDE 0x1
//>> OPO PVGND Key Words
#define VCOM 0x1
#define GND 0x0
//>> OPO Single Side Mode Key Words
#define P_A0P 0x1
#define P_A1P 0x2
#define P_A2P 0x4
#define P_A3P 0x8
#define N_A0P 0x1
#define N_A1P 0x2
#define N_A2P 0x4
#define N_A3P 0x8
//>> SD Clock Div Key Words
#define SD_CLK_3M 0x0
#define SD_CLK_1_5M 0x1
#define SD_CLK_781K 0x2
#define SD_CLK_390K 0x3
//>> SD AD Filter CLK Key Words
#define SD_FCLK_1K 0x0
#define SD_FCLK_512 0x1
#define SD_FCLK_256 0x2
#define SD_FCLK_128 0x3
//>> SD AD Length Key Words
#define SD_14BIT 0x0
#define SD_16BIT 0x1
#define SD_18BIT 0x2
#define SD_20BIT 0x3
//>> SD Conversion Trigger Key Words
#define SD_PWM 0x1
#define SD_WT2READ 0x0
//>> V2P Resistor Key Words
#define V2P_220K 0x0
#define V2P_256K 0x1
#define V2P_291K 0x2
#define V2P_185K 0x3
/**
 * @brief This function clears AD_READ_REG
 *
 * @return      void
 */
#define RT_ADC_Clear() MemoryWrite32(AD_CLR_REG, 1)
/************* OPO setup **************/
// set OPO on
#define RT_OPO_On() MemoryOr32(AD_OPO_REG, 0x1)
// set OPO off
#define RT_OPO_Off() MemoryAnd32(AD_OPO_REG, ~1)
/**
 * @brief
 * This function selects the opo channel to use, ON for use, Off for not use.
 * @param ch0       channel 0
 * @param ch1       channel 1
 * @param ch2       channel 2
 * @param ch3       channel 3
 * @return          void
 */
#define RT_OPO_SetChannel(ch0, ch1, ch2, ch3)                                        \
    {                                                                                \
        MemoryAnd32(AD_OPO_REG, ~(0xf << 4));                                        \
        MemoryOr32(AD_OPO_REG, ((ch0 << 4) + (ch1 << 5) + (ch2 << 6) + (ch3 << 7))); \
    }
/**
 * @brief This function sets the amplification of opo.
 *
 * @param Pin       Pin resistor
 * @param Pgain     Pside amplification
 * @param Nin       Nin resistor
 * @param Ngain     Nside amplification
 * @return          void
 */
#define RT_OPO_SetAmplification(Pin, Pgain, Nin, Ngain)                                  \
    {                                                                                    \
        MemoryAnd32(AD_OPO_REG, ~(0xff << 8));                                           \
        MemoryOr32(AD_OPO_REG, (((Pin << 7) + (Pgain << 4) + (Nin << 3) + Ngain) << 8)); \
    }
/**
 * @brief This function sets the feedback mode of OPO
 * select amp feedback to be single side  or both side
 * 0 for both side (normal use), 1 for single side (only n side has feedback)
 * when mode = 1, vcom(1.5V) is connected to the resistor block at inp
 * when mode = 0, vcom is disconnected to the resistor block at inp
 * @param mode      Pside feedback switch, ON or OFF
 * @return          void
 */
#define RT_OPO_SetPsideFeedback(mode)           \
    {                                           \
        if (mode)                               \
            MemoryOr32(AD_OPO_REG, (1 << 3));   \
        else                                    \
            MemoryAnd32(AD_OPO_REG, ~(1 << 3)); \
    }
/**
 * @brief This function sets whether to exchange Pside and Nside
 * 1 for inn and inp switch, 0 for not (normal use)
 * @param mode      exchange switch, ON or OFF
 * @return          void
 */
#define RT_OPO_SetPNExchange(mode)              \
    {                                           \
        if (mode)                               \
            MemoryOr32(AD_OPO_REG, (1 << 2));   \
        else                                    \
            MemoryAnd32(AD_OPO_REG, ~(1 << 2)); \
    }
/**
 * @brief This function sets whether to connecte pin and nin to vcom
 * Channel 0-3 should be closed
 * @param mode      short switch, ON or OFF
 * @return          void
 */
#define RT_OPO_SetShort(mode)                     \
    {                                             \
        if (mode)                                 \
        {                                         \
            MemoryAnd32(AD_OPO_REG, ~(0xf << 4)); \
            MemoryOr32(AD_OPO_REG, (1 << 1));     \
        }                                         \
        else                                      \
            MemoryAnd32(AD_OPO_REG, ~(1 << 1));   \
    }
/**
 * @brief This function sets the bypass of opo.
 * If opo is bypassed, input will be fed into SD directly.
 * (select the filter resistor, 1 for 50k and 0 for 100k)
 * @param mode      bypass switch, ON or OFF
 * @return          void
 */
#define RT_OPO_SetBypass(mode)                    \
    {                                             \
        if (mode)                                 \
            MemoryOr32(AD_CTL0_REG, (1 << 15));   \
        else                                      \
            MemoryAnd32(AD_CTL0_REG, ~(1 << 15)); \
    }
/**
 * @brief This function sets the gnd of Pside
 * op=1, PsideGND = vcom; op=0, PsideGND = 0
 * @param op    the option of gnd, VCOM or GND
 * @return      void
 */
#define RT_OPO_SetPsideGND(op)               \
    {                                        \
        MemoryAnd32(AD_CTL0_REG, ~(1 << 7)); \
        MemoryOr32(AD_CTL0_REG, op << 7);    \
    }
/**
 * @brief This function sets OPO at SingleSide Mode
 *
 * @param PorN      the switch to exchange Pside and Nside, ON or OFF
 * @param channel   the channel to select
 * @return          void
 */
#define RT_OPO_SetSingleSideMode(PorN, channel) \
    {                                           \
        RT_ADC_V2P_SetRes(V2P_185K);            \
        RT_ADC_TemperatureSensorOff();          \
        RT_OPO_SetPNExchange(PorN);             \
        MemoryAnd32(AD_OPO_REG, ~(0xf << 4));   \
        MemoryOr32(AD_OPO_REG, channel);        \
    }
/**
 * @brief This function sets OPO at Differential Mode
 *
 * @param PorN      the switch to exchange Pside and Nside, ON or OFF
 * @param channel   the channel to select
 * @return          void
 */
#define RT_OPO_SetDifferentialMode(PorN, channel) \
    {                                             \
        RT_ADC_V2P_SetRes(0);                     \
        RT_OPO_SetPNExchange(PorN);               \
        MemoryAnd32(AD_OPO_REG, ~(0xf << 4));     \
        MemoryOr32(AD_OPO_REG, channel);          \
    }

/************* SD Setup **************/
// set ADC_SD on
#define RT_ADC_SD_On() MemoryOr32(AD_CTL0_REG, 1)
// set ADC_SD off
#define RT_ADC_SD_Off() MemoryAnd32(AD_CTL0_REG, ~1)
/**
 * @brief This function sets the samplerate of RT_ADC_SD
 *
 * @param mode      SD_CLK_3M, SD_CLK_1_5M, SD_CLK_781K or SD_CLK_390K
 * @return          void
 */
#define RT_ADC_SD_SetSampleRate(mode)          \
    {                                          \
        MemoryAnd32(AD_CTL0_REG, ~(0x3 << 3)); \
        MemoryOr32(AD_CTL0_REG, (mode << 3));  \
    }
/**
 * @brief This function sets the filter frequency, also sets the number adbits
 *
 * @param freq      SD_FCLK_1K, SD_FCLK_512, SD_FCLK_256 or SD_FCLK_128
 * @return          void
 */
#define RT_ADC_SD_SetFilterCLK(freq)           \
    {                                          \
        MemoryAnd32(AD_CTL0_REG, ~(0x3 << 1)); \
        MemoryOr32(AD_CTL0_REG, (freq << 1));  \
    }
// set the digital filter clock freq with ad bits (defined at the beginning)
/**
 * @brief This function sets the number of ad
 *
 * @param mode      SD_14BIT, SD_16BIT, SD_18BIT or SD_20BIT
 * @return          void
 */
#define RT_ADC_SD_SetAdBits(mode)              \
    {                                          \
        MemoryAnd32(AD_CTL0_REG, ~(0x3 << 1)); \
        MemoryOr32(AD_CTL0_REG, (mode << 1));  \
    }
/**
 * @brief This function sets the trigger source of RT_ADC_SD
 *
 * @param op        SD_PWM or SD_WT2READ
 * @return          void
 */
#define RT_ADC_SD_SetTrigger(op)             \
    {                                        \
        MemoryAnd32(AD_CTL0_REG, ~(1 << 6)); \
        MemoryOr32(AD_CTL0_REG, op << 6);    \
    }
/**
 * @brief This function sets RT_ADC_SD briefly.
 *
 * @param samplerate    the samplerate of SD
 * @param ad            the number of ad
 * @return              void
 */
#define RT_ADC_SD_Setup(samplerate, ad)      \
    {                                        \
        RT_ADC_SD_SetSampleRate(samplerate); \
        RT_ADC_SD_SetAdBits(ad);             \
    }
/**
 * @brief This function starts ADC accumulate
 * When writing to AD_READ_REG, it will start df conversion,
 * if SD is enabled and choose trig pwm. SD flag or irq will
 * be asserted upon conversion completed.
 * @return #define
 */
#define RT_ADC_SD_Start()              \
    {                                  \
        RT_ADC_SD_On();                \
        RT_ADC_Clear();                \
        MemoryWrite32(AD_READ_REG, 1); \
    }

/************* V2P Setup **************/
// set ADC_V2P on
#define RT_ADC_V2P_On() MemoryOr32(AD_CTL0_REG, (1 << 8))
// set ADC_V2P off
#define RT_ADC_V2P_Off() MemoryAnd32(AD_CTL0_REG, ~(1 << 8))
/**
 * @brief This function sets the resistor of V2P
 * when res = 3, single input mode is enabled, vcom will be fed into the P-side of OPO
 * @param res   V2P_185K, V2P_220K, V2P_256K, or V2P_291K
 * @return #define
 */
#define RT_ADC_V2P_SetRes(res)                 \
    {                                          \
        MemoryAnd32(AD_CTL0_REG, ~(0x3 << 9)); \
        MemoryOr32(AD_CTL0_REG, (res << 9));   \
    }
// set ADC temperature sensor on
#define RT_ADC_TemperatureSensorOn() MemoryOr32(AD_CTL0_REG, 1 << 5)
// set ADC temperature sensor off
#define RT_ADC_TemperatureSensorOff() MemoryAnd32(AD_CTL0_REG, ~(1 << 5))
/**
 * @brief This function returns ADC_SD Value
 *
 * @return int  ADC_SD Value
 */
int RT_ADC_SD_Read();
/**
 * @brief This function returns ADC_V2P Value
 *
 * @return int  ADC_V2P Value
 */
int RT_ADC_V2P_Read();
#endif // End of __AFE_h__
