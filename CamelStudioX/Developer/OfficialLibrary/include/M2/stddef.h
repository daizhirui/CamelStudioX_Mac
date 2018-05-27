/**
 * @brief Standard Definition for M2
 * 
 * @file stdnum.h
 * @author Zhirui Dai
 * @date 2018-05-27
 */

#ifndef __M2_STDDEF_H__
#define __M2_STDDEF_H__

typedef enum bool_t {
    false = 0,
    true = 1
}bool;

#define NULL    (void*)0

typedef signed char     int8_t;
typedef unsigned char   uint8_t;
typedef short           int16_t;
typedef unsigned short  uint16_t;
typedef int             int32_t;
typedef unsigned int    uint32_t;
typedef unsigned int    size_t;

#endif  // End of __M2_STDDEF_H__