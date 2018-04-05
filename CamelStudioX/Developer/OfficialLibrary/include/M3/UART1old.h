/*--------------------------------------------------------------------
 * TITLE: m2 Hardware Defines
 * AUTHOR: John & Jack 
 * DATE CREATED: 2013/10/10
 * FILENAME: m2.h
 * PROJECT: m2
 * COPYRIGHT: Small World, Inc.
 * DESCRIPTION:
 *    m2 Hardware Defines
 *
 *    2014-03-17: added sd adc, opo, v2p; sys reg modified
 *    2014-01-11: added sd adc, opo, v2p; sys reg modified
 *    2013-12-18: misc edit
 *    2013-12-15: uart reg back to m1
 *    2012-10-16: modified base on m2 new design
 *    2012-10-10: modified base on s0.h
 *--------------------------------------------------------------------*/
#ifndef __UART1_H__
#define __UART1_H__


/*********** Hardware addesses ***********/
#define PRINT_PORT        0x1f800802
#define UART1_WRITE        0x1f800802
#define UART1_READ         0x1f800800  // snoop read
#define UART1_DATA_RDY     0x1f800805
#define UART1_CTL          0x1f800804
#define UART1_IRQ_ACK      0x1f800803  // clear IRQ when wt
#define UART1_BUSY         0x1f800801
#define uart1_bport         0x1f800801 // uart busy port
#define uart1_wport         0x1f800802
#define uart1_rport         0x1f800800
#define uart1_rdy_port      0x1f800805
#define uart1_aport         0x1f800803 // read ack port
#define WRITE_BUSY         0x0001
#define READ_RDY           0x0001
/*************** UART Setup***************/
#define RT_UART1_Busy()	 (*(volatile unsigned *)UART1_BUSY)
#define RT_UART1_DataRdy() 	(*(volatile unsigned *)uart1_rdy_port)
#define RT_UART1_Read()	(*(volatile unsigned*)uart1_rport)
void RT_UART1_WriteChar(unsigned char value);
void RT_UART1_WriteShort(unsigned short value);
void RT_UART1_WriteLong(unsigned long value);
void RT_UART1_WriteLongLong(long long value);
void RT_UART1_WriteString(unsigned char * string);
void RT_UART1_WriteLongArray(unsigned long * data, unsigned long num);
unsigned char RT_UART1_WaitRead();
/**************** UART End****************/

#endif //__UART1_H__
