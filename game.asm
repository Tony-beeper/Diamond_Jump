#####################################################################
#
# CSCB58 Winter 2022 Assembly Final Project
# University of Toronto, Scarborough
#
# Student: Name, Student Number, UTorID, official email
#
# Bitmap Display Configuration:
# - Unit width in pixels: 4 (update this as needed)
# - Unit height in pixels: 4 (update this as needed)
# - Display width in pixels: 256 (update this as needed)
# - Display height in pixels: 256 (update this as needed)
# - Base Address for Display: 0x10008000 ($gp)
#
# Which milestones have been reached in this submission?
# (See the assignment handout for descriptions of the milestones)
# - Milestone 1/2/3 (choose the one the applies)
#
# Which approved features have been implemented for milestone 3?
# (See the assignment handout for the list of additional features)
# 1. (fill in the feature, if any)
# 2. (fill in the feature, if any)
# 3. (fill in the feature, if any)
# ... (add more if necessary)
#
# Link to video demonstration for final submission:
# - (insert YouTube / MyMedia / other URL here). Make sure we can view it!
#
# Are you OK with us sharing the video with people outside course staff?
# - yes / no / yes, and please share this project github link as well!
#
# Any additional information that the TA needs to know:
# - (write here, if any)
#
#####################################################################
# Bitmap display starter code
#
# Bitmap Display Configuration:
# - Unit width in pixels: 4
# - Unit height in pixels: 4
# - Display width in pixels: 512
# - Display height in pixels: 256
# - Base Address for Display: 0x10008000 ($gp)
#
.eqv BASE_ADDRESS 0x10008000

.eqv KEY_STROKE_ADDRESS 0xffff0000

.eqv topRight	  0x100081FC		#Top right of screen
.eqv BottomScreen   0x1000FC00
.eqv bottomRight  0x1000FFFC		#Bottom right of screen




.eqv pixelDown	512 	#next pixel downward

.eqv MoveLeft	-4
.eqv MoveRight	4
.eqv MoveUp	-2048
.eqv MoveDown	2048




.eqv GravityCounter 0

.eqv CharInitial 0x10008000

.eqv charWidth	24
.eqv CharLength 4096		#The length of the Character

.data
platForms: .word 7168, 10432, 20864	#platform position with offset to base_address

.text
.globl main


Start:
	li $t0, CharInitial
	li $t5, GravityCounter #set gravity counter to 0 initially
GameLoop:

	addi $t1, $zero, 0	#reset movement
	
	#blt $t4, 7168, Next
	#blt $t4, 7168, Next
	addi $t5, $t5, 1	#increment gravity counter
	
Next:
	li $t9, KEY_STROKE_ADDRESS
	
	li $v0, 32	#sleep and wait for input
	li $a0, 15 # Wait one second (20 milliseconds)
	syscall
	
	
	
	
	lw $t8, 0($t9)	
	

	
	beq $t8, 0, KeyCheckEnds
	lw $t2, 4($t9) # this assumes $t9 is set to 0xfff0000 from before

Left:
	bne $t2, 0x61, Right # ASCII code of 'a' is 0x61 or 97 in decimal

	addi $sp, $sp, -4
	sw $t0, 0($sp)
	
	jal CheckLeft		#Checks if the character is at the left side of the screen if so we will not move left
	
	lw $t0, 0($sp)
	addi $sp, $sp, 4
	lw $s0, 0($sp)
	addi $sp, $sp, 4
	
	beq $s0, $zero, ReDraw
	addi $t1, $zero, MoveLeft		
	
	j ReDraw
	
Right:
	bne $t2, 0x64, Down

	addi $sp, $sp, -4
	sw $t0, 0($sp)
	
	jal CheckRight			#Checks if the character is at the right side of the screen if so we will not move right
	
	#lw $t0, 0($sp)
	addi $sp, $sp, 4
	lw $s0, 0($sp)
	addi $sp, $sp, 4
	
	beq $s0, $zero, ReDraw
	
	addi $t1, $zero, MoveRight
	j ReDraw
	
Down:
	bne $t2, 0x73, Up
	addi $t4, $t0, CharLength
	bge $t4, BottomScreen, ReDraw 	#If the length passes the bottom boundry then stop the ship from moving more down
	
	
#collision Check for this downward motion
	addi $sp, $sp, -4

	sw $t4, 0($sp)	#give the position of the ship to function
	jal CheckPlatformCollision	#return 0 if no collision, 1 if there's collision
	lw $t6, 0($sp)	#t6 stores the result of collided or not
	addi $sp, $sp, 4
	
	beq $t6, 1, ReDraw
	#bge $t4, 7168, GameDraw
	#ble $t4, 7232, GameDraw
	
	addi $t1, $zero, MoveDown
	j ReDraw

	

Up:
	bne $t2, 0x77, Restart
	ble $t0, BASE_ADDRESS, ReDraw
	addi $t1, $zero, MoveUp
	j ReDraw
	
Restart:

ReDraw:
	addi $sp, $sp, -4			
	sw $t0, 0($sp)
	jal ClearCharacter			#Clearing the character for redraw
	
	add $t0, $t0, $t1

KeyCheckEnds:
	#if counter .. then go otherwise go gamedraw
	
CheckGravity:
	bne $t5, 25, GameDraw	#check gravity counter
	
#check if collid with platform, if so, don't apply gravity
	addi $t4, $t0, CharLength	
	addi $sp, $sp, -4
	sw $t4, 0($sp)	#give the position of the ship to function
	jal CheckPlatformCollision	#return 0 if no collision, 1 if there's collision
	lw $t6, 0($sp)	#t6 stores the result of collided or not
	addi $sp, $sp, 4
	beq $t6, 1, ResetGravity
	
	addi $t4, $t0, CharLength	#gravity
	bge $t4, BottomScreen, ResetGravity 	#If the length passes the bottom boundry then stop the character from moving more down
	addi $t1, $t1, MoveDown
	
	addi $sp, $sp, -4
	sw $t0, 0($sp)
	jal ClearCharacter	
	
	add $t0, $t0, $t1

ResetGravity:

	add $t5, $zero, $zero #reset the gravity counter
	
GameDraw:
	addi $sp, $sp, -4
	sw $t0, 0($sp)
	jal DrawChar

GameContinue:
	j GameLoop

##################### function check platform collision ####################
CheckPlatformCollision:
	lw $a0, 0($sp)
	addi $sp, $sp, 4
	addi $a1, $zero, 0		#assume no collision
	li $a2, 0	#offset
	li $a3, BASE_ADDRESS	#base position
	
	la $t7, platForms	#load address of platform array
	add $t9, $zero, $zero
	
CheckPlatformLoop:
	beq $t9, 3, CollisionCheckEnds
	lw $t8, 0($t7)
	add $a2, $a3, $t8
	
First_Plat1:

	bge $a0, $a2, First_Plat_Next1		#less than
	j First_Plat2
First_Plat_Next1:
	addi $a2, $a2, 64
	ble $a0, $a2, CollisionHappened
	
First_Plat2:
	addi $t8, $t8, 512
	add $a2, $a3, $t8
	bge $a0, $a2, First_Plat_Next2		#less than
	j First_Plat3
	
First_Plat_Next2:
	addi $a2, $a2, 64
	ble $a0, $a2, CollisionHappened
	
First_Plat3:
	addi $t8, $t8, 512
	add $a2, $a3, $t8
	bge $a0, $a2, First_Plat_Next3		#less than
	j First_Plat4
First_Plat_Next3:
	addi $a2, $a2, 64
	ble $a0, $a2, CollisionHappened
	
First_Plat4:
	addi $t8, $t8, 512
	add $a2, $a3, $t8
	bge $a0, $a2, First_Plat_Next4		#less than
	j CollisionLoopCheck
	
First_Plat_Next4:
	addi $a2, $a2, 64
	ble $a0, $a2, CollisionHappened
	
	j CollisionLoopCheck

CollisionLoopCheck:
	addi $t7, $t7, 4
	addi $t9, $t9, 1
	j CheckPlatformLoop
	
CollisionHappened:
	addi $a1, $zero, 1

CollisionCheckEnds:
	addi $sp, $sp, -4
	sw $a1, 0($sp)
	jr $ra

	
##################### function to clear character before redraw ####################
ClearCharacter:
	lw $a0, 0($sp) 		# $a0 stores the base address for display
	addi $sp, $sp, 4

	li $a1, 0x000000  	# $a2 stores the black colour code
	
	#Note each "group" of units represents one row in the Bitmap Display, groups are separated by spaces
	#Note that everything is being turned to black so it is erased


	sw $a1, 8($a0)		#Red outline of the top wing
	
	sw $a1, 516($a0)		#Red outline of the top wing
	sw $a1, 520($a0)		#Red outline of the top wing
	sw $a1, 524($a0)		#Red outline of the top wing

	
	sw $a1, 1024($a0)		#Red outline of the top wing
	sw $a1, 1028($a0)		#Red outline of the top wing
	sw $a1, 1032($a0)		#Red outline of the top wing
	sw $a1, 1036($a0)		#Red outline of the top wing
	sw $a1, 1040($a0)		#Red outline of the top wing

	sw $a1, 1540($a0)		#Red outline of the top wing
	sw $a1, 1544($a0)		#Red outline of the top wing
	sw $a1, 1548($a0)		#Red outline of the top wing

	sw $a1, 2056($a0)		#Red outline of the top wing
		
		

	jr $ra
##################### functions to draw character and platform #####################

DrawPlatform:
	lw $a0, 0($sp) 		# $a0 stores the base address for display
	addi $sp, $sp, 4

	li $a2, 0xa4161a  	# store red color $a2
	
	sw $a2, 4($a0)		#Red outline of the top wing
	sw $a2, 8($a0)		#Red outline of the top wing
	sw $a2, 12($a0)		#Red outline of the top wing
	sw $a2, 16($a0)		#Red outline of the top wing
	sw $a2, 20($a0)		#Red outline of the top wing
	sw $a2, 24($a0)		#Red outline of the top wing
	sw $a2, 28($a0)		#Red outline of the top wing
	sw $a2, 32($a0)		#Red outline of the top wing
	sw $a2, 36($a0)		#Red outline of the top wing
	sw $a2, 40($a0)		#Red outline of the top wing
	sw $a2, 44($a0)		#Red outline of the top wing
	sw $a2, 48($a0)		#Red outline of the top wing
	sw $a2, 52($a0)		#Red outline of the top wing
	sw $a2, 56($a0)		#Red outline of the top wing
	sw $a2, 60($a0)		#Red outline of the top wing
	sw $a2, 64($a0)		#Red outline of the top wing

	sw $a2, 516($a0)		#Red outline of the top wing
	sw $a2, 520($a0)		#Red outline of the top wing
	sw $a2, 524($a0)		#Red outline of the top wing
	sw $a2, 528($a0)		#Red outline of the top wing
	sw $a2, 532($a0)		#Red outline of the top wing
	sw $a2, 536($a0)		#Red outline of the top wing
	sw $a2, 540($a0)		#Red outline of the top wing
	sw $a2, 544($a0)		#Red outline of the top wing
	sw $a2, 548($a0)		#Red outline of the top wing
	sw $a2, 552($a0)		#Red outline of the top wing
	sw $a2, 556($a0)		#Red outline of the top wing
	sw $a2, 560($a0)		#Red outline of the top wing
	sw $a2, 564($a0)		#Red outline of the top wing
	sw $a2, 568($a0)		#Red outline of the top wing
	sw $a2, 572($a0)		#Red outline of the top wing
	sw $a2, 576($a0)		#Red outline of the top wing
	
	jr $ra
		

DrawChar: 
	lw $a0, 0($sp) 		# $a0 stores the base address for display
	addi $sp, $sp, 4

	li $a1, 0xFFFFFF  	# $a1 stores the white colour code
	li $a2, 0xa4161a  	# $a2 stores the red colour code
	#Note each "group" of units represents one row in the Bitmap Display, groups are separated by spaces
			
	sw $a1, 8($a0)		#Red outline of the top wing
	
	sw $a1, 516($a0)		#Red outline of the top wing
	sw $a1, 520($a0)		#Red outline of the top wing
	sw $a1, 524($a0)		#Red outline of the top wing

	
	sw $a1, 1024($a0)		#Red outline of the top wing
	sw $a1, 1028($a0)		#Red outline of the top wing
	sw $a1, 1032($a0)		#Red outline of the top wing
	sw $a1, 1036($a0)		#Red outline of the top wing
	sw $a1, 1040($a0)		#Red outline of the top wing

	sw $a1, 1540($a0)		#Red outline of the top wing
	sw $a1, 1544($a0)		#Red outline of the top wing
	sw $a1, 1548($a0)		#Red outline of the top wing

	sw $a1, 2056($a0)		#Red outline of the top wing

	jr $ra
	

########################################### check left function ####################################

CheckLeft:
	lw $a0, 0($sp)
	addi $sp, $sp, 4
	
	addi $a1, $zero, BASE_ADDRESS		#Load the topLeft of the screen
	addi $a2, $zero, 1
	
CheckLeftLoop:	
	bgt $a1, $a0, CheckLeftExit		#If the pixel we chck is greater than the position then we break
	bne $a1, $a0, CheckLeftEnd		#If it is on the edge then continue
	addi $a2, $zero, 0			#Return zero to show that it is on the edge
	j CheckLeftExit
	
CheckLeftEnd:
	addi $a1, $a1, pixelDown			#Increment loop, note that we go to the next pixel down
	j CheckLeftLoop
	
CheckLeftExit:	
	addi $sp, $sp, -4
	sw $a2, 0($sp)
	addi $sp, $sp, -4
	sw $a0, 0($sp)
	
	jr $ra

########################################### check right function ####################################
	
CheckRight:
	lw $a0, 0($sp)
	addi $sp, $sp, 4
	
	addi $a0, $a0, charWidth		#width of the character add to original position
	addi $a1, $zero, topRight		#Load the top right
	addi $a2, $zero, 1
	addi $a3, $zero, bottomRight
	
CheckRightLoop:	
	beq $a1,$a3 , CheckRightExit		#If it is not on the edge exit
	bne $a1, $a0, CheckRightEnd		#If it is on the edge then continue
	addi $a2, $zero, 0			#Return zero to show that it is on the edge
	j CheckRightExit
	
CheckRightEnd:
	addi $a1, $a1, pixelDown			#Increment loop
	j CheckRightLoop
	
CheckRightExit:	
	addi $a0, $a0, -charWidth
	addi $sp, $sp, -4
	sw $a2, 0($sp)
	addi $sp, $sp, -4
	sw $a0, 0($sp)
	
	jr $ra
	
############################################ ####################################

main:

	li $t1, BASE_ADDRESS # $t0 stores the base address for display
	li $t3, 0x00ff00   # $t2 stores the green colour code 
	li $t2, 0x100097FC
	
	sw $t3, 0($t2)


	la $a0, 7168($t1) # draw the initial platform
	addi $sp, $sp, -4
	sw $a0, 0($sp)
	jal DrawPlatform


	la $a0, 10432($t1) # draw the initial platform
	addi $sp, $sp, -4
	sw $a0, 0($sp)
	jal DrawPlatform
	

	la $a0, 20864($t1) # draw the initial platform
	addi $sp, $sp, -4
	sw $a0, 0($sp)
	jal DrawPlatform
	
	
	la $a0, 1024($t1)
	lw $t0, 1024($t1)
	addi $sp, $sp, -4
	sw $a0, 0($sp)
	jal DrawChar

	j Start


	
	


	li $v0, 10 # terminate the program gracefully
	syscall

