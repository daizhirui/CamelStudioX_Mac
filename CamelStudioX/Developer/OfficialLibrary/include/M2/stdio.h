/**
 * @brief Standard Input Outpt Library for M2
 *
 * @file stdio.h
 * @author Zhirui Dai
 * @date 2018-05-26
 */

#ifndef __M2_STDIO_H__
#define __M2_STDIO_H__


/**
 * @brief Print a character to uart0.
 *
 * @param c  Character to be printed.
 */
void putchar(char c);

/**
 * @brief Print a string to uart0.
 *
 * @param string  String to be printed.
 */
void puts(const char* string);

/**
 * @brief Get a character from uart0.
 *
 * @return char  The character got from uart0.
 */
char getchar();

/**
 * @brief Get a decimal integer from uart0.
 *
 * @return long  The integer got from uart0.
 */
long getnum();

/**
 * @brief Get a hexadecimal integer from uart0.
 *
 * @return unsigned long  An unsigned integer got from uart0.
 */
unsigned long getHexNum();

/**
 * @brief Convert an integer to a string.
 *
 * @param value     Value to be converted to a string.
 * @param base      Numerical base used to represent the value as a string, between 2 and 36, where 10 means decimal base, 16 hexadecimal, 8 octal, and 2 binary.
 * @return char*    A pointer to the resulting null-terminated string.
 */
char* itoa(int value, unsigned int base);

/**
 * @brief Convert an integer to a hex string.
 *
 * @param value     Value to be converted to a string.
 * @return char*    A pointer to the resulting null-terminated string.
 */
#define xtoa(value) itoa((value), 16)

/**
 * @brief  Print a formated string to uart0.
 *
 * @param format  pointer to a null-terminated multibyte string specifying how to interpret the data.
 * @param ...   values to be interpreted.
 */
void printf(const char *format, ...);

/**
 * @brief  Generate and store a formated string.
 *
 * @param buf  Buffer to store the string.
 * @param format  pointer to a null-terminated multibyte string specifying how to interpret the data.
 * @param ...  values to be interpreted.
 */
void sprintf(char* buf, const char* format, ...);

#endif
