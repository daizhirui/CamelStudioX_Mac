/*--------------------------------------------------------------------
 * TITLE: 		Flash Handle Functions
 * AUTHOR: 		mas/lilb 
 * FILENAME: 	flash.h
 * PROJECT: 	m2-sejoy
 * COPYRIGHT: 	SHRIME, Inc.
 * DESCRIPTION:
 *    2016-07-14	-	mas/lilb	-	started
 *    2016-07-15	-	mas/lilb	-	parameter/functions define
 *
 *--------------------------------------------------------------------*/
 
#ifndef FLASH_H
#define FLASH_H

#define FLASH_B0_START   		0x1001E400								// Block Base Address
#define FLASH_B1_START   		0x1001F000
#define FLASH_B2_START		0x1001D800				
#define FLASH_B3_START		0x1001CC00
#define FLASH_NO_BLOCK		0x1FFFFFFF

#define FLASH_B0_DATA_START 	FLASH_B0_START+8						// Block Data Address
#define FLASH_B1_DATA_START 	FLASH_B1_START+8

#define Block0	0x1001E400												// Block Number
#define Block1 0x1001F000
#define Block2	0x1001D800								
#define Block3	0x1001CC00

#define BlockErasePass		0x01										// Block Erase Value
#define BlockNumError		0xF1
#define BlockEraseError	0xF2

#define BlockIniPass		0x01										// Block Initiallize Value
#define BlockIniError		0xF3

#define BlockEnPass		0x01										// Block Enable
#define BlockEnFail		0xF4
#define BlockDisPass		0x01										// Block Disable
#define BlockDisFail		0xF5
#define InitState			0x0
#define ValidState         0x1
#define DataFull			0x2
#define Forbidden			0x3

#define DataLable			0x00
#define DataCantFind       0x00
#define DataFind			0x1
#define BlockCantfind		0xF6

#define WriteSucc 			0x1
#define CantWrite			0x2
#define AmStart			0
#define AmEnd				12
#define PmStart			12
#define PmEnd				24

#define DBG_MODE			0x00										// Normal use or Debug use
#define DBG_MODE_PASS		0x01
#define NO_DBG_MODE		0xD0
#define No_Error_Line		0xD1

extern unsigned char RT_FlashBlockEnEx(unsigned long BNum);				// Flash Block Enable
extern unsigned char RT_FlashBlockDisEx(unsigned long BNum);			// Flash Block Disable

extern unsigned char RT_FlashBlockInitEx(unsigned long BNum);			// Flash Block Initiallize,only m2
extern unsigned char RT_FlashBlockEraseEx(unsigned long BNum);			// Flash Block Erase, only m2

extern unsigned char RT_FlashBlockDbgTypeEx(unsigned long BNum);
extern unsigned long RT_FlashBlockDbgLineEx(unsigned long BNum);
extern unsigned char RT_FlashBlockStateJudgeEx(unsigned long block_addr);
extern void RT_FlashBlockLineReadEx(unsigned long block_addr, unsigned char bias_addr);
extern int RT_FlashBlockLineWriteEx(unsigned long block_addr, unsigned char bias_addr, unsigned long word1, unsigned long word2, unsigned long word3);
extern int RT_FlashBlockDataLookUpEx(unsigned long block_addr, unsigned char data_num);
extern int RT_FlashBlockRoomCheckEx(unsigned long block_addr);
extern int RT_FlashBlockWriteEx(unsigned long block_addr, unsigned long word1, unsigned long word2, unsigned long word3);
extern int RT_FlashBlockCheckEx();
extern void RT_FlashBlockTransDataEx();

#endif
