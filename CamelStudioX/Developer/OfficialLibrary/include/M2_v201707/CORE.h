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
#ifndef __CORE_H__
#define __CORE_H__


void RT_Delay_ms(unsigned long ms);
void RT_Clr_Ram();

#endif //__CORE_H__
