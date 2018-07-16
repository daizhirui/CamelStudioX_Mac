/**
 * @brief M2 micro core unit
 * @file mcu.h
 * @author Zhirui Dai
 * @date 2018-05-25
 */

#ifndef __M2_MCU__
#define __M2_MCU__

#include <stdint.h>

/*! switch type */
typedef enum {
    /*! Turn on */
    ON  = 0x1,
    /*! Turn off */
    OFF = 0x0
} switch_t;

/*! trigger mode type */
typedef enum {
    /*! Rising trigger */
    RISING_TRIGGER     = 0x1,
    /*! Falling trigger */
    FALLING_TRIGGER    = 0x0
} trigger_mode_t;

/*! Addresses for kernal interrupt process. These are not needed in user code. */
enum KERNAL_INTERRUPT {
	/*! interrupt is from user code if [0] is 1. */
    USER_INT = (uint32_t)0x01001FFC,
	/*! SRAM address to store current program counter */
    PC_LOC = (uint32_t)0x01001FF8,
	/*! SRAM address to store current interrupt depth, number of interrupts. */
    INT_COUNT = (uint32_t)0x01001FF4
};

/*! memory address type */
typedef unsigned long memory_addr_t;
/*! M2's external registers. */
enum M2_EXTERNAL_REG {
// System
    SYS_CTL0_REG        = (memory_addr_t)0x1f800700,// sys control digi_off - - - - - dbg inten
    SYS_CTL2_REG        = (memory_addr_t)0x1f800702,
    SYS_IRQ_REG         = (memory_addr_t)0x1f800707,	// SYS INT IRQ read
// Interrupt

// External Interrupt
    INT_CTL0_REG        = (memory_addr_t)0x1f800500,// EX Int enable control and base
    INT_CTL1_REG        = (memory_addr_t)0x1f800501,// EX Int IRQ bits content read, (m1=03)
    INT_CTL2_REG        = (memory_addr_t)0x1f800502,// EX Int high enable
    INT_CLR_REG         = (memory_addr_t)0x1f800503,	// EX Int IRQ clear  (m1=01)
// Uart0
    UART0_READ_REG      = (memory_addr_t)0x1f800000,
    UART0_BUSY_REG      = (memory_addr_t)0x1f800001,
    UART0_WRITE_REG     = (memory_addr_t)0x1f800002,
    UART0_IRQ_ACK_REG   = (memory_addr_t)0x1f800003,
    UART0_CTL_REG       = (memory_addr_t)0x1f800004,
    UART0_DATA_RDY_REG  = (memory_addr_t)0x1f800005,
    UART0_LIN_BREAK_REG = (memory_addr_t)0x1f800006,
    UART0_BRP_REG       = (memory_addr_t)0x1f800007,
// Uart1
    UART1_READ_REG      = (memory_addr_t)0x1f800800,
    UART1_BUSY_REG      = (memory_addr_t)0x1f800801,
    UART1_WRITE_REG     = (memory_addr_t)0x1f800802,
    UART1_IRQ_ACK_REG   = (memory_addr_t)0x1f800803,
    UART1_CTL_REG       = (memory_addr_t)0x1f800804,
    UART1_DATA_RDY_REG  = (memory_addr_t)0x1f800805,
    UART1_LIN_BREAK_REG = (memory_addr_t)0x1f800806,
    UART1_BRP_REG       = (memory_addr_t)0x1f800807,
// SPI
    SPI_READ_REG        = (memory_addr_t)0x1f800d00,// snoop read
    SPI_BUSY_REG        = (memory_addr_t)0x1f800d01,
    SPI_WRITE_REG       = (memory_addr_t)0x1f800d02,
    SPI_IRQ_ACK_REG     = (memory_addr_t)0x1f800d03,	// clear IRQ when wt
    SPI_CTL_REG         = (memory_addr_t)0x1f800d04,
    SPI_DATA_RDY_REG    = (memory_addr_t)0x1f800d05,
	/*! GDR register. */
    SYS_GDR_REG         = (memory_addr_t)0x1f800703,
	/*! GPIO mode control register(16-bit). */
    SYS_IOCTL_REG       = (memory_addr_t)0x1f800704,
	/*! GPIO output control register(16-bit). */
    SYS_GPIO0_REG       = (memory_addr_t)0x1f800705,
	/*! GPIO input value register(16-bit). */
    SYS_GPIO1_REG       = (memory_addr_t)0x1f800706,
// TC0
    T0_CTL0_REG         = (memory_addr_t)0x1f800100,	// T0 (32-bit)control and base
    T0_REF_REG          = (memory_addr_t)0x1f800101,	// T0 ref number for PWM(1)
    T0_READ_REG         = (memory_addr_t)0x1f800102,	// T0 value
    T0_CLRIRQ_REG       = (memory_addr_t)0x1f800103,	// T0 clear IRQ
    T0_CLK_REG          = (memory_addr_t)0x1f800104,	// T0 clk div
    T0_CLRCNT_REG       = (memory_addr_t)0x1f800105,	// T0 clear counter content (and PWM)
// TC1
    T1_CTL0_REG         = (memory_addr_t)0x1f800200,	// Timer1 (32-bit)control and base
    T1_REF_REG          = (memory_addr_t)0x1f800201,	// Timer1 ref number for PWM(1)
    T1_READ_REG         = (memory_addr_t)0x1f800202,	// Timer1 value
    T1_CLRIRQ_REG       = (memory_addr_t)0x1f800203,	// Timer1 clear IRQ
    T1_CLK_REG          = (memory_addr_t)0x1f800204,	// Timer1 clk div
    T1_CLRCNT_REG       = (memory_addr_t)0x1f800205,	// Timer1 clear counter content (and PWM)
// TC2
    T2_CTL0_REG         = (memory_addr_t)0x1f800400,	// Timer2 (32-bit)control and base
    T2_REF_REG          = (memory_addr_t)0x1f800401,	// Timer2 ref number for PWM(4, 32bit)
    T2_READ_REG         = (memory_addr_t)0x1f800402,	// Timer2 value
    T2_CLRIRQ_REG       = (memory_addr_t)0x1f800403,	// Timer2 clear IRQ
    T2_CLK_REG          = (memory_addr_t)0x1f800404,	// Timer2 clk div
    T2_CLRCNT_REG       = (memory_addr_t)0x1f800405,	// Timer2 clear counter content (and PWM)
    T2_PHASE_REG        = (memory_addr_t)0x1f800406,// Timer2 PWM phase reg (32b, 4 pwm)
// TC4
    T4_CTL0_REG         = (memory_addr_t)0x1f800a00,	// Timer8-4 (2-bit) enable control
    T4_REF0_REG         = (memory_addr_t)0x1f800a01,	// Timer8-4 ref number for PWM0 buz(8-bit)
    T4_CLK0_REG         = (memory_addr_t)0x1f800a02,	// Timer8-4 clk div for PWM0 (8-bit)
    T4_REF1_REG         = (memory_addr_t)0x1f800a03,	// Timer8-4 ref number for PWM1 fast(4-bit)
    T4_CLK1_REG         = (memory_addr_t)0x1f800a04,	// Timer8-4 clk div for PWM1 (8-bit)
// Analog
    AD_CTL0_REG         = (memory_addr_t)0x1f800600,	// SD and V2P control (16-bit)
    AD_OPO_REG          = (memory_addr_t)0x1f800601,	// OPO and Chan control (16-bit)
    AD_READ_REG         = (memory_addr_t)0x1f800602,	// SD df read (16-bit)
    AD_CLR_REG          = (memory_addr_t)0x1f800603,	// SD ADC clear reg
// LCD
    LCD_CTL0_REG        = (memory_addr_t)0x1f800300,// LCD control
    LCD_RAM_REG         = (memory_addr_t)0x1f800380,	// LCD ram starting (80-8C)
    LCD_RAM_LINE0       = (memory_addr_t)0x1f800380,	// LCD ram line0 (80-8C)
    LCD_RAM_LINE1       = (memory_addr_t)0x1f800384,	// LCD ram line1 (80-8C)
    LCD_RAM_LINE2       = (memory_addr_t)0x1f800388,	// LCD ram line2 (80-8C)
    LCD_RAM_LINE3       = (memory_addr_t)0x1f80038c,	// LCD ram line3 (80-8C)
// Watch Dog
    WDT_CTL0_REG        = (memory_addr_t)0x1f800b00,// WDT control
    WDT_CLR_REG         = (memory_addr_t)0x1f800b03,	// WDT clear reg
    WDT_READ_REG        = (memory_addr_t)0x1f800b02,// WDT read reg
// Real time module
    RTC_CTL_REG         = (memory_addr_t)0x1f800f00,
    RTC_TIME_REG        = (memory_addr_t)0x1f800f01,// time
    RTC_CLR_REG         = (memory_addr_t)0x1f800f03
};

/*! \cond PRIVATE */
#define DATA_SIZE 256
/*! \endcond */

/*! \cond PRIVATE */
#define MemoryRead(A) (*(volatile unsigned int*)(A))
#define MemoryWrite(A,V) *(volatile unsigned int*)(A)=(V)
#define MemoryOr(A,V) (*(volatile unsigned int*)(A)|=(V))
#define MemoryAnd(A,V) (*(volatile unsigned int*)(A)&=(V))
/*! \endcond */

/**
 * @brief Read 32-bit data from a specific address.
 * @param addr  the address to read
 * @return long the read value
 */
#define MemoryRead32(addr)      (*(volatile memory_addr_t*)(addr))

/**
 * @brief Write 32-bit data to a specific address.
 * @param addr  the address to write
 * @param val   the value to be written
 * @return void
 */
#define MemoryWrite32(addr, val)    (*(volatile memory_addr_t*)(addr)) = (val)

/**
 * @brief Logical OR operation on 32-bit data at a specific address.
 * @param addr   the address to be OR
 * @param val    the OR mask
 * @return void
 */
#define MemoryOr32(addr, val)    ((*(volatile memory_addr_t*)(addr)) |= (val))

/**
 * @brief Logical addrND operation on 32-bit data from a specific address.
 * @param addr   the address to be AND
 * @param val    the AND mask
 * @return void
 */
#define MemoryAnd32(addr, val)    ((*(volatile memory_addr_t*)(addr)) &= (val))

/**
 * @brief Get a specific bit of a 32-bit data from a specific address.
 * @param addr   the address
 * @param val    the bit location (in the 32-bit data)
 * @return long  the bit
 */
#define MemoryBitAt(addr, val)    (( *(volatile memory_addr_t*)(addr) >> val ) &0x1)

/**
 * @brief Set a specific bit of a 32-bit data from a specific address to 1.
 * @param addr   the address
 * @param val    the bit location (in the 32-bit data)
 * @return void
 */
#define MemoryBitOn(addr, val)    MemoryOr32(addr,1<<(val))

/**
 * @brief Set a specific bit of a 32-bit data from a specific address to 0.
 * @param addr   the address
 * @param val    the bit location (in the 32-bit data)
 * @return void
 */
#define MemoryBitOff(addr, val)    MemoryAnd32(addr,~(1<<(val)))

/**
 * @brief Set a specific bit of a 32-bit data from a specific address to opposite state.
 * @param addr   the address
 * @param val    the bit location (in the 32-bit data)
 * @return void
 */
#define MemoryBitSwitch(addr, val)    (*(volatile memory_addr_t*)(addr)^=(1<<(val)))

/*! Function pointer type (void)->void definition. */
typedef void (*FuncPtr)(void);

/*! Function pointer type (uint32_t)->void definition. */
typedef void (*FuncPtr1)(uint32_t);

/*! Function pointer type (uint32_t, uint32_t)->void definition. */
typedef void (*FuncPtr2)(uint32_t, uint32_t);

/**
 * @brief           Jump to a specific address.
 * @param address   the address to jump
 * @note            When this function is used, returning to the position where this function is used is impossible.
                    By using RT_MCU_JumpTo, we can make a soft reset. For example, if the entrance address of the program is 0x10000000, it is:
                    \code{.c}
                    RT_MCU_JumpTo(0x10000000);
                    \endcode
 * @return void
 */
#define RT_MCU_JumpTo(address)      \
{                                   \
    FuncPtr funcptr;                \
    funcptr = (FuncPtr)address;     \
    funcptr();                      \
}

/*! Keyword for setting the system clock frequency. */
typedef enum {
	/*! Set the system clock frequency at 3 MHz. */
    SYS_CLK_3M = (0x0<<12),
	/*! Set the system clock frequency at 6 MHz. */
    SYS_CLK_6M = (0x1<<12),
	/*! Set the system clock frequency at 12 MHz. */
    SYS_CLK_12M = (0x3<<12)
} SYS_CLK;

/**
 * @brief        Set the frequency of the system clock.
 * @note         This is used in UART to adjust the baudrate.
 * @param mode   The frequency of system clock to set.
                Optional value: #SYS_CLK_3M, #SYS_CLK_6M, #SYS_CLK_12M.
 * @return void
 */
#define RT_MCU_SetSystemClock(mode)             \
{                                               \
    MemoryAnd32(SYS_CTL2_REG, ~SYS_CLK_12M);    \
    MemoryOr32(SYS_CTL2_REG, mode);             \
}
/**
 * @brief       This function is to clear the former 7K-byte sram
 * @warning     To avoid possible influence on the stack, this function only clear the former 7K bytes.
                When it is in interrupt, this function is not recommended because some important data is stored
                in the sram for the later state recover from the interrupt.
 * @return      void
 */
#define RT_Sram_Clear()                                     \
{                                                           \
    unsigned long i;                                        \
    for(i=0;i<7168;i++)                                     \
    {                                                       \
      (*(volatile unsigned char *)(0x01000000 + i)) = 0;    \
    }                                                       \
}

#endif	// End of __M2_MCU__
