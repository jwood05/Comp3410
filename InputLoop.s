# COMP3410
# PA 01
# Assembly Language Program #2
# Add the odd integers under 10
# main/driver starts here
 .globl main
main:
# data segment
.data
input: .word 0
str1: .asciiz "Please type in an integer no greater than 12 to see its factorial: "
str2: .asciiz "The factorial of this integer is: "
str3: .asciiz "This number is too large.\n\n"
# text segment
.text
P1:
li $v0, 4 # system call code to print a string
la $a0, str1 #address of string to print (saved above)
syscall #print the string
li $v0, 5 # get ready to read an integer into $v0
syscall # read in integer input
sw $v0, input #store integer value
lw $t1, input # address of the integer storing the sum
li $t3, 13 # setting $t3 = 13 to make sure a number too big is not accepted
bge $t3, $t1, P2 # if the input is < 13, go to P2
li $v0, 4 # get ready to print text
la $a0, str3 # load str3 (from .data) for printing
syscall # print str3 to console
j P1 # jump back to P1
P2:
# everything else