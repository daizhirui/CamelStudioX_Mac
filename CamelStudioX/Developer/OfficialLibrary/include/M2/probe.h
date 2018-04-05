/*--------------------------------------------------------------------
 * TITLE: M2 Hardware Definition
 * AUTHOR: John & Jack 
 * DATE CREATED: 2017/11/4
 * FILENAME: probe_def.h
 * PROJECT: M2Library
 * COPYRIGHT: Camel Microelectronics, Ltd.
 * DESCRIPTION:
 * 		This file is copied from V20170715 directly.
 *--------------------------------------------------------------------*/
typedef unsigned char BYTE;     // these save typing
typedef unsigned short WORD;

extern BYTE connected;         // usb is connected to host or not
void initialize_MAX(void);
void probe_setup();
void CMprobe(unsigned char addr, unsigned long val);


