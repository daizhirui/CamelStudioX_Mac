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
 *    2015-12-12 485 communication slave
 *--------------------------------------------------------------------*/
#ifndef __COMSLA_H__
#define __COMSLA_H__

void CommSend(long port, unsigned char * msg);
unsigned int CommRecv(long port, unsigned char * msg);
unsigned int CommRecvReady(long port);


#endif //__COMSLA_H__
