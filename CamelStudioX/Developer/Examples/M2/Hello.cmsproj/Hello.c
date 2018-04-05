/**********************************************************
/**
* @file	hello.c
*
* This file contains an example to do loop printing
* a string of "Hello!"
*
*
* MODIFICATION HISTORY:
*
* Ver   Who		Date      Changes
* ---   ------	--------  --------------------------------
* 1.0	yuchun  02/22/18  First release
*
***********************************************************/

/*********************************************************/
/**
* This function is the user interrupt handler.
*
*
**********************************************************/
#include "str.h"
void user_interrupt(void){}

/*********************************************************/
/**
* This function is the main function
*
*
**********************************************************/

int main(){
	
	while(1){
		puts("Hello!\n");
	}
	
}

