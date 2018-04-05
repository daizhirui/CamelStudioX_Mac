/*--------------------------------------------------------------------
 * TITLE: mcu Hardware Defines
 * AUTHOR: Weize 
 * DATE CREATED: 2015/08/11
 * FILENAME: mcu.h
 * PROJECT: mcu
 * COPYRIGHT: Camel Microelectronics, Ltd.
 * DESCRIPTION:
 *    mcu Hardware Defines
 *
 *
 *    2015-08-20: updated m3a U0, adding 0x7 for compare hard IRQ
 *    2015-08-11: general MCU registers
 *--------------------------------------------------------------------*/
#ifndef __MCU_H__
#define __MCU_H__
/*********** Value Definition ************/
// This part aims to make coding easier.
// A starting level learner just needs to use following key words.
// There are some key words which are used only in a specific module,
// so these key words are defined in a header file of a module.
// For example, there are lots of key words in AFE.h
//>> Switch Value
#define ON 0x1
#define OFF 0x0
//>> Trigger Mode, used in TC0, TC1, TC2, TC4, EXINT
#define RISING 0x1
#define FALLING 0x0
//>> Uart Lin Break Mode
#define NORMALBREAK     0x0
#define EXTREMEBREAK    0x1

/*********** COMMUNICATION ***************/
//same as in "mcu.h", used as communication between studio/mcu and mcu, PAC_XXX is for RS485 type communication
//format: 
//<PAC_HEAD> <SEND_ID> <RECV_ID> <MSG> <PAC_TAIL>
//<MSG> could be:
// 1. <DATA_START> <DATA> <DATA_END>   //this is used to pass the mcu debbuger sending data back to studio, <DATA> is the data from debugger
// 2. <DBG_ACK>   //mcu entered debugger mode acknowledgement
// 3. <WRITE_ACK>  //mcu acknowledges command from sender is received
// 4. <MSG>  //string send by the program on mcu to receiver
#define SYNC_LEN 8
#define PAC_HEAD 0x1
#define PAC_TAIL 0x17
#define MAC_ID 0x1001f3f0
//#define MAC_ID 0x1001D00
#define DBG_ACK 0x5
#define WRITE_ACK 0x6
#define DATA_START 0x2
#define DATA_END 0x3
//LOAD_START indicate code upload start for uart upload using flash space code
#define LOAD_START 0x4
#define LOAD_END   0x7
#define MASTER_ID 0x20
#define STUDIO_ID 0x20
#define BROADCAST_ID 0x20
#define DATA_SIZE 256
/********** END of COMMUNICATION **************/

/*********** Hardware addesses ***********/
#define USER_INT             0x01001FFC   //interrupt is from user code if [0] is 1
#define PC_LOC               0x01001FF8  //RAM address to store current program counter
#define INT_COUNT	     0x01001FF4  //RAM address to store current interrupt depth, number of interrupts

#define UART_DATA_RDY        0x1f800005
#define UART_OSC_REG         0x1f800702  //6:4 adjust the uart freq

#define SYS_CTL2_REG         0x1f800702  
#define SYS_IOCTL_REG        0x1f800704  // 0=in; 1-out (16-bit), was IO config
#define SYS_IRQ_REG          0x1f800707  // SYS INT IRQ read
#define SYS_CTL0_REG         0x1f800700  // sys control digi_off - - - - - dbg inten

#define INT_CTL0_REG         0x1f800500  // EX Int enable control and base
#define INT_CTL1_REG         0x1f800501  // EX Int IRQ bits content read, (m1=03) 
#define INT_CTL2_REG         0x1f800502  // EX Int high enable 
#define INT_CLR_REG          0x1f800503  // EX Int IRQ clear  (m1=01)

// System data
#define SD_CTL_REG           0x1f800c00  // Control Reg (8-bit)
//
// ports def
//

#define uart_bport         0x1f800001 // uart busy port
#define uart_wport         0x1f800002
#define uart_rport         0x1f800000
#define uart_rdy_port      0x1f800005
#define uart_aport         0x1f800003 // read ack port
#define WRITE_BUSY         0x0001
#define READ_RDY           0x0001



//#define MemoryRead8(A) (*(volatile char*)(A))
//#define MemoryRead16(A) (*(volatile unsigned short*)(A))
#define MemoryRead(A) (*(volatile unsigned int*)(A))
#define MemoryRead32(A) (*(volatile unsigned long*)(A))
//#define MemoryWrite8(A,V) *(volatile char*)(A)=(V)
//#define MemoryWrite16(A,V) *(volatile unsigned short*)(A)=(V)
#define MemoryWrite(A,V) *(volatile unsigned int*)(A)=(V)
#define MemoryWrite32(A,V) *(volatile unsigned long*)(A)=(V)

//#define MemoryOr8(A,V) (*(volatile char*)(A)|=(V))
//#define MemoryOr16(A,V) (*(volatile unsigned short*)(A)|=(V))
#define MemoryOr(A,V) (*(volatile unsigned int*)(A)|=(V))
#define MemoryOr32(A,V) (*(volatile unsigned long*)(A)|=(V))

//#define MemoryAnd8(A,V) (*(volatile char*)(A)&=(V))
//#define MemoryAnd16(A,V) (*(volatile unsigned short*)(A)&=(V))
#define MemoryAnd(A,V) (*(volatile unsigned int*)(A)&=(V))
#define MemoryAnd32(A,V) (*(volatile unsigned long*)(A)&=(V))

#define MemoryBitAt(A,V) ((*(volatile unsigned int*)(A)&=(1<<V))>>V)
#define RT_SYS_EnInt() (MemoryOr32(SYS_CTL0_REG, 1))

typedef void (*FuncPtr)(void);
typedef void (*FuncPtr2)(unsigned long, unsigned long);
typedef void (*FuncPtr1)(unsigned long);

#define flashWrite(value, address) {FuncPtr2 funcptr; funcptr = (FuncPtr2)0x2d8; funcptr(value, address);}
#define flashErase(address) {unsigned long addr; FuncPtr1 funcptr; funcptr =  (FuncPtr1)0x30c; addr = (((((address>>16)&0xF)|0x1010)<<16) + (address&0xFFFF)); funcptr(addr);}

#define JumpTo(address) {FuncPtr funcptr; funcptr = (FuncPtr)address; funcptr();}

//extern char __mac_id;
#define getMAC() MemoryRead32(MAC_ID)
#define setMAC(id) flashWrite(id, MAC_ID)

//void setMAC(char id);

#define UART0_INT 	0x1
#define TC0_INT		0x2
#define TC1_INT		0x4
#define TC2_INT		0x8
#define EXT_INT		0x20
#define WDT_INT		0x40
#define UART1_INT	0x100
#define SPI_INT		0x400
#define RT_SYSINT_Flag()  MemoryRead(SYS_IRQ_REG)
#define RT_SYSINT_En()  MemoryWrite(SYS_CRL0_REG, 0x1)
#define RT_SYSINT_On(A) (MemoryRead(SYS_IRQ_REG)&A)
#endif //__MCU_H__

