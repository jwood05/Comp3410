#################
# COMP 3410     #
# Final Project #
# MIPS Mansion  #
# Version 1.0.0 #
#################

# main/driver starts here
 .globl main
main:

# data segment
.data
buffer: .space 1200 # used to store room name, room description, and room input values
filepath: .asciiz "/home/jonathan/Desktop/Final Project/rooms/" # hard coded rooms directory
room: .asciiz "00/" # temporary storage point for current room number
readFile: .asciiz "n" # temporary storage point for current file to be read
filename: .space 70 # used to store the full file path/name for i/o
validInput: .space 32 # used to store valid input strings
userInput: .space 32 # used to store user input (surprise!)
nameHolder: .asciiz "n" # "name" # designates the name file
descHolder: .asciiz "d" # designates the description file
inputHolder: .asciiz "i" # designates the input file
delimiter: .asciiz "*" # used to mark the end of a valid input
pickup: .asciiz "You find a key!\n" # used in special inputs when a key is found
unlock: .asciiz "You use your key to unlock the door. The key breaks off in the door\nand, as you pass through, the door slams shut behind you, locked."
die: .asciiz "You see the last light from the candle flash off of the eye of the\nbeast that has been hunting you. The beast growls softly..."
live: .asciiz "You have somehow survived this nightmare, but who knows what lurks\naround the next corner...?"
special1: .asciiz "k" # if this special input result is received, you've picked up a key
special2: .asciiz "u" # if this special input result is received, you've used a key
special3: .asciiz "l" # if this special input result is received, you've lived through the nightmare
false: .byte 0 # just a false byte for verification
alreadyHave: .asciiz "\nYou've already picked up this key!\n" # message if a key is picked back up
doNotHave: .asciiz "\nYou need a key to do this!\n" # message if a key is needed
candleRemaining1: .asciiz "\nYou only have "
candleRemaining2: .asciiz " minutes left to escape...\n"
correctMove: .asciiz "\nThe candle burns a little more as you press forward.\n"
incorrectMove: .asciiz "\nYou can't do that. You're wasting time! The candle burns more\nas you try in vain...\n"

# text segment
.text

####################################################
# Reserved registers:
# $s0 = file descriptor
# $s1 = filename
# $s2 = filepath
# $s3 = room
# $s4 = readFile
# $s5 = new room number
# $s6 = key boolean
# $s7 = candle counter
####################################################

####################################################
# general room procedure
# configurable by room files: name, description, input
####################################################
li $s7, 31 # initial candle value load

BuildRoom:
jal GetName # get name for room
jal GetDescription # get description for room
jal GetInput # get input for room
jal ClearInputs # clear out previous rooms valid inputs
j PlayRoom # after the room is built, it is played

GetName:
move $t7, $ra # saving the return address so we can get back
jal ClearBuffer # clear the buffer so there is no data overlap
lb $t0, nameHolder # loading the file name for the 'name' file
la $t1, readFile # loading the address for the file name
sb $t0, ($t1) # storing the file name in the file name address
jal GetFilename # concatenate the file path/name
jal FileOpen # read the file into buffer space

# print room name
li $v0, 4 # get ready to print text
la $a0, buffer # load the address of the buffer space
syscall # print that buffer!
jal ClearBuffer # clear the buffer before the next file
jr $t7 # Get back!

# get description text
GetDescription:
move $t7, $ra # saving the return address so we can get back
lb $t0, descHolder # loading the file name for the 'description' file
la $t1, readFile # loading the address for the file name
sb $t0, ($t1) # storing the file name in the file name address
jal GetFilename # concatenate the file path/name
jal FileOpen # read the file into buffer space

# print room description
li $v0, 4 # get ready to print text
la $a0, buffer # load the address of the buffer space
syscall # print that buffer!
jal ClearBuffer # clear the buffer before the next file
jr $t7 # Get back!

# get input/result file and hold in buffer
GetInput:
move $t7, $ra # saving the return address so we can get back
lb $t0, inputHolder # loading the file name for the 'description' file
la $t1, readFile # loading the address for the file name
sb $t0, ($t1) # storing the file name in the file name address
jal GetFilename # concatenate the file path/name
jal FileOpen # read the file into buffer space
jr $t7 # Get back to where you once belonged!

# the actual playing part
PlayRoom:
# get room input
li $v0, 8 # open up for input
la $a0, userInput # going to read the input into the 'input' memory address
syscall # user input is now stored at 'userInput'

# validate room input (include special cases)
j ValidateInput

####################################################
# procedure to clear the buffer in between string
# loads/unloads (prevents data overlap)
####################################################
ClearBuffer:
la $t1, buffer # load the address of the buffer for clearing
li $t0, 0x00000000 # hex 0 (null), for clearing
addi $t2, $t1, 1196 # buffer is 1200 bytes long. Our null is a word. Do the math.
j Clear # clear it out!

Clear:
sw $t0, 0($t1) # store the null word in the address
addi $t1, $t1, 4 # move up a word in the space
ble $t1, $t2, Clear # if we're not past the end of the space, clear the new address
jr $ra # otherwise, get outta heah!

ClearInputs:
la $t1, validInput # load the address of the valid input string
li $t0, 0x00000000 # hex 0 (null), for clearing
addi $t2, $t1, 28 # valid input space is 32 bytes long. Our null is a word. Seriously, do the math.
j Clear # clear it out!

####################################################
# procedure to check input, provide feedback
####################################################
ValidateInput:
la $t0, validInput # valid input strings will be stored at $t0
la $t1, buffer # valid input string is now reachable at $t1
lb $t2, delimiter # setting $t2 to '*' to check end of input
j buildValid

buildValid:
# loop through, pulling out valid input bytes one by one, then comparing
lb $t3, ($t1) # load current byte from valid inputs into $t2
beq $t3, $t2, CheckInput # end of current input string, compare user input
beqz $t3, InvalidInput # if it reaches null, it's an invalid input
sb $t3, ($t0) # store the current byte and move on
addi $t0, $t0, 1 # increase address to store next byte of string
addi $t1, $t1, 1 # increase address to read next byte of buffer
j buildValid # loop

CheckInput:
# going to compare 'input' address to user input
li $t4, 0x0A # load hex value of new line (dec: 13) into $t4
sb $t4, ($t0) # store cr value as next byte in validInput
la $t4, userInput # current user input
la $t0, validInput # current valid input string
j InputChecker

InputChecker:
lb $t6, ($t4) # load current byte of user input
lb $t7, ($t0) # load current byte of valid input string
bne $t6, $t7, Invalidated # if bytes are not equal, call invalidated
beqz $t7, ValidInput # if bytes are equal and one of them is null, this is valid
# otherwise, increment and compare
addi $t4, $t4, 1 # move to next byte of user input
addi $t0, $t0, 1 # move to next byte of valid input string
j InputChecker

Invalidated:
addi $t1, $t1, 4 # move to beginning of next valid input string
la $t0, validInput # load addres for storing valid input string
j buildValid # build next valid input string

ValidInput:
# set $s5 to new room
la $s5, room # getting ready to write new room
addi $t1, $t1, 1 #moving to first character of new room number
lb $t4, ($t1) # loading first byte of new room number
subi $s7, $s7, 1 # decrement the candle by 1 'minute'
jal CheckSpecial # make sure that the input return value isn't a special case
sb $t4, ($s5) # storing first byte of new room number
addi $t1, $t1, 1 # moving to second character of new room number
addi $s5, $s5, 1 # moving to second room number character
lb $t4, ($t1) # loading second byte of new room number
sb $t4, ($s5) # storing second byte of new room number
li $v0, 4 # get ready to print some text
la $a0, correctMove # load address for the 'correct move' feedback
syscall # print it
j DispCandle # display the candle length

InvalidInput:
li $v0, 4 # get ready to print some text
la $a0, incorrectMove # load address for the 'incorrect move' feedback
syscall # print it
subi $s7, $s7, 2 # decrement the candle by 2 'minutes'
j DispCandle # display the candle length

DispCandle:
ble $s7, $0, Die # if the candle length is <= 0, you die
li $v0, 4 # get ready to print some text
la $a0, candleRemaining1 # load address for the intro to the candle text
syscall # print it
li $v0, 1 # get ready to print a number
addi $a0, $s7, 0 # load up the current candle length
syscall # print it
li $v0, 4 # get ready to print some text
la $a0, candleRemaining2 # load address for the conclusion of the candle text
syscall # print it
j BuildRoom # go build the room, knucklehead...

####################################################
# procedures to handle special input results
####################################################
# checks for special input results and handles them appropriately
CheckSpecial:
lb $t2, special1 # load byte to compare and see if a key is picked up
beq $t2, $t4, GetKey # if the return value byte = k, you get a key!
lb $t2, special2 # load byte to compare and see if a key is used
beq $t2, $t4, UseKey # if the return value byte = u, you need a key!
lb $t2, special3 # load byte to compare and see if the game is won
beq $t2, $t4, Live # if the return value byte = l, you survive!
jr $ra # no special input results; continue with the room number

# when an input result means you pick up a key
GetKey:
lb $t2, false # load the false byte up
bne $s6, $t2, HaveKey # if you have a key, you can't pick up a key
li $v0, 4 # get ready to print some text
la $a0, pickup # load the address for the key picked up feedback
syscall # print it
li $s6, 1 # key = true
addi $t1, $t1, 1 #moving to first character of new room number
lb $t4, ($t1) # loading first byte of new room number
jr $ra


# if you already have a key, you can't pick another one up
HaveKey:
li $v0, 4 # get ready to print a string
la $a0, alreadyHave # you already have the key, knucklehead!
syscall # print it
j DispCandle # go build the room

# when an input requires that you use a key
UseKey:
lb $t2, false # load the false byte
beq $s6, $t2, NoKey # if you don't have a key, you can't use it
li $v0, 4 # get ready to print some text
la $a0, unlock # load the address of the "you did it!" text
syscall # go print it
li $s6, 0 # get rid of the key

# changing room number
addi $t1, $t1, 1 # moving to first character of new room number
lb $t4, ($t1) # loading first byte of new room number
jr $ra

# check whether a key is in inventory
NoKey:
li $v0, 4 # get ready to print some text
la $a0, doNotHave # load the address of the "you need a key, dolt!" text
syscall # print it
j DispCandle # go build the room

# when your input wins the game
Live:
li $v0, 4 # get ready to print some text
la $a0, live # load the address of the "you survived!" text
syscall # print it
j End # Game over, man! Game over!

# when your candlie hits 0 (not necessarily special input)
Die:
li $v0, 4 # get ready to print some text
la $a0, die # load the "you dead, mofo!" text
syscall # print it
j End # Game over, man!, Game over!

####################################################
# procedure to concatenate filepath, room, and
# specified file to open for room configuration
####################################################
GetFilename:
la $s1, filename # will be writing bytes to filename
la $s2, filepath # loading generic filepath into $s2
la $s3, room # loading room number into $s3
la $s4, readFile # loading name of file to read into $s4
j ConcFilepath # start concatenating the file path

ConcFilepath:  
lb $t0, ($s2) # get character at address  
beqz $t0, ConcRoomNum # if the whole path is loaded in, get the room number, too
sb $t0, ($s1) # else store current character in the buffer  
addi $s2, $s2, 1 # filepath pointer points a position forward  
addi $s1, $s1, 1 # same for filename pointer  
j ConcFilepath # loop

# I hate code repetition, but this makes the app
# more flexible
ConcRoomNum:
lb $t0, ($s3) # get character at address
beqz $t0, ConcFile # if the whole room number is loaded in, get the room number, too
sb $t0, ($s1) # else, store the current character in the buffer
addi $s3, $s3, 1 # room pointer points a position forward
addi $s1, $s1, 1 # same for filename pointer
j ConcRoomNum # loop

ConcFile:
lb $t0, ($s4) # get character at address
beqz $t0, ReturnFile # if the whole file name is loaded in, return it
sb $t0, ($s1) # else, store the current character in the buffer
addi $s4, $s4, 1 # name pointer points a position forward
addi $s1, $s1, 1 # same for filename pointer
j ConcFile # loop

ReturnFile:
jr $ra # filepath is all written out, so return

####################################################
# procedure to open file specified in filename space
####################################################
FileOpen:
# open the file for reading
li $v0, 13 # system call code for opening a file
la $a0, filename # loading the file name
li $a1, 0 # loading said file for reading
li $a2, 0 # mode is ignored
syscall # opening the file (file descriptor returned in $v0)
move $s0, $v0 # save the file descriptor

# read from the file
li $v0, 14 # system call for reading from a file
move $a0, $s0 # file descriptor to read
la $a1, buffer # address of buffer to read into
li $a2, 1200 # max read of 1200 characters
syscall # reading from file into buffer

# close the file
li $v0, 16 # system call code for closing a file
move $a0, $s0 # file descriptor to close
syscall # close the file

jr $ra # file has been read into address 'buffer'

####################################################
# final exit code
####################################################
End:
li $v0, 10 # exiting the program
syscall # booyah!
