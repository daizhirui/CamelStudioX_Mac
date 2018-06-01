/**
 * @brief Standard Input Outpt Library for M2
 *
 * @file stdio.h
 * @author Zhirui Dai
 * @date 2018-05-26
 */

#ifndef __M2_STDIO_H__
#define __M2_STDIO_H__

void putchar(char c);
void puts(const char* string);
char getchar();
long getnum();
unsigned long getHexNum();
char* itoa(int value, unsigned int base);
#define xtoa(A) itoa(A, 16)
void printf(const char *format, ...);
void sprintf(char* buf, const char* format, ...);

#endif
