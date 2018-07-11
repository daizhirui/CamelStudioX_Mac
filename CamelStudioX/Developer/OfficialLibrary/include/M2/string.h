/**
* @file string.h
* @author John & Jack
* @date 16 Jun 2018
* @copyright 2018 Zhirui
* @brief String Library for M2
*/
#ifndef __string_h__
#define __string_h__

/*! Keyword size_t. */
#define size_t unsigned int

/**
 * @brief           Search for character c in the first n bytes in string *str
 * @param *str      the pointer to the string
 * @param c         the matching character
 * @param n         the count
 * @return void     when the 1st c is found, turn the pointer to the location; return NULL if not found
 */
void *memchr(const void *str, int c, size_t n);

/**
 * @brief           String compare the first n count in str1 and str2
 * @param str1      the pointer to the 1st string
 * @param str2      the pointer to the 2nd string
 * @param n         the first n count to compare
 * @return int      return <0 if str1 < str2; reutnr =0 if str1=str2; return >0 if str1>str2
 */
int memcmp(const void * str1, const void * str2, size_t n);

/**
 * @brief           Copy n count from src to dest
 * @param *dest     the pointer to the dest string
 * @param *src      the pointer to the src string
 * @param n         the count
 * @return *        the pointer to the dest string
 */
void * memcpy(void * dest, const void * src, size_t n);

/**
 * @brief           Same as memcpy, except that it take care of the overlapped area case
 * @param *dest     the pointer to the dest string
 * @param *src      the pointer to the src string
 * @param n         the count
 * @return *        the pointer to the dest string
 */
void * memmove(void * dest, const void * src, size_t n);

/**
 * @brief           Set n count in *str with character c
 * @param *str      the pointer to the src string
 * @param c         the character to be set
 * @param n         the count
 * @return *        the pointer of the new string
 */
void * memset(void *str, int c, size_t n);

/**
 * @brief           Append *str to the end of *dest
 * @param *dest     the pointer to the dest string
 * @param *src      the string to be appended to *dest
 * @return *        the pointer to the dest string
 */
char * strcat(char *dest, const char * src);

/**
 * @brief           Append n count of *src to *dest
 * @param *dest     the pointer to the dest string
 * @param *src      the pointer to the src string (use to append)
 * @param n         the count
 * @return *        the pointer to the dest string
 */
char * strncat(char *dest, const char * src, size_t n);

/**
 * @brief           Find the location of the 1st occuring of c in *str
 * @param *str      the pointer to the src string
 * @param c         the matching character
 * @return *        the pointer to the first match in *str; NULL if not found
 */
char * strchr(const char *str, int c);

/**
 * @brief           String compare str1 and str2
 * @param s1      the pointer to the 1st string
 * @param s2      the pointer to the 2nd string
 * @return int      return <0 if str1 < str2; reutnr =0 if str1=str2; return >0 if str1>str2
 */
int strcmp(const char * s1, const char * s2);

/**
 * @brief           String compare the first n count in str1 and str2
 * @param s1        the pointer to the 1st string
 * @param s2        the pointer to the 2nd string
 * @param n         the first n count to compare
 * @return int      return <0 if str1 < str2; reutnr =0 if str1=str2; return >0 if str1>str2
 */
int strncmp(const char * s1, const char * s2, size_t n);

/**
 * @brief           Copy string src to dest
 * @param *dest     the pointer to the dest string
 * @param *src      the pointer to the src string
 * @return *        the pointer to the dest string
 */
char * strcpy(char * dest, const char * src);


/**
 * @brief           Copy n count from src to dest
 * @param *dest     the pointer to the dest string
 * @param *src      the pointer to the src string
 * @param n         the count
 * @return *        the pointer to the dest string
 */
char * strncpy(char * dest, const char * src, size_t n);

/**
 * @brief           String length
 * @param *str      the pointer to the string src
 * @return size_t   the string length
 */
size_t strlen(const char * str);

/**
 * @brief           Check if *s2 is part of *s1
 * @param *s1      the pointer to the string to be checked
 * @param *s2      the pointer to the substring
 * @return *       the pointer to the 1st occuring of s2 in s1; NULL if not found
 */
char * strstr(const char *s1, const char * s2);


#endif
