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

/**
 * @brief   Keyword SYSINT_SPIINT
 * @note    Optional value for RT_SYSINT_Flag
 */
#define SYSINT_SPIINT       0x8
/**
 * @brief   Keyword SYSINT_UART1INT
 * @note    Optional value for RT_SYSINT_Flag
 */
#define SYSINT_UART1INT     0x7
/**
 * @brief   Keyword SYSINT_WDTINT
 * @note    Optional value for RT_SYSINT_Flag
 */
#define SYSINT_WDTINT       0x6
/**
 * @brief   Keyword SYSINT_EXTINT
 * @note    Optional value for RT_SYSINT_Flag
 */
#define SYSINT_EXTINT       0x5
/**
 * @brief   Keyword SYSINT_DBGINT
 * @note    Optional value for RT_SYSINT_Flag
 */
#define SYSINT_DBGINT       0x4
/**
 * @brief   Keyword SYSINT_TC2INT
 * @note    Optional value for RT_SYSINT_Flag
 */
#define SYSINT_TC2INT       0x3
/**
 * @brief   Keyword SYSINT_TC1INT
 * @note    Optional value for RT_SYSINT_Flag
 */
#define SYSINT_TC1INT       0x2
/**
 * @brief   Keyword SYSINT_TC0INT
 * @note    Optional value for RT_SYSINT_Flag
 */
#define SYSINT_TC0INT       0x1
/**
 * @brief   Keyword SYSINT_UART0INT
 * @note    Optional value for RT_SYSINT_Flag
 */
#define SYSINT_UART0INT     0x0
/**
 * @brief Check interrupt flag of SPI, UART1, WatchDog, ExternalInterrupt,
 *        Debug, Timer2, Timer1, Timer0 or UART0.
 * @note  SYS_IRQ_REG[8:0]: 9 devices.
 * @param device Optional value: #SYSINT_SPIINT, #SYSINT_UART1INT, #SYSINT_UART0INT, #SYSINT_WDTINT, #SYSINT_EXTINT, #SYSINT_DBGINT, #SYSINT_TC2INT, #SYSINT_TC1INT, #SYSINT_TC0INT
 */
#define RT_SYSINT_GetFlag(device)  (MemoryRead(SYS_IRQ_REG)&(0x1 << device) >> device)
/**
 * @brief Turn on system interrupt.
 * @note  SYS_CTL0_REG[0]: 1=enable system interrupt, 0=disable system interrupt.
 */
#define RT_SYSINT_On()              MemoryOr(SYS_CTL0_REG, 0x1)
/**
 * @brief Turn off system interrupt.
 * @note  SYS_CTL0_REG[0]: 1=enable system interrupt, 0=disable system interrupt.
 */
#define RT_SYSINT_Off()             MemoryAnd(SYS_CTL0_REG, ~0x1)
/**
 * @brief Keyword EXINT0
 * @note  Optional value used in RT_EXINT_Setup
 */
#define EXINT0      0x0
/**
 * @brief Keyword EXINT1
 * @note  Optional value used in RT_EXINT_Setup
 */
#define EXINT1      0x1
/**
 * @brief Keyword EXINT2
 * @note  Optional value used in RT_EXINT_Setup
 */
#define EXINT2      0x2
/**
 * @brief Keyword EXINT3
 * @note  Optional value used in RT_EXINT_Setup
 */
#define EXINT3      0x3
/**
 * @brief Keyword EXINT4
 * @note  Optional value used in RT_EXINT_Setup
 */
#define EXINT4      0x4
/**
 * @brief Keyword EXINT5
 * @note  Optional value used in RT_EXINT_Setup
 */
#define EXINT5      0x5
/**
 * @brief Keyword RISING.
 * @note  Optional value used in RT_EXINT_Setup
 */
#define RISING  0x1
/**
 * @brief Keyword FALLING.
 * @note  Optional value used in RT_EXINT_Setup
 */
#define FALLING 0x0
/**
 * @brief           Set the external interrupt
 * @param port      the port of external interrupt, optional value: #EXINT0, #EXINT1, #EXINT2, #EXINT3, #EXINT4, #EXINT5
 * @param trigger   the trigger mode, optional value: #RISING, #FALLING
 * @return          void
 */
#define RT_EXINT_Setup(port, trigger)                \
    {                                                \
        MemoryOr32(INT_CTL0_REG, 1 << port);         \
        MemoryAnd32(INT_CTL2_REG, ~(RISING << port));\
        MemoryOr32(INT_CTL2_REG, trigger << port);   \
    }
/**
 * @brief           Close an external interrupt port.
 * @param port      the external interrupt port to close, optional value:
                    #EXINT0, #EXINT1, #EXINT2, #EXINT3, #EXINT4, #EXINT5
 * @return          void
 */
#define RT_EXINT_Off(port)  MemoryAnd32(INT_CTL0_REG, ~(1 << port))

/**
 * @brief       Clear interrupt flag from specific external interrupt port
 * @param port  the external interrupt port to clear irq flag, optional value: #EXINT0, #EXINT1, #EXINT2, #EXINT3, #EXINT4, #EXINT5
 * @return      void
 */
#define RT_EXINT_Clear(port)  MemoryWrite(INT_CLR_REG, 1 << port)
/**
 * @brief   Clear all external interrupt flag.
 * @return  void
 */
#define RT_EXINT_ClearAll() MemoryWrite(INT_CLR_REG, 0xff)
/**
 * @brief   Get the external interrupt flag table.
 * @return  the external interrupt flag table
 */
#define RT_EXINT_GetAllFlag()       MemoryRead(INT_CTL1_REG)
/**
 * @brief   Get the flag of specific external interrupt port.
 * @return  The flag of the external interrupt port.
 */
#define RT_EXINT_GetFlag(port)      ((RT_EXINT_GetAllFlag() >> port) & 0x1)

#endif
