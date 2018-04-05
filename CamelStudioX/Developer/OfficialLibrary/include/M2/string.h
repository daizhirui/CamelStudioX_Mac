/*--------------------------------------------------------------------
 * TITLE: M2 Hardware Definition
 * AUTHOR: Astro
 * DATE CREATED: 2017/11/1
 * FILENAME: string.h
 * PROJECT: M2Library
 * COPYRIGHT: Camel Microelectronics, Ltd.
 * DESCRIPTION:
 * NOTE:
 *      This library has been checked. --Astro, 2017/11/3
 *--------------------------------------------------------------------*/
#ifndef __string_h__
#define __string_h__

#define size_t unsigned int
void *memchr(const void *str, int c, size_t n);
int memcmp(const void * str1, const void * str2, size_t n);
void * memcpy(void * dest, const void * src, size_t n);
void * memmove(void * dest, const void * src, size_t n);
void * memset(void *str, int c, size_t n);
char * strcat(char *dest, const char * src);
char * strncat(char *dest, const char * src, size_t n);
char * strchr(const char *str, int c);
int strcmp(const char * s1, const char * s2);
int strncmp(const char * s1, const char * s2, size_t n);
char * strcpy(char * dest, const char * src);
char * strncpy(char * dest, const char * src, size_t n);
size_t strlen(const char * str);
char * strstr(const char *s1, const char * s2);
int memcmp(const void * str1, const void * str2, size_t n);
#endif
