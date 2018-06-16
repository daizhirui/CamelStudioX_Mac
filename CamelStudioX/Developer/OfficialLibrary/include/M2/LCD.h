/**
* @file LCD.h
* @author John & Jack, Zhirui Dai
* @date 16 Jun 2018
* @copyright 2018 Zhirui
* @brief LCD Library for M2
*/
#ifndef __LCD_H__
#define __LCD_H__

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
void RT_LCD_DisSign(unsigned long x, unsigned long y);
void RT_LCD_ClearSign(unsigned long x,unsigned long y);
void RT_LCD_GetSegCode1(unsigned int b);
void RT_LCD_GetSegCode2(unsigned int b);
void RT_LCD_GetSegCode3(unsigned int b);
void RT_LCD_ExtractDigit(unsigned int b);
void RT_LCD_BlinkSign(unsigned long x,unsigned long y);
void RT_LCD_BlinkMinute();
void RT_LCD_BlinkHour();
void RT_LCD_BlinkDay();
void RT_LCD_BlinkMonth();
void RT_LCD_delay(unsigned int a);

/*********** LCD disp app end ***********/

#endif //__LCD_H__
