/**
* @file IO.h
* @author Zhirui Dai
* @date 16 Jun 2018
* @copyright 2018 Zhirui
* @brief General Input Output Library for M2
*/
#ifndef __IO_h__
#define __IO_h__

#include "mcu.h"

/*! Keyword OUTPUT. */
#define OUTPUT 0x1
/*! Keyword INPUT. */
#define INPUT 0x0
/*! Keyword HIGH. */
#define HIGH 0x1
/*! Keyword LOW. */
#define LOW 0x0

/**
 * @brief This function sets a specific channel at OUTPUT mode
 * @param io    Channel to set.
 * @return      void
 */
#define RT_IO_SetOutput(io) MemoryOr32(SYS_IOCTL_REG, (1 << (io)))

/**
 * @brief This function sets a specific channel at INPUT mode
 * @param io    Channel to set.
 * @return      void
 */
#define RT_IO_SetInput(io) MemoryAnd32(SYS_IOCTL_REG, ~(1 << (io)))

/**
 * @brief       This function sets the mode of all GPIO channels
 * @param mode  16-bit number which defines 16 IO channels' mode
 * @return      void
 */
#define RT_IO_SetInputOutput16(mode) MemoryWrite32(SYS_IOCTL_REG, mode)

/**
 * @brief       This function sets a specific output io channel at HIGH level
 * @param io    Channel to set.
 * @return      void
 */
#define RT_IO_SetHigh(io) MemoryOr32(SYS_GPIO0_REG, (1 << (io)))

/**
 * @brief       This function sets a specific output io channel at LOW level
 * @param io    Channel to set.
 * @return      void
 */
#define RT_IO_SetLow(io) MemoryAnd32(SYS_GPIO0_REG, ~(1 << (io)))

/**
 * @brief       This function sets the level of all 16 io channel
 *
 * @param level 16-bit number which defines 16 IO channels' level
 * @return      void
 */
#define RT_IO_SetLevel16(level) MemoryWrite32(SYS_GPIO0_REG, (level))

/**
 * @brief       This function returns the level of a specific io
 *
 * @param  io   the io channel to read
 * @return      the io level
 */
#define RT_IO_Read(io) ((MemoryRead32(SYS_GPIO1_REG) >> (io)) & 0x1)

/**
 * @brief           This function returns the level of all 16 io
 *
 * @return uint16_t 16-bit number which defines 16 io channels' level
 */
#define RT_IO_Read16() MemoryRead32(SYS_GPIO1_REG)

/**
 * @brief This function sets the mode of specific GPIO channel
 *
 * @param io    the specific io channel to setup
 * @param mode  the mode, optional value: #INPUT, #OUTPUT
 * @return      void
 */
#define RT_IO_SetInputOutput(io, mode)     \
    {                         \
        if (!mode)            \
            IO_SetInput(io);  \
        else                  \
            IO_SetOutput(io); \
    }

/**
 * @brief This function sets the level of a specific io channel
 *
 * @param io    the io channel to setup
 * @param level the io level, optional value: #HIGH, #LOW
 * @return      void
 */
#define RT_IO_SetLevel(io, level) \
    {                       \
        IO_SetOutput(io);   \
        if (!level)         \
            IO_SetLow(io);  \
        else                \
            IO_SetHigh(io); \
    }
#endif // End of __IO_h__
