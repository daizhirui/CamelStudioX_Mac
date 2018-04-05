/*--------------------------------------------------------------------
 * TITLE: M2 Hardware Definition
 * AUTHOR: Astro
 * DATE CREATED: 2017/11/2
 * FILENAME: extend_str.h
 * PROJECT: M2Library
 * COPYRIGHT: Camel Microelectronics, Ltd.
 * DESCRIPTION:
 *--------------------------------------------------------------------*/
#ifndef __str_h__
#define __str_h__

#include "str.h"
// redirect some functions to str library
#define putchar(A)      putch(A)
#define getchar(A)      getch(A)
#define getHexNum()     getnum()
#define num2Hex(A)      xtoa(A)
/*  These functions have been definded in str library.
void putchar(unsigned char c);
void puts(unsigned char *string);
unsigned char getchar();
unsigned long getHexNum(void);
*/
/**
 * @brief
 * This function converts a string in decimal style to a long type number.
 * @param void
 * @return unsigned long    the decimal number
 */
unsigned long getDecNum(void);
/**
 * @brief
 * This function converts a number to a string in decimal style.
 * @param num       The number to be converted
 * @return char*    The pointer to the result
 */
char *num2Dec(unsigned long num);
/**
 * @brief
 * This function converts a number to a string in bin style.
 * @param num       The number to be converted
 * @return char*    The pointer to the result
 */
char *num2Bin(unsigned long num);
unsigned int Hex2num(char *string);
unsigned int Dec2num(char *string);
#endif
