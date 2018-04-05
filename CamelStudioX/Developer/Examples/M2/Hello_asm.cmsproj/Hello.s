##################################################################
# TITLE: simple Hello test to uart 2
# AUTHOR: John & Matt
# DATE CREATED: 2011-11-12
# FILENAME: hiuart2.s
# PROJECT: s0/mp2
# COPYRIGHT: Camel Microelectronics, Inc (C) 2009-2019.
# DESCRIPTION:
#
#    print "Hello, World!" to uart, with repeat, no $drom
#    this is to test Uart initial
#
##################################################################
	.text
	   .align	2
	   .globl	main
	   .ent	main
main:
		.set noreorder
		.set noat

  nop
  nop
  li   $20,0x1f800002 		 	# uart write port

B1_:
  nop                  		 	#delay slot
  ori   $4,$0,'H'  	  		        #H
  jal   uart_write_
  nop
  ori   $4,$0,'e'   		 	#e
  jal   uart_write_
  nop
  ori   $4,$0,'l'  		  	    #l
  jal   uart_write_
  nop
  ori   $4,$0,'l'  		     	#l
  jal   uart_write_
  nop
  ori   $4,$0,'o' 		    	#o
  jal   uart_write_
  nop
  ori   $4,$0,'!'  		     	# !
  jal   uart_write_
  nop
  ori   $4,$0,'\r'      		#<\R> letter
  jal   uart_write_
  nop
  ori   $4,$0,'\n'     	  		#<CR> letter
  jal   uart_write_
  nop

j B1_
  nop

   ######################################
   # END, the next step will jump to end
   ######################################

$DONE:
   j progend
   nop
######################################
# This is the uart write sub
######################################

uart_write_:
   li   $20,0x1f800000  # uart starting port 01 = busy port, 02 				= write port
   li   $5,0            # test uart port status  0  no busy 1 					busy
   nop                  # delay slot
uwait_:
   lw   $2,1($20)       # uart port address 01
   or   $2,$5,$2
   bgtz $2, uwait_      # uart port 1 = busy
   nop
   sb   $4,2($20)       # uart wt port = 02; parameter @ $4
   j    $31             # return
   nop
nop
nop


######################################
# This is the end section
# all user program should jump to here
######################################
progend:             	# end of program
   nop
   ori   $4,$0,'E'
   jal   uart_write_   	#E
   nop
   ori   $4,$0,'n'
   jal   uart_write_   	#n
   nop
   ori   $4,$0,'d'
   jal   uart_write_   	#d
   nop

   ######################################
   # END, the next step will jump to end
   ######################################
  .set reorder
 .end    main
