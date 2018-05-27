/*--------------------------------------------------------------------
 * TITLE: str  Defines
 * AUTHOR: Weize 
 * DATE CREATED: 2015/08/11
 * FILENAME: str.h
 * PROJECT: M2Library
 * COPYRIGHT: Camel Microelectronics, Ltd.
 * DESCRIPTION:
 *    mcu Hardware Defines
 *
 *    2017-11-04: copy from V20170715 directly
 *    2015-08-20: updated m3a U0, adding 0x7 for compare hard IRQ
 *    2015-08-11: general MCU registers
 *--------------------------------------------------------------------*/
#ifndef __STR_H__
#define __STR_H__
void putc_uart(unsigned char c);
unsigned char read_uart();
int putch(unsigned char value);
int puts(const char *string);
char * cm_strcat(char * des, char * source);
char * charcat(char * des, char ch);
char *xtoa(unsigned long num);
int kbhit(void);
unsigned char getch(void);
unsigned long getnum(void);
void CommSend(char rport, unsigned char * msg);
void CommSendHead(char rport);
void CommSendHead2(char rport, char sport);
void CommSendTail();
unsigned int CommRecv(char * port, char data[]);
#if 1
unsigned int CommRecvHead(char * port);
#else
unsigned int CommRecvHead(char * port, char msg[], int * index);
#endif
unsigned int CommRecvTail();
void sendData2Studio(char * msg, unsigned long state);
#endif //__STR_H__
