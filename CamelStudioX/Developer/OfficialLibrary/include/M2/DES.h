/**
* @file DES.h
* @author Zhirui Dai
* @date 14 Jun 2018
* @copyright 2018 Zhirui
* @brief Data Encryption Standard Library for M2
*/

#ifndef __DES_H__
#define __DES_H__

#include <stdint.h>

/**
* @brief Keyword DES_ENCRYPT_MODE
*/
#define DES_ENCRYPT_MODE    0x0

/**
* @brief Keyword DES_DECRYPT_MODE
*/
#define DES_DECRYPT_MODE    0x1

/**
 * @brief Type for storing key to be used by DES Algorithm.
 */
typedef union {
    /**
     * @brief  64-bit key.
     */
    uint64_t key;
    /**
     * @brief  two 32-bit key. apart[1] is high 32 bits, apart[0] is low 32 bits.
     */
    uint32_t apart[2];
} DES_Key;

/**
 * @brief Type for storing data to be processed by DES Algorithm.
 */
typedef union {
    /**
     * @brief  64-bit key.
     */
    uint64_t data;
    /**
     * @brief  two 32-bit keys. apart[1] is high 32 bits, apart[0] is low 32 bits.
     */
    uint32_t apart[2];
    /**
     * @brief  eight 8-bit keys.
     */
    uint8_t  bytes[8];
} MessageData;

DES_Key* DES_generateSubKeys(const DES_Key originalKey);
MessageData DES_process(MessageData originalData, DES_Key* subKeys, uint8_t mode);
MessageData DES(MessageData originalData, DES_Key originalKey, uint8_t mode);

#endif
