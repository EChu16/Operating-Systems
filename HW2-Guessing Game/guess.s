#  Homework 2
#  Guessing Game Assembly Code 512 bits
#  CS 3224
#  Erich Chu

.code16         # Use 16-bit assembly
.globl start    # This tells the linker where we want to start executing

start: 
    movb $0x00,%ah      	# 0x00 - set video mode
    movb $0x03,%al      	# 0x03 - 80x25 text mode
    int $0x10           	# call into the BIOS

gen_num:								# generates random number from 0-9
    mov $0x00, %al			# selects seconds register
    out %al, $0x70			# writes register to RTC
    in $0x71, %al 			# reads seconds from RTC
    mov $0x0A, %bl			# stores 10 into %bl
    idiv %bl						# divides al by bl for remainder (0-9)
    mov %ah, %al 				# moves remainder to %al
    mov $0x30, %bl			# moves 48 to %bl
    add %bl, %al				# converts int to ASCII value
    movb %al, %dl				# stores value into %dl

set_question:							# sets question
		movw $question, %si 	# sets question message to %si
		jmp print_question		# jumps to print function
		
print_question: 				# prints question
    lodsb           		# loads a single byte from (%si) into %al and increments %si
    testb %al,%al   		# checks to see if the byte is 0
    jz chk_input    		# if so, jump out (jz jumps if ZF in EFLAGS is set)
    movb $0x0E,%ah  		# 0x0E is the BIOS code to print the single character
    int $0x10       		# call into the BIOS using a software interrupt
    jmp print_question  # go back to the start of the loop

chk_input:									# checks user input
		mov $0x00, %ah					# sets ah to 0 for user input
		int $0x16								# waits for user input
		movb $0x0E,%ah					# 0x0E is the BIOS code to print the single character
		int $0x10     		  		# call into the BIOS using a software interrupt
		movw $correctmsg, %si 	# sets winning message to %si
		cmp %al, %dl 						# compares user input to randomized number
		jz game_over 						# if true, user wins
		movw $wrongmsg, %si 		# else set try again message to %si
		jmp try_again 					# print out try again message

try_again:							# incorrect guess
		lodsb           		# loads a single byte from (%si) into %al and increments %si
    testb %al,%al   		# checks to see if the byte is 0
    jz set_question  		# if so, jump out (jz jumps if ZF in EFLAGS is set)
    movb $0x0E,%ah  		# 0x0E is the BIOS code to print the single character
    int $0x10      			# call into the BIOS using a software interrupt
    jmp try_again  			# go back to the start of the loop

game_over:					# correct guess
		lodsb           # loads a single byte from (%si) into %al and increments %si
    testb %al,%al   # checks to see if the byte is 0
    jz done    			# if so, jump out (jz jumps if ZF in EFLAGS is set)
    movb $0x0E,%ah  # 0x0E is the BIOS code to print the single character
    int $0x10       # call into the BIOS using a software interrupt
    jmp game_over   # go back to the start of the loop

done: 							# done
    jmp done        # loop forever

#Strings for guessing game
question:    .string    "\rWhat number am I thinking of (0-9)? "
correctmsg:    .string    "\r\nRight! Congratulations.\n"
wrongmsg:    .string    "\r\nWrong. Try again.\n"

# This pads out the rest of the boot sector and then puts
# the magic 0x55AA that the BIOS expects at the end, making sure
# we end up with 512 bytes in total.
# 
# The somewhat cryptic "(. - start)" means "the current address
# minus the start of code", i.e. the size of the code we've written
# so far. So this will insert as many zeroes as are needed to make
# the boot sector 510 bytes log, and 

.fill 510 - (. - start), 1, 0
.byte 0x55
.byte 0xAA
