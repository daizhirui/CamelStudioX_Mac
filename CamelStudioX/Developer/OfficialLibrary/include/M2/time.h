/**
* @file time.h
* @author Zhirui Dai
* @date 16 Jun 2018
* @copyright 2018 Zhirui
* @brief Real Time Module Library for M2
*/#ifndef __time_h__
#define __time_h__

#include "mcu.h"

/**
 * @brief   Turn on RTC.
 * @return  void
 */
#define RT_RTC_On() MemoryOr32(RTC_CTL_REG, 1)

/**
 * @brief   Turn off RTC.
 * @return  void
 */
#define RT_RTC_Off() MemoryAnd32(RTC_CTL_REG, ~1)

/**
 * @brief   Keyword RTC_12HOUR
 * @note    Time format used in RT_RTC_SetTimeFormat
 */
#define RTC_12HOUR 0x1

/**
 * @brief   Keyword RTC_24HOUR
 * @note    Time format used in RT_RTC_SetTimeFormat
 */
#define RTC_24HOUR 0x3

/**
 * @brief           Set the time format of RTC.
 * @param formate   The time format, optional value: \code{.c}RTC_12HOUR, RTC_24HOUR\endcode.
 * @return          void
 */
#define RT_RTC_SetTimeFormat(format)             \
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
