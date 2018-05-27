#ifndef __irq_h__
#define __irq_h__

#include "mcu.h"

/*********** Hardware addesses ***********/
#define INT_CTL0_REG 0x1f800500 // EX Int enable control and base
#define INT_CTL1_REG 0x1f800501 // EX Int IRQ bits content read, (m1=03)
#define INT_CTL2_REG 0x1f800502 // EX Int high enable
#define INT_CLR_REG 0x1f800503  // EX Int IRQ clear  (m1=01)
#define SYS_CTL0_REG 0x1f800700 // sys control digi_off - - - - - dbg inten
#define SYS_IRQ_REG 0x1f800707

#define RT_SysIrq_On() MemoryOr32(SYS_CTL0_REG, 0x1)
#define RT_SysIrq_Off()   MemoryAnd32(SYS_CTL0_REG, ~0x1)
#define RT_SysIrq_GetFlag()   MemoryRead32(SYS_IRQ_REG)
//|BIT|  0  | 1 | 2 | 3 | 4 | 5 | 6 |  7  | 8 |
//|IRQ|UART0|TC0|TC1|TC2|DBG|EXT|WDT|UART1|SPI|
/*********** External interrupt***********/
//********************************************************//
// void EXINT_Set(int en, int trigger)                 //
// Description:                                           //
// This function set the external interrupt               //
// "en" is the the number of the interrupt you want to    //
// open. en = 0:5 stands for INT0:INT5 representively.    //
// "trigger" is the trigger constrant."trigger" = 1 means //
// raising edge trigger."trigger"=0 means falling edge trigger //
//********************************************************//
/**
 * @brief This function sets the external interrupt
 * 
 * @param port   the port of external interrupt, 0 to 5
 * @param trigger   the trigger mode, RISING or FALLING
 * @return          void
 */
#define RT_EXINT_Set(port, trigger)                     \
    {                                                \
        MemoryOr32(INT_CTL0_REG, 1 << port);         \
        if (trigger == 1)                            \
            MemoryOr32(INT_CTL2_REG, 1 << port);     \
        else                                         \
            MemoryAnd32(INT_CTL2_REG, ~(1 << port)); \
    }
/**
 * @brief This function closes an external interrupt port
 * 
 * @param port      the external interrupt port to close
 * @return          void
 */
#define RT_EXINT_Off(port) MemoryAnd32(INT_CTL0_REG, ~(1 << port))
/**
 * @brief This function clears interrupt flag from specific EXINT port
 * 
 * @return          void
 */
#define RT_EXINT_Clear(no) MemoryWrite(INT_CLR_REG, 1 << no)
/**
 * @brief This function clears all EXINT flag
 * 
 * @return          void
 */
#define RT_EXINT_ClearAll() MemoryWrite(INT_CLR_REG, 0xff)
/**
 * @brief This function gets the EXINT flag table
 * 
 * @return         the EXINT flag table 
 */
#define RT_EXINT_GetFlag() MemoryRead(INT_CTL1_REG)
/*********** External interrupt end*******/

#endif //__EXTIN_H__
