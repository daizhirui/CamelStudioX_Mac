/**
 * @file Interrupt.h
 * @author Zhirui Dai
 * @date 16 Jun 2018
 * @copyright 2018 Zhirui
 * @brief Interrupt Library for M2
 */

#ifndef __INTERRUPT_H__
#define __INTERRUPT_H__

#include "mcu.h"

typedef enum {
    SYSINT_SPIINT    = 0x8,		/*! SPI Interrupt */
    SYSINT_UART1INT  = 0x7,		/*! UART1 Interrupt */
    SYSINT_WDTINT    = 0x6,		/*! WDT Interrupt */
    SYSINT_EXTINT    = 0x5,		/*! EXT Interrupt */
    SYSINT_DBGINT    = 0x4,		/*! DBG Interrupt */
    SYSINT_TC2INT    = 0x3,		/*! TC2 Interrupt */
    SYSINT_TC1INT    = 0x2,		/*! TC1 Interrupt */
    SYSINT_TC0INT    = 0x1,		/*! TC0 Interrupt */
    SYSINT_UART0INT  = 0x0		/*! UART0 Interrupt */
} SYSINT_DEVICE;

/**
 * @brief Check interrupt flag of SPI, UART1, WatchDog, ExternalInterrupt,
 *        Debug, Timer2, Timer1, Timer0 or UART0.
 * @note  SYS_IRQ_REG[8:0]: 9 devices.
 * @param device Optional value: #SYSINT_SPIINT, #SYSINT_UART1INT, #SYSINT_UART0INT, #SYSINT_WDTINT, #SYSINT_EXTINT, #SYSINT_DBGINT, #SYSINT_TC2INT, #SYSINT_TC1INT, #SYSINT_TC0INT
 */
inline uint32_t RT_SYSINT_GetFlag(SYSINT_DEVICE device)
{
    return ( MemoryRead32(SYS_IRQ_REG) & (0x1 << device) ) >> device;
}
/**
 * @brief Turn on system interrupt.
 * @note  SYS_CTL0_REG[0]: 1=enable system interrupt, 0=disable system interrupt.
 */
inline void RT_SYSINT_On()
{
    MemoryOr32(SYS_CTL0_REG, 0x1);
}
/**
 * @brief Turn off system interrupt.
 * @note  SYS_CTL0_REG[0]: 1=enable system interrupt, 0=disable system interrupt.
 */
inline void RT_SYSINT_Off()
{
    MemoryAnd32(SYS_CTL0_REG, ~0x1);
}

typedef enum {
    EXINT0 = 0x0,	/*! Enternal interrupt 0 */
    EXINT1 = 0x1,	/*! Enternal interrupt 1 */
    EXINT2 = 0x2,	/*! Enternal interrupt 2 */
    EXINT3 = 0x3,	/*! Enternal interrupt 3 */
    EXINT4 = 0x4,	/*! Enternal interrupt 4 */
    EXINT5 = 0x5	/*! Enternal interrupt 5 */
} EXTINT_PORT;
/**
 * @brief           Set the external interrupt
 * @param port      the port of external interrupt, optional value: #EXINT0, #EXINT1, #EXINT2, #EXINT3, #EXINT4, #EXINT5
 * @param trigger   the trigger mode, optional value: #RISING, #FALLING
 * @return          void
 */
inline void RT_EXINT_Setup(EXTINT_PORT port, trigger_mode_t mode)                \
    {                                                \
        MemoryOr32(INT_CTL0_REG, 1 << port);         \
        MemoryAnd32(INT_CTL2_REG, ~(RISING_TRIGGER << port)); \
        MemoryOr32(INT_CTL2_REG, trigger << port);   \
    }
/**
 * @brief           Close an external interrupt port.
 * @param port      the external interrupt port to close, optional value:
 #EXINT0, #EXINT1, #EXINT2, #EXINT3, #EXINT4, #EXINT5
 * @return          void
 */
inline void RT_EXINT_Off(port)
{
    MemoryAnd32(INT_CTL0_REG, ~(1 << port));
}

/**
 * @brief       Clear interrupt flag from specific external interrupt port
 * @param port  the external interrupt port to clear irq flag, optional value: #EXINT0, #EXINT1, #EXINT2, #EXINT3, #EXINT4, #EXINT5
 * @return      void
 */
inline void RT_EXINT_Clear(port)
{
    MemoryWrite32(INT_CLR_REG, 1 << port);
}
/**
 * @brief   Clear all external interrupt flag.
 * @return  void
 */
inline void RT_EXINT_ClearAll()
{
    MemoryWrite32(INT_CLR_REG, 0xff);
}
/**
 * @brief   Get the external interrupt flag table.
 * @return  the external interrupt flag table
 */
inline uint32_t RT_EXINT_GetAllFlag()
{
    return MemoryRead32(INT_CTL1_REG);
}
/**
 * @brief   Get the flag of specific external interrupt port.
 * @return  The flag of the external interrupt port.
 */
inline uint32_t RT_EXINT_GetFlag(port)
{
    return ( (RT_EXINT_GetAllFlag() >> port) & 0x1 );
}

#endif
