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
#define PAC_HEAD 0x29
#define PAC_TAIL 0x17
#define MAC_ID 0x1001f3f0
//#define MAC_ID 0x1001D00
#define DBG_ACK 0x5
#define WRITE_ACK 0x6
#define DATA_START 0x2
#define DATA_END 0x3
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



#define MemoryRead8(A) (*(volatile char*)(A))
#define MemoryRead16(A) (*(volatile unsigned short*)(A))
#define MemoryRead(A) (*(volatile unsigned int*)(A))
#define MemoryRead32(A) (*(volatile unsigned long*)(A))
#define MemoryWrite8(A,V) *(volatile char*)(A)=(V)
#define MemoryWrite16(A,V) *(volatile unsigned short*)(A)=(V)
#define MemoryWrite(A,V) *(volatile unsigned int*)(A)=(V)
#define MemoryWrite32(A,V) *(volatile unsigned long*)(A)=(V)

#define MemoryOr8(A,V) (*(volatile char*)(A)|=(V))
#define MemoryOr16(A,V) (*(volatile unsigned short*)(A)|=(V))
#define MemoryOr(A,V) (*(volatile unsigned int*)(A)|=(V))
#define MemoryOr32(A,V) (*(volatile unsigned long*)(A)|=(V))

#define MemoryAnd8(A,V) (*(volatile char*)(A)&=(V))
#define MemoryAnd16(A,V) (*(volatile unsigned short*)(A)&=(V))
#define MemoryAnd(A,V) (*(volatile unsigned int*)(A)&=(V))
#define MemoryAnd32(A,V) (*(volatile unsigned long*)(A)&=(V))

#define MemoryBitAt(A,V) ((*(volatile unsigned int*)(A)&=(1<<V))>>V)

extern char __mac_id;
char getMAC();
void setMAC(char id);

// set interrupt enable
#define	RT_SYS_InterruptEn()	MemoryOr32(SYS_CTL0_REG, 0x1)

#endif //__MCU_H__

