/*--------------------------------------------------------------------
 * TITLE: M2 Hardware Definition
 * AUTHOR: Astro
 * DATE CREATED: 2017/11/2
 * FILENAME: IO.h
 * PROJECT: M2Library
 * COPYRIGHT: Camel Microelectronics, Ltd.
 * DESCRIPTION:
 *--------------------------------------------------------------------*/
#ifndef __IO_h__
#define __IO_h__

#include "mcu.h"

/*********** Hardware addesses ***********/
#define SYS_GDR_REG 0x1f800703   // gdr register
#define SYS_IOCTL_REG 0x1f800704 // 0=in; 1-out (16-bit), was IO config
#define SYS_GPIO0_REG 0x1f800705 // GPIO (16-bit) to pad content
#define SYS_GPIO1_REG 0x1f800706 // GPIO (16_bit) from pad read
/*********** Value DefinitIOn ************/
#define OUTPUT 0x1
#define INPUT 0x0
#define HIGH 0x1
#define LOW 0x0
/***************** IO Setup***************/
/**
 * @brief This function sets a specific channel at OUTPUT mode
 * 
 * @return      void
 */
#define RT_IO_SetOutput(A) MemoryOr32(SYS_IOCTL_REG, (1 << A))
/**
 * @brief This function sets a specific channel at INPUT mode
 * 
 * @return      void
 */
#define RT_IO_SetInput(A) MemoryAnd32(SYS_IOCTL_REG, ~(1 << A))
/**
 * @brief This function sets the mode of all GPIO channels
 * 
 * @param A     16-bit number which defines 16 IO channels' mode
 * @return      void
 */
#define RT_IO_Mode16(A) MemoryWrite32(SYS_IOCTL_REG, A)
/**
 * @brief This function sets a specific output io channel at HIGH level
 * 
 * @return      void 
 */
#define RT_IO_SetHigh(A) MemoryOr32(SYS_GPIO0_REG, (1 << A))
/**
 * @brief This function sets a specific output io channel at LOW level
 * 
 * @return      void 
 */
#define RT_IO_SetLow(A) MemoryAnd32(SYS_GPIO0_REG, ~(1 << A))
/**
 * @brief This function sets the level of all 16 io channel
 * 
 * @param A     16-bit number which defines 16 IO channels' level
 * @return      void 
 */
#define RT_IO_Write16(A) MemoryWrite32(SYS_GPIO0_REG, A)
/**
 * @brief This function returns the level of a specific io
 * 
 * @param  A    the io channel to read
 * @return      the io level
 */
#define RT_IO_Read(A) ((MemoryRead32(SYS_GPIO1_REG) >> A) & 0x1)
/**
 * @brief This function returns the level of all 16 io
 * 
 * @return      16-bit number which defines 16 io channels' level 
 */
#define RT_IO_Read16() MemoryRead32(SYS_GPIO1_REG)
/**
 * @brief This function sets the mode of specific GPIO channel
 * 
 * @param io    the specific io channel to setup
 * @param mode  the mode, INPUT or OUTPUT
 * @return      void
 */
#define RT_IO_Mode(io, mode)     \
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
 * @param level the io level
 * @return      void
 */
#define RT_IO_Write(io, level) \
    {                       \
        IO_SetOutput(io);   \
        if (!level)         \
            IO_SetLow(io);  \
        else                \
            IO_SetHigh(io); \
    }
#endif // End of __IO_h__
