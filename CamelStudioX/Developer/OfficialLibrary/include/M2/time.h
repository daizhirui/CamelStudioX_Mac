/*--------------------------------------------------------------------
 * TITLE: M2 Hardware Definition
 * AUTHOR: Astro
 * DATE CREATED: 2017/11/4
 * FILENAME: time.h
 * PROJECT: M2Library
 * COPYRIGHT: Camel Microelectronics, Ltd.
 * DESCRIPTION:
 *--------------------------------------------------------------------*/
#ifndef __time_h__
#define __time_h__

#include "mcu.h"

#define RTC_12HOUR 0x1
#define RTC_24HOUR 0x3
/*********** Hardware addesses ***********/

// RTC
#define RTC_CTL_REG 0x1f800f00
#define RTC_TIME_REG 0x1f800f01 // time
#define RTC_CLR_REG 0x1f800f03

/**
 * @brief This function turns RTC on
 * 
 * @return      void
 */
#define RT_RTC_On() MemoryOr32(RTC_CTL_REG, 1)
/**
 * @brief This function turns RTC off
 * 
 * @return      void
 */
#define RT_RTC_Off() MemoryAnd32(RTC_CTL_REG, ~1)
/**
 * @brief This function sets the time format of RTC
 * 
 * @param formate 
 * @return      void
 */
#define RT_RTC_SetTimeFormat(format)                \
    {                                            \
        MemoryWrite32(RTC_CTL_REG, format);      \
        MemoryWrite32(RTC_TIME_REG, 0x00420000); \
    }
/**
 * @brief This function sets the time of RTC
 * 
 * @param year      year value
 * @param month     month value
 * @param day       day value
 * @param hour      hour value
 * @param min       minute value
 * @param sec       second value
 * @return          void
 */
#define RT_RTC_SetTime(year, month, day, hour, min, sec) \
                        MemoryWrite32(RTC_TIME_REG, year << 26 | mon << 22 | day << 17 | hour << 12 | min << 6 | sec);
/**
 * @brief This function returns the RTC time raw value
 * 
 * @return #define 
 */
#define RT_RTC_Read32()    MemoryRead32(RTC_TIME_REG)
/**
 * @brief This function returns the RTC time
 * 
 * @param d_year    year
 * @param d_mon     month
 * @param d_day     day
 * @param d_hour    hour
 * @param d_min     minute
 * @param d_sec     second
 */
extern void RT_RTC_GetTime(unsigned char *d_year, unsigned char *d_mon, unsigned char *d_day,
                        unsigned char *d_hour, unsigned char *d_min, unsigned char *d_sec);
/**
 * @brief This function delays specific time
 * 
 * @param ms 	time to delay, the unit is ms
 */
void RT_DelayMiliseconds(unsigned long ms);

#endif