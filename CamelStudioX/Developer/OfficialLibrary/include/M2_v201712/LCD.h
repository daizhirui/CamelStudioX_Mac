/*--------------------------------------------------------------------
 * TITLE: m2 Hardware Defines
 * AUTHOR: John & Jack 
 * DATE CREATED: 2013/10/10
 * FILENAME: LCD.h
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
 * NOTE:
 * 		This LCD library is almost full-copied from old version. It hasn't
 * been checked again.	-- Astro, 2017/11/3
 *--------------------------------------------------------------------*/
#ifndef __LCD_H__
#define __LCD_H__


/*********** Hardware addesses ***********/
#define LCD_CTL0_REG      0x1f800300  // LCD control
#define LCD_RAM_REG       0x1f800380  // LCD ram starting (80-8C)
#define LCD_RAM_LINE0     0x1f800380  // LCD ram line0 (80-8C)
#define LCD_RAM_LINE1     0x1f800384  // LCD ram line1 (80-8C)
#define LCD_RAM_LINE2     0x1f800388  // LCD ram line2 (80-8C)
#define LCD_RAM_LINE3     0x1f80038c  // LCD ram line3 (80-8C)

/*********** LCD Special Sign  ***********/
#define LCD_M2  0,0
#define kPa  0,2
#define DP1  0,2
#define mmHg 0,4
#define DN   0,6
#define UP	 4,6
#define LB	 8,6
#define M1	 12,6
#define L3	 0,7
#define L4	 4,7
#define L5	 8,7
#define L6	 12,7
#define L2	 0,8
#define L1	 4,8
#define IHB	 8,8
#define AVG	 12,8
#define elAGD 12,10
#define DP2	 12,12
#define E13	 12,14
#define AM	 12,15
#define C9	 8,15
#define B9	 4,15
#define nineAGDE 0,15
#define HT	 12,17
#define colon 12,19
#define PM	 12,21
#define No	 12,22
#define HR	 12,24
#define C13	 0,26
#define M_2  12,28
#define B13	 12,30

#define segment 0x01000600   //0604 0608 060c
#define digit 0x01000610     //0610 0611 0612 
#define days  0x01000613     //0613 0614 0615 0616 0617  ***  061e
#define LCDCode1 0x01000620  //0620 0624 0628 062c
#define LCDCode2 0x01000630  //0630 0634 0638 063c
#define LCDCode3 0x01000640  //0640 0644 0648 064c
//==============================variable
#define flaga     0x0100006f

//======================================
#define subsecond 0x01000650
#define second    0x01000654
#define minuteg   0x01000658
#define hourg     0x01000678
#define dayg      0x01000660
#define monthg    0x01000664
#define SetMode   (*(volatile unsigned long *)(0x01000664))      
/*********** End of LCD Special Sign******/

/*********** LCD dis app******************/

void RT_LCD_Initialize();
void RT_LCD_ShowAll();
void RT_LCD_DispOn();
void RT_LCD_DisHiPressure(unsigned int b);
void RT_LCD_DisLoPressure(unsigned int b);
void RT_LCD_DisHeartRate(unsigned int b);
void RT_LCD_DisDate(unsigned int month,unsigned int day);
void RT_LCD_DisTime(unsigned int hour,unsigned int minute);
void RT_LCD_DisSign(unsigned int x,unsigned int y);
void RT_LCD_ClearSign(unsigned int x,unsigned int y);
void RT_LCD_GetSegCode1(unsigned int b);
void RT_LCD_GetSegCode2(unsigned int b);
void RT_LCD_GetSegCode3(unsigned int b);
void RT_LCD_ExtractDigit(unsigned int b);
void RT_LCD_BlinkSign(unsigned int x,unsigned int y);
void RT_LCD_BlinkMinute();
void RT_LCD_BlinkHour();
void RT_LCD_BlinkDay();
void RT_LCD_BlinkMonth();
void RT_LCD_delay(unsigned int a);

/*********** LCD disp app end ***********/

#endif //__LCD_H__
