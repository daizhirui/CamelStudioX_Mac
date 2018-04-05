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
#ifndef __UART_H__
#define __UART_H__


/*********** Hardware addesses ***********/
#define PRINT_PORT        0x1f800002
#define UART_WRITE        0x1f800002
#define UART_READ         0x1f800000  // snoop read
#define UART_DATA_RDY     0x1f800005
#define UART_CTL          0x1f800004
#define UART_IRQ_ACK      0x1f800003  // clear IRQ when wt
#define UART_BUSY         0x1f800001
#define uart_bport         0x1f800001 // uart busy port
#define uart_wport         0x1f800002
#define uart_rport         0x1f800000
#define uart_rdy_port      0x1f800005
#define uart_aport         0x1f800003 // read ack port
#define WRITE_BUSY         0x0001
#define READ_RDY           0x0001
/*************** UART Setup***************/
#define RT_UART_Busy()	(*(volatile unsigned *)UART_BUSY)
#define RT_UART_DataRdy() 	(*(volatile unsigned int*)uart_rdy_port)
#define RT_UART_Read()	(*(volatile unsigned*)uart_rport)
void RT_UART_WriteChar(unsigned char value);
void RT_UART_WriteShort(unsigned short value);
void RT_UART_WriteLong(unsigned long value);
void RT_UART_WriteLongLong(long long value);
void RT_UART_WriteString(unsigned char * string);
void RT_UART_WriteLongArray(unsigned long * data, unsigned long num);
unsigned char RT_UART_WaitRead();
/**************** UART End****************/

#endif //__UART_H__
