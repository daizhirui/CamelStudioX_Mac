/**
 * @brief Functions for UART0, UART1...
 * 
 * @file autoUART.h
 * @author Zhirui Dai
 * @date 2018-05-28
 */

#ifndef __M2_AUTOUART_H__
#define __M2_AUTOUART_H__

#include "stddef.h"

unsigned char __uartPort;           // Port number of auto-UART
char* __uartBuffer;                 // Buffer pointer for UART.
unsigned char __uartBufferSize;     // Size of the buffer for UART.
unsigned char __uartBufferIndex;    // Index of the buffer for UART.
bool __autoUartEnabled;             // Switch to enable the autoUART controller.
char* __uartTerminal;               // Terminal indicating an end of a uart data transmision.
unsigned int __uartTimeout;         // Time to wait for a complete incoming uart data sequense.
bool __autoUartDataReady;           // Indicate if data is ready.
FuncPtr __autoUartUserHandler;      // Handler defined by user to process uart data.

void RT_AUTOUART_Enable(unsigned char port, unsigned char* buffer, unsigned char bufferSize,\
                        char* start, char* terminal, unsigned int timeout, FuncPtr handler);
void RT_AUTOUART_Disabled();

#endif  // End of __M2_AUTOUART_H__