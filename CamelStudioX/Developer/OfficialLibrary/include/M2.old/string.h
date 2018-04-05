/*--------------------------------------------------------------------
 * TITLE: string  Defines
 * AUTHOR: Weize 
 * DATE CREATED: 2015/08/11
 * FILENAME: string.h
 * PROJECT: mcu
 * COPYRIGHT: Camel Microelectronics, Ltd.
 * DESCRIPTION:
 *    mcu Hardware Defines
 *
 *
 *    2015-08-20: updated m3a U0, adding 0x7 for compare hard IRQ
 *    2015-08-11: general MCU registers
 *--------------------------------------------------------------------*/
#ifndef __STRING_H__
#define __STRING_H__
#include "stddef.h"

void *memchr(const void *str, int c, size_t n);
int memcmp(const void * str1, const void * str2, size_t n);
void * memcpy(void * dest, const void * src, size_t n);
void * memmove(void * dest, const void * src, size_t n);
void * memset(void *str, int c, size_t n);
char * strcat(char *dest, const char * src);
char * strncat(char *dest, const char * src, size_t n);
char * strchr(const char *str, int c);
int strcmp(const char * str1, const char * str2);
int strncmp(const char * str1, const char * str2, size_t n);
char * strcpy(char * dest, const char * src);
char * strncpy(char * dest, const char * src, size_t n);
size_t strlen(const char * str);
char * strstr(const char *haystack, const char * needle);

#endif //__STRING_H__
