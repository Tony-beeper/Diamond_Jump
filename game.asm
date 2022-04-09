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

.eqv purpleHex	0x800080
.eqv pinkHex	0xFF4DE1
.eqv whiteHex	0xFFFFFF

.eqv pixelDown	512 	#next pixel downward

.eqv MoveLeft	-4
.eqv MoveRight	4
.eqv MoveUp	-2048
.eqv MoveDown	2048




.eqv GravityCounter 0

.eqv CharInitial 0x10008000

.eqv charWidth	24
.eqv CharLength 4096		#The length of the Character

.eqv firePos 16704

.eqv StarPos 16512

.data
platForms: .word 7168, 10432, 20864	#platform position with offset to base_address

.text
.globl main


Start:
	li $t0, CharInitial
	la $t3, 16704($t0)
	li $t5, GravityCounter #set gravity counter to 0 initially
	la $s1, 16512($t0)
	add $s4, $zero, $zero	#set score to 0
	

	
GameLoop:
	
	addi $s4, $s4, 1
	addi $t1, $zero, 0	#reset movement
	
	
	addi $sp, $sp, -4	#char
	sw $t0, 0($sp)
	
	addi $sp, $sp, -4	#star
	sw $s1, 0($sp)
	
	addi $sp, $sp, -4	#fire
	sw $t3, 0($sp)
	
	jal StarFireCollisionCheck	# return 0 if no, return 1 if star, return 2 if fire, 3 if heart winnning
	lw $s2, 0($sp)
	addi $sp, $sp, 4
	beq $s2, 3, GameWin
	
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
	bge $t4, BottomScreen, GameOver 	#If the length passes the bottom boundry then stop the char from moving more down
	
	
	
#collision Check for this downward motion
	addi $sp, $sp, -4

	sw $t4, 0($sp)	#give the position of the char to function
	jal CheckPlatformCollision	#return 0 if no collision, 1 if there's collision
	lw $t6, 0($sp)	#t6 stores the result of collided or not
	addi $sp, $sp, 4
	
	beq $t6, 1, ReDraw
	#bge $t4, 7168, GameDraw
	#ble $t4, 7232, GameDraw
	
	addi $t1, $zero, MoveDown
	j ReDraw

	

Up:
	bne $t2, 0x77, RestartCheck
	ble $t0, BASE_ADDRESS, ReDraw
	
	
	addi $sp, $sp, -4

	sw $t0, 0($sp)	#give the position of the char to function
	jal CheckPlatformCollision	#return 0 if no collision, 1 if there's collision
	lw $t6, 0($sp)	#t6 stores the result of collided or not
	addi $sp, $sp, 4
	
	beq $t6, 1, ReDraw
	
	addi $t1, $zero, MoveUp
	j ReDraw
	
RestartCheck:
	bne $t2, 0x70, ReDraw
	j Restart
	

ReDraw:
	addi $sp, $sp, -4			
	sw $t0, 0($sp)
	jal ClearCharacter			#Clearing the character for redraw
	
	add $t0, $t0, $t1

KeyCheckEnds:
	#if counter .. then go otherwise go gamedraw

CheckGravity:
	bne $t5, 50, GameDraw	#check gravity counter
	
#check if collid with platform, if so, don't apply gravity
	addi $t4, $t0, CharLength	
	addi $sp, $sp, -4
	sw $t4, 0($sp)	#give the position of the char to function
	jal CheckPlatformCollision	#return 0 if no collision, 1 if there's collision
	lw $t6, 0($sp)	#t6 stores the result of collided or not
	addi $sp, $sp, 4
	beq $t6, 1, ResetGravity
	
	addi $t4, $t0, CharLength	#gravity
	bge $t4, BottomScreen, GameOver 	#If the length passes the bottom boundry then stop the character from moving more down
	addi $t1, $t1, MoveDown
	
	addi $sp, $sp, -4
	sw $t0, 0($sp)
	jal ClearCharacter	
	
	add $t0, $t0, $t1
	


ResetGravity:

	add $t5, $zero, $zero #reset the gravity counter
	
GameDraw:


	#draw character
	addi $sp, $sp, -4	#position
	sw $t0, 0($sp)
	beq $s2, 0, NoCollisionColor
	beq $s2, 1, StarColor
	beq $s2, 2, FireColor
	
NoCollisionColor:

	addi $sp, $sp, -4	#position
	li $s3, whiteHex
	sw $s3, 0($sp)
	j ReallyDrawNow
	
StarColor:
	addi $sp, $sp, -4	#position
	li $s3, purpleHex
	sw $s3, 0($sp)
	j ReallyDrawNow
	
FireColor:
	addi $sp, $sp, -4	#position
	li $s3, pinkHex
	sw $s3, 0($sp)
	j ReallyDrawNow

ReallyDrawNow:
	jal DrawChar

MoveFire:
	#draw fire
	bne $t5, 25, MoveStar	#check gravity counter
	
	#clean fire
	addi $sp, $sp, -4
	sw $t3, 0($sp)
	jal CleanFire
	
	li $v0, 42
	li $a0, 0
	li $a1, 28
	syscall
	
	bge $a0, 14, MoveFireLeft
	
MoveFireRight:
	#drawfire
	addi $t3, $t3, MoveRight
	
	addi $sp, $sp, -4
	sw $t3, 0($sp)
	jal DrawFire
	j MoveStar
		
MoveFireLeft:
	
	addi $t3, $t3, MoveLeft
	
	addi $sp, $sp, -4
	sw $t3, 0($sp)
	jal DrawFire

MoveStar:
	#draw fire
	bne $t5, 12, ReDrawPlatforms	#check gravity counter
	
	#clean fire
	addi $sp, $sp, -4
	sw $s1, 0($sp)
	jal CleanFire
	
	li $v0, 42
	li $a0, 0
	li $a1, 28
	syscall
	
	bge $a0, 14, MoveStarLeft
	
MoveStarRight:
	#drawfire
	addi $s1, $s1, MoveRight
	
	addi $sp, $sp, -4
	sw $s1, 0($sp)
	jal DrawStar
	j ReDrawPlatforms
	
MoveStarLeft:
	
	addi $s1, $s1, MoveLeft
	
	addi $sp, $sp, -4
	sw $s1, 0($sp)
	jal DrawStar


ReDrawPlatforms:
	la $t7, platForms	#load address of platform array	
	add $t9, $zero, $zero
	li $a3, BASE_ADDRESS	#base position
	li $a2, 0	#offset
ReDrawPlatformsLoop:
	beq $t9, 3, GameContinue
	
	lw $t8, 0($t7)
	addi $sp, $sp, -4
	add $a2, $a3, $t8
	sw $a2, 0($sp)
	jal DrawPlatform
	
ReDrawPlatformsAdvance:
	addi $t9, $t9, 1
	addi $t7, $t7, 4
	j ReDrawPlatformsLoop
	
GameContinue:

	
	j GameLoop
	
######################### Fucntion to play when game over ###############################
	
GameOver:
	###print the GameOver image #############
	
	
	#li $v0, 32
	
	#li $a0, 4000 # Sleep for 4 seconds before restart
	#syscall
	
	j Restart
	
######################### Fucntion to play when win ###############################
GameWin:
	###print the winning image #############
	
	#li $v0, 32
	
	#li $a0, 4000 # Sleep for 4 seconds before restart
	#syscall
	
	j Restart
######################### Fucntion to check for collision ###############################

StarFireCollisionCheck:
	lw $a2, 0($sp)	#fire
	addi $sp, $sp, 4

	lw $a1, 0($sp)	#star
	addi $sp, $sp, 4
	
	lw $a0, 0($sp)	#char
	addi $sp, $sp, 4
	
	addi $a0, $a0, 1032	#center of char
	
	li $a3, BASE_ADDRESS
	la $a3, 14256($a3)
	
HeartCollisionCheckLoop:

	beq $a0, $a3, HeartCollided
	addi $a3, $a3, 4
	beq $a0, $a3, HeartCollided
	addi $a3, $a3, 4
	beq $a0, $a3, HeartCollided
	addi $a3, $a3, 4
	beq $a0, $a3, HeartCollided
	addi $a3, $a3, 4
	beq $a0, $a3, HeartCollided
	addi $a3, $a3, 492
	
	beq $a0, $a3, HeartCollided
	addi $a3, $a3, 4
	beq $a0, $a3, HeartCollided
	addi $a3, $a3, 4
	beq $a0, $a3, HeartCollided
	addi $a3, $a3, 4
	beq $a0, $a3, HeartCollided
	addi $a3, $a3, 4
	beq $a0, $a3, HeartCollided
	addi $a3, $a3, 492
	
	beq $a0, $a3, HeartCollided
	addi $a3, $a3, 4
	beq $a0, $a3, HeartCollided
	addi $a3, $a3, 4
	beq $a0, $a3, HeartCollided
	addi $a3, $a3, 4
	beq $a0, $a3, HeartCollided
	addi $a3, $a3, 4
	beq $a0, $a3, HeartCollided
	addi $a3, $a3, 492
	
	beq $a0, $a3, HeartCollided
	addi $a3, $a3, 4
	beq $a0, $a3, HeartCollided
	addi $a3, $a3, 4
	beq $a0, $a3, HeartCollided
	addi $a3, $a3, 4
	beq $a0, $a3, HeartCollided
	addi $a3, $a3, 4
	beq $a0, $a3, HeartCollided
	addi $a3, $a3, 492
	
		
	
	
	
StarCollisionCheckLoop:

	beq $a0, $a1, StarCollided
	addi $a1, $a1, 4
	beq $a0, $a1, StarCollided
	addi $a1, $a1, 4
	beq $a0, $a1, StarCollided
	addi $a1, $a1, 4
	beq $a0, $a1, StarCollided
	addi $a1, $a1, 4
	beq $a0, $a1, StarCollided
	addi $a1, $a1, 492
	
	beq $a0, $a1, StarCollided
	addi $a1, $a1, 4
	beq $a0, $a1, StarCollided
	addi $a1, $a1, 4
	beq $a0, $a1, StarCollided
	addi $a1, $a1, 4
	beq $a0, $a1, StarCollided
	addi $a1, $a1, 4
	beq $a0, $a1, StarCollided
	addi $a1, $a1, 492
	
	beq $a0, $a1, StarCollided
	addi $a1, $a1, 4
	beq $a0, $a1, StarCollided
	addi $a1, $a1, 4
	beq $a0, $a1, StarCollided
	addi $a1, $a1, 4
	beq $a0, $a1, StarCollided
	addi $a1, $a1, 4
	beq $a0, $a1, StarCollided
	addi $a1, $a1, 492
	
	beq $a0, $a1, StarCollided
	addi $a1, $a1, 4
	beq $a0, $a1, StarCollided
	addi $a1, $a1, 4
	beq $a0, $a1, StarCollided
	addi $a1, $a1, 4
	beq $a0, $a1, StarCollided
	addi $a1, $a1, 4
	beq $a0, $a1, StarCollided
	addi $a1, $a1, 492
	
	
FireCollisionCheckLoop:

	beq $a0, $a2, FireCollided
	addi $a2, $a2, 4
	beq $a0, $a2, FireCollided
	addi $a2, $a2, 4
	beq $a0, $a2, FireCollided
	addi $a2, $a2, 4
	beq $a0, $a2, FireCollided
	addi $a2, $a2, 4
	beq $a0, $a2, FireCollided
	addi $a2, $a2, 492
	
	beq $a0, $a2, FireCollided
	addi $a2, $a2, 4
	beq $a0, $a2, FireCollided
	addi $a2, $a2, 4
	beq $a0, $a2, FireCollided
	addi $a2, $a2, 4
	beq $a0, $a2, FireCollided
	addi $a2, $a2, 4
	beq $a0, $a2, FireCollided
	addi $a2, $a2, 492
	
	beq $a0, $a2, FireCollided
	addi $a2, $a2, 4
	beq $a0, $a2, FireCollided
	addi $a2, $a2, 4
	beq $a0, $a2, FireCollided
	addi $a2, $a2, 4
	beq $a0, $a2, FireCollided
	addi $a2, $a2, 4
	beq $a0, $a2, FireCollided
	addi $a2, $a2, 492
	
	beq $a0, $a2, FireCollided
	addi $a2, $a2, 4
	beq $a0, $a2, FireCollided
	addi $a2, $a2, 4
	beq $a0, $a2, FireCollided
	addi $a2, $a2, 4
	beq $a0, $a2, FireCollided
	addi $a2, $a2, 4
	beq $a0, $a2, FireCollided
	addi $a2, $a2, 492
	j StarFireCollisionCheckEnd
	
	
HeartCollided:
	addi $sp, $sp, -4
	addi $a0, $zero, 3
	sw $a0, 0($sp)
	jr $ra
StarCollided:
	addi $sp, $sp, -4
	addi $a0, $zero, 1
	sw $a0, 0($sp)
	jr $ra
FireCollided:

	addi $sp, $sp, -4
	addi $a0, $zero, 2
	sw $a0, 0($sp)
	jr $ra
	
StarFireCollisionCheckEnd:

	addi $sp, $sp, -4
	addi $a0, $zero, 0
	sw $a0, 0($sp)
	jr $ra

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
	
Plat1:

	bge $a0, $a2, Plat_Next1		#less than
	j Plat2
Plat_Next1:
	addi $a2, $a2, 64
	ble $a0, $a2, CollisionHappened
	
Plat2:
	addi $t8, $t8, 512
	add $a2, $a3, $t8
	bge $a0, $a2, Plat_Next2		#less than
	j Plat3
	
Plat_Next2:
	addi $a2, $a2, 64
	ble $a0, $a2, CollisionHappened
	
Plat3:
	addi $t8, $t8, 512
	add $a2, $a3, $t8
	bge $a0, $a2, Plat_Next3		#less than
	j Plat4
Plat_Next3:
	addi $a2, $a2, 64
	ble $a0, $a2, CollisionHappened

Plat4:
	addi $t8, $t8, 512
	add $a2, $a3, $t8
	bge $a0, $a2, Plat_Next4		#less than
	j CollisionLoopCheck
	
Plat_Next4:
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
	
##################### function to clear character before redraw ####################
CleanFire:
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
##################### functions to draw Heart for winning #####################
DrawHeart:	
	lw $a0, 0($sp) 		# $a0 stores the base address for display
	addi $sp, $sp, 4

	li $a2, 0xCCFF88	# store red color $a2
	
	sw $a2, 4($a0)
	sw $a2, 12($a0)
	sw $a2, 512($a0)
	sw $a2, 516($a0)
	sw $a2, 520($a0)
	sw $a2, 524($a0)
	sw $a2, 528($a0)
	sw $a2, 1028($a0)
	sw $a2, 1032($a0)
	sw $a2, 1036($a0)
	sw $a2, 1544($a0)
	
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
	
########################### function to draw the character ##############################
DrawChar: 
	lw $a1, 0($sp)
	#li $a1, purpleHex
	addi $sp, $sp, 4
	lw $a0, 0($sp) 		# $a0 stores the base address for display
	addi $sp, $sp, 4
			
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
	
########################### function to draw the fire ##############################
DrawFire: 
	lw $a0, 0($sp) 		# $a0 stores the base address for display
	addi $sp, $sp, 4

	li $a1, 0xFFFFFF  	# $a1 stores the white colour code
	li $a2, 0xa4161a  	# $a2 stores the red colour code
	#Note each "group" of units represents one row in the Bitmap Display, groups are separated by spaces
			
	sw $a2, 8($a0)		#Red outline of the top wing
	
	sw $a2, 516($a0)		#Red outline of the top wing
	sw $a2, 520($a0)		#Red outline of the top wing
	sw $a2, 524($a0)		#Red outline of the top wing

	
	sw $a2, 1024($a0)		#Red outline of the top wing
	sw $a2, 1028($a0)		#Red outline of the top wing
	sw $a2, 1032($a0)		#Red outline of the top wing
	sw $a2, 1036($a0)		#Red outline of the top wing
	sw $a2, 1040($a0)		#Red outline of the top wing

	sw $a2, 1540($a0)		#Red outline of the top wing
	sw $a2, 1544($a0)		#Red outline of the top wing
	sw $a2, 1548($a0)		#Red outline of the top wing

	sw $a2, 2056($a0)		#Red outline of the top wing

	jr $ra

########################### function to draw the star ##############################
DrawStar: 
	lw $a0, 0($sp) 		# $a0 stores the base address for display
	addi $sp, $sp, 4


	li $a2, 0xFFFF00  	# $a2 stores the red colour code
	#Note each "group" of units represents one row in the Bitmap Display, groups are separated by spaces
			
	sw $a2, 8($a0)		#Red outline of the top wing
	
	sw $a2, 516($a0)		#Red outline of the top wing
	sw $a2, 520($a0)		#Red outline of the top wing
	sw $a2, 524($a0)		#Red outline of the top wing

	
	sw $a2, 1024($a0)		#Red outline of the top wing
	sw $a2, 1028($a0)		#Red outline of the top wing
	sw $a2, 1032($a0)		#Red outline of the top wing
	sw $a2, 1036($a0)		#Red outline of the top wing
	sw $a2, 1040($a0)		#Red outline of the top wing

	sw $a2, 1540($a0)		#Red outline of the top wing
	sw $a2, 1544($a0)		#Red outline of the top wing
	sw $a2, 1548($a0)		#Red outline of the top wing

	sw $a2, 2056($a0)		#Red outline of the top wing

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
########################################### Restart function to restart the whole game ####################################
Restart:
	
ClearScreen:
	li $a0, BASE_ADDRESS
	li $a2, 0	#counter
	li $a1, 0x000000	#hex for black
	
ClearScreenLoop:
	beq $a2, 32768, ClearScreenEnds
	
	sw $a1, 0($a0) #clear
ClearScreenLoopAdvance:

	addi $a0, $a0, 4
	addi $a2, $a2, 4
	j ClearScreenLoop
	
ClearScreenEnds:
	li $v0, 32
	li $a0, 3000 # Wait one second (1000 milliseconds)
	syscall
	
	
	# print out the score
	
	j main
	
	
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
	#li $t3, 0x00ff00   # $t2 stores the green colour code 
	li $t2, 0x100097FC
	li $t4, 0xFFFF00	#yellow
	#sw $t3, 0($t2)


	la $a0, 7168($t1) # draw the initial platform
	addi $sp, $sp, -4
	sw $a0, 0($sp)
	jal DrawPlatform
	
	la $a0, 14256($t1) # draw the Heart for winning
	addi $sp, $sp, -4
	sw $a0, 0($sp)
	jal DrawHeart


	la $a0, 10432($t1) # draw the initial platform
	addi $sp, $sp, -4
	sw $a0, 0($sp)
	jal DrawPlatform
	

	la $a0, 20864($t1) # draw the initial platform
	addi $sp, $sp, -4
	sw $a0, 0($sp)
	jal DrawPlatform
	
	la $a0, 16704($t1) # draw the initial Fire
	addi $sp, $sp, -4
	sw $a0, 0($sp)
	jal DrawFire

	la $a0, 16512($t1) # draw the initial Star
	addi $sp, $sp, -4
	sw $a0, 0($sp)
	jal DrawStar
	
	

	
	#la $a0, 1024($t1)
	#lw $t0, 1024($t1)
	
	#addi $sp, $sp, -4
	#sw $a0, 0($sp)
	
	#addi $sp, $sp, -4
	#li $t1, whiteHex
	#sw $t1, 0($sp)
	
	#jal DrawChar

	j Start


	
	


	li $v0, 10 # terminate the program gracefully
	syscall

