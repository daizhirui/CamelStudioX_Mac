/**
* @file Flash.h
* @author Zhirui Dai
* @date 22 Jun 2018
* @copyright 2018 Zhirui
* @brief Flash Operation Library for M2
*/

#ifndef __M2_FLASH_H__
#define __M2_FLASH_H__

#include "mcu.h"

/*! \cond PRIVATE */
#define FLASH_WRITE_ADDRESS 0x2c4
#define FLASH_ERASE_ADDRESS 0x2f8
/*! \endcond */

/**
 * @brief       Flash Write procedure, 32-bit write
 * @param address     The address to write, staring from 0x10000000
 * @param value       The value to be written, a 32-bit value
 * @return      void
 */
#define RT_Flash_Write(value, address)                  \
    {                                                   \
        FuncPtr2 funcptr;                               \
        funcptr = (FuncPtr2)FLASH_WRITE_ADDRESS;        \
        uint32_t oldVal = MemoryRead32(SYS_CTL2_REG);   \
        RT_MCU_SetSystemClock(SYS_CLK_6M);              \
        funcptr(value, address);                        \
        MemoryWrite32(SYS_CTL2_REG, oldVal);            \
    }

/**
 * @brief       Flash erase procedure, 1K-byte erase from the given address
 * @param address     The starting address to erase, 1K-byte space to be erased
 * @return      void
 */
#define RT_Flash_Erase1k(address)                       \
    {                                                   \
        unsigned long addr;                             \
        FuncPtr1 funcptr;                               \
        funcptr =  (FuncPtr1)FLASH_ERASE_ADDRESS;       \
        addr = ((address&0x1ffff) | 0x10100000);        \
        uint32_t oldVal = MemoryRead32(SYS_CTL2_REG);   \
        RT_MCU_SetSystemClock(SYS_CLK_6M);              \
        funcptr(addr);                                  \
        MemoryWrite32(SYS_CTL2_REG, oldVal);            \
    }
/**
 * @brief       Flash erase from the given address, to the end of the flash
 * @param address     The starting address to the end (0x10001f400)
 * @return      void
 */
#define RT_Flash_EraseFrom(address)                                     \
    {                                                                   \
        for(unsigned long addr=address;addr<0x10001f400;addr+=0x400) {  \
            RT_Flash_Erase1k(addr);                                     \
        }                                                               \
    }


/**
 * @brief       Chip ID location (this will be replaced by NVR chip ID)
 * @return      void
 */
#define MAC_ID 0x1001f3f0

/**
 * @brief Set chip identity(MAC_ID).
 */
#define RT_Flash_SetMAC(id)     RT_Flash_Write(id, MAC_ID)

/**
 * @brief Get chip identity(MAC_ID).
 */
#define getMAC() MemoryRead32(MAC_ID)

#endif
