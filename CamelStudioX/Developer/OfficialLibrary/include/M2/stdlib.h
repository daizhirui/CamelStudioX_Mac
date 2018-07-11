/**
* @file stdlib.h
* @author Zhirui Dai
* @date 27 May 2018
* @copyright 2018 Zhirui
* @brief Standard Library for M2
*/

#ifndef __M2_STDLIB_H__
#define __M2_STDLIB_H__

/**
 * @brief Convert a string (decimal) to an integer value.
 *
 * @param str  String (hexadecimal) to be converted to an integer.
 * @return unsigned long  An unsigned long integer.
 */
long atoi(const char* str);

/**
 * @brief Convert a string (hexadecimal) to an integer value.
 *
 * @param str  String (decimal) to be converted to an integer.
 * @return long  A long integer.
 */
unsigned long xtoi(const char* str);

#endif  // End of __M2_STDLIB_H__
