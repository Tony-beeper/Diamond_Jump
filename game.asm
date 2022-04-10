#####################################################################
#
# CSCB58 Winter 2022 Assembly Final Project
# University of Toronto, Scarborough
#
# Student: Youxin Tan, Student Number: 1005263858, UTorID: tanyouxi, official email: youxin.tan@mail.utoronto.ca
#
# Bitmap Display Configuration:
# - Unit width in pixels: 4 (update this as needed)
# - Unit height in pixels: 4 (update this as needed)
# - Display width in pixels: 512 (update this as needed)
# - Display height in pixels: 256 (update this as needed)
# - Base Address for Display: 0x10008000 ($gp)
#
# Which milestones have been reached in this submission?
# (See the assignment handout for descriptions of the milestones)
# - Milestone 3 (choose the one the applies)
#
# Which approved features have been implemented for milestone 3?
# (See the assignment handout for the list of additional features)
# 1. B
# 2. C
# 3. D
# 4. E
# 5. G
# 6. K
# Link to video demonstration for final submission:
# - (insert YouTube / MyMedia / other URL here). Make sure we can view it!
#
# Are you OK with us sharing the video with people outside course staff?
# - no
#
# Any additional information that the TA needs to know:
# - no
#
#####################################################################

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
.eqv MoveRight	32
.eqv MoveUp	-4096
.eqv MoveDown	2048




.eqv GravityCounter 0

.eqv CharInitial 0x1000801C

.eqv charWidth	24
.eqv CharLength 4096		#The length of the Character

.eqv firePos 16704

.eqv StarPos 16512

.eqv HeartPosHex 0x1000B7B0

.data
platForms: .word 7168, 10432, 20864	#platform position with offset to base_address
Level: .word 0
.text
.globl main


Start:

	li $t0, CharInitial
	la $t3, 16704($t0)
	li $t5, GravityCounter #set gravity counter to 0 initially
	la $s1, 16512($t0)
	li $s5, 0	#regular jump energy
	li $s6, 0	#Double jump energy
	#add $s4, $zero, $zero	#set score to 0
	#lw $s4, Level	#load what level is it
	
GameLoop:
	#check platform collision for double jump and regular jump
	addi $t4, $t0, CharLength	
	addi $sp, $sp, -4
	sw $t4, 0($sp)	#give the position of the char to function
	jal CheckPlatformCollision	#return 0 if no collision, 1 if there's collision
	lw $t6, 0($sp)	#t6 stores the result of collided or not
	addi $sp, $sp, 4
	bne $t6, 1, UnChargeJump
ChargeJump:
	#on platform, charge up jump and double jump
	
	li $s5, 1	#regular jump energy
	li $s6, 1
	j GameLoopCont
UnChargeJump:
	li $s5, 0	#regular jump energy
	
GameLoopCont:
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
	beq $s2, 3, HeartReached
	
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
	
	addi $t1, $zero, MoveRight ####
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
	
	bne $s5, 1, CheckDouble
	li $s5, 0
	addi $t1, $zero, MoveUp
	j ReDraw
	
CheckDouble:
	bne $s6, 1, ReDraw
	li $s6, 0
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
	beq $s4, 1, MoveFireRightLevel2
	beq $s4, 2, MoveFireRightLevel3
	
MoveFireRightLevel1:
	addi $t3, $t3, 4
	j MoveFireRightAdditionEnds
MoveFireRightLevel2:
	addi $t3, $t3, 16
	j MoveFireRightAdditionEnds
MoveFireRightLevel3:
	addi $t3, $t3, 32

MoveFireRightAdditionEnds:
	addi $sp, $sp, -4
	sw $t3, 0($sp)
	jal DrawFire
	j MoveStar
		
MoveFireLeft:

	#addi $t3, $t3, MoveLeft
	beq $s4, 1, MoveFireLeftLevel2
	beq $s4, 2, MoveFireLeftLevel3

MoveFireLeftLevel1:
	addi $t3, $t3, -4
	j MoveFireLeftAdditionEnds
MoveFireLeftLevel2:
	addi $t3, $t3, -16
	j MoveFireLeftAdditionEnds
MoveFireLeftLevel3:
	addi $t3, $t3, -32

MoveFireLeftAdditionEnds:
	addi $sp, $sp, -4
	sw $t3, 0($sp)
	jal DrawFire

MoveStar:
	#draw fire
	bne $t5, 12, ClearPlatforms	#check gravity counter
	
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
	beq $s4, 1, MoveStarRightLevel2
	beq $s4, 2, MoveStarRightLevel3
	
MoveStarRightLevel1:
	addi $s1, $s1, 4
	j MoveStarRightAdditionEnds
MoveStarRightLevel2:
	addi $s1, $s1, 16
	j MoveStarRightAdditionEnds
MoveStarRightLevel3:
	addi $s1, $s1, 32

MoveStarRightAdditionEnds:
	addi $sp, $sp, -4
	sw $s1, 0($sp)
	jal DrawStar
	j ClearPlatforms
	
MoveStarLeft:
	
	beq $s4, 1, MoveStarLeftLevel2
	beq $s4, 2, MoveStarLeftLevel3
	
MoveStarLeftLevel1:
	addi $s1, $s1, -4
	j MoveStarLeftAdditionEnds
MoveStarLeftLevel2:
	addi $s1, $s1, -16
	j MoveStarLeftAdditionEnds
MoveStarLeftLevel3:
	addi $s1, $s1, -32

MoveStarLeftAdditionEnds:
	addi $sp, $sp, -4
	sw $s1, 0($sp)
	jal DrawStar
	
##to clean plat before redraw
ClearPlatforms:
	la $t7, platForms	#load address of platform array	
	add $t9, $zero, $zero
	li $a3, BASE_ADDRESS	#base position
	li $a2, 0	#offset
ClearPlatformsLoop:
	beq $t9, 3, MovePlatforms
	
	lw $t8, 0($t7)
	addi $sp, $sp, -4
	add $a2, $a3, $t8
	sw $a2, 0($sp)
	jal ClearPlatform
	
ClearPlatformsAdvance:
	addi $t9, $t9, 1
	addi $t7, $t7, 4
	j ClearPlatformsLoop

### randomize platform movement ######
MovePlatforms:
	bne $t5, 48, ReDrawPlatforms
	li $v0, 42
	li $a0, 0
	li $a1, 28
	
	la $t7, platForms	#load address of platform array	
	add $t9, $zero, $zero
	
	syscall
	bge $a0, 14, MovePlatformsLeft
	
	
MovePlatformsRight:
	
MovePlatformsRightLoop:
	beq $t9, 3, ReDrawPlatforms
	lw $t8, 0($t7)
	beq $s4, 1, MovePlatformsRightLevel2
	beq $s4, 2, MovePlatformsRightLevel3
	
MovePlatformsRightLevel1:
	add $t8, $t8, 4
	j MovePlatformsRightAdditionEnds
MovePlatformsRightLevel2:
	add $t8, $t8, 16
	j MovePlatformsRightAdditionEnds
	
MovePlatformsRightLevel3:
	add $t8, $t8, 32
	
MovePlatformsRightAdditionEnds:

	sw $t8, 0($t7)
	addi $t9, $t9, 1
	addi $t7, $t7, 4
	j MovePlatformsRightLoop
	
MovePlatformsLeft:

MovePlatformsLeftLoop:
	beq $t9, 3, ReDrawPlatforms
	lw $t8, 0($t7)
	beq $s4, 1, MovePlatformsLeftLevel2
	beq $s4, 2, MovePlatformsLeftLevel3

MovePlatformsLeftLevel1:
	add $t8, $t8, -4
	j MovePlatformsLeftAdditionEnds
	
MovePlatformsLeftLevel2:
	add $t8, $t8, -16
	j MovePlatformsLeftAdditionEnds
	
MovePlatformsLeftLevel3:
	add $t8, $t8, -32
	
MovePlatformsLeftAdditionEnds:

	sw $t8, 0($t7)
	addi $t9, $t9, 1
	addi $t7, $t7, 4
	j MovePlatformsLeftLoop

##to redraw
ReDrawPlatforms:
	la $t7, platForms	#load address of platform array	
	add $t9, $zero, $zero
	li $a3, BASE_ADDRESS	#base position
	li $a2, 0	#offset
ReDrawPlatformsLoop:
	beq $t9, 3, ReDrawHeart
	
	lw $t8, 0($t7)
	addi $sp, $sp, -4
	add $a2, $a3, $t8
	sw $a2, 0($sp)
	jal DrawPlatform
	
ReDrawPlatformsAdvance:
	addi $t9, $t9, 1
	addi $t7, $t7, 4
	j ReDrawPlatformsLoop
	
ReDrawHeart:
	li $t8, HeartPosHex
	addi $sp, $sp, -4
	sw $t8, 0($sp)
	jal DrawHeart
	
GameContinue:

	
	j GameLoop

######################### Fucntion to play when game over ###############################
	
GameOver:



li $v0, 32  #syscall for sleeping 30 ms
li $a0, 30 
addi $t4, $zero, BASE_ADDRESS
addi $t3, $t4,  0
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  4
sw $t5, 0($t3)
addi $t3, $t4,  8
sw $t5, 0($t3)
addi $t3, $t4,  12
sw $t5, 0($t3)
addi $t3, $t4,  16
sw $t5, 0($t3)
addi $t3, $t4,  20
sw $t5, 0($t3)
addi $t3, $t4,  24
sw $t5, 0($t3)
addi $t3, $t4,  28
sw $t5, 0($t3)
addi $t3, $t4,  32
sw $t5, 0($t3)
addi $t3, $t4,  36
sw $t5, 0($t3)
addi $t3, $t4,  40
sw $t5, 0($t3)
addi $t3, $t4,  44
sw $t5, 0($t3)
addi $t3, $t4,  48
sw $t5, 0($t3)
addi $t3, $t4,  52
sw $t5, 0($t3)
addi $t3, $t4,  56
sw $t5, 0($t3)
addi $t3, $t4,  60
sw $t5, 0($t3)
addi $t3, $t4,  64
sw $t5, 0($t3)
addi $t3, $t4,  68
sw $t5, 0($t3)
addi $t3, $t4,  72
sw $t5, 0($t3)
addi $t3, $t4,  76
sw $t5, 0($t3)
addi $t3, $t4,  80
sw $t5, 0($t3)
addi $t3, $t4,  84
sw $t5, 0($t3)
addi $t3, $t4,  88
sw $t5, 0($t3)
addi $t3, $t4,  92
sw $t5, 0($t3)
addi $t3, $t4,  96
sw $t5, 0($t3)
addi $t3, $t4,  100
sw $t5, 0($t3)
addi $t3, $t4,  104
sw $t5, 0($t3)
addi $t3, $t4,  108
sw $t5, 0($t3)
addi $t3, $t4,  112
sw $t5, 0($t3)
addi $t3, $t4,  116
sw $t5, 0($t3)
addi $t3, $t4,  120
sw $t5, 0($t3)
addi $t3, $t4,  124
sw $t5, 0($t3)
addi $t3, $t4,  128
sw $t5, 0($t3)
addi $t3, $t4,  132
sw $t5, 0($t3)
addi $t3, $t4,  136
sw $t5, 0($t3)
addi $t3, $t4,  140
sw $t5, 0($t3)
addi $t3, $t4,  144
sw $t5, 0($t3)
addi $t3, $t4,  148
sw $t5, 0($t3)
addi $t3, $t4,  152
sw $t5, 0($t3)
addi $t3, $t4,  156
sw $t5, 0($t3)
addi $t3, $t4,  160
sw $t5, 0($t3)
addi $t3, $t4,  164
sw $t5, 0($t3)
addi $t3, $t4,  168
sw $t5, 0($t3)
addi $t3, $t4,  172
sw $t5, 0($t3)
addi $t3, $t4,  176
sw $t5, 0($t3)
addi $t3, $t4,  180
sw $t5, 0($t3)
addi $t3, $t4,  184
sw $t5, 0($t3)
addi $t3, $t4,  188
sw $t5, 0($t3)
addi $t3, $t4,  192
sw $t5, 0($t3)
addi $t3, $t4,  196
sw $t5, 0($t3)
addi $t3, $t4,  200
sw $t5, 0($t3)
addi $t3, $t4,  204
sw $t5, 0($t3)
addi $t3, $t4,  208
sw $t5, 0($t3)
addi $t3, $t4,  212
sw $t5, 0($t3)
addi $t3, $t4,  216
sw $t5, 0($t3)
addi $t3, $t4,  220
sw $t5, 0($t3)
addi $t3, $t4,  224
sw $t5, 0($t3)
addi $t3, $t4,  228
sw $t5, 0($t3)
addi $t3, $t4,  232
sw $t5, 0($t3)
addi $t3, $t4,  236
sw $t5, 0($t3)
addi $t3, $t4,  240
sw $t5, 0($t3)
addi $t3, $t4,  244
sw $t5, 0($t3)
addi $t3, $t4,  248
sw $t5, 0($t3)
addi $t3, $t4,  252
sw $t5, 0($t3)
addi $t3, $t4,  256
sw $t5, 0($t3)
addi $t3, $t4,  260
sw $t5, 0($t3)
addi $t3, $t4,  264
sw $t5, 0($t3)
addi $t3, $t4,  268
sw $t5, 0($t3)
addi $t3, $t4,  272
sw $t5, 0($t3)
addi $t3, $t4,  276
sw $t5, 0($t3)
addi $t3, $t4,  280
sw $t5, 0($t3)
addi $t3, $t4,  284
sw $t5, 0($t3)
addi $t3, $t4,  288
sw $t5, 0($t3)
addi $t3, $t4,  292
sw $t5, 0($t3)
addi $t3, $t4,  296
sw $t5, 0($t3)
addi $t3, $t4,  300
sw $t5, 0($t3)
addi $t3, $t4,  304
sw $t5, 0($t3)
addi $t3, $t4,  308
sw $t5, 0($t3)
addi $t3, $t4,  312
sw $t5, 0($t3)
addi $t3, $t4,  316
sw $t5, 0($t3)
addi $t3, $t4,  320
sw $t5, 0($t3)
addi $t3, $t4,  324
sw $t5, 0($t3)
addi $t3, $t4,  328
sw $t5, 0($t3)
addi $t3, $t4,  332
sw $t5, 0($t3)
addi $t3, $t4,  336
sw $t5, 0($t3)
addi $t3, $t4,  340
sw $t5, 0($t3)
addi $t3, $t4,  344
sw $t5, 0($t3)
addi $t3, $t4,  348
sw $t5, 0($t3)
addi $t3, $t4,  352
sw $t5, 0($t3)
addi $t3, $t4,  356
sw $t5, 0($t3)
addi $t3, $t4,  360
sw $t5, 0($t3)
addi $t3, $t4,  364
sw $t5, 0($t3)
addi $t3, $t4,  368
sw $t5, 0($t3)
addi $t3, $t4,  372
sw $t5, 0($t3)
addi $t3, $t4,  376
sw $t5, 0($t3)
addi $t3, $t4,  380
sw $t5, 0($t3)
addi $t3, $t4,  384
sw $t5, 0($t3)
addi $t3, $t4,  388
sw $t5, 0($t3)
addi $t3, $t4,  392
sw $t5, 0($t3)
addi $t3, $t4,  396
sw $t5, 0($t3)
addi $t3, $t4,  400
sw $t5, 0($t3)
addi $t3, $t4,  404
sw $t5, 0($t3)
addi $t3, $t4,  408
sw $t5, 0($t3)
addi $t3, $t4,  412
sw $t5, 0($t3)
addi $t3, $t4,  416
sw $t5, 0($t3)
addi $t3, $t4,  420
sw $t5, 0($t3)
addi $t3, $t4,  424
sw $t5, 0($t3)
addi $t3, $t4,  428
sw $t5, 0($t3)
addi $t3, $t4,  432
sw $t5, 0($t3)
addi $t3, $t4,  436
sw $t5, 0($t3)
addi $t3, $t4,  440
sw $t5, 0($t3)
addi $t3, $t4,  444
sw $t5, 0($t3)
addi $t3, $t4,  448
sw $t5, 0($t3)
addi $t3, $t4,  452
sw $t5, 0($t3)
addi $t3, $t4,  456
sw $t5, 0($t3)
addi $t3, $t4,  460
sw $t5, 0($t3)
addi $t3, $t4,  464
sw $t5, 0($t3)
addi $t3, $t4,  468
sw $t5, 0($t3)
addi $t3, $t4,  472
sw $t5, 0($t3)
addi $t3, $t4,  476
sw $t5, 0($t3)
addi $t3, $t4,  480
sw $t5, 0($t3)
addi $t3, $t4,  484
sw $t5, 0($t3)
addi $t3, $t4,  488
sw $t5, 0($t3)
addi $t3, $t4,  492
sw $t5, 0($t3)
addi $t3, $t4,  496
sw $t5, 0($t3)
addi $t3, $t4,  500
sw $t5, 0($t3)
addi $t3, $t4,  504
sw $t5, 0($t3)
addi $t3, $t4,  508
sw $t5, 0($t3)
syscall #sleep for 30 ms
addi $t3, $t4,  512
sw $t5, 0($t3)
addi $t3, $t4,  516
sw $t5, 0($t3)
addi $t3, $t4,  520
sw $t5, 0($t3)
addi $t3, $t4,  524
sw $t5, 0($t3)
addi $t3, $t4,  528
sw $t5, 0($t3)
addi $t3, $t4,  532
sw $t5, 0($t3)
addi $t3, $t4,  536
sw $t5, 0($t3)
addi $t3, $t4,  540
sw $t5, 0($t3)
addi $t3, $t4,  544
sw $t5, 0($t3)
addi $t3, $t4,  548
sw $t5, 0($t3)
addi $t3, $t4,  552
sw $t5, 0($t3)
addi $t3, $t4,  556
sw $t5, 0($t3)
addi $t3, $t4,  560
sw $t5, 0($t3)
addi $t3, $t4,  564
sw $t5, 0($t3)
addi $t3, $t4,  568
sw $t5, 0($t3)
addi $t3, $t4,  572
sw $t5, 0($t3)
addi $t3, $t4,  576
sw $t5, 0($t3)
addi $t3, $t4,  580
sw $t5, 0($t3)
addi $t3, $t4,  584
sw $t5, 0($t3)
addi $t3, $t4,  588
sw $t5, 0($t3)
addi $t3, $t4,  592
sw $t5, 0($t3)
addi $t3, $t4,  596
sw $t5, 0($t3)
addi $t3, $t4,  600
sw $t5, 0($t3)
addi $t3, $t4,  604
sw $t5, 0($t3)
addi $t3, $t4,  608
sw $t5, 0($t3)
addi $t3, $t4,  612
sw $t5, 0($t3)
addi $t3, $t4,  616
sw $t5, 0($t3)
addi $t3, $t4,  620
sw $t5, 0($t3)
addi $t3, $t4,  624
sw $t5, 0($t3)
addi $t3, $t4,  628
sw $t5, 0($t3)
addi $t3, $t4,  632
sw $t5, 0($t3)
addi $t3, $t4,  636
sw $t5, 0($t3)
addi $t3, $t4,  640
sw $t5, 0($t3)
addi $t3, $t4,  644
sw $t5, 0($t3)
addi $t3, $t4,  648
sw $t5, 0($t3)
addi $t3, $t4,  652
sw $t5, 0($t3)
addi $t3, $t4,  656
sw $t5, 0($t3)
addi $t3, $t4,  660
sw $t5, 0($t3)
addi $t3, $t4,  664
sw $t5, 0($t3)
addi $t3, $t4,  668
sw $t5, 0($t3)
addi $t3, $t4,  672
sw $t5, 0($t3)
addi $t3, $t4,  676
sw $t5, 0($t3)
addi $t3, $t4,  680
sw $t5, 0($t3)
addi $t3, $t4,  684
sw $t5, 0($t3)
addi $t3, $t4,  688
sw $t5, 0($t3)
addi $t3, $t4,  692
sw $t5, 0($t3)
addi $t3, $t4,  696
sw $t5, 0($t3)
addi $t3, $t4,  700
sw $t5, 0($t3)
addi $t3, $t4,  704
sw $t5, 0($t3)
addi $t3, $t4,  708
sw $t5, 0($t3)
addi $t3, $t4,  712
sw $t5, 0($t3)
addi $t3, $t4,  716
sw $t5, 0($t3)
addi $t3, $t4,  720
sw $t5, 0($t3)
addi $t3, $t4,  724
sw $t5, 0($t3)
addi $t3, $t4,  728
sw $t5, 0($t3)
addi $t3, $t4,  732
sw $t5, 0($t3)
addi $t3, $t4,  736
sw $t5, 0($t3)
addi $t3, $t4,  740
sw $t5, 0($t3)
addi $t3, $t4,  744
sw $t5, 0($t3)
addi $t3, $t4,  748
sw $t5, 0($t3)
addi $t3, $t4,  752
sw $t5, 0($t3)
addi $t3, $t4,  756
sw $t5, 0($t3)
addi $t3, $t4,  760
sw $t5, 0($t3)
addi $t3, $t4,  764
sw $t5, 0($t3)
addi $t3, $t4,  768
sw $t5, 0($t3)
addi $t3, $t4,  772
sw $t5, 0($t3)
addi $t3, $t4,  776
sw $t5, 0($t3)
addi $t3, $t4,  780
sw $t5, 0($t3)
addi $t3, $t4,  784
sw $t5, 0($t3)
addi $t3, $t4,  788
sw $t5, 0($t3)
addi $t3, $t4,  792
sw $t5, 0($t3)
addi $t3, $t4,  796
sw $t5, 0($t3)
addi $t3, $t4,  800
sw $t5, 0($t3)
addi $t3, $t4,  804
sw $t5, 0($t3)
addi $t3, $t4,  808
sw $t5, 0($t3)
addi $t3, $t4,  812
sw $t5, 0($t3)
addi $t3, $t4,  816
sw $t5, 0($t3)
addi $t3, $t4,  820
sw $t5, 0($t3)
addi $t3, $t4,  824
sw $t5, 0($t3)
addi $t3, $t4,  828
sw $t5, 0($t3)
addi $t3, $t4,  832
sw $t5, 0($t3)
addi $t3, $t4,  836
sw $t5, 0($t3)
addi $t3, $t4,  840
sw $t5, 0($t3)
addi $t3, $t4,  844
sw $t5, 0($t3)
addi $t3, $t4,  848
sw $t5, 0($t3)
addi $t3, $t4,  852
sw $t5, 0($t3)
addi $t3, $t4,  856
sw $t5, 0($t3)
addi $t3, $t4,  860
sw $t5, 0($t3)
addi $t3, $t4,  864
sw $t5, 0($t3)
addi $t3, $t4,  868
sw $t5, 0($t3)
addi $t3, $t4,  872
sw $t5, 0($t3)
addi $t3, $t4,  876
sw $t5, 0($t3)
addi $t3, $t4,  880
sw $t5, 0($t3)
addi $t3, $t4,  884
sw $t5, 0($t3)
addi $t3, $t4,  888
sw $t5, 0($t3)
addi $t3, $t4,  892
sw $t5, 0($t3)
addi $t3, $t4,  896
sw $t5, 0($t3)
addi $t3, $t4,  900
sw $t5, 0($t3)
addi $t3, $t4,  904
sw $t5, 0($t3)
addi $t3, $t4,  908
sw $t5, 0($t3)
addi $t3, $t4,  912
sw $t5, 0($t3)
addi $t3, $t4,  916
sw $t5, 0($t3)
addi $t3, $t4,  920
sw $t5, 0($t3)
addi $t3, $t4,  924
sw $t5, 0($t3)
addi $t3, $t4,  928
sw $t5, 0($t3)
addi $t3, $t4,  932
sw $t5, 0($t3)
addi $t3, $t4,  936
sw $t5, 0($t3)
addi $t3, $t4,  940
sw $t5, 0($t3)
addi $t3, $t4,  944
sw $t5, 0($t3)
addi $t3, $t4,  948
sw $t5, 0($t3)
addi $t3, $t4,  952
sw $t5, 0($t3)
addi $t3, $t4,  956
sw $t5, 0($t3)
addi $t3, $t4,  960
sw $t5, 0($t3)
addi $t3, $t4,  964
sw $t5, 0($t3)
addi $t3, $t4,  968
sw $t5, 0($t3)
addi $t3, $t4,  972
sw $t5, 0($t3)
addi $t3, $t4,  976
sw $t5, 0($t3)
addi $t3, $t4,  980
sw $t5, 0($t3)
addi $t3, $t4,  984
sw $t5, 0($t3)
addi $t3, $t4,  988
sw $t5, 0($t3)
addi $t3, $t4,  992
sw $t5, 0($t3)
addi $t3, $t4,  996
sw $t5, 0($t3)
addi $t3, $t4,  1000
sw $t5, 0($t3)
addi $t3, $t4,  1004
sw $t5, 0($t3)
addi $t3, $t4,  1008
sw $t5, 0($t3)
addi $t3, $t4,  1012
sw $t5, 0($t3)
addi $t3, $t4,  1016
sw $t5, 0($t3)
addi $t3, $t4,  1020
sw $t5, 0($t3)
syscall #sleep for 30 ms
addi $t3, $t4,  1024
sw $t5, 0($t3)
addi $t3, $t4,  1028
sw $t5, 0($t3)
addi $t3, $t4,  1032
sw $t5, 0($t3)
addi $t3, $t4,  1036
sw $t5, 0($t3)
addi $t3, $t4,  1040
sw $t5, 0($t3)
addi $t3, $t4,  1044
sw $t5, 0($t3)
addi $t3, $t4,  1048
sw $t5, 0($t3)
addi $t3, $t4,  1052
sw $t5, 0($t3)
addi $t3, $t4,  1056
sw $t5, 0($t3)
addi $t3, $t4,  1060
sw $t5, 0($t3)
addi $t3, $t4,  1064
sw $t5, 0($t3)
addi $t3, $t4,  1068
sw $t5, 0($t3)
addi $t3, $t4,  1072
sw $t5, 0($t3)
addi $t3, $t4,  1076
sw $t5, 0($t3)
addi $t3, $t4,  1080
sw $t5, 0($t3)
addi $t3, $t4,  1084
sw $t5, 0($t3)
addi $t3, $t4,  1088
sw $t5, 0($t3)
addi $t3, $t4,  1092
sw $t5, 0($t3)
addi $t3, $t4,  1096
sw $t5, 0($t3)
addi $t3, $t4,  1100
sw $t5, 0($t3)
addi $t3, $t4,  1104
sw $t5, 0($t3)
addi $t3, $t4,  1108
sw $t5, 0($t3)
addi $t3, $t4,  1112
sw $t5, 0($t3)
addi $t3, $t4,  1116
sw $t5, 0($t3)
addi $t3, $t4,  1120
sw $t5, 0($t3)
addi $t3, $t4,  1124
sw $t5, 0($t3)
addi $t3, $t4,  1128
sw $t5, 0($t3)
addi $t3, $t4,  1132
sw $t5, 0($t3)
addi $t3, $t4,  1136
sw $t5, 0($t3)
addi $t3, $t4,  1140
sw $t5, 0($t3)
addi $t3, $t4,  1144
sw $t5, 0($t3)
addi $t3, $t4,  1148
sw $t5, 0($t3)
addi $t3, $t4,  1152
sw $t5, 0($t3)
addi $t3, $t4,  1156
sw $t5, 0($t3)
addi $t3, $t4,  1160
sw $t5, 0($t3)
addi $t3, $t4,  1164
sw $t5, 0($t3)
addi $t3, $t4,  1168
sw $t5, 0($t3)
addi $t3, $t4,  1172
sw $t5, 0($t3)
addi $t3, $t4,  1176
sw $t5, 0($t3)
addi $t3, $t4,  1180
sw $t5, 0($t3)
addi $t3, $t4,  1184
sw $t5, 0($t3)
addi $t3, $t4,  1188
sw $t5, 0($t3)
addi $t3, $t4,  1192
sw $t5, 0($t3)
addi $t3, $t4,  1196
sw $t5, 0($t3)
addi $t3, $t4,  1200
sw $t5, 0($t3)
addi $t3, $t4,  1204
sw $t5, 0($t3)
addi $t3, $t4,  1208
sw $t5, 0($t3)
addi $t3, $t4,  1212
sw $t5, 0($t3)
addi $t3, $t4,  1216
sw $t5, 0($t3)
addi $t3, $t4,  1220
sw $t5, 0($t3)
addi $t3, $t4,  1224
sw $t5, 0($t3)
addi $t3, $t4,  1228
sw $t5, 0($t3)
addi $t3, $t4,  1232
sw $t5, 0($t3)
addi $t3, $t4,  1236
sw $t5, 0($t3)
addi $t3, $t4,  1240
sw $t5, 0($t3)
addi $t3, $t4,  1244
sw $t5, 0($t3)
addi $t3, $t4,  1248
sw $t5, 0($t3)
addi $t3, $t4,  1252
sw $t5, 0($t3)
addi $t3, $t4,  1256
sw $t5, 0($t3)
addi $t3, $t4,  1260
sw $t5, 0($t3)
addi $t3, $t4,  1264
sw $t5, 0($t3)
addi $t3, $t4,  1268
sw $t5, 0($t3)
addi $t3, $t4,  1272
sw $t5, 0($t3)
addi $t3, $t4,  1276
sw $t5, 0($t3)
addi $t3, $t4,  1280
sw $t5, 0($t3)
addi $t3, $t4,  1284
sw $t5, 0($t3)
addi $t3, $t4,  1288
sw $t5, 0($t3)
addi $t3, $t4,  1292
sw $t5, 0($t3)
addi $t3, $t4,  1296
sw $t5, 0($t3)
addi $t3, $t4,  1300
sw $t5, 0($t3)
addi $t3, $t4,  1304
sw $t5, 0($t3)
addi $t3, $t4,  1308
sw $t5, 0($t3)
addi $t3, $t4,  1312
sw $t5, 0($t3)
addi $t3, $t4,  1316
sw $t5, 0($t3)
addi $t3, $t4,  1320
sw $t5, 0($t3)
addi $t3, $t4,  1324
sw $t5, 0($t3)
addi $t3, $t4,  1328
sw $t5, 0($t3)
addi $t3, $t4,  1332
sw $t5, 0($t3)
addi $t3, $t4,  1336
sw $t5, 0($t3)
addi $t3, $t4,  1340
sw $t5, 0($t3)
addi $t3, $t4,  1344
sw $t5, 0($t3)
addi $t3, $t4,  1348
sw $t5, 0($t3)
addi $t3, $t4,  1352
sw $t5, 0($t3)
addi $t3, $t4,  1356
sw $t5, 0($t3)
addi $t3, $t4,  1360
sw $t5, 0($t3)
addi $t3, $t4,  1364
sw $t5, 0($t3)
addi $t3, $t4,  1368
sw $t5, 0($t3)
addi $t3, $t4,  1372
sw $t5, 0($t3)
addi $t3, $t4,  1376
sw $t5, 0($t3)
addi $t3, $t4,  1380
sw $t5, 0($t3)
addi $t3, $t4,  1384
sw $t5, 0($t3)
addi $t3, $t4,  1388
sw $t5, 0($t3)
addi $t3, $t4,  1392
sw $t5, 0($t3)
addi $t3, $t4,  1396
sw $t5, 0($t3)
addi $t3, $t4,  1400
sw $t5, 0($t3)
addi $t3, $t4,  1404
sw $t5, 0($t3)
addi $t3, $t4,  1408
sw $t5, 0($t3)
addi $t3, $t4,  1412
sw $t5, 0($t3)
addi $t3, $t4,  1416
sw $t5, 0($t3)
addi $t3, $t4,  1420
sw $t5, 0($t3)
addi $t3, $t4,  1424
sw $t5, 0($t3)
addi $t3, $t4,  1428
sw $t5, 0($t3)
addi $t3, $t4,  1432
sw $t5, 0($t3)
addi $t3, $t4,  1436
sw $t5, 0($t3)
addi $t3, $t4,  1440
sw $t5, 0($t3)
addi $t3, $t4,  1444
sw $t5, 0($t3)
addi $t3, $t4,  1448
sw $t5, 0($t3)
addi $t3, $t4,  1452
sw $t5, 0($t3)
addi $t3, $t4,  1456
sw $t5, 0($t3)
addi $t3, $t4,  1460
sw $t5, 0($t3)
addi $t3, $t4,  1464
sw $t5, 0($t3)
addi $t3, $t4,  1468
sw $t5, 0($t3)
addi $t3, $t4,  1472
sw $t5, 0($t3)
addi $t3, $t4,  1476
sw $t5, 0($t3)
addi $t3, $t4,  1480
sw $t5, 0($t3)
addi $t3, $t4,  1484
sw $t5, 0($t3)
addi $t3, $t4,  1488
sw $t5, 0($t3)
addi $t3, $t4,  1492
sw $t5, 0($t3)
addi $t3, $t4,  1496
sw $t5, 0($t3)
addi $t3, $t4,  1500
sw $t5, 0($t3)
addi $t3, $t4,  1504
sw $t5, 0($t3)
addi $t3, $t4,  1508
sw $t5, 0($t3)
addi $t3, $t4,  1512
sw $t5, 0($t3)
addi $t3, $t4,  1516
sw $t5, 0($t3)
addi $t3, $t4,  1520
sw $t5, 0($t3)
addi $t3, $t4,  1524
sw $t5, 0($t3)
addi $t3, $t4,  1528
sw $t5, 0($t3)
addi $t3, $t4,  1532
sw $t5, 0($t3)
syscall #sleep for 30 ms
addi $t3, $t4,  1536
sw $t5, 0($t3)
addi $t3, $t4,  1540
sw $t5, 0($t3)
addi $t3, $t4,  1544
sw $t5, 0($t3)
addi $t3, $t4,  1548
sw $t5, 0($t3)
addi $t3, $t4,  1552
sw $t5, 0($t3)
addi $t3, $t4,  1556
sw $t5, 0($t3)
addi $t3, $t4,  1560
sw $t5, 0($t3)
addi $t3, $t4,  1564
sw $t5, 0($t3)
addi $t3, $t4,  1568
sw $t5, 0($t3)
addi $t3, $t4,  1572
sw $t5, 0($t3)
addi $t3, $t4,  1576
sw $t5, 0($t3)
addi $t3, $t4,  1580
sw $t5, 0($t3)
addi $t3, $t4,  1584
sw $t5, 0($t3)
addi $t3, $t4,  1588
sw $t5, 0($t3)
addi $t3, $t4,  1592
sw $t5, 0($t3)
addi $t3, $t4,  1596
sw $t5, 0($t3)
addi $t3, $t4,  1600
sw $t5, 0($t3)
addi $t3, $t4,  1604
sw $t5, 0($t3)
addi $t3, $t4,  1608
sw $t5, 0($t3)
addi $t3, $t4,  1612
sw $t5, 0($t3)
addi $t3, $t4,  1616
sw $t5, 0($t3)
addi $t3, $t4,  1620
sw $t5, 0($t3)
addi $t3, $t4,  1624
sw $t5, 0($t3)
addi $t3, $t4,  1628
sw $t5, 0($t3)
addi $t3, $t4,  1632
sw $t5, 0($t3)
addi $t3, $t4,  1636
sw $t5, 0($t3)
addi $t3, $t4,  1640
sw $t5, 0($t3)
addi $t3, $t4,  1644
sw $t5, 0($t3)
addi $t3, $t4,  1648
sw $t5, 0($t3)
addi $t3, $t4,  1652
sw $t5, 0($t3)
addi $t3, $t4,  1656
sw $t5, 0($t3)
addi $t3, $t4,  1660
sw $t5, 0($t3)
addi $t3, $t4,  1664
sw $t5, 0($t3)
addi $t3, $t4,  1668
sw $t5, 0($t3)
addi $t3, $t4,  1672
sw $t5, 0($t3)
addi $t3, $t4,  1676
sw $t5, 0($t3)
addi $t3, $t4,  1680
sw $t5, 0($t3)
addi $t3, $t4,  1684
sw $t5, 0($t3)
addi $t3, $t4,  1688
sw $t5, 0($t3)
addi $t3, $t4,  1692
sw $t5, 0($t3)
addi $t3, $t4,  1696
sw $t5, 0($t3)
addi $t3, $t4,  1700
sw $t5, 0($t3)
addi $t3, $t4,  1704
sw $t5, 0($t3)
addi $t3, $t4,  1708
sw $t5, 0($t3)
addi $t3, $t4,  1712
sw $t5, 0($t3)
addi $t3, $t4,  1716
sw $t5, 0($t3)
addi $t3, $t4,  1720
sw $t5, 0($t3)
addi $t3, $t4,  1724
sw $t5, 0($t3)
addi $t3, $t4,  1728
sw $t5, 0($t3)
addi $t3, $t4,  1732
sw $t5, 0($t3)
addi $t3, $t4,  1736
sw $t5, 0($t3)
addi $t3, $t4,  1740
sw $t5, 0($t3)
addi $t3, $t4,  1744
sw $t5, 0($t3)
addi $t3, $t4,  1748
sw $t5, 0($t3)
addi $t3, $t4,  1752
sw $t5, 0($t3)
addi $t3, $t4,  1756
sw $t5, 0($t3)
addi $t3, $t4,  1760
sw $t5, 0($t3)
addi $t3, $t4,  1764
sw $t5, 0($t3)
addi $t3, $t4,  1768
sw $t5, 0($t3)
addi $t3, $t4,  1772
sw $t5, 0($t3)
addi $t3, $t4,  1776
sw $t5, 0($t3)
addi $t3, $t4,  1780
sw $t5, 0($t3)
addi $t3, $t4,  1784
sw $t5, 0($t3)
addi $t3, $t4,  1788
sw $t5, 0($t3)
addi $t3, $t4,  1792
sw $t5, 0($t3)
addi $t3, $t4,  1796
sw $t5, 0($t3)
addi $t3, $t4,  1800
sw $t5, 0($t3)
addi $t3, $t4,  1804
sw $t5, 0($t3)
addi $t3, $t4,  1808
sw $t5, 0($t3)
addi $t3, $t4,  1812
sw $t5, 0($t3)
addi $t3, $t4,  1816
sw $t5, 0($t3)
addi $t3, $t4,  1820
sw $t5, 0($t3)
addi $t3, $t4,  1824
sw $t5, 0($t3)
addi $t3, $t4,  1828
sw $t5, 0($t3)
addi $t3, $t4,  1832
sw $t5, 0($t3)
addi $t3, $t4,  1836
sw $t5, 0($t3)
addi $t3, $t4,  1840
sw $t5, 0($t3)
addi $t3, $t4,  1844
sw $t5, 0($t3)
addi $t3, $t4,  1848
sw $t5, 0($t3)
addi $t3, $t4,  1852
sw $t5, 0($t3)
addi $t3, $t4,  1856
sw $t5, 0($t3)
addi $t3, $t4,  1860
sw $t5, 0($t3)
addi $t3, $t4,  1864
sw $t5, 0($t3)
addi $t3, $t4,  1868
sw $t5, 0($t3)
addi $t3, $t4,  1872
sw $t5, 0($t3)
addi $t3, $t4,  1876
sw $t5, 0($t3)
addi $t3, $t4,  1880
sw $t5, 0($t3)
addi $t3, $t4,  1884
sw $t5, 0($t3)
addi $t3, $t4,  1888
sw $t5, 0($t3)
addi $t3, $t4,  1892
sw $t5, 0($t3)
addi $t3, $t4,  1896
sw $t5, 0($t3)
addi $t3, $t4,  1900
sw $t5, 0($t3)
addi $t3, $t4,  1904
sw $t5, 0($t3)
addi $t3, $t4,  1908
sw $t5, 0($t3)
addi $t3, $t4,  1912
sw $t5, 0($t3)
addi $t3, $t4,  1916
sw $t5, 0($t3)
addi $t3, $t4,  1920
sw $t5, 0($t3)
addi $t3, $t4,  1924
sw $t5, 0($t3)
addi $t3, $t4,  1928
sw $t5, 0($t3)
addi $t3, $t4,  1932
sw $t5, 0($t3)
addi $t3, $t4,  1936
sw $t5, 0($t3)
addi $t3, $t4,  1940
sw $t5, 0($t3)
addi $t3, $t4,  1944
sw $t5, 0($t3)
addi $t3, $t4,  1948
sw $t5, 0($t3)
addi $t3, $t4,  1952
sw $t5, 0($t3)
addi $t3, $t4,  1956
sw $t5, 0($t3)
addi $t3, $t4,  1960
sw $t5, 0($t3)
addi $t3, $t4,  1964
sw $t5, 0($t3)
addi $t3, $t4,  1968
sw $t5, 0($t3)
addi $t3, $t4,  1972
sw $t5, 0($t3)
addi $t3, $t4,  1976
sw $t5, 0($t3)
addi $t3, $t4,  1980
sw $t5, 0($t3)
addi $t3, $t4,  1984
sw $t5, 0($t3)
addi $t3, $t4,  1988
sw $t5, 0($t3)
addi $t3, $t4,  1992
sw $t5, 0($t3)
addi $t3, $t4,  1996
sw $t5, 0($t3)
addi $t3, $t4,  2000
sw $t5, 0($t3)
addi $t3, $t4,  2004
sw $t5, 0($t3)
addi $t3, $t4,  2008
sw $t5, 0($t3)
addi $t3, $t4,  2012
sw $t5, 0($t3)
addi $t3, $t4,  2016
sw $t5, 0($t3)
addi $t3, $t4,  2020
sw $t5, 0($t3)
addi $t3, $t4,  2024
sw $t5, 0($t3)
addi $t3, $t4,  2028
sw $t5, 0($t3)
addi $t3, $t4,  2032
sw $t5, 0($t3)
addi $t3, $t4,  2036
sw $t5, 0($t3)
addi $t3, $t4,  2040
sw $t5, 0($t3)
addi $t3, $t4,  2044
sw $t5, 0($t3)
syscall #sleep for 30 ms
addi $t3, $t4,  2048
sw $t5, 0($t3)
addi $t3, $t4,  2052
sw $t5, 0($t3)
addi $t3, $t4,  2056
sw $t5, 0($t3)
addi $t3, $t4,  2060
sw $t5, 0($t3)
addi $t3, $t4,  2064
sw $t5, 0($t3)
addi $t3, $t4,  2068
sw $t5, 0($t3)
addi $t3, $t4,  2072
sw $t5, 0($t3)
addi $t3, $t4,  2076
sw $t5, 0($t3)
addi $t3, $t4,  2080
sw $t5, 0($t3)
addi $t3, $t4,  2084
sw $t5, 0($t3)
addi $t3, $t4,  2088
sw $t5, 0($t3)
addi $t3, $t4,  2092
sw $t5, 0($t3)
addi $t3, $t4,  2096
sw $t5, 0($t3)
addi $t3, $t4,  2100
sw $t5, 0($t3)
addi $t3, $t4,  2104
sw $t5, 0($t3)
addi $t3, $t4,  2108
sw $t5, 0($t3)
addi $t3, $t4,  2112
sw $t5, 0($t3)
addi $t3, $t4,  2116
sw $t5, 0($t3)
addi $t3, $t4,  2120
sw $t5, 0($t3)
addi $t3, $t4,  2124
sw $t5, 0($t3)
addi $t3, $t4,  2128
sw $t5, 0($t3)
addi $t3, $t4,  2132
sw $t5, 0($t3)
addi $t3, $t4,  2136
sw $t5, 0($t3)
addi $t3, $t4,  2140
sw $t5, 0($t3)
addi $t3, $t4,  2144
sw $t5, 0($t3)
addi $t3, $t4,  2148
sw $t5, 0($t3)
addi $t3, $t4,  2152
sw $t5, 0($t3)
addi $t3, $t4,  2156
sw $t5, 0($t3)
addi $t3, $t4,  2160
sw $t5, 0($t3)
addi $t3, $t4,  2164
sw $t5, 0($t3)
addi $t3, $t4,  2168
sw $t5, 0($t3)
addi $t3, $t4,  2172
sw $t5, 0($t3)
addi $t3, $t4,  2176
sw $t5, 0($t3)
addi $t3, $t4,  2180
sw $t5, 0($t3)
addi $t3, $t4,  2184
sw $t5, 0($t3)
addi $t3, $t4,  2188
sw $t5, 0($t3)
addi $t3, $t4,  2192
sw $t5, 0($t3)
addi $t3, $t4,  2196
sw $t5, 0($t3)
addi $t3, $t4,  2200
sw $t5, 0($t3)
addi $t3, $t4,  2204
sw $t5, 0($t3)
addi $t3, $t4,  2208
sw $t5, 0($t3)
addi $t3, $t4,  2212
sw $t5, 0($t3)
addi $t3, $t4,  2216
sw $t5, 0($t3)
addi $t3, $t4,  2220
sw $t5, 0($t3)
addi $t3, $t4,  2224
sw $t5, 0($t3)
addi $t3, $t4,  2228
sw $t5, 0($t3)
addi $t3, $t4,  2232
sw $t5, 0($t3)
addi $t3, $t4,  2236
sw $t5, 0($t3)
addi $t3, $t4,  2240
sw $t5, 0($t3)
addi $t3, $t4,  2244
sw $t5, 0($t3)
addi $t3, $t4,  2248
sw $t5, 0($t3)
addi $t3, $t4,  2252
sw $t5, 0($t3)
addi $t3, $t4,  2256
sw $t5, 0($t3)
addi $t3, $t4,  2260
sw $t5, 0($t3)
addi $t3, $t4,  2264
sw $t5, 0($t3)
addi $t3, $t4,  2268
sw $t5, 0($t3)
addi $t3, $t4,  2272
sw $t5, 0($t3)
addi $t3, $t4,  2276
sw $t5, 0($t3)
addi $t3, $t4,  2280
sw $t5, 0($t3)
addi $t3, $t4,  2284
sw $t5, 0($t3)
addi $t3, $t4,  2288
sw $t5, 0($t3)
addi $t3, $t4,  2292
sw $t5, 0($t3)
addi $t3, $t4,  2296
sw $t5, 0($t3)
addi $t3, $t4,  2300
sw $t5, 0($t3)
addi $t3, $t4,  2304
sw $t5, 0($t3)
addi $t3, $t4,  2308
sw $t5, 0($t3)
addi $t3, $t4,  2312
sw $t5, 0($t3)
addi $t3, $t4,  2316
sw $t5, 0($t3)
addi $t3, $t4,  2320
sw $t5, 0($t3)
addi $t3, $t4,  2324
sw $t5, 0($t3)
addi $t3, $t4,  2328
sw $t5, 0($t3)
addi $t3, $t4,  2332
sw $t5, 0($t3)
addi $t3, $t4,  2336
sw $t5, 0($t3)
addi $t3, $t4,  2340
sw $t5, 0($t3)
addi $t3, $t4,  2344
sw $t5, 0($t3)
addi $t3, $t4,  2348
sw $t5, 0($t3)
addi $t3, $t4,  2352
sw $t5, 0($t3)
addi $t3, $t4,  2356
sw $t5, 0($t3)
addi $t3, $t4,  2360
sw $t5, 0($t3)
addi $t3, $t4,  2364
sw $t5, 0($t3)
addi $t3, $t4,  2368
sw $t5, 0($t3)
addi $t3, $t4,  2372
sw $t5, 0($t3)
addi $t3, $t4,  2376
sw $t5, 0($t3)
addi $t3, $t4,  2380
sw $t5, 0($t3)
addi $t3, $t4,  2384
sw $t5, 0($t3)
addi $t3, $t4,  2388
sw $t5, 0($t3)
addi $t3, $t4,  2392
sw $t5, 0($t3)
addi $t3, $t4,  2396
sw $t5, 0($t3)
addi $t3, $t4,  2400
sw $t5, 0($t3)
addi $t3, $t4,  2404
sw $t5, 0($t3)
addi $t3, $t4,  2408
sw $t5, 0($t3)
addi $t3, $t4,  2412
sw $t5, 0($t3)
addi $t3, $t4,  2416
sw $t5, 0($t3)
addi $t3, $t4,  2420
sw $t5, 0($t3)
addi $t3, $t4,  2424
sw $t5, 0($t3)
addi $t3, $t4,  2428
sw $t5, 0($t3)
addi $t3, $t4,  2432
sw $t5, 0($t3)
addi $t3, $t4,  2436
sw $t5, 0($t3)
addi $t3, $t4,  2440
sw $t5, 0($t3)
addi $t3, $t4,  2444
sw $t5, 0($t3)
addi $t3, $t4,  2448
sw $t5, 0($t3)
addi $t3, $t4,  2452
sw $t5, 0($t3)
addi $t3, $t4,  2456
sw $t5, 0($t3)
addi $t3, $t4,  2460
sw $t5, 0($t3)
addi $t3, $t4,  2464
sw $t5, 0($t3)
addi $t3, $t4,  2468
sw $t5, 0($t3)
addi $t3, $t4,  2472
sw $t5, 0($t3)
addi $t3, $t4,  2476
sw $t5, 0($t3)
addi $t3, $t4,  2480
sw $t5, 0($t3)
addi $t3, $t4,  2484
sw $t5, 0($t3)
addi $t3, $t4,  2488
sw $t5, 0($t3)
addi $t3, $t4,  2492
sw $t5, 0($t3)
addi $t3, $t4,  2496
sw $t5, 0($t3)
addi $t3, $t4,  2500
sw $t5, 0($t3)
addi $t3, $t4,  2504
sw $t5, 0($t3)
addi $t3, $t4,  2508
sw $t5, 0($t3)
addi $t3, $t4,  2512
sw $t5, 0($t3)
addi $t3, $t4,  2516
sw $t5, 0($t3)
addi $t3, $t4,  2520
sw $t5, 0($t3)
addi $t3, $t4,  2524
sw $t5, 0($t3)
addi $t3, $t4,  2528
sw $t5, 0($t3)
addi $t3, $t4,  2532
sw $t5, 0($t3)
addi $t3, $t4,  2536
sw $t5, 0($t3)
addi $t3, $t4,  2540
sw $t5, 0($t3)
addi $t3, $t4,  2544
sw $t5, 0($t3)
addi $t3, $t4,  2548
sw $t5, 0($t3)
addi $t3, $t4,  2552
sw $t5, 0($t3)
addi $t3, $t4,  2556
sw $t5, 0($t3)
syscall #sleep for 30 ms
addi $t3, $t4,  2560
sw $t5, 0($t3)
addi $t3, $t4,  2564
sw $t5, 0($t3)
addi $t3, $t4,  2568
sw $t5, 0($t3)
addi $t3, $t4,  2572
sw $t5, 0($t3)
addi $t3, $t4,  2576
sw $t5, 0($t3)
addi $t3, $t4,  2580
sw $t5, 0($t3)
addi $t3, $t4,  2584
sw $t5, 0($t3)
addi $t3, $t4,  2588
sw $t5, 0($t3)
addi $t3, $t4,  2592
sw $t5, 0($t3)
addi $t3, $t4,  2596
sw $t5, 0($t3)
addi $t3, $t4,  2600
sw $t5, 0($t3)
addi $t3, $t4,  2604
sw $t5, 0($t3)
addi $t3, $t4,  2608
sw $t5, 0($t3)
addi $t3, $t4,  2612
sw $t5, 0($t3)
addi $t3, $t4,  2616
sw $t5, 0($t3)
addi $t3, $t4,  2620
sw $t5, 0($t3)
addi $t3, $t4,  2624
sw $t5, 0($t3)
addi $t3, $t4,  2628
sw $t5, 0($t3)
addi $t3, $t4,  2632
sw $t5, 0($t3)
addi $t3, $t4,  2636
sw $t5, 0($t3)
addi $t3, $t4,  2640
sw $t5, 0($t3)
addi $t3, $t4,  2644
sw $t5, 0($t3)
addi $t3, $t4,  2648
sw $t5, 0($t3)
addi $t3, $t4,  2652
sw $t5, 0($t3)
addi $t3, $t4,  2656
sw $t5, 0($t3)
addi $t3, $t4,  2660
sw $t5, 0($t3)
addi $t3, $t4,  2664
sw $t5, 0($t3)
addi $t3, $t4,  2668
sw $t5, 0($t3)
addi $t3, $t4,  2672
sw $t5, 0($t3)
addi $t3, $t4,  2676
sw $t5, 0($t3)
addi $t3, $t4,  2680
sw $t5, 0($t3)
addi $t3, $t4,  2684
sw $t5, 0($t3)
addi $t3, $t4,  2688
sw $t5, 0($t3)
addi $t3, $t4,  2692
sw $t5, 0($t3)
addi $t3, $t4,  2696
sw $t5, 0($t3)
addi $t3, $t4,  2700
sw $t5, 0($t3)
addi $t3, $t4,  2704
sw $t5, 0($t3)
addi $t3, $t4,  2708
sw $t5, 0($t3)
addi $t3, $t4,  2712
sw $t5, 0($t3)
addi $t3, $t4,  2716
sw $t5, 0($t3)
addi $t3, $t4,  2720
sw $t5, 0($t3)
addi $t3, $t4,  2724
sw $t5, 0($t3)
addi $t3, $t4,  2728
sw $t5, 0($t3)
addi $t3, $t4,  2732
sw $t5, 0($t3)
addi $t3, $t4,  2736
sw $t5, 0($t3)
addi $t3, $t4,  2740
sw $t5, 0($t3)
addi $t3, $t4,  2744
sw $t5, 0($t3)
addi $t3, $t4,  2748
sw $t5, 0($t3)
addi $t3, $t4,  2752
sw $t5, 0($t3)
addi $t3, $t4,  2756
sw $t5, 0($t3)
addi $t3, $t4,  2760
sw $t5, 0($t3)
addi $t3, $t4,  2764
sw $t5, 0($t3)
addi $t3, $t4,  2768
sw $t5, 0($t3)
addi $t3, $t4,  2772
sw $t5, 0($t3)
addi $t3, $t4,  2776
sw $t5, 0($t3)
addi $t3, $t4,  2780
sw $t5, 0($t3)
addi $t3, $t4,  2784
sw $t5, 0($t3)
addi $t3, $t4,  2788
sw $t5, 0($t3)
addi $t3, $t4,  2792
sw $t5, 0($t3)
addi $t3, $t4,  2796
sw $t5, 0($t3)
addi $t3, $t4,  2800
sw $t5, 0($t3)
addi $t3, $t4,  2804
sw $t5, 0($t3)
addi $t3, $t4,  2808
sw $t5, 0($t3)
addi $t3, $t4,  2812
sw $t5, 0($t3)
addi $t3, $t4,  2816
sw $t5, 0($t3)
addi $t3, $t4,  2820
sw $t5, 0($t3)
addi $t3, $t4,  2824
sw $t5, 0($t3)
addi $t3, $t4,  2828
sw $t5, 0($t3)
addi $t3, $t4,  2832
sw $t5, 0($t3)
addi $t3, $t4,  2836
sw $t5, 0($t3)
addi $t3, $t4,  2840
sw $t5, 0($t3)
addi $t3, $t4,  2844
sw $t5, 0($t3)
addi $t3, $t4,  2848
sw $t5, 0($t3)
addi $t3, $t4,  2852
sw $t5, 0($t3)
addi $t3, $t4,  2856
sw $t5, 0($t3)
addi $t3, $t4,  2860
sw $t5, 0($t3)
addi $t3, $t4,  2864
sw $t5, 0($t3)
addi $t3, $t4,  2868
sw $t5, 0($t3)
addi $t3, $t4,  2872
sw $t5, 0($t3)
addi $t3, $t4,  2876
sw $t5, 0($t3)
addi $t3, $t4,  2880
sw $t5, 0($t3)
addi $t3, $t4,  2884
sw $t5, 0($t3)
addi $t3, $t4,  2888
sw $t5, 0($t3)
addi $t3, $t4,  2892
sw $t5, 0($t3)
addi $t3, $t4,  2896
sw $t5, 0($t3)
addi $t3, $t4,  2900
sw $t5, 0($t3)
addi $t3, $t4,  2904
sw $t5, 0($t3)
addi $t3, $t4,  2908
sw $t5, 0($t3)
addi $t3, $t4,  2912
sw $t5, 0($t3)
addi $t3, $t4,  2916
sw $t5, 0($t3)
addi $t3, $t4,  2920
sw $t5, 0($t3)
addi $t3, $t4,  2924
sw $t5, 0($t3)
addi $t3, $t4,  2928
sw $t5, 0($t3)
addi $t3, $t4,  2932
sw $t5, 0($t3)
addi $t3, $t4,  2936
sw $t5, 0($t3)
addi $t3, $t4,  2940
sw $t5, 0($t3)
addi $t3, $t4,  2944
sw $t5, 0($t3)
addi $t3, $t4,  2948
sw $t5, 0($t3)
addi $t3, $t4,  2952
sw $t5, 0($t3)
addi $t3, $t4,  2956
sw $t5, 0($t3)
addi $t3, $t4,  2960
sw $t5, 0($t3)
addi $t3, $t4,  2964
sw $t5, 0($t3)
addi $t3, $t4,  2968
sw $t5, 0($t3)
addi $t3, $t4,  2972
sw $t5, 0($t3)
addi $t3, $t4,  2976
sw $t5, 0($t3)
addi $t3, $t4,  2980
sw $t5, 0($t3)
addi $t3, $t4,  2984
sw $t5, 0($t3)
addi $t3, $t4,  2988
sw $t5, 0($t3)
addi $t3, $t4,  2992
sw $t5, 0($t3)
addi $t3, $t4,  2996
sw $t5, 0($t3)
addi $t3, $t4,  3000
sw $t5, 0($t3)
addi $t3, $t4,  3004
sw $t5, 0($t3)
addi $t3, $t4,  3008
sw $t5, 0($t3)
addi $t3, $t4,  3012
sw $t5, 0($t3)
addi $t3, $t4,  3016
sw $t5, 0($t3)
addi $t3, $t4,  3020
sw $t5, 0($t3)
addi $t3, $t4,  3024
sw $t5, 0($t3)
addi $t3, $t4,  3028
sw $t5, 0($t3)
addi $t3, $t4,  3032
sw $t5, 0($t3)
addi $t3, $t4,  3036
sw $t5, 0($t3)
addi $t3, $t4,  3040
sw $t5, 0($t3)
addi $t3, $t4,  3044
sw $t5, 0($t3)
addi $t3, $t4,  3048
sw $t5, 0($t3)
addi $t3, $t4,  3052
sw $t5, 0($t3)
addi $t3, $t4,  3056
sw $t5, 0($t3)
addi $t3, $t4,  3060
sw $t5, 0($t3)
addi $t3, $t4,  3064
sw $t5, 0($t3)
addi $t3, $t4,  3068
sw $t5, 0($t3)
syscall #sleep for 30 ms
addi $t3, $t4,  3072
sw $t5, 0($t3)
addi $t3, $t4,  3076
sw $t5, 0($t3)
addi $t3, $t4,  3080
sw $t5, 0($t3)
addi $t3, $t4,  3084
sw $t5, 0($t3)
addi $t3, $t4,  3088
sw $t5, 0($t3)
addi $t3, $t4,  3092
sw $t5, 0($t3)
addi $t3, $t4,  3096
sw $t5, 0($t3)
addi $t3, $t4,  3100
sw $t5, 0($t3)
addi $t3, $t4,  3104
sw $t5, 0($t3)
addi $t3, $t4,  3108
sw $t5, 0($t3)
addi $t3, $t4,  3112
sw $t5, 0($t3)
addi $t3, $t4,  3116
sw $t5, 0($t3)
addi $t3, $t4,  3120
sw $t5, 0($t3)
addi $t3, $t4,  3124
sw $t5, 0($t3)
addi $t3, $t4,  3128
sw $t5, 0($t3)
addi $t3, $t4,  3132
sw $t5, 0($t3)
addi $t3, $t4,  3136
sw $t5, 0($t3)
addi $t3, $t4,  3140
sw $t5, 0($t3)
addi $t3, $t4,  3144
sw $t5, 0($t3)
addi $t3, $t4,  3148
sw $t5, 0($t3)
addi $t3, $t4,  3152
sw $t5, 0($t3)
addi $t3, $t4,  3156
sw $t5, 0($t3)
addi $t3, $t4,  3160
sw $t5, 0($t3)
addi $t3, $t4,  3164
sw $t5, 0($t3)
addi $t3, $t4,  3168
sw $t5, 0($t3)
addi $t3, $t4,  3172
sw $t5, 0($t3)
addi $t3, $t4,  3176
sw $t5, 0($t3)
addi $t3, $t4,  3180
sw $t5, 0($t3)
addi $t3, $t4,  3184
sw $t5, 0($t3)
addi $t3, $t4,  3188
sw $t5, 0($t3)
addi $t3, $t4,  3192
sw $t5, 0($t3)
addi $t3, $t4,  3196
sw $t5, 0($t3)
addi $t3, $t4,  3200
sw $t5, 0($t3)
addi $t3, $t4,  3204
sw $t5, 0($t3)
addi $t3, $t4,  3208
sw $t5, 0($t3)
addi $t3, $t4,  3212
sw $t5, 0($t3)
addi $t3, $t4,  3216
sw $t5, 0($t3)
addi $t3, $t4,  3220
sw $t5, 0($t3)
addi $t3, $t4,  3224
sw $t5, 0($t3)
addi $t3, $t4,  3228
sw $t5, 0($t3)
addi $t3, $t4,  3232
sw $t5, 0($t3)
addi $t3, $t4,  3236
sw $t5, 0($t3)
addi $t3, $t4,  3240
sw $t5, 0($t3)
addi $t3, $t4,  3244
sw $t5, 0($t3)
addi $t3, $t4,  3248
sw $t5, 0($t3)
addi $t3, $t4,  3252
sw $t5, 0($t3)
addi $t3, $t4,  3256
sw $t5, 0($t3)
addi $t3, $t4,  3260
sw $t5, 0($t3)
addi $t3, $t4,  3264
sw $t5, 0($t3)
addi $t3, $t4,  3268
sw $t5, 0($t3)
addi $t3, $t4,  3272
sw $t5, 0($t3)
addi $t3, $t4,  3276
sw $t5, 0($t3)
addi $t3, $t4,  3280
sw $t5, 0($t3)
addi $t3, $t4,  3284
sw $t5, 0($t3)
addi $t3, $t4,  3288
sw $t5, 0($t3)
addi $t3, $t4,  3292
sw $t5, 0($t3)
addi $t3, $t4,  3296
sw $t5, 0($t3)
addi $t3, $t4,  3300
sw $t5, 0($t3)
addi $t3, $t4,  3304
sw $t5, 0($t3)
addi $t3, $t4,  3308
sw $t5, 0($t3)
addi $t3, $t4,  3312
sw $t5, 0($t3)
addi $t3, $t4,  3316
sw $t5, 0($t3)
addi $t3, $t4,  3320
sw $t5, 0($t3)
addi $t3, $t4,  3324
sw $t5, 0($t3)
addi $t3, $t4,  3328
sw $t5, 0($t3)
addi $t3, $t4,  3332
sw $t5, 0($t3)
addi $t3, $t4,  3336
sw $t5, 0($t3)
addi $t3, $t4,  3340
sw $t5, 0($t3)
addi $t3, $t4,  3344
sw $t5, 0($t3)
addi $t3, $t4,  3348
sw $t5, 0($t3)
addi $t3, $t4,  3352
sw $t5, 0($t3)
addi $t3, $t4,  3356
sw $t5, 0($t3)
addi $t3, $t4,  3360
sw $t5, 0($t3)
addi $t3, $t4,  3364
sw $t5, 0($t3)
addi $t3, $t4,  3368
sw $t5, 0($t3)
addi $t3, $t4,  3372
sw $t5, 0($t3)
addi $t3, $t4,  3376
sw $t5, 0($t3)
addi $t3, $t4,  3380
sw $t5, 0($t3)
addi $t3, $t4,  3384
sw $t5, 0($t3)
addi $t3, $t4,  3388
sw $t5, 0($t3)
addi $t3, $t4,  3392
sw $t5, 0($t3)
addi $t3, $t4,  3396
sw $t5, 0($t3)
addi $t3, $t4,  3400
sw $t5, 0($t3)
addi $t3, $t4,  3404
sw $t5, 0($t3)
addi $t3, $t4,  3408
sw $t5, 0($t3)
addi $t3, $t4,  3412
sw $t5, 0($t3)
addi $t3, $t4,  3416
sw $t5, 0($t3)
addi $t3, $t4,  3420
sw $t5, 0($t3)
addi $t3, $t4,  3424
sw $t5, 0($t3)
addi $t3, $t4,  3428
sw $t5, 0($t3)
addi $t3, $t4,  3432
sw $t5, 0($t3)
addi $t3, $t4,  3436
sw $t5, 0($t3)
addi $t3, $t4,  3440
sw $t5, 0($t3)
addi $t3, $t4,  3444
sw $t5, 0($t3)
addi $t3, $t4,  3448
sw $t5, 0($t3)
addi $t3, $t4,  3452
sw $t5, 0($t3)
addi $t3, $t4,  3456
sw $t5, 0($t3)
addi $t3, $t4,  3460
sw $t5, 0($t3)
addi $t3, $t4,  3464
sw $t5, 0($t3)
addi $t3, $t4,  3468
sw $t5, 0($t3)
addi $t3, $t4,  3472
sw $t5, 0($t3)
addi $t3, $t4,  3476
sw $t5, 0($t3)
addi $t3, $t4,  3480
sw $t5, 0($t3)
addi $t3, $t4,  3484
sw $t5, 0($t3)
addi $t3, $t4,  3488
sw $t5, 0($t3)
addi $t3, $t4,  3492
sw $t5, 0($t3)
addi $t3, $t4,  3496
sw $t5, 0($t3)
addi $t3, $t4,  3500
sw $t5, 0($t3)
addi $t3, $t4,  3504
sw $t5, 0($t3)
addi $t3, $t4,  3508
sw $t5, 0($t3)
addi $t3, $t4,  3512
sw $t5, 0($t3)
addi $t3, $t4,  3516
sw $t5, 0($t3)
addi $t3, $t4,  3520
sw $t5, 0($t3)
addi $t3, $t4,  3524
sw $t5, 0($t3)
addi $t3, $t4,  3528
sw $t5, 0($t3)
addi $t3, $t4,  3532
sw $t5, 0($t3)
addi $t3, $t4,  3536
sw $t5, 0($t3)
addi $t3, $t4,  3540
sw $t5, 0($t3)
addi $t3, $t4,  3544
sw $t5, 0($t3)
addi $t3, $t4,  3548
sw $t5, 0($t3)
addi $t3, $t4,  3552
sw $t5, 0($t3)
addi $t3, $t4,  3556
sw $t5, 0($t3)
addi $t3, $t4,  3560
sw $t5, 0($t3)
addi $t3, $t4,  3564
sw $t5, 0($t3)
addi $t3, $t4,  3568
sw $t5, 0($t3)
addi $t3, $t4,  3572
sw $t5, 0($t3)
addi $t3, $t4,  3576
sw $t5, 0($t3)
addi $t3, $t4,  3580
sw $t5, 0($t3)
syscall #sleep for 30 ms
addi $t3, $t4,  3584
sw $t5, 0($t3)
addi $t3, $t4,  3588
sw $t5, 0($t3)
addi $t3, $t4,  3592
sw $t5, 0($t3)
addi $t3, $t4,  3596
sw $t5, 0($t3)
addi $t3, $t4,  3600
sw $t5, 0($t3)
addi $t3, $t4,  3604
sw $t5, 0($t3)
addi $t3, $t4,  3608
sw $t5, 0($t3)
addi $t3, $t4,  3612
sw $t5, 0($t3)
addi $t3, $t4,  3616
sw $t5, 0($t3)
addi $t3, $t4,  3620
sw $t5, 0($t3)
addi $t3, $t4,  3624
sw $t5, 0($t3)
addi $t3, $t4,  3628
sw $t5, 0($t3)
addi $t3, $t4,  3632
sw $t5, 0($t3)
addi $t3, $t4,  3636
sw $t5, 0($t3)
addi $t3, $t4,  3640
sw $t5, 0($t3)
addi $t3, $t4,  3644
sw $t5, 0($t3)
addi $t3, $t4,  3648
sw $t5, 0($t3)
addi $t3, $t4,  3652
sw $t5, 0($t3)
addi $t3, $t4,  3656
sw $t5, 0($t3)
addi $t3, $t4,  3660
sw $t5, 0($t3)
addi $t3, $t4,  3664
sw $t5, 0($t3)
addi $t3, $t4,  3668
sw $t5, 0($t3)
addi $t3, $t4,  3672
sw $t5, 0($t3)
addi $t3, $t4,  3676
sw $t5, 0($t3)
addi $t3, $t4,  3680
sw $t5, 0($t3)
addi $t3, $t4,  3684
sw $t5, 0($t3)
addi $t3, $t4,  3688
sw $t5, 0($t3)
addi $t3, $t4,  3692
sw $t5, 0($t3)
addi $t3, $t4,  3696
sw $t5, 0($t3)
addi $t3, $t4,  3700
sw $t5, 0($t3)
addi $t3, $t4,  3704
sw $t5, 0($t3)
addi $t3, $t4,  3708
sw $t5, 0($t3)
addi $t3, $t4,  3712
sw $t5, 0($t3)
addi $t3, $t4,  3716
sw $t5, 0($t3)
addi $t3, $t4,  3720
sw $t5, 0($t3)
addi $t3, $t4,  3724
sw $t5, 0($t3)
addi $t3, $t4,  3728
sw $t5, 0($t3)
addi $t3, $t4,  3732
sw $t5, 0($t3)
addi $t3, $t4,  3736
sw $t5, 0($t3)
addi $t3, $t4,  3740
sw $t5, 0($t3)
addi $t3, $t4,  3744
sw $t5, 0($t3)
addi $t3, $t4,  3748
sw $t5, 0($t3)
addi $t3, $t4,  3752
sw $t5, 0($t3)
addi $t3, $t4,  3756
sw $t5, 0($t3)
addi $t3, $t4,  3760
sw $t5, 0($t3)
addi $t3, $t4,  3764
sw $t5, 0($t3)
addi $t3, $t4,  3768
sw $t5, 0($t3)
addi $t3, $t4,  3772
sw $t5, 0($t3)
addi $t3, $t4,  3776
sw $t5, 0($t3)
addi $t3, $t4,  3780
sw $t5, 0($t3)
addi $t3, $t4,  3784
sw $t5, 0($t3)
addi $t3, $t4,  3788
sw $t5, 0($t3)
addi $t3, $t4,  3792
sw $t5, 0($t3)
addi $t3, $t4,  3796
sw $t5, 0($t3)
addi $t3, $t4,  3800
sw $t5, 0($t3)
addi $t3, $t4,  3804
sw $t5, 0($t3)
addi $t3, $t4,  3808
sw $t5, 0($t3)
addi $t3, $t4,  3812
sw $t5, 0($t3)
addi $t3, $t4,  3816
sw $t5, 0($t3)
addi $t3, $t4,  3820
sw $t5, 0($t3)
addi $t3, $t4,  3824
sw $t5, 0($t3)
addi $t3, $t4,  3828
sw $t5, 0($t3)
addi $t3, $t4,  3832
sw $t5, 0($t3)
addi $t3, $t4,  3836
sw $t5, 0($t3)
addi $t3, $t4,  3840
sw $t5, 0($t3)
addi $t3, $t4,  3844
sw $t5, 0($t3)
addi $t3, $t4,  3848
sw $t5, 0($t3)
addi $t3, $t4,  3852
sw $t5, 0($t3)
addi $t3, $t4,  3856
sw $t5, 0($t3)
addi $t3, $t4,  3860
sw $t5, 0($t3)
addi $t3, $t4,  3864
sw $t5, 0($t3)
addi $t3, $t4,  3868
sw $t5, 0($t3)
addi $t3, $t4,  3872
sw $t5, 0($t3)
addi $t3, $t4,  3876
sw $t5, 0($t3)
addi $t3, $t4,  3880
sw $t5, 0($t3)
addi $t3, $t4,  3884
sw $t5, 0($t3)
addi $t3, $t4,  3888
sw $t5, 0($t3)
addi $t3, $t4,  3892
sw $t5, 0($t3)
addi $t3, $t4,  3896
sw $t5, 0($t3)
addi $t3, $t4,  3900
sw $t5, 0($t3)
addi $t3, $t4,  3904
sw $t5, 0($t3)
addi $t3, $t4,  3908
sw $t5, 0($t3)
addi $t3, $t4,  3912
sw $t5, 0($t3)
addi $t3, $t4,  3916
sw $t5, 0($t3)
addi $t3, $t4,  3920
sw $t5, 0($t3)
addi $t3, $t4,  3924
sw $t5, 0($t3)
addi $t3, $t4,  3928
sw $t5, 0($t3)
addi $t3, $t4,  3932
sw $t5, 0($t3)
addi $t3, $t4,  3936
sw $t5, 0($t3)
addi $t3, $t4,  3940
sw $t5, 0($t3)
addi $t3, $t4,  3944
sw $t5, 0($t3)
addi $t3, $t4,  3948
sw $t5, 0($t3)
addi $t3, $t4,  3952
sw $t5, 0($t3)
addi $t3, $t4,  3956
sw $t5, 0($t3)
addi $t3, $t4,  3960
sw $t5, 0($t3)
addi $t3, $t4,  3964
sw $t5, 0($t3)
addi $t3, $t4,  3968
sw $t5, 0($t3)
addi $t3, $t4,  3972
sw $t5, 0($t3)
addi $t3, $t4,  3976
sw $t5, 0($t3)
addi $t3, $t4,  3980
sw $t5, 0($t3)
addi $t3, $t4,  3984
sw $t5, 0($t3)
addi $t3, $t4,  3988
sw $t5, 0($t3)
addi $t3, $t4,  3992
sw $t5, 0($t3)
addi $t3, $t4,  3996
sw $t5, 0($t3)
addi $t3, $t4,  4000
sw $t5, 0($t3)
addi $t3, $t4,  4004
sw $t5, 0($t3)
addi $t3, $t4,  4008
sw $t5, 0($t3)
addi $t3, $t4,  4012
sw $t5, 0($t3)
addi $t3, $t4,  4016
sw $t5, 0($t3)
addi $t3, $t4,  4020
sw $t5, 0($t3)
addi $t3, $t4,  4024
sw $t5, 0($t3)
addi $t3, $t4,  4028
sw $t5, 0($t3)
addi $t3, $t4,  4032
sw $t5, 0($t3)
addi $t3, $t4,  4036
sw $t5, 0($t3)
addi $t3, $t4,  4040
sw $t5, 0($t3)
addi $t3, $t4,  4044
sw $t5, 0($t3)
addi $t3, $t4,  4048
sw $t5, 0($t3)
addi $t3, $t4,  4052
sw $t5, 0($t3)
addi $t3, $t4,  4056
sw $t5, 0($t3)
addi $t3, $t4,  4060
sw $t5, 0($t3)
addi $t3, $t4,  4064
sw $t5, 0($t3)
addi $t3, $t4,  4068
sw $t5, 0($t3)
addi $t3, $t4,  4072
sw $t5, 0($t3)
addi $t3, $t4,  4076
sw $t5, 0($t3)
addi $t3, $t4,  4080
sw $t5, 0($t3)
addi $t3, $t4,  4084
sw $t5, 0($t3)
addi $t3, $t4,  4088
sw $t5, 0($t3)
addi $t3, $t4,  4092
sw $t5, 0($t3)
syscall #sleep for 30 ms
addi $t3, $t4,  4096
sw $t5, 0($t3)
addi $t3, $t4,  4100
sw $t5, 0($t3)
addi $t3, $t4,  4104
sw $t5, 0($t3)
addi $t3, $t4,  4108
sw $t5, 0($t3)
addi $t3, $t4,  4112
sw $t5, 0($t3)
addi $t3, $t4,  4116
sw $t5, 0($t3)
addi $t3, $t4,  4120
sw $t5, 0($t3)
addi $t3, $t4,  4124
sw $t5, 0($t3)
addi $t3, $t4,  4128
sw $t5, 0($t3)
addi $t3, $t4,  4132
sw $t5, 0($t3)
addi $t3, $t4,  4136
sw $t5, 0($t3)
addi $t3, $t4,  4140
sw $t5, 0($t3)
addi $t3, $t4,  4144
sw $t5, 0($t3)
addi $t3, $t4,  4148
sw $t5, 0($t3)
addi $t3, $t4,  4152
sw $t5, 0($t3)
addi $t3, $t4,  4156
sw $t5, 0($t3)
addi $t3, $t4,  4160
sw $t5, 0($t3)
addi $t3, $t4,  4164
sw $t5, 0($t3)
addi $t3, $t4,  4168
sw $t5, 0($t3)
addi $t3, $t4,  4172
sw $t5, 0($t3)
addi $t3, $t4,  4176
sw $t5, 0($t3)
addi $t3, $t4,  4180
sw $t5, 0($t3)
addi $t3, $t4,  4184
sw $t5, 0($t3)
addi $t3, $t4,  4188
sw $t5, 0($t3)
addi $t3, $t4,  4192
sw $t5, 0($t3)
addi $t3, $t4,  4196
sw $t5, 0($t3)
addi $t3, $t4,  4200
sw $t5, 0($t3)
addi $t3, $t4,  4204
sw $t5, 0($t3)
addi $t3, $t4,  4208
sw $t5, 0($t3)
addi $t3, $t4,  4212
sw $t5, 0($t3)
addi $t3, $t4,  4216
sw $t5, 0($t3)
addi $t3, $t4,  4220
sw $t5, 0($t3)
addi $t3, $t4,  4224
sw $t5, 0($t3)
addi $t3, $t4,  4228
sw $t5, 0($t3)
addi $t3, $t4,  4232
sw $t5, 0($t3)
addi $t3, $t4,  4236
sw $t5, 0($t3)
addi $t3, $t4,  4240
sw $t5, 0($t3)
addi $t3, $t4,  4244
sw $t5, 0($t3)
addi $t3, $t4,  4248
sw $t5, 0($t3)
addi $t3, $t4,  4252
sw $t5, 0($t3)
addi $t3, $t4,  4256
sw $t5, 0($t3)
addi $t3, $t4,  4260
sw $t5, 0($t3)
addi $t3, $t4,  4264
sw $t5, 0($t3)
addi $t3, $t4,  4268
sw $t5, 0($t3)
addi $t3, $t4,  4272
sw $t5, 0($t3)
addi $t3, $t4,  4276
sw $t5, 0($t3)
addi $t3, $t4,  4280
sw $t5, 0($t3)
addi $t3, $t4,  4284
sw $t5, 0($t3)
addi $t3, $t4,  4288
sw $t5, 0($t3)
addi $t3, $t4,  4292
sw $t5, 0($t3)
addi $t3, $t4,  4296
sw $t5, 0($t3)
addi $t3, $t4,  4300
sw $t5, 0($t3)
addi $t3, $t4,  4304
sw $t5, 0($t3)
addi $t3, $t4,  4308
sw $t5, 0($t3)
addi $t3, $t4,  4312
sw $t5, 0($t3)
addi $t3, $t4,  4316
sw $t5, 0($t3)
addi $t3, $t4,  4320
sw $t5, 0($t3)
addi $t3, $t4,  4324
sw $t5, 0($t3)
addi $t3, $t4,  4328
sw $t5, 0($t3)
addi $t3, $t4,  4332
sw $t5, 0($t3)
addi $t3, $t4,  4336
sw $t5, 0($t3)
addi $t3, $t4,  4340
sw $t5, 0($t3)
addi $t3, $t4,  4344
sw $t5, 0($t3)
addi $t3, $t4,  4348
sw $t5, 0($t3)
addi $t3, $t4,  4352
sw $t5, 0($t3)
addi $t3, $t4,  4356
sw $t5, 0($t3)
addi $t3, $t4,  4360
sw $t5, 0($t3)
addi $t3, $t4,  4364
sw $t5, 0($t3)
addi $t3, $t4,  4368
sw $t5, 0($t3)
addi $t3, $t4,  4372
sw $t5, 0($t3)
addi $t3, $t4,  4376
sw $t5, 0($t3)
addi $t3, $t4,  4380
sw $t5, 0($t3)
addi $t3, $t4,  4384
sw $t5, 0($t3)
addi $t3, $t4,  4388
sw $t5, 0($t3)
addi $t3, $t4,  4392
sw $t5, 0($t3)
addi $t3, $t4,  4396
sw $t5, 0($t3)
addi $t3, $t4,  4400
sw $t5, 0($t3)
addi $t3, $t4,  4404
sw $t5, 0($t3)
addi $t3, $t4,  4408
sw $t5, 0($t3)
addi $t3, $t4,  4412
sw $t5, 0($t3)
addi $t3, $t4,  4416
sw $t5, 0($t3)
addi $t3, $t4,  4420
sw $t5, 0($t3)
addi $t3, $t4,  4424
sw $t5, 0($t3)
addi $t3, $t4,  4428
sw $t5, 0($t3)
addi $t3, $t4,  4432
sw $t5, 0($t3)
addi $t3, $t4,  4436
sw $t5, 0($t3)
addi $t3, $t4,  4440
sw $t5, 0($t3)
addi $t3, $t4,  4444
sw $t5, 0($t3)
addi $t3, $t4,  4448
sw $t5, 0($t3)
addi $t3, $t4,  4452
sw $t5, 0($t3)
addi $t3, $t4,  4456
sw $t5, 0($t3)
addi $t3, $t4,  4460
sw $t5, 0($t3)
addi $t3, $t4,  4464
sw $t5, 0($t3)
addi $t3, $t4,  4468
sw $t5, 0($t3)
addi $t3, $t4,  4472
sw $t5, 0($t3)
addi $t3, $t4,  4476
sw $t5, 0($t3)
addi $t3, $t4,  4480
sw $t5, 0($t3)
addi $t3, $t4,  4484
sw $t5, 0($t3)
addi $t3, $t4,  4488
sw $t5, 0($t3)
addi $t3, $t4,  4492
sw $t5, 0($t3)
addi $t3, $t4,  4496
sw $t5, 0($t3)
addi $t3, $t4,  4500
sw $t5, 0($t3)
addi $t3, $t4,  4504
sw $t5, 0($t3)
addi $t3, $t4,  4508
sw $t5, 0($t3)
addi $t3, $t4,  4512
sw $t5, 0($t3)
addi $t3, $t4,  4516
sw $t5, 0($t3)
addi $t3, $t4,  4520
sw $t5, 0($t3)
addi $t3, $t4,  4524
sw $t5, 0($t3)
addi $t3, $t4,  4528
sw $t5, 0($t3)
addi $t3, $t4,  4532
sw $t5, 0($t3)
addi $t3, $t4,  4536
sw $t5, 0($t3)
addi $t3, $t4,  4540
sw $t5, 0($t3)
addi $t3, $t4,  4544
sw $t5, 0($t3)
addi $t3, $t4,  4548
sw $t5, 0($t3)
addi $t3, $t4,  4552
sw $t5, 0($t3)
addi $t3, $t4,  4556
sw $t5, 0($t3)
addi $t3, $t4,  4560
sw $t5, 0($t3)
addi $t3, $t4,  4564
sw $t5, 0($t3)
addi $t3, $t4,  4568
sw $t5, 0($t3)
addi $t3, $t4,  4572
sw $t5, 0($t3)
addi $t3, $t4,  4576
sw $t5, 0($t3)
addi $t3, $t4,  4580
sw $t5, 0($t3)
addi $t3, $t4,  4584
sw $t5, 0($t3)
addi $t3, $t4,  4588
sw $t5, 0($t3)
addi $t3, $t4,  4592
sw $t5, 0($t3)
addi $t3, $t4,  4596
sw $t5, 0($t3)
addi $t3, $t4,  4600
sw $t5, 0($t3)
addi $t3, $t4,  4604
sw $t5, 0($t3)
syscall #sleep for 30 ms
addi $t3, $t4,  4608
sw $t5, 0($t3)
addi $t3, $t4,  4612
sw $t5, 0($t3)
addi $t3, $t4,  4616
sw $t5, 0($t3)
addi $t3, $t4,  4620
sw $t5, 0($t3)
addi $t3, $t4,  4624
sw $t5, 0($t3)
addi $t3, $t4,  4628
sw $t5, 0($t3)
addi $t3, $t4,  4632
sw $t5, 0($t3)
addi $t3, $t4,  4636
sw $t5, 0($t3)
addi $t3, $t4,  4640
sw $t5, 0($t3)
addi $t3, $t4,  4644
sw $t5, 0($t3)
addi $t3, $t4,  4648
sw $t5, 0($t3)
addi $t3, $t4,  4652
sw $t5, 0($t3)
addi $t3, $t4,  4656
sw $t5, 0($t3)
addi $t3, $t4,  4660
sw $t5, 0($t3)
addi $t3, $t4,  4664
sw $t5, 0($t3)
addi $t3, $t4,  4668
sw $t5, 0($t3)
addi $t3, $t4,  4672
sw $t5, 0($t3)
addi $t3, $t4,  4676
sw $t5, 0($t3)
addi $t3, $t4,  4680
sw $t5, 0($t3)
addi $t3, $t4,  4684
sw $t5, 0($t3)
addi $t3, $t4,  4688
sw $t5, 0($t3)
addi $t3, $t4,  4692
sw $t5, 0($t3)
addi $t3, $t4,  4696
sw $t5, 0($t3)
addi $t3, $t4,  4700
sw $t5, 0($t3)
addi $t3, $t4,  4704
sw $t5, 0($t3)
addi $t3, $t4,  4708
sw $t5, 0($t3)
addi $t3, $t4,  4712
sw $t5, 0($t3)
addi $t3, $t4,  4716
sw $t5, 0($t3)
addi $t3, $t4,  4720
sw $t5, 0($t3)
addi $t3, $t4,  4724
sw $t5, 0($t3)
addi $t3, $t4,  4728
sw $t5, 0($t3)
addi $t3, $t4,  4732
sw $t5, 0($t3)
addi $t3, $t4,  4736
sw $t5, 0($t3)
addi $t3, $t4,  4740
sw $t5, 0($t3)
addi $t3, $t4,  4744
sw $t5, 0($t3)
addi $t3, $t4,  4748
sw $t5, 0($t3)
addi $t3, $t4,  4752
sw $t5, 0($t3)
addi $t3, $t4,  4756
sw $t5, 0($t3)
addi $t3, $t4,  4760
sw $t5, 0($t3)
addi $t3, $t4,  4764
sw $t5, 0($t3)
addi $t3, $t4,  4768
sw $t5, 0($t3)
addi $t3, $t4,  4772
sw $t5, 0($t3)
addi $t3, $t4,  4776
sw $t5, 0($t3)
addi $t3, $t4,  4780
sw $t5, 0($t3)
addi $t3, $t4,  4784
sw $t5, 0($t3)
addi $t3, $t4,  4788
sw $t5, 0($t3)
addi $t3, $t4,  4792
sw $t5, 0($t3)
addi $t3, $t4,  4796
sw $t5, 0($t3)
addi $t3, $t4,  4800
sw $t5, 0($t3)
addi $t3, $t4,  4804
sw $t5, 0($t3)
addi $t3, $t4,  4808
sw $t5, 0($t3)
addi $t3, $t4,  4812
sw $t5, 0($t3)
addi $t3, $t4,  4816
sw $t5, 0($t3)
addi $t3, $t4,  4820
sw $t5, 0($t3)
addi $t3, $t4,  4824
sw $t5, 0($t3)
addi $t3, $t4,  4828
sw $t5, 0($t3)
addi $t3, $t4,  4832
sw $t5, 0($t3)
addi $t3, $t4,  4836
sw $t5, 0($t3)
addi $t3, $t4,  4840
sw $t5, 0($t3)
addi $t3, $t4,  4844
sw $t5, 0($t3)
addi $t3, $t4,  4848
sw $t5, 0($t3)
addi $t3, $t4,  4852
sw $t5, 0($t3)
addi $t3, $t4,  4856
sw $t5, 0($t3)
addi $t3, $t4,  4860
sw $t5, 0($t3)
addi $t3, $t4,  4864
sw $t5, 0($t3)
addi $t3, $t4,  4868
sw $t5, 0($t3)
addi $t3, $t4,  4872
sw $t5, 0($t3)
addi $t3, $t4,  4876
sw $t5, 0($t3)
addi $t3, $t4,  4880
sw $t5, 0($t3)
addi $t3, $t4,  4884
sw $t5, 0($t3)
addi $t3, $t4,  4888
sw $t5, 0($t3)
addi $t3, $t4,  4892
sw $t5, 0($t3)
addi $t3, $t4,  4896
sw $t5, 0($t3)
addi $t3, $t4,  4900
sw $t5, 0($t3)
addi $t3, $t4,  4904
sw $t5, 0($t3)
addi $t3, $t4,  4908
sw $t5, 0($t3)
addi $t3, $t4,  4912
sw $t5, 0($t3)
addi $t3, $t4,  4916
sw $t5, 0($t3)
addi $t3, $t4,  4920
sw $t5, 0($t3)
addi $t3, $t4,  4924
sw $t5, 0($t3)
addi $t3, $t4,  4928
sw $t5, 0($t3)
addi $t3, $t4,  4932
sw $t5, 0($t3)
addi $t3, $t4,  4936
sw $t5, 0($t3)
addi $t3, $t4,  4940
sw $t5, 0($t3)
addi $t3, $t4,  4944
sw $t5, 0($t3)
addi $t3, $t4,  4948
sw $t5, 0($t3)
addi $t3, $t4,  4952
sw $t5, 0($t3)
addi $t3, $t4,  4956
sw $t5, 0($t3)
addi $t3, $t4,  4960
sw $t5, 0($t3)
addi $t3, $t4,  4964
sw $t5, 0($t3)
addi $t3, $t4,  4968
sw $t5, 0($t3)
addi $t3, $t4,  4972
sw $t5, 0($t3)
addi $t3, $t4,  4976
sw $t5, 0($t3)
addi $t3, $t4,  4980
sw $t5, 0($t3)
addi $t3, $t4,  4984
sw $t5, 0($t3)
addi $t3, $t4,  4988
sw $t5, 0($t3)
addi $t3, $t4,  4992
sw $t5, 0($t3)
addi $t3, $t4,  4996
sw $t5, 0($t3)
addi $t3, $t4,  5000
sw $t5, 0($t3)
addi $t3, $t4,  5004
sw $t5, 0($t3)
addi $t3, $t4,  5008
sw $t5, 0($t3)
addi $t3, $t4,  5012
sw $t5, 0($t3)
addi $t3, $t4,  5016
sw $t5, 0($t3)
addi $t3, $t4,  5020
sw $t5, 0($t3)
addi $t3, $t4,  5024
sw $t5, 0($t3)
addi $t3, $t4,  5028
sw $t5, 0($t3)
addi $t3, $t4,  5032
sw $t5, 0($t3)
addi $t3, $t4,  5036
sw $t5, 0($t3)
addi $t3, $t4,  5040
sw $t5, 0($t3)
addi $t3, $t4,  5044
sw $t5, 0($t3)
addi $t3, $t4,  5048
sw $t5, 0($t3)
addi $t3, $t4,  5052
sw $t5, 0($t3)
addi $t3, $t4,  5056
sw $t5, 0($t3)
addi $t3, $t4,  5060
sw $t5, 0($t3)
addi $t3, $t4,  5064
sw $t5, 0($t3)
addi $t3, $t4,  5068
sw $t5, 0($t3)
addi $t3, $t4,  5072
sw $t5, 0($t3)
addi $t3, $t4,  5076
sw $t5, 0($t3)
addi $t3, $t4,  5080
sw $t5, 0($t3)
addi $t3, $t4,  5084
sw $t5, 0($t3)
addi $t3, $t4,  5088
sw $t5, 0($t3)
addi $t3, $t4,  5092
sw $t5, 0($t3)
addi $t3, $t4,  5096
sw $t5, 0($t3)
addi $t3, $t4,  5100
sw $t5, 0($t3)
addi $t3, $t4,  5104
sw $t5, 0($t3)
addi $t3, $t4,  5108
sw $t5, 0($t3)
addi $t3, $t4,  5112
sw $t5, 0($t3)
addi $t3, $t4,  5116
sw $t5, 0($t3)
syscall #sleep for 30 ms
addi $t3, $t4,  5120
sw $t5, 0($t3)
addi $t3, $t4,  5124
sw $t5, 0($t3)
addi $t3, $t4,  5128
sw $t5, 0($t3)
addi $t3, $t4,  5132
sw $t5, 0($t3)
addi $t3, $t4,  5136
sw $t5, 0($t3)
addi $t3, $t4,  5140
sw $t5, 0($t3)
addi $t3, $t4,  5144
sw $t5, 0($t3)
addi $t3, $t4,  5148
sw $t5, 0($t3)
addi $t3, $t4,  5152
sw $t5, 0($t3)
addi $t3, $t4,  5156
sw $t5, 0($t3)
addi $t3, $t4,  5160
sw $t5, 0($t3)
addi $t3, $t4,  5164
sw $t5, 0($t3)
addi $t3, $t4,  5168
sw $t5, 0($t3)
addi $t3, $t4,  5172
sw $t5, 0($t3)
addi $t3, $t4,  5176
sw $t5, 0($t3)
addi $t3, $t4,  5180
sw $t5, 0($t3)
addi $t3, $t4,  5184
sw $t5, 0($t3)
addi $t3, $t4,  5188
sw $t5, 0($t3)
addi $t3, $t4,  5192
sw $t5, 0($t3)
addi $t3, $t4,  5196
sw $t5, 0($t3)
addi $t3, $t4,  5200
sw $t5, 0($t3)
addi $t3, $t4,  5204
sw $t5, 0($t3)
addi $t3, $t4,  5208
sw $t5, 0($t3)
addi $t3, $t4,  5212
sw $t5, 0($t3)
addi $t3, $t4,  5216
sw $t5, 0($t3)
addi $t3, $t4,  5220
sw $t5, 0($t3)
addi $t3, $t4,  5224
sw $t5, 0($t3)
addi $t3, $t4,  5228
sw $t5, 0($t3)
addi $t3, $t4,  5232
sw $t5, 0($t3)
addi $t3, $t4,  5236
sw $t5, 0($t3)
addi $t3, $t4,  5240
sw $t5, 0($t3)
addi $t3, $t4,  5244
sw $t5, 0($t3)
addi $t3, $t4,  5248
sw $t5, 0($t3)
addi $t3, $t4,  5252
sw $t5, 0($t3)
addi $t3, $t4,  5256
sw $t5, 0($t3)
addi $t3, $t4,  5260
sw $t5, 0($t3)
addi $t3, $t4,  5264
sw $t5, 0($t3)
addi $t3, $t4,  5268
sw $t5, 0($t3)
addi $t3, $t4,  5272
sw $t5, 0($t3)
addi $t3, $t4,  5276
sw $t5, 0($t3)
addi $t3, $t4,  5280
sw $t5, 0($t3)
addi $t3, $t4,  5284
sw $t5, 0($t3)
addi $t3, $t4,  5288
sw $t5, 0($t3)
addi $t3, $t4,  5292
sw $t5, 0($t3)
addi $t3, $t4,  5296
sw $t5, 0($t3)
addi $t3, $t4,  5300
sw $t5, 0($t3)
addi $t3, $t4,  5304
sw $t5, 0($t3)
addi $t3, $t4,  5308
sw $t5, 0($t3)
addi $t3, $t4,  5312
sw $t5, 0($t3)
addi $t3, $t4,  5316
sw $t5, 0($t3)
addi $t3, $t4,  5320
sw $t5, 0($t3)
addi $t3, $t4,  5324
sw $t5, 0($t3)
addi $t3, $t4,  5328
sw $t5, 0($t3)
addi $t3, $t4,  5332
sw $t5, 0($t3)
addi $t3, $t4,  5336
sw $t5, 0($t3)
addi $t3, $t4,  5340
sw $t5, 0($t3)
addi $t3, $t4,  5344
sw $t5, 0($t3)
addi $t3, $t4,  5348
sw $t5, 0($t3)
addi $t3, $t4,  5352
sw $t5, 0($t3)
addi $t3, $t4,  5356
sw $t5, 0($t3)
addi $t3, $t4,  5360
sw $t5, 0($t3)
addi $t3, $t4,  5364
sw $t5, 0($t3)
addi $t3, $t4,  5368
sw $t5, 0($t3)
addi $t3, $t4,  5372
sw $t5, 0($t3)
addi $t3, $t4,  5376
sw $t5, 0($t3)
addi $t3, $t4,  5380
sw $t5, 0($t3)
addi $t3, $t4,  5384
sw $t5, 0($t3)
addi $t3, $t4,  5388
sw $t5, 0($t3)
addi $t3, $t4,  5392
sw $t5, 0($t3)
addi $t3, $t4,  5396
sw $t5, 0($t3)
addi $t3, $t4,  5400
sw $t5, 0($t3)
addi $t3, $t4,  5404
sw $t5, 0($t3)
addi $t3, $t4,  5408
sw $t5, 0($t3)
addi $t3, $t4,  5412
sw $t5, 0($t3)
addi $t3, $t4,  5416
sw $t5, 0($t3)
addi $t3, $t4,  5420
sw $t5, 0($t3)
addi $t3, $t4,  5424
sw $t5, 0($t3)
addi $t3, $t4,  5428
sw $t5, 0($t3)
addi $t3, $t4,  5432
sw $t5, 0($t3)
addi $t3, $t4,  5436
sw $t5, 0($t3)
addi $t3, $t4,  5440
sw $t5, 0($t3)
addi $t3, $t4,  5444
sw $t5, 0($t3)
addi $t3, $t4,  5448
sw $t5, 0($t3)
addi $t3, $t4,  5452
sw $t5, 0($t3)
addi $t3, $t4,  5456
sw $t5, 0($t3)
addi $t3, $t4,  5460
sw $t5, 0($t3)
addi $t3, $t4,  5464
sw $t5, 0($t3)
addi $t3, $t4,  5468
sw $t5, 0($t3)
addi $t3, $t4,  5472
sw $t5, 0($t3)
addi $t3, $t4,  5476
sw $t5, 0($t3)
addi $t3, $t4,  5480
sw $t5, 0($t3)
addi $t3, $t4,  5484
sw $t5, 0($t3)
addi $t3, $t4,  5488
sw $t5, 0($t3)
addi $t3, $t4,  5492
sw $t5, 0($t3)
addi $t3, $t4,  5496
sw $t5, 0($t3)
addi $t3, $t4,  5500
sw $t5, 0($t3)
addi $t3, $t4,  5504
sw $t5, 0($t3)
addi $t3, $t4,  5508
sw $t5, 0($t3)
addi $t3, $t4,  5512
sw $t5, 0($t3)
addi $t3, $t4,  5516
sw $t5, 0($t3)
addi $t3, $t4,  5520
sw $t5, 0($t3)
addi $t3, $t4,  5524
sw $t5, 0($t3)
addi $t3, $t4,  5528
sw $t5, 0($t3)
addi $t3, $t4,  5532
sw $t5, 0($t3)
addi $t3, $t4,  5536
sw $t5, 0($t3)
addi $t3, $t4,  5540
sw $t5, 0($t3)
addi $t3, $t4,  5544
sw $t5, 0($t3)
addi $t3, $t4,  5548
sw $t5, 0($t3)
addi $t3, $t4,  5552
sw $t5, 0($t3)
addi $t3, $t4,  5556
sw $t5, 0($t3)
addi $t3, $t4,  5560
sw $t5, 0($t3)
addi $t3, $t4,  5564
sw $t5, 0($t3)
addi $t3, $t4,  5568
sw $t5, 0($t3)
addi $t3, $t4,  5572
sw $t5, 0($t3)
addi $t3, $t4,  5576
sw $t5, 0($t3)
addi $t3, $t4,  5580
sw $t5, 0($t3)
addi $t3, $t4,  5584
sw $t5, 0($t3)
addi $t3, $t4,  5588
sw $t5, 0($t3)
addi $t3, $t4,  5592
sw $t5, 0($t3)
addi $t3, $t4,  5596
sw $t5, 0($t3)
addi $t3, $t4,  5600
sw $t5, 0($t3)
addi $t3, $t4,  5604
sw $t5, 0($t3)
addi $t3, $t4,  5608
sw $t5, 0($t3)
addi $t3, $t4,  5612
sw $t5, 0($t3)
addi $t3, $t4,  5616
sw $t5, 0($t3)
addi $t3, $t4,  5620
sw $t5, 0($t3)
addi $t3, $t4,  5624
sw $t5, 0($t3)
addi $t3, $t4,  5628
sw $t5, 0($t3)
syscall #sleep for 30 ms
addi $t3, $t4,  5632
sw $t5, 0($t3)
addi $t3, $t4,  5636
sw $t5, 0($t3)
addi $t3, $t4,  5640
sw $t5, 0($t3)
addi $t3, $t4,  5644
sw $t5, 0($t3)
addi $t3, $t4,  5648
sw $t5, 0($t3)
addi $t3, $t4,  5652
sw $t5, 0($t3)
addi $t3, $t4,  5656
sw $t5, 0($t3)
addi $t3, $t4,  5660
sw $t5, 0($t3)
addi $t3, $t4,  5664
sw $t5, 0($t3)
addi $t3, $t4,  5668
sw $t5, 0($t3)
addi $t3, $t4,  5672
sw $t5, 0($t3)
addi $t3, $t4,  5676
sw $t5, 0($t3)
addi $t3, $t4,  5680
sw $t5, 0($t3)
addi $t3, $t4,  5684
sw $t5, 0($t3)
addi $t3, $t4,  5688
sw $t5, 0($t3)
addi $t3, $t4,  5692
sw $t5, 0($t3)
addi $t3, $t4,  5696
sw $t5, 0($t3)
addi $t3, $t4,  5700
sw $t5, 0($t3)
addi $t3, $t4,  5704
sw $t5, 0($t3)
addi $t3, $t4,  5708
sw $t5, 0($t3)
addi $t3, $t4,  5712
sw $t5, 0($t3)
addi $t3, $t4,  5716
sw $t5, 0($t3)
addi $t3, $t4,  5720
sw $t5, 0($t3)
addi $t3, $t4,  5724
sw $t5, 0($t3)
addi $t3, $t4,  5728
sw $t5, 0($t3)
addi $t3, $t4,  5732
sw $t5, 0($t3)
addi $t3, $t4,  5736
sw $t5, 0($t3)
addi $t3, $t4,  5740
sw $t5, 0($t3)
addi $t3, $t4,  5744
sw $t5, 0($t3)
addi $t3, $t4,  5748
sw $t5, 0($t3)
addi $t3, $t4,  5752
sw $t5, 0($t3)
addi $t3, $t4,  5756
sw $t5, 0($t3)
addi $t3, $t4,  5760
sw $t5, 0($t3)
addi $t3, $t4,  5764
sw $t5, 0($t3)
addi $t3, $t4,  5768
sw $t5, 0($t3)
addi $t3, $t4,  5772
sw $t5, 0($t3)
addi $t3, $t4,  5776
sw $t5, 0($t3)
addi $t3, $t4,  5780
sw $t5, 0($t3)
addi $t3, $t4,  5784
sw $t5, 0($t3)
addi $t3, $t4,  5788
sw $t5, 0($t3)
addi $t3, $t4,  5792
sw $t5, 0($t3)
addi $t3, $t4,  5796
sw $t5, 0($t3)
addi $t3, $t4,  5800
sw $t5, 0($t3)
addi $t3, $t4,  5804
sw $t5, 0($t3)
addi $t3, $t4,  5808
sw $t5, 0($t3)
addi $t3, $t4,  5812
sw $t5, 0($t3)
addi $t3, $t4,  5816
sw $t5, 0($t3)
addi $t3, $t4,  5820
sw $t5, 0($t3)
addi $t3, $t4,  5824
sw $t5, 0($t3)
addi $t3, $t4,  5828
sw $t5, 0($t3)
addi $t3, $t4,  5832
sw $t5, 0($t3)
addi $t3, $t4,  5836
sw $t5, 0($t3)
addi $t3, $t4,  5840
sw $t5, 0($t3)
addi $t3, $t4,  5844
sw $t5, 0($t3)
addi $t3, $t4,  5848
sw $t5, 0($t3)
addi $t3, $t4,  5852
sw $t5, 0($t3)
addi $t3, $t4,  5856
sw $t5, 0($t3)
addi $t3, $t4,  5860
sw $t5, 0($t3)
addi $t3, $t4,  5864
sw $t5, 0($t3)
addi $t3, $t4,  5868
sw $t5, 0($t3)
addi $t3, $t4,  5872
sw $t5, 0($t3)
addi $t3, $t4,  5876
sw $t5, 0($t3)
addi $t3, $t4,  5880
sw $t5, 0($t3)
addi $t3, $t4,  5884
sw $t5, 0($t3)
addi $t3, $t4,  5888
sw $t5, 0($t3)
addi $t3, $t4,  5892
sw $t5, 0($t3)
addi $t3, $t4,  5896
sw $t5, 0($t3)
addi $t3, $t4,  5900
sw $t5, 0($t3)
addi $t3, $t4,  5904
sw $t5, 0($t3)
addi $t3, $t4,  5908
sw $t5, 0($t3)
addi $t3, $t4,  5912
sw $t5, 0($t3)
addi $t3, $t4,  5916
sw $t5, 0($t3)
addi $t3, $t4,  5920
sw $t5, 0($t3)
addi $t3, $t4,  5924
sw $t5, 0($t3)
addi $t3, $t4,  5928
sw $t5, 0($t3)
addi $t3, $t4,  5932
sw $t5, 0($t3)
addi $t3, $t4,  5936
sw $t5, 0($t3)
addi $t3, $t4,  5940
sw $t5, 0($t3)
addi $t3, $t4,  5944
sw $t5, 0($t3)
addi $t3, $t4,  5948
sw $t5, 0($t3)
addi $t3, $t4,  5952
sw $t5, 0($t3)
addi $t3, $t4,  5956
sw $t5, 0($t3)
addi $t3, $t4,  5960
sw $t5, 0($t3)
addi $t3, $t4,  5964
sw $t5, 0($t3)
addi $t3, $t4,  5968
sw $t5, 0($t3)
addi $t3, $t4,  5972
sw $t5, 0($t3)
addi $t3, $t4,  5976
sw $t5, 0($t3)
addi $t3, $t4,  5980
sw $t5, 0($t3)
addi $t3, $t4,  5984
sw $t5, 0($t3)
addi $t3, $t4,  5988
sw $t5, 0($t3)
addi $t3, $t4,  5992
sw $t5, 0($t3)
addi $t3, $t4,  5996
sw $t5, 0($t3)
addi $t3, $t4,  6000
sw $t5, 0($t3)
addi $t3, $t4,  6004
sw $t5, 0($t3)
addi $t3, $t4,  6008
sw $t5, 0($t3)
addi $t3, $t4,  6012
sw $t5, 0($t3)
addi $t3, $t4,  6016
sw $t5, 0($t3)
addi $t3, $t4,  6020
sw $t5, 0($t3)
addi $t3, $t4,  6024
sw $t5, 0($t3)
addi $t3, $t4,  6028
sw $t5, 0($t3)
addi $t3, $t4,  6032
sw $t5, 0($t3)
addi $t3, $t4,  6036
sw $t5, 0($t3)
addi $t3, $t4,  6040
sw $t5, 0($t3)
addi $t3, $t4,  6044
sw $t5, 0($t3)
addi $t3, $t4,  6048
sw $t5, 0($t3)
addi $t3, $t4,  6052
sw $t5, 0($t3)
addi $t3, $t4,  6056
sw $t5, 0($t3)
addi $t3, $t4,  6060
sw $t5, 0($t3)
addi $t3, $t4,  6064
sw $t5, 0($t3)
addi $t3, $t4,  6068
sw $t5, 0($t3)
addi $t3, $t4,  6072
sw $t5, 0($t3)
addi $t3, $t4,  6076
sw $t5, 0($t3)
addi $t3, $t4,  6080
sw $t5, 0($t3)
addi $t3, $t4,  6084
sw $t5, 0($t3)
addi $t3, $t4,  6088
sw $t5, 0($t3)
addi $t3, $t4,  6092
sw $t5, 0($t3)
addi $t3, $t4,  6096
sw $t5, 0($t3)
addi $t3, $t4,  6100
sw $t5, 0($t3)
addi $t3, $t4,  6104
sw $t5, 0($t3)
addi $t3, $t4,  6108
sw $t5, 0($t3)
addi $t3, $t4,  6112
sw $t5, 0($t3)
addi $t3, $t4,  6116
sw $t5, 0($t3)
addi $t3, $t4,  6120
sw $t5, 0($t3)
addi $t3, $t4,  6124
sw $t5, 0($t3)
addi $t3, $t4,  6128
sw $t5, 0($t3)
addi $t3, $t4,  6132
sw $t5, 0($t3)
addi $t3, $t4,  6136
sw $t5, 0($t3)
addi $t3, $t4,  6140
sw $t5, 0($t3)
syscall #sleep for 30 ms
addi $t3, $t4,  6144
sw $t5, 0($t3)
addi $t3, $t4,  6148
sw $t5, 0($t3)
addi $t3, $t4,  6152
sw $t5, 0($t3)
addi $t3, $t4,  6156
sw $t5, 0($t3)
addi $t3, $t4,  6160
sw $t5, 0($t3)
addi $t3, $t4,  6164
sw $t5, 0($t3)
addi $t3, $t4,  6168
sw $t5, 0($t3)
addi $t3, $t4,  6172
sw $t5, 0($t3)
addi $t3, $t4,  6176
sw $t5, 0($t3)
addi $t3, $t4,  6180
sw $t5, 0($t3)
addi $t3, $t4,  6184
sw $t5, 0($t3)
addi $t3, $t4,  6188
sw $t5, 0($t3)
addi $t3, $t4,  6192
sw $t5, 0($t3)
addi $t3, $t4,  6196
sw $t5, 0($t3)
addi $t3, $t4,  6200
sw $t5, 0($t3)
addi $t3, $t4,  6204
sw $t5, 0($t3)
addi $t3, $t4,  6208
sw $t5, 0($t3)
addi $t3, $t4,  6212
sw $t5, 0($t3)
addi $t3, $t4,  6216
sw $t5, 0($t3)
addi $t3, $t4,  6220
sw $t5, 0($t3)
addi $t3, $t4,  6224
sw $t5, 0($t3)
addi $t3, $t4,  6228
sw $t5, 0($t3)
addi $t3, $t4,  6232
sw $t5, 0($t3)
addi $t3, $t4,  6236
sw $t5, 0($t3)
addi $t3, $t4,  6240
sw $t5, 0($t3)
addi $t3, $t4,  6244
sw $t5, 0($t3)
addi $t3, $t4,  6248
sw $t5, 0($t3)
addi $t3, $t4,  6252
sw $t5, 0($t3)
addi $t3, $t4,  6256
sw $t5, 0($t3)
addi $t3, $t4,  6260
sw $t5, 0($t3)
addi $t3, $t4,  6264
sw $t5, 0($t3)
addi $t3, $t4,  6268
sw $t5, 0($t3)
addi $t3, $t4,  6272
sw $t5, 0($t3)
addi $t3, $t4,  6276
sw $t5, 0($t3)
addi $t3, $t4,  6280
sw $t5, 0($t3)
addi $t3, $t4,  6284
sw $t5, 0($t3)
addi $t3, $t4,  6288
sw $t5, 0($t3)
addi $t3, $t4,  6292
sw $t5, 0($t3)
addi $t3, $t4,  6296
sw $t5, 0($t3)
addi $t3, $t4,  6300
sw $t5, 0($t3)
addi $t3, $t4,  6304
sw $t5, 0($t3)
addi $t3, $t4,  6308
sw $t5, 0($t3)
addi $t3, $t4,  6312
sw $t5, 0($t3)
addi $t3, $t4,  6316
sw $t5, 0($t3)
addi $t3, $t4,  6320
sw $t5, 0($t3)
addi $t3, $t4,  6324
sw $t5, 0($t3)
addi $t3, $t4,  6328
sw $t5, 0($t3)
addi $t3, $t4,  6332
sw $t5, 0($t3)
addi $t3, $t4,  6336
sw $t5, 0($t3)
addi $t3, $t4,  6340
sw $t5, 0($t3)
addi $t3, $t4,  6344
sw $t5, 0($t3)
addi $t3, $t4,  6348
sw $t5, 0($t3)
addi $t3, $t4,  6352
sw $t5, 0($t3)
addi $t3, $t4,  6356
sw $t5, 0($t3)
addi $t3, $t4,  6360
sw $t5, 0($t3)
addi $t3, $t4,  6364
sw $t5, 0($t3)
addi $t3, $t4,  6368
sw $t5, 0($t3)
addi $t3, $t4,  6372
sw $t5, 0($t3)
addi $t3, $t4,  6376
sw $t5, 0($t3)
addi $t3, $t4,  6380
sw $t5, 0($t3)
addi $t3, $t4,  6384
sw $t5, 0($t3)
addi $t3, $t4,  6388
sw $t5, 0($t3)
addi $t3, $t4,  6392
sw $t5, 0($t3)
addi $t3, $t4,  6396
sw $t5, 0($t3)
addi $t3, $t4,  6400
sw $t5, 0($t3)
addi $t3, $t4,  6404
sw $t5, 0($t3)
addi $t3, $t4,  6408
sw $t5, 0($t3)
addi $t3, $t4,  6412
sw $t5, 0($t3)
addi $t3, $t4,  6416
sw $t5, 0($t3)
addi $t3, $t4,  6420
sw $t5, 0($t3)
addi $t3, $t4,  6424
sw $t5, 0($t3)
addi $t3, $t4,  6428
sw $t5, 0($t3)
addi $t3, $t4,  6432
sw $t5, 0($t3)
addi $t3, $t4,  6436
sw $t5, 0($t3)
addi $t3, $t4,  6440
sw $t5, 0($t3)
addi $t3, $t4,  6444
sw $t5, 0($t3)
addi $t3, $t4,  6448
sw $t5, 0($t3)
addi $t3, $t4,  6452
sw $t5, 0($t3)
addi $t3, $t4,  6456
sw $t5, 0($t3)
addi $t3, $t4,  6460
sw $t5, 0($t3)
addi $t3, $t4,  6464
sw $t5, 0($t3)
addi $t3, $t4,  6468
sw $t5, 0($t3)
addi $t3, $t4,  6472
sw $t5, 0($t3)
addi $t3, $t4,  6476
sw $t5, 0($t3)
addi $t3, $t4,  6480
sw $t5, 0($t3)
addi $t3, $t4,  6484
sw $t5, 0($t3)
addi $t3, $t4,  6488
sw $t5, 0($t3)
addi $t3, $t4,  6492
sw $t5, 0($t3)
addi $t3, $t4,  6496
sw $t5, 0($t3)
addi $t3, $t4,  6500
sw $t5, 0($t3)
addi $t3, $t4,  6504
sw $t5, 0($t3)
addi $t3, $t4,  6508
sw $t5, 0($t3)
addi $t3, $t4,  6512
sw $t5, 0($t3)
addi $t3, $t4,  6516
sw $t5, 0($t3)
addi $t3, $t4,  6520
sw $t5, 0($t3)
addi $t3, $t4,  6524
sw $t5, 0($t3)
addi $t3, $t4,  6528
sw $t5, 0($t3)
addi $t3, $t4,  6532
sw $t5, 0($t3)
addi $t3, $t4,  6536
sw $t5, 0($t3)
addi $t3, $t4,  6540
sw $t5, 0($t3)
addi $t3, $t4,  6544
sw $t5, 0($t3)
addi $t3, $t4,  6548
sw $t5, 0($t3)
addi $t3, $t4,  6552
sw $t5, 0($t3)
addi $t3, $t4,  6556
sw $t5, 0($t3)
addi $t3, $t4,  6560
sw $t5, 0($t3)
addi $t3, $t4,  6564
sw $t5, 0($t3)
addi $t3, $t4,  6568
sw $t5, 0($t3)
addi $t3, $t4,  6572
sw $t5, 0($t3)
addi $t3, $t4,  6576
sw $t5, 0($t3)
addi $t3, $t4,  6580
sw $t5, 0($t3)
addi $t3, $t4,  6584
sw $t5, 0($t3)
addi $t3, $t4,  6588
sw $t5, 0($t3)
addi $t3, $t4,  6592
sw $t5, 0($t3)
addi $t3, $t4,  6596
sw $t5, 0($t3)
addi $t3, $t4,  6600
sw $t5, 0($t3)
addi $t3, $t4,  6604
sw $t5, 0($t3)
addi $t3, $t4,  6608
sw $t5, 0($t3)
addi $t3, $t4,  6612
sw $t5, 0($t3)
addi $t3, $t4,  6616
sw $t5, 0($t3)
addi $t3, $t4,  6620
sw $t5, 0($t3)
addi $t3, $t4,  6624
sw $t5, 0($t3)
addi $t3, $t4,  6628
sw $t5, 0($t3)
addi $t3, $t4,  6632
sw $t5, 0($t3)
addi $t3, $t4,  6636
sw $t5, 0($t3)
addi $t3, $t4,  6640
sw $t5, 0($t3)
addi $t3, $t4,  6644
sw $t5, 0($t3)
addi $t3, $t4,  6648
sw $t5, 0($t3)
addi $t3, $t4,  6652
sw $t5, 0($t3)
syscall #sleep for 30 ms
addi $t3, $t4,  6656
sw $t5, 0($t3)
addi $t3, $t4,  6660
sw $t5, 0($t3)
addi $t3, $t4,  6664
sw $t5, 0($t3)
addi $t3, $t4,  6668
sw $t5, 0($t3)
addi $t3, $t4,  6672
sw $t5, 0($t3)
addi $t3, $t4,  6676
sw $t5, 0($t3)
addi $t3, $t4,  6680
sw $t5, 0($t3)
addi $t3, $t4,  6684
sw $t5, 0($t3)
addi $t3, $t4,  6688
sw $t5, 0($t3)
addi $t3, $t4,  6692
sw $t5, 0($t3)
addi $t3, $t4,  6696
sw $t5, 0($t3)
addi $t3, $t4,  6700
sw $t5, 0($t3)
addi $t3, $t4,  6704
sw $t5, 0($t3)
addi $t3, $t4,  6708
sw $t5, 0($t3)
addi $t3, $t4,  6712
sw $t5, 0($t3)
addi $t3, $t4,  6716
sw $t5, 0($t3)
addi $t3, $t4,  6720
sw $t5, 0($t3)
addi $t3, $t4,  6724
sw $t5, 0($t3)
addi $t3, $t4,  6728
sw $t5, 0($t3)
addi $t3, $t4,  6732
sw $t5, 0($t3)
addi $t3, $t4,  6736
sw $t5, 0($t3)
addi $t3, $t4,  6740
sw $t5, 0($t3)
addi $t3, $t4,  6744
sw $t5, 0($t3)
addi $t3, $t4,  6748
sw $t5, 0($t3)
addi $t3, $t4,  6752
sw $t5, 0($t3)
addi $t3, $t4,  6756
li $t5, 0x000001
sw $t5, 0($t3)
addi $t3, $t4,  6760
sw $t5, 0($t3)
addi $t3, $t4,  6764
sw $t5, 0($t3)
addi $t3, $t4,  6768
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  6772
sw $t5, 0($t3)
addi $t3, $t4,  6776
sw $t5, 0($t3)
addi $t3, $t4,  6780
sw $t5, 0($t3)
addi $t3, $t4,  6784
sw $t5, 0($t3)
addi $t3, $t4,  6788
sw $t5, 0($t3)
addi $t3, $t4,  6792
sw $t5, 0($t3)
addi $t3, $t4,  6796
sw $t5, 0($t3)
addi $t3, $t4,  6800
sw $t5, 0($t3)
addi $t3, $t4,  6804
sw $t5, 0($t3)
addi $t3, $t4,  6808
sw $t5, 0($t3)
addi $t3, $t4,  6812
li $t5, 0x000002
sw $t5, 0($t3)
addi $t3, $t4,  6816
li $t5, 0x000001
sw $t5, 0($t3)
addi $t3, $t4,  6820
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  6824
sw $t5, 0($t3)
addi $t3, $t4,  6828
sw $t5, 0($t3)
addi $t3, $t4,  6832
sw $t5, 0($t3)
addi $t3, $t4,  6836
sw $t5, 0($t3)
addi $t3, $t4,  6840
sw $t5, 0($t3)
addi $t3, $t4,  6844
sw $t5, 0($t3)
addi $t3, $t4,  6848
sw $t5, 0($t3)
addi $t3, $t4,  6852
sw $t5, 0($t3)
addi $t3, $t4,  6856
sw $t5, 0($t3)
addi $t3, $t4,  6860
sw $t5, 0($t3)
addi $t3, $t4,  6864
sw $t5, 0($t3)
addi $t3, $t4,  6868
sw $t5, 0($t3)
addi $t3, $t4,  6872
sw $t5, 0($t3)
addi $t3, $t4,  6876
sw $t5, 0($t3)
addi $t3, $t4,  6880
sw $t5, 0($t3)
addi $t3, $t4,  6884
li $t5, 0x000002
sw $t5, 0($t3)
addi $t3, $t4,  6888
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  6892
sw $t5, 0($t3)
addi $t3, $t4,  6896
sw $t5, 0($t3)
addi $t3, $t4,  6900
sw $t5, 0($t3)
addi $t3, $t4,  6904
sw $t5, 0($t3)
addi $t3, $t4,  6908
sw $t5, 0($t3)
addi $t3, $t4,  6912
li $t5, 0x000001
sw $t5, 0($t3)
addi $t3, $t4,  6916
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  6920
li $t5, 0x000001
sw $t5, 0($t3)
addi $t3, $t4,  6924
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  6928
sw $t5, 0($t3)
addi $t3, $t4,  6932
sw $t5, 0($t3)
addi $t3, $t4,  6936
sw $t5, 0($t3)
addi $t3, $t4,  6940
sw $t5, 0($t3)
addi $t3, $t4,  6944
sw $t5, 0($t3)
addi $t3, $t4,  6948
sw $t5, 0($t3)
addi $t3, $t4,  6952
sw $t5, 0($t3)
addi $t3, $t4,  6956
sw $t5, 0($t3)
addi $t3, $t4,  6960
sw $t5, 0($t3)
addi $t3, $t4,  6964
sw $t5, 0($t3)
addi $t3, $t4,  6968
sw $t5, 0($t3)
addi $t3, $t4,  6972
sw $t5, 0($t3)
addi $t3, $t4,  6976
sw $t5, 0($t3)
addi $t3, $t4,  6980
sw $t5, 0($t3)
addi $t3, $t4,  6984
sw $t5, 0($t3)
addi $t3, $t4,  6988
sw $t5, 0($t3)
addi $t3, $t4,  6992
sw $t5, 0($t3)
addi $t3, $t4,  6996
sw $t5, 0($t3)
addi $t3, $t4,  7000
sw $t5, 0($t3)
addi $t3, $t4,  7004
li $t5, 0x000100
sw $t5, 0($t3)
addi $t3, $t4,  7008
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  7012
sw $t5, 0($t3)
addi $t3, $t4,  7016
sw $t5, 0($t3)
addi $t3, $t4,  7020
sw $t5, 0($t3)
addi $t3, $t4,  7024
sw $t5, 0($t3)
addi $t3, $t4,  7028
sw $t5, 0($t3)
addi $t3, $t4,  7032
sw $t5, 0($t3)
addi $t3, $t4,  7036
sw $t5, 0($t3)
addi $t3, $t4,  7040
sw $t5, 0($t3)
addi $t3, $t4,  7044
sw $t5, 0($t3)
addi $t3, $t4,  7048
sw $t5, 0($t3)
addi $t3, $t4,  7052
sw $t5, 0($t3)
addi $t3, $t4,  7056
sw $t5, 0($t3)
addi $t3, $t4,  7060
sw $t5, 0($t3)
addi $t3, $t4,  7064
sw $t5, 0($t3)
addi $t3, $t4,  7068
sw $t5, 0($t3)
addi $t3, $t4,  7072
sw $t5, 0($t3)
addi $t3, $t4,  7076
sw $t5, 0($t3)
addi $t3, $t4,  7080
li $t5, 0x000001
sw $t5, 0($t3)
addi $t3, $t4,  7084
li $t5, 0x000003
sw $t5, 0($t3)
addi $t3, $t4,  7088
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  7092
sw $t5, 0($t3)
addi $t3, $t4,  7096
sw $t5, 0($t3)
addi $t3, $t4,  7100
sw $t5, 0($t3)
addi $t3, $t4,  7104
sw $t5, 0($t3)
addi $t3, $t4,  7108
sw $t5, 0($t3)
addi $t3, $t4,  7112
sw $t5, 0($t3)
addi $t3, $t4,  7116
sw $t5, 0($t3)
addi $t3, $t4,  7120
sw $t5, 0($t3)
addi $t3, $t4,  7124
sw $t5, 0($t3)
addi $t3, $t4,  7128
sw $t5, 0($t3)
addi $t3, $t4,  7132
sw $t5, 0($t3)
addi $t3, $t4,  7136
sw $t5, 0($t3)
addi $t3, $t4,  7140
sw $t5, 0($t3)
addi $t3, $t4,  7144
sw $t5, 0($t3)
addi $t3, $t4,  7148
sw $t5, 0($t3)
addi $t3, $t4,  7152
sw $t5, 0($t3)
addi $t3, $t4,  7156
sw $t5, 0($t3)
addi $t3, $t4,  7160
sw $t5, 0($t3)
addi $t3, $t4,  7164
sw $t5, 0($t3)
syscall #sleep for 30 ms
addi $t3, $t4,  7168
sw $t5, 0($t3)
addi $t3, $t4,  7172
sw $t5, 0($t3)
addi $t3, $t4,  7176
sw $t5, 0($t3)
addi $t3, $t4,  7180
sw $t5, 0($t3)
addi $t3, $t4,  7184
sw $t5, 0($t3)
addi $t3, $t4,  7188
sw $t5, 0($t3)
addi $t3, $t4,  7192
sw $t5, 0($t3)
addi $t3, $t4,  7196
sw $t5, 0($t3)
addi $t3, $t4,  7200
sw $t5, 0($t3)
addi $t3, $t4,  7204
sw $t5, 0($t3)
addi $t3, $t4,  7208
sw $t5, 0($t3)
addi $t3, $t4,  7212
sw $t5, 0($t3)
addi $t3, $t4,  7216
sw $t5, 0($t3)
addi $t3, $t4,  7220
sw $t5, 0($t3)
addi $t3, $t4,  7224
sw $t5, 0($t3)
addi $t3, $t4,  7228
sw $t5, 0($t3)
addi $t3, $t4,  7232
sw $t5, 0($t3)
addi $t3, $t4,  7236
sw $t5, 0($t3)
addi $t3, $t4,  7240
sw $t5, 0($t3)
addi $t3, $t4,  7244
sw $t5, 0($t3)
addi $t3, $t4,  7248
sw $t5, 0($t3)
addi $t3, $t4,  7252
sw $t5, 0($t3)
addi $t3, $t4,  7256
sw $t5, 0($t3)
addi $t3, $t4,  7260
sw $t5, 0($t3)
addi $t3, $t4,  7264
sw $t5, 0($t3)
addi $t3, $t4,  7268
li $t5, 0x010000
sw $t5, 0($t3)
addi $t3, $t4,  7272
li $t5, 0xebff0a
sw $t5, 0($t3)
addi $t3, $t4,  7276
li $t5, 0xe9fe0a
sw $t5, 0($t3)
addi $t3, $t4,  7280
li $t5, 0xecfe00
sw $t5, 0($t3)
addi $t3, $t4,  7284
sw $t5, 0($t3)
addi $t3, $t4,  7288
sw $t5, 0($t3)
addi $t3, $t4,  7292
sw $t5, 0($t3)
addi $t3, $t4,  7296
sw $t5, 0($t3)
addi $t3, $t4,  7300
sw $t5, 0($t3)
addi $t3, $t4,  7304
sw $t5, 0($t3)
addi $t3, $t4,  7308
sw $t5, 0($t3)
addi $t3, $t4,  7312
sw $t5, 0($t3)
addi $t3, $t4,  7316
sw $t5, 0($t3)
addi $t3, $t4,  7320
li $t5, 0xecfb15
sw $t5, 0($t3)
addi $t3, $t4,  7324
li $t5, 0xe7ff00
sw $t5, 0($t3)
addi $t3, $t4,  7328
li $t5, 0x414111
sw $t5, 0($t3)
addi $t3, $t4,  7332
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  7336
sw $t5, 0($t3)
addi $t3, $t4,  7340
sw $t5, 0($t3)
addi $t3, $t4,  7344
sw $t5, 0($t3)
addi $t3, $t4,  7348
sw $t5, 0($t3)
addi $t3, $t4,  7352
li $t5, 0x000200
sw $t5, 0($t3)
addi $t3, $t4,  7356
li $t5, 0x020201
sw $t5, 0($t3)
addi $t3, $t4,  7360
li $t5, 0x889532
sw $t5, 0($t3)
addi $t3, $t4,  7364
li $t5, 0xeaff00
sw $t5, 0($t3)
addi $t3, $t4,  7368
sw $t5, 0($t3)
addi $t3, $t4,  7372
sw $t5, 0($t3)
addi $t3, $t4,  7376
sw $t5, 0($t3)
addi $t3, $t4,  7380
sw $t5, 0($t3)
addi $t3, $t4,  7384
sw $t5, 0($t3)
addi $t3, $t4,  7388
sw $t5, 0($t3)
addi $t3, $t4,  7392
li $t5, 0xedfc11
sw $t5, 0($t3)
addi $t3, $t4,  7396
li $t5, 0x090800
sw $t5, 0($t3)
addi $t3, $t4,  7400
li $t5, 0x000006
sw $t5, 0($t3)
addi $t3, $t4,  7404
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  7408
sw $t5, 0($t3)
addi $t3, $t4,  7412
sw $t5, 0($t3)
addi $t3, $t4,  7416
sw $t5, 0($t3)
addi $t3, $t4,  7420
sw $t5, 0($t3)
addi $t3, $t4,  7424
li $t5, 0x000202
sw $t5, 0($t3)
addi $t3, $t4,  7428
li $t5, 0xe8fc0d
sw $t5, 0($t3)
addi $t3, $t4,  7432
li $t5, 0xedfe00
sw $t5, 0($t3)
addi $t3, $t4,  7436
li $t5, 0xf0fd00
sw $t5, 0($t3)
addi $t3, $t4,  7440
sw $t5, 0($t3)
addi $t3, $t4,  7444
li $t5, 0xeefe00
sw $t5, 0($t3)
addi $t3, $t4,  7448
li $t5, 0xe4f722
sw $t5, 0($t3)
addi $t3, $t4,  7452
li $t5, 0x000103
sw $t5, 0($t3)
addi $t3, $t4,  7456
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  7460
sw $t5, 0($t3)
addi $t3, $t4,  7464
sw $t5, 0($t3)
addi $t3, $t4,  7468
sw $t5, 0($t3)
addi $t3, $t4,  7472
sw $t5, 0($t3)
addi $t3, $t4,  7476
sw $t5, 0($t3)
addi $t3, $t4,  7480
li $t5, 0x010101
sw $t5, 0($t3)
addi $t3, $t4,  7484
li $t5, 0xdde61c
sw $t5, 0($t3)
addi $t3, $t4,  7488
li $t5, 0xf1fe00
sw $t5, 0($t3)
addi $t3, $t4,  7492
li $t5, 0xf0fd00
sw $t5, 0($t3)
addi $t3, $t4,  7496
sw $t5, 0($t3)
addi $t3, $t4,  7500
sw $t5, 0($t3)
addi $t3, $t4,  7504
li $t5, 0xf1fe08
sw $t5, 0($t3)
addi $t3, $t4,  7508
li $t5, 0x060200
sw $t5, 0($t3)
addi $t3, $t4,  7512
li $t5, 0x000003
sw $t5, 0($t3)
addi $t3, $t4,  7516
li $t5, 0xecf81b
sw $t5, 0($t3)
addi $t3, $t4,  7520
li $t5, 0xf4fc00
sw $t5, 0($t3)
addi $t3, $t4,  7524
li $t5, 0xf0fd05
sw $t5, 0($t3)
addi $t3, $t4,  7528
li $t5, 0xf0fd00
sw $t5, 0($t3)
addi $t3, $t4,  7532
sw $t5, 0($t3)
addi $t3, $t4,  7536
sw $t5, 0($t3)
addi $t3, $t4,  7540
li $t5, 0xf1fe00
sw $t5, 0($t3)
addi $t3, $t4,  7544
sw $t5, 0($t3)
addi $t3, $t4,  7548
li $t5, 0xf0fd00
sw $t5, 0($t3)
addi $t3, $t4,  7552
sw $t5, 0($t3)
addi $t3, $t4,  7556
li $t5, 0xf1fe00
sw $t5, 0($t3)
addi $t3, $t4,  7560
sw $t5, 0($t3)
addi $t3, $t4,  7564
sw $t5, 0($t3)
addi $t3, $t4,  7568
li $t5, 0xf0fd00
sw $t5, 0($t3)
addi $t3, $t4,  7572
sw $t5, 0($t3)
addi $t3, $t4,  7576
li $t5, 0xf1fe00
sw $t5, 0($t3)
addi $t3, $t4,  7580
sw $t5, 0($t3)
addi $t3, $t4,  7584
sw $t5, 0($t3)
addi $t3, $t4,  7588
li $t5, 0xf3fd00
sw $t5, 0($t3)
addi $t3, $t4,  7592
li $t5, 0xedf701
sw $t5, 0($t3)
addi $t3, $t4,  7596
li $t5, 0x202000
sw $t5, 0($t3)
addi $t3, $t4,  7600
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  7604
sw $t5, 0($t3)
addi $t3, $t4,  7608
sw $t5, 0($t3)
addi $t3, $t4,  7612
sw $t5, 0($t3)
addi $t3, $t4,  7616
sw $t5, 0($t3)
addi $t3, $t4,  7620
sw $t5, 0($t3)
addi $t3, $t4,  7624
sw $t5, 0($t3)
addi $t3, $t4,  7628
sw $t5, 0($t3)
addi $t3, $t4,  7632
sw $t5, 0($t3)
addi $t3, $t4,  7636
sw $t5, 0($t3)
addi $t3, $t4,  7640
sw $t5, 0($t3)
addi $t3, $t4,  7644
sw $t5, 0($t3)
addi $t3, $t4,  7648
sw $t5, 0($t3)
addi $t3, $t4,  7652
sw $t5, 0($t3)
addi $t3, $t4,  7656
sw $t5, 0($t3)
addi $t3, $t4,  7660
sw $t5, 0($t3)
addi $t3, $t4,  7664
sw $t5, 0($t3)
addi $t3, $t4,  7668
sw $t5, 0($t3)
addi $t3, $t4,  7672
sw $t5, 0($t3)
addi $t3, $t4,  7676
sw $t5, 0($t3)
syscall #sleep for 30 ms
addi $t3, $t4,  7680
sw $t5, 0($t3)
addi $t3, $t4,  7684
sw $t5, 0($t3)
addi $t3, $t4,  7688
sw $t5, 0($t3)
addi $t3, $t4,  7692
sw $t5, 0($t3)
addi $t3, $t4,  7696
sw $t5, 0($t3)
addi $t3, $t4,  7700
sw $t5, 0($t3)
addi $t3, $t4,  7704
sw $t5, 0($t3)
addi $t3, $t4,  7708
sw $t5, 0($t3)
addi $t3, $t4,  7712
sw $t5, 0($t3)
addi $t3, $t4,  7716
sw $t5, 0($t3)
addi $t3, $t4,  7720
sw $t5, 0($t3)
addi $t3, $t4,  7724
sw $t5, 0($t3)
addi $t3, $t4,  7728
sw $t5, 0($t3)
addi $t3, $t4,  7732
sw $t5, 0($t3)
addi $t3, $t4,  7736
sw $t5, 0($t3)
addi $t3, $t4,  7740
sw $t5, 0($t3)
addi $t3, $t4,  7744
sw $t5, 0($t3)
addi $t3, $t4,  7748
sw $t5, 0($t3)
addi $t3, $t4,  7752
sw $t5, 0($t3)
addi $t3, $t4,  7756
sw $t5, 0($t3)
addi $t3, $t4,  7760
sw $t5, 0($t3)
addi $t3, $t4,  7764
sw $t5, 0($t3)
addi $t3, $t4,  7768
sw $t5, 0($t3)
addi $t3, $t4,  7772
sw $t5, 0($t3)
addi $t3, $t4,  7776
sw $t5, 0($t3)
addi $t3, $t4,  7780
li $t5, 0x020000
sw $t5, 0($t3)
addi $t3, $t4,  7784
li $t5, 0xedff03
sw $t5, 0($t3)
addi $t3, $t4,  7788
li $t5, 0xebff00
sw $t5, 0($t3)
addi $t3, $t4,  7792
li $t5, 0xebfd08
sw $t5, 0($t3)
addi $t3, $t4,  7796
sw $t5, 0($t3)
addi $t3, $t4,  7800
sw $t5, 0($t3)
addi $t3, $t4,  7804
sw $t5, 0($t3)
addi $t3, $t4,  7808
sw $t5, 0($t3)
addi $t3, $t4,  7812
li $t5, 0xecfe09
sw $t5, 0($t3)
addi $t3, $t4,  7816
sw $t5, 0($t3)
addi $t3, $t4,  7820
sw $t5, 0($t3)
addi $t3, $t4,  7824
sw $t5, 0($t3)
addi $t3, $t4,  7828
li $t5, 0xedff0a
sw $t5, 0($t3)
addi $t3, $t4,  7832
li $t5, 0xf3fd00
sw $t5, 0($t3)
addi $t3, $t4,  7836
li $t5, 0xecff03
sw $t5, 0($t3)
addi $t3, $t4,  7840
li $t5, 0x41460d
sw $t5, 0($t3)
addi $t3, $t4,  7844
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  7848
sw $t5, 0($t3)
addi $t3, $t4,  7852
sw $t5, 0($t3)
addi $t3, $t4,  7856
sw $t5, 0($t3)
addi $t3, $t4,  7860
sw $t5, 0($t3)
addi $t3, $t4,  7864
li $t5, 0x000100
sw $t5, 0($t3)
addi $t3, $t4,  7868
li $t5, 0x010300
sw $t5, 0($t3)
addi $t3, $t4,  7872
li $t5, 0x8b9834
sw $t5, 0($t3)
addi $t3, $t4,  7876
li $t5, 0xecff06
sw $t5, 0($t3)
addi $t3, $t4,  7880
sw $t5, 0($t3)
addi $t3, $t4,  7884
sw $t5, 0($t3)
addi $t3, $t4,  7888
sw $t5, 0($t3)
addi $t3, $t4,  7892
sw $t5, 0($t3)
addi $t3, $t4,  7896
sw $t5, 0($t3)
addi $t3, $t4,  7900
sw $t5, 0($t3)
addi $t3, $t4,  7904
li $t5, 0xecfd02
sw $t5, 0($t3)
addi $t3, $t4,  7908
li $t5, 0x070300
sw $t5, 0($t3)
addi $t3, $t4,  7912
li $t5, 0x000004
sw $t5, 0($t3)
addi $t3, $t4,  7916
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  7920
sw $t5, 0($t3)
addi $t3, $t4,  7924
sw $t5, 0($t3)
addi $t3, $t4,  7928
sw $t5, 0($t3)
addi $t3, $t4,  7932
sw $t5, 0($t3)
addi $t3, $t4,  7936
li $t5, 0x010300
sw $t5, 0($t3)
addi $t3, $t4,  7940
li $t5, 0xebfe02
sw $t5, 0($t3)
addi $t3, $t4,  7944
li $t5, 0xeefd0c
sw $t5, 0($t3)
addi $t3, $t4,  7948
li $t5, 0xedff06
sw $t5, 0($t3)
addi $t3, $t4,  7952
sw $t5, 0($t3)
addi $t3, $t4,  7956
li $t5, 0xf0fe00
sw $t5, 0($t3)
addi $t3, $t4,  7960
li $t5, 0xebfe06
sw $t5, 0($t3)
addi $t3, $t4,  7964
li $t5, 0x020500
sw $t5, 0($t3)
addi $t3, $t4,  7968
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  7972
sw $t5, 0($t3)
addi $t3, $t4,  7976
sw $t5, 0($t3)
addi $t3, $t4,  7980
sw $t5, 0($t3)
addi $t3, $t4,  7984
sw $t5, 0($t3)
addi $t3, $t4,  7988
sw $t5, 0($t3)
addi $t3, $t4,  7992
sw $t5, 0($t3)
addi $t3, $t4,  7996
li $t5, 0xdbe52a
sw $t5, 0($t3)
addi $t3, $t4,  8000
li $t5, 0xeefe07
sw $t5, 0($t3)
addi $t3, $t4,  8004
li $t5, 0xedfe05
sw $t5, 0($t3)
addi $t3, $t4,  8008
li $t5, 0xedff06
sw $t5, 0($t3)
addi $t3, $t4,  8012
sw $t5, 0($t3)
addi $t3, $t4,  8016
li $t5, 0xf1fd01
sw $t5, 0($t3)
addi $t3, $t4,  8020
li $t5, 0x030400
sw $t5, 0($t3)
addi $t3, $t4,  8024
li $t5, 0x020001
sw $t5, 0($t3)
addi $t3, $t4,  8028
li $t5, 0xedfb2b
sw $t5, 0($t3)
addi $t3, $t4,  8032
li $t5, 0xf0fd07
sw $t5, 0($t3)
addi $t3, $t4,  8036
li $t5, 0xedff01
sw $t5, 0($t3)
addi $t3, $t4,  8040
li $t5, 0xedff06
sw $t5, 0($t3)
addi $t3, $t4,  8044
sw $t5, 0($t3)
addi $t3, $t4,  8048
sw $t5, 0($t3)
addi $t3, $t4,  8052
sw $t5, 0($t3)
addi $t3, $t4,  8056
sw $t5, 0($t3)
addi $t3, $t4,  8060
sw $t5, 0($t3)
addi $t3, $t4,  8064
sw $t5, 0($t3)
addi $t3, $t4,  8068
sw $t5, 0($t3)
addi $t3, $t4,  8072
li $t5, 0xedff07
sw $t5, 0($t3)
addi $t3, $t4,  8076
li $t5, 0xeeff07
sw $t5, 0($t3)
addi $t3, $t4,  8080
li $t5, 0xedff06
sw $t5, 0($t3)
addi $t3, $t4,  8084
li $t5, 0xeeff07
sw $t5, 0($t3)
addi $t3, $t4,  8088
sw $t5, 0($t3)
addi $t3, $t4,  8092
sw $t5, 0($t3)
addi $t3, $t4,  8096
sw $t5, 0($t3)
addi $t3, $t4,  8100
li $t5, 0xeffd0b
sw $t5, 0($t3)
addi $t3, $t4,  8104
li $t5, 0xf3ff06
sw $t5, 0($t3)
addi $t3, $t4,  8108
li $t5, 0x1a1a00
sw $t5, 0($t3)
addi $t3, $t4,  8112
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  8116
sw $t5, 0($t3)
addi $t3, $t4,  8120
sw $t5, 0($t3)
addi $t3, $t4,  8124
sw $t5, 0($t3)
addi $t3, $t4,  8128
sw $t5, 0($t3)
addi $t3, $t4,  8132
sw $t5, 0($t3)
addi $t3, $t4,  8136
sw $t5, 0($t3)
addi $t3, $t4,  8140
sw $t5, 0($t3)
addi $t3, $t4,  8144
sw $t5, 0($t3)
addi $t3, $t4,  8148
sw $t5, 0($t3)
addi $t3, $t4,  8152
sw $t5, 0($t3)
addi $t3, $t4,  8156
sw $t5, 0($t3)
addi $t3, $t4,  8160
sw $t5, 0($t3)
addi $t3, $t4,  8164
sw $t5, 0($t3)
addi $t3, $t4,  8168
sw $t5, 0($t3)
addi $t3, $t4,  8172
sw $t5, 0($t3)
addi $t3, $t4,  8176
sw $t5, 0($t3)
addi $t3, $t4,  8180
sw $t5, 0($t3)
addi $t3, $t4,  8184
sw $t5, 0($t3)
addi $t3, $t4,  8188
sw $t5, 0($t3)
syscall #sleep for 30 ms
addi $t3, $t4,  8192
sw $t5, 0($t3)
addi $t3, $t4,  8196
sw $t5, 0($t3)
addi $t3, $t4,  8200
sw $t5, 0($t3)
addi $t3, $t4,  8204
sw $t5, 0($t3)
addi $t3, $t4,  8208
sw $t5, 0($t3)
addi $t3, $t4,  8212
sw $t5, 0($t3)
addi $t3, $t4,  8216
sw $t5, 0($t3)
addi $t3, $t4,  8220
sw $t5, 0($t3)
addi $t3, $t4,  8224
sw $t5, 0($t3)
addi $t3, $t4,  8228
sw $t5, 0($t3)
addi $t3, $t4,  8232
sw $t5, 0($t3)
addi $t3, $t4,  8236
sw $t5, 0($t3)
addi $t3, $t4,  8240
sw $t5, 0($t3)
addi $t3, $t4,  8244
sw $t5, 0($t3)
addi $t3, $t4,  8248
sw $t5, 0($t3)
addi $t3, $t4,  8252
sw $t5, 0($t3)
addi $t3, $t4,  8256
sw $t5, 0($t3)
addi $t3, $t4,  8260
sw $t5, 0($t3)
addi $t3, $t4,  8264
sw $t5, 0($t3)
addi $t3, $t4,  8268
sw $t5, 0($t3)
addi $t3, $t4,  8272
sw $t5, 0($t3)
addi $t3, $t4,  8276
sw $t5, 0($t3)
addi $t3, $t4,  8280
sw $t5, 0($t3)
addi $t3, $t4,  8284
li $t5, 0x4a4d09
sw $t5, 0($t3)
addi $t3, $t4,  8288
li $t5, 0x4a4e06
sw $t5, 0($t3)
addi $t3, $t4,  8292
li $t5, 0x4b4c0b
sw $t5, 0($t3)
addi $t3, $t4,  8296
li $t5, 0xeffe04
sw $t5, 0($t3)
addi $t3, $t4,  8300
li $t5, 0xedff00
sw $t5, 0($t3)
addi $t3, $t4,  8304
li $t5, 0xeaff07
sw $t5, 0($t3)
addi $t3, $t4,  8308
li $t5, 0xbac21b
sw $t5, 0($t3)
addi $t3, $t4,  8312
li $t5, 0xb7bf2f
sw $t5, 0($t3)
addi $t3, $t4,  8316
li $t5, 0xb7bf33
sw $t5, 0($t3)
addi $t3, $t4,  8320
sw $t5, 0($t3)
addi $t3, $t4,  8324
li $t5, 0xb7bf31
sw $t5, 0($t3)
addi $t3, $t4,  8328
sw $t5, 0($t3)
addi $t3, $t4,  8332
li $t5, 0xb6be30
sw $t5, 0($t3)
addi $t3, $t4,  8336
sw $t5, 0($t3)
addi $t3, $t4,  8340
li $t5, 0xb7bf31
sw $t5, 0($t3)
addi $t3, $t4,  8344
li $t5, 0xb6c033
sw $t5, 0($t3)
addi $t3, $t4,  8348
li $t5, 0xbdc024
sw $t5, 0($t3)
addi $t3, $t4,  8352
li $t5, 0x323714
sw $t5, 0($t3)
addi $t3, $t4,  8356
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  8360
sw $t5, 0($t3)
addi $t3, $t4,  8364
li $t5, 0x000001
sw $t5, 0($t3)
addi $t3, $t4,  8368
li $t5, 0x010002
sw $t5, 0($t3)
addi $t3, $t4,  8372
li $t5, 0x050600
sw $t5, 0($t3)
addi $t3, $t4,  8376
li $t5, 0x0c0c00
sw $t5, 0($t3)
addi $t3, $t4,  8380
li $t5, 0x100e00
sw $t5, 0($t3)
addi $t3, $t4,  8384
li $t5, 0x919d2b
sw $t5, 0($t3)
addi $t3, $t4,  8388
li $t5, 0xeeff00
sw $t5, 0($t3)
addi $t3, $t4,  8392
sw $t5, 0($t3)
addi $t3, $t4,  8396
li $t5, 0xf2fa2d
sw $t5, 0($t3)
addi $t3, $t4,  8400
li $t5, 0xe6f737
sw $t5, 0($t3)
addi $t3, $t4,  8404
li $t5, 0xeaf836
sw $t5, 0($t3)
addi $t3, $t4,  8408
li $t5, 0xecfb06
sw $t5, 0($t3)
addi $t3, $t4,  8412
li $t5, 0xefff00
sw $t5, 0($t3)
addi $t3, $t4,  8416
li $t5, 0xeffe03
sw $t5, 0($t3)
addi $t3, $t4,  8420
li $t5, 0x686716
sw $t5, 0($t3)
addi $t3, $t4,  8424
li $t5, 0x5e640f
sw $t5, 0($t3)
addi $t3, $t4,  8428
li $t5, 0x5f620c
sw $t5, 0($t3)
addi $t3, $t4,  8432
li $t5, 0x000009
sw $t5, 0($t3)
addi $t3, $t4,  8436
li $t5, 0x020004
sw $t5, 0($t3)
addi $t3, $t4,  8440
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  8444
sw $t5, 0($t3)
addi $t3, $t4,  8448
li $t5, 0x040002
sw $t5, 0($t3)
addi $t3, $t4,  8452
li $t5, 0xeffd04
sw $t5, 0($t3)
addi $t3, $t4,  8456
li $t5, 0xf1fe00
sw $t5, 0($t3)
addi $t3, $t4,  8460
li $t5, 0xf0fe00
sw $t5, 0($t3)
addi $t3, $t4,  8464
sw $t5, 0($t3)
addi $t3, $t4,  8468
li $t5, 0xf1fc0c
sw $t5, 0($t3)
addi $t3, $t4,  8472
li $t5, 0xeffd18
sw $t5, 0($t3)
addi $t3, $t4,  8476
li $t5, 0x656712
sw $t5, 0($t3)
addi $t3, $t4,  8480
li $t5, 0x61650f
sw $t5, 0($t3)
addi $t3, $t4,  8484
li $t5, 0x636b1f
sw $t5, 0($t3)
addi $t3, $t4,  8488
li $t5, 0x000203
sw $t5, 0($t3)
addi $t3, $t4,  8492
li $t5, 0x010008
sw $t5, 0($t3)
addi $t3, $t4,  8496
li $t5, 0x191a00
sw $t5, 0($t3)
addi $t3, $t4,  8500
li $t5, 0x1d1e00
sw $t5, 0($t3)
addi $t3, $t4,  8504
li $t5, 0x1e1f00
sw $t5, 0($t3)
addi $t3, $t4,  8508
li $t5, 0xe2ec17
sw $t5, 0($t3)
addi $t3, $t4,  8512
li $t5, 0xf1fe01
sw $t5, 0($t3)
addi $t3, $t4,  8516
li $t5, 0xf1ff00
sw $t5, 0($t3)
addi $t3, $t4,  8520
sw $t5, 0($t3)
addi $t3, $t4,  8524
sw $t5, 0($t3)
addi $t3, $t4,  8528
li $t5, 0xf3ff00
sw $t5, 0($t3)
addi $t3, $t4,  8532
li $t5, 0x070200
sw $t5, 0($t3)
addi $t3, $t4,  8536
li $t5, 0x000004
sw $t5, 0($t3)
addi $t3, $t4,  8540
li $t5, 0xf0fd1d
sw $t5, 0($t3)
addi $t3, $t4,  8544
li $t5, 0xf1ff01
sw $t5, 0($t3)
addi $t3, $t4,  8548
li $t5, 0xf4fd06
sw $t5, 0($t3)
addi $t3, $t4,  8552
li $t5, 0xf2fe00
sw $t5, 0($t3)
addi $t3, $t4,  8556
sw $t5, 0($t3)
addi $t3, $t4,  8560
li $t5, 0xf2fb0c
sw $t5, 0($t3)
addi $t3, $t4,  8564
li $t5, 0xa5a81b
sw $t5, 0($t3)
addi $t3, $t4,  8568
li $t5, 0xa1a520
sw $t5, 0($t3)
addi $t3, $t4,  8572
li $t5, 0xa1a521
sw $t5, 0($t3)
addi $t3, $t4,  8576
sw $t5, 0($t3)
addi $t3, $t4,  8580
sw $t5, 0($t3)
addi $t3, $t4,  8584
sw $t5, 0($t3)
addi $t3, $t4,  8588
sw $t5, 0($t3)
addi $t3, $t4,  8592
li $t5, 0xa3a421
sw $t5, 0($t3)
addi $t3, $t4,  8596
li $t5, 0xa4a522
sw $t5, 0($t3)
addi $t3, $t4,  8600
li $t5, 0xa3a421
sw $t5, 0($t3)
addi $t3, $t4,  8604
sw $t5, 0($t3)
addi $t3, $t4,  8608
sw $t5, 0($t3)
addi $t3, $t4,  8612
li $t5, 0x9fa623
sw $t5, 0($t3)
addi $t3, $t4,  8616
li $t5, 0x9fa81c
sw $t5, 0($t3)
addi $t3, $t4,  8620
li $t5, 0x181500
sw $t5, 0($t3)
addi $t3, $t4,  8624
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  8628
sw $t5, 0($t3)
addi $t3, $t4,  8632
sw $t5, 0($t3)
addi $t3, $t4,  8636
sw $t5, 0($t3)
addi $t3, $t4,  8640
sw $t5, 0($t3)
addi $t3, $t4,  8644
sw $t5, 0($t3)
addi $t3, $t4,  8648
sw $t5, 0($t3)
addi $t3, $t4,  8652
sw $t5, 0($t3)
addi $t3, $t4,  8656
sw $t5, 0($t3)
addi $t3, $t4,  8660
sw $t5, 0($t3)
addi $t3, $t4,  8664
sw $t5, 0($t3)
addi $t3, $t4,  8668
sw $t5, 0($t3)
addi $t3, $t4,  8672
sw $t5, 0($t3)
addi $t3, $t4,  8676
sw $t5, 0($t3)
addi $t3, $t4,  8680
sw $t5, 0($t3)
addi $t3, $t4,  8684
sw $t5, 0($t3)
addi $t3, $t4,  8688
sw $t5, 0($t3)
addi $t3, $t4,  8692
sw $t5, 0($t3)
addi $t3, $t4,  8696
sw $t5, 0($t3)
addi $t3, $t4,  8700
sw $t5, 0($t3)
syscall #sleep for 30 ms
addi $t3, $t4,  8704
sw $t5, 0($t3)
addi $t3, $t4,  8708
sw $t5, 0($t3)
addi $t3, $t4,  8712
sw $t5, 0($t3)
addi $t3, $t4,  8716
sw $t5, 0($t3)
addi $t3, $t4,  8720
sw $t5, 0($t3)
addi $t3, $t4,  8724
sw $t5, 0($t3)
addi $t3, $t4,  8728
sw $t5, 0($t3)
addi $t3, $t4,  8732
sw $t5, 0($t3)
addi $t3, $t4,  8736
sw $t5, 0($t3)
addi $t3, $t4,  8740
sw $t5, 0($t3)
addi $t3, $t4,  8744
sw $t5, 0($t3)
addi $t3, $t4,  8748
sw $t5, 0($t3)
addi $t3, $t4,  8752
sw $t5, 0($t3)
addi $t3, $t4,  8756
sw $t5, 0($t3)
addi $t3, $t4,  8760
sw $t5, 0($t3)
addi $t3, $t4,  8764
sw $t5, 0($t3)
addi $t3, $t4,  8768
sw $t5, 0($t3)
addi $t3, $t4,  8772
sw $t5, 0($t3)
addi $t3, $t4,  8776
sw $t5, 0($t3)
addi $t3, $t4,  8780
sw $t5, 0($t3)
addi $t3, $t4,  8784
sw $t5, 0($t3)
addi $t3, $t4,  8788
sw $t5, 0($t3)
addi $t3, $t4,  8792
li $t5, 0x020202
sw $t5, 0($t3)
addi $t3, $t4,  8796
li $t5, 0xf2fb0c
sw $t5, 0($t3)
addi $t3, $t4,  8800
li $t5, 0xf2fd01
sw $t5, 0($t3)
addi $t3, $t4,  8804
li $t5, 0xf1fd01
sw $t5, 0($t3)
addi $t3, $t4,  8808
li $t5, 0xefff00
sw $t5, 0($t3)
addi $t3, $t4,  8812
li $t5, 0xefff01
sw $t5, 0($t3)
addi $t3, $t4,  8816
li $t5, 0xf1fd04
sw $t5, 0($t3)
addi $t3, $t4,  8820
li $t5, 0x010008
sw $t5, 0($t3)
addi $t3, $t4,  8824
li $t5, 0x000008
sw $t5, 0($t3)
addi $t3, $t4,  8828
li $t5, 0x000102
sw $t5, 0($t3)
addi $t3, $t4,  8832
sw $t5, 0($t3)
addi $t3, $t4,  8836
li $t5, 0x000003
sw $t5, 0($t3)
addi $t3, $t4,  8840
li $t5, 0x000004
sw $t5, 0($t3)
addi $t3, $t4,  8844
sw $t5, 0($t3)
addi $t3, $t4,  8848
sw $t5, 0($t3)
addi $t3, $t4,  8852
sw $t5, 0($t3)
addi $t3, $t4,  8856
sw $t5, 0($t3)
addi $t3, $t4,  8860
li $t5, 0x00000b
sw $t5, 0($t3)
addi $t3, $t4,  8864
li $t5, 0x00000a
sw $t5, 0($t3)
addi $t3, $t4,  8868
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  8872
sw $t5, 0($t3)
addi $t3, $t4,  8876
li $t5, 0x010000
sw $t5, 0($t3)
addi $t3, $t4,  8880
li $t5, 0x000400
sw $t5, 0($t3)
addi $t3, $t4,  8884
li $t5, 0x232000
sw $t5, 0($t3)
addi $t3, $t4,  8888
li $t5, 0xf4fe00
sw $t5, 0($t3)
addi $t3, $t4,  8892
sw $t5, 0($t3)
addi $t3, $t4,  8896
sw $t5, 0($t3)
addi $t3, $t4,  8900
li $t5, 0xf2ff00
sw $t5, 0($t3)
addi $t3, $t4,  8904
sw $t5, 0($t3)
addi $t3, $t4,  8908
li $t5, 0x262f00
sw $t5, 0($t3)
addi $t3, $t4,  8912
li $t5, 0x000102
sw $t5, 0($t3)
addi $t3, $t4,  8916
li $t5, 0x000100
sw $t5, 0($t3)
addi $t3, $t4,  8920
li $t5, 0xecfa29
sw $t5, 0($t3)
addi $t3, $t4,  8924
li $t5, 0xf5fd00
sw $t5, 0($t3)
addi $t3, $t4,  8928
li $t5, 0xf2ff00
sw $t5, 0($t3)
addi $t3, $t4,  8932
li $t5, 0xf4ff00
sw $t5, 0($t3)
addi $t3, $t4,  8936
li $t5, 0xf5fc04
sw $t5, 0($t3)
addi $t3, $t4,  8940
li $t5, 0xf7fc01
sw $t5, 0($t3)
addi $t3, $t4,  8944
li $t5, 0x020105
sw $t5, 0($t3)
addi $t3, $t4,  8948
li $t5, 0x000001
sw $t5, 0($t3)
addi $t3, $t4,  8952
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  8956
sw $t5, 0($t3)
addi $t3, $t4,  8960
li $t5, 0x040002
sw $t5, 0($t3)
addi $t3, $t4,  8964
li $t5, 0xf0fe05
sw $t5, 0($t3)
addi $t3, $t4,  8968
li $t5, 0xf3ff00
sw $t5, 0($t3)
addi $t3, $t4,  8972
li $t5, 0xf4fe00
sw $t5, 0($t3)
addi $t3, $t4,  8976
sw $t5, 0($t3)
addi $t3, $t4,  8980
li $t5, 0xf3fd0a
sw $t5, 0($t3)
addi $t3, $t4,  8984
li $t5, 0xf4fe00
sw $t5, 0($t3)
addi $t3, $t4,  8988
li $t5, 0xf5fd01
sw $t5, 0($t3)
addi $t3, $t4,  8992
li $t5, 0xfafb01
sw $t5, 0($t3)
addi $t3, $t4,  8996
li $t5, 0xf2fc32
sw $t5, 0($t3)
addi $t3, $t4,  9000
li $t5, 0x000009
sw $t5, 0($t3)
addi $t3, $t4,  9004
li $t5, 0x000007
sw $t5, 0($t3)
addi $t3, $t4,  9008
li $t5, 0xb4b81f
sw $t5, 0($t3)
addi $t3, $t4,  9012
li $t5, 0xf4fe02
sw $t5, 0($t3)
addi $t3, $t4,  9016
sw $t5, 0($t3)
addi $t3, $t4,  9020
li $t5, 0xf4fe00
sw $t5, 0($t3)
addi $t3, $t4,  9024
li $t5, 0xf4fd02
sw $t5, 0($t3)
addi $t3, $t4,  9028
li $t5, 0xf4fe00
sw $t5, 0($t3)
addi $t3, $t4,  9032
sw $t5, 0($t3)
addi $t3, $t4,  9036
sw $t5, 0($t3)
addi $t3, $t4,  9040
sw $t5, 0($t3)
addi $t3, $t4,  9044
li $t5, 0x070200
sw $t5, 0($t3)
addi $t3, $t4,  9048
li $t5, 0x000004
sw $t5, 0($t3)
addi $t3, $t4,  9052
li $t5, 0xf4fd1d
sw $t5, 0($t3)
addi $t3, $t4,  9056
li $t5, 0xf4ff02
sw $t5, 0($t3)
addi $t3, $t4,  9060
li $t5, 0xf9fc07
sw $t5, 0($t3)
addi $t3, $t4,  9064
li $t5, 0xf7fe01
sw $t5, 0($t3)
addi $t3, $t4,  9068
sw $t5, 0($t3)
addi $t3, $t4,  9072
li $t5, 0xf6fd03
sw $t5, 0($t3)
addi $t3, $t4,  9076
li $t5, 0x010007
sw $t5, 0($t3)
addi $t3, $t4,  9080
li $t5, 0x000106
sw $t5, 0($t3)
addi $t3, $t4,  9084
li $t5, 0x000100
sw $t5, 0($t3)
addi $t3, $t4,  9088
sw $t5, 0($t3)
addi $t3, $t4,  9092
sw $t5, 0($t3)
addi $t3, $t4,  9096
sw $t5, 0($t3)
addi $t3, $t4,  9100
sw $t5, 0($t3)
addi $t3, $t4,  9104
li $t5, 0x000200
sw $t5, 0($t3)
addi $t3, $t4,  9108
sw $t5, 0($t3)
addi $t3, $t4,  9112
sw $t5, 0($t3)
addi $t3, $t4,  9116
sw $t5, 0($t3)
addi $t3, $t4,  9120
sw $t5, 0($t3)
addi $t3, $t4,  9124
li $t5, 0x000104
sw $t5, 0($t3)
addi $t3, $t4,  9128
li $t5, 0x000004
sw $t5, 0($t3)
addi $t3, $t4,  9132
li $t5, 0x000100
sw $t5, 0($t3)
addi $t3, $t4,  9136
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  9140
sw $t5, 0($t3)
addi $t3, $t4,  9144
sw $t5, 0($t3)
addi $t3, $t4,  9148
sw $t5, 0($t3)
addi $t3, $t4,  9152
sw $t5, 0($t3)
addi $t3, $t4,  9156
sw $t5, 0($t3)
addi $t3, $t4,  9160
sw $t5, 0($t3)
addi $t3, $t4,  9164
sw $t5, 0($t3)
addi $t3, $t4,  9168
sw $t5, 0($t3)
addi $t3, $t4,  9172
sw $t5, 0($t3)
addi $t3, $t4,  9176
sw $t5, 0($t3)
addi $t3, $t4,  9180
sw $t5, 0($t3)
addi $t3, $t4,  9184
sw $t5, 0($t3)
addi $t3, $t4,  9188
sw $t5, 0($t3)
addi $t3, $t4,  9192
sw $t5, 0($t3)
addi $t3, $t4,  9196
sw $t5, 0($t3)
addi $t3, $t4,  9200
sw $t5, 0($t3)
addi $t3, $t4,  9204
sw $t5, 0($t3)
addi $t3, $t4,  9208
sw $t5, 0($t3)
addi $t3, $t4,  9212
sw $t5, 0($t3)
syscall #sleep for 30 ms
addi $t3, $t4,  9216
sw $t5, 0($t3)
addi $t3, $t4,  9220
sw $t5, 0($t3)
addi $t3, $t4,  9224
sw $t5, 0($t3)
addi $t3, $t4,  9228
sw $t5, 0($t3)
addi $t3, $t4,  9232
sw $t5, 0($t3)
addi $t3, $t4,  9236
sw $t5, 0($t3)
addi $t3, $t4,  9240
sw $t5, 0($t3)
addi $t3, $t4,  9244
sw $t5, 0($t3)
addi $t3, $t4,  9248
sw $t5, 0($t3)
addi $t3, $t4,  9252
sw $t5, 0($t3)
addi $t3, $t4,  9256
sw $t5, 0($t3)
addi $t3, $t4,  9260
sw $t5, 0($t3)
addi $t3, $t4,  9264
sw $t5, 0($t3)
addi $t3, $t4,  9268
sw $t5, 0($t3)
addi $t3, $t4,  9272
sw $t5, 0($t3)
addi $t3, $t4,  9276
sw $t5, 0($t3)
addi $t3, $t4,  9280
sw $t5, 0($t3)
addi $t3, $t4,  9284
sw $t5, 0($t3)
addi $t3, $t4,  9288
li $t5, 0x010300
sw $t5, 0($t3)
addi $t3, $t4,  9292
li $t5, 0x000400
sw $t5, 0($t3)
addi $t3, $t4,  9296
li $t5, 0x020201
sw $t5, 0($t3)
addi $t3, $t4,  9300
li $t5, 0x010103
sw $t5, 0($t3)
addi $t3, $t4,  9304
li $t5, 0x020204
sw $t5, 0($t3)
addi $t3, $t4,  9308
li $t5, 0xf1fb0b
sw $t5, 0($t3)
addi $t3, $t4,  9312
li $t5, 0xf1ff00
sw $t5, 0($t3)
addi $t3, $t4,  9316
li $t5, 0xf2fd04
sw $t5, 0($t3)
addi $t3, $t4,  9320
li $t5, 0xf4f900
sw $t5, 0($t3)
addi $t3, $t4,  9324
li $t5, 0xf3fb00
sw $t5, 0($t3)
addi $t3, $t4,  9328
li $t5, 0xf4fc01
sw $t5, 0($t3)
addi $t3, $t4,  9332
li $t5, 0x01010d
sw $t5, 0($t3)
addi $t3, $t4,  9336
li $t5, 0x020005
sw $t5, 0($t3)
addi $t3, $t4,  9340
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  9344
sw $t5, 0($t3)
addi $t3, $t4,  9348
sw $t5, 0($t3)
addi $t3, $t4,  9352
sw $t5, 0($t3)
addi $t3, $t4,  9356
sw $t5, 0($t3)
addi $t3, $t4,  9360
sw $t5, 0($t3)
addi $t3, $t4,  9364
sw $t5, 0($t3)
addi $t3, $t4,  9368
sw $t5, 0($t3)
addi $t3, $t4,  9372
sw $t5, 0($t3)
addi $t3, $t4,  9376
sw $t5, 0($t3)
addi $t3, $t4,  9380
li $t5, 0x010000
sw $t5, 0($t3)
addi $t3, $t4,  9384
li $t5, 0x010104
sw $t5, 0($t3)
addi $t3, $t4,  9388
li $t5, 0x040201
sw $t5, 0($t3)
addi $t3, $t4,  9392
li $t5, 0x000301
sw $t5, 0($t3)
addi $t3, $t4,  9396
li $t5, 0x1d1700
sw $t5, 0($t3)
addi $t3, $t4,  9400
li $t5, 0xf3fd00
sw $t5, 0($t3)
addi $t3, $t4,  9404
li $t5, 0xf4fd01
sw $t5, 0($t3)
addi $t3, $t4,  9408
li $t5, 0xf4fe00
sw $t5, 0($t3)
addi $t3, $t4,  9412
li $t5, 0xf3fc06
sw $t5, 0($t3)
addi $t3, $t4,  9416
li $t5, 0xf2fb06
sw $t5, 0($t3)
addi $t3, $t4,  9420
li $t5, 0x212c00
sw $t5, 0($t3)
addi $t3, $t4,  9424
li $t5, 0x000300
sw $t5, 0($t3)
addi $t3, $t4,  9428
li $t5, 0x000202
sw $t5, 0($t3)
addi $t3, $t4,  9432
li $t5, 0xeff436
sw $t5, 0($t3)
addi $t3, $t4,  9436
li $t5, 0xf6f90c
sw $t5, 0($t3)
addi $t3, $t4,  9440
li $t5, 0xf6fc04
sw $t5, 0($t3)
addi $t3, $t4,  9444
li $t5, 0xfdff09
sw $t5, 0($t3)
addi $t3, $t4,  9448
li $t5, 0xf2fd01
sw $t5, 0($t3)
addi $t3, $t4,  9452
li $t5, 0xf3fd01
sw $t5, 0($t3)
addi $t3, $t4,  9456
li $t5, 0x040103
sw $t5, 0($t3)
addi $t3, $t4,  9460
li $t5, 0x000400
sw $t5, 0($t3)
addi $t3, $t4,  9464
li $t5, 0x000204
sw $t5, 0($t3)
addi $t3, $t4,  9468
li $t5, 0x040500
sw $t5, 0($t3)
addi $t3, $t4,  9472
li $t5, 0x010101
sw $t5, 0($t3)
addi $t3, $t4,  9476
li $t5, 0xf3fa04
sw $t5, 0($t3)
addi $t3, $t4,  9480
li $t5, 0xf3fd00
sw $t5, 0($t3)
addi $t3, $t4,  9484
li $t5, 0xf6fb00
sw $t5, 0($t3)
addi $t3, $t4,  9488
sw $t5, 0($t3)
addi $t3, $t4,  9492
sw $t5, 0($t3)
addi $t3, $t4,  9496
sw $t5, 0($t3)
addi $t3, $t4,  9500
li $t5, 0xf5fc00
sw $t5, 0($t3)
addi $t3, $t4,  9504
li $t5, 0xf7fb02
sw $t5, 0($t3)
addi $t3, $t4,  9508
li $t5, 0xf2ff42
sw $t5, 0($t3)
addi $t3, $t4,  9512
li $t5, 0x040202
sw $t5, 0($t3)
addi $t3, $t4,  9516
li $t5, 0x000405
sw $t5, 0($t3)
addi $t3, $t4,  9520
li $t5, 0xb6b927
sw $t5, 0($t3)
addi $t3, $t4,  9524
li $t5, 0xf6fb00
sw $t5, 0($t3)
addi $t3, $t4,  9528
sw $t5, 0($t3)
addi $t3, $t4,  9532
sw $t5, 0($t3)
addi $t3, $t4,  9536
sw $t5, 0($t3)
addi $t3, $t4,  9540
li $t5, 0xf7fc00
sw $t5, 0($t3)
addi $t3, $t4,  9544
li $t5, 0xf8fc00
sw $t5, 0($t3)
addi $t3, $t4,  9548
sw $t5, 0($t3)
addi $t3, $t4,  9552
li $t5, 0xfcfa00
sw $t5, 0($t3)
addi $t3, $t4,  9556
li $t5, 0x020400
sw $t5, 0($t3)
addi $t3, $t4,  9560
li $t5, 0x020004
sw $t5, 0($t3)
addi $t3, $t4,  9564
li $t5, 0xf1fd1d
sw $t5, 0($t3)
addi $t3, $t4,  9568
li $t5, 0xf8fc01
sw $t5, 0($t3)
addi $t3, $t4,  9572
li $t5, 0xf8fa06
sw $t5, 0($t3)
addi $t3, $t4,  9576
li $t5, 0xf8fc00
sw $t5, 0($t3)
addi $t3, $t4,  9580
sw $t5, 0($t3)
addi $t3, $t4,  9584
li $t5, 0xfafb04
sw $t5, 0($t3)
addi $t3, $t4,  9588
li $t5, 0x000002
sw $t5, 0($t3)
addi $t3, $t4,  9592
li $t5, 0x020000
sw $t5, 0($t3)
addi $t3, $t4,  9596
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  9600
sw $t5, 0($t3)
addi $t3, $t4,  9604
sw $t5, 0($t3)
addi $t3, $t4,  9608
sw $t5, 0($t3)
addi $t3, $t4,  9612
sw $t5, 0($t3)
addi $t3, $t4,  9616
sw $t5, 0($t3)
addi $t3, $t4,  9620
sw $t5, 0($t3)
addi $t3, $t4,  9624
sw $t5, 0($t3)
addi $t3, $t4,  9628
sw $t5, 0($t3)
addi $t3, $t4,  9632
sw $t5, 0($t3)
addi $t3, $t4,  9636
sw $t5, 0($t3)
addi $t3, $t4,  9640
sw $t5, 0($t3)
addi $t3, $t4,  9644
sw $t5, 0($t3)
addi $t3, $t4,  9648
sw $t5, 0($t3)
addi $t3, $t4,  9652
sw $t5, 0($t3)
addi $t3, $t4,  9656
sw $t5, 0($t3)
addi $t3, $t4,  9660
sw $t5, 0($t3)
addi $t3, $t4,  9664
sw $t5, 0($t3)
addi $t3, $t4,  9668
sw $t5, 0($t3)
addi $t3, $t4,  9672
sw $t5, 0($t3)
addi $t3, $t4,  9676
sw $t5, 0($t3)
addi $t3, $t4,  9680
sw $t5, 0($t3)
addi $t3, $t4,  9684
sw $t5, 0($t3)
addi $t3, $t4,  9688
sw $t5, 0($t3)
addi $t3, $t4,  9692
sw $t5, 0($t3)
addi $t3, $t4,  9696
sw $t5, 0($t3)
addi $t3, $t4,  9700
sw $t5, 0($t3)
addi $t3, $t4,  9704
sw $t5, 0($t3)
addi $t3, $t4,  9708
sw $t5, 0($t3)
addi $t3, $t4,  9712
sw $t5, 0($t3)
addi $t3, $t4,  9716
sw $t5, 0($t3)
addi $t3, $t4,  9720
sw $t5, 0($t3)
addi $t3, $t4,  9724
sw $t5, 0($t3)
syscall #sleep for 30 ms
addi $t3, $t4,  9728
sw $t5, 0($t3)
addi $t3, $t4,  9732
sw $t5, 0($t3)
addi $t3, $t4,  9736
sw $t5, 0($t3)
addi $t3, $t4,  9740
sw $t5, 0($t3)
addi $t3, $t4,  9744
sw $t5, 0($t3)
addi $t3, $t4,  9748
sw $t5, 0($t3)
addi $t3, $t4,  9752
sw $t5, 0($t3)
addi $t3, $t4,  9756
sw $t5, 0($t3)
addi $t3, $t4,  9760
sw $t5, 0($t3)
addi $t3, $t4,  9764
sw $t5, 0($t3)
addi $t3, $t4,  9768
sw $t5, 0($t3)
addi $t3, $t4,  9772
sw $t5, 0($t3)
addi $t3, $t4,  9776
sw $t5, 0($t3)
addi $t3, $t4,  9780
sw $t5, 0($t3)
addi $t3, $t4,  9784
sw $t5, 0($t3)
addi $t3, $t4,  9788
sw $t5, 0($t3)
addi $t3, $t4,  9792
sw $t5, 0($t3)
addi $t3, $t4,  9796
sw $t5, 0($t3)
addi $t3, $t4,  9800
sw $t5, 0($t3)
addi $t3, $t4,  9804
li $t5, 0x010100
sw $t5, 0($t3)
addi $t3, $t4,  9808
li $t5, 0xecf63a
sw $t5, 0($t3)
addi $t3, $t4,  9812
li $t5, 0xf0fb04
sw $t5, 0($t3)
addi $t3, $t4,  9816
sw $t5, 0($t3)
addi $t3, $t4,  9820
li $t5, 0xf6fa04
sw $t5, 0($t3)
addi $t3, $t4,  9824
li $t5, 0xf5fa00
sw $t5, 0($t3)
addi $t3, $t4,  9828
li $t5, 0xf3fa05
sw $t5, 0($t3)
addi $t3, $t4,  9832
li $t5, 0x0a0000
sw $t5, 0($t3)
addi $t3, $t4,  9836
li $t5, 0x05000d
sw $t5, 0($t3)
addi $t3, $t4,  9840
li $t5, 0x070007
sw $t5, 0($t3)
addi $t3, $t4,  9844
li $t5, 0x000010
sw $t5, 0($t3)
addi $t3, $t4,  9848
li $t5, 0x010000
sw $t5, 0($t3)
addi $t3, $t4,  9852
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  9856
sw $t5, 0($t3)
addi $t3, $t4,  9860
sw $t5, 0($t3)
addi $t3, $t4,  9864
sw $t5, 0($t3)
addi $t3, $t4,  9868
sw $t5, 0($t3)
addi $t3, $t4,  9872
sw $t5, 0($t3)
addi $t3, $t4,  9876
sw $t5, 0($t3)
addi $t3, $t4,  9880
sw $t5, 0($t3)
addi $t3, $t4,  9884
sw $t5, 0($t3)
addi $t3, $t4,  9888
sw $t5, 0($t3)
addi $t3, $t4,  9892
li $t5, 0x010001
sw $t5, 0($t3)
addi $t3, $t4,  9896
li $t5, 0x040004
sw $t5, 0($t3)
addi $t3, $t4,  9900
li $t5, 0xf1f913
sw $t5, 0($t3)
addi $t3, $t4,  9904
li $t5, 0xf2fa14
sw $t5, 0($t3)
addi $t3, $t4,  9908
li $t5, 0xf8f80a
sw $t5, 0($t3)
addi $t3, $t4,  9912
li $t5, 0xf9f902
sw $t5, 0($t3)
addi $t3, $t4,  9916
li $t5, 0xf9fa01
sw $t5, 0($t3)
addi $t3, $t4,  9920
li $t5, 0xe9e81e
sw $t5, 0($t3)
addi $t3, $t4,  9924
li $t5, 0x020100
sw $t5, 0($t3)
addi $t3, $t4,  9928
sw $t5, 0($t3)
addi $t3, $t4,  9932
li $t5, 0x020200
sw $t5, 0($t3)
addi $t3, $t4,  9936
li $t5, 0x000100
sw $t5, 0($t3)
addi $t3, $t4,  9940
li $t5, 0x000300
sw $t5, 0($t3)
addi $t3, $t4,  9944
li $t5, 0x030000
sw $t5, 0($t3)
addi $t3, $t4,  9948
li $t5, 0x04000c
sw $t5, 0($t3)
addi $t3, $t4,  9952
li $t5, 0x000011
sw $t5, 0($t3)
addi $t3, $t4,  9956
li $t5, 0xeef412
sw $t5, 0($t3)
addi $t3, $t4,  9960
li $t5, 0xf9f800
sw $t5, 0($t3)
addi $t3, $t4,  9964
li $t5, 0xf8f900
sw $t5, 0($t3)
addi $t3, $t4,  9968
li $t5, 0xf6f70d
sw $t5, 0($t3)
addi $t3, $t4,  9972
li $t5, 0xf8f706
sw $t5, 0($t3)
addi $t3, $t4,  9976
li $t5, 0xf2f808
sw $t5, 0($t3)
addi $t3, $t4,  9980
li $t5, 0x020102
sw $t5, 0($t3)
addi $t3, $t4,  9984
li $t5, 0x000101
sw $t5, 0($t3)
addi $t3, $t4,  9988
li $t5, 0xf7f804
sw $t5, 0($t3)
addi $t3, $t4,  9992
li $t5, 0xf9fa00
sw $t5, 0($t3)
addi $t3, $t4,  9996
li $t5, 0xfbf900
sw $t5, 0($t3)
addi $t3, $t4,  10000
sw $t5, 0($t3)
addi $t3, $t4,  10004
sw $t5, 0($t3)
addi $t3, $t4,  10008
sw $t5, 0($t3)
addi $t3, $t4,  10012
li $t5, 0xfaf900
sw $t5, 0($t3)
addi $t3, $t4,  10016
li $t5, 0xfbf901
sw $t5, 0($t3)
addi $t3, $t4,  10020
li $t5, 0xf7fa04
sw $t5, 0($t3)
addi $t3, $t4,  10024
li $t5, 0xf9f510
sw $t5, 0($t3)
addi $t3, $t4,  10028
li $t5, 0xf7f70b
sw $t5, 0($t3)
addi $t3, $t4,  10032
li $t5, 0xfbf509
sw $t5, 0($t3)
addi $t3, $t4,  10036
li $t5, 0xfaf800
sw $t5, 0($t3)
addi $t3, $t4,  10040
sw $t5, 0($t3)
addi $t3, $t4,  10044
li $t5, 0xfcfa00
sw $t5, 0($t3)
addi $t3, $t4,  10048
sw $t5, 0($t3)
addi $t3, $t4,  10052
li $t5, 0xfbf900
sw $t5, 0($t3)
addi $t3, $t4,  10056
li $t5, 0xfcf800
sw $t5, 0($t3)
addi $t3, $t4,  10060
sw $t5, 0($t3)
addi $t3, $t4,  10064
li $t5, 0xfdf800
sw $t5, 0($t3)
addi $t3, $t4,  10068
li $t5, 0x030500
sw $t5, 0($t3)
addi $t3, $t4,  10072
li $t5, 0x020004
sw $t5, 0($t3)
addi $t3, $t4,  10076
li $t5, 0xf5fa1c
sw $t5, 0($t3)
addi $t3, $t4,  10080
li $t5, 0xfbf800
sw $t5, 0($t3)
addi $t3, $t4,  10084
li $t5, 0xfcf705
sw $t5, 0($t3)
addi $t3, $t4,  10088
li $t5, 0xfcf800
sw $t5, 0($t3)
addi $t3, $t4,  10092
li $t5, 0xfdf900
sw $t5, 0($t3)
addi $t3, $t4,  10096
li $t5, 0xfff703
sw $t5, 0($t3)
addi $t3, $t4,  10100
li $t5, 0x020002
sw $t5, 0($t3)
addi $t3, $t4,  10104
li $t5, 0x010000
sw $t5, 0($t3)
addi $t3, $t4,  10108
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  10112
sw $t5, 0($t3)
addi $t3, $t4,  10116
sw $t5, 0($t3)
addi $t3, $t4,  10120
sw $t5, 0($t3)
addi $t3, $t4,  10124
sw $t5, 0($t3)
addi $t3, $t4,  10128
sw $t5, 0($t3)
addi $t3, $t4,  10132
sw $t5, 0($t3)
addi $t3, $t4,  10136
sw $t5, 0($t3)
addi $t3, $t4,  10140
sw $t5, 0($t3)
addi $t3, $t4,  10144
sw $t5, 0($t3)
addi $t3, $t4,  10148
sw $t5, 0($t3)
addi $t3, $t4,  10152
sw $t5, 0($t3)
addi $t3, $t4,  10156
sw $t5, 0($t3)
addi $t3, $t4,  10160
sw $t5, 0($t3)
addi $t3, $t4,  10164
sw $t5, 0($t3)
addi $t3, $t4,  10168
sw $t5, 0($t3)
addi $t3, $t4,  10172
sw $t5, 0($t3)
addi $t3, $t4,  10176
sw $t5, 0($t3)
addi $t3, $t4,  10180
sw $t5, 0($t3)
addi $t3, $t4,  10184
sw $t5, 0($t3)
addi $t3, $t4,  10188
sw $t5, 0($t3)
addi $t3, $t4,  10192
sw $t5, 0($t3)
addi $t3, $t4,  10196
sw $t5, 0($t3)
addi $t3, $t4,  10200
sw $t5, 0($t3)
addi $t3, $t4,  10204
sw $t5, 0($t3)
addi $t3, $t4,  10208
sw $t5, 0($t3)
addi $t3, $t4,  10212
sw $t5, 0($t3)
addi $t3, $t4,  10216
sw $t5, 0($t3)
addi $t3, $t4,  10220
sw $t5, 0($t3)
addi $t3, $t4,  10224
sw $t5, 0($t3)
addi $t3, $t4,  10228
sw $t5, 0($t3)
addi $t3, $t4,  10232
sw $t5, 0($t3)
addi $t3, $t4,  10236
sw $t5, 0($t3)
syscall #sleep for 30 ms
addi $t3, $t4,  10240
sw $t5, 0($t3)
addi $t3, $t4,  10244
sw $t5, 0($t3)
addi $t3, $t4,  10248
sw $t5, 0($t3)
addi $t3, $t4,  10252
sw $t5, 0($t3)
addi $t3, $t4,  10256
sw $t5, 0($t3)
addi $t3, $t4,  10260
sw $t5, 0($t3)
addi $t3, $t4,  10264
sw $t5, 0($t3)
addi $t3, $t4,  10268
sw $t5, 0($t3)
addi $t3, $t4,  10272
sw $t5, 0($t3)
addi $t3, $t4,  10276
sw $t5, 0($t3)
addi $t3, $t4,  10280
sw $t5, 0($t3)
addi $t3, $t4,  10284
sw $t5, 0($t3)
addi $t3, $t4,  10288
sw $t5, 0($t3)
addi $t3, $t4,  10292
sw $t5, 0($t3)
addi $t3, $t4,  10296
sw $t5, 0($t3)
addi $t3, $t4,  10300
sw $t5, 0($t3)
addi $t3, $t4,  10304
sw $t5, 0($t3)
addi $t3, $t4,  10308
sw $t5, 0($t3)
addi $t3, $t4,  10312
li $t5, 0x010002
sw $t5, 0($t3)
addi $t3, $t4,  10316
li $t5, 0x010102
sw $t5, 0($t3)
addi $t3, $t4,  10320
li $t5, 0xf4f52c
sw $t5, 0($t3)
addi $t3, $t4,  10324
li $t5, 0xf9f700
sw $t5, 0($t3)
addi $t3, $t4,  10328
sw $t5, 0($t3)
addi $t3, $t4,  10332
li $t5, 0xf9f600
sw $t5, 0($t3)
addi $t3, $t4,  10336
li $t5, 0xf8f600
sw $t5, 0($t3)
addi $t3, $t4,  10340
li $t5, 0xf8f601
sw $t5, 0($t3)
addi $t3, $t4,  10344
li $t5, 0x02000a
sw $t5, 0($t3)
addi $t3, $t4,  10348
li $t5, 0x010001
sw $t5, 0($t3)
addi $t3, $t4,  10352
li $t5, 0x000005
sw $t5, 0($t3)
addi $t3, $t4,  10356
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  10360
sw $t5, 0($t3)
addi $t3, $t4,  10364
li $t5, 0x000100
sw $t5, 0($t3)
addi $t3, $t4,  10368
li $t5, 0x00000e
sw $t5, 0($t3)
addi $t3, $t4,  10372
li $t5, 0x020000
sw $t5, 0($t3)
addi $t3, $t4,  10376
sw $t5, 0($t3)
addi $t3, $t4,  10380
sw $t5, 0($t3)
addi $t3, $t4,  10384
sw $t5, 0($t3)
addi $t3, $t4,  10388
sw $t5, 0($t3)
addi $t3, $t4,  10392
sw $t5, 0($t3)
addi $t3, $t4,  10396
sw $t5, 0($t3)
addi $t3, $t4,  10400
li $t5, 0x000001
sw $t5, 0($t3)
addi $t3, $t4,  10404
li $t5, 0x020003
sw $t5, 0($t3)
addi $t3, $t4,  10408
li $t5, 0x060300
sw $t5, 0($t3)
addi $t3, $t4,  10412
li $t5, 0xfdf308
sw $t5, 0($t3)
addi $t3, $t4,  10416
li $t5, 0xfbf701
sw $t5, 0($t3)
addi $t3, $t4,  10420
li $t5, 0xfaf600
sw $t5, 0($t3)
addi $t3, $t4,  10424
li $t5, 0xfef501
sw $t5, 0($t3)
addi $t3, $t4,  10428
li $t5, 0xfcf600
sw $t5, 0($t3)
addi $t3, $t4,  10432
li $t5, 0xebe327
sw $t5, 0($t3)
addi $t3, $t4,  10436
li $t5, 0x020000
sw $t5, 0($t3)
addi $t3, $t4,  10440
sw $t5, 0($t3)
addi $t3, $t4,  10444
li $t5, 0x010005
sw $t5, 0($t3)
addi $t3, $t4,  10448
li $t5, 0x000001
sw $t5, 0($t3)
addi $t3, $t4,  10452
sw $t5, 0($t3)
addi $t3, $t4,  10456
li $t5, 0x000003
sw $t5, 0($t3)
addi $t3, $t4,  10460
li $t5, 0x000002
sw $t5, 0($t3)
addi $t3, $t4,  10464
li $t5, 0x000302
sw $t5, 0($t3)
addi $t3, $t4,  10468
li $t5, 0xf4f506
sw $t5, 0($t3)
addi $t3, $t4,  10472
li $t5, 0xfdf408
sw $t5, 0($t3)
addi $t3, $t4,  10476
li $t5, 0xfdf504
sw $t5, 0($t3)
addi $t3, $t4,  10480
li $t5, 0xfbf700
sw $t5, 0($t3)
addi $t3, $t4,  10484
li $t5, 0xf9f601
sw $t5, 0($t3)
addi $t3, $t4,  10488
li $t5, 0xf9f402
sw $t5, 0($t3)
addi $t3, $t4,  10492
li $t5, 0x01010a
sw $t5, 0($t3)
addi $t3, $t4,  10496
li $t5, 0x000202
sw $t5, 0($t3)
addi $t3, $t4,  10500
li $t5, 0xf9f403
sw $t5, 0($t3)
addi $t3, $t4,  10504
li $t5, 0xfaf600
sw $t5, 0($t3)
addi $t3, $t4,  10508
li $t5, 0xfdf500
sw $t5, 0($t3)
addi $t3, $t4,  10512
sw $t5, 0($t3)
addi $t3, $t4,  10516
sw $t5, 0($t3)
addi $t3, $t4,  10520
sw $t5, 0($t3)
addi $t3, $t4,  10524
sw $t5, 0($t3)
addi $t3, $t4,  10528
li $t5, 0xfdf502
sw $t5, 0($t3)
addi $t3, $t4,  10532
li $t5, 0xfff305
sw $t5, 0($t3)
addi $t3, $t4,  10536
li $t5, 0xfdf502
sw $t5, 0($t3)
addi $t3, $t4,  10540
li $t5, 0xfdf408
sw $t5, 0($t3)
addi $t3, $t4,  10544
li $t5, 0xfbf702
sw $t5, 0($t3)
addi $t3, $t4,  10548
li $t5, 0xfef500
sw $t5, 0($t3)
addi $t3, $t4,  10552
sw $t5, 0($t3)
addi $t3, $t4,  10556
sw $t5, 0($t3)
addi $t3, $t4,  10560
sw $t5, 0($t3)
addi $t3, $t4,  10564
li $t5, 0xfef600
sw $t5, 0($t3)
addi $t3, $t4,  10568
li $t5, 0xfff500
sw $t5, 0($t3)
addi $t3, $t4,  10572
sw $t5, 0($t3)
addi $t3, $t4,  10576
li $t5, 0xfff400
sw $t5, 0($t3)
addi $t3, $t4,  10580
li $t5, 0x040400
sw $t5, 0($t3)
addi $t3, $t4,  10584
li $t5, 0x010003
sw $t5, 0($t3)
addi $t3, $t4,  10588
li $t5, 0xf8f81d
sw $t5, 0($t3)
addi $t3, $t4,  10592
li $t5, 0xfef500
sw $t5, 0($t3)
addi $t3, $t4,  10596
li $t5, 0xfff304
sw $t5, 0($t3)
addi $t3, $t4,  10600
li $t5, 0xfef500
sw $t5, 0($t3)
addi $t3, $t4,  10604
li $t5, 0xfff500
sw $t5, 0($t3)
addi $t3, $t4,  10608
li $t5, 0xfff301
sw $t5, 0($t3)
addi $t3, $t4,  10612
li $t5, 0x050007
sw $t5, 0($t3)
addi $t3, $t4,  10616
li $t5, 0x010000
sw $t5, 0($t3)
addi $t3, $t4,  10620
li $t5, 0x020000
sw $t5, 0($t3)
addi $t3, $t4,  10624
sw $t5, 0($t3)
addi $t3, $t4,  10628
sw $t5, 0($t3)
addi $t3, $t4,  10632
sw $t5, 0($t3)
addi $t3, $t4,  10636
sw $t5, 0($t3)
addi $t3, $t4,  10640
li $t5, 0x020004
sw $t5, 0($t3)
addi $t3, $t4,  10644
li $t5, 0x020000
sw $t5, 0($t3)
addi $t3, $t4,  10648
li $t5, 0x010001
sw $t5, 0($t3)
addi $t3, $t4,  10652
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  10656
sw $t5, 0($t3)
addi $t3, $t4,  10660
sw $t5, 0($t3)
addi $t3, $t4,  10664
sw $t5, 0($t3)
addi $t3, $t4,  10668
sw $t5, 0($t3)
addi $t3, $t4,  10672
sw $t5, 0($t3)
addi $t3, $t4,  10676
sw $t5, 0($t3)
addi $t3, $t4,  10680
sw $t5, 0($t3)
addi $t3, $t4,  10684
sw $t5, 0($t3)
addi $t3, $t4,  10688
sw $t5, 0($t3)
addi $t3, $t4,  10692
sw $t5, 0($t3)
addi $t3, $t4,  10696
sw $t5, 0($t3)
addi $t3, $t4,  10700
sw $t5, 0($t3)
addi $t3, $t4,  10704
sw $t5, 0($t3)
addi $t3, $t4,  10708
sw $t5, 0($t3)
addi $t3, $t4,  10712
sw $t5, 0($t3)
addi $t3, $t4,  10716
sw $t5, 0($t3)
addi $t3, $t4,  10720
sw $t5, 0($t3)
addi $t3, $t4,  10724
sw $t5, 0($t3)
addi $t3, $t4,  10728
sw $t5, 0($t3)
addi $t3, $t4,  10732
sw $t5, 0($t3)
addi $t3, $t4,  10736
sw $t5, 0($t3)
addi $t3, $t4,  10740
sw $t5, 0($t3)
addi $t3, $t4,  10744
sw $t5, 0($t3)
addi $t3, $t4,  10748
sw $t5, 0($t3)
syscall #sleep for 30 ms
addi $t3, $t4,  10752
sw $t5, 0($t3)
addi $t3, $t4,  10756
sw $t5, 0($t3)
addi $t3, $t4,  10760
sw $t5, 0($t3)
addi $t3, $t4,  10764
sw $t5, 0($t3)
addi $t3, $t4,  10768
sw $t5, 0($t3)
addi $t3, $t4,  10772
sw $t5, 0($t3)
addi $t3, $t4,  10776
sw $t5, 0($t3)
addi $t3, $t4,  10780
sw $t5, 0($t3)
addi $t3, $t4,  10784
sw $t5, 0($t3)
addi $t3, $t4,  10788
sw $t5, 0($t3)
addi $t3, $t4,  10792
sw $t5, 0($t3)
addi $t3, $t4,  10796
sw $t5, 0($t3)
addi $t3, $t4,  10800
sw $t5, 0($t3)
addi $t3, $t4,  10804
sw $t5, 0($t3)
addi $t3, $t4,  10808
sw $t5, 0($t3)
addi $t3, $t4,  10812
sw $t5, 0($t3)
addi $t3, $t4,  10816
sw $t5, 0($t3)
addi $t3, $t4,  10820
sw $t5, 0($t3)
addi $t3, $t4,  10824
li $t5, 0x010000
sw $t5, 0($t3)
addi $t3, $t4,  10828
li $t5, 0x000300
sw $t5, 0($t3)
addi $t3, $t4,  10832
li $t5, 0xf5f031
sw $t5, 0($t3)
addi $t3, $t4,  10836
li $t5, 0xfbf200
sw $t5, 0($t3)
addi $t3, $t4,  10840
sw $t5, 0($t3)
addi $t3, $t4,  10844
sw $t5, 0($t3)
addi $t3, $t4,  10848
sw $t5, 0($t3)
addi $t3, $t4,  10852
li $t5, 0xfaf201
sw $t5, 0($t3)
addi $t3, $t4,  10856
li $t5, 0x010001
sw $t5, 0($t3)
addi $t3, $t4,  10860
li $t5, 0x020000
sw $t5, 0($t3)
addi $t3, $t4,  10864
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  10868
sw $t5, 0($t3)
addi $t3, $t4,  10872
sw $t5, 0($t3)
addi $t3, $t4,  10876
li $t5, 0x030004
sw $t5, 0($t3)
addi $t3, $t4,  10880
li $t5, 0x060200
sw $t5, 0($t3)
addi $t3, $t4,  10884
li $t5, 0x050200
sw $t5, 0($t3)
addi $t3, $t4,  10888
sw $t5, 0($t3)
addi $t3, $t4,  10892
sw $t5, 0($t3)
addi $t3, $t4,  10896
sw $t5, 0($t3)
addi $t3, $t4,  10900
sw $t5, 0($t3)
addi $t3, $t4,  10904
li $t5, 0x030400
sw $t5, 0($t3)
addi $t3, $t4,  10908
li $t5, 0x0a0000
sw $t5, 0($t3)
addi $t3, $t4,  10912
li $t5, 0x020000
sw $t5, 0($t3)
addi $t3, $t4,  10916
li $t5, 0x020001
sw $t5, 0($t3)
addi $t3, $t4,  10920
li $t5, 0x060600
sw $t5, 0($t3)
addi $t3, $t4,  10924
li $t5, 0xfff200
sw $t5, 0($t3)
addi $t3, $t4,  10928
li $t5, 0xfef200
sw $t5, 0($t3)
addi $t3, $t4,  10932
li $t5, 0xfff301
sw $t5, 0($t3)
addi $t3, $t4,  10936
li $t5, 0xfff101
sw $t5, 0($t3)
addi $t3, $t4,  10940
li $t5, 0xfdf300
sw $t5, 0($t3)
addi $t3, $t4,  10944
li $t5, 0xeadf26
sw $t5, 0($t3)
addi $t3, $t4,  10948
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  10952
sw $t5, 0($t3)
addi $t3, $t4,  10956
sw $t5, 0($t3)
addi $t3, $t4,  10960
sw $t5, 0($t3)
addi $t3, $t4,  10964
sw $t5, 0($t3)
addi $t3, $t4,  10968
sw $t5, 0($t3)
addi $t3, $t4,  10972
sw $t5, 0($t3)
addi $t3, $t4,  10976
li $t5, 0x000300
sw $t5, 0($t3)
addi $t3, $t4,  10980
li $t5, 0xf6f306
sw $t5, 0($t3)
addi $t3, $t4,  10984
li $t5, 0xfef105
sw $t5, 0($t3)
addi $t3, $t4,  10988
li $t5, 0xfef200
sw $t5, 0($t3)
addi $t3, $t4,  10992
sw $t5, 0($t3)
addi $t3, $t4,  10996
li $t5, 0xf9f300
sw $t5, 0($t3)
addi $t3, $t4,  11000
li $t5, 0xfaf002
sw $t5, 0($t3)
addi $t3, $t4,  11004
li $t5, 0x000102
sw $t5, 0($t3)
addi $t3, $t4,  11008
sw $t5, 0($t3)
addi $t3, $t4,  11012
li $t5, 0xfaf002
sw $t5, 0($t3)
addi $t3, $t4,  11016
li $t5, 0xfaf300
sw $t5, 0($t3)
addi $t3, $t4,  11020
li $t5, 0xfff100
sw $t5, 0($t3)
addi $t3, $t4,  11024
sw $t5, 0($t3)
addi $t3, $t4,  11028
sw $t5, 0($t3)
addi $t3, $t4,  11032
sw $t5, 0($t3)
addi $t3, $t4,  11036
sw $t5, 0($t3)
addi $t3, $t4,  11040
sw $t5, 0($t3)
addi $t3, $t4,  11044
sw $t5, 0($t3)
addi $t3, $t4,  11048
sw $t5, 0($t3)
addi $t3, $t4,  11052
sw $t5, 0($t3)
addi $t3, $t4,  11056
sw $t5, 0($t3)
addi $t3, $t4,  11060
sw $t5, 0($t3)
addi $t3, $t4,  11064
sw $t5, 0($t3)
addi $t3, $t4,  11068
sw $t5, 0($t3)
addi $t3, $t4,  11072
sw $t5, 0($t3)
addi $t3, $t4,  11076
sw $t5, 0($t3)
addi $t3, $t4,  11080
sw $t5, 0($t3)
addi $t3, $t4,  11084
sw $t5, 0($t3)
addi $t3, $t4,  11088
li $t5, 0xffef00
sw $t5, 0($t3)
addi $t3, $t4,  11092
li $t5, 0x020200
sw $t5, 0($t3)
addi $t3, $t4,  11096
li $t5, 0x000001
sw $t5, 0($t3)
addi $t3, $t4,  11100
li $t5, 0xf8f51e
sw $t5, 0($t3)
addi $t3, $t4,  11104
li $t5, 0xfef000
sw $t5, 0($t3)
addi $t3, $t4,  11108
li $t5, 0xffee04
sw $t5, 0($t3)
addi $t3, $t4,  11112
li $t5, 0xfff000
sw $t5, 0($t3)
addi $t3, $t4,  11116
li $t5, 0xfff100
sw $t5, 0($t3)
addi $t3, $t4,  11120
li $t5, 0xfbf208
sw $t5, 0($t3)
addi $t3, $t4,  11124
li $t5, 0x0a0400
sw $t5, 0($t3)
addi $t3, $t4,  11128
li $t5, 0x0a0104
sw $t5, 0($t3)
addi $t3, $t4,  11132
li $t5, 0x0a0200
sw $t5, 0($t3)
addi $t3, $t4,  11136
sw $t5, 0($t3)
addi $t3, $t4,  11140
sw $t5, 0($t3)
addi $t3, $t4,  11144
sw $t5, 0($t3)
addi $t3, $t4,  11148
sw $t5, 0($t3)
addi $t3, $t4,  11152
li $t5, 0x0b0200
sw $t5, 0($t3)
addi $t3, $t4,  11156
li $t5, 0x060700
sw $t5, 0($t3)
addi $t3, $t4,  11160
li $t5, 0x000002
sw $t5, 0($t3)
addi $t3, $t4,  11164
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  11168
sw $t5, 0($t3)
addi $t3, $t4,  11172
sw $t5, 0($t3)
addi $t3, $t4,  11176
sw $t5, 0($t3)
addi $t3, $t4,  11180
sw $t5, 0($t3)
addi $t3, $t4,  11184
sw $t5, 0($t3)
addi $t3, $t4,  11188
sw $t5, 0($t3)
addi $t3, $t4,  11192
sw $t5, 0($t3)
addi $t3, $t4,  11196
sw $t5, 0($t3)
addi $t3, $t4,  11200
sw $t5, 0($t3)
addi $t3, $t4,  11204
sw $t5, 0($t3)
addi $t3, $t4,  11208
sw $t5, 0($t3)
addi $t3, $t4,  11212
sw $t5, 0($t3)
addi $t3, $t4,  11216
sw $t5, 0($t3)
addi $t3, $t4,  11220
sw $t5, 0($t3)
addi $t3, $t4,  11224
sw $t5, 0($t3)
addi $t3, $t4,  11228
sw $t5, 0($t3)
addi $t3, $t4,  11232
sw $t5, 0($t3)
addi $t3, $t4,  11236
sw $t5, 0($t3)
addi $t3, $t4,  11240
sw $t5, 0($t3)
addi $t3, $t4,  11244
sw $t5, 0($t3)
addi $t3, $t4,  11248
sw $t5, 0($t3)
addi $t3, $t4,  11252
sw $t5, 0($t3)
addi $t3, $t4,  11256
sw $t5, 0($t3)
addi $t3, $t4,  11260
sw $t5, 0($t3)
syscall #sleep for 30 ms
addi $t3, $t4,  11264
sw $t5, 0($t3)
addi $t3, $t4,  11268
sw $t5, 0($t3)
addi $t3, $t4,  11272
sw $t5, 0($t3)
addi $t3, $t4,  11276
sw $t5, 0($t3)
addi $t3, $t4,  11280
sw $t5, 0($t3)
addi $t3, $t4,  11284
sw $t5, 0($t3)
addi $t3, $t4,  11288
sw $t5, 0($t3)
addi $t3, $t4,  11292
sw $t5, 0($t3)
addi $t3, $t4,  11296
sw $t5, 0($t3)
addi $t3, $t4,  11300
sw $t5, 0($t3)
addi $t3, $t4,  11304
sw $t5, 0($t3)
addi $t3, $t4,  11308
sw $t5, 0($t3)
addi $t3, $t4,  11312
sw $t5, 0($t3)
addi $t3, $t4,  11316
sw $t5, 0($t3)
addi $t3, $t4,  11320
sw $t5, 0($t3)
addi $t3, $t4,  11324
sw $t5, 0($t3)
addi $t3, $t4,  11328
sw $t5, 0($t3)
addi $t3, $t4,  11332
sw $t5, 0($t3)
addi $t3, $t4,  11336
li $t5, 0x010000
sw $t5, 0($t3)
addi $t3, $t4,  11340
li $t5, 0x000300
sw $t5, 0($t3)
addi $t3, $t4,  11344
li $t5, 0xf6ed31
sw $t5, 0($t3)
addi $t3, $t4,  11348
li $t5, 0xffee02
sw $t5, 0($t3)
addi $t3, $t4,  11352
sw $t5, 0($t3)
addi $t3, $t4,  11356
sw $t5, 0($t3)
addi $t3, $t4,  11360
sw $t5, 0($t3)
addi $t3, $t4,  11364
li $t5, 0xfdef03
sw $t5, 0($t3)
addi $t3, $t4,  11368
li $t5, 0x040301
sw $t5, 0($t3)
addi $t3, $t4,  11372
li $t5, 0x020000
sw $t5, 0($t3)
addi $t3, $t4,  11376
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  11380
sw $t5, 0($t3)
addi $t3, $t4,  11384
sw $t5, 0($t3)
addi $t3, $t4,  11388
li $t5, 0x0d0201
sw $t5, 0($t3)
addi $t3, $t4,  11392
li $t5, 0xfdef00
sw $t5, 0($t3)
addi $t3, $t4,  11396
li $t5, 0xfeee00
sw $t5, 0($t3)
addi $t3, $t4,  11400
li $t5, 0xfeef00
sw $t5, 0($t3)
addi $t3, $t4,  11404
sw $t5, 0($t3)
addi $t3, $t4,  11408
sw $t5, 0($t3)
addi $t3, $t4,  11412
sw $t5, 0($t3)
addi $t3, $t4,  11416
li $t5, 0xfcf000
sw $t5, 0($t3)
addi $t3, $t4,  11420
li $t5, 0xffee00
sw $t5, 0($t3)
addi $t3, $t4,  11424
li $t5, 0x3f3e0c
sw $t5, 0($t3)
addi $t3, $t4,  11428
li $t5, 0x020001
sw $t5, 0($t3)
addi $t3, $t4,  11432
li $t5, 0x030300
sw $t5, 0($t3)
addi $t3, $t4,  11436
li $t5, 0xffee00
sw $t5, 0($t3)
addi $t3, $t4,  11440
li $t5, 0xfeee02
sw $t5, 0($t3)
addi $t3, $t4,  11444
sw $t5, 0($t3)
addi $t3, $t4,  11448
li $t5, 0xffed02
sw $t5, 0($t3)
addi $t3, $t4,  11452
li $t5, 0xfdef00
sw $t5, 0($t3)
addi $t3, $t4,  11456
li $t5, 0xeadc27
sw $t5, 0($t3)
addi $t3, $t4,  11460
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  11464
sw $t5, 0($t3)
addi $t3, $t4,  11468
sw $t5, 0($t3)
addi $t3, $t4,  11472
sw $t5, 0($t3)
addi $t3, $t4,  11476
sw $t5, 0($t3)
addi $t3, $t4,  11480
sw $t5, 0($t3)
addi $t3, $t4,  11484
sw $t5, 0($t3)
addi $t3, $t4,  11488
li $t5, 0x010101
sw $t5, 0($t3)
addi $t3, $t4,  11492
li $t5, 0xf4ee06
sw $t5, 0($t3)
addi $t3, $t4,  11496
li $t5, 0xfeec05
sw $t5, 0($t3)
addi $t3, $t4,  11500
li $t5, 0xfded01
sw $t5, 0($t3)
addi $t3, $t4,  11504
sw $t5, 0($t3)
addi $t3, $t4,  11508
li $t5, 0xfaf000
sw $t5, 0($t3)
addi $t3, $t4,  11512
li $t5, 0xfbec02
sw $t5, 0($t3)
addi $t3, $t4,  11516
li $t5, 0x030102
sw $t5, 0($t3)
addi $t3, $t4,  11520
li $t5, 0x020002
sw $t5, 0($t3)
addi $t3, $t4,  11524
li $t5, 0xfbec02
sw $t5, 0($t3)
addi $t3, $t4,  11528
li $t5, 0xfbef00
sw $t5, 0($t3)
addi $t3, $t4,  11532
li $t5, 0xffec01
sw $t5, 0($t3)
addi $t3, $t4,  11536
sw $t5, 0($t3)
addi $t3, $t4,  11540
sw $t5, 0($t3)
addi $t3, $t4,  11544
sw $t5, 0($t3)
addi $t3, $t4,  11548
sw $t5, 0($t3)
addi $t3, $t4,  11552
sw $t5, 0($t3)
addi $t3, $t4,  11556
sw $t5, 0($t3)
addi $t3, $t4,  11560
sw $t5, 0($t3)
addi $t3, $t4,  11564
sw $t5, 0($t3)
addi $t3, $t4,  11568
sw $t5, 0($t3)
addi $t3, $t4,  11572
sw $t5, 0($t3)
addi $t3, $t4,  11576
sw $t5, 0($t3)
addi $t3, $t4,  11580
sw $t5, 0($t3)
addi $t3, $t4,  11584
sw $t5, 0($t3)
addi $t3, $t4,  11588
sw $t5, 0($t3)
addi $t3, $t4,  11592
sw $t5, 0($t3)
addi $t3, $t4,  11596
sw $t5, 0($t3)
addi $t3, $t4,  11600
li $t5, 0xffec00
sw $t5, 0($t3)
addi $t3, $t4,  11604
li $t5, 0x030400
sw $t5, 0($t3)
addi $t3, $t4,  11608
li $t5, 0x000001
sw $t5, 0($t3)
addi $t3, $t4,  11612
li $t5, 0xf8f11e
sw $t5, 0($t3)
addi $t3, $t4,  11616
li $t5, 0xffec01
sw $t5, 0($t3)
addi $t3, $t4,  11620
li $t5, 0xffea06
sw $t5, 0($t3)
addi $t3, $t4,  11624
li $t5, 0xffec01
sw $t5, 0($t3)
addi $t3, $t4,  11628
sw $t5, 0($t3)
addi $t3, $t4,  11632
li $t5, 0xffe905
sw $t5, 0($t3)
addi $t3, $t4,  11636
li $t5, 0xfded00
sw $t5, 0($t3)
addi $t3, $t4,  11640
li $t5, 0xfeeb02
sw $t5, 0($t3)
addi $t3, $t4,  11644
li $t5, 0xfce903
sw $t5, 0($t3)
addi $t3, $t4,  11648
li $t5, 0xfeeb04
sw $t5, 0($t3)
addi $t3, $t4,  11652
sw $t5, 0($t3)
addi $t3, $t4,  11656
sw $t5, 0($t3)
addi $t3, $t4,  11660
li $t5, 0xfeeb03
sw $t5, 0($t3)
addi $t3, $t4,  11664
li $t5, 0xffeb01
sw $t5, 0($t3)
addi $t3, $t4,  11668
li $t5, 0xfaf50f
sw $t5, 0($t3)
addi $t3, $t4,  11672
li $t5, 0x000100
sw $t5, 0($t3)
addi $t3, $t4,  11676
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  11680
sw $t5, 0($t3)
addi $t3, $t4,  11684
sw $t5, 0($t3)
addi $t3, $t4,  11688
sw $t5, 0($t3)
addi $t3, $t4,  11692
sw $t5, 0($t3)
addi $t3, $t4,  11696
sw $t5, 0($t3)
addi $t3, $t4,  11700
sw $t5, 0($t3)
addi $t3, $t4,  11704
sw $t5, 0($t3)
addi $t3, $t4,  11708
sw $t5, 0($t3)
addi $t3, $t4,  11712
sw $t5, 0($t3)
addi $t3, $t4,  11716
sw $t5, 0($t3)
addi $t3, $t4,  11720
sw $t5, 0($t3)
addi $t3, $t4,  11724
sw $t5, 0($t3)
addi $t3, $t4,  11728
sw $t5, 0($t3)
addi $t3, $t4,  11732
sw $t5, 0($t3)
addi $t3, $t4,  11736
sw $t5, 0($t3)
addi $t3, $t4,  11740
sw $t5, 0($t3)
addi $t3, $t4,  11744
sw $t5, 0($t3)
addi $t3, $t4,  11748
sw $t5, 0($t3)
addi $t3, $t4,  11752
sw $t5, 0($t3)
addi $t3, $t4,  11756
sw $t5, 0($t3)
addi $t3, $t4,  11760
sw $t5, 0($t3)
addi $t3, $t4,  11764
sw $t5, 0($t3)
addi $t3, $t4,  11768
sw $t5, 0($t3)
addi $t3, $t4,  11772
sw $t5, 0($t3)
syscall #sleep for 30 ms
addi $t3, $t4,  11776
sw $t5, 0($t3)
addi $t3, $t4,  11780
sw $t5, 0($t3)
addi $t3, $t4,  11784
sw $t5, 0($t3)
addi $t3, $t4,  11788
sw $t5, 0($t3)
addi $t3, $t4,  11792
sw $t5, 0($t3)
addi $t3, $t4,  11796
sw $t5, 0($t3)
addi $t3, $t4,  11800
sw $t5, 0($t3)
addi $t3, $t4,  11804
sw $t5, 0($t3)
addi $t3, $t4,  11808
sw $t5, 0($t3)
addi $t3, $t4,  11812
sw $t5, 0($t3)
addi $t3, $t4,  11816
sw $t5, 0($t3)
addi $t3, $t4,  11820
sw $t5, 0($t3)
addi $t3, $t4,  11824
sw $t5, 0($t3)
addi $t3, $t4,  11828
sw $t5, 0($t3)
addi $t3, $t4,  11832
sw $t5, 0($t3)
addi $t3, $t4,  11836
sw $t5, 0($t3)
addi $t3, $t4,  11840
sw $t5, 0($t3)
addi $t3, $t4,  11844
sw $t5, 0($t3)
addi $t3, $t4,  11848
li $t5, 0x020001
sw $t5, 0($t3)
addi $t3, $t4,  11852
li $t5, 0x000200
sw $t5, 0($t3)
addi $t3, $t4,  11856
li $t5, 0xf7e730
sw $t5, 0($t3)
addi $t3, $t4,  11860
li $t5, 0xffe900
sw $t5, 0($t3)
addi $t3, $t4,  11864
sw $t5, 0($t3)
addi $t3, $t4,  11868
sw $t5, 0($t3)
addi $t3, $t4,  11872
sw $t5, 0($t3)
addi $t3, $t4,  11876
li $t5, 0xfee903
sw $t5, 0($t3)
addi $t3, $t4,  11880
li $t5, 0x030001
sw $t5, 0($t3)
addi $t3, $t4,  11884
li $t5, 0x020001
sw $t5, 0($t3)
addi $t3, $t4,  11888
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  11892
sw $t5, 0($t3)
addi $t3, $t4,  11896
sw $t5, 0($t3)
addi $t3, $t4,  11900
li $t5, 0x070302
sw $t5, 0($t3)
addi $t3, $t4,  11904
li $t5, 0xffe900
sw $t5, 0($t3)
addi $t3, $t4,  11908
li $t5, 0xffe706
sw $t5, 0($t3)
addi $t3, $t4,  11912
li $t5, 0xffe800
sw $t5, 0($t3)
addi $t3, $t4,  11916
li $t5, 0xfeeb00
sw $t5, 0($t3)
addi $t3, $t4,  11920
li $t5, 0xffe900
sw $t5, 0($t3)
addi $t3, $t4,  11924
sw $t5, 0($t3)
addi $t3, $t4,  11928
li $t5, 0xffe706
sw $t5, 0($t3)
addi $t3, $t4,  11932
li $t5, 0xffe705
sw $t5, 0($t3)
addi $t3, $t4,  11936
li $t5, 0x453c13
sw $t5, 0($t3)
addi $t3, $t4,  11940
li $t5, 0x000002
sw $t5, 0($t3)
addi $t3, $t4,  11944
li $t5, 0x050200
sw $t5, 0($t3)
addi $t3, $t4,  11948
li $t5, 0xffe700
sw $t5, 0($t3)
addi $t3, $t4,  11952
sw $t5, 0($t3)
addi $t3, $t4,  11956
sw $t5, 0($t3)
addi $t3, $t4,  11960
li $t5, 0xfee801
sw $t5, 0($t3)
addi $t3, $t4,  11964
li $t5, 0xfee900
sw $t5, 0($t3)
addi $t3, $t4,  11968
li $t5, 0xebd821
sw $t5, 0($t3)
addi $t3, $t4,  11972
li $t5, 0x000200
sw $t5, 0($t3)
addi $t3, $t4,  11976
sw $t5, 0($t3)
addi $t3, $t4,  11980
sw $t5, 0($t3)
addi $t3, $t4,  11984
sw $t5, 0($t3)
addi $t3, $t4,  11988
sw $t5, 0($t3)
addi $t3, $t4,  11992
sw $t5, 0($t3)
addi $t3, $t4,  11996
sw $t5, 0($t3)
addi $t3, $t4,  12000
li $t5, 0x000401
sw $t5, 0($t3)
addi $t3, $t4,  12004
li $t5, 0xf1ed05
sw $t5, 0($t3)
addi $t3, $t4,  12008
li $t5, 0xffe605
sw $t5, 0($t3)
addi $t3, $t4,  12012
li $t5, 0xffe700
sw $t5, 0($t3)
addi $t3, $t4,  12016
sw $t5, 0($t3)
addi $t3, $t4,  12020
li $t5, 0xfeea00
sw $t5, 0($t3)
addi $t3, $t4,  12024
li $t5, 0xfbe706
sw $t5, 0($t3)
addi $t3, $t4,  12028
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  12032
li $t5, 0x000101
sw $t5, 0($t3)
addi $t3, $t4,  12036
li $t5, 0xfbe702
sw $t5, 0($t3)
addi $t3, $t4,  12040
li $t5, 0xfee901
sw $t5, 0($t3)
addi $t3, $t4,  12044
li $t5, 0xffe700
sw $t5, 0($t3)
addi $t3, $t4,  12048
sw $t5, 0($t3)
addi $t3, $t4,  12052
li $t5, 0xffe703
sw $t5, 0($t3)
addi $t3, $t4,  12056
li $t5, 0xfee800
sw $t5, 0($t3)
addi $t3, $t4,  12060
li $t5, 0xffe800
sw $t5, 0($t3)
addi $t3, $t4,  12064
li $t5, 0xffe700
sw $t5, 0($t3)
addi $t3, $t4,  12068
li $t5, 0xffe508
sw $t5, 0($t3)
addi $t3, $t4,  12072
li $t5, 0xfdea00
sw $t5, 0($t3)
addi $t3, $t4,  12076
li $t5, 0xffe609
sw $t5, 0($t3)
addi $t3, $t4,  12080
li $t5, 0xffe800
sw $t5, 0($t3)
addi $t3, $t4,  12084
li $t5, 0xffe602
sw $t5, 0($t3)
addi $t3, $t4,  12088
sw $t5, 0($t3)
addi $t3, $t4,  12092
li $t5, 0xfde900
sw $t5, 0($t3)
addi $t3, $t4,  12096
li $t5, 0xfee800
sw $t5, 0($t3)
addi $t3, $t4,  12100
li $t5, 0xfde801
sw $t5, 0($t3)
addi $t3, $t4,  12104
li $t5, 0xffe700
sw $t5, 0($t3)
addi $t3, $t4,  12108
li $t5, 0xfee600
sw $t5, 0($t3)
addi $t3, $t4,  12112
li $t5, 0xffe600
sw $t5, 0($t3)
addi $t3, $t4,  12116
li $t5, 0x060400
sw $t5, 0($t3)
addi $t3, $t4,  12120
li $t5, 0x000005
sw $t5, 0($t3)
addi $t3, $t4,  12124
li $t5, 0xf5ee1d
sw $t5, 0($t3)
addi $t3, $t4,  12128
li $t5, 0xfde700
sw $t5, 0($t3)
addi $t3, $t4,  12132
li $t5, 0xffe406
sw $t5, 0($t3)
addi $t3, $t4,  12136
li $t5, 0xfee600
sw $t5, 0($t3)
addi $t3, $t4,  12140
sw $t5, 0($t3)
addi $t3, $t4,  12144
li $t5, 0xffe504
sw $t5, 0($t3)
addi $t3, $t4,  12148
li $t5, 0xffe500
sw $t5, 0($t3)
addi $t3, $t4,  12152
li $t5, 0xffe206
sw $t5, 0($t3)
addi $t3, $t4,  12156
li $t5, 0xffe404
sw $t5, 0($t3)
addi $t3, $t4,  12160
sw $t5, 0($t3)
addi $t3, $t4,  12164
sw $t5, 0($t3)
addi $t3, $t4,  12168
sw $t5, 0($t3)
addi $t3, $t4,  12172
sw $t5, 0($t3)
addi $t3, $t4,  12176
li $t5, 0xffe600
sw $t5, 0($t3)
addi $t3, $t4,  12180
li $t5, 0xfaea17
sw $t5, 0($t3)
addi $t3, $t4,  12184
li $t5, 0x000004
sw $t5, 0($t3)
addi $t3, $t4,  12188
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  12192
sw $t5, 0($t3)
addi $t3, $t4,  12196
sw $t5, 0($t3)
addi $t3, $t4,  12200
sw $t5, 0($t3)
addi $t3, $t4,  12204
sw $t5, 0($t3)
addi $t3, $t4,  12208
sw $t5, 0($t3)
addi $t3, $t4,  12212
sw $t5, 0($t3)
addi $t3, $t4,  12216
sw $t5, 0($t3)
addi $t3, $t4,  12220
sw $t5, 0($t3)
addi $t3, $t4,  12224
sw $t5, 0($t3)
addi $t3, $t4,  12228
sw $t5, 0($t3)
addi $t3, $t4,  12232
sw $t5, 0($t3)
addi $t3, $t4,  12236
sw $t5, 0($t3)
addi $t3, $t4,  12240
sw $t5, 0($t3)
addi $t3, $t4,  12244
sw $t5, 0($t3)
addi $t3, $t4,  12248
sw $t5, 0($t3)
addi $t3, $t4,  12252
sw $t5, 0($t3)
addi $t3, $t4,  12256
sw $t5, 0($t3)
addi $t3, $t4,  12260
sw $t5, 0($t3)
addi $t3, $t4,  12264
sw $t5, 0($t3)
addi $t3, $t4,  12268
sw $t5, 0($t3)
addi $t3, $t4,  12272
sw $t5, 0($t3)
addi $t3, $t4,  12276
sw $t5, 0($t3)
addi $t3, $t4,  12280
sw $t5, 0($t3)
addi $t3, $t4,  12284
sw $t5, 0($t3)
syscall #sleep for 30 ms
addi $t3, $t4,  12288
sw $t5, 0($t3)
addi $t3, $t4,  12292
sw $t5, 0($t3)
addi $t3, $t4,  12296
sw $t5, 0($t3)
addi $t3, $t4,  12300
sw $t5, 0($t3)
addi $t3, $t4,  12304
sw $t5, 0($t3)
addi $t3, $t4,  12308
sw $t5, 0($t3)
addi $t3, $t4,  12312
sw $t5, 0($t3)
addi $t3, $t4,  12316
sw $t5, 0($t3)
addi $t3, $t4,  12320
sw $t5, 0($t3)
addi $t3, $t4,  12324
sw $t5, 0($t3)
addi $t3, $t4,  12328
sw $t5, 0($t3)
addi $t3, $t4,  12332
sw $t5, 0($t3)
addi $t3, $t4,  12336
sw $t5, 0($t3)
addi $t3, $t4,  12340
sw $t5, 0($t3)
addi $t3, $t4,  12344
sw $t5, 0($t3)
addi $t3, $t4,  12348
sw $t5, 0($t3)
addi $t3, $t4,  12352
sw $t5, 0($t3)
addi $t3, $t4,  12356
sw $t5, 0($t3)
addi $t3, $t4,  12360
li $t5, 0x020001
sw $t5, 0($t3)
addi $t3, $t4,  12364
li $t5, 0x000300
sw $t5, 0($t3)
addi $t3, $t4,  12368
li $t5, 0xf6e32f
sw $t5, 0($t3)
addi $t3, $t4,  12372
li $t5, 0xffe401
sw $t5, 0($t3)
addi $t3, $t4,  12376
sw $t5, 0($t3)
addi $t3, $t4,  12380
sw $t5, 0($t3)
addi $t3, $t4,  12384
sw $t5, 0($t3)
addi $t3, $t4,  12388
li $t5, 0xfce502
sw $t5, 0($t3)
addi $t3, $t4,  12392
li $t5, 0x030001
sw $t5, 0($t3)
addi $t3, $t4,  12396
li $t5, 0x020001
sw $t5, 0($t3)
addi $t3, $t4,  12400
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  12404
sw $t5, 0($t3)
addi $t3, $t4,  12408
sw $t5, 0($t3)
addi $t3, $t4,  12412
li $t5, 0x010110
sw $t5, 0($t3)
addi $t3, $t4,  12416
li $t5, 0x332403
sw $t5, 0($t3)
addi $t3, $t4,  12420
li $t5, 0x2c2a02
sw $t5, 0($t3)
addi $t3, $t4,  12424
li $t5, 0x3f3000
sw $t5, 0($t3)
addi $t3, $t4,  12428
li $t5, 0xffe300
sw $t5, 0($t3)
addi $t3, $t4,  12432
li $t5, 0xffe401
sw $t5, 0($t3)
addi $t3, $t4,  12436
sw $t5, 0($t3)
addi $t3, $t4,  12440
li $t5, 0xffe206
sw $t5, 0($t3)
addi $t3, $t4,  12444
li $t5, 0xffe305
sw $t5, 0($t3)
addi $t3, $t4,  12448
li $t5, 0x463913
sw $t5, 0($t3)
addi $t3, $t4,  12452
li $t5, 0x000002
sw $t5, 0($t3)
addi $t3, $t4,  12456
li $t5, 0x050200
sw $t5, 0($t3)
addi $t3, $t4,  12460
li $t5, 0xffe400
sw $t5, 0($t3)
addi $t3, $t4,  12464
li $t5, 0xffe301
sw $t5, 0($t3)
addi $t3, $t4,  12468
sw $t5, 0($t3)
addi $t3, $t4,  12472
li $t5, 0xffe304
sw $t5, 0($t3)
addi $t3, $t4,  12476
li $t5, 0xfde202
sw $t5, 0($t3)
addi $t3, $t4,  12480
li $t5, 0xfce304
sw $t5, 0($t3)
addi $t3, $t4,  12484
li $t5, 0xf4e618
sw $t5, 0($t3)
addi $t3, $t4,  12488
li $t5, 0xf3e517
sw $t5, 0($t3)
addi $t3, $t4,  12492
li $t5, 0xf2e416
sw $t5, 0($t3)
addi $t3, $t4,  12496
li $t5, 0xf3e516
sw $t5, 0($t3)
addi $t3, $t4,  12500
li $t5, 0xf3e517
sw $t5, 0($t3)
addi $t3, $t4,  12504
sw $t5, 0($t3)
addi $t3, $t4,  12508
li $t5, 0xf2e416
sw $t5, 0($t3)
addi $t3, $t4,  12512
li $t5, 0xf3e31d
sw $t5, 0($t3)
addi $t3, $t4,  12516
li $t5, 0xfae300
sw $t5, 0($t3)
addi $t3, $t4,  12520
li $t5, 0xffe301
sw $t5, 0($t3)
addi $t3, $t4,  12524
sw $t5, 0($t3)
addi $t3, $t4,  12528
sw $t5, 0($t3)
addi $t3, $t4,  12532
li $t5, 0xfde400
sw $t5, 0($t3)
addi $t3, $t4,  12536
li $t5, 0xfae106
sw $t5, 0($t3)
addi $t3, $t4,  12540
li $t5, 0x020001
sw $t5, 0($t3)
addi $t3, $t4,  12544
li $t5, 0x030003
sw $t5, 0($t3)
addi $t3, $t4,  12548
li $t5, 0xfae202
sw $t5, 0($t3)
addi $t3, $t4,  12552
li $t5, 0xfde300
sw $t5, 0($t3)
addi $t3, $t4,  12556
li $t5, 0xffe200
sw $t5, 0($t3)
addi $t3, $t4,  12560
sw $t5, 0($t3)
addi $t3, $t4,  12564
li $t5, 0xfde301
sw $t5, 0($t3)
addi $t3, $t4,  12568
li $t5, 0xf6db10
sw $t5, 0($t3)
addi $t3, $t4,  12572
li $t5, 0x190f00
sw $t5, 0($t3)
addi $t3, $t4,  12576
li $t5, 0x0e0a00
sw $t5, 0($t3)
addi $t3, $t4,  12580
li $t5, 0x1e0c00
sw $t5, 0($t3)
addi $t3, $t4,  12584
li $t5, 0xfce302
sw $t5, 0($t3)
addi $t3, $t4,  12588
li $t5, 0xfede0a
sw $t5, 0($t3)
addi $t3, $t4,  12592
li $t5, 0xb69f17
sw $t5, 0($t3)
addi $t3, $t4,  12596
li $t5, 0x110800
sw $t5, 0($t3)
addi $t3, $t4,  12600
sw $t5, 0($t3)
addi $t3, $t4,  12604
li $t5, 0x988611
sw $t5, 0($t3)
addi $t3, $t4,  12608
li $t5, 0xfde400
sw $t5, 0($t3)
addi $t3, $t4,  12612
li $t5, 0xfee204
sw $t5, 0($t3)
addi $t3, $t4,  12616
li $t5, 0xffe200
sw $t5, 0($t3)
addi $t3, $t4,  12620
sw $t5, 0($t3)
addi $t3, $t4,  12624
li $t5, 0xfee200
sw $t5, 0($t3)
addi $t3, $t4,  12628
li $t5, 0x050400
sw $t5, 0($t3)
addi $t3, $t4,  12632
li $t5, 0x000005
sw $t5, 0($t3)
addi $t3, $t4,  12636
li $t5, 0xf6ea1d
sw $t5, 0($t3)
addi $t3, $t4,  12640
li $t5, 0xfee301
sw $t5, 0($t3)
addi $t3, $t4,  12644
li $t5, 0xffdf08
sw $t5, 0($t3)
addi $t3, $t4,  12648
li $t5, 0xffe200
sw $t5, 0($t3)
addi $t3, $t4,  12652
sw $t5, 0($t3)
addi $t3, $t4,  12656
li $t5, 0xfde205
sw $t5, 0($t3)
addi $t3, $t4,  12660
li $t5, 0x170500
sw $t5, 0($t3)
addi $t3, $t4,  12664
li $t5, 0x100503
sw $t5, 0($t3)
addi $t3, $t4,  12668
li $t5, 0x140800
sw $t5, 0($t3)
addi $t3, $t4,  12672
sw $t5, 0($t3)
addi $t3, $t4,  12676
sw $t5, 0($t3)
addi $t3, $t4,  12680
sw $t5, 0($t3)
addi $t3, $t4,  12684
sw $t5, 0($t3)
addi $t3, $t4,  12688
li $t5, 0x100a00
sw $t5, 0($t3)
addi $t3, $t4,  12692
li $t5, 0x170800
sw $t5, 0($t3)
addi $t3, $t4,  12696
li $t5, 0x000004
sw $t5, 0($t3)
addi $t3, $t4,  12700
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  12704
sw $t5, 0($t3)
addi $t3, $t4,  12708
sw $t5, 0($t3)
addi $t3, $t4,  12712
sw $t5, 0($t3)
addi $t3, $t4,  12716
sw $t5, 0($t3)
addi $t3, $t4,  12720
sw $t5, 0($t3)
addi $t3, $t4,  12724
sw $t5, 0($t3)
addi $t3, $t4,  12728
sw $t5, 0($t3)
addi $t3, $t4,  12732
sw $t5, 0($t3)
addi $t3, $t4,  12736
sw $t5, 0($t3)
addi $t3, $t4,  12740
sw $t5, 0($t3)
addi $t3, $t4,  12744
sw $t5, 0($t3)
addi $t3, $t4,  12748
sw $t5, 0($t3)
addi $t3, $t4,  12752
sw $t5, 0($t3)
addi $t3, $t4,  12756
sw $t5, 0($t3)
addi $t3, $t4,  12760
sw $t5, 0($t3)
addi $t3, $t4,  12764
sw $t5, 0($t3)
addi $t3, $t4,  12768
sw $t5, 0($t3)
addi $t3, $t4,  12772
sw $t5, 0($t3)
addi $t3, $t4,  12776
sw $t5, 0($t3)
addi $t3, $t4,  12780
sw $t5, 0($t3)
addi $t3, $t4,  12784
sw $t5, 0($t3)
addi $t3, $t4,  12788
sw $t5, 0($t3)
addi $t3, $t4,  12792
sw $t5, 0($t3)
addi $t3, $t4,  12796
sw $t5, 0($t3)
syscall #sleep for 30 ms
addi $t3, $t4,  12800
sw $t5, 0($t3)
addi $t3, $t4,  12804
sw $t5, 0($t3)
addi $t3, $t4,  12808
sw $t5, 0($t3)
addi $t3, $t4,  12812
sw $t5, 0($t3)
addi $t3, $t4,  12816
sw $t5, 0($t3)
addi $t3, $t4,  12820
sw $t5, 0($t3)
addi $t3, $t4,  12824
sw $t5, 0($t3)
addi $t3, $t4,  12828
sw $t5, 0($t3)
addi $t3, $t4,  12832
sw $t5, 0($t3)
addi $t3, $t4,  12836
sw $t5, 0($t3)
addi $t3, $t4,  12840
sw $t5, 0($t3)
addi $t3, $t4,  12844
sw $t5, 0($t3)
addi $t3, $t4,  12848
sw $t5, 0($t3)
addi $t3, $t4,  12852
sw $t5, 0($t3)
addi $t3, $t4,  12856
sw $t5, 0($t3)
addi $t3, $t4,  12860
sw $t5, 0($t3)
addi $t3, $t4,  12864
sw $t5, 0($t3)
addi $t3, $t4,  12868
sw $t5, 0($t3)
addi $t3, $t4,  12872
li $t5, 0x020000
sw $t5, 0($t3)
addi $t3, $t4,  12876
li $t5, 0x000300
sw $t5, 0($t3)
addi $t3, $t4,  12880
li $t5, 0xf2e02d
sw $t5, 0($t3)
addi $t3, $t4,  12884
li $t5, 0xfbe101
sw $t5, 0($t3)
addi $t3, $t4,  12888
sw $t5, 0($t3)
addi $t3, $t4,  12892
li $t5, 0xffe000
sw $t5, 0($t3)
addi $t3, $t4,  12896
li $t5, 0xfedf00
sw $t5, 0($t3)
addi $t3, $t4,  12900
li $t5, 0xfddf02
sw $t5, 0($t3)
addi $t3, $t4,  12904
li $t5, 0x060001
sw $t5, 0($t3)
addi $t3, $t4,  12908
li $t5, 0x010001
sw $t5, 0($t3)
addi $t3, $t4,  12912
li $t5, 0x000200
sw $t5, 0($t3)
addi $t3, $t4,  12916
li $t5, 0x000004
sw $t5, 0($t3)
addi $t3, $t4,  12920
li $t5, 0x000100
sw $t5, 0($t3)
addi $t3, $t4,  12924
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  12928
sw $t5, 0($t3)
addi $t3, $t4,  12932
li $t5, 0x020000
sw $t5, 0($t3)
addi $t3, $t4,  12936
li $t5, 0x110600
sw $t5, 0($t3)
addi $t3, $t4,  12940
li $t5, 0xffdf05
sw $t5, 0($t3)
addi $t3, $t4,  12944
li $t5, 0xffdd00
sw $t5, 0($t3)
addi $t3, $t4,  12948
sw $t5, 0($t3)
addi $t3, $t4,  12952
li $t5, 0xffdc04
sw $t5, 0($t3)
addi $t3, $t4,  12956
li $t5, 0xffdb07
sw $t5, 0($t3)
addi $t3, $t4,  12960
li $t5, 0x463a12
sw $t5, 0($t3)
addi $t3, $t4,  12964
li $t5, 0x010005
sw $t5, 0($t3)
addi $t3, $t4,  12968
li $t5, 0x060200
sw $t5, 0($t3)
addi $t3, $t4,  12972
li $t5, 0xffdd00
sw $t5, 0($t3)
addi $t3, $t4,  12976
sw $t5, 0($t3)
addi $t3, $t4,  12980
sw $t5, 0($t3)
addi $t3, $t4,  12984
sw $t5, 0($t3)
addi $t3, $t4,  12988
sw $t5, 0($t3)
addi $t3, $t4,  12992
li $t5, 0xffde00
sw $t5, 0($t3)
addi $t3, $t4,  12996
li $t5, 0xfddf00
sw $t5, 0($t3)
addi $t3, $t4,  13000
sw $t5, 0($t3)
addi $t3, $t4,  13004
sw $t5, 0($t3)
addi $t3, $t4,  13008
sw $t5, 0($t3)
addi $t3, $t4,  13012
sw $t5, 0($t3)
addi $t3, $t4,  13016
sw $t5, 0($t3)
addi $t3, $t4,  13020
sw $t5, 0($t3)
addi $t3, $t4,  13024
li $t5, 0xfedd03
sw $t5, 0($t3)
addi $t3, $t4,  13028
li $t5, 0xfdde02
sw $t5, 0($t3)
addi $t3, $t4,  13032
sw $t5, 0($t3)
addi $t3, $t4,  13036
li $t5, 0xffdc00
sw $t5, 0($t3)
addi $t3, $t4,  13040
sw $t5, 0($t3)
addi $t3, $t4,  13044
li $t5, 0xfddf00
sw $t5, 0($t3)
addi $t3, $t4,  13048
li $t5, 0xfbdb04
sw $t5, 0($t3)
addi $t3, $t4,  13052
li $t5, 0x000100
sw $t5, 0($t3)
addi $t3, $t4,  13056
li $t5, 0x030000
sw $t5, 0($t3)
addi $t3, $t4,  13060
li $t5, 0xf8dd04
sw $t5, 0($t3)
addi $t3, $t4,  13064
li $t5, 0xfddf00
sw $t5, 0($t3)
addi $t3, $t4,  13068
li $t5, 0xffdc00
sw $t5, 0($t3)
addi $t3, $t4,  13072
sw $t5, 0($t3)
addi $t3, $t4,  13076
li $t5, 0xffdd00
sw $t5, 0($t3)
addi $t3, $t4,  13080
li $t5, 0xfddf08
sw $t5, 0($t3)
addi $t3, $t4,  13084
li $t5, 0x000202
sw $t5, 0($t3)
addi $t3, $t4,  13088
li $t5, 0x000300
sw $t5, 0($t3)
addi $t3, $t4,  13092
li $t5, 0x0f0002
sw $t5, 0($t3)
addi $t3, $t4,  13096
li $t5, 0xfcde00
sw $t5, 0($t3)
addi $t3, $t4,  13100
li $t5, 0xffd901
sw $t5, 0($t3)
addi $t3, $t4,  13104
li $t5, 0xa89c2b
sw $t5, 0($t3)
addi $t3, $t4,  13108
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  13112
sw $t5, 0($t3)
addi $t3, $t4,  13116
li $t5, 0x94841a
sw $t5, 0($t3)
addi $t3, $t4,  13120
li $t5, 0xffd90a
sw $t5, 0($t3)
addi $t3, $t4,  13124
li $t5, 0xfedb07
sw $t5, 0($t3)
addi $t3, $t4,  13128
li $t5, 0xfddc00
sw $t5, 0($t3)
addi $t3, $t4,  13132
sw $t5, 0($t3)
addi $t3, $t4,  13136
li $t5, 0xffda00
sw $t5, 0($t3)
addi $t3, $t4,  13140
li $t5, 0x080200
sw $t5, 0($t3)
addi $t3, $t4,  13144
li $t5, 0x000005
sw $t5, 0($t3)
addi $t3, $t4,  13148
li $t5, 0xf4e21b
sw $t5, 0($t3)
addi $t3, $t4,  13152
li $t5, 0xffdb01
sw $t5, 0($t3)
addi $t3, $t4,  13156
li $t5, 0xffda07
sw $t5, 0($t3)
addi $t3, $t4,  13160
li $t5, 0xfddc00
sw $t5, 0($t3)
addi $t3, $t4,  13164
sw $t5, 0($t3)
addi $t3, $t4,  13168
li $t5, 0xffdb03
sw $t5, 0($t3)
addi $t3, $t4,  13172
li $t5, 0x000400
sw $t5, 0($t3)
addi $t3, $t4,  13176
sw $t5, 0($t3)
addi $t3, $t4,  13180
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  13184
sw $t5, 0($t3)
addi $t3, $t4,  13188
sw $t5, 0($t3)
addi $t3, $t4,  13192
sw $t5, 0($t3)
addi $t3, $t4,  13196
sw $t5, 0($t3)
addi $t3, $t4,  13200
sw $t5, 0($t3)
addi $t3, $t4,  13204
sw $t5, 0($t3)
addi $t3, $t4,  13208
sw $t5, 0($t3)
addi $t3, $t4,  13212
sw $t5, 0($t3)
addi $t3, $t4,  13216
sw $t5, 0($t3)
addi $t3, $t4,  13220
sw $t5, 0($t3)
addi $t3, $t4,  13224
sw $t5, 0($t3)
addi $t3, $t4,  13228
sw $t5, 0($t3)
addi $t3, $t4,  13232
sw $t5, 0($t3)
addi $t3, $t4,  13236
sw $t5, 0($t3)
addi $t3, $t4,  13240
sw $t5, 0($t3)
addi $t3, $t4,  13244
sw $t5, 0($t3)
addi $t3, $t4,  13248
sw $t5, 0($t3)
addi $t3, $t4,  13252
sw $t5, 0($t3)
addi $t3, $t4,  13256
sw $t5, 0($t3)
addi $t3, $t4,  13260
sw $t5, 0($t3)
addi $t3, $t4,  13264
sw $t5, 0($t3)
addi $t3, $t4,  13268
sw $t5, 0($t3)
addi $t3, $t4,  13272
sw $t5, 0($t3)
addi $t3, $t4,  13276
sw $t5, 0($t3)
addi $t3, $t4,  13280
sw $t5, 0($t3)
addi $t3, $t4,  13284
sw $t5, 0($t3)
addi $t3, $t4,  13288
sw $t5, 0($t3)
addi $t3, $t4,  13292
sw $t5, 0($t3)
addi $t3, $t4,  13296
sw $t5, 0($t3)
addi $t3, $t4,  13300
sw $t5, 0($t3)
addi $t3, $t4,  13304
sw $t5, 0($t3)
addi $t3, $t4,  13308
sw $t5, 0($t3)
syscall #sleep for 30 ms
addi $t3, $t4,  13312
sw $t5, 0($t3)
addi $t3, $t4,  13316
sw $t5, 0($t3)
addi $t3, $t4,  13320
sw $t5, 0($t3)
addi $t3, $t4,  13324
sw $t5, 0($t3)
addi $t3, $t4,  13328
sw $t5, 0($t3)
addi $t3, $t4,  13332
sw $t5, 0($t3)
addi $t3, $t4,  13336
sw $t5, 0($t3)
addi $t3, $t4,  13340
sw $t5, 0($t3)
addi $t3, $t4,  13344
sw $t5, 0($t3)
addi $t3, $t4,  13348
sw $t5, 0($t3)
addi $t3, $t4,  13352
sw $t5, 0($t3)
addi $t3, $t4,  13356
sw $t5, 0($t3)
addi $t3, $t4,  13360
sw $t5, 0($t3)
addi $t3, $t4,  13364
sw $t5, 0($t3)
addi $t3, $t4,  13368
sw $t5, 0($t3)
addi $t3, $t4,  13372
sw $t5, 0($t3)
addi $t3, $t4,  13376
sw $t5, 0($t3)
addi $t3, $t4,  13380
sw $t5, 0($t3)
addi $t3, $t4,  13384
li $t5, 0x020000
sw $t5, 0($t3)
addi $t3, $t4,  13388
li $t5, 0x000104
sw $t5, 0($t3)
addi $t3, $t4,  13392
li $t5, 0xf3d82d
sw $t5, 0($t3)
addi $t3, $t4,  13396
li $t5, 0xffd901
sw $t5, 0($t3)
addi $t3, $t4,  13400
sw $t5, 0($t3)
addi $t3, $t4,  13404
li $t5, 0xfdde0b
sw $t5, 0($t3)
addi $t3, $t4,  13408
li $t5, 0xffdb00
sw $t5, 0($t3)
addi $t3, $t4,  13412
li $t5, 0xfed809
sw $t5, 0($t3)
addi $t3, $t4,  13416
li $t5, 0x0f0102
sw $t5, 0($t3)
addi $t3, $t4,  13420
li $t5, 0x0a0003
sw $t5, 0($t3)
addi $t3, $t4,  13424
li $t5, 0x0e0100
sw $t5, 0($t3)
addi $t3, $t4,  13428
li $t5, 0x000003
sw $t5, 0($t3)
addi $t3, $t4,  13432
li $t5, 0x020006
sw $t5, 0($t3)
addi $t3, $t4,  13436
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  13440
sw $t5, 0($t3)
addi $t3, $t4,  13444
li $t5, 0x000001
sw $t5, 0($t3)
addi $t3, $t4,  13448
li $t5, 0x140700
sw $t5, 0($t3)
addi $t3, $t4,  13452
li $t5, 0xffd502
sw $t5, 0($t3)
addi $t3, $t4,  13456
li $t5, 0xffd801
sw $t5, 0($t3)
addi $t3, $t4,  13460
sw $t5, 0($t3)
addi $t3, $t4,  13464
li $t5, 0xffd704
sw $t5, 0($t3)
addi $t3, $t4,  13468
li $t5, 0xffd508
sw $t5, 0($t3)
addi $t3, $t4,  13472
li $t5, 0x473612
sw $t5, 0($t3)
addi $t3, $t4,  13476
li $t5, 0x010005
sw $t5, 0($t3)
addi $t3, $t4,  13480
li $t5, 0x080400
sw $t5, 0($t3)
addi $t3, $t4,  13484
li $t5, 0xfed700
sw $t5, 0($t3)
addi $t3, $t4,  13488
li $t5, 0xffd801
sw $t5, 0($t3)
addi $t3, $t4,  13492
sw $t5, 0($t3)
addi $t3, $t4,  13496
li $t5, 0xffd802
sw $t5, 0($t3)
addi $t3, $t4,  13500
li $t5, 0xfdd700
sw $t5, 0($t3)
addi $t3, $t4,  13504
li $t5, 0xffd903
sw $t5, 0($t3)
addi $t3, $t4,  13508
li $t5, 0xffd804
sw $t5, 0($t3)
addi $t3, $t4,  13512
li $t5, 0xffd704
sw $t5, 0($t3)
addi $t3, $t4,  13516
sw $t5, 0($t3)
addi $t3, $t4,  13520
sw $t5, 0($t3)
addi $t3, $t4,  13524
sw $t5, 0($t3)
addi $t3, $t4,  13528
sw $t5, 0($t3)
addi $t3, $t4,  13532
sw $t5, 0($t3)
addi $t3, $t4,  13536
li $t5, 0xf8db13
sw $t5, 0($t3)
addi $t3, $t4,  13540
li $t5, 0xffd700
sw $t5, 0($t3)
addi $t3, $t4,  13544
li $t5, 0xffd500
sw $t5, 0($t3)
addi $t3, $t4,  13548
li $t5, 0xffd701
sw $t5, 0($t3)
addi $t3, $t4,  13552
sw $t5, 0($t3)
addi $t3, $t4,  13556
li $t5, 0xfcd900
sw $t5, 0($t3)
addi $t3, $t4,  13560
li $t5, 0xfbd603
sw $t5, 0($t3)
addi $t3, $t4,  13564
li $t5, 0x020003
sw $t5, 0($t3)
addi $t3, $t4,  13568
sw $t5, 0($t3)
addi $t3, $t4,  13572
li $t5, 0xf9d703
sw $t5, 0($t3)
addi $t3, $t4,  13576
li $t5, 0xffd800
sw $t5, 0($t3)
addi $t3, $t4,  13580
li $t5, 0xffd600
sw $t5, 0($t3)
addi $t3, $t4,  13584
sw $t5, 0($t3)
addi $t3, $t4,  13588
li $t5, 0xffd700
sw $t5, 0($t3)
addi $t3, $t4,  13592
li $t5, 0xfbd908
sw $t5, 0($t3)
addi $t3, $t4,  13596
li $t5, 0x000004
sw $t5, 0($t3)
addi $t3, $t4,  13600
li $t5, 0x010100
sw $t5, 0($t3)
addi $t3, $t4,  13604
li $t5, 0x0a0400
sw $t5, 0($t3)
addi $t3, $t4,  13608
li $t5, 0xf9d702
sw $t5, 0($t3)
addi $t3, $t4,  13612
li $t5, 0xf6d600
sw $t5, 0($t3)
addi $t3, $t4,  13616
li $t5, 0xaf9f17
sw $t5, 0($t3)
addi $t3, $t4,  13620
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  13624
sw $t5, 0($t3)
addi $t3, $t4,  13628
li $t5, 0x98801a
sw $t5, 0($t3)
addi $t3, $t4,  13632
li $t5, 0xffd109
sw $t5, 0($t3)
addi $t3, $t4,  13636
li $t5, 0xffd408
sw $t5, 0($t3)
addi $t3, $t4,  13640
li $t5, 0xffd600
sw $t5, 0($t3)
addi $t3, $t4,  13644
sw $t5, 0($t3)
addi $t3, $t4,  13648
li $t5, 0xffd500
sw $t5, 0($t3)
addi $t3, $t4,  13652
li $t5, 0x090300
sw $t5, 0($t3)
addi $t3, $t4,  13656
li $t5, 0x000005
sw $t5, 0($t3)
addi $t3, $t4,  13660
li $t5, 0xf4de1c
sw $t5, 0($t3)
addi $t3, $t4,  13664
li $t5, 0xffd601
sw $t5, 0($t3)
addi $t3, $t4,  13668
li $t5, 0xffd407
sw $t5, 0($t3)
addi $t3, $t4,  13672
li $t5, 0xffd600
sw $t5, 0($t3)
addi $t3, $t4,  13676
sw $t5, 0($t3)
addi $t3, $t4,  13680
li $t5, 0xfed502
sw $t5, 0($t3)
addi $t3, $t4,  13684
li $t5, 0x000202
sw $t5, 0($t3)
addi $t3, $t4,  13688
li $t5, 0x000201
sw $t5, 0($t3)
addi $t3, $t4,  13692
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  13696
sw $t5, 0($t3)
addi $t3, $t4,  13700
sw $t5, 0($t3)
addi $t3, $t4,  13704
sw $t5, 0($t3)
addi $t3, $t4,  13708
sw $t5, 0($t3)
addi $t3, $t4,  13712
sw $t5, 0($t3)
addi $t3, $t4,  13716
sw $t5, 0($t3)
addi $t3, $t4,  13720
sw $t5, 0($t3)
addi $t3, $t4,  13724
sw $t5, 0($t3)
addi $t3, $t4,  13728
sw $t5, 0($t3)
addi $t3, $t4,  13732
sw $t5, 0($t3)
addi $t3, $t4,  13736
sw $t5, 0($t3)
addi $t3, $t4,  13740
sw $t5, 0($t3)
addi $t3, $t4,  13744
sw $t5, 0($t3)
addi $t3, $t4,  13748
sw $t5, 0($t3)
addi $t3, $t4,  13752
sw $t5, 0($t3)
addi $t3, $t4,  13756
sw $t5, 0($t3)
addi $t3, $t4,  13760
sw $t5, 0($t3)
addi $t3, $t4,  13764
sw $t5, 0($t3)
addi $t3, $t4,  13768
sw $t5, 0($t3)
addi $t3, $t4,  13772
sw $t5, 0($t3)
addi $t3, $t4,  13776
sw $t5, 0($t3)
addi $t3, $t4,  13780
sw $t5, 0($t3)
addi $t3, $t4,  13784
sw $t5, 0($t3)
addi $t3, $t4,  13788
sw $t5, 0($t3)
addi $t3, $t4,  13792
sw $t5, 0($t3)
addi $t3, $t4,  13796
sw $t5, 0($t3)
addi $t3, $t4,  13800
sw $t5, 0($t3)
addi $t3, $t4,  13804
sw $t5, 0($t3)
addi $t3, $t4,  13808
sw $t5, 0($t3)
addi $t3, $t4,  13812
sw $t5, 0($t3)
addi $t3, $t4,  13816
sw $t5, 0($t3)
addi $t3, $t4,  13820
sw $t5, 0($t3)
syscall #sleep for 30 ms
addi $t3, $t4,  13824
sw $t5, 0($t3)
addi $t3, $t4,  13828
sw $t5, 0($t3)
addi $t3, $t4,  13832
sw $t5, 0($t3)
addi $t3, $t4,  13836
sw $t5, 0($t3)
addi $t3, $t4,  13840
sw $t5, 0($t3)
addi $t3, $t4,  13844
sw $t5, 0($t3)
addi $t3, $t4,  13848
sw $t5, 0($t3)
addi $t3, $t4,  13852
sw $t5, 0($t3)
addi $t3, $t4,  13856
sw $t5, 0($t3)
addi $t3, $t4,  13860
sw $t5, 0($t3)
addi $t3, $t4,  13864
sw $t5, 0($t3)
addi $t3, $t4,  13868
sw $t5, 0($t3)
addi $t3, $t4,  13872
sw $t5, 0($t3)
addi $t3, $t4,  13876
sw $t5, 0($t3)
addi $t3, $t4,  13880
sw $t5, 0($t3)
addi $t3, $t4,  13884
sw $t5, 0($t3)
addi $t3, $t4,  13888
sw $t5, 0($t3)
addi $t3, $t4,  13892
sw $t5, 0($t3)
addi $t3, $t4,  13896
sw $t5, 0($t3)
addi $t3, $t4,  13900
sw $t5, 0($t3)
addi $t3, $t4,  13904
sw $t5, 0($t3)
addi $t3, $t4,  13908
sw $t5, 0($t3)
addi $t3, $t4,  13912
sw $t5, 0($t3)
addi $t3, $t4,  13916
li $t5, 0xf4d90f
sw $t5, 0($t3)
addi $t3, $t4,  13920
li $t5, 0xfdd500
sw $t5, 0($t3)
addi $t3, $t4,  13924
li $t5, 0xffd300
sw $t5, 0($t3)
addi $t3, $t4,  13928
li $t5, 0xffd400
sw $t5, 0($t3)
addi $t3, $t4,  13932
li $t5, 0xffd203
sw $t5, 0($t3)
addi $t3, $t4,  13936
li $t5, 0xf1d600
sw $t5, 0($t3)
addi $t3, $t4,  13940
li $t5, 0x000200
sw $t5, 0($t3)
addi $t3, $t4,  13944
li $t5, 0x000006
sw $t5, 0($t3)
addi $t3, $t4,  13948
li $t5, 0x050000
sw $t5, 0($t3)
addi $t3, $t4,  13952
sw $t5, 0($t3)
addi $t3, $t4,  13956
sw $t5, 0($t3)
addi $t3, $t4,  13960
li $t5, 0x150700
sw $t5, 0($t3)
addi $t3, $t4,  13964
li $t5, 0xffd104
sw $t5, 0($t3)
addi $t3, $t4,  13968
li $t5, 0xffd202
sw $t5, 0($t3)
addi $t3, $t4,  13972
sw $t5, 0($t3)
addi $t3, $t4,  13976
li $t5, 0xffcf07
sw $t5, 0($t3)
addi $t3, $t4,  13980
li $t5, 0xffd200
sw $t5, 0($t3)
addi $t3, $t4,  13984
li $t5, 0x46380e
sw $t5, 0($t3)
addi $t3, $t4,  13988
li $t5, 0x010004
sw $t5, 0($t3)
addi $t3, $t4,  13992
li $t5, 0x0a0300
sw $t5, 0($t3)
addi $t3, $t4,  13996
li $t5, 0xffcf01
sw $t5, 0($t3)
addi $t3, $t4,  14000
li $t5, 0xffd101
sw $t5, 0($t3)
addi $t3, $t4,  14004
li $t5, 0xffd202
sw $t5, 0($t3)
addi $t3, $t4,  14008
li $t5, 0xfdd201
sw $t5, 0($t3)
addi $t3, $t4,  14012
li $t5, 0xffd201
sw $t5, 0($t3)
addi $t3, $t4,  14016
li $t5, 0xe6c423
sw $t5, 0($t3)
addi $t3, $t4,  14020
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  14024
sw $t5, 0($t3)
addi $t3, $t4,  14028
sw $t5, 0($t3)
addi $t3, $t4,  14032
sw $t5, 0($t3)
addi $t3, $t4,  14036
sw $t5, 0($t3)
addi $t3, $t4,  14040
sw $t5, 0($t3)
addi $t3, $t4,  14044
sw $t5, 0($t3)
addi $t3, $t4,  14048
li $t5, 0x020000
sw $t5, 0($t3)
addi $t3, $t4,  14052
li $t5, 0xfbcf06
sw $t5, 0($t3)
addi $t3, $t4,  14056
li $t5, 0xfbd303
sw $t5, 0($t3)
addi $t3, $t4,  14060
li $t5, 0xffd003
sw $t5, 0($t3)
addi $t3, $t4,  14064
sw $t5, 0($t3)
addi $t3, $t4,  14068
li $t5, 0xffd100
sw $t5, 0($t3)
addi $t3, $t4,  14072
li $t5, 0xfece07
sw $t5, 0($t3)
addi $t3, $t4,  14076
li $t5, 0x000200
sw $t5, 0($t3)
addi $t3, $t4,  14080
li $t5, 0x000300
sw $t5, 0($t3)
addi $t3, $t4,  14084
li $t5, 0xfdce04
sw $t5, 0($t3)
addi $t3, $t4,  14088
li $t5, 0xffce04
sw $t5, 0($t3)
addi $t3, $t4,  14092
li $t5, 0xffd101
sw $t5, 0($t3)
addi $t3, $t4,  14096
sw $t5, 0($t3)
addi $t3, $t4,  14100
li $t5, 0xfdd200
sw $t5, 0($t3)
addi $t3, $t4,  14104
li $t5, 0xfbd007
sw $t5, 0($t3)
addi $t3, $t4,  14108
li $t5, 0x010000
sw $t5, 0($t3)
addi $t3, $t4,  14112
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  14116
li $t5, 0x000001
sw $t5, 0($t3)
addi $t3, $t4,  14120
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  14124
li $t5, 0x010101
sw $t5, 0($t3)
addi $t3, $t4,  14128
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  14132
sw $t5, 0($t3)
addi $t3, $t4,  14136
sw $t5, 0($t3)
addi $t3, $t4,  14140
li $t5, 0x9a7e1a
sw $t5, 0($t3)
addi $t3, $t4,  14144
li $t5, 0xffcc09
sw $t5, 0($t3)
addi $t3, $t4,  14148
li $t5, 0xffce08
sw $t5, 0($t3)
addi $t3, $t4,  14152
li $t5, 0xffcf02
sw $t5, 0($t3)
addi $t3, $t4,  14156
sw $t5, 0($t3)
addi $t3, $t4,  14160
sw $t5, 0($t3)
addi $t3, $t4,  14164
li $t5, 0x060300
sw $t5, 0($t3)
addi $t3, $t4,  14168
li $t5, 0x000004
sw $t5, 0($t3)
addi $t3, $t4,  14172
li $t5, 0xf7d61a
sw $t5, 0($t3)
addi $t3, $t4,  14176
li $t5, 0xfad105
sw $t5, 0($t3)
addi $t3, $t4,  14180
li $t5, 0xf9d107
sw $t5, 0($t3)
addi $t3, $t4,  14184
li $t5, 0xffcf00
sw $t5, 0($t3)
addi $t3, $t4,  14188
sw $t5, 0($t3)
addi $t3, $t4,  14192
li $t5, 0xfece01
sw $t5, 0($t3)
addi $t3, $t4,  14196
li $t5, 0x000208
sw $t5, 0($t3)
addi $t3, $t4,  14200
li $t5, 0x000105
sw $t5, 0($t3)
addi $t3, $t4,  14204
li $t5, 0x050000
sw $t5, 0($t3)
addi $t3, $t4,  14208
sw $t5, 0($t3)
addi $t3, $t4,  14212
sw $t5, 0($t3)
addi $t3, $t4,  14216
sw $t5, 0($t3)
addi $t3, $t4,  14220
sw $t5, 0($t3)
addi $t3, $t4,  14224
sw $t5, 0($t3)
addi $t3, $t4,  14228
sw $t5, 0($t3)
addi $t3, $t4,  14232
sw $t5, 0($t3)
addi $t3, $t4,  14236
sw $t5, 0($t3)
addi $t3, $t4,  14240
sw $t5, 0($t3)
addi $t3, $t4,  14244
li $t5, 0x000001
sw $t5, 0($t3)
addi $t3, $t4,  14248
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  14252
sw $t5, 0($t3)
addi $t3, $t4,  14256
sw $t5, 0($t3)
addi $t3, $t4,  14260
sw $t5, 0($t3)
addi $t3, $t4,  14264
sw $t5, 0($t3)
addi $t3, $t4,  14268
sw $t5, 0($t3)
addi $t3, $t4,  14272
sw $t5, 0($t3)
addi $t3, $t4,  14276
sw $t5, 0($t3)
addi $t3, $t4,  14280
sw $t5, 0($t3)
addi $t3, $t4,  14284
sw $t5, 0($t3)
addi $t3, $t4,  14288
sw $t5, 0($t3)
addi $t3, $t4,  14292
sw $t5, 0($t3)
addi $t3, $t4,  14296
sw $t5, 0($t3)
addi $t3, $t4,  14300
sw $t5, 0($t3)
addi $t3, $t4,  14304
sw $t5, 0($t3)
addi $t3, $t4,  14308
sw $t5, 0($t3)
addi $t3, $t4,  14312
sw $t5, 0($t3)
addi $t3, $t4,  14316
sw $t5, 0($t3)
addi $t3, $t4,  14320
sw $t5, 0($t3)
addi $t3, $t4,  14324
sw $t5, 0($t3)
addi $t3, $t4,  14328
sw $t5, 0($t3)
addi $t3, $t4,  14332
sw $t5, 0($t3)
syscall #sleep for 30 ms
addi $t3, $t4,  14336
sw $t5, 0($t3)
addi $t3, $t4,  14340
sw $t5, 0($t3)
addi $t3, $t4,  14344
sw $t5, 0($t3)
addi $t3, $t4,  14348
sw $t5, 0($t3)
addi $t3, $t4,  14352
sw $t5, 0($t3)
addi $t3, $t4,  14356
sw $t5, 0($t3)
addi $t3, $t4,  14360
sw $t5, 0($t3)
addi $t3, $t4,  14364
sw $t5, 0($t3)
addi $t3, $t4,  14368
sw $t5, 0($t3)
addi $t3, $t4,  14372
sw $t5, 0($t3)
addi $t3, $t4,  14376
sw $t5, 0($t3)
addi $t3, $t4,  14380
sw $t5, 0($t3)
addi $t3, $t4,  14384
sw $t5, 0($t3)
addi $t3, $t4,  14388
sw $t5, 0($t3)
addi $t3, $t4,  14392
sw $t5, 0($t3)
addi $t3, $t4,  14396
sw $t5, 0($t3)
addi $t3, $t4,  14400
sw $t5, 0($t3)
addi $t3, $t4,  14404
sw $t5, 0($t3)
addi $t3, $t4,  14408
sw $t5, 0($t3)
addi $t3, $t4,  14412
sw $t5, 0($t3)
addi $t3, $t4,  14416
sw $t5, 0($t3)
addi $t3, $t4,  14420
sw $t5, 0($t3)
addi $t3, $t4,  14424
sw $t5, 0($t3)
addi $t3, $t4,  14428
li $t5, 0xf8d10d
sw $t5, 0($t3)
addi $t3, $t4,  14432
li $t5, 0xfecc00
sw $t5, 0($t3)
addi $t3, $t4,  14436
li $t5, 0xffca00
sw $t5, 0($t3)
addi $t3, $t4,  14440
li $t5, 0xfcc900
sw $t5, 0($t3)
addi $t3, $t4,  14444
li $t5, 0xfecb00
sw $t5, 0($t3)
addi $t3, $t4,  14448
li $t5, 0xefce00
sw $t5, 0($t3)
addi $t3, $t4,  14452
li $t5, 0x000106
sw $t5, 0($t3)
addi $t3, $t4,  14456
li $t5, 0x000500
sw $t5, 0($t3)
addi $t3, $t4,  14460
li $t5, 0x060002
sw $t5, 0($t3)
addi $t3, $t4,  14464
sw $t5, 0($t3)
addi $t3, $t4,  14468
li $t5, 0x010300
sw $t5, 0($t3)
addi $t3, $t4,  14472
li $t5, 0x140a00
sw $t5, 0($t3)
addi $t3, $t4,  14476
li $t5, 0xfbcc04
sw $t5, 0($t3)
addi $t3, $t4,  14480
li $t5, 0xffca00
sw $t5, 0($t3)
addi $t3, $t4,  14484
sw $t5, 0($t3)
addi $t3, $t4,  14488
li $t5, 0xffc804
sw $t5, 0($t3)
addi $t3, $t4,  14492
li $t5, 0xfecc00
sw $t5, 0($t3)
addi $t3, $t4,  14496
li $t5, 0x46350e
sw $t5, 0($t3)
addi $t3, $t4,  14500
li $t5, 0x010004
sw $t5, 0($t3)
addi $t3, $t4,  14504
li $t5, 0x0b0300
sw $t5, 0($t3)
addi $t3, $t4,  14508
li $t5, 0xffc900
sw $t5, 0($t3)
addi $t3, $t4,  14512
li $t5, 0xfec900
sw $t5, 0($t3)
addi $t3, $t4,  14516
sw $t5, 0($t3)
addi $t3, $t4,  14520
sw $t5, 0($t3)
addi $t3, $t4,  14524
li $t5, 0xffca00
sw $t5, 0($t3)
addi $t3, $t4,  14528
li $t5, 0xe5bd22
sw $t5, 0($t3)
addi $t3, $t4,  14532
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  14536
sw $t5, 0($t3)
addi $t3, $t4,  14540
sw $t5, 0($t3)
addi $t3, $t4,  14544
sw $t5, 0($t3)
addi $t3, $t4,  14548
sw $t5, 0($t3)
addi $t3, $t4,  14552
sw $t5, 0($t3)
addi $t3, $t4,  14556
sw $t5, 0($t3)
addi $t3, $t4,  14560
li $t5, 0x020201
sw $t5, 0($t3)
addi $t3, $t4,  14564
li $t5, 0xf9c805
sw $t5, 0($t3)
addi $t3, $t4,  14568
li $t5, 0xfbc906
sw $t5, 0($t3)
addi $t3, $t4,  14572
li $t5, 0xfec901
sw $t5, 0($t3)
addi $t3, $t4,  14576
sw $t5, 0($t3)
addi $t3, $t4,  14580
li $t5, 0xffc800
sw $t5, 0($t3)
addi $t3, $t4,  14584
li $t5, 0xfdc704
sw $t5, 0($t3)
addi $t3, $t4,  14588
li $t5, 0x000302
sw $t5, 0($t3)
addi $t3, $t4,  14592
li $t5, 0x000401
sw $t5, 0($t3)
addi $t3, $t4,  14596
li $t5, 0xfdc703
sw $t5, 0($t3)
addi $t3, $t4,  14600
li $t5, 0xffc605
sw $t5, 0($t3)
addi $t3, $t4,  14604
li $t5, 0xfec902
sw $t5, 0($t3)
addi $t3, $t4,  14608
sw $t5, 0($t3)
addi $t3, $t4,  14612
li $t5, 0xffc900
sw $t5, 0($t3)
addi $t3, $t4,  14616
li $t5, 0xf9ca06
sw $t5, 0($t3)
addi $t3, $t4,  14620
li $t5, 0x000100
sw $t5, 0($t3)
addi $t3, $t4,  14624
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  14628
li $t5, 0x363636
sw $t5, 0($t3)
addi $t3, $t4,  14632
li $t5, 0x272727
sw $t5, 0($t3)
addi $t3, $t4,  14636
li $t5, 0x242424
sw $t5, 0($t3)
addi $t3, $t4,  14640
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  14644
sw $t5, 0($t3)
addi $t3, $t4,  14648
sw $t5, 0($t3)
addi $t3, $t4,  14652
li $t5, 0x9a781a
sw $t5, 0($t3)
addi $t3, $t4,  14656
li $t5, 0xffc507
sw $t5, 0($t3)
addi $t3, $t4,  14660
li $t5, 0xffc606
sw $t5, 0($t3)
addi $t3, $t4,  14664
li $t5, 0xffc700
sw $t5, 0($t3)
addi $t3, $t4,  14668
sw $t5, 0($t3)
addi $t3, $t4,  14672
sw $t5, 0($t3)
addi $t3, $t4,  14676
li $t5, 0x0c0300
sw $t5, 0($t3)
addi $t3, $t4,  14680
li $t5, 0x000004
sw $t5, 0($t3)
addi $t3, $t4,  14684
li $t5, 0xf6ce18
sw $t5, 0($t3)
addi $t3, $t4,  14688
li $t5, 0xfac903
sw $t5, 0($t3)
addi $t3, $t4,  14692
li $t5, 0xf9c806
sw $t5, 0($t3)
addi $t3, $t4,  14696
li $t5, 0xffc601
sw $t5, 0($t3)
addi $t3, $t4,  14700
sw $t5, 0($t3)
addi $t3, $t4,  14704
li $t5, 0xfaca00
sw $t5, 0($t3)
addi $t3, $t4,  14708
li $t5, 0x000600
sw $t5, 0($t3)
addi $t3, $t4,  14712
li $t5, 0x000402
sw $t5, 0($t3)
addi $t3, $t4,  14716
li $t5, 0x050000
sw $t5, 0($t3)
addi $t3, $t4,  14720
sw $t5, 0($t3)
addi $t3, $t4,  14724
sw $t5, 0($t3)
addi $t3, $t4,  14728
sw $t5, 0($t3)
addi $t3, $t4,  14732
sw $t5, 0($t3)
addi $t3, $t4,  14736
sw $t5, 0($t3)
addi $t3, $t4,  14740
sw $t5, 0($t3)
addi $t3, $t4,  14744
sw $t5, 0($t3)
addi $t3, $t4,  14748
sw $t5, 0($t3)
addi $t3, $t4,  14752
sw $t5, 0($t3)
addi $t3, $t4,  14756
li $t5, 0x000400
sw $t5, 0($t3)
addi $t3, $t4,  14760
sw $t5, 0($t3)
addi $t3, $t4,  14764
li $t5, 0x000100
sw $t5, 0($t3)
addi $t3, $t4,  14768
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  14772
sw $t5, 0($t3)
addi $t3, $t4,  14776
sw $t5, 0($t3)
addi $t3, $t4,  14780
sw $t5, 0($t3)
addi $t3, $t4,  14784
sw $t5, 0($t3)
addi $t3, $t4,  14788
sw $t5, 0($t3)
addi $t3, $t4,  14792
sw $t5, 0($t3)
addi $t3, $t4,  14796
sw $t5, 0($t3)
addi $t3, $t4,  14800
sw $t5, 0($t3)
addi $t3, $t4,  14804
sw $t5, 0($t3)
addi $t3, $t4,  14808
sw $t5, 0($t3)
addi $t3, $t4,  14812
sw $t5, 0($t3)
addi $t3, $t4,  14816
sw $t5, 0($t3)
addi $t3, $t4,  14820
sw $t5, 0($t3)
addi $t3, $t4,  14824
sw $t5, 0($t3)
addi $t3, $t4,  14828
sw $t5, 0($t3)
addi $t3, $t4,  14832
sw $t5, 0($t3)
addi $t3, $t4,  14836
sw $t5, 0($t3)
addi $t3, $t4,  14840
sw $t5, 0($t3)
addi $t3, $t4,  14844
sw $t5, 0($t3)
syscall #sleep for 30 ms
addi $t3, $t4,  14848
sw $t5, 0($t3)
addi $t3, $t4,  14852
sw $t5, 0($t3)
addi $t3, $t4,  14856
sw $t5, 0($t3)
addi $t3, $t4,  14860
sw $t5, 0($t3)
addi $t3, $t4,  14864
sw $t5, 0($t3)
addi $t3, $t4,  14868
sw $t5, 0($t3)
addi $t3, $t4,  14872
sw $t5, 0($t3)
addi $t3, $t4,  14876
sw $t5, 0($t3)
addi $t3, $t4,  14880
sw $t5, 0($t3)
addi $t3, $t4,  14884
sw $t5, 0($t3)
addi $t3, $t4,  14888
sw $t5, 0($t3)
addi $t3, $t4,  14892
sw $t5, 0($t3)
addi $t3, $t4,  14896
sw $t5, 0($t3)
addi $t3, $t4,  14900
sw $t5, 0($t3)
addi $t3, $t4,  14904
sw $t5, 0($t3)
addi $t3, $t4,  14908
sw $t5, 0($t3)
addi $t3, $t4,  14912
sw $t5, 0($t3)
addi $t3, $t4,  14916
sw $t5, 0($t3)
addi $t3, $t4,  14920
sw $t5, 0($t3)
addi $t3, $t4,  14924
sw $t5, 0($t3)
addi $t3, $t4,  14928
sw $t5, 0($t3)
addi $t3, $t4,  14932
sw $t5, 0($t3)
addi $t3, $t4,  14936
sw $t5, 0($t3)
addi $t3, $t4,  14940
li $t5, 0xc2a426
sw $t5, 0($t3)
addi $t3, $t4,  14944
li $t5, 0xc7a018
sw $t5, 0($t3)
addi $t3, $t4,  14948
li $t5, 0xca9e19
sw $t5, 0($t3)
addi $t3, $t4,  14952
li $t5, 0xfdc304
sw $t5, 0($t3)
addi $t3, $t4,  14956
li $t5, 0xfec400
sw $t5, 0($t3)
addi $t3, $t4,  14960
li $t5, 0xf8c200
sw $t5, 0($t3)
addi $t3, $t4,  14964
li $t5, 0xdec53e
sw $t5, 0($t3)
addi $t3, $t4,  14968
li $t5, 0xe4c243
sw $t5, 0($t3)
addi $t3, $t4,  14972
li $t5, 0xe6c140
sw $t5, 0($t3)
addi $t3, $t4,  14976
sw $t5, 0($t3)
addi $t3, $t4,  14980
li $t5, 0xe7c433
sw $t5, 0($t3)
addi $t3, $t4,  14984
li $t5, 0xe8c03a
sw $t5, 0($t3)
addi $t3, $t4,  14988
li $t5, 0xffc402
sw $t5, 0($t3)
addi $t3, $t4,  14992
li $t5, 0xffc300
sw $t5, 0($t3)
addi $t3, $t4,  14996
sw $t5, 0($t3)
addi $t3, $t4,  15000
li $t5, 0xffc104
sw $t5, 0($t3)
addi $t3, $t4,  15004
li $t5, 0xfec400
sw $t5, 0($t3)
addi $t3, $t4,  15008
li $t5, 0x47320e
sw $t5, 0($t3)
addi $t3, $t4,  15012
li $t5, 0x010004
sw $t5, 0($t3)
addi $t3, $t4,  15016
li $t5, 0x0b0300
sw $t5, 0($t3)
addi $t3, $t4,  15020
li $t5, 0xffc300
sw $t5, 0($t3)
addi $t3, $t4,  15024
li $t5, 0xffc200
sw $t5, 0($t3)
addi $t3, $t4,  15028
sw $t5, 0($t3)
addi $t3, $t4,  15032
li $t5, 0xfdc300
sw $t5, 0($t3)
addi $t3, $t4,  15036
li $t5, 0xffc300
sw $t5, 0($t3)
addi $t3, $t4,  15040
li $t5, 0xe5b720
sw $t5, 0($t3)
addi $t3, $t4,  15044
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  15048
sw $t5, 0($t3)
addi $t3, $t4,  15052
sw $t5, 0($t3)
addi $t3, $t4,  15056
sw $t5, 0($t3)
addi $t3, $t4,  15060
sw $t5, 0($t3)
addi $t3, $t4,  15064
sw $t5, 0($t3)
addi $t3, $t4,  15068
sw $t5, 0($t3)
addi $t3, $t4,  15072
li $t5, 0x010300
sw $t5, 0($t3)
addi $t3, $t4,  15076
li $t5, 0xf8c204
sw $t5, 0($t3)
addi $t3, $t4,  15080
li $t5, 0xfcc207
sw $t5, 0($t3)
addi $t3, $t4,  15084
li $t5, 0xffc200
sw $t5, 0($t3)
addi $t3, $t4,  15088
sw $t5, 0($t3)
addi $t3, $t4,  15092
li $t5, 0xffc100
sw $t5, 0($t3)
addi $t3, $t4,  15096
li $t5, 0xfdc004
sw $t5, 0($t3)
addi $t3, $t4,  15100
li $t5, 0x000302
sw $t5, 0($t3)
addi $t3, $t4,  15104
li $t5, 0x000401
sw $t5, 0($t3)
addi $t3, $t4,  15108
li $t5, 0xfdc002
sw $t5, 0($t3)
addi $t3, $t4,  15112
li $t5, 0xffbf05
sw $t5, 0($t3)
addi $t3, $t4,  15116
li $t5, 0xffc103
sw $t5, 0($t3)
addi $t3, $t4,  15120
li $t5, 0xffc102
sw $t5, 0($t3)
addi $t3, $t4,  15124
li $t5, 0xffc200
sw $t5, 0($t3)
addi $t3, $t4,  15128
li $t5, 0xf8c304
sw $t5, 0($t3)
addi $t3, $t4,  15132
li $t5, 0x000102
sw $t5, 0($t3)
addi $t3, $t4,  15136
li $t5, 0x383838
sw $t5, 0($t3)
addi $t3, $t4,  15140
li $t5, 0x353535
sw $t5, 0($t3)
addi $t3, $t4,  15144
li $t5, 0x060606
sw $t5, 0($t3)
addi $t3, $t4,  15148
li $t5, 0x0c0c0c
sw $t5, 0($t3)
addi $t3, $t4,  15152
li $t5, 0x020202
sw $t5, 0($t3)
addi $t3, $t4,  15156
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  15160
sw $t5, 0($t3)
addi $t3, $t4,  15164
li $t5, 0x9a7119
sw $t5, 0($t3)
addi $t3, $t4,  15168
li $t5, 0xffbe06
sw $t5, 0($t3)
addi $t3, $t4,  15172
li $t5, 0xffbf04
sw $t5, 0($t3)
addi $t3, $t4,  15176
li $t5, 0xffc000
sw $t5, 0($t3)
addi $t3, $t4,  15180
sw $t5, 0($t3)
addi $t3, $t4,  15184
li $t5, 0xffbe00
sw $t5, 0($t3)
addi $t3, $t4,  15188
li $t5, 0x0e0300
sw $t5, 0($t3)
addi $t3, $t4,  15192
li $t5, 0x000003
sw $t5, 0($t3)
addi $t3, $t4,  15196
li $t5, 0xf6c618
sw $t5, 0($t3)
addi $t3, $t4,  15200
li $t5, 0xf9c200
sw $t5, 0($t3)
addi $t3, $t4,  15204
li $t5, 0xfbc105
sw $t5, 0($t3)
addi $t3, $t4,  15208
li $t5, 0xffbf02
sw $t5, 0($t3)
addi $t3, $t4,  15212
sw $t5, 0($t3)
addi $t3, $t4,  15216
li $t5, 0xfdba00
sw $t5, 0($t3)
addi $t3, $t4,  15220
li $t5, 0xceb752
sw $t5, 0($t3)
addi $t3, $t4,  15224
li $t5, 0xd6b73f
sw $t5, 0($t3)
addi $t3, $t4,  15228
li $t5, 0xdcb246
sw $t5, 0($t3)
addi $t3, $t4,  15232
li $t5, 0xdab044
sw $t5, 0($t3)
addi $t3, $t4,  15236
sw $t5, 0($t3)
addi $t3, $t4,  15240
sw $t5, 0($t3)
addi $t3, $t4,  15244
sw $t5, 0($t3)
addi $t3, $t4,  15248
sw $t5, 0($t3)
addi $t3, $t4,  15252
sw $t5, 0($t3)
addi $t3, $t4,  15256
sw $t5, 0($t3)
addi $t3, $t4,  15260
sw $t5, 0($t3)
addi $t3, $t4,  15264
sw $t5, 0($t3)
addi $t3, $t4,  15268
li $t5, 0xd3b347
sw $t5, 0($t3)
addi $t3, $t4,  15272
li $t5, 0xd0ac49
sw $t5, 0($t3)
addi $t3, $t4,  15276
li $t5, 0x281600
sw $t5, 0($t3)
addi $t3, $t4,  15280
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  15284
sw $t5, 0($t3)
addi $t3, $t4,  15288
sw $t5, 0($t3)
addi $t3, $t4,  15292
sw $t5, 0($t3)
addi $t3, $t4,  15296
sw $t5, 0($t3)
addi $t3, $t4,  15300
sw $t5, 0($t3)
addi $t3, $t4,  15304
sw $t5, 0($t3)
addi $t3, $t4,  15308
sw $t5, 0($t3)
addi $t3, $t4,  15312
sw $t5, 0($t3)
addi $t3, $t4,  15316
sw $t5, 0($t3)
addi $t3, $t4,  15320
sw $t5, 0($t3)
addi $t3, $t4,  15324
sw $t5, 0($t3)
addi $t3, $t4,  15328
sw $t5, 0($t3)
addi $t3, $t4,  15332
sw $t5, 0($t3)
addi $t3, $t4,  15336
sw $t5, 0($t3)
addi $t3, $t4,  15340
sw $t5, 0($t3)
addi $t3, $t4,  15344
sw $t5, 0($t3)
addi $t3, $t4,  15348
sw $t5, 0($t3)
addi $t3, $t4,  15352
sw $t5, 0($t3)
addi $t3, $t4,  15356
sw $t5, 0($t3)
syscall #sleep for 30 ms
addi $t3, $t4,  15360
sw $t5, 0($t3)
addi $t3, $t4,  15364
sw $t5, 0($t3)
addi $t3, $t4,  15368
sw $t5, 0($t3)
addi $t3, $t4,  15372
sw $t5, 0($t3)
addi $t3, $t4,  15376
sw $t5, 0($t3)
addi $t3, $t4,  15380
sw $t5, 0($t3)
addi $t3, $t4,  15384
sw $t5, 0($t3)
addi $t3, $t4,  15388
sw $t5, 0($t3)
addi $t3, $t4,  15392
sw $t5, 0($t3)
addi $t3, $t4,  15396
sw $t5, 0($t3)
addi $t3, $t4,  15400
sw $t5, 0($t3)
addi $t3, $t4,  15404
sw $t5, 0($t3)
addi $t3, $t4,  15408
sw $t5, 0($t3)
addi $t3, $t4,  15412
sw $t5, 0($t3)
addi $t3, $t4,  15416
sw $t5, 0($t3)
addi $t3, $t4,  15420
sw $t5, 0($t3)
addi $t3, $t4,  15424
sw $t5, 0($t3)
addi $t3, $t4,  15428
sw $t5, 0($t3)
addi $t3, $t4,  15432
sw $t5, 0($t3)
addi $t3, $t4,  15436
sw $t5, 0($t3)
addi $t3, $t4,  15440
sw $t5, 0($t3)
addi $t3, $t4,  15444
sw $t5, 0($t3)
addi $t3, $t4,  15448
sw $t5, 0($t3)
addi $t3, $t4,  15452
sw $t5, 0($t3)
addi $t3, $t4,  15456
sw $t5, 0($t3)
addi $t3, $t4,  15460
li $t5, 0x010000
sw $t5, 0($t3)
addi $t3, $t4,  15464
li $t5, 0xfabd05
sw $t5, 0($t3)
addi $t3, $t4,  15468
li $t5, 0xfbbe00
sw $t5, 0($t3)
addi $t3, $t4,  15472
li $t5, 0xfebb00
sw $t5, 0($t3)
addi $t3, $t4,  15476
li $t5, 0xfdba00
sw $t5, 0($t3)
addi $t3, $t4,  15480
sw $t5, 0($t3)
addi $t3, $t4,  15484
li $t5, 0xfdba01
sw $t5, 0($t3)
addi $t3, $t4,  15488
sw $t5, 0($t3)
addi $t3, $t4,  15492
sw $t5, 0($t3)
addi $t3, $t4,  15496
sw $t5, 0($t3)
addi $t3, $t4,  15500
li $t5, 0xfebb02
sw $t5, 0($t3)
addi $t3, $t4,  15504
li $t5, 0xffba00
sw $t5, 0($t3)
addi $t3, $t4,  15508
sw $t5, 0($t3)
addi $t3, $t4,  15512
li $t5, 0xffb801
sw $t5, 0($t3)
addi $t3, $t4,  15516
li $t5, 0xffba00
sw $t5, 0($t3)
addi $t3, $t4,  15520
li $t5, 0x4b300d
sw $t5, 0($t3)
addi $t3, $t4,  15524
li $t5, 0x010004
sw $t5, 0($t3)
addi $t3, $t4,  15528
li $t5, 0x1e140f
sw $t5, 0($t3)
addi $t3, $t4,  15532
li $t5, 0xfab50b
sw $t5, 0($t3)
addi $t3, $t4,  15536
li $t5, 0xfdb900
sw $t5, 0($t3)
addi $t3, $t4,  15540
li $t5, 0xfeba00
sw $t5, 0($t3)
addi $t3, $t4,  15544
li $t5, 0xfdbb00
sw $t5, 0($t3)
addi $t3, $t4,  15548
li $t5, 0xffba00
sw $t5, 0($t3)
addi $t3, $t4,  15552
li $t5, 0xe4b021
sw $t5, 0($t3)
addi $t3, $t4,  15556
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  15560
sw $t5, 0($t3)
addi $t3, $t4,  15564
sw $t5, 0($t3)
addi $t3, $t4,  15568
sw $t5, 0($t3)
addi $t3, $t4,  15572
sw $t5, 0($t3)
addi $t3, $t4,  15576
sw $t5, 0($t3)
addi $t3, $t4,  15580
sw $t5, 0($t3)
addi $t3, $t4,  15584
li $t5, 0x010101
sw $t5, 0($t3)
addi $t3, $t4,  15588
li $t5, 0xfcbd04
sw $t5, 0($t3)
addi $t3, $t4,  15592
li $t5, 0xfcba05
sw $t5, 0($t3)
addi $t3, $t4,  15596
li $t5, 0xffb900
sw $t5, 0($t3)
addi $t3, $t4,  15600
sw $t5, 0($t3)
addi $t3, $t4,  15604
li $t5, 0xffba05
sw $t5, 0($t3)
addi $t3, $t4,  15608
li $t5, 0xfeb407
sw $t5, 0($t3)
addi $t3, $t4,  15612
li $t5, 0x000500
sw $t5, 0($t3)
addi $t3, $t4,  15616
sw $t5, 0($t3)
addi $t3, $t4,  15620
li $t5, 0xfeb501
sw $t5, 0($t3)
addi $t3, $t4,  15624
li $t5, 0xfdb706
sw $t5, 0($t3)
addi $t3, $t4,  15628
li $t5, 0xfeb800
sw $t5, 0($t3)
addi $t3, $t4,  15632
li $t5, 0xfeb802
sw $t5, 0($t3)
addi $t3, $t4,  15636
li $t5, 0xfaba02
sw $t5, 0($t3)
addi $t3, $t4,  15640
li $t5, 0xf8ba03
sw $t5, 0($t3)
addi $t3, $t4,  15644
li $t5, 0x000201
sw $t5, 0($t3)
addi $t3, $t4,  15648
li $t5, 0x303030
sw $t5, 0($t3)
addi $t3, $t4,  15652
li $t5, 0x151515
sw $t5, 0($t3)
addi $t3, $t4,  15656
li $t5, 0x1b1b1b
sw $t5, 0($t3)
addi $t3, $t4,  15660
li $t5, 0x191919
sw $t5, 0($t3)
addi $t3, $t4,  15664
li $t5, 0x040404
sw $t5, 0($t3)
addi $t3, $t4,  15668
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  15672
sw $t5, 0($t3)
addi $t3, $t4,  15676
li $t5, 0x9a6d19
sw $t5, 0($t3)
addi $t3, $t4,  15680
li $t5, 0xffb708
sw $t5, 0($t3)
addi $t3, $t4,  15684
li $t5, 0xfdb804
sw $t5, 0($t3)
addi $t3, $t4,  15688
li $t5, 0xffb800
sw $t5, 0($t3)
addi $t3, $t4,  15692
sw $t5, 0($t3)
addi $t3, $t4,  15696
li $t5, 0xffb500
sw $t5, 0($t3)
addi $t3, $t4,  15700
li $t5, 0x0a0000
sw $t5, 0($t3)
addi $t3, $t4,  15704
li $t5, 0x000003
sw $t5, 0($t3)
addi $t3, $t4,  15708
li $t5, 0xf3be1d
sw $t5, 0($t3)
addi $t3, $t4,  15712
li $t5, 0xf9bb00
sw $t5, 0($t3)
addi $t3, $t4,  15716
li $t5, 0xfcb701
sw $t5, 0($t3)
addi $t3, $t4,  15720
li $t5, 0xfeb600
sw $t5, 0($t3)
addi $t3, $t4,  15724
sw $t5, 0($t3)
addi $t3, $t4,  15728
sw $t5, 0($t3)
addi $t3, $t4,  15732
sw $t5, 0($t3)
addi $t3, $t4,  15736
sw $t5, 0($t3)
addi $t3, $t4,  15740
sw $t5, 0($t3)
addi $t3, $t4,  15744
sw $t5, 0($t3)
addi $t3, $t4,  15748
sw $t5, 0($t3)
addi $t3, $t4,  15752
sw $t5, 0($t3)
addi $t3, $t4,  15756
sw $t5, 0($t3)
addi $t3, $t4,  15760
sw $t5, 0($t3)
addi $t3, $t4,  15764
li $t5, 0xfdb500
sw $t5, 0($t3)
addi $t3, $t4,  15768
li $t5, 0xfeb600
sw $t5, 0($t3)
addi $t3, $t4,  15772
sw $t5, 0($t3)
addi $t3, $t4,  15776
sw $t5, 0($t3)
addi $t3, $t4,  15780
li $t5, 0xfdb700
sw $t5, 0($t3)
addi $t3, $t4,  15784
li $t5, 0xffb503
sw $t5, 0($t3)
addi $t3, $t4,  15788
li $t5, 0x2a0e00
sw $t5, 0($t3)
addi $t3, $t4,  15792
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  15796
sw $t5, 0($t3)
addi $t3, $t4,  15800
sw $t5, 0($t3)
addi $t3, $t4,  15804
sw $t5, 0($t3)
addi $t3, $t4,  15808
sw $t5, 0($t3)
addi $t3, $t4,  15812
sw $t5, 0($t3)
addi $t3, $t4,  15816
sw $t5, 0($t3)
addi $t3, $t4,  15820
sw $t5, 0($t3)
addi $t3, $t4,  15824
sw $t5, 0($t3)
addi $t3, $t4,  15828
sw $t5, 0($t3)
addi $t3, $t4,  15832
sw $t5, 0($t3)
addi $t3, $t4,  15836
sw $t5, 0($t3)
addi $t3, $t4,  15840
sw $t5, 0($t3)
addi $t3, $t4,  15844
sw $t5, 0($t3)
addi $t3, $t4,  15848
sw $t5, 0($t3)
addi $t3, $t4,  15852
sw $t5, 0($t3)
addi $t3, $t4,  15856
sw $t5, 0($t3)
addi $t3, $t4,  15860
sw $t5, 0($t3)
addi $t3, $t4,  15864
sw $t5, 0($t3)
addi $t3, $t4,  15868
sw $t5, 0($t3)
syscall #sleep for 30 ms
addi $t3, $t4,  15872
sw $t5, 0($t3)
addi $t3, $t4,  15876
sw $t5, 0($t3)
addi $t3, $t4,  15880
sw $t5, 0($t3)
addi $t3, $t4,  15884
sw $t5, 0($t3)
addi $t3, $t4,  15888
sw $t5, 0($t3)
addi $t3, $t4,  15892
sw $t5, 0($t3)
addi $t3, $t4,  15896
sw $t5, 0($t3)
addi $t3, $t4,  15900
sw $t5, 0($t3)
addi $t3, $t4,  15904
sw $t5, 0($t3)
addi $t3, $t4,  15908
sw $t5, 0($t3)
addi $t3, $t4,  15912
sw $t5, 0($t3)
addi $t3, $t4,  15916
sw $t5, 0($t3)
addi $t3, $t4,  15920
sw $t5, 0($t3)
addi $t3, $t4,  15924
sw $t5, 0($t3)
addi $t3, $t4,  15928
sw $t5, 0($t3)
addi $t3, $t4,  15932
sw $t5, 0($t3)
addi $t3, $t4,  15936
sw $t5, 0($t3)
addi $t3, $t4,  15940
sw $t5, 0($t3)
addi $t3, $t4,  15944
sw $t5, 0($t3)
addi $t3, $t4,  15948
sw $t5, 0($t3)
addi $t3, $t4,  15952
sw $t5, 0($t3)
addi $t3, $t4,  15956
sw $t5, 0($t3)
addi $t3, $t4,  15960
sw $t5, 0($t3)
addi $t3, $t4,  15964
sw $t5, 0($t3)
addi $t3, $t4,  15968
sw $t5, 0($t3)
addi $t3, $t4,  15972
li $t5, 0x030000
sw $t5, 0($t3)
addi $t3, $t4,  15976
li $t5, 0xfab303
sw $t5, 0($t3)
addi $t3, $t4,  15980
li $t5, 0xf8b200
sw $t5, 0($t3)
addi $t3, $t4,  15984
li $t5, 0xfbb000
sw $t5, 0($t3)
addi $t3, $t4,  15988
sw $t5, 0($t3)
addi $t3, $t4,  15992
sw $t5, 0($t3)
addi $t3, $t4,  15996
sw $t5, 0($t3)
addi $t3, $t4,  16000
li $t5, 0xfdb200
sw $t5, 0($t3)
addi $t3, $t4,  16004
li $t5, 0xfcb100
sw $t5, 0($t3)
addi $t3, $t4,  16008
sw $t5, 0($t3)
addi $t3, $t4,  16012
sw $t5, 0($t3)
addi $t3, $t4,  16016
li $t5, 0xfeb000
sw $t5, 0($t3)
addi $t3, $t4,  16020
sw $t5, 0($t3)
addi $t3, $t4,  16024
li $t5, 0xfeb100
sw $t5, 0($t3)
addi $t3, $t4,  16028
li $t5, 0xfeb300
sw $t5, 0($t3)
addi $t3, $t4,  16032
li $t5, 0x4a2d0d
sw $t5, 0($t3)
addi $t3, $t4,  16036
li $t5, 0x010005
sw $t5, 0($t3)
addi $t3, $t4,  16040
li $t5, 0x3c3226
sw $t5, 0($t3)
addi $t3, $t4,  16044
li $t5, 0xfab616
sw $t5, 0($t3)
addi $t3, $t4,  16048
li $t5, 0xfab101
sw $t5, 0($t3)
addi $t3, $t4,  16052
li $t5, 0xfab200
sw $t5, 0($t3)
addi $t3, $t4,  16056
li $t5, 0xfcaf00
sw $t5, 0($t3)
addi $t3, $t4,  16060
li $t5, 0xfdae00
sw $t5, 0($t3)
addi $t3, $t4,  16064
li $t5, 0xe3a721
sw $t5, 0($t3)
addi $t3, $t4,  16068
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  16072
sw $t5, 0($t3)
addi $t3, $t4,  16076
sw $t5, 0($t3)
addi $t3, $t4,  16080
sw $t5, 0($t3)
addi $t3, $t4,  16084
sw $t5, 0($t3)
addi $t3, $t4,  16088
sw $t5, 0($t3)
addi $t3, $t4,  16092
sw $t5, 0($t3)
addi $t3, $t4,  16096
li $t5, 0x000200
sw $t5, 0($t3)
addi $t3, $t4,  16100
li $t5, 0xf9b603
sw $t5, 0($t3)
addi $t3, $t4,  16104
li $t5, 0xfdaf07
sw $t5, 0($t3)
addi $t3, $t4,  16108
li $t5, 0xfeb000
sw $t5, 0($t3)
addi $t3, $t4,  16112
sw $t5, 0($t3)
addi $t3, $t4,  16116
li $t5, 0xfeae07
sw $t5, 0($t3)
addi $t3, $t4,  16120
li $t5, 0xfead08
sw $t5, 0($t3)
addi $t3, $t4,  16124
li $t5, 0x000600
sw $t5, 0($t3)
addi $t3, $t4,  16128
li $t5, 0x000500
sw $t5, 0($t3)
addi $t3, $t4,  16132
li $t5, 0xfeac01
sw $t5, 0($t3)
addi $t3, $t4,  16136
li $t5, 0xfdad08
sw $t5, 0($t3)
addi $t3, $t4,  16140
li $t5, 0xfcb200
sw $t5, 0($t3)
addi $t3, $t4,  16144
li $t5, 0xf9ac05
sw $t5, 0($t3)
addi $t3, $t4,  16148
li $t5, 0xeca809
sw $t5, 0($t3)
addi $t3, $t4,  16152
li $t5, 0xf2b306
sw $t5, 0($t3)
addi $t3, $t4,  16156
li $t5, 0x000302
sw $t5, 0($t3)
addi $t3, $t4,  16160
li $t5, 0x010101
sw $t5, 0($t3)
addi $t3, $t4,  16164
li $t5, 0x0a0a0a
sw $t5, 0($t3)
addi $t3, $t4,  16168
li $t5, 0x080808
sw $t5, 0($t3)
addi $t3, $t4,  16172
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  16176
sw $t5, 0($t3)
addi $t3, $t4,  16180
sw $t5, 0($t3)
addi $t3, $t4,  16184
sw $t5, 0($t3)
addi $t3, $t4,  16188
li $t5, 0x9c6719
sw $t5, 0($t3)
addi $t3, $t4,  16192
li $t5, 0xffad09
sw $t5, 0($t3)
addi $t3, $t4,  16196
li $t5, 0xfcac04
sw $t5, 0($t3)
addi $t3, $t4,  16200
li $t5, 0xfdad00
sw $t5, 0($t3)
addi $t3, $t4,  16204
sw $t5, 0($t3)
addi $t3, $t4,  16208
li $t5, 0xfead00
sw $t5, 0($t3)
addi $t3, $t4,  16212
li $t5, 0x0c0000
sw $t5, 0($t3)
addi $t3, $t4,  16216
li $t5, 0x010003
sw $t5, 0($t3)
addi $t3, $t4,  16220
li $t5, 0xf1b318
sw $t5, 0($t3)
addi $t3, $t4,  16224
li $t5, 0xf8b100
sw $t5, 0($t3)
addi $t3, $t4,  16228
li $t5, 0xfbae00
sw $t5, 0($t3)
addi $t3, $t4,  16232
li $t5, 0xfdad00
sw $t5, 0($t3)
addi $t3, $t4,  16236
li $t5, 0xfcac00
sw $t5, 0($t3)
addi $t3, $t4,  16240
sw $t5, 0($t3)
addi $t3, $t4,  16244
sw $t5, 0($t3)
addi $t3, $t4,  16248
sw $t5, 0($t3)
addi $t3, $t4,  16252
sw $t5, 0($t3)
addi $t3, $t4,  16256
sw $t5, 0($t3)
addi $t3, $t4,  16260
sw $t5, 0($t3)
addi $t3, $t4,  16264
sw $t5, 0($t3)
addi $t3, $t4,  16268
li $t5, 0xfbab00
sw $t5, 0($t3)
addi $t3, $t4,  16272
sw $t5, 0($t3)
addi $t3, $t4,  16276
sw $t5, 0($t3)
addi $t3, $t4,  16280
sw $t5, 0($t3)
addi $t3, $t4,  16284
sw $t5, 0($t3)
addi $t3, $t4,  16288
sw $t5, 0($t3)
addi $t3, $t4,  16292
li $t5, 0xfaac00
sw $t5, 0($t3)
addi $t3, $t4,  16296
li $t5, 0xffaa02
sw $t5, 0($t3)
addi $t3, $t4,  16300
li $t5, 0x2a0900
sw $t5, 0($t3)
addi $t3, $t4,  16304
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  16308
sw $t5, 0($t3)
addi $t3, $t4,  16312
sw $t5, 0($t3)
addi $t3, $t4,  16316
sw $t5, 0($t3)
addi $t3, $t4,  16320
sw $t5, 0($t3)
addi $t3, $t4,  16324
sw $t5, 0($t3)
addi $t3, $t4,  16328
sw $t5, 0($t3)
addi $t3, $t4,  16332
sw $t5, 0($t3)
addi $t3, $t4,  16336
sw $t5, 0($t3)
addi $t3, $t4,  16340
sw $t5, 0($t3)
addi $t3, $t4,  16344
sw $t5, 0($t3)
addi $t3, $t4,  16348
sw $t5, 0($t3)
addi $t3, $t4,  16352
sw $t5, 0($t3)
addi $t3, $t4,  16356
sw $t5, 0($t3)
addi $t3, $t4,  16360
sw $t5, 0($t3)
addi $t3, $t4,  16364
sw $t5, 0($t3)
addi $t3, $t4,  16368
sw $t5, 0($t3)
addi $t3, $t4,  16372
sw $t5, 0($t3)
addi $t3, $t4,  16376
sw $t5, 0($t3)
addi $t3, $t4,  16380
sw $t5, 0($t3)
syscall #sleep for 30 ms
addi $t3, $t4,  16384
sw $t5, 0($t3)
addi $t3, $t4,  16388
sw $t5, 0($t3)
addi $t3, $t4,  16392
sw $t5, 0($t3)
addi $t3, $t4,  16396
sw $t5, 0($t3)
addi $t3, $t4,  16400
sw $t5, 0($t3)
addi $t3, $t4,  16404
sw $t5, 0($t3)
addi $t3, $t4,  16408
sw $t5, 0($t3)
addi $t3, $t4,  16412
sw $t5, 0($t3)
addi $t3, $t4,  16416
sw $t5, 0($t3)
addi $t3, $t4,  16420
sw $t5, 0($t3)
addi $t3, $t4,  16424
sw $t5, 0($t3)
addi $t3, $t4,  16428
sw $t5, 0($t3)
addi $t3, $t4,  16432
sw $t5, 0($t3)
addi $t3, $t4,  16436
sw $t5, 0($t3)
addi $t3, $t4,  16440
sw $t5, 0($t3)
addi $t3, $t4,  16444
sw $t5, 0($t3)
addi $t3, $t4,  16448
sw $t5, 0($t3)
addi $t3, $t4,  16452
sw $t5, 0($t3)
addi $t3, $t4,  16456
sw $t5, 0($t3)
addi $t3, $t4,  16460
sw $t5, 0($t3)
addi $t3, $t4,  16464
sw $t5, 0($t3)
addi $t3, $t4,  16468
sw $t5, 0($t3)
addi $t3, $t4,  16472
sw $t5, 0($t3)
addi $t3, $t4,  16476
li $t5, 0x000200
sw $t5, 0($t3)
addi $t3, $t4,  16480
sw $t5, 0($t3)
addi $t3, $t4,  16484
li $t5, 0x000201
sw $t5, 0($t3)
addi $t3, $t4,  16488
li $t5, 0x000300
sw $t5, 0($t3)
addi $t3, $t4,  16492
li $t5, 0x010100
sw $t5, 0($t3)
addi $t3, $t4,  16496
li $t5, 0x000102
sw $t5, 0($t3)
addi $t3, $t4,  16500
sw $t5, 0($t3)
addi $t3, $t4,  16504
sw $t5, 0($t3)
addi $t3, $t4,  16508
sw $t5, 0($t3)
addi $t3, $t4,  16512
sw $t5, 0($t3)
addi $t3, $t4,  16516
sw $t5, 0($t3)
addi $t3, $t4,  16520
sw $t5, 0($t3)
addi $t3, $t4,  16524
sw $t5, 0($t3)
addi $t3, $t4,  16528
li $t5, 0x000200
sw $t5, 0($t3)
addi $t3, $t4,  16532
li $t5, 0x020004
sw $t5, 0($t3)
addi $t3, $t4,  16536
li $t5, 0x050000
sw $t5, 0($t3)
addi $t3, $t4,  16540
li $t5, 0x010200
sw $t5, 0($t3)
addi $t3, $t4,  16544
li $t5, 0x111616
sw $t5, 0($t3)
addi $t3, $t4,  16548
li $t5, 0x000100
sw $t5, 0($t3)
addi $t3, $t4,  16552
li $t5, 0x33353b
sw $t5, 0($t3)
addi $t3, $t4,  16556
li $t5, 0x272825
sw $t5, 0($t3)
addi $t3, $t4,  16560
li $t5, 0x000200
sw $t5, 0($t3)
addi $t3, $t4,  16564
li $t5, 0x07080a
sw $t5, 0($t3)
addi $t3, $t4,  16568
li $t5, 0x060709
sw $t5, 0($t3)
addi $t3, $t4,  16572
li $t5, 0x010303
sw $t5, 0($t3)
addi $t3, $t4,  16576
li $t5, 0x313332
sw $t5, 0($t3)
addi $t3, $t4,  16580
li $t5, 0x050505
sw $t5, 0($t3)
addi $t3, $t4,  16584
li $t5, 0x030303
sw $t5, 0($t3)
addi $t3, $t4,  16588
li $t5, 0x010101
sw $t5, 0($t3)
addi $t3, $t4,  16592
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  16596
li $t5, 0x1d1d1d
sw $t5, 0($t3)
addi $t3, $t4,  16600
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  16604
li $t5, 0x0b0b0b
sw $t5, 0($t3)
addi $t3, $t4,  16608
li $t5, 0x010201
sw $t5, 0($t3)
addi $t3, $t4,  16612
li $t5, 0x000200
sw $t5, 0($t3)
addi $t3, $t4,  16616
li $t5, 0x2f2e35
sw $t5, 0($t3)
addi $t3, $t4,  16620
li $t5, 0x000105
sw $t5, 0($t3)
addi $t3, $t4,  16624
li $t5, 0x28292c
sw $t5, 0($t3)
addi $t3, $t4,  16628
li $t5, 0x00010d
sw $t5, 0($t3)
addi $t3, $t4,  16632
li $t5, 0x090b08
sw $t5, 0($t3)
addi $t3, $t4,  16636
li $t5, 0x050204
sw $t5, 0($t3)
addi $t3, $t4,  16640
li $t5, 0x040404
sw $t5, 0($t3)
addi $t3, $t4,  16644
li $t5, 0x020100
sw $t5, 0($t3)
addi $t3, $t4,  16648
li $t5, 0x101219
sw $t5, 0($t3)
addi $t3, $t4,  16652
li $t5, 0x030507
sw $t5, 0($t3)
addi $t3, $t4,  16656
li $t5, 0x010406
sw $t5, 0($t3)
addi $t3, $t4,  16660
li $t5, 0x090a05
sw $t5, 0($t3)
addi $t3, $t4,  16664
li $t5, 0x040100
sw $t5, 0($t3)
addi $t3, $t4,  16668
li $t5, 0x03060f
sw $t5, 0($t3)
addi $t3, $t4,  16672
li $t5, 0x111612
sw $t5, 0($t3)
addi $t3, $t4,  16676
li $t5, 0x1d221f
sw $t5, 0($t3)
addi $t3, $t4,  16680
li $t5, 0x2e332d
sw $t5, 0($t3)
addi $t3, $t4,  16684
li $t5, 0x000200
sw $t5, 0($t3)
addi $t3, $t4,  16688
li $t5, 0x252a24
sw $t5, 0($t3)
addi $t3, $t4,  16692
li $t5, 0x000401
sw $t5, 0($t3)
addi $t3, $t4,  16696
li $t5, 0x262b27
sw $t5, 0($t3)
addi $t3, $t4,  16700
li $t5, 0x000209
sw $t5, 0($t3)
addi $t3, $t4,  16704
li $t5, 0x030605
sw $t5, 0($t3)
addi $t3, $t4,  16708
li $t5, 0x000002
sw $t5, 0($t3)
addi $t3, $t4,  16712
li $t5, 0x000102
sw $t5, 0($t3)
addi $t3, $t4,  16716
li $t5, 0x2c2d2c
sw $t5, 0($t3)
addi $t3, $t4,  16720
li $t5, 0x010000
sw $t5, 0($t3)
addi $t3, $t4,  16724
li $t5, 0x0d0d0d
sw $t5, 0($t3)
addi $t3, $t4,  16728
li $t5, 0x030301
sw $t5, 0($t3)
addi $t3, $t4,  16732
li $t5, 0x010302
sw $t5, 0($t3)
addi $t3, $t4,  16736
li $t5, 0x000302
sw $t5, 0($t3)
addi $t3, $t4,  16740
li $t5, 0x010001
sw $t5, 0($t3)
addi $t3, $t4,  16744
li $t5, 0x000001
sw $t5, 0($t3)
addi $t3, $t4,  16748
sw $t5, 0($t3)
addi $t3, $t4,  16752
sw $t5, 0($t3)
addi $t3, $t4,  16756
sw $t5, 0($t3)
addi $t3, $t4,  16760
sw $t5, 0($t3)
addi $t3, $t4,  16764
sw $t5, 0($t3)
addi $t3, $t4,  16768
sw $t5, 0($t3)
addi $t3, $t4,  16772
sw $t5, 0($t3)
addi $t3, $t4,  16776
sw $t5, 0($t3)
addi $t3, $t4,  16780
sw $t5, 0($t3)
addi $t3, $t4,  16784
sw $t5, 0($t3)
addi $t3, $t4,  16788
sw $t5, 0($t3)
addi $t3, $t4,  16792
li $t5, 0x010005
sw $t5, 0($t3)
addi $t3, $t4,  16796
li $t5, 0x000102
sw $t5, 0($t3)
addi $t3, $t4,  16800
li $t5, 0x040000
sw $t5, 0($t3)
addi $t3, $t4,  16804
li $t5, 0x010006
sw $t5, 0($t3)
addi $t3, $t4,  16808
li $t5, 0x06040b
sw $t5, 0($t3)
addi $t3, $t4,  16812
li $t5, 0x030106
sw $t5, 0($t3)
addi $t3, $t4,  16816
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  16820
sw $t5, 0($t3)
addi $t3, $t4,  16824
sw $t5, 0($t3)
addi $t3, $t4,  16828
sw $t5, 0($t3)
addi $t3, $t4,  16832
sw $t5, 0($t3)
addi $t3, $t4,  16836
sw $t5, 0($t3)
addi $t3, $t4,  16840
sw $t5, 0($t3)
addi $t3, $t4,  16844
sw $t5, 0($t3)
addi $t3, $t4,  16848
sw $t5, 0($t3)
addi $t3, $t4,  16852
sw $t5, 0($t3)
addi $t3, $t4,  16856
sw $t5, 0($t3)
addi $t3, $t4,  16860
sw $t5, 0($t3)
addi $t3, $t4,  16864
sw $t5, 0($t3)
addi $t3, $t4,  16868
sw $t5, 0($t3)
addi $t3, $t4,  16872
sw $t5, 0($t3)
addi $t3, $t4,  16876
sw $t5, 0($t3)
addi $t3, $t4,  16880
sw $t5, 0($t3)
addi $t3, $t4,  16884
sw $t5, 0($t3)
addi $t3, $t4,  16888
sw $t5, 0($t3)
addi $t3, $t4,  16892
sw $t5, 0($t3)
syscall #sleep for 30 ms
addi $t3, $t4,  16896
sw $t5, 0($t3)
addi $t3, $t4,  16900
sw $t5, 0($t3)
addi $t3, $t4,  16904
sw $t5, 0($t3)
addi $t3, $t4,  16908
sw $t5, 0($t3)
addi $t3, $t4,  16912
sw $t5, 0($t3)
addi $t3, $t4,  16916
sw $t5, 0($t3)
addi $t3, $t4,  16920
sw $t5, 0($t3)
addi $t3, $t4,  16924
sw $t5, 0($t3)
addi $t3, $t4,  16928
sw $t5, 0($t3)
addi $t3, $t4,  16932
sw $t5, 0($t3)
addi $t3, $t4,  16936
sw $t5, 0($t3)
addi $t3, $t4,  16940
sw $t5, 0($t3)
addi $t3, $t4,  16944
sw $t5, 0($t3)
addi $t3, $t4,  16948
sw $t5, 0($t3)
addi $t3, $t4,  16952
sw $t5, 0($t3)
addi $t3, $t4,  16956
sw $t5, 0($t3)
addi $t3, $t4,  16960
sw $t5, 0($t3)
addi $t3, $t4,  16964
sw $t5, 0($t3)
addi $t3, $t4,  16968
sw $t5, 0($t3)
addi $t3, $t4,  16972
sw $t5, 0($t3)
addi $t3, $t4,  16976
sw $t5, 0($t3)
addi $t3, $t4,  16980
sw $t5, 0($t3)
addi $t3, $t4,  16984
li $t5, 0x030303
sw $t5, 0($t3)
addi $t3, $t4,  16988
li $t5, 0xad7b2c
sw $t5, 0($t3)
addi $t3, $t4,  16992
li $t5, 0xad7a2b
sw $t5, 0($t3)
addi $t3, $t4,  16996
sw $t5, 0($t3)
addi $t3, $t4,  17000
li $t5, 0xb1782a
sw $t5, 0($t3)
addi $t3, $t4,  17004
li $t5, 0xb0782c
sw $t5, 0($t3)
addi $t3, $t4,  17008
li $t5, 0xb17925
sw $t5, 0($t3)
addi $t3, $t4,  17012
li $t5, 0xb07824
sw $t5, 0($t3)
addi $t3, $t4,  17016
sw $t5, 0($t3)
addi $t3, $t4,  17020
sw $t5, 0($t3)
addi $t3, $t4,  17024
sw $t5, 0($t3)
addi $t3, $t4,  17028
sw $t5, 0($t3)
addi $t3, $t4,  17032
sw $t5, 0($t3)
addi $t3, $t4,  17036
sw $t5, 0($t3)
addi $t3, $t4,  17040
li $t5, 0xb2762b
sw $t5, 0($t3)
addi $t3, $t4,  17044
li $t5, 0x71541f
sw $t5, 0($t3)
addi $t3, $t4,  17048
li $t5, 0x030000
sw $t5, 0($t3)
addi $t3, $t4,  17052
li $t5, 0x2a2523
sw $t5, 0($t3)
addi $t3, $t4,  17056
li $t5, 0x312b2a
sw $t5, 0($t3)
addi $t3, $t4,  17060
li $t5, 0x030503
sw $t5, 0($t3)
addi $t3, $t4,  17064
li $t5, 0x393128
sw $t5, 0($t3)
addi $t3, $t4,  17068
li $t5, 0xba8b3b
sw $t5, 0($t3)
addi $t3, $t4,  17072
li $t5, 0xb27d36
sw $t5, 0($t3)
addi $t3, $t4,  17076
li $t5, 0xc49046
sw $t5, 0($t3)
addi $t3, $t4,  17080
li $t5, 0xb37d27
sw $t5, 0($t3)
addi $t3, $t4,  17084
li $t5, 0xad7729
sw $t5, 0($t3)
addi $t3, $t4,  17088
li $t5, 0x725628
sw $t5, 0($t3)
addi $t3, $t4,  17092
li $t5, 0x323232
sw $t5, 0($t3)
addi $t3, $t4,  17096
li $t5, 0x040404
sw $t5, 0($t3)
addi $t3, $t4,  17100
li $t5, 0x020202
sw $t5, 0($t3)
addi $t3, $t4,  17104
li $t5, 0x1a1a1a
sw $t5, 0($t3)
addi $t3, $t4,  17108
li $t5, 0x292929
sw $t5, 0($t3)
addi $t3, $t4,  17112
li $t5, 0x010101
sw $t5, 0($t3)
addi $t3, $t4,  17116
li $t5, 0x313131
sw $t5, 0($t3)
addi $t3, $t4,  17120
li $t5, 0x2c2934
sw $t5, 0($t3)
addi $t3, $t4,  17124
li $t5, 0x997131
sw $t5, 0($t3)
addi $t3, $t4,  17128
li $t5, 0xa5742c
sw $t5, 0($t3)
addi $t3, $t4,  17132
li $t5, 0xb67f2f
sw $t5, 0($t3)
addi $t3, $t4,  17136
li $t5, 0xa8782d
sw $t5, 0($t3)
addi $t3, $t4,  17140
li $t5, 0xab7827
sw $t5, 0($t3)
addi $t3, $t4,  17144
li $t5, 0xbb9248
sw $t5, 0($t3)
addi $t3, $t4,  17148
li $t5, 0x272524
sw $t5, 0($t3)
addi $t3, $t4,  17152
li $t5, 0x060102
sw $t5, 0($t3)
addi $t3, $t4,  17156
li $t5, 0x9c7329
sw $t5, 0($t3)
addi $t3, $t4,  17160
li $t5, 0xaf7f32
sw $t5, 0($t3)
addi $t3, $t4,  17164
li $t5, 0xb17824
sw $t5, 0($t3)
addi $t3, $t4,  17168
li $t5, 0xad7a2a
sw $t5, 0($t3)
addi $t3, $t4,  17172
li $t5, 0xa37936
sw $t5, 0($t3)
addi $t3, $t4,  17176
li $t5, 0xad7a30
sw $t5, 0($t3)
addi $t3, $t4,  17180
li $t5, 0xa8772f
sw $t5, 0($t3)
addi $t3, $t4,  17184
li $t5, 0xad7c30
sw $t5, 0($t3)
addi $t3, $t4,  17188
li $t5, 0xb8873d
sw $t5, 0($t3)
addi $t3, $t4,  17192
li $t5, 0xc49453
sw $t5, 0($t3)
addi $t3, $t4,  17196
li $t5, 0xa47626
sw $t5, 0($t3)
addi $t3, $t4,  17200
li $t5, 0xa47332
sw $t5, 0($t3)
addi $t3, $t4,  17204
li $t5, 0xb38133
sw $t5, 0($t3)
addi $t3, $t4,  17208
li $t5, 0xa1732e
sw $t5, 0($t3)
addi $t3, $t4,  17212
li $t5, 0xa97524
sw $t5, 0($t3)
addi $t3, $t4,  17216
li $t5, 0xc38c44
sw $t5, 0($t3)
addi $t3, $t4,  17220
li $t5, 0xbc8b3f
sw $t5, 0($t3)
addi $t3, $t4,  17224
li $t5, 0xad752a
sw $t5, 0($t3)
addi $t3, $t4,  17228
li $t5, 0xaa7831
sw $t5, 0($t3)
addi $t3, $t4,  17232
li $t5, 0xbc8d3d
sw $t5, 0($t3)
addi $t3, $t4,  17236
li $t5, 0x0e0303
sw $t5, 0($t3)
addi $t3, $t4,  17240
li $t5, 0x010200
sw $t5, 0($t3)
addi $t3, $t4,  17244
li $t5, 0xa87d40
sw $t5, 0($t3)
addi $t3, $t4,  17248
li $t5, 0xb2772a
sw $t5, 0($t3)
addi $t3, $t4,  17252
li $t5, 0xb47822
sw $t5, 0($t3)
addi $t3, $t4,  17256
li $t5, 0xb27828
sw $t5, 0($t3)
addi $t3, $t4,  17260
sw $t5, 0($t3)
addi $t3, $t4,  17264
sw $t5, 0($t3)
addi $t3, $t4,  17268
sw $t5, 0($t3)
addi $t3, $t4,  17272
sw $t5, 0($t3)
addi $t3, $t4,  17276
sw $t5, 0($t3)
addi $t3, $t4,  17280
sw $t5, 0($t3)
addi $t3, $t4,  17284
li $t5, 0xb07626
sw $t5, 0($t3)
addi $t3, $t4,  17288
sw $t5, 0($t3)
addi $t3, $t4,  17292
sw $t5, 0($t3)
addi $t3, $t4,  17296
li $t5, 0xaf7525
sw $t5, 0($t3)
addi $t3, $t4,  17300
sw $t5, 0($t3)
addi $t3, $t4,  17304
li $t5, 0xb37323
sw $t5, 0($t3)
addi $t3, $t4,  17308
li $t5, 0xad7721
sw $t5, 0($t3)
addi $t3, $t4,  17312
li $t5, 0x503417
sw $t5, 0($t3)
addi $t3, $t4,  17316
li $t5, 0x020009
sw $t5, 0($t3)
addi $t3, $t4,  17320
sw $t5, 0($t3)
addi $t3, $t4,  17324
li $t5, 0x020005
sw $t5, 0($t3)
addi $t3, $t4,  17328
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  17332
sw $t5, 0($t3)
addi $t3, $t4,  17336
sw $t5, 0($t3)
addi $t3, $t4,  17340
sw $t5, 0($t3)
addi $t3, $t4,  17344
sw $t5, 0($t3)
addi $t3, $t4,  17348
sw $t5, 0($t3)
addi $t3, $t4,  17352
sw $t5, 0($t3)
addi $t3, $t4,  17356
sw $t5, 0($t3)
addi $t3, $t4,  17360
sw $t5, 0($t3)
addi $t3, $t4,  17364
sw $t5, 0($t3)
addi $t3, $t4,  17368
sw $t5, 0($t3)
addi $t3, $t4,  17372
sw $t5, 0($t3)
addi $t3, $t4,  17376
sw $t5, 0($t3)
addi $t3, $t4,  17380
sw $t5, 0($t3)
addi $t3, $t4,  17384
sw $t5, 0($t3)
addi $t3, $t4,  17388
sw $t5, 0($t3)
addi $t3, $t4,  17392
sw $t5, 0($t3)
addi $t3, $t4,  17396
sw $t5, 0($t3)
addi $t3, $t4,  17400
sw $t5, 0($t3)
addi $t3, $t4,  17404
sw $t5, 0($t3)
syscall #sleep for 30 ms
addi $t3, $t4,  17408
sw $t5, 0($t3)
addi $t3, $t4,  17412
sw $t5, 0($t3)
addi $t3, $t4,  17416
sw $t5, 0($t3)
addi $t3, $t4,  17420
sw $t5, 0($t3)
addi $t3, $t4,  17424
sw $t5, 0($t3)
addi $t3, $t4,  17428
sw $t5, 0($t3)
addi $t3, $t4,  17432
sw $t5, 0($t3)
addi $t3, $t4,  17436
sw $t5, 0($t3)
addi $t3, $t4,  17440
sw $t5, 0($t3)
addi $t3, $t4,  17444
sw $t5, 0($t3)
addi $t3, $t4,  17448
sw $t5, 0($t3)
addi $t3, $t4,  17452
sw $t5, 0($t3)
addi $t3, $t4,  17456
sw $t5, 0($t3)
addi $t3, $t4,  17460
sw $t5, 0($t3)
addi $t3, $t4,  17464
sw $t5, 0($t3)
addi $t3, $t4,  17468
sw $t5, 0($t3)
addi $t3, $t4,  17472
sw $t5, 0($t3)
addi $t3, $t4,  17476
sw $t5, 0($t3)
addi $t3, $t4,  17480
sw $t5, 0($t3)
addi $t3, $t4,  17484
li $t5, 0x020000
sw $t5, 0($t3)
addi $t3, $t4,  17488
li $t5, 0x050000
sw $t5, 0($t3)
addi $t3, $t4,  17492
li $t5, 0x030000
sw $t5, 0($t3)
addi $t3, $t4,  17496
li $t5, 0x0a0000
sw $t5, 0($t3)
addi $t3, $t4,  17500
li $t5, 0xfc9707
sw $t5, 0($t3)
addi $t3, $t4,  17504
li $t5, 0xfd9700
sw $t5, 0($t3)
addi $t3, $t4,  17508
li $t5, 0xff9503
sw $t5, 0($t3)
addi $t3, $t4,  17512
li $t5, 0xff9305
sw $t5, 0($t3)
addi $t3, $t4,  17516
li $t5, 0xff940d
sw $t5, 0($t3)
addi $t3, $t4,  17520
li $t5, 0xff9308
sw $t5, 0($t3)
addi $t3, $t4,  17524
sw $t5, 0($t3)
addi $t3, $t4,  17528
sw $t5, 0($t3)
addi $t3, $t4,  17532
li $t5, 0xff9207
sw $t5, 0($t3)
addi $t3, $t4,  17536
li $t5, 0xff9308
sw $t5, 0($t3)
addi $t3, $t4,  17540
li $t5, 0xfc9700
sw $t5, 0($t3)
addi $t3, $t4,  17544
li $t5, 0xff9400
sw $t5, 0($t3)
addi $t3, $t4,  17548
li $t5, 0xff9100
sw $t5, 0($t3)
addi $t3, $t4,  17552
li $t5, 0xf99900
sw $t5, 0($t3)
addi $t3, $t4,  17556
li $t5, 0xa06c18
sw $t5, 0($t3)
addi $t3, $t4,  17560
li $t5, 0x020007
sw $t5, 0($t3)
addi $t3, $t4,  17564
li $t5, 0x2a2521
sw $t5, 0($t3)
addi $t3, $t4,  17568
li $t5, 0x2a2a29
sw $t5, 0($t3)
addi $t3, $t4,  17572
li $t5, 0x040207
sw $t5, 0($t3)
addi $t3, $t4,  17576
li $t5, 0x25281a
sw $t5, 0($t3)
addi $t3, $t4,  17580
li $t5, 0xfa9f1c
sw $t5, 0($t3)
addi $t3, $t4,  17584
li $t5, 0xf89812
sw $t5, 0($t3)
addi $t3, $t4,  17588
li $t5, 0xfea51d
sw $t5, 0($t3)
addi $t3, $t4,  17592
li $t5, 0xff9304
sw $t5, 0($t3)
addi $t3, $t4,  17596
li $t5, 0xfb8c11
sw $t5, 0($t3)
addi $t3, $t4,  17600
li $t5, 0x975e1d
sw $t5, 0($t3)
addi $t3, $t4,  17604
li $t5, 0x272727
sw $t5, 0($t3)
addi $t3, $t4,  17608
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  17612
li $t5, 0x020202
sw $t5, 0($t3)
addi $t3, $t4,  17616
li $t5, 0x1e1e1e
sw $t5, 0($t3)
addi $t3, $t4,  17620
li $t5, 0x242424
sw $t5, 0($t3)
addi $t3, $t4,  17624
li $t5, 0x080808
sw $t5, 0($t3)
addi $t3, $t4,  17628
li $t5, 0x171717
sw $t5, 0($t3)
addi $t3, $t4,  17632
li $t5, 0x322b2f
sw $t5, 0($t3)
addi $t3, $t4,  17636
li $t5, 0xf38e06
sw $t5, 0($t3)
addi $t3, $t4,  17640
li $t5, 0xea8708
sw $t5, 0($t3)
addi $t3, $t4,  17644
li $t5, 0xfc9407
sw $t5, 0($t3)
addi $t3, $t4,  17648
li $t5, 0xf1900c
sw $t5, 0($t3)
addi $t3, $t4,  17652
li $t5, 0xfb9104
sw $t5, 0($t3)
addi $t3, $t4,  17656
li $t5, 0xfea62d
sw $t5, 0($t3)
addi $t3, $t4,  17660
li $t5, 0x21291a
sw $t5, 0($t3)
addi $t3, $t4,  17664
li $t5, 0x040302
sw $t5, 0($t3)
addi $t3, $t4,  17668
li $t5, 0xe77e03
sw $t5, 0($t3)
addi $t3, $t4,  17672
li $t5, 0xed920e
sw $t5, 0($t3)
addi $t3, $t4,  17676
li $t5, 0xfe9303
sw $t5, 0($t3)
addi $t3, $t4,  17680
li $t5, 0xfd950c
sw $t5, 0($t3)
addi $t3, $t4,  17684
li $t5, 0xee8c0c
sw $t5, 0($t3)
addi $t3, $t4,  17688
li $t5, 0xfd980e
sw $t5, 0($t3)
addi $t3, $t4,  17692
li $t5, 0xf99a1e
sw $t5, 0($t3)
addi $t3, $t4,  17696
li $t5, 0xf08f08
sw $t5, 0($t3)
addi $t3, $t4,  17700
li $t5, 0xfd9a0e
sw $t5, 0($t3)
addi $t3, $t4,  17704
li $t5, 0xffa32e
sw $t5, 0($t3)
addi $t3, $t4,  17708
li $t5, 0xf48c09
sw $t5, 0($t3)
addi $t3, $t4,  17712
li $t5, 0xf1901a
sw $t5, 0($t3)
addi $t3, $t4,  17716
li $t5, 0xf9910c
sw $t5, 0($t3)
addi $t3, $t4,  17720
li $t5, 0xec8810
sw $t5, 0($t3)
addi $t3, $t4,  17724
li $t5, 0xf58d04
sw $t5, 0($t3)
addi $t3, $t4,  17728
li $t5, 0xfda221
sw $t5, 0($t3)
addi $t3, $t4,  17732
li $t5, 0xff9f26
sw $t5, 0($t3)
addi $t3, $t4,  17736
li $t5, 0xee8b01
sw $t5, 0($t3)
addi $t3, $t4,  17740
li $t5, 0xee9210
sw $t5, 0($t3)
addi $t3, $t4,  17744
li $t5, 0xfc9d24
sw $t5, 0($t3)
addi $t3, $t4,  17748
li $t5, 0x0b0002
sw $t5, 0($t3)
addi $t3, $t4,  17752
li $t5, 0x000202
sw $t5, 0($t3)
addi $t3, $t4,  17756
li $t5, 0xf69414
sw $t5, 0($t3)
addi $t3, $t4,  17760
li $t5, 0xfb8f00
sw $t5, 0($t3)
addi $t3, $t4,  17764
li $t5, 0xff9000
sw $t5, 0($t3)
addi $t3, $t4,  17768
li $t5, 0xff9102
sw $t5, 0($t3)
addi $t3, $t4,  17772
sw $t5, 0($t3)
addi $t3, $t4,  17776
li $t5, 0xff9100
sw $t5, 0($t3)
addi $t3, $t4,  17780
li $t5, 0xff8e00
sw $t5, 0($t3)
addi $t3, $t4,  17784
sw $t5, 0($t3)
addi $t3, $t4,  17788
li $t5, 0xfa9204
sw $t5, 0($t3)
addi $t3, $t4,  17792
sw $t5, 0($t3)
addi $t3, $t4,  17796
li $t5, 0xfa9109
sw $t5, 0($t3)
addi $t3, $t4,  17800
sw $t5, 0($t3)
addi $t3, $t4,  17804
sw $t5, 0($t3)
addi $t3, $t4,  17808
li $t5, 0xff8f01
sw $t5, 0($t3)
addi $t3, $t4,  17812
li $t5, 0xff8f00
sw $t5, 0($t3)
addi $t3, $t4,  17816
sw $t5, 0($t3)
addi $t3, $t4,  17820
li $t5, 0xf7920a
sw $t5, 0($t3)
addi $t3, $t4,  17824
li $t5, 0x753b12
sw $t5, 0($t3)
addi $t3, $t4,  17828
li $t5, 0x0b0000
sw $t5, 0($t3)
addi $t3, $t4,  17832
li $t5, 0x080000
sw $t5, 0($t3)
addi $t3, $t4,  17836
li $t5, 0x050000
sw $t5, 0($t3)
addi $t3, $t4,  17840
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  17844
sw $t5, 0($t3)
addi $t3, $t4,  17848
sw $t5, 0($t3)
addi $t3, $t4,  17852
sw $t5, 0($t3)
addi $t3, $t4,  17856
sw $t5, 0($t3)
addi $t3, $t4,  17860
sw $t5, 0($t3)
addi $t3, $t4,  17864
sw $t5, 0($t3)
addi $t3, $t4,  17868
sw $t5, 0($t3)
addi $t3, $t4,  17872
sw $t5, 0($t3)
addi $t3, $t4,  17876
sw $t5, 0($t3)
addi $t3, $t4,  17880
sw $t5, 0($t3)
addi $t3, $t4,  17884
sw $t5, 0($t3)
addi $t3, $t4,  17888
sw $t5, 0($t3)
addi $t3, $t4,  17892
sw $t5, 0($t3)
addi $t3, $t4,  17896
sw $t5, 0($t3)
addi $t3, $t4,  17900
sw $t5, 0($t3)
addi $t3, $t4,  17904
sw $t5, 0($t3)
addi $t3, $t4,  17908
sw $t5, 0($t3)
addi $t3, $t4,  17912
sw $t5, 0($t3)
addi $t3, $t4,  17916
sw $t5, 0($t3)
syscall #sleep for 30 ms
addi $t3, $t4,  17920
sw $t5, 0($t3)
addi $t3, $t4,  17924
sw $t5, 0($t3)
addi $t3, $t4,  17928
sw $t5, 0($t3)
addi $t3, $t4,  17932
sw $t5, 0($t3)
addi $t3, $t4,  17936
sw $t5, 0($t3)
addi $t3, $t4,  17940
sw $t5, 0($t3)
addi $t3, $t4,  17944
sw $t5, 0($t3)
addi $t3, $t4,  17948
sw $t5, 0($t3)
addi $t3, $t4,  17952
sw $t5, 0($t3)
addi $t3, $t4,  17956
sw $t5, 0($t3)
addi $t3, $t4,  17960
sw $t5, 0($t3)
addi $t3, $t4,  17964
sw $t5, 0($t3)
addi $t3, $t4,  17968
sw $t5, 0($t3)
addi $t3, $t4,  17972
sw $t5, 0($t3)
addi $t3, $t4,  17976
sw $t5, 0($t3)
addi $t3, $t4,  17980
sw $t5, 0($t3)
addi $t3, $t4,  17984
sw $t5, 0($t3)
addi $t3, $t4,  17988
sw $t5, 0($t3)
addi $t3, $t4,  17992
li $t5, 0x010000
sw $t5, 0($t3)
addi $t3, $t4,  17996
li $t5, 0x020508
sw $t5, 0($t3)
addi $t3, $t4,  18000
li $t5, 0x070000
sw $t5, 0($t3)
addi $t3, $t4,  18004
li $t5, 0x050000
sw $t5, 0($t3)
addi $t3, $t4,  18008
li $t5, 0x0b0000
sw $t5, 0($t3)
addi $t3, $t4,  18012
li $t5, 0xfd8b06
sw $t5, 0($t3)
addi $t3, $t4,  18016
li $t5, 0xff8d00
sw $t5, 0($t3)
addi $t3, $t4,  18020
li $t5, 0xff8b03
sw $t5, 0($t3)
addi $t3, $t4,  18024
li $t5, 0xf58e16
sw $t5, 0($t3)
addi $t3, $t4,  18028
li $t5, 0xff8900
sw $t5, 0($t3)
addi $t3, $t4,  18032
li $t5, 0xff8a04
sw $t5, 0($t3)
addi $t3, $t4,  18036
sw $t5, 0($t3)
addi $t3, $t4,  18040
sw $t5, 0($t3)
addi $t3, $t4,  18044
sw $t5, 0($t3)
addi $t3, $t4,  18048
sw $t5, 0($t3)
addi $t3, $t4,  18052
li $t5, 0xff8700
sw $t5, 0($t3)
addi $t3, $t4,  18056
li $t5, 0xff8b03
sw $t5, 0($t3)
addi $t3, $t4,  18060
li $t5, 0xfc9002
sw $t5, 0($t3)
addi $t3, $t4,  18064
li $t5, 0xfe8d00
sw $t5, 0($t3)
addi $t3, $t4,  18068
li $t5, 0xa4691e
sw $t5, 0($t3)
addi $t3, $t4,  18072
li $t5, 0x010007
sw $t5, 0($t3)
addi $t3, $t4,  18076
li $t5, 0x010107
sw $t5, 0($t3)
addi $t3, $t4,  18080
li $t5, 0x181115
sw $t5, 0($t3)
addi $t3, $t4,  18084
li $t5, 0x000104
sw $t5, 0($t3)
addi $t3, $t4,  18088
li $t5, 0x2a2c1e
sw $t5, 0($t3)
addi $t3, $t4,  18092
li $t5, 0xfe8d09
sw $t5, 0($t3)
addi $t3, $t4,  18096
li $t5, 0xf88c11
sw $t5, 0($t3)
addi $t3, $t4,  18100
li $t5, 0xfe9e22
sw $t5, 0($t3)
addi $t3, $t4,  18104
li $t5, 0xff8906
sw $t5, 0($t3)
addi $t3, $t4,  18108
li $t5, 0xff8410
sw $t5, 0($t3)
addi $t3, $t4,  18112
li $t5, 0xb87032
sw $t5, 0($t3)
addi $t3, $t4,  18116
li $t5, 0x030303
sw $t5, 0($t3)
addi $t3, $t4,  18120
li $t5, 0x020202
sw $t5, 0($t3)
addi $t3, $t4,  18124
li $t5, 0x181818
sw $t5, 0($t3)
addi $t3, $t4,  18128
li $t5, 0x030303
sw $t5, 0($t3)
addi $t3, $t4,  18132
li $t5, 0x2c2c2c
sw $t5, 0($t3)
addi $t3, $t4,  18136
li $t5, 0x030303
sw $t5, 0($t3)
addi $t3, $t4,  18140
li $t5, 0x131313
sw $t5, 0($t3)
addi $t3, $t4,  18144
li $t5, 0x292727
sw $t5, 0($t3)
addi $t3, $t4,  18148
li $t5, 0xec8604
sw $t5, 0($t3)
addi $t3, $t4,  18152
li $t5, 0xee8313
sw $t5, 0($t3)
addi $t3, $t4,  18156
li $t5, 0xf88807
sw $t5, 0($t3)
addi $t3, $t4,  18160
li $t5, 0xf48a12
sw $t5, 0($t3)
addi $t3, $t4,  18164
li $t5, 0xfb8401
sw $t5, 0($t3)
addi $t3, $t4,  18168
li $t5, 0xff9e2c
sw $t5, 0($t3)
addi $t3, $t4,  18172
li $t5, 0x23281f
sw $t5, 0($t3)
addi $t3, $t4,  18176
li $t5, 0x232420
sw $t5, 0($t3)
addi $t3, $t4,  18180
li $t5, 0xf1820d
sw $t5, 0($t3)
addi $t3, $t4,  18184
li $t5, 0xea7f06
sw $t5, 0($t3)
addi $t3, $t4,  18188
li $t5, 0xff8800
sw $t5, 0($t3)
addi $t3, $t4,  18192
li $t5, 0xff8904
sw $t5, 0($t3)
addi $t3, $t4,  18196
li $t5, 0xfc9a29
sw $t5, 0($t3)
addi $t3, $t4,  18200
li $t5, 0xf4870a
sw $t5, 0($t3)
addi $t3, $t4,  18204
li $t5, 0xf2840d
sw $t5, 0($t3)
addi $t3, $t4,  18208
li $t5, 0xfb880a
sw $t5, 0($t3)
addi $t3, $t4,  18212
li $t5, 0xfc8a0d
sw $t5, 0($t3)
addi $t3, $t4,  18216
li $t5, 0xfd9a30
sw $t5, 0($t3)
addi $t3, $t4,  18220
li $t5, 0xf3860f
sw $t5, 0($t3)
addi $t3, $t4,  18224
li $t5, 0xec861a
sw $t5, 0($t3)
addi $t3, $t4,  18228
li $t5, 0xfa8713
sw $t5, 0($t3)
addi $t3, $t4,  18232
li $t5, 0xeb7d10
sw $t5, 0($t3)
addi $t3, $t4,  18236
li $t5, 0xf67b08
sw $t5, 0($t3)
addi $t3, $t4,  18240
li $t5, 0xfd9425
sw $t5, 0($t3)
addi $t3, $t4,  18244
li $t5, 0xfe9324
sw $t5, 0($t3)
addi $t3, $t4,  18248
li $t5, 0xfc8501
sw $t5, 0($t3)
addi $t3, $t4,  18252
li $t5, 0xfd9517
sw $t5, 0($t3)
addi $t3, $t4,  18256
li $t5, 0xfc890f
sw $t5, 0($t3)
addi $t3, $t4,  18260
li $t5, 0x100000
sw $t5, 0($t3)
addi $t3, $t4,  18264
li $t5, 0x010109
sw $t5, 0($t3)
addi $t3, $t4,  18268
li $t5, 0xe38a24
sw $t5, 0($t3)
addi $t3, $t4,  18272
li $t5, 0xfa8909
sw $t5, 0($t3)
addi $t3, $t4,  18276
li $t5, 0xff8103
sw $t5, 0($t3)
addi $t3, $t4,  18280
li $t5, 0xff8501
sw $t5, 0($t3)
addi $t3, $t4,  18284
sw $t5, 0($t3)
addi $t3, $t4,  18288
li $t5, 0xf98400
sw $t5, 0($t3)
addi $t3, $t4,  18292
li $t5, 0xff8601
sw $t5, 0($t3)
addi $t3, $t4,  18296
li $t5, 0xff8700
sw $t5, 0($t3)
addi $t3, $t4,  18300
li $t5, 0xfa8704
sw $t5, 0($t3)
addi $t3, $t4,  18304
sw $t5, 0($t3)
addi $t3, $t4,  18308
li $t5, 0xfa8706
sw $t5, 0($t3)
addi $t3, $t4,  18312
sw $t5, 0($t3)
addi $t3, $t4,  18316
sw $t5, 0($t3)
addi $t3, $t4,  18320
li $t5, 0xff8400
sw $t5, 0($t3)
addi $t3, $t4,  18324
li $t5, 0xff8905
sw $t5, 0($t3)
addi $t3, $t4,  18328
li $t5, 0xfa8705
sw $t5, 0($t3)
addi $t3, $t4,  18332
li $t5, 0xfe8406
sw $t5, 0($t3)
addi $t3, $t4,  18336
li $t5, 0x6c3315
sw $t5, 0($t3)
addi $t3, $t4,  18340
li $t5, 0x000104
sw $t5, 0($t3)
addi $t3, $t4,  18344
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  18348
li $t5, 0x000105
sw $t5, 0($t3)
addi $t3, $t4,  18352
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  18356
sw $t5, 0($t3)
addi $t3, $t4,  18360
sw $t5, 0($t3)
addi $t3, $t4,  18364
sw $t5, 0($t3)
addi $t3, $t4,  18368
sw $t5, 0($t3)
addi $t3, $t4,  18372
sw $t5, 0($t3)
addi $t3, $t4,  18376
sw $t5, 0($t3)
addi $t3, $t4,  18380
sw $t5, 0($t3)
addi $t3, $t4,  18384
sw $t5, 0($t3)
addi $t3, $t4,  18388
sw $t5, 0($t3)
addi $t3, $t4,  18392
sw $t5, 0($t3)
addi $t3, $t4,  18396
sw $t5, 0($t3)
addi $t3, $t4,  18400
sw $t5, 0($t3)
addi $t3, $t4,  18404
sw $t5, 0($t3)
addi $t3, $t4,  18408
sw $t5, 0($t3)
addi $t3, $t4,  18412
sw $t5, 0($t3)
addi $t3, $t4,  18416
sw $t5, 0($t3)
addi $t3, $t4,  18420
sw $t5, 0($t3)
addi $t3, $t4,  18424
sw $t5, 0($t3)
addi $t3, $t4,  18428
sw $t5, 0($t3)
syscall #sleep for 30 ms
addi $t3, $t4,  18432
sw $t5, 0($t3)
addi $t3, $t4,  18436
sw $t5, 0($t3)
addi $t3, $t4,  18440
sw $t5, 0($t3)
addi $t3, $t4,  18444
sw $t5, 0($t3)
addi $t3, $t4,  18448
sw $t5, 0($t3)
addi $t3, $t4,  18452
sw $t5, 0($t3)
addi $t3, $t4,  18456
sw $t5, 0($t3)
addi $t3, $t4,  18460
sw $t5, 0($t3)
addi $t3, $t4,  18464
sw $t5, 0($t3)
addi $t3, $t4,  18468
sw $t5, 0($t3)
addi $t3, $t4,  18472
sw $t5, 0($t3)
addi $t3, $t4,  18476
sw $t5, 0($t3)
addi $t3, $t4,  18480
sw $t5, 0($t3)
addi $t3, $t4,  18484
sw $t5, 0($t3)
addi $t3, $t4,  18488
sw $t5, 0($t3)
addi $t3, $t4,  18492
sw $t5, 0($t3)
addi $t3, $t4,  18496
sw $t5, 0($t3)
addi $t3, $t4,  18500
sw $t5, 0($t3)
addi $t3, $t4,  18504
li $t5, 0x000200
sw $t5, 0($t3)
addi $t3, $t4,  18508
li $t5, 0x050000
sw $t5, 0($t3)
addi $t3, $t4,  18512
li $t5, 0xeb8526
sw $t5, 0($t3)
addi $t3, $t4,  18516
li $t5, 0xfc8101
sw $t5, 0($t3)
addi $t3, $t4,  18520
li $t5, 0xfd8000
sw $t5, 0($t3)
addi $t3, $t4,  18524
li $t5, 0xfd8001
sw $t5, 0($t3)
addi $t3, $t4,  18528
li $t5, 0xfd8000
sw $t5, 0($t3)
addi $t3, $t4,  18532
li $t5, 0xfe7f02
sw $t5, 0($t3)
addi $t3, $t4,  18536
li $t5, 0x030002
sw $t5, 0($t3)
addi $t3, $t4,  18540
li $t5, 0x010001
sw $t5, 0($t3)
addi $t3, $t4,  18544
li $t5, 0x010000
sw $t5, 0($t3)
addi $t3, $t4,  18548
sw $t5, 0($t3)
addi $t3, $t4,  18552
sw $t5, 0($t3)
addi $t3, $t4,  18556
sw $t5, 0($t3)
addi $t3, $t4,  18560
sw $t5, 0($t3)
addi $t3, $t4,  18564
sw $t5, 0($t3)
addi $t3, $t4,  18568
li $t5, 0x290a00
sw $t5, 0($t3)
addi $t3, $t4,  18572
li $t5, 0xfe8101
sw $t5, 0($t3)
addi $t3, $t4,  18576
li $t5, 0xfc8101
sw $t5, 0($t3)
addi $t3, $t4,  18580
li $t5, 0xfe8002
sw $t5, 0($t3)
addi $t3, $t4,  18584
li $t5, 0xff7e00
sw $t5, 0($t3)
addi $t3, $t4,  18588
li $t5, 0xff7c00
sw $t5, 0($t3)
addi $t3, $t4,  18592
li $t5, 0x4b210c
sw $t5, 0($t3)
addi $t3, $t4,  18596
li $t5, 0x000006
sw $t5, 0($t3)
addi $t3, $t4,  18600
li $t5, 0x020300
sw $t5, 0($t3)
addi $t3, $t4,  18604
li $t5, 0xfe7f00
sw $t5, 0($t3)
addi $t3, $t4,  18608
li $t5, 0xfd7f02
sw $t5, 0($t3)
addi $t3, $t4,  18612
li $t5, 0xfc7f02
sw $t5, 0($t3)
addi $t3, $t4,  18616
li $t5, 0xff7d07
sw $t5, 0($t3)
addi $t3, $t4,  18620
li $t5, 0xfc7e09
sw $t5, 0($t3)
addi $t3, $t4,  18624
li $t5, 0x9b4c14
sw $t5, 0($t3)
addi $t3, $t4,  18628
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  18632
sw $t5, 0($t3)
addi $t3, $t4,  18636
sw $t5, 0($t3)
addi $t3, $t4,  18640
sw $t5, 0($t3)
addi $t3, $t4,  18644
sw $t5, 0($t3)
addi $t3, $t4,  18648
sw $t5, 0($t3)
addi $t3, $t4,  18652
sw $t5, 0($t3)
addi $t3, $t4,  18656
li $t5, 0x030105
sw $t5, 0($t3)
addi $t3, $t4,  18660
li $t5, 0xfc7f03
sw $t5, 0($t3)
addi $t3, $t4,  18664
li $t5, 0xff7d03
sw $t5, 0($t3)
addi $t3, $t4,  18668
li $t5, 0xfe7e00
sw $t5, 0($t3)
addi $t3, $t4,  18672
li $t5, 0xfd7e02
sw $t5, 0($t3)
addi $t3, $t4,  18676
li $t5, 0xfc7e00
sw $t5, 0($t3)
addi $t3, $t4,  18680
li $t5, 0xfc7d07
sw $t5, 0($t3)
addi $t3, $t4,  18684
li $t5, 0x010000
sw $t5, 0($t3)
addi $t3, $t4,  18688
li $t5, 0x020000
sw $t5, 0($t3)
addi $t3, $t4,  18692
li $t5, 0xfd7c03
sw $t5, 0($t3)
addi $t3, $t4,  18696
li $t5, 0xfb7f01
sw $t5, 0($t3)
addi $t3, $t4,  18700
li $t5, 0xff7f02
sw $t5, 0($t3)
addi $t3, $t4,  18704
li $t5, 0xff7d01
sw $t5, 0($t3)
addi $t3, $t4,  18708
li $t5, 0xff7d00
sw $t5, 0($t3)
addi $t3, $t4,  18712
li $t5, 0xf77b0b
sw $t5, 0($t3)
addi $t3, $t4,  18716
li $t5, 0x000101
sw $t5, 0($t3)
addi $t3, $t4,  18720
li $t5, 0x000100
sw $t5, 0($t3)
addi $t3, $t4,  18724
sw $t5, 0($t3)
addi $t3, $t4,  18728
li $t5, 0x000002
sw $t5, 0($t3)
addi $t3, $t4,  18732
li $t5, 0x010000
sw $t5, 0($t3)
addi $t3, $t4,  18736
li $t5, 0x000001
sw $t5, 0($t3)
addi $t3, $t4,  18740
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  18744
li $t5, 0x000100
sw $t5, 0($t3)
addi $t3, $t4,  18748
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  18752
li $t5, 0x000100
sw $t5, 0($t3)
addi $t3, $t4,  18756
sw $t5, 0($t3)
addi $t3, $t4,  18760
sw $t5, 0($t3)
addi $t3, $t4,  18764
sw $t5, 0($t3)
addi $t3, $t4,  18768
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  18772
li $t5, 0x000006
sw $t5, 0($t3)
addi $t3, $t4,  18776
li $t5, 0x010000
sw $t5, 0($t3)
addi $t3, $t4,  18780
li $t5, 0xf57f10
sw $t5, 0($t3)
addi $t3, $t4,  18784
li $t5, 0xff7b00
sw $t5, 0($t3)
addi $t3, $t4,  18788
li $t5, 0xff7a01
sw $t5, 0($t3)
addi $t3, $t4,  18792
sw $t5, 0($t3)
addi $t3, $t4,  18796
sw $t5, 0($t3)
addi $t3, $t4,  18800
li $t5, 0xff7b04
sw $t5, 0($t3)
addi $t3, $t4,  18804
li $t5, 0x080000
sw $t5, 0($t3)
addi $t3, $t4,  18808
li $t5, 0x040000
sw $t5, 0($t3)
addi $t3, $t4,  18812
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  18816
sw $t5, 0($t3)
addi $t3, $t4,  18820
sw $t5, 0($t3)
addi $t3, $t4,  18824
sw $t5, 0($t3)
addi $t3, $t4,  18828
sw $t5, 0($t3)
addi $t3, $t4,  18832
li $t5, 0x010002
sw $t5, 0($t3)
addi $t3, $t4,  18836
li $t5, 0x4b1500
sw $t5, 0($t3)
addi $t3, $t4,  18840
li $t5, 0xfd7905
sw $t5, 0($t3)
addi $t3, $t4,  18844
li $t5, 0xfe7803
sw $t5, 0($t3)
addi $t3, $t4,  18848
li $t5, 0xff7800
sw $t5, 0($t3)
addi $t3, $t4,  18852
li $t5, 0xfa7a06
sw $t5, 0($t3)
addi $t3, $t4,  18856
li $t5, 0xf77808
sw $t5, 0($t3)
addi $t3, $t4,  18860
li $t5, 0x2f0900
sw $t5, 0($t3)
addi $t3, $t4,  18864
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  18868
sw $t5, 0($t3)
addi $t3, $t4,  18872
sw $t5, 0($t3)
addi $t3, $t4,  18876
sw $t5, 0($t3)
addi $t3, $t4,  18880
sw $t5, 0($t3)
addi $t3, $t4,  18884
sw $t5, 0($t3)
addi $t3, $t4,  18888
sw $t5, 0($t3)
addi $t3, $t4,  18892
sw $t5, 0($t3)
addi $t3, $t4,  18896
sw $t5, 0($t3)
addi $t3, $t4,  18900
sw $t5, 0($t3)
addi $t3, $t4,  18904
sw $t5, 0($t3)
addi $t3, $t4,  18908
sw $t5, 0($t3)
addi $t3, $t4,  18912
sw $t5, 0($t3)
addi $t3, $t4,  18916
sw $t5, 0($t3)
addi $t3, $t4,  18920
sw $t5, 0($t3)
addi $t3, $t4,  18924
sw $t5, 0($t3)
addi $t3, $t4,  18928
sw $t5, 0($t3)
addi $t3, $t4,  18932
sw $t5, 0($t3)
addi $t3, $t4,  18936
sw $t5, 0($t3)
addi $t3, $t4,  18940
sw $t5, 0($t3)
syscall #sleep for 30 ms
addi $t3, $t4,  18944
sw $t5, 0($t3)
addi $t3, $t4,  18948
sw $t5, 0($t3)
addi $t3, $t4,  18952
sw $t5, 0($t3)
addi $t3, $t4,  18956
sw $t5, 0($t3)
addi $t3, $t4,  18960
sw $t5, 0($t3)
addi $t3, $t4,  18964
sw $t5, 0($t3)
addi $t3, $t4,  18968
sw $t5, 0($t3)
addi $t3, $t4,  18972
sw $t5, 0($t3)
addi $t3, $t4,  18976
sw $t5, 0($t3)
addi $t3, $t4,  18980
sw $t5, 0($t3)
addi $t3, $t4,  18984
sw $t5, 0($t3)
addi $t3, $t4,  18988
sw $t5, 0($t3)
addi $t3, $t4,  18992
sw $t5, 0($t3)
addi $t3, $t4,  18996
sw $t5, 0($t3)
addi $t3, $t4,  19000
sw $t5, 0($t3)
addi $t3, $t4,  19004
sw $t5, 0($t3)
addi $t3, $t4,  19008
sw $t5, 0($t3)
addi $t3, $t4,  19012
sw $t5, 0($t3)
addi $t3, $t4,  19016
li $t5, 0x000200
sw $t5, 0($t3)
addi $t3, $t4,  19020
li $t5, 0x050002
sw $t5, 0($t3)
addi $t3, $t4,  19024
li $t5, 0xef7d20
sw $t5, 0($t3)
addi $t3, $t4,  19028
li $t5, 0xff7701
sw $t5, 0($t3)
addi $t3, $t4,  19032
sw $t5, 0($t3)
addi $t3, $t4,  19036
sw $t5, 0($t3)
addi $t3, $t4,  19040
li $t5, 0xff7801
sw $t5, 0($t3)
addi $t3, $t4,  19044
li $t5, 0xff7800
sw $t5, 0($t3)
addi $t3, $t4,  19048
li $t5, 0x030005
sw $t5, 0($t3)
addi $t3, $t4,  19052
li $t5, 0x000202
sw $t5, 0($t3)
addi $t3, $t4,  19056
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  19060
sw $t5, 0($t3)
addi $t3, $t4,  19064
sw $t5, 0($t3)
addi $t3, $t4,  19068
sw $t5, 0($t3)
addi $t3, $t4,  19072
sw $t5, 0($t3)
addi $t3, $t4,  19076
li $t5, 0x000100
sw $t5, 0($t3)
addi $t3, $t4,  19080
li $t5, 0x290a00
sw $t5, 0($t3)
addi $t3, $t4,  19084
li $t5, 0xff7702
sw $t5, 0($t3)
addi $t3, $t4,  19088
li $t5, 0xff7603
sw $t5, 0($t3)
addi $t3, $t4,  19092
sw $t5, 0($t3)
addi $t3, $t4,  19096
li $t5, 0xff7600
sw $t5, 0($t3)
addi $t3, $t4,  19100
li $t5, 0xff7400
sw $t5, 0($t3)
addi $t3, $t4,  19104
li $t5, 0x4e1f0d
sw $t5, 0($t3)
addi $t3, $t4,  19108
li $t5, 0x000006
sw $t5, 0($t3)
addi $t3, $t4,  19112
li $t5, 0x050100
sw $t5, 0($t3)
addi $t3, $t4,  19116
li $t5, 0xff7603
sw $t5, 0($t3)
addi $t3, $t4,  19120
li $t5, 0xff7502
sw $t5, 0($t3)
addi $t3, $t4,  19124
sw $t5, 0($t3)
addi $t3, $t4,  19128
li $t5, 0xff7108
sw $t5, 0($t3)
addi $t3, $t4,  19132
li $t5, 0xfd7609
sw $t5, 0($t3)
addi $t3, $t4,  19136
li $t5, 0x9b4515
sw $t5, 0($t3)
addi $t3, $t4,  19140
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  19144
sw $t5, 0($t3)
addi $t3, $t4,  19148
sw $t5, 0($t3)
addi $t3, $t4,  19152
sw $t5, 0($t3)
addi $t3, $t4,  19156
sw $t5, 0($t3)
addi $t3, $t4,  19160
sw $t5, 0($t3)
addi $t3, $t4,  19164
sw $t5, 0($t3)
addi $t3, $t4,  19168
li $t5, 0x020103
sw $t5, 0($t3)
addi $t3, $t4,  19172
li $t5, 0xf97403
sw $t5, 0($t3)
addi $t3, $t4,  19176
li $t5, 0xff7202
sw $t5, 0($t3)
addi $t3, $t4,  19180
li $t5, 0xff7300
sw $t5, 0($t3)
addi $t3, $t4,  19184
li $t5, 0xff7200
sw $t5, 0($t3)
addi $t3, $t4,  19188
li $t5, 0xfc7300
sw $t5, 0($t3)
addi $t3, $t4,  19192
li $t5, 0xfe7202
sw $t5, 0($t3)
addi $t3, $t4,  19196
li $t5, 0x040000
sw $t5, 0($t3)
addi $t3, $t4,  19200
sw $t5, 0($t3)
addi $t3, $t4,  19204
li $t5, 0xfc7001
sw $t5, 0($t3)
addi $t3, $t4,  19208
li $t5, 0xfc7200
sw $t5, 0($t3)
addi $t3, $t4,  19212
li $t5, 0xfe7202
sw $t5, 0($t3)
addi $t3, $t4,  19216
li $t5, 0xff7203
sw $t5, 0($t3)
addi $t3, $t4,  19220
li $t5, 0xff7200
sw $t5, 0($t3)
addi $t3, $t4,  19224
li $t5, 0xfa7104
sw $t5, 0($t3)
addi $t3, $t4,  19228
li $t5, 0x030000
sw $t5, 0($t3)
addi $t3, $t4,  19232
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  19236
sw $t5, 0($t3)
addi $t3, $t4,  19240
sw $t5, 0($t3)
addi $t3, $t4,  19244
sw $t5, 0($t3)
addi $t3, $t4,  19248
sw $t5, 0($t3)
addi $t3, $t4,  19252
sw $t5, 0($t3)
addi $t3, $t4,  19256
sw $t5, 0($t3)
addi $t3, $t4,  19260
sw $t5, 0($t3)
addi $t3, $t4,  19264
sw $t5, 0($t3)
addi $t3, $t4,  19268
sw $t5, 0($t3)
addi $t3, $t4,  19272
sw $t5, 0($t3)
addi $t3, $t4,  19276
sw $t5, 0($t3)
addi $t3, $t4,  19280
sw $t5, 0($t3)
addi $t3, $t4,  19284
sw $t5, 0($t3)
addi $t3, $t4,  19288
sw $t5, 0($t3)
addi $t3, $t4,  19292
li $t5, 0xf97611
sw $t5, 0($t3)
addi $t3, $t4,  19296
li $t5, 0xff6e00
sw $t5, 0($t3)
addi $t3, $t4,  19300
li $t5, 0xff6f01
sw $t5, 0($t3)
addi $t3, $t4,  19304
li $t5, 0xff6f02
sw $t5, 0($t3)
addi $t3, $t4,  19308
sw $t5, 0($t3)
addi $t3, $t4,  19312
li $t5, 0xff6f01
sw $t5, 0($t3)
addi $t3, $t4,  19316
li $t5, 0x070001
sw $t5, 0($t3)
addi $t3, $t4,  19320
li $t5, 0x020000
sw $t5, 0($t3)
addi $t3, $t4,  19324
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  19328
sw $t5, 0($t3)
addi $t3, $t4,  19332
sw $t5, 0($t3)
addi $t3, $t4,  19336
sw $t5, 0($t3)
addi $t3, $t4,  19340
sw $t5, 0($t3)
addi $t3, $t4,  19344
li $t5, 0x010001
sw $t5, 0($t3)
addi $t3, $t4,  19348
li $t5, 0x4d1000
sw $t5, 0($t3)
addi $t3, $t4,  19352
li $t5, 0xfe6d03
sw $t5, 0($t3)
addi $t3, $t4,  19356
li $t5, 0xff6d01
sw $t5, 0($t3)
addi $t3, $t4,  19360
sw $t5, 0($t3)
addi $t3, $t4,  19364
li $t5, 0xfb6e05
sw $t5, 0($t3)
addi $t3, $t4,  19368
li $t5, 0xf76c05
sw $t5, 0($t3)
addi $t3, $t4,  19372
li $t5, 0x2e0500
sw $t5, 0($t3)
addi $t3, $t4,  19376
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  19380
sw $t5, 0($t3)
addi $t3, $t4,  19384
sw $t5, 0($t3)
addi $t3, $t4,  19388
sw $t5, 0($t3)
addi $t3, $t4,  19392
sw $t5, 0($t3)
addi $t3, $t4,  19396
sw $t5, 0($t3)
addi $t3, $t4,  19400
sw $t5, 0($t3)
addi $t3, $t4,  19404
sw $t5, 0($t3)
addi $t3, $t4,  19408
sw $t5, 0($t3)
addi $t3, $t4,  19412
sw $t5, 0($t3)
addi $t3, $t4,  19416
sw $t5, 0($t3)
addi $t3, $t4,  19420
sw $t5, 0($t3)
addi $t3, $t4,  19424
sw $t5, 0($t3)
addi $t3, $t4,  19428
sw $t5, 0($t3)
addi $t3, $t4,  19432
sw $t5, 0($t3)
addi $t3, $t4,  19436
sw $t5, 0($t3)
addi $t3, $t4,  19440
sw $t5, 0($t3)
addi $t3, $t4,  19444
sw $t5, 0($t3)
addi $t3, $t4,  19448
sw $t5, 0($t3)
addi $t3, $t4,  19452
sw $t5, 0($t3)
syscall #sleep for 30 ms
addi $t3, $t4,  19456
sw $t5, 0($t3)
addi $t3, $t4,  19460
sw $t5, 0($t3)
addi $t3, $t4,  19464
sw $t5, 0($t3)
addi $t3, $t4,  19468
sw $t5, 0($t3)
addi $t3, $t4,  19472
sw $t5, 0($t3)
addi $t3, $t4,  19476
sw $t5, 0($t3)
addi $t3, $t4,  19480
sw $t5, 0($t3)
addi $t3, $t4,  19484
sw $t5, 0($t3)
addi $t3, $t4,  19488
sw $t5, 0($t3)
addi $t3, $t4,  19492
sw $t5, 0($t3)
addi $t3, $t4,  19496
sw $t5, 0($t3)
addi $t3, $t4,  19500
sw $t5, 0($t3)
addi $t3, $t4,  19504
sw $t5, 0($t3)
addi $t3, $t4,  19508
sw $t5, 0($t3)
addi $t3, $t4,  19512
sw $t5, 0($t3)
addi $t3, $t4,  19516
sw $t5, 0($t3)
addi $t3, $t4,  19520
sw $t5, 0($t3)
addi $t3, $t4,  19524
sw $t5, 0($t3)
addi $t3, $t4,  19528
li $t5, 0x000200
sw $t5, 0($t3)
addi $t3, $t4,  19532
li $t5, 0x050001
sw $t5, 0($t3)
addi $t3, $t4,  19536
li $t5, 0xec741c
sw $t5, 0($t3)
addi $t3, $t4,  19540
li $t5, 0xfe6c00
sw $t5, 0($t3)
addi $t3, $t4,  19544
sw $t5, 0($t3)
addi $t3, $t4,  19548
sw $t5, 0($t3)
addi $t3, $t4,  19552
li $t5, 0xff6c00
sw $t5, 0($t3)
addi $t3, $t4,  19556
li $t5, 0xfe6c00
sw $t5, 0($t3)
addi $t3, $t4,  19560
li $t5, 0x030004
sw $t5, 0($t3)
addi $t3, $t4,  19564
li $t5, 0x000302
sw $t5, 0($t3)
addi $t3, $t4,  19568
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  19572
sw $t5, 0($t3)
addi $t3, $t4,  19576
sw $t5, 0($t3)
addi $t3, $t4,  19580
sw $t5, 0($t3)
addi $t3, $t4,  19584
sw $t5, 0($t3)
addi $t3, $t4,  19588
li $t5, 0x000200
sw $t5, 0($t3)
addi $t3, $t4,  19592
li $t5, 0x2b0900
sw $t5, 0($t3)
addi $t3, $t4,  19596
li $t5, 0xff6a02
sw $t5, 0($t3)
addi $t3, $t4,  19600
li $t5, 0xfe6a00
sw $t5, 0($t3)
addi $t3, $t4,  19604
sw $t5, 0($t3)
addi $t3, $t4,  19608
li $t5, 0xff6a00
sw $t5, 0($t3)
addi $t3, $t4,  19612
li $t5, 0xff6900
sw $t5, 0($t3)
addi $t3, $t4,  19616
li $t5, 0x4d1d0d
sw $t5, 0($t3)
addi $t3, $t4,  19620
li $t5, 0x000005
sw $t5, 0($t3)
addi $t3, $t4,  19624
li $t5, 0x080000
sw $t5, 0($t3)
addi $t3, $t4,  19628
li $t5, 0xfe6a03
sw $t5, 0($t3)
addi $t3, $t4,  19632
li $t5, 0xfe6a00
sw $t5, 0($t3)
addi $t3, $t4,  19636
li $t5, 0xfd6900
sw $t5, 0($t3)
addi $t3, $t4,  19640
li $t5, 0xff6604
sw $t5, 0($t3)
addi $t3, $t4,  19644
li $t5, 0xfb6907
sw $t5, 0($t3)
addi $t3, $t4,  19648
li $t5, 0x9c3e15
sw $t5, 0($t3)
addi $t3, $t4,  19652
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  19656
sw $t5, 0($t3)
addi $t3, $t4,  19660
sw $t5, 0($t3)
addi $t3, $t4,  19664
sw $t5, 0($t3)
addi $t3, $t4,  19668
sw $t5, 0($t3)
addi $t3, $t4,  19672
sw $t5, 0($t3)
addi $t3, $t4,  19676
sw $t5, 0($t3)
addi $t3, $t4,  19680
li $t5, 0x020001
sw $t5, 0($t3)
addi $t3, $t4,  19684
li $t5, 0xf86c02
sw $t5, 0($t3)
addi $t3, $t4,  19688
li $t5, 0xff6502
sw $t5, 0($t3)
addi $t3, $t4,  19692
li $t5, 0xff6700
sw $t5, 0($t3)
addi $t3, $t4,  19696
li $t5, 0xff6600
sw $t5, 0($t3)
addi $t3, $t4,  19700
li $t5, 0xff6702
sw $t5, 0($t3)
addi $t3, $t4,  19704
li $t5, 0xfb6600
sw $t5, 0($t3)
addi $t3, $t4,  19708
li $t5, 0x050000
sw $t5, 0($t3)
addi $t3, $t4,  19712
li $t5, 0x060000
sw $t5, 0($t3)
addi $t3, $t4,  19716
li $t5, 0xfc6701
sw $t5, 0($t3)
addi $t3, $t4,  19720
li $t5, 0xfe6602
sw $t5, 0($t3)
addi $t3, $t4,  19724
li $t5, 0xff6600
sw $t5, 0($t3)
addi $t3, $t4,  19728
sw $t5, 0($t3)
addi $t3, $t4,  19732
li $t5, 0xff6401
sw $t5, 0($t3)
addi $t3, $t4,  19736
li $t5, 0xfa6803
sw $t5, 0($t3)
addi $t3, $t4,  19740
li $t5, 0x040000
sw $t5, 0($t3)
addi $t3, $t4,  19744
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  19748
sw $t5, 0($t3)
addi $t3, $t4,  19752
sw $t5, 0($t3)
addi $t3, $t4,  19756
sw $t5, 0($t3)
addi $t3, $t4,  19760
sw $t5, 0($t3)
addi $t3, $t4,  19764
sw $t5, 0($t3)
addi $t3, $t4,  19768
sw $t5, 0($t3)
addi $t3, $t4,  19772
sw $t5, 0($t3)
addi $t3, $t4,  19776
sw $t5, 0($t3)
addi $t3, $t4,  19780
sw $t5, 0($t3)
addi $t3, $t4,  19784
sw $t5, 0($t3)
addi $t3, $t4,  19788
sw $t5, 0($t3)
addi $t3, $t4,  19792
sw $t5, 0($t3)
addi $t3, $t4,  19796
sw $t5, 0($t3)
addi $t3, $t4,  19800
sw $t5, 0($t3)
addi $t3, $t4,  19804
li $t5, 0xf8690f
sw $t5, 0($t3)
addi $t3, $t4,  19808
li $t5, 0xff6200
sw $t5, 0($t3)
addi $t3, $t4,  19812
li $t5, 0xfe6300
sw $t5, 0($t3)
addi $t3, $t4,  19816
sw $t5, 0($t3)
addi $t3, $t4,  19820
sw $t5, 0($t3)
addi $t3, $t4,  19824
li $t5, 0xfe6101
sw $t5, 0($t3)
addi $t3, $t4,  19828
li $t5, 0x090002
sw $t5, 0($t3)
addi $t3, $t4,  19832
li $t5, 0x000100
sw $t5, 0($t3)
addi $t3, $t4,  19836
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  19840
sw $t5, 0($t3)
addi $t3, $t4,  19844
sw $t5, 0($t3)
addi $t3, $t4,  19848
sw $t5, 0($t3)
addi $t3, $t4,  19852
sw $t5, 0($t3)
addi $t3, $t4,  19856
li $t5, 0x000101
sw $t5, 0($t3)
addi $t3, $t4,  19860
li $t5, 0x4e0c00
sw $t5, 0($t3)
addi $t3, $t4,  19864
li $t5, 0xfd6101
sw $t5, 0($t3)
addi $t3, $t4,  19868
li $t5, 0xff6100
sw $t5, 0($t3)
addi $t3, $t4,  19872
sw $t5, 0($t3)
addi $t3, $t4,  19876
li $t5, 0xfa6303
sw $t5, 0($t3)
addi $t3, $t4,  19880
li $t5, 0xf76103
sw $t5, 0($t3)
addi $t3, $t4,  19884
li $t5, 0x310300
sw $t5, 0($t3)
addi $t3, $t4,  19888
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  19892
sw $t5, 0($t3)
addi $t3, $t4,  19896
sw $t5, 0($t3)
addi $t3, $t4,  19900
sw $t5, 0($t3)
addi $t3, $t4,  19904
sw $t5, 0($t3)
addi $t3, $t4,  19908
sw $t5, 0($t3)
addi $t3, $t4,  19912
sw $t5, 0($t3)
addi $t3, $t4,  19916
sw $t5, 0($t3)
addi $t3, $t4,  19920
sw $t5, 0($t3)
addi $t3, $t4,  19924
sw $t5, 0($t3)
addi $t3, $t4,  19928
sw $t5, 0($t3)
addi $t3, $t4,  19932
sw $t5, 0($t3)
addi $t3, $t4,  19936
sw $t5, 0($t3)
addi $t3, $t4,  19940
sw $t5, 0($t3)
addi $t3, $t4,  19944
sw $t5, 0($t3)
addi $t3, $t4,  19948
sw $t5, 0($t3)
addi $t3, $t4,  19952
sw $t5, 0($t3)
addi $t3, $t4,  19956
sw $t5, 0($t3)
addi $t3, $t4,  19960
sw $t5, 0($t3)
addi $t3, $t4,  19964
sw $t5, 0($t3)
syscall #sleep for 30 ms
addi $t3, $t4,  19968
sw $t5, 0($t3)
addi $t3, $t4,  19972
sw $t5, 0($t3)
addi $t3, $t4,  19976
sw $t5, 0($t3)
addi $t3, $t4,  19980
sw $t5, 0($t3)
addi $t3, $t4,  19984
sw $t5, 0($t3)
addi $t3, $t4,  19988
sw $t5, 0($t3)
addi $t3, $t4,  19992
sw $t5, 0($t3)
addi $t3, $t4,  19996
sw $t5, 0($t3)
addi $t3, $t4,  20000
sw $t5, 0($t3)
addi $t3, $t4,  20004
sw $t5, 0($t3)
addi $t3, $t4,  20008
sw $t5, 0($t3)
addi $t3, $t4,  20012
sw $t5, 0($t3)
addi $t3, $t4,  20016
sw $t5, 0($t3)
addi $t3, $t4,  20020
sw $t5, 0($t3)
addi $t3, $t4,  20024
sw $t5, 0($t3)
addi $t3, $t4,  20028
sw $t5, 0($t3)
addi $t3, $t4,  20032
sw $t5, 0($t3)
addi $t3, $t4,  20036
sw $t5, 0($t3)
addi $t3, $t4,  20040
li $t5, 0x010100
sw $t5, 0($t3)
addi $t3, $t4,  20044
li $t5, 0x010102
sw $t5, 0($t3)
addi $t3, $t4,  20048
li $t5, 0xed6719
sw $t5, 0($t3)
addi $t3, $t4,  20052
li $t5, 0xfd6000
sw $t5, 0($t3)
addi $t3, $t4,  20056
sw $t5, 0($t3)
addi $t3, $t4,  20060
sw $t5, 0($t3)
addi $t3, $t4,  20064
sw $t5, 0($t3)
addi $t3, $t4,  20068
li $t5, 0xff5f00
sw $t5, 0($t3)
addi $t3, $t4,  20072
li $t5, 0x000100
sw $t5, 0($t3)
addi $t3, $t4,  20076
li $t5, 0x000005
sw $t5, 0($t3)
addi $t3, $t4,  20080
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  20084
sw $t5, 0($t3)
addi $t3, $t4,  20088
sw $t5, 0($t3)
addi $t3, $t4,  20092
sw $t5, 0($t3)
addi $t3, $t4,  20096
sw $t5, 0($t3)
addi $t3, $t4,  20100
li $t5, 0x040002
sw $t5, 0($t3)
addi $t3, $t4,  20104
li $t5, 0x2d0800
sw $t5, 0($t3)
addi $t3, $t4,  20108
li $t5, 0xfe5f01
sw $t5, 0($t3)
addi $t3, $t4,  20112
li $t5, 0xfe5e00
sw $t5, 0($t3)
addi $t3, $t4,  20116
sw $t5, 0($t3)
addi $t3, $t4,  20120
li $t5, 0xfe6000
sw $t5, 0($t3)
addi $t3, $t4,  20124
li $t5, 0xf96000
sw $t5, 0($t3)
addi $t3, $t4,  20128
li $t5, 0x4d190c
sw $t5, 0($t3)
addi $t3, $t4,  20132
li $t5, 0x000003
sw $t5, 0($t3)
addi $t3, $t4,  20136
li $t5, 0x070000
sw $t5, 0($t3)
addi $t3, $t4,  20140
li $t5, 0xff5d02
sw $t5, 0($t3)
addi $t3, $t4,  20144
li $t5, 0xfe5e00
sw $t5, 0($t3)
addi $t3, $t4,  20148
li $t5, 0xfd5d00
sw $t5, 0($t3)
addi $t3, $t4,  20152
li $t5, 0xf96000
sw $t5, 0($t3)
addi $t3, $t4,  20156
li $t5, 0xf95f05
sw $t5, 0($t3)
addi $t3, $t4,  20160
li $t5, 0x923e11
sw $t5, 0($t3)
addi $t3, $t4,  20164
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  20168
sw $t5, 0($t3)
addi $t3, $t4,  20172
sw $t5, 0($t3)
addi $t3, $t4,  20176
sw $t5, 0($t3)
addi $t3, $t4,  20180
sw $t5, 0($t3)
addi $t3, $t4,  20184
sw $t5, 0($t3)
addi $t3, $t4,  20188
sw $t5, 0($t3)
addi $t3, $t4,  20192
li $t5, 0x010001
sw $t5, 0($t3)
addi $t3, $t4,  20196
li $t5, 0xf75c03
sw $t5, 0($t3)
addi $t3, $t4,  20200
li $t5, 0xff5a00
sw $t5, 0($t3)
addi $t3, $t4,  20204
li $t5, 0xfd5b00
sw $t5, 0($t3)
addi $t3, $t4,  20208
sw $t5, 0($t3)
addi $t3, $t4,  20212
li $t5, 0xfb5c01
sw $t5, 0($t3)
addi $t3, $t4,  20216
li $t5, 0xf95b01
sw $t5, 0($t3)
addi $t3, $t4,  20220
li $t5, 0x050000
sw $t5, 0($t3)
addi $t3, $t4,  20224
sw $t5, 0($t3)
addi $t3, $t4,  20228
li $t5, 0xf95b01
sw $t5, 0($t3)
addi $t3, $t4,  20232
li $t5, 0xfb5a00
sw $t5, 0($t3)
addi $t3, $t4,  20236
li $t5, 0xff5a00
sw $t5, 0($t3)
addi $t3, $t4,  20240
sw $t5, 0($t3)
addi $t3, $t4,  20244
li $t5, 0xff5800
sw $t5, 0($t3)
addi $t3, $t4,  20248
li $t5, 0xfd5902
sw $t5, 0($t3)
addi $t3, $t4,  20252
li $t5, 0x000200
sw $t5, 0($t3)
addi $t3, $t4,  20256
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  20260
sw $t5, 0($t3)
addi $t3, $t4,  20264
sw $t5, 0($t3)
addi $t3, $t4,  20268
sw $t5, 0($t3)
addi $t3, $t4,  20272
sw $t5, 0($t3)
addi $t3, $t4,  20276
sw $t5, 0($t3)
addi $t3, $t4,  20280
sw $t5, 0($t3)
addi $t3, $t4,  20284
sw $t5, 0($t3)
addi $t3, $t4,  20288
sw $t5, 0($t3)
addi $t3, $t4,  20292
sw $t5, 0($t3)
addi $t3, $t4,  20296
sw $t5, 0($t3)
addi $t3, $t4,  20300
sw $t5, 0($t3)
addi $t3, $t4,  20304
sw $t5, 0($t3)
addi $t3, $t4,  20308
sw $t5, 0($t3)
addi $t3, $t4,  20312
sw $t5, 0($t3)
addi $t3, $t4,  20316
li $t5, 0xf05e0c
sw $t5, 0($t3)
addi $t3, $t4,  20320
li $t5, 0xff5400
sw $t5, 0($t3)
addi $t3, $t4,  20324
li $t5, 0xff5504
sw $t5, 0($t3)
addi $t3, $t4,  20328
li $t5, 0xff5600
sw $t5, 0($t3)
addi $t3, $t4,  20332
sw $t5, 0($t3)
addi $t3, $t4,  20336
li $t5, 0xfe5702
sw $t5, 0($t3)
addi $t3, $t4,  20340
li $t5, 0x080100
sw $t5, 0($t3)
addi $t3, $t4,  20344
li $t5, 0x010002
sw $t5, 0($t3)
addi $t3, $t4,  20348
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  20352
sw $t5, 0($t3)
addi $t3, $t4,  20356
sw $t5, 0($t3)
addi $t3, $t4,  20360
sw $t5, 0($t3)
addi $t3, $t4,  20364
sw $t5, 0($t3)
addi $t3, $t4,  20368
li $t5, 0x000101
sw $t5, 0($t3)
addi $t3, $t4,  20372
li $t5, 0x4e0a00
sw $t5, 0($t3)
addi $t3, $t4,  20376
li $t5, 0xfe5402
sw $t5, 0($t3)
addi $t3, $t4,  20380
li $t5, 0xfe5401
sw $t5, 0($t3)
addi $t3, $t4,  20384
li $t5, 0xfd5300
sw $t5, 0($t3)
addi $t3, $t4,  20388
li $t5, 0xfb5403
sw $t5, 0($t3)
addi $t3, $t4,  20392
li $t5, 0xfa5405
sw $t5, 0($t3)
addi $t3, $t4,  20396
li $t5, 0x330200
sw $t5, 0($t3)
addi $t3, $t4,  20400
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  20404
sw $t5, 0($t3)
addi $t3, $t4,  20408
sw $t5, 0($t3)
addi $t3, $t4,  20412
sw $t5, 0($t3)
addi $t3, $t4,  20416
sw $t5, 0($t3)
addi $t3, $t4,  20420
sw $t5, 0($t3)
addi $t3, $t4,  20424
sw $t5, 0($t3)
addi $t3, $t4,  20428
sw $t5, 0($t3)
addi $t3, $t4,  20432
sw $t5, 0($t3)
addi $t3, $t4,  20436
sw $t5, 0($t3)
addi $t3, $t4,  20440
sw $t5, 0($t3)
addi $t3, $t4,  20444
sw $t5, 0($t3)
addi $t3, $t4,  20448
sw $t5, 0($t3)
addi $t3, $t4,  20452
sw $t5, 0($t3)
addi $t3, $t4,  20456
sw $t5, 0($t3)
addi $t3, $t4,  20460
sw $t5, 0($t3)
addi $t3, $t4,  20464
sw $t5, 0($t3)
addi $t3, $t4,  20468
sw $t5, 0($t3)
addi $t3, $t4,  20472
sw $t5, 0($t3)
addi $t3, $t4,  20476
sw $t5, 0($t3)
syscall #sleep for 30 ms
addi $t3, $t4,  20480
sw $t5, 0($t3)
addi $t3, $t4,  20484
sw $t5, 0($t3)
addi $t3, $t4,  20488
sw $t5, 0($t3)
addi $t3, $t4,  20492
sw $t5, 0($t3)
addi $t3, $t4,  20496
sw $t5, 0($t3)
addi $t3, $t4,  20500
sw $t5, 0($t3)
addi $t3, $t4,  20504
sw $t5, 0($t3)
addi $t3, $t4,  20508
sw $t5, 0($t3)
addi $t3, $t4,  20512
sw $t5, 0($t3)
addi $t3, $t4,  20516
sw $t5, 0($t3)
addi $t3, $t4,  20520
sw $t5, 0($t3)
addi $t3, $t4,  20524
sw $t5, 0($t3)
addi $t3, $t4,  20528
sw $t5, 0($t3)
addi $t3, $t4,  20532
sw $t5, 0($t3)
addi $t3, $t4,  20536
sw $t5, 0($t3)
addi $t3, $t4,  20540
sw $t5, 0($t3)
addi $t3, $t4,  20544
sw $t5, 0($t3)
addi $t3, $t4,  20548
sw $t5, 0($t3)
addi $t3, $t4,  20552
li $t5, 0x010100
sw $t5, 0($t3)
addi $t3, $t4,  20556
li $t5, 0x010102
sw $t5, 0($t3)
addi $t3, $t4,  20560
li $t5, 0xea5c16
sw $t5, 0($t3)
addi $t3, $t4,  20564
li $t5, 0xff5201
sw $t5, 0($t3)
addi $t3, $t4,  20568
sw $t5, 0($t3)
addi $t3, $t4,  20572
sw $t5, 0($t3)
addi $t3, $t4,  20576
sw $t5, 0($t3)
addi $t3, $t4,  20580
li $t5, 0xff5200
sw $t5, 0($t3)
addi $t3, $t4,  20584
li $t5, 0x040000
sw $t5, 0($t3)
addi $t3, $t4,  20588
li $t5, 0x000005
sw $t5, 0($t3)
addi $t3, $t4,  20592
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  20596
sw $t5, 0($t3)
addi $t3, $t4,  20600
sw $t5, 0($t3)
addi $t3, $t4,  20604
sw $t5, 0($t3)
addi $t3, $t4,  20608
sw $t5, 0($t3)
addi $t3, $t4,  20612
li $t5, 0x010000
sw $t5, 0($t3)
addi $t3, $t4,  20616
li $t5, 0x2e0700
sw $t5, 0($t3)
addi $t3, $t4,  20620
li $t5, 0xfe5302
sw $t5, 0($t3)
addi $t3, $t4,  20624
li $t5, 0xfe5000
sw $t5, 0($t3)
addi $t3, $t4,  20628
sw $t5, 0($t3)
addi $t3, $t4,  20632
li $t5, 0xff4f00
sw $t5, 0($t3)
addi $t3, $t4,  20636
li $t5, 0xfb5100
sw $t5, 0($t3)
addi $t3, $t4,  20640
li $t5, 0x50160a
sw $t5, 0($t3)
addi $t3, $t4,  20644
li $t5, 0x000101
sw $t5, 0($t3)
addi $t3, $t4,  20648
li $t5, 0x0b0002
sw $t5, 0($t3)
addi $t3, $t4,  20652
li $t5, 0xff4f03
sw $t5, 0($t3)
addi $t3, $t4,  20656
li $t5, 0xfe4f00
sw $t5, 0($t3)
addi $t3, $t4,  20660
sw $t5, 0($t3)
addi $t3, $t4,  20664
li $t5, 0xfb5300
sw $t5, 0($t3)
addi $t3, $t4,  20668
li $t5, 0xfa5105
sw $t5, 0($t3)
addi $t3, $t4,  20672
li $t5, 0x953510
sw $t5, 0($t3)
addi $t3, $t4,  20676
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  20680
sw $t5, 0($t3)
addi $t3, $t4,  20684
sw $t5, 0($t3)
addi $t3, $t4,  20688
sw $t5, 0($t3)
addi $t3, $t4,  20692
sw $t5, 0($t3)
addi $t3, $t4,  20696
sw $t5, 0($t3)
addi $t3, $t4,  20700
sw $t5, 0($t3)
addi $t3, $t4,  20704
li $t5, 0x020002
sw $t5, 0($t3)
addi $t3, $t4,  20708
li $t5, 0xf25003
sw $t5, 0($t3)
addi $t3, $t4,  20712
li $t5, 0xff4c00
sw $t5, 0($t3)
addi $t3, $t4,  20716
li $t5, 0xfe4c00
sw $t5, 0($t3)
addi $t3, $t4,  20720
sw $t5, 0($t3)
addi $t3, $t4,  20724
li $t5, 0xfd4c03
sw $t5, 0($t3)
addi $t3, $t4,  20728
li $t5, 0xf94f00
sw $t5, 0($t3)
addi $t3, $t4,  20732
li $t5, 0x070000
sw $t5, 0($t3)
addi $t3, $t4,  20736
li $t5, 0x060000
sw $t5, 0($t3)
addi $t3, $t4,  20740
li $t5, 0xf84f01
sw $t5, 0($t3)
addi $t3, $t4,  20744
li $t5, 0xfc4b03
sw $t5, 0($t3)
addi $t3, $t4,  20748
li $t5, 0xff4c03
sw $t5, 0($t3)
addi $t3, $t4,  20752
li $t5, 0xff4b02
sw $t5, 0($t3)
addi $t3, $t4,  20756
li $t5, 0xff4a00
sw $t5, 0($t3)
addi $t3, $t4,  20760
li $t5, 0xfc4d02
sw $t5, 0($t3)
addi $t3, $t4,  20764
li $t5, 0x000200
sw $t5, 0($t3)
addi $t3, $t4,  20768
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  20772
sw $t5, 0($t3)
addi $t3, $t4,  20776
sw $t5, 0($t3)
addi $t3, $t4,  20780
sw $t5, 0($t3)
addi $t3, $t4,  20784
sw $t5, 0($t3)
addi $t3, $t4,  20788
sw $t5, 0($t3)
addi $t3, $t4,  20792
sw $t5, 0($t3)
addi $t3, $t4,  20796
sw $t5, 0($t3)
addi $t3, $t4,  20800
sw $t5, 0($t3)
addi $t3, $t4,  20804
sw $t5, 0($t3)
addi $t3, $t4,  20808
sw $t5, 0($t3)
addi $t3, $t4,  20812
sw $t5, 0($t3)
addi $t3, $t4,  20816
sw $t5, 0($t3)
addi $t3, $t4,  20820
sw $t5, 0($t3)
addi $t3, $t4,  20824
sw $t5, 0($t3)
addi $t3, $t4,  20828
li $t5, 0xf04f0a
sw $t5, 0($t3)
addi $t3, $t4,  20832
li $t5, 0xff4600
sw $t5, 0($t3)
addi $t3, $t4,  20836
li $t5, 0xfe4702
sw $t5, 0($t3)
addi $t3, $t4,  20840
li $t5, 0xfe4701
sw $t5, 0($t3)
addi $t3, $t4,  20844
sw $t5, 0($t3)
addi $t3, $t4,  20848
li $t5, 0xfc4800
sw $t5, 0($t3)
addi $t3, $t4,  20852
li $t5, 0x0a0000
sw $t5, 0($t3)
addi $t3, $t4,  20856
li $t5, 0x000100
sw $t5, 0($t3)
addi $t3, $t4,  20860
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  20864
sw $t5, 0($t3)
addi $t3, $t4,  20868
sw $t5, 0($t3)
addi $t3, $t4,  20872
sw $t5, 0($t3)
addi $t3, $t4,  20876
sw $t5, 0($t3)
addi $t3, $t4,  20880
li $t5, 0x000101
sw $t5, 0($t3)
addi $t3, $t4,  20884
li $t5, 0x4f0400
sw $t5, 0($t3)
addi $t3, $t4,  20888
li $t5, 0xff4403
sw $t5, 0($t3)
addi $t3, $t4,  20892
li $t5, 0xff4401
sw $t5, 0($t3)
addi $t3, $t4,  20896
sw $t5, 0($t3)
addi $t3, $t4,  20900
li $t5, 0xfb4605
sw $t5, 0($t3)
addi $t3, $t4,  20904
li $t5, 0xf84406
sw $t5, 0($t3)
addi $t3, $t4,  20908
li $t5, 0x360000
sw $t5, 0($t3)
addi $t3, $t4,  20912
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  20916
sw $t5, 0($t3)
addi $t3, $t4,  20920
sw $t5, 0($t3)
addi $t3, $t4,  20924
sw $t5, 0($t3)
addi $t3, $t4,  20928
sw $t5, 0($t3)
addi $t3, $t4,  20932
sw $t5, 0($t3)
addi $t3, $t4,  20936
sw $t5, 0($t3)
addi $t3, $t4,  20940
sw $t5, 0($t3)
addi $t3, $t4,  20944
sw $t5, 0($t3)
addi $t3, $t4,  20948
sw $t5, 0($t3)
addi $t3, $t4,  20952
sw $t5, 0($t3)
addi $t3, $t4,  20956
sw $t5, 0($t3)
addi $t3, $t4,  20960
sw $t5, 0($t3)
addi $t3, $t4,  20964
sw $t5, 0($t3)
addi $t3, $t4,  20968
sw $t5, 0($t3)
addi $t3, $t4,  20972
sw $t5, 0($t3)
addi $t3, $t4,  20976
sw $t5, 0($t3)
addi $t3, $t4,  20980
sw $t5, 0($t3)
addi $t3, $t4,  20984
sw $t5, 0($t3)
addi $t3, $t4,  20988
sw $t5, 0($t3)
syscall #sleep for 30 ms
addi $t3, $t4,  20992
sw $t5, 0($t3)
addi $t3, $t4,  20996
sw $t5, 0($t3)
addi $t3, $t4,  21000
sw $t5, 0($t3)
addi $t3, $t4,  21004
sw $t5, 0($t3)
addi $t3, $t4,  21008
sw $t5, 0($t3)
addi $t3, $t4,  21012
sw $t5, 0($t3)
addi $t3, $t4,  21016
sw $t5, 0($t3)
addi $t3, $t4,  21020
sw $t5, 0($t3)
addi $t3, $t4,  21024
sw $t5, 0($t3)
addi $t3, $t4,  21028
sw $t5, 0($t3)
addi $t3, $t4,  21032
sw $t5, 0($t3)
addi $t3, $t4,  21036
sw $t5, 0($t3)
addi $t3, $t4,  21040
sw $t5, 0($t3)
addi $t3, $t4,  21044
sw $t5, 0($t3)
addi $t3, $t4,  21048
sw $t5, 0($t3)
addi $t3, $t4,  21052
sw $t5, 0($t3)
addi $t3, $t4,  21056
sw $t5, 0($t3)
addi $t3, $t4,  21060
sw $t5, 0($t3)
addi $t3, $t4,  21064
li $t5, 0x010100
sw $t5, 0($t3)
addi $t3, $t4,  21068
li $t5, 0x020103
sw $t5, 0($t3)
addi $t3, $t4,  21072
li $t5, 0xe94e16
sw $t5, 0($t3)
addi $t3, $t4,  21076
li $t5, 0xfe4500
sw $t5, 0($t3)
addi $t3, $t4,  21080
li $t5, 0xff4601
sw $t5, 0($t3)
addi $t3, $t4,  21084
li $t5, 0xff4400
sw $t5, 0($t3)
addi $t3, $t4,  21088
sw $t5, 0($t3)
addi $t3, $t4,  21092
li $t5, 0xff4500
sw $t5, 0($t3)
addi $t3, $t4,  21096
li $t5, 0x060203
sw $t5, 0($t3)
addi $t3, $t4,  21100
li $t5, 0x000103
sw $t5, 0($t3)
addi $t3, $t4,  21104
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  21108
sw $t5, 0($t3)
addi $t3, $t4,  21112
sw $t5, 0($t3)
addi $t3, $t4,  21116
sw $t5, 0($t3)
addi $t3, $t4,  21120
sw $t5, 0($t3)
addi $t3, $t4,  21124
li $t5, 0x050000
sw $t5, 0($t3)
addi $t3, $t4,  21128
li $t5, 0x310500
sw $t5, 0($t3)
addi $t3, $t4,  21132
li $t5, 0xfd4501
sw $t5, 0($t3)
addi $t3, $t4,  21136
li $t5, 0xff4202
sw $t5, 0($t3)
addi $t3, $t4,  21140
sw $t5, 0($t3)
addi $t3, $t4,  21144
li $t5, 0xfe4301
sw $t5, 0($t3)
addi $t3, $t4,  21148
li $t5, 0xff4300
sw $t5, 0($t3)
addi $t3, $t4,  21152
li $t5, 0x4d1409
sw $t5, 0($t3)
addi $t3, $t4,  21156
li $t5, 0x000200
sw $t5, 0($t3)
addi $t3, $t4,  21160
li $t5, 0x0d0003
sw $t5, 0($t3)
addi $t3, $t4,  21164
li $t5, 0xff4200
sw $t5, 0($t3)
addi $t3, $t4,  21168
li $t5, 0xfe4100
sw $t5, 0($t3)
addi $t3, $t4,  21172
sw $t5, 0($t3)
addi $t3, $t4,  21176
li $t5, 0xfd4200
sw $t5, 0($t3)
addi $t3, $t4,  21180
li $t5, 0xfc4100
sw $t5, 0($t3)
addi $t3, $t4,  21184
li $t5, 0xfc4201
sw $t5, 0($t3)
addi $t3, $t4,  21188
li $t5, 0xf94005
sw $t5, 0($t3)
addi $t3, $t4,  21192
li $t5, 0xf94106
sw $t5, 0($t3)
addi $t3, $t4,  21196
li $t5, 0x681c08
sw $t5, 0($t3)
addi $t3, $t4,  21200
li $t5, 0x050101
sw $t5, 0($t3)
addi $t3, $t4,  21204
li $t5, 0x020000
sw $t5, 0($t3)
addi $t3, $t4,  21208
li $t5, 0xec5012
sw $t5, 0($t3)
addi $t3, $t4,  21212
li $t5, 0xff3e04
sw $t5, 0($t3)
addi $t3, $t4,  21216
li $t5, 0xf04617
sw $t5, 0($t3)
addi $t3, $t4,  21220
li $t5, 0xfe3e01
sw $t5, 0($t3)
addi $t3, $t4,  21224
li $t5, 0xf04502
sw $t5, 0($t3)
addi $t3, $t4,  21228
li $t5, 0xfe3e00
sw $t5, 0($t3)
addi $t3, $t4,  21232
sw $t5, 0($t3)
addi $t3, $t4,  21236
li $t5, 0xff4000
sw $t5, 0($t3)
addi $t3, $t4,  21240
li $t5, 0xfd3c01
sw $t5, 0($t3)
addi $t3, $t4,  21244
li $t5, 0x010007
sw $t5, 0($t3)
addi $t3, $t4,  21248
li $t5, 0x000105
sw $t5, 0($t3)
addi $t3, $t4,  21252
li $t5, 0xfe3d01
sw $t5, 0($t3)
addi $t3, $t4,  21256
li $t5, 0xff3c00
sw $t5, 0($t3)
addi $t3, $t4,  21260
sw $t5, 0($t3)
addi $t3, $t4,  21264
li $t5, 0xfe3c00
sw $t5, 0($t3)
addi $t3, $t4,  21268
li $t5, 0xff3a00
sw $t5, 0($t3)
addi $t3, $t4,  21272
li $t5, 0xfe3803
sw $t5, 0($t3)
addi $t3, $t4,  21276
li $t5, 0xf33b07
sw $t5, 0($t3)
addi $t3, $t4,  21280
li $t5, 0xf93e08
sw $t5, 0($t3)
addi $t3, $t4,  21284
li $t5, 0xf83d08
sw $t5, 0($t3)
addi $t3, $t4,  21288
li $t5, 0xff3808
sw $t5, 0($t3)
addi $t3, $t4,  21292
li $t5, 0xff3908
sw $t5, 0($t3)
addi $t3, $t4,  21296
sw $t5, 0($t3)
addi $t3, $t4,  21300
li $t5, 0xfc3606
sw $t5, 0($t3)
addi $t3, $t4,  21304
li $t5, 0xff3808
sw $t5, 0($t3)
addi $t3, $t4,  21308
li $t5, 0xa03019
sw $t5, 0($t3)
addi $t3, $t4,  21312
li $t5, 0x000100
sw $t5, 0($t3)
addi $t3, $t4,  21316
li $t5, 0x000104
sw $t5, 0($t3)
addi $t3, $t4,  21320
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  21324
sw $t5, 0($t3)
addi $t3, $t4,  21328
sw $t5, 0($t3)
addi $t3, $t4,  21332
sw $t5, 0($t3)
addi $t3, $t4,  21336
sw $t5, 0($t3)
addi $t3, $t4,  21340
li $t5, 0xeb400c
sw $t5, 0($t3)
addi $t3, $t4,  21344
li $t5, 0xff3301
sw $t5, 0($t3)
addi $t3, $t4,  21348
li $t5, 0xfc3800
sw $t5, 0($t3)
addi $t3, $t4,  21352
li $t5, 0xfd3800
sw $t5, 0($t3)
addi $t3, $t4,  21356
sw $t5, 0($t3)
addi $t3, $t4,  21360
li $t5, 0xfc3800
sw $t5, 0($t3)
addi $t3, $t4,  21364
li $t5, 0x020006
sw $t5, 0($t3)
addi $t3, $t4,  21368
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  21372
sw $t5, 0($t3)
addi $t3, $t4,  21376
sw $t5, 0($t3)
addi $t3, $t4,  21380
li $t5, 0x000300
sw $t5, 0($t3)
addi $t3, $t4,  21384
li $t5, 0x060100
sw $t5, 0($t3)
addi $t3, $t4,  21388
li $t5, 0xef3807
sw $t5, 0($t3)
addi $t3, $t4,  21392
li $t5, 0xff310c
sw $t5, 0($t3)
addi $t3, $t4,  21396
li $t5, 0xff3107
sw $t5, 0($t3)
addi $t3, $t4,  21400
li $t5, 0xff3300
sw $t5, 0($t3)
addi $t3, $t4,  21404
li $t5, 0xff3400
sw $t5, 0($t3)
addi $t3, $t4,  21408
sw $t5, 0($t3)
addi $t3, $t4,  21412
li $t5, 0xfe3500
sw $t5, 0($t3)
addi $t3, $t4,  21416
li $t5, 0xff3502
sw $t5, 0($t3)
addi $t3, $t4,  21420
li $t5, 0x340200
sw $t5, 0($t3)
addi $t3, $t4,  21424
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  21428
sw $t5, 0($t3)
addi $t3, $t4,  21432
sw $t5, 0($t3)
addi $t3, $t4,  21436
sw $t5, 0($t3)
addi $t3, $t4,  21440
sw $t5, 0($t3)
addi $t3, $t4,  21444
sw $t5, 0($t3)
addi $t3, $t4,  21448
sw $t5, 0($t3)
addi $t3, $t4,  21452
sw $t5, 0($t3)
addi $t3, $t4,  21456
sw $t5, 0($t3)
addi $t3, $t4,  21460
sw $t5, 0($t3)
addi $t3, $t4,  21464
sw $t5, 0($t3)
addi $t3, $t4,  21468
sw $t5, 0($t3)
addi $t3, $t4,  21472
sw $t5, 0($t3)
addi $t3, $t4,  21476
sw $t5, 0($t3)
addi $t3, $t4,  21480
sw $t5, 0($t3)
addi $t3, $t4,  21484
sw $t5, 0($t3)
addi $t3, $t4,  21488
sw $t5, 0($t3)
addi $t3, $t4,  21492
sw $t5, 0($t3)
addi $t3, $t4,  21496
sw $t5, 0($t3)
addi $t3, $t4,  21500
sw $t5, 0($t3)
syscall #sleep for 30 ms
addi $t3, $t4,  21504
sw $t5, 0($t3)
addi $t3, $t4,  21508
sw $t5, 0($t3)
addi $t3, $t4,  21512
sw $t5, 0($t3)
addi $t3, $t4,  21516
sw $t5, 0($t3)
addi $t3, $t4,  21520
sw $t5, 0($t3)
addi $t3, $t4,  21524
sw $t5, 0($t3)
addi $t3, $t4,  21528
sw $t5, 0($t3)
addi $t3, $t4,  21532
sw $t5, 0($t3)
addi $t3, $t4,  21536
sw $t5, 0($t3)
addi $t3, $t4,  21540
sw $t5, 0($t3)
addi $t3, $t4,  21544
sw $t5, 0($t3)
addi $t3, $t4,  21548
sw $t5, 0($t3)
addi $t3, $t4,  21552
sw $t5, 0($t3)
addi $t3, $t4,  21556
sw $t5, 0($t3)
addi $t3, $t4,  21560
sw $t5, 0($t3)
addi $t3, $t4,  21564
sw $t5, 0($t3)
addi $t3, $t4,  21568
sw $t5, 0($t3)
addi $t3, $t4,  21572
sw $t5, 0($t3)
addi $t3, $t4,  21576
li $t5, 0x010100
sw $t5, 0($t3)
addi $t3, $t4,  21580
li $t5, 0x020102
sw $t5, 0($t3)
addi $t3, $t4,  21584
li $t5, 0xe74113
sw $t5, 0($t3)
addi $t3, $t4,  21588
li $t5, 0xff3403
sw $t5, 0($t3)
addi $t3, $t4,  21592
sw $t5, 0($t3)
addi $t3, $t4,  21596
li $t5, 0xff3303
sw $t5, 0($t3)
addi $t3, $t4,  21600
sw $t5, 0($t3)
addi $t3, $t4,  21604
li $t5, 0xff3401
sw $t5, 0($t3)
addi $t3, $t4,  21608
li $t5, 0x08010a
sw $t5, 0($t3)
addi $t3, $t4,  21612
li $t5, 0x000103
sw $t5, 0($t3)
addi $t3, $t4,  21616
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  21620
sw $t5, 0($t3)
addi $t3, $t4,  21624
sw $t5, 0($t3)
addi $t3, $t4,  21628
sw $t5, 0($t3)
addi $t3, $t4,  21632
sw $t5, 0($t3)
addi $t3, $t4,  21636
li $t5, 0x020000
sw $t5, 0($t3)
addi $t3, $t4,  21640
li $t5, 0x350400
sw $t5, 0($t3)
addi $t3, $t4,  21644
li $t5, 0xff2e00
sw $t5, 0($t3)
addi $t3, $t4,  21648
li $t5, 0xff3002
sw $t5, 0($t3)
addi $t3, $t4,  21652
li $t5, 0xff2f01
sw $t5, 0($t3)
addi $t3, $t4,  21656
li $t5, 0xfa3100
sw $t5, 0($t3)
addi $t3, $t4,  21660
li $t5, 0xff2c00
sw $t5, 0($t3)
addi $t3, $t4,  21664
li $t5, 0x4f120a
sw $t5, 0($t3)
addi $t3, $t4,  21668
li $t5, 0x000100
sw $t5, 0($t3)
addi $t3, $t4,  21672
li $t5, 0x0c0001
sw $t5, 0($t3)
addi $t3, $t4,  21676
li $t5, 0xff2d02
sw $t5, 0($t3)
addi $t3, $t4,  21680
li $t5, 0xff2e02
sw $t5, 0($t3)
addi $t3, $t4,  21684
sw $t5, 0($t3)
addi $t3, $t4,  21688
li $t5, 0xff2e03
sw $t5, 0($t3)
addi $t3, $t4,  21692
li $t5, 0xff2d02
sw $t5, 0($t3)
addi $t3, $t4,  21696
li $t5, 0xff2e02
sw $t5, 0($t3)
addi $t3, $t4,  21700
li $t5, 0xfd2e00
sw $t5, 0($t3)
addi $t3, $t4,  21704
li $t5, 0xfc2d00
sw $t5, 0($t3)
addi $t3, $t4,  21708
li $t5, 0x701605
sw $t5, 0($t3)
addi $t3, $t4,  21712
li $t5, 0x010001
sw $t5, 0($t3)
addi $t3, $t4,  21716
li $t5, 0x040000
sw $t5, 0($t3)
addi $t3, $t4,  21720
li $t5, 0xed350a
sw $t5, 0($t3)
addi $t3, $t4,  21724
li $t5, 0xf53300
sw $t5, 0($t3)
addi $t3, $t4,  21728
li $t5, 0xff2509
sw $t5, 0($t3)
addi $t3, $t4,  21732
li $t5, 0xf92c04
sw $t5, 0($t3)
addi $t3, $t4,  21736
li $t5, 0xfc2b00
sw $t5, 0($t3)
addi $t3, $t4,  21740
li $t5, 0xff2901
sw $t5, 0($t3)
addi $t3, $t4,  21744
sw $t5, 0($t3)
addi $t3, $t4,  21748
li $t5, 0xff2900
sw $t5, 0($t3)
addi $t3, $t4,  21752
li $t5, 0xfe2b01
sw $t5, 0($t3)
addi $t3, $t4,  21756
li $t5, 0x000008
sw $t5, 0($t3)
addi $t3, $t4,  21760
sw $t5, 0($t3)
addi $t3, $t4,  21764
li $t5, 0xfe2a00
sw $t5, 0($t3)
addi $t3, $t4,  21768
li $t5, 0xff2602
sw $t5, 0($t3)
addi $t3, $t4,  21772
li $t5, 0xff2702
sw $t5, 0($t3)
addi $t3, $t4,  21776
li $t5, 0xff2501
sw $t5, 0($t3)
addi $t3, $t4,  21780
li $t5, 0xfc2801
sw $t5, 0($t3)
addi $t3, $t4,  21784
li $t5, 0xfa2b01
sw $t5, 0($t3)
addi $t3, $t4,  21788
li $t5, 0xff2800
sw $t5, 0($t3)
addi $t3, $t4,  21792
li $t5, 0xfa2806
sw $t5, 0($t3)
addi $t3, $t4,  21796
sw $t5, 0($t3)
addi $t3, $t4,  21800
li $t5, 0xfe2505
sw $t5, 0($t3)
addi $t3, $t4,  21804
sw $t5, 0($t3)
addi $t3, $t4,  21808
sw $t5, 0($t3)
addi $t3, $t4,  21812
li $t5, 0xfe2304
sw $t5, 0($t3)
addi $t3, $t4,  21816
sw $t5, 0($t3)
addi $t3, $t4,  21820
li $t5, 0xa92618
sw $t5, 0($t3)
addi $t3, $t4,  21824
li $t5, 0x000200
sw $t5, 0($t3)
addi $t3, $t4,  21828
li $t5, 0x000104
sw $t5, 0($t3)
addi $t3, $t4,  21832
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  21836
sw $t5, 0($t3)
addi $t3, $t4,  21840
sw $t5, 0($t3)
addi $t3, $t4,  21844
sw $t5, 0($t3)
addi $t3, $t4,  21848
sw $t5, 0($t3)
addi $t3, $t4,  21852
li $t5, 0xec290c
sw $t5, 0($t3)
addi $t3, $t4,  21856
li $t5, 0xff1d01
sw $t5, 0($t3)
addi $t3, $t4,  21860
li $t5, 0xfe2100
sw $t5, 0($t3)
addi $t3, $t4,  21864
li $t5, 0xff1e02
sw $t5, 0($t3)
addi $t3, $t4,  21868
sw $t5, 0($t3)
addi $t3, $t4,  21872
li $t5, 0xfe1d02
sw $t5, 0($t3)
addi $t3, $t4,  21876
li $t5, 0x020006
sw $t5, 0($t3)
addi $t3, $t4,  21880
li $t5, 0x010005
sw $t5, 0($t3)
addi $t3, $t4,  21884
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  21888
sw $t5, 0($t3)
addi $t3, $t4,  21892
li $t5, 0x020009
sw $t5, 0($t3)
addi $t3, $t4,  21896
li $t5, 0x080004
sw $t5, 0($t3)
addi $t3, $t4,  21900
li $t5, 0xf82202
sw $t5, 0($t3)
addi $t3, $t4,  21904
li $t5, 0xfe1c02
sw $t5, 0($t3)
addi $t3, $t4,  21908
li $t5, 0xff1804
sw $t5, 0($t3)
addi $t3, $t4,  21912
li $t5, 0xff1903
sw $t5, 0($t3)
addi $t3, $t4,  21916
li $t5, 0xff1a01
sw $t5, 0($t3)
addi $t3, $t4,  21920
sw $t5, 0($t3)
addi $t3, $t4,  21924
li $t5, 0xff1a00
sw $t5, 0($t3)
addi $t3, $t4,  21928
li $t5, 0xfb1600
sw $t5, 0($t3)
addi $t3, $t4,  21932
li $t5, 0x3c0000
sw $t5, 0($t3)
addi $t3, $t4,  21936
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  21940
sw $t5, 0($t3)
addi $t3, $t4,  21944
sw $t5, 0($t3)
addi $t3, $t4,  21948
sw $t5, 0($t3)
addi $t3, $t4,  21952
sw $t5, 0($t3)
addi $t3, $t4,  21956
sw $t5, 0($t3)
addi $t3, $t4,  21960
sw $t5, 0($t3)
addi $t3, $t4,  21964
sw $t5, 0($t3)
addi $t3, $t4,  21968
sw $t5, 0($t3)
addi $t3, $t4,  21972
sw $t5, 0($t3)
addi $t3, $t4,  21976
sw $t5, 0($t3)
addi $t3, $t4,  21980
sw $t5, 0($t3)
addi $t3, $t4,  21984
sw $t5, 0($t3)
addi $t3, $t4,  21988
sw $t5, 0($t3)
addi $t3, $t4,  21992
sw $t5, 0($t3)
addi $t3, $t4,  21996
sw $t5, 0($t3)
addi $t3, $t4,  22000
sw $t5, 0($t3)
addi $t3, $t4,  22004
sw $t5, 0($t3)
addi $t3, $t4,  22008
sw $t5, 0($t3)
addi $t3, $t4,  22012
sw $t5, 0($t3)
syscall #sleep for 30 ms
addi $t3, $t4,  22016
sw $t5, 0($t3)
addi $t3, $t4,  22020
sw $t5, 0($t3)
addi $t3, $t4,  22024
sw $t5, 0($t3)
addi $t3, $t4,  22028
sw $t5, 0($t3)
addi $t3, $t4,  22032
sw $t5, 0($t3)
addi $t3, $t4,  22036
sw $t5, 0($t3)
addi $t3, $t4,  22040
sw $t5, 0($t3)
addi $t3, $t4,  22044
sw $t5, 0($t3)
addi $t3, $t4,  22048
sw $t5, 0($t3)
addi $t3, $t4,  22052
sw $t5, 0($t3)
addi $t3, $t4,  22056
sw $t5, 0($t3)
addi $t3, $t4,  22060
sw $t5, 0($t3)
addi $t3, $t4,  22064
sw $t5, 0($t3)
addi $t3, $t4,  22068
sw $t5, 0($t3)
addi $t3, $t4,  22072
sw $t5, 0($t3)
addi $t3, $t4,  22076
sw $t5, 0($t3)
addi $t3, $t4,  22080
sw $t5, 0($t3)
addi $t3, $t4,  22084
sw $t5, 0($t3)
addi $t3, $t4,  22088
li $t5, 0x010009
sw $t5, 0($t3)
addi $t3, $t4,  22092
li $t5, 0x010305
sw $t5, 0($t3)
addi $t3, $t4,  22096
li $t5, 0xe62818
sw $t5, 0($t3)
addi $t3, $t4,  22100
li $t5, 0xff1f03
sw $t5, 0($t3)
addi $t3, $t4,  22104
sw $t5, 0($t3)
addi $t3, $t4,  22108
li $t5, 0xff1e02
sw $t5, 0($t3)
addi $t3, $t4,  22112
sw $t5, 0($t3)
addi $t3, $t4,  22116
li $t5, 0xff1e03
sw $t5, 0($t3)
addi $t3, $t4,  22120
li $t5, 0x040000
sw $t5, 0($t3)
addi $t3, $t4,  22124
li $t5, 0x010100
sw $t5, 0($t3)
addi $t3, $t4,  22128
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  22132
sw $t5, 0($t3)
addi $t3, $t4,  22136
sw $t5, 0($t3)
addi $t3, $t4,  22140
sw $t5, 0($t3)
addi $t3, $t4,  22144
sw $t5, 0($t3)
addi $t3, $t4,  22148
li $t5, 0x000003
sw $t5, 0($t3)
addi $t3, $t4,  22152
li $t5, 0x280301
sw $t5, 0($t3)
addi $t3, $t4,  22156
li $t5, 0xfb1907
sw $t5, 0($t3)
addi $t3, $t4,  22160
li $t5, 0xff1901
sw $t5, 0($t3)
addi $t3, $t4,  22164
sw $t5, 0($t3)
addi $t3, $t4,  22168
li $t5, 0xff1a00
sw $t5, 0($t3)
addi $t3, $t4,  22172
li $t5, 0xff1601
sw $t5, 0($t3)
addi $t3, $t4,  22176
li $t5, 0x520b07
sw $t5, 0($t3)
addi $t3, $t4,  22180
li $t5, 0x030001
sw $t5, 0($t3)
addi $t3, $t4,  22184
li $t5, 0x0e0000
sw $t5, 0($t3)
addi $t3, $t4,  22188
li $t5, 0xf41c0b
sw $t5, 0($t3)
addi $t3, $t4,  22192
li $t5, 0xe32308
sw $t5, 0($t3)
addi $t3, $t4,  22196
li $t5, 0xf31a09
sw $t5, 0($t3)
addi $t3, $t4,  22200
li $t5, 0xff1401
sw $t5, 0($t3)
addi $t3, $t4,  22204
li $t5, 0xff1502
sw $t5, 0($t3)
addi $t3, $t4,  22208
sw $t5, 0($t3)
addi $t3, $t4,  22212
li $t5, 0xff1402
sw $t5, 0($t3)
addi $t3, $t4,  22216
li $t5, 0xff1301
sw $t5, 0($t3)
addi $t3, $t4,  22220
li $t5, 0x830807
sw $t5, 0($t3)
addi $t3, $t4,  22224
li $t5, 0x240000
sw $t5, 0($t3)
addi $t3, $t4,  22228
li $t5, 0x280000
sw $t5, 0($t3)
addi $t3, $t4,  22232
li $t5, 0xe11d11
sw $t5, 0($t3)
addi $t3, $t4,  22236
li $t5, 0xfe1300
sw $t5, 0($t3)
addi $t3, $t4,  22240
li $t5, 0xfe1001
sw $t5, 0($t3)
addi $t3, $t4,  22244
li $t5, 0xfe1101
sw $t5, 0($t3)
addi $t3, $t4,  22248
sw $t5, 0($t3)
addi $t3, $t4,  22252
li $t5, 0xfa1300
sw $t5, 0($t3)
addi $t3, $t4,  22256
li $t5, 0xd41d19
sw $t5, 0($t3)
addi $t3, $t4,  22260
li $t5, 0xd2210a
sw $t5, 0($t3)
addi $t3, $t4,  22264
li $t5, 0xd11f1a
sw $t5, 0($t3)
addi $t3, $t4,  22268
li $t5, 0x050001
sw $t5, 0($t3)
addi $t3, $t4,  22272
li $t5, 0x000105
sw $t5, 0($t3)
addi $t3, $t4,  22276
li $t5, 0xfe0c03
sw $t5, 0($t3)
addi $t3, $t4,  22280
li $t5, 0xff0c00
sw $t5, 0($t3)
addi $t3, $t4,  22284
li $t5, 0xff0d01
sw $t5, 0($t3)
addi $t3, $t4,  22288
li $t5, 0xff0c01
sw $t5, 0($t3)
addi $t3, $t4,  22292
li $t5, 0xff0a01
sw $t5, 0($t3)
addi $t3, $t4,  22296
li $t5, 0xfe0702
sw $t5, 0($t3)
addi $t3, $t4,  22300
li $t5, 0xda1b1b
sw $t5, 0($t3)
addi $t3, $t4,  22304
li $t5, 0xe11811
sw $t5, 0($t3)
addi $t3, $t4,  22308
sw $t5, 0($t3)
addi $t3, $t4,  22312
li $t5, 0xe41711
sw $t5, 0($t3)
addi $t3, $t4,  22316
li $t5, 0xe31611
sw $t5, 0($t3)
addi $t3, $t4,  22320
li $t5, 0xe31610
sw $t5, 0($t3)
addi $t3, $t4,  22324
li $t5, 0xe2150f
sw $t5, 0($t3)
addi $t3, $t4,  22328
sw $t5, 0($t3)
addi $t3, $t4,  22332
li $t5, 0x8b2223
sw $t5, 0($t3)
addi $t3, $t4,  22336
li $t5, 0x000702
sw $t5, 0($t3)
addi $t3, $t4,  22340
li $t5, 0x010001
sw $t5, 0($t3)
addi $t3, $t4,  22344
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  22348
sw $t5, 0($t3)
addi $t3, $t4,  22352
sw $t5, 0($t3)
addi $t3, $t4,  22356
sw $t5, 0($t3)
addi $t3, $t4,  22360
sw $t5, 0($t3)
addi $t3, $t4,  22364
li $t5, 0xec0a0d
sw $t5, 0($t3)
addi $t3, $t4,  22368
li $t5, 0xff0208
sw $t5, 0($t3)
addi $t3, $t4,  22372
li $t5, 0xfc030a
sw $t5, 0($t3)
addi $t3, $t4,  22376
li $t5, 0xff0202
sw $t5, 0($t3)
addi $t3, $t4,  22380
li $t5, 0xff0101
sw $t5, 0($t3)
addi $t3, $t4,  22384
li $t5, 0xf70702
sw $t5, 0($t3)
addi $t3, $t4,  22388
li $t5, 0x450000
sw $t5, 0($t3)
addi $t3, $t4,  22392
li $t5, 0x330001
sw $t5, 0($t3)
addi $t3, $t4,  22396
li $t5, 0x380000
sw $t5, 0($t3)
addi $t3, $t4,  22400
sw $t5, 0($t3)
addi $t3, $t4,  22404
li $t5, 0x3c0000
sw $t5, 0($t3)
addi $t3, $t4,  22408
li $t5, 0x4f0000
sw $t5, 0($t3)
addi $t3, $t4,  22412
li $t5, 0xfb0200
sw $t5, 0($t3)
addi $t3, $t4,  22416
li $t5, 0xf20701
sw $t5, 0($t3)
addi $t3, $t4,  22420
li $t5, 0xf51009
sw $t5, 0($t3)
addi $t3, $t4,  22424
li $t5, 0xcb1211
sw $t5, 0($t3)
addi $t3, $t4,  22428
li $t5, 0xc91310
sw $t5, 0($t3)
addi $t3, $t4,  22432
li $t5, 0xc9130f
sw $t5, 0($t3)
addi $t3, $t4,  22436
li $t5, 0xc7140e
sw $t5, 0($t3)
addi $t3, $t4,  22440
li $t5, 0xc80e13
sw $t5, 0($t3)
addi $t3, $t4,  22444
li $t5, 0x400201
sw $t5, 0($t3)
addi $t3, $t4,  22448
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  22452
sw $t5, 0($t3)
addi $t3, $t4,  22456
sw $t5, 0($t3)
addi $t3, $t4,  22460
sw $t5, 0($t3)
addi $t3, $t4,  22464
sw $t5, 0($t3)
addi $t3, $t4,  22468
sw $t5, 0($t3)
addi $t3, $t4,  22472
sw $t5, 0($t3)
addi $t3, $t4,  22476
sw $t5, 0($t3)
addi $t3, $t4,  22480
sw $t5, 0($t3)
addi $t3, $t4,  22484
sw $t5, 0($t3)
addi $t3, $t4,  22488
sw $t5, 0($t3)
addi $t3, $t4,  22492
sw $t5, 0($t3)
addi $t3, $t4,  22496
sw $t5, 0($t3)
addi $t3, $t4,  22500
sw $t5, 0($t3)
addi $t3, $t4,  22504
sw $t5, 0($t3)
addi $t3, $t4,  22508
sw $t5, 0($t3)
addi $t3, $t4,  22512
sw $t5, 0($t3)
addi $t3, $t4,  22516
sw $t5, 0($t3)
addi $t3, $t4,  22520
sw $t5, 0($t3)
addi $t3, $t4,  22524
sw $t5, 0($t3)
syscall #sleep for 30 ms
addi $t3, $t4,  22528
sw $t5, 0($t3)
addi $t3, $t4,  22532
sw $t5, 0($t3)
addi $t3, $t4,  22536
sw $t5, 0($t3)
addi $t3, $t4,  22540
sw $t5, 0($t3)
addi $t3, $t4,  22544
sw $t5, 0($t3)
addi $t3, $t4,  22548
sw $t5, 0($t3)
addi $t3, $t4,  22552
sw $t5, 0($t3)
addi $t3, $t4,  22556
sw $t5, 0($t3)
addi $t3, $t4,  22560
sw $t5, 0($t3)
addi $t3, $t4,  22564
sw $t5, 0($t3)
addi $t3, $t4,  22568
sw $t5, 0($t3)
addi $t3, $t4,  22572
sw $t5, 0($t3)
addi $t3, $t4,  22576
sw $t5, 0($t3)
addi $t3, $t4,  22580
sw $t5, 0($t3)
addi $t3, $t4,  22584
sw $t5, 0($t3)
addi $t3, $t4,  22588
sw $t5, 0($t3)
addi $t3, $t4,  22592
sw $t5, 0($t3)
addi $t3, $t4,  22596
sw $t5, 0($t3)
addi $t3, $t4,  22600
li $t5, 0x010009
sw $t5, 0($t3)
addi $t3, $t4,  22604
li $t5, 0x000103
sw $t5, 0($t3)
addi $t3, $t4,  22608
li $t5, 0xdc100e
sw $t5, 0($t3)
addi $t3, $t4,  22612
li $t5, 0xfc0200
sw $t5, 0($t3)
addi $t3, $t4,  22616
sw $t5, 0($t3)
addi $t3, $t4,  22620
sw $t5, 0($t3)
addi $t3, $t4,  22624
sw $t5, 0($t3)
addi $t3, $t4,  22628
li $t5, 0xfb0200
sw $t5, 0($t3)
addi $t3, $t4,  22632
li $t5, 0x060001
sw $t5, 0($t3)
addi $t3, $t4,  22636
li $t5, 0x010100
sw $t5, 0($t3)
addi $t3, $t4,  22640
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  22644
sw $t5, 0($t3)
addi $t3, $t4,  22648
sw $t5, 0($t3)
addi $t3, $t4,  22652
sw $t5, 0($t3)
addi $t3, $t4,  22656
sw $t5, 0($t3)
addi $t3, $t4,  22660
li $t5, 0x000200
sw $t5, 0($t3)
addi $t3, $t4,  22664
li $t5, 0x2f0100
sw $t5, 0($t3)
addi $t3, $t4,  22668
li $t5, 0xfc0100
sw $t5, 0($t3)
addi $t3, $t4,  22672
li $t5, 0xfd0001
sw $t5, 0($t3)
addi $t3, $t4,  22676
sw $t5, 0($t3)
addi $t3, $t4,  22680
li $t5, 0xfd0100
sw $t5, 0($t3)
addi $t3, $t4,  22684
sw $t5, 0($t3)
addi $t3, $t4,  22688
li $t5, 0x540707
sw $t5, 0($t3)
addi $t3, $t4,  22692
li $t5, 0x000102
sw $t5, 0($t3)
addi $t3, $t4,  22696
li $t5, 0x010100
sw $t5, 0($t3)
addi $t3, $t4,  22700
li $t5, 0x000506
sw $t5, 0($t3)
addi $t3, $t4,  22704
li $t5, 0x010100
sw $t5, 0($t3)
addi $t3, $t4,  22708
li $t5, 0x290000
sw $t5, 0($t3)
addi $t3, $t4,  22712
li $t5, 0xfe0001
sw $t5, 0($t3)
addi $t3, $t4,  22716
sw $t5, 0($t3)
addi $t3, $t4,  22720
sw $t5, 0($t3)
addi $t3, $t4,  22724
sw $t5, 0($t3)
addi $t3, $t4,  22728
sw $t5, 0($t3)
addi $t3, $t4,  22732
li $t5, 0xf60401
sw $t5, 0($t3)
addi $t3, $t4,  22736
li $t5, 0xfd0101
sw $t5, 0($t3)
addi $t3, $t4,  22740
li $t5, 0xf90400
sw $t5, 0($t3)
addi $t3, $t4,  22744
li $t5, 0xfe0002
sw $t5, 0($t3)
addi $t3, $t4,  22748
li $t5, 0xfb0104
sw $t5, 0($t3)
addi $t3, $t4,  22752
li $t5, 0xfe0002
sw $t5, 0($t3)
addi $t3, $t4,  22756
sw $t5, 0($t3)
addi $t3, $t4,  22760
sw $t5, 0($t3)
addi $t3, $t4,  22764
li $t5, 0xfd0002
sw $t5, 0($t3)
addi $t3, $t4,  22768
li $t5, 0x050001
sw $t5, 0($t3)
addi $t3, $t4,  22772
li $t5, 0x0b0006
sw $t5, 0($t3)
addi $t3, $t4,  22776
li $t5, 0x040002
sw $t5, 0($t3)
addi $t3, $t4,  22780
li $t5, 0x040001
sw $t5, 0($t3)
addi $t3, $t4,  22784
li $t5, 0x010008
sw $t5, 0($t3)
addi $t3, $t4,  22788
li $t5, 0xfb0200
sw $t5, 0($t3)
addi $t3, $t4,  22792
li $t5, 0xfe0100
sw $t5, 0($t3)
addi $t3, $t4,  22796
li $t5, 0xfe0002
sw $t5, 0($t3)
addi $t3, $t4,  22800
sw $t5, 0($t3)
addi $t3, $t4,  22804
li $t5, 0xfd0200
sw $t5, 0($t3)
addi $t3, $t4,  22808
li $t5, 0xf1020e
sw $t5, 0($t3)
addi $t3, $t4,  22812
li $t5, 0x000605
sw $t5, 0($t3)
addi $t3, $t4,  22816
li $t5, 0x030002
sw $t5, 0($t3)
addi $t3, $t4,  22820
sw $t5, 0($t3)
addi $t3, $t4,  22824
sw $t5, 0($t3)
addi $t3, $t4,  22828
sw $t5, 0($t3)
addi $t3, $t4,  22832
sw $t5, 0($t3)
addi $t3, $t4,  22836
sw $t5, 0($t3)
addi $t3, $t4,  22840
sw $t5, 0($t3)
addi $t3, $t4,  22844
li $t5, 0x000200
sw $t5, 0($t3)
addi $t3, $t4,  22848
li $t5, 0x010001
sw $t5, 0($t3)
addi $t3, $t4,  22852
li $t5, 0x030000
sw $t5, 0($t3)
addi $t3, $t4,  22856
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  22860
sw $t5, 0($t3)
addi $t3, $t4,  22864
sw $t5, 0($t3)
addi $t3, $t4,  22868
sw $t5, 0($t3)
addi $t3, $t4,  22872
sw $t5, 0($t3)
addi $t3, $t4,  22876
li $t5, 0xe9080b
sw $t5, 0($t3)
addi $t3, $t4,  22880
li $t5, 0xfd0006
sw $t5, 0($t3)
addi $t3, $t4,  22884
li $t5, 0xfa0108
sw $t5, 0($t3)
addi $t3, $t4,  22888
li $t5, 0xfe0000
sw $t5, 0($t3)
addi $t3, $t4,  22892
sw $t5, 0($t3)
addi $t3, $t4,  22896
li $t5, 0xfe0200
sw $t5, 0($t3)
addi $t3, $t4,  22900
li $t5, 0xfc0200
sw $t5, 0($t3)
addi $t3, $t4,  22904
li $t5, 0xf10700
sw $t5, 0($t3)
addi $t3, $t4,  22908
li $t5, 0xfb0106
sw $t5, 0($t3)
addi $t3, $t4,  22912
sw $t5, 0($t3)
addi $t3, $t4,  22916
li $t5, 0xf20601
sw $t5, 0($t3)
addi $t3, $t4,  22920
li $t5, 0xfc0101
sw $t5, 0($t3)
addi $t3, $t4,  22924
li $t5, 0xfe0100
sw $t5, 0($t3)
addi $t3, $t4,  22928
li $t5, 0xf80400
sw $t5, 0($t3)
addi $t3, $t4,  22932
li $t5, 0xb7181b
sw $t5, 0($t3)
addi $t3, $t4,  22936
li $t5, 0x040000
sw $t5, 0($t3)
addi $t3, $t4,  22940
li $t5, 0x030000
sw $t5, 0($t3)
addi $t3, $t4,  22944
sw $t5, 0($t3)
addi $t3, $t4,  22948
li $t5, 0x000600
sw $t5, 0($t3)
addi $t3, $t4,  22952
li $t5, 0x000500
sw $t5, 0($t3)
addi $t3, $t4,  22956
li $t5, 0x000200
sw $t5, 0($t3)
addi $t3, $t4,  22960
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  22964
sw $t5, 0($t3)
addi $t3, $t4,  22968
sw $t5, 0($t3)
addi $t3, $t4,  22972
sw $t5, 0($t3)
addi $t3, $t4,  22976
sw $t5, 0($t3)
addi $t3, $t4,  22980
sw $t5, 0($t3)
addi $t3, $t4,  22984
sw $t5, 0($t3)
addi $t3, $t4,  22988
sw $t5, 0($t3)
addi $t3, $t4,  22992
sw $t5, 0($t3)
addi $t3, $t4,  22996
sw $t5, 0($t3)
addi $t3, $t4,  23000
sw $t5, 0($t3)
addi $t3, $t4,  23004
sw $t5, 0($t3)
addi $t3, $t4,  23008
sw $t5, 0($t3)
addi $t3, $t4,  23012
sw $t5, 0($t3)
addi $t3, $t4,  23016
sw $t5, 0($t3)
addi $t3, $t4,  23020
sw $t5, 0($t3)
addi $t3, $t4,  23024
sw $t5, 0($t3)
addi $t3, $t4,  23028
sw $t5, 0($t3)
addi $t3, $t4,  23032
sw $t5, 0($t3)
addi $t3, $t4,  23036
sw $t5, 0($t3)
syscall #sleep for 30 ms
addi $t3, $t4,  23040
sw $t5, 0($t3)
addi $t3, $t4,  23044
sw $t5, 0($t3)
addi $t3, $t4,  23048
sw $t5, 0($t3)
addi $t3, $t4,  23052
sw $t5, 0($t3)
addi $t3, $t4,  23056
sw $t5, 0($t3)
addi $t3, $t4,  23060
sw $t5, 0($t3)
addi $t3, $t4,  23064
sw $t5, 0($t3)
addi $t3, $t4,  23068
sw $t5, 0($t3)
addi $t3, $t4,  23072
sw $t5, 0($t3)
addi $t3, $t4,  23076
sw $t5, 0($t3)
addi $t3, $t4,  23080
sw $t5, 0($t3)
addi $t3, $t4,  23084
sw $t5, 0($t3)
addi $t3, $t4,  23088
sw $t5, 0($t3)
addi $t3, $t4,  23092
sw $t5, 0($t3)
addi $t3, $t4,  23096
sw $t5, 0($t3)
addi $t3, $t4,  23100
sw $t5, 0($t3)
addi $t3, $t4,  23104
sw $t5, 0($t3)
addi $t3, $t4,  23108
sw $t5, 0($t3)
addi $t3, $t4,  23112
li $t5, 0x010009
sw $t5, 0($t3)
addi $t3, $t4,  23116
li $t5, 0x010003
sw $t5, 0($t3)
addi $t3, $t4,  23120
li $t5, 0xdf0e0f
sw $t5, 0($t3)
addi $t3, $t4,  23124
li $t5, 0xfe0000
sw $t5, 0($t3)
addi $t3, $t4,  23128
sw $t5, 0($t3)
addi $t3, $t4,  23132
sw $t5, 0($t3)
addi $t3, $t4,  23136
sw $t5, 0($t3)
addi $t3, $t4,  23140
li $t5, 0xfe0001
sw $t5, 0($t3)
addi $t3, $t4,  23144
li $t5, 0x060001
sw $t5, 0($t3)
addi $t3, $t4,  23148
li $t5, 0x000100
sw $t5, 0($t3)
addi $t3, $t4,  23152
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  23156
sw $t5, 0($t3)
addi $t3, $t4,  23160
sw $t5, 0($t3)
addi $t3, $t4,  23164
sw $t5, 0($t3)
addi $t3, $t4,  23168
sw $t5, 0($t3)
addi $t3, $t4,  23172
li $t5, 0x000100
sw $t5, 0($t3)
addi $t3, $t4,  23176
li $t5, 0x2e0101
sw $t5, 0($t3)
addi $t3, $t4,  23180
li $t5, 0xfa0204
sw $t5, 0($t3)
addi $t3, $t4,  23184
li $t5, 0xfd0001
sw $t5, 0($t3)
addi $t3, $t4,  23188
sw $t5, 0($t3)
addi $t3, $t4,  23192
li $t5, 0xfe0100
sw $t5, 0($t3)
addi $t3, $t4,  23196
li $t5, 0xfd0100
sw $t5, 0($t3)
addi $t3, $t4,  23200
li $t5, 0x510806
sw $t5, 0($t3)
addi $t3, $t4,  23204
li $t5, 0x000100
sw $t5, 0($t3)
addi $t3, $t4,  23208
li $t5, 0x000008
sw $t5, 0($t3)
addi $t3, $t4,  23212
li $t5, 0x050007
sw $t5, 0($t3)
addi $t3, $t4,  23216
li $t5, 0x010401
sw $t5, 0($t3)
addi $t3, $t4,  23220
li $t5, 0x2e0000
sw $t5, 0($t3)
addi $t3, $t4,  23224
li $t5, 0xfb0100
sw $t5, 0($t3)
addi $t3, $t4,  23228
li $t5, 0xfd0000
sw $t5, 0($t3)
addi $t3, $t4,  23232
li $t5, 0xfe0100
sw $t5, 0($t3)
addi $t3, $t4,  23236
li $t5, 0xfd0100
sw $t5, 0($t3)
addi $t3, $t4,  23240
sw $t5, 0($t3)
addi $t3, $t4,  23244
li $t5, 0xfe0100
sw $t5, 0($t3)
addi $t3, $t4,  23248
li $t5, 0xfb0200
sw $t5, 0($t3)
addi $t3, $t4,  23252
li $t5, 0xfe0000
sw $t5, 0($t3)
addi $t3, $t4,  23256
li $t5, 0xfd0100
sw $t5, 0($t3)
addi $t3, $t4,  23260
li $t5, 0xfe0000
sw $t5, 0($t3)
addi $t3, $t4,  23264
li $t5, 0xfd0101
sw $t5, 0($t3)
addi $t3, $t4,  23268
li $t5, 0xf70400
sw $t5, 0($t3)
addi $t3, $t4,  23272
li $t5, 0xf40500
sw $t5, 0($t3)
addi $t3, $t4,  23276
li $t5, 0xf20800
sw $t5, 0($t3)
addi $t3, $t4,  23280
li $t5, 0x0a0201
sw $t5, 0($t3)
addi $t3, $t4,  23284
li $t5, 0x010101
sw $t5, 0($t3)
addi $t3, $t4,  23288
li $t5, 0x020001
sw $t5, 0($t3)
addi $t3, $t4,  23292
li $t5, 0x040000
sw $t5, 0($t3)
addi $t3, $t4,  23296
li $t5, 0x010008
sw $t5, 0($t3)
addi $t3, $t4,  23300
li $t5, 0xfd0100
sw $t5, 0($t3)
addi $t3, $t4,  23304
li $t5, 0xfe0200
sw $t5, 0($t3)
addi $t3, $t4,  23308
li $t5, 0xfd0100
sw $t5, 0($t3)
addi $t3, $t4,  23312
sw $t5, 0($t3)
addi $t3, $t4,  23316
li $t5, 0xfe0005
sw $t5, 0($t3)
addi $t3, $t4,  23320
li $t5, 0xf4020b
sw $t5, 0($t3)
addi $t3, $t4,  23324
li $t5, 0x000005
sw $t5, 0($t3)
addi $t3, $t4,  23328
li $t5, 0x000003
sw $t5, 0($t3)
addi $t3, $t4,  23332
sw $t5, 0($t3)
addi $t3, $t4,  23336
sw $t5, 0($t3)
addi $t3, $t4,  23340
sw $t5, 0($t3)
addi $t3, $t4,  23344
sw $t5, 0($t3)
addi $t3, $t4,  23348
sw $t5, 0($t3)
addi $t3, $t4,  23352
sw $t5, 0($t3)
addi $t3, $t4,  23356
li $t5, 0x020000
sw $t5, 0($t3)
addi $t3, $t4,  23360
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  23364
li $t5, 0x020002
sw $t5, 0($t3)
addi $t3, $t4,  23368
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  23372
sw $t5, 0($t3)
addi $t3, $t4,  23376
sw $t5, 0($t3)
addi $t3, $t4,  23380
sw $t5, 0($t3)
addi $t3, $t4,  23384
sw $t5, 0($t3)
addi $t3, $t4,  23388
li $t5, 0xe9080b
sw $t5, 0($t3)
addi $t3, $t4,  23392
li $t5, 0xfd0006
sw $t5, 0($t3)
addi $t3, $t4,  23396
li $t5, 0xfa0108
sw $t5, 0($t3)
addi $t3, $t4,  23400
li $t5, 0xfe0000
sw $t5, 0($t3)
addi $t3, $t4,  23404
sw $t5, 0($t3)
addi $t3, $t4,  23408
li $t5, 0xfd0104
sw $t5, 0($t3)
addi $t3, $t4,  23412
li $t5, 0xf60400
sw $t5, 0($t3)
addi $t3, $t4,  23416
li $t5, 0xfa0300
sw $t5, 0($t3)
addi $t3, $t4,  23420
li $t5, 0xfd0100
sw $t5, 0($t3)
addi $t3, $t4,  23424
li $t5, 0xfb0104
sw $t5, 0($t3)
addi $t3, $t4,  23428
li $t5, 0xfb0200
sw $t5, 0($t3)
addi $t3, $t4,  23432
li $t5, 0xf90300
sw $t5, 0($t3)
addi $t3, $t4,  23436
li $t5, 0xfe0003
sw $t5, 0($t3)
addi $t3, $t4,  23440
li $t5, 0xfb0300
sw $t5, 0($t3)
addi $t3, $t4,  23444
li $t5, 0xb51c20
sw $t5, 0($t3)
addi $t3, $t4,  23448
li $t5, 0x000601
sw $t5, 0($t3)
addi $t3, $t4,  23452
li $t5, 0x000307
sw $t5, 0($t3)
addi $t3, $t4,  23456
li $t5, 0x060002
sw $t5, 0($t3)
addi $t3, $t4,  23460
li $t5, 0x000300
sw $t5, 0($t3)
addi $t3, $t4,  23464
li $t5, 0x020000
sw $t5, 0($t3)
addi $t3, $t4,  23468
li $t5, 0x000300
sw $t5, 0($t3)
addi $t3, $t4,  23472
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  23476
sw $t5, 0($t3)
addi $t3, $t4,  23480
sw $t5, 0($t3)
addi $t3, $t4,  23484
sw $t5, 0($t3)
addi $t3, $t4,  23488
sw $t5, 0($t3)
addi $t3, $t4,  23492
sw $t5, 0($t3)
addi $t3, $t4,  23496
sw $t5, 0($t3)
addi $t3, $t4,  23500
sw $t5, 0($t3)
addi $t3, $t4,  23504
sw $t5, 0($t3)
addi $t3, $t4,  23508
sw $t5, 0($t3)
addi $t3, $t4,  23512
sw $t5, 0($t3)
addi $t3, $t4,  23516
sw $t5, 0($t3)
addi $t3, $t4,  23520
sw $t5, 0($t3)
addi $t3, $t4,  23524
sw $t5, 0($t3)
addi $t3, $t4,  23528
sw $t5, 0($t3)
addi $t3, $t4,  23532
sw $t5, 0($t3)
addi $t3, $t4,  23536
sw $t5, 0($t3)
addi $t3, $t4,  23540
sw $t5, 0($t3)
addi $t3, $t4,  23544
sw $t5, 0($t3)
addi $t3, $t4,  23548
sw $t5, 0($t3)
syscall #sleep for 30 ms
addi $t3, $t4,  23552
sw $t5, 0($t3)
addi $t3, $t4,  23556
sw $t5, 0($t3)
addi $t3, $t4,  23560
sw $t5, 0($t3)
addi $t3, $t4,  23564
sw $t5, 0($t3)
addi $t3, $t4,  23568
sw $t5, 0($t3)
addi $t3, $t4,  23572
sw $t5, 0($t3)
addi $t3, $t4,  23576
sw $t5, 0($t3)
addi $t3, $t4,  23580
sw $t5, 0($t3)
addi $t3, $t4,  23584
sw $t5, 0($t3)
addi $t3, $t4,  23588
sw $t5, 0($t3)
addi $t3, $t4,  23592
sw $t5, 0($t3)
addi $t3, $t4,  23596
sw $t5, 0($t3)
addi $t3, $t4,  23600
sw $t5, 0($t3)
addi $t3, $t4,  23604
sw $t5, 0($t3)
addi $t3, $t4,  23608
sw $t5, 0($t3)
addi $t3, $t4,  23612
sw $t5, 0($t3)
addi $t3, $t4,  23616
sw $t5, 0($t3)
addi $t3, $t4,  23620
sw $t5, 0($t3)
addi $t3, $t4,  23624
li $t5, 0x000209
sw $t5, 0($t3)
addi $t3, $t4,  23628
li $t5, 0x020003
sw $t5, 0($t3)
addi $t3, $t4,  23632
li $t5, 0xe10d0f
sw $t5, 0($t3)
addi $t3, $t4,  23636
li $t5, 0xfe0000
sw $t5, 0($t3)
addi $t3, $t4,  23640
sw $t5, 0($t3)
addi $t3, $t4,  23644
sw $t5, 0($t3)
addi $t3, $t4,  23648
sw $t5, 0($t3)
addi $t3, $t4,  23652
li $t5, 0xfd0001
sw $t5, 0($t3)
addi $t3, $t4,  23656
li $t5, 0x050001
sw $t5, 0($t3)
addi $t3, $t4,  23660
li $t5, 0x000100
sw $t5, 0($t3)
addi $t3, $t4,  23664
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  23668
sw $t5, 0($t3)
addi $t3, $t4,  23672
sw $t5, 0($t3)
addi $t3, $t4,  23676
sw $t5, 0($t3)
addi $t3, $t4,  23680
sw $t5, 0($t3)
addi $t3, $t4,  23684
li $t5, 0x000100
sw $t5, 0($t3)
addi $t3, $t4,  23688
li $t5, 0x300101
sw $t5, 0($t3)
addi $t3, $t4,  23692
li $t5, 0xfb0102
sw $t5, 0($t3)
addi $t3, $t4,  23696
li $t5, 0xfe0000
sw $t5, 0($t3)
addi $t3, $t4,  23700
sw $t5, 0($t3)
addi $t3, $t4,  23704
li $t5, 0xfd0100
sw $t5, 0($t3)
addi $t3, $t4,  23708
sw $t5, 0($t3)
addi $t3, $t4,  23712
li $t5, 0x520707
sw $t5, 0($t3)
addi $t3, $t4,  23716
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  23720
sw $t5, 0($t3)
addi $t3, $t4,  23724
li $t5, 0x010002
sw $t5, 0($t3)
addi $t3, $t4,  23728
li $t5, 0x080000
sw $t5, 0($t3)
addi $t3, $t4,  23732
li $t5, 0x030201
sw $t5, 0($t3)
addi $t3, $t4,  23736
li $t5, 0x130100
sw $t5, 0($t3)
addi $t3, $t4,  23740
li $t5, 0x200001
sw $t5, 0($t3)
addi $t3, $t4,  23744
li $t5, 0x780e0d
sw $t5, 0($t3)
addi $t3, $t4,  23748
li $t5, 0xfe0000
sw $t5, 0($t3)
addi $t3, $t4,  23752
sw $t5, 0($t3)
addi $t3, $t4,  23756
sw $t5, 0($t3)
addi $t3, $t4,  23760
sw $t5, 0($t3)
addi $t3, $t4,  23764
sw $t5, 0($t3)
addi $t3, $t4,  23768
sw $t5, 0($t3)
addi $t3, $t4,  23772
sw $t5, 0($t3)
addi $t3, $t4,  23776
li $t5, 0xf50200
sw $t5, 0($t3)
addi $t3, $t4,  23780
li $t5, 0x1e0100
sw $t5, 0($t3)
addi $t3, $t4,  23784
li $t5, 0x080400
sw $t5, 0($t3)
addi $t3, $t4,  23788
li $t5, 0x050600
sw $t5, 0($t3)
addi $t3, $t4,  23792
li $t5, 0x000306
sw $t5, 0($t3)
addi $t3, $t4,  23796
li $t5, 0x000100
sw $t5, 0($t3)
addi $t3, $t4,  23800
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  23804
sw $t5, 0($t3)
addi $t3, $t4,  23808
li $t5, 0x010005
sw $t5, 0($t3)
addi $t3, $t4,  23812
li $t5, 0xfd0100
sw $t5, 0($t3)
addi $t3, $t4,  23816
li $t5, 0xfe0100
sw $t5, 0($t3)
addi $t3, $t4,  23820
li $t5, 0xfe0000
sw $t5, 0($t3)
addi $t3, $t4,  23824
sw $t5, 0($t3)
addi $t3, $t4,  23828
li $t5, 0xfe0002
sw $t5, 0($t3)
addi $t3, $t4,  23832
li $t5, 0xf40207
sw $t5, 0($t3)
addi $t3, $t4,  23836
li $t5, 0x000104
sw $t5, 0($t3)
addi $t3, $t4,  23840
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  23844
sw $t5, 0($t3)
addi $t3, $t4,  23848
sw $t5, 0($t3)
addi $t3, $t4,  23852
sw $t5, 0($t3)
addi $t3, $t4,  23856
sw $t5, 0($t3)
addi $t3, $t4,  23860
sw $t5, 0($t3)
addi $t3, $t4,  23864
sw $t5, 0($t3)
addi $t3, $t4,  23868
sw $t5, 0($t3)
addi $t3, $t4,  23872
sw $t5, 0($t3)
addi $t3, $t4,  23876
sw $t5, 0($t3)
addi $t3, $t4,  23880
sw $t5, 0($t3)
addi $t3, $t4,  23884
sw $t5, 0($t3)
addi $t3, $t4,  23888
sw $t5, 0($t3)
addi $t3, $t4,  23892
sw $t5, 0($t3)
addi $t3, $t4,  23896
sw $t5, 0($t3)
addi $t3, $t4,  23900
li $t5, 0xe9080b
sw $t5, 0($t3)
addi $t3, $t4,  23904
li $t5, 0xfd0006
sw $t5, 0($t3)
addi $t3, $t4,  23908
li $t5, 0xfa0108
sw $t5, 0($t3)
addi $t3, $t4,  23912
li $t5, 0xfe0000
sw $t5, 0($t3)
addi $t3, $t4,  23916
sw $t5, 0($t3)
addi $t3, $t4,  23920
li $t5, 0xfa0302
sw $t5, 0($t3)
addi $t3, $t4,  23924
li $t5, 0x290000
sw $t5, 0($t3)
addi $t3, $t4,  23928
li $t5, 0x150100
sw $t5, 0($t3)
addi $t3, $t4,  23932
li $t5, 0x2f0000
sw $t5, 0($t3)
addi $t3, $t4,  23936
li $t5, 0xf80302
sw $t5, 0($t3)
addi $t3, $t4,  23940
li $t5, 0xfe0000
sw $t5, 0($t3)
addi $t3, $t4,  23944
sw $t5, 0($t3)
addi $t3, $t4,  23948
sw $t5, 0($t3)
addi $t3, $t4,  23952
li $t5, 0xf80400
sw $t5, 0($t3)
addi $t3, $t4,  23956
li $t5, 0xfe0907
sw $t5, 0($t3)
addi $t3, $t4,  23960
li $t5, 0xf7020e
sw $t5, 0($t3)
addi $t3, $t4,  23964
li $t5, 0xf10702
sw $t5, 0($t3)
addi $t3, $t4,  23968
li $t5, 0x78080b
sw $t5, 0($t3)
addi $t3, $t4,  23972
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  23976
sw $t5, 0($t3)
addi $t3, $t4,  23980
sw $t5, 0($t3)
addi $t3, $t4,  23984
sw $t5, 0($t3)
addi $t3, $t4,  23988
sw $t5, 0($t3)
addi $t3, $t4,  23992
sw $t5, 0($t3)
addi $t3, $t4,  23996
sw $t5, 0($t3)
addi $t3, $t4,  24000
sw $t5, 0($t3)
addi $t3, $t4,  24004
sw $t5, 0($t3)
addi $t3, $t4,  24008
sw $t5, 0($t3)
addi $t3, $t4,  24012
sw $t5, 0($t3)
addi $t3, $t4,  24016
sw $t5, 0($t3)
addi $t3, $t4,  24020
sw $t5, 0($t3)
addi $t3, $t4,  24024
sw $t5, 0($t3)
addi $t3, $t4,  24028
sw $t5, 0($t3)
addi $t3, $t4,  24032
sw $t5, 0($t3)
addi $t3, $t4,  24036
sw $t5, 0($t3)
addi $t3, $t4,  24040
sw $t5, 0($t3)
addi $t3, $t4,  24044
sw $t5, 0($t3)
addi $t3, $t4,  24048
sw $t5, 0($t3)
addi $t3, $t4,  24052
sw $t5, 0($t3)
addi $t3, $t4,  24056
sw $t5, 0($t3)
addi $t3, $t4,  24060
sw $t5, 0($t3)
syscall #sleep for 30 ms
addi $t3, $t4,  24064
sw $t5, 0($t3)
addi $t3, $t4,  24068
sw $t5, 0($t3)
addi $t3, $t4,  24072
sw $t5, 0($t3)
addi $t3, $t4,  24076
sw $t5, 0($t3)
addi $t3, $t4,  24080
sw $t5, 0($t3)
addi $t3, $t4,  24084
sw $t5, 0($t3)
addi $t3, $t4,  24088
sw $t5, 0($t3)
addi $t3, $t4,  24092
sw $t5, 0($t3)
addi $t3, $t4,  24096
sw $t5, 0($t3)
addi $t3, $t4,  24100
sw $t5, 0($t3)
addi $t3, $t4,  24104
sw $t5, 0($t3)
addi $t3, $t4,  24108
sw $t5, 0($t3)
addi $t3, $t4,  24112
sw $t5, 0($t3)
addi $t3, $t4,  24116
sw $t5, 0($t3)
addi $t3, $t4,  24120
sw $t5, 0($t3)
addi $t3, $t4,  24124
sw $t5, 0($t3)
addi $t3, $t4,  24128
sw $t5, 0($t3)
addi $t3, $t4,  24132
sw $t5, 0($t3)
addi $t3, $t4,  24136
li $t5, 0x000209
sw $t5, 0($t3)
addi $t3, $t4,  24140
li $t5, 0x020003
sw $t5, 0($t3)
addi $t3, $t4,  24144
li $t5, 0xe10d0f
sw $t5, 0($t3)
addi $t3, $t4,  24148
li $t5, 0xfe0000
sw $t5, 0($t3)
addi $t3, $t4,  24152
sw $t5, 0($t3)
addi $t3, $t4,  24156
sw $t5, 0($t3)
addi $t3, $t4,  24160
sw $t5, 0($t3)
addi $t3, $t4,  24164
li $t5, 0xfd0001
sw $t5, 0($t3)
addi $t3, $t4,  24168
li $t5, 0x050001
sw $t5, 0($t3)
addi $t3, $t4,  24172
li $t5, 0x000100
sw $t5, 0($t3)
addi $t3, $t4,  24176
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  24180
sw $t5, 0($t3)
addi $t3, $t4,  24184
sw $t5, 0($t3)
addi $t3, $t4,  24188
sw $t5, 0($t3)
addi $t3, $t4,  24192
sw $t5, 0($t3)
addi $t3, $t4,  24196
li $t5, 0x000100
sw $t5, 0($t3)
addi $t3, $t4,  24200
li $t5, 0x300101
sw $t5, 0($t3)
addi $t3, $t4,  24204
li $t5, 0xfb0102
sw $t5, 0($t3)
addi $t3, $t4,  24208
li $t5, 0xfe0000
sw $t5, 0($t3)
addi $t3, $t4,  24212
sw $t5, 0($t3)
addi $t3, $t4,  24216
li $t5, 0xfd0100
sw $t5, 0($t3)
addi $t3, $t4,  24220
sw $t5, 0($t3)
addi $t3, $t4,  24224
li $t5, 0x520707
sw $t5, 0($t3)
addi $t3, $t4,  24228
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  24232
sw $t5, 0($t3)
addi $t3, $t4,  24236
sw $t5, 0($t3)
addi $t3, $t4,  24240
li $t5, 0x000203
sw $t5, 0($t3)
addi $t3, $t4,  24244
li $t5, 0x060000
sw $t5, 0($t3)
addi $t3, $t4,  24248
li $t5, 0x000102
sw $t5, 0($t3)
addi $t3, $t4,  24252
li $t5, 0x000305
sw $t5, 0($t3)
addi $t3, $t4,  24256
li $t5, 0x790e0e
sw $t5, 0($t3)
addi $t3, $t4,  24260
li $t5, 0xfe0000
sw $t5, 0($t3)
addi $t3, $t4,  24264
sw $t5, 0($t3)
addi $t3, $t4,  24268
sw $t5, 0($t3)
addi $t3, $t4,  24272
sw $t5, 0($t3)
addi $t3, $t4,  24276
sw $t5, 0($t3)
addi $t3, $t4,  24280
sw $t5, 0($t3)
addi $t3, $t4,  24284
sw $t5, 0($t3)
addi $t3, $t4,  24288
li $t5, 0xfb0700
sw $t5, 0($t3)
addi $t3, $t4,  24292
li $t5, 0x050400
sw $t5, 0($t3)
addi $t3, $t4,  24296
li $t5, 0x010201
sw $t5, 0($t3)
addi $t3, $t4,  24300
li $t5, 0x040102
sw $t5, 0($t3)
addi $t3, $t4,  24304
li $t5, 0x000200
sw $t5, 0($t3)
addi $t3, $t4,  24308
li $t5, 0x010001
sw $t5, 0($t3)
addi $t3, $t4,  24312
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  24316
sw $t5, 0($t3)
addi $t3, $t4,  24320
li $t5, 0x010005
sw $t5, 0($t3)
addi $t3, $t4,  24324
li $t5, 0xfd0100
sw $t5, 0($t3)
addi $t3, $t4,  24328
li $t5, 0xfe0100
sw $t5, 0($t3)
addi $t3, $t4,  24332
li $t5, 0xfe0000
sw $t5, 0($t3)
addi $t3, $t4,  24336
sw $t5, 0($t3)
addi $t3, $t4,  24340
li $t5, 0xfe0002
sw $t5, 0($t3)
addi $t3, $t4,  24344
li $t5, 0xf40207
sw $t5, 0($t3)
addi $t3, $t4,  24348
li $t5, 0x000104
sw $t5, 0($t3)
addi $t3, $t4,  24352
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  24356
sw $t5, 0($t3)
addi $t3, $t4,  24360
sw $t5, 0($t3)
addi $t3, $t4,  24364
sw $t5, 0($t3)
addi $t3, $t4,  24368
sw $t5, 0($t3)
addi $t3, $t4,  24372
sw $t5, 0($t3)
addi $t3, $t4,  24376
sw $t5, 0($t3)
addi $t3, $t4,  24380
sw $t5, 0($t3)
addi $t3, $t4,  24384
sw $t5, 0($t3)
addi $t3, $t4,  24388
sw $t5, 0($t3)
addi $t3, $t4,  24392
sw $t5, 0($t3)
addi $t3, $t4,  24396
sw $t5, 0($t3)
addi $t3, $t4,  24400
sw $t5, 0($t3)
addi $t3, $t4,  24404
sw $t5, 0($t3)
addi $t3, $t4,  24408
sw $t5, 0($t3)
addi $t3, $t4,  24412
li $t5, 0xe9080b
sw $t5, 0($t3)
addi $t3, $t4,  24416
li $t5, 0xfd0006
sw $t5, 0($t3)
addi $t3, $t4,  24420
li $t5, 0xfa0108
sw $t5, 0($t3)
addi $t3, $t4,  24424
li $t5, 0xfe0000
sw $t5, 0($t3)
addi $t3, $t4,  24428
sw $t5, 0($t3)
addi $t3, $t4,  24432
li $t5, 0xf60301
sw $t5, 0($t3)
addi $t3, $t4,  24436
li $t5, 0x010100
sw $t5, 0($t3)
addi $t3, $t4,  24440
li $t5, 0x000300
sw $t5, 0($t3)
addi $t3, $t4,  24444
li $t5, 0x050205
sw $t5, 0($t3)
addi $t3, $t4,  24448
li $t5, 0xfc0200
sw $t5, 0($t3)
addi $t3, $t4,  24452
li $t5, 0xfe0000
sw $t5, 0($t3)
addi $t3, $t4,  24456
sw $t5, 0($t3)
addi $t3, $t4,  24460
sw $t5, 0($t3)
addi $t3, $t4,  24464
li $t5, 0xf80301
sw $t5, 0($t3)
addi $t3, $t4,  24468
li $t5, 0xfc0003
sw $t5, 0($t3)
addi $t3, $t4,  24472
li $t5, 0xfb0200
sw $t5, 0($t3)
addi $t3, $t4,  24476
li $t5, 0xfa0300
sw $t5, 0($t3)
addi $t3, $t4,  24480
li $t5, 0x750b0d
sw $t5, 0($t3)
addi $t3, $t4,  24484
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  24488
sw $t5, 0($t3)
addi $t3, $t4,  24492
sw $t5, 0($t3)
addi $t3, $t4,  24496
sw $t5, 0($t3)
addi $t3, $t4,  24500
sw $t5, 0($t3)
addi $t3, $t4,  24504
sw $t5, 0($t3)
addi $t3, $t4,  24508
sw $t5, 0($t3)
addi $t3, $t4,  24512
sw $t5, 0($t3)
addi $t3, $t4,  24516
sw $t5, 0($t3)
addi $t3, $t4,  24520
sw $t5, 0($t3)
addi $t3, $t4,  24524
sw $t5, 0($t3)
addi $t3, $t4,  24528
sw $t5, 0($t3)
addi $t3, $t4,  24532
sw $t5, 0($t3)
addi $t3, $t4,  24536
sw $t5, 0($t3)
addi $t3, $t4,  24540
sw $t5, 0($t3)
addi $t3, $t4,  24544
sw $t5, 0($t3)
addi $t3, $t4,  24548
sw $t5, 0($t3)
addi $t3, $t4,  24552
sw $t5, 0($t3)
addi $t3, $t4,  24556
sw $t5, 0($t3)
addi $t3, $t4,  24560
sw $t5, 0($t3)
addi $t3, $t4,  24564
sw $t5, 0($t3)
addi $t3, $t4,  24568
sw $t5, 0($t3)
addi $t3, $t4,  24572
sw $t5, 0($t3)
syscall #sleep for 30 ms
addi $t3, $t4,  24576
sw $t5, 0($t3)
addi $t3, $t4,  24580
sw $t5, 0($t3)
addi $t3, $t4,  24584
sw $t5, 0($t3)
addi $t3, $t4,  24588
sw $t5, 0($t3)
addi $t3, $t4,  24592
sw $t5, 0($t3)
addi $t3, $t4,  24596
sw $t5, 0($t3)
addi $t3, $t4,  24600
sw $t5, 0($t3)
addi $t3, $t4,  24604
sw $t5, 0($t3)
addi $t3, $t4,  24608
sw $t5, 0($t3)
addi $t3, $t4,  24612
sw $t5, 0($t3)
addi $t3, $t4,  24616
sw $t5, 0($t3)
addi $t3, $t4,  24620
sw $t5, 0($t3)
addi $t3, $t4,  24624
sw $t5, 0($t3)
addi $t3, $t4,  24628
sw $t5, 0($t3)
addi $t3, $t4,  24632
sw $t5, 0($t3)
addi $t3, $t4,  24636
sw $t5, 0($t3)
addi $t3, $t4,  24640
sw $t5, 0($t3)
addi $t3, $t4,  24644
sw $t5, 0($t3)
addi $t3, $t4,  24648
li $t5, 0x050000
sw $t5, 0($t3)
addi $t3, $t4,  24652
li $t5, 0x070105
sw $t5, 0($t3)
addi $t3, $t4,  24656
li $t5, 0xd91016
sw $t5, 0($t3)
addi $t3, $t4,  24660
li $t5, 0xfb0200
sw $t5, 0($t3)
addi $t3, $t4,  24664
li $t5, 0xfa0100
sw $t5, 0($t3)
addi $t3, $t4,  24668
li $t5, 0xf90203
sw $t5, 0($t3)
addi $t3, $t4,  24672
li $t5, 0xf90204
sw $t5, 0($t3)
addi $t3, $t4,  24676
li $t5, 0xfa0300
sw $t5, 0($t3)
addi $t3, $t4,  24680
li $t5, 0x110000
sw $t5, 0($t3)
addi $t3, $t4,  24684
li $t5, 0x050600
sw $t5, 0($t3)
addi $t3, $t4,  24688
li $t5, 0x0b0200
sw $t5, 0($t3)
addi $t3, $t4,  24692
sw $t5, 0($t3)
addi $t3, $t4,  24696
sw $t5, 0($t3)
addi $t3, $t4,  24700
sw $t5, 0($t3)
addi $t3, $t4,  24704
sw $t5, 0($t3)
addi $t3, $t4,  24708
li $t5, 0x110201
sw $t5, 0($t3)
addi $t3, $t4,  24712
li $t5, 0x4c0001
sw $t5, 0($t3)
addi $t3, $t4,  24716
li $t5, 0xf50402
sw $t5, 0($t3)
addi $t3, $t4,  24720
li $t5, 0xf80300
sw $t5, 0($t3)
addi $t3, $t4,  24724
li $t5, 0xf90006
sw $t5, 0($t3)
addi $t3, $t4,  24728
li $t5, 0xee070c
sw $t5, 0($t3)
addi $t3, $t4,  24732
li $t5, 0xf0070f
sw $t5, 0($t3)
addi $t3, $t4,  24736
li $t5, 0x610608
sw $t5, 0($t3)
addi $t3, $t4,  24740
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  24744
sw $t5, 0($t3)
addi $t3, $t4,  24748
sw $t5, 0($t3)
addi $t3, $t4,  24752
sw $t5, 0($t3)
addi $t3, $t4,  24756
sw $t5, 0($t3)
addi $t3, $t4,  24760
li $t5, 0x010000
sw $t5, 0($t3)
addi $t3, $t4,  24764
li $t5, 0x000402
sw $t5, 0($t3)
addi $t3, $t4,  24768
li $t5, 0x691314
sw $t5, 0($t3)
addi $t3, $t4,  24772
li $t5, 0xf80200
sw $t5, 0($t3)
addi $t3, $t4,  24776
sw $t5, 0($t3)
addi $t3, $t4,  24780
li $t5, 0xfa0106
sw $t5, 0($t3)
addi $t3, $t4,  24784
li $t5, 0xfe0100
sw $t5, 0($t3)
addi $t3, $t4,  24788
li $t5, 0xf50402
sw $t5, 0($t3)
addi $t3, $t4,  24792
li $t5, 0xea0a08
sw $t5, 0($t3)
addi $t3, $t4,  24796
li $t5, 0xef0613
sw $t5, 0($t3)
addi $t3, $t4,  24800
li $t5, 0xe70b0a
sw $t5, 0($t3)
addi $t3, $t4,  24804
li $t5, 0x120000
sw $t5, 0($t3)
addi $t3, $t4,  24808
li $t5, 0x070100
sw $t5, 0($t3)
addi $t3, $t4,  24812
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  24816
sw $t5, 0($t3)
addi $t3, $t4,  24820
sw $t5, 0($t3)
addi $t3, $t4,  24824
sw $t5, 0($t3)
addi $t3, $t4,  24828
sw $t5, 0($t3)
addi $t3, $t4,  24832
li $t5, 0x010005
sw $t5, 0($t3)
addi $t3, $t4,  24836
li $t5, 0xfd0100
sw $t5, 0($t3)
addi $t3, $t4,  24840
li $t5, 0xfe0100
sw $t5, 0($t3)
addi $t3, $t4,  24844
li $t5, 0xfe0000
sw $t5, 0($t3)
addi $t3, $t4,  24848
sw $t5, 0($t3)
addi $t3, $t4,  24852
li $t5, 0xfb0006
sw $t5, 0($t3)
addi $t3, $t4,  24856
li $t5, 0xf9070f
sw $t5, 0($t3)
addi $t3, $t4,  24860
li $t5, 0x1f0001
sw $t5, 0($t3)
addi $t3, $t4,  24864
li $t5, 0x060300
sw $t5, 0($t3)
addi $t3, $t4,  24868
sw $t5, 0($t3)
addi $t3, $t4,  24872
sw $t5, 0($t3)
addi $t3, $t4,  24876
sw $t5, 0($t3)
addi $t3, $t4,  24880
sw $t5, 0($t3)
addi $t3, $t4,  24884
sw $t5, 0($t3)
addi $t3, $t4,  24888
sw $t5, 0($t3)
addi $t3, $t4,  24892
sw $t5, 0($t3)
addi $t3, $t4,  24896
sw $t5, 0($t3)
addi $t3, $t4,  24900
sw $t5, 0($t3)
addi $t3, $t4,  24904
sw $t5, 0($t3)
addi $t3, $t4,  24908
sw $t5, 0($t3)
addi $t3, $t4,  24912
li $t5, 0x0e0200
sw $t5, 0($t3)
addi $t3, $t4,  24916
li $t5, 0x0a0003
sw $t5, 0($t3)
addi $t3, $t4,  24920
li $t5, 0x000100
sw $t5, 0($t3)
addi $t3, $t4,  24924
li $t5, 0xe9080b
sw $t5, 0($t3)
addi $t3, $t4,  24928
li $t5, 0xfd0006
sw $t5, 0($t3)
addi $t3, $t4,  24932
li $t5, 0xfa0108
sw $t5, 0($t3)
addi $t3, $t4,  24936
li $t5, 0xfe0000
sw $t5, 0($t3)
addi $t3, $t4,  24940
sw $t5, 0($t3)
addi $t3, $t4,  24944
li $t5, 0xfd0200
sw $t5, 0($t3)
addi $t3, $t4,  24948
li $t5, 0x030006
sw $t5, 0($t3)
addi $t3, $t4,  24952
li $t5, 0x010004
sw $t5, 0($t3)
addi $t3, $t4,  24956
li $t5, 0x070104
sw $t5, 0($t3)
addi $t3, $t4,  24960
li $t5, 0xf70300
sw $t5, 0($t3)
addi $t3, $t4,  24964
li $t5, 0xfb0300
sw $t5, 0($t3)
addi $t3, $t4,  24968
li $t5, 0xf00605
sw $t5, 0($t3)
addi $t3, $t4,  24972
li $t5, 0xf70208
sw $t5, 0($t3)
addi $t3, $t4,  24976
li $t5, 0xfe0000
sw $t5, 0($t3)
addi $t3, $t4,  24980
sw $t5, 0($t3)
addi $t3, $t4,  24984
li $t5, 0xfb0200
sw $t5, 0($t3)
addi $t3, $t4,  24988
li $t5, 0xf20602
sw $t5, 0($t3)
addi $t3, $t4,  24992
li $t5, 0x910707
sw $t5, 0($t3)
addi $t3, $t4,  24996
li $t5, 0x110100
sw $t5, 0($t3)
addi $t3, $t4,  25000
li $t5, 0x100200
sw $t5, 0($t3)
addi $t3, $t4,  25004
li $t5, 0x000403
sw $t5, 0($t3)
addi $t3, $t4,  25008
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  25012
sw $t5, 0($t3)
addi $t3, $t4,  25016
sw $t5, 0($t3)
addi $t3, $t4,  25020
sw $t5, 0($t3)
addi $t3, $t4,  25024
sw $t5, 0($t3)
addi $t3, $t4,  25028
sw $t5, 0($t3)
addi $t3, $t4,  25032
sw $t5, 0($t3)
addi $t3, $t4,  25036
sw $t5, 0($t3)
addi $t3, $t4,  25040
sw $t5, 0($t3)
addi $t3, $t4,  25044
sw $t5, 0($t3)
addi $t3, $t4,  25048
sw $t5, 0($t3)
addi $t3, $t4,  25052
sw $t5, 0($t3)
addi $t3, $t4,  25056
sw $t5, 0($t3)
addi $t3, $t4,  25060
sw $t5, 0($t3)
addi $t3, $t4,  25064
sw $t5, 0($t3)
addi $t3, $t4,  25068
sw $t5, 0($t3)
addi $t3, $t4,  25072
sw $t5, 0($t3)
addi $t3, $t4,  25076
sw $t5, 0($t3)
addi $t3, $t4,  25080
sw $t5, 0($t3)
addi $t3, $t4,  25084
sw $t5, 0($t3)
syscall #sleep for 30 ms
addi $t3, $t4,  25088
sw $t5, 0($t3)
addi $t3, $t4,  25092
sw $t5, 0($t3)
addi $t3, $t4,  25096
sw $t5, 0($t3)
addi $t3, $t4,  25100
sw $t5, 0($t3)
addi $t3, $t4,  25104
sw $t5, 0($t3)
addi $t3, $t4,  25108
sw $t5, 0($t3)
addi $t3, $t4,  25112
sw $t5, 0($t3)
addi $t3, $t4,  25116
sw $t5, 0($t3)
addi $t3, $t4,  25120
sw $t5, 0($t3)
addi $t3, $t4,  25124
sw $t5, 0($t3)
addi $t3, $t4,  25128
sw $t5, 0($t3)
addi $t3, $t4,  25132
sw $t5, 0($t3)
addi $t3, $t4,  25136
sw $t5, 0($t3)
addi $t3, $t4,  25140
sw $t5, 0($t3)
addi $t3, $t4,  25144
sw $t5, 0($t3)
addi $t3, $t4,  25148
sw $t5, 0($t3)
addi $t3, $t4,  25152
sw $t5, 0($t3)
addi $t3, $t4,  25156
sw $t5, 0($t3)
addi $t3, $t4,  25160
sw $t5, 0($t3)
addi $t3, $t4,  25164
li $t5, 0x000005
sw $t5, 0($t3)
addi $t3, $t4,  25168
li $t5, 0x040101
sw $t5, 0($t3)
addi $t3, $t4,  25172
li $t5, 0x030102
sw $t5, 0($t3)
addi $t3, $t4,  25176
sw $t5, 0($t3)
addi $t3, $t4,  25180
li $t5, 0xea0a10
sw $t5, 0($t3)
addi $t3, $t4,  25184
li $t5, 0xf00701
sw $t5, 0($t3)
addi $t3, $t4,  25188
li $t5, 0xf40600
sw $t5, 0($t3)
addi $t3, $t4,  25192
li $t5, 0xfc0300
sw $t5, 0($t3)
addi $t3, $t4,  25196
li $t5, 0xfd0100
sw $t5, 0($t3)
addi $t3, $t4,  25200
li $t5, 0xfe0200
sw $t5, 0($t3)
addi $t3, $t4,  25204
sw $t5, 0($t3)
addi $t3, $t4,  25208
sw $t5, 0($t3)
addi $t3, $t4,  25212
sw $t5, 0($t3)
addi $t3, $t4,  25216
sw $t5, 0($t3)
addi $t3, $t4,  25220
li $t5, 0xf70600
sw $t5, 0($t3)
addi $t3, $t4,  25224
li $t5, 0xfa0300
sw $t5, 0($t3)
addi $t3, $t4,  25228
li $t5, 0xfe0003
sw $t5, 0($t3)
addi $t3, $t4,  25232
li $t5, 0xfe0100
sw $t5, 0($t3)
addi $t3, $t4,  25236
li $t5, 0xdb1421
sw $t5, 0($t3)
addi $t3, $t4,  25240
li $t5, 0x000608
sw $t5, 0($t3)
addi $t3, $t4,  25244
li $t5, 0x000200
sw $t5, 0($t3)
addi $t3, $t4,  25248
li $t5, 0x030006
sw $t5, 0($t3)
addi $t3, $t4,  25252
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  25256
sw $t5, 0($t3)
addi $t3, $t4,  25260
sw $t5, 0($t3)
addi $t3, $t4,  25264
sw $t5, 0($t3)
addi $t3, $t4,  25268
sw $t5, 0($t3)
addi $t3, $t4,  25272
li $t5, 0x020000
sw $t5, 0($t3)
addi $t3, $t4,  25276
li $t5, 0x010000
sw $t5, 0($t3)
addi $t3, $t4,  25280
li $t5, 0x030000
sw $t5, 0($t3)
addi $t3, $t4,  25284
li $t5, 0x020102
sw $t5, 0($t3)
addi $t3, $t4,  25288
sw $t5, 0($t3)
addi $t3, $t4,  25292
li $t5, 0x981213
sw $t5, 0($t3)
addi $t3, $t4,  25296
li $t5, 0xf50500
sw $t5, 0($t3)
addi $t3, $t4,  25300
li $t5, 0xfe0100
sw $t5, 0($t3)
addi $t3, $t4,  25304
li $t5, 0x1b0101
sw $t5, 0($t3)
addi $t3, $t4,  25308
li $t5, 0x000400
sw $t5, 0($t3)
addi $t3, $t4,  25312
li $t5, 0x000303
sw $t5, 0($t3)
addi $t3, $t4,  25316
li $t5, 0x000104
sw $t5, 0($t3)
addi $t3, $t4,  25320
li $t5, 0x000506
sw $t5, 0($t3)
addi $t3, $t4,  25324
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  25328
sw $t5, 0($t3)
addi $t3, $t4,  25332
sw $t5, 0($t3)
addi $t3, $t4,  25336
sw $t5, 0($t3)
addi $t3, $t4,  25340
sw $t5, 0($t3)
addi $t3, $t4,  25344
li $t5, 0x010005
sw $t5, 0($t3)
addi $t3, $t4,  25348
li $t5, 0xfd0100
sw $t5, 0($t3)
addi $t3, $t4,  25352
li $t5, 0xfe0100
sw $t5, 0($t3)
addi $t3, $t4,  25356
li $t5, 0xfe0000
sw $t5, 0($t3)
addi $t3, $t4,  25360
sw $t5, 0($t3)
addi $t3, $t4,  25364
li $t5, 0xfd0200
sw $t5, 0($t3)
addi $t3, $t4,  25368
li $t5, 0xfc0200
sw $t5, 0($t3)
addi $t3, $t4,  25372
li $t5, 0xfe0001
sw $t5, 0($t3)
addi $t3, $t4,  25376
li $t5, 0xfe0200
sw $t5, 0($t3)
addi $t3, $t4,  25380
sw $t5, 0($t3)
addi $t3, $t4,  25384
sw $t5, 0($t3)
addi $t3, $t4,  25388
sw $t5, 0($t3)
addi $t3, $t4,  25392
sw $t5, 0($t3)
addi $t3, $t4,  25396
sw $t5, 0($t3)
addi $t3, $t4,  25400
sw $t5, 0($t3)
addi $t3, $t4,  25404
sw $t5, 0($t3)
addi $t3, $t4,  25408
sw $t5, 0($t3)
addi $t3, $t4,  25412
sw $t5, 0($t3)
addi $t3, $t4,  25416
sw $t5, 0($t3)
addi $t3, $t4,  25420
sw $t5, 0($t3)
addi $t3, $t4,  25424
li $t5, 0xfe0300
sw $t5, 0($t3)
addi $t3, $t4,  25428
li $t5, 0x050700
sw $t5, 0($t3)
addi $t3, $t4,  25432
li $t5, 0x000300
sw $t5, 0($t3)
addi $t3, $t4,  25436
li $t5, 0xe9080b
sw $t5, 0($t3)
addi $t3, $t4,  25440
li $t5, 0xfd0006
sw $t5, 0($t3)
addi $t3, $t4,  25444
li $t5, 0xfa0108
sw $t5, 0($t3)
addi $t3, $t4,  25448
li $t5, 0xfe0000
sw $t5, 0($t3)
addi $t3, $t4,  25452
sw $t5, 0($t3)
addi $t3, $t4,  25456
li $t5, 0xfd0200
sw $t5, 0($t3)
addi $t3, $t4,  25460
li $t5, 0x030006
sw $t5, 0($t3)
addi $t3, $t4,  25464
li $t5, 0x010004
sw $t5, 0($t3)
addi $t3, $t4,  25468
li $t5, 0x000100
sw $t5, 0($t3)
addi $t3, $t4,  25472
li $t5, 0x040008
sw $t5, 0($t3)
addi $t3, $t4,  25476
li $t5, 0x000306
sw $t5, 0($t3)
addi $t3, $t4,  25480
li $t5, 0x0a0000
sw $t5, 0($t3)
addi $t3, $t4,  25484
li $t5, 0xfe0401
sw $t5, 0($t3)
addi $t3, $t4,  25488
li $t5, 0xfe0000
sw $t5, 0($t3)
addi $t3, $t4,  25492
sw $t5, 0($t3)
addi $t3, $t4,  25496
li $t5, 0xf80301
sw $t5, 0($t3)
addi $t3, $t4,  25500
li $t5, 0xfe0000
sw $t5, 0($t3)
addi $t3, $t4,  25504
li $t5, 0xfe0002
sw $t5, 0($t3)
addi $t3, $t4,  25508
li $t5, 0xfb0008
sw $t5, 0($t3)
addi $t3, $t4,  25512
li $t5, 0xf30403
sw $t5, 0($t3)
addi $t3, $t4,  25516
li $t5, 0x390000
sw $t5, 0($t3)
addi $t3, $t4,  25520
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  25524
sw $t5, 0($t3)
addi $t3, $t4,  25528
sw $t5, 0($t3)
addi $t3, $t4,  25532
sw $t5, 0($t3)
addi $t3, $t4,  25536
sw $t5, 0($t3)
addi $t3, $t4,  25540
sw $t5, 0($t3)
addi $t3, $t4,  25544
sw $t5, 0($t3)
addi $t3, $t4,  25548
sw $t5, 0($t3)
addi $t3, $t4,  25552
sw $t5, 0($t3)
addi $t3, $t4,  25556
sw $t5, 0($t3)
addi $t3, $t4,  25560
sw $t5, 0($t3)
addi $t3, $t4,  25564
sw $t5, 0($t3)
addi $t3, $t4,  25568
sw $t5, 0($t3)
addi $t3, $t4,  25572
sw $t5, 0($t3)
addi $t3, $t4,  25576
sw $t5, 0($t3)
addi $t3, $t4,  25580
sw $t5, 0($t3)
addi $t3, $t4,  25584
sw $t5, 0($t3)
addi $t3, $t4,  25588
sw $t5, 0($t3)
addi $t3, $t4,  25592
sw $t5, 0($t3)
addi $t3, $t4,  25596
sw $t5, 0($t3)
syscall #sleep for 30 ms
addi $t3, $t4,  25600
sw $t5, 0($t3)
addi $t3, $t4,  25604
sw $t5, 0($t3)
addi $t3, $t4,  25608
sw $t5, 0($t3)
addi $t3, $t4,  25612
sw $t5, 0($t3)
addi $t3, $t4,  25616
sw $t5, 0($t3)
addi $t3, $t4,  25620
sw $t5, 0($t3)
addi $t3, $t4,  25624
sw $t5, 0($t3)
addi $t3, $t4,  25628
sw $t5, 0($t3)
addi $t3, $t4,  25632
sw $t5, 0($t3)
addi $t3, $t4,  25636
sw $t5, 0($t3)
addi $t3, $t4,  25640
sw $t5, 0($t3)
addi $t3, $t4,  25644
sw $t5, 0($t3)
addi $t3, $t4,  25648
sw $t5, 0($t3)
addi $t3, $t4,  25652
sw $t5, 0($t3)
addi $t3, $t4,  25656
sw $t5, 0($t3)
addi $t3, $t4,  25660
sw $t5, 0($t3)
addi $t3, $t4,  25664
sw $t5, 0($t3)
addi $t3, $t4,  25668
sw $t5, 0($t3)
addi $t3, $t4,  25672
sw $t5, 0($t3)
addi $t3, $t4,  25676
sw $t5, 0($t3)
addi $t3, $t4,  25680
sw $t5, 0($t3)
addi $t3, $t4,  25684
sw $t5, 0($t3)
addi $t3, $t4,  25688
sw $t5, 0($t3)
addi $t3, $t4,  25692
li $t5, 0xef060c
sw $t5, 0($t3)
addi $t3, $t4,  25696
li $t5, 0xf80400
sw $t5, 0($t3)
addi $t3, $t4,  25700
li $t5, 0xf80500
sw $t5, 0($t3)
addi $t3, $t4,  25704
li $t5, 0xfd0100
sw $t5, 0($t3)
addi $t3, $t4,  25708
sw $t5, 0($t3)
addi $t3, $t4,  25712
sw $t5, 0($t3)
addi $t3, $t4,  25716
sw $t5, 0($t3)
addi $t3, $t4,  25720
sw $t5, 0($t3)
addi $t3, $t4,  25724
sw $t5, 0($t3)
addi $t3, $t4,  25728
sw $t5, 0($t3)
addi $t3, $t4,  25732
sw $t5, 0($t3)
addi $t3, $t4,  25736
sw $t5, 0($t3)
addi $t3, $t4,  25740
sw $t5, 0($t3)
addi $t3, $t4,  25744
li $t5, 0xfe0200
sw $t5, 0($t3)
addi $t3, $t4,  25748
li $t5, 0xe3101f
sw $t5, 0($t3)
addi $t3, $t4,  25752
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  25756
sw $t5, 0($t3)
addi $t3, $t4,  25760
sw $t5, 0($t3)
addi $t3, $t4,  25764
sw $t5, 0($t3)
addi $t3, $t4,  25768
sw $t5, 0($t3)
addi $t3, $t4,  25772
sw $t5, 0($t3)
addi $t3, $t4,  25776
sw $t5, 0($t3)
addi $t3, $t4,  25780
sw $t5, 0($t3)
addi $t3, $t4,  25784
sw $t5, 0($t3)
addi $t3, $t4,  25788
sw $t5, 0($t3)
addi $t3, $t4,  25792
sw $t5, 0($t3)
addi $t3, $t4,  25796
sw $t5, 0($t3)
addi $t3, $t4,  25800
sw $t5, 0($t3)
addi $t3, $t4,  25804
li $t5, 0xa10e0b
sw $t5, 0($t3)
addi $t3, $t4,  25808
li $t5, 0xfb0300
sw $t5, 0($t3)
addi $t3, $t4,  25812
li $t5, 0xfc0200
sw $t5, 0($t3)
addi $t3, $t4,  25816
li $t5, 0x1e0100
sw $t5, 0($t3)
addi $t3, $t4,  25820
li $t5, 0x020200
sw $t5, 0($t3)
addi $t3, $t4,  25824
li $t5, 0x000100
sw $t5, 0($t3)
addi $t3, $t4,  25828
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  25832
sw $t5, 0($t3)
addi $t3, $t4,  25836
sw $t5, 0($t3)
addi $t3, $t4,  25840
sw $t5, 0($t3)
addi $t3, $t4,  25844
sw $t5, 0($t3)
addi $t3, $t4,  25848
sw $t5, 0($t3)
addi $t3, $t4,  25852
sw $t5, 0($t3)
addi $t3, $t4,  25856
li $t5, 0x020200
sw $t5, 0($t3)
addi $t3, $t4,  25860
li $t5, 0xf90201
sw $t5, 0($t3)
addi $t3, $t4,  25864
li $t5, 0xf80300
sw $t5, 0($t3)
addi $t3, $t4,  25868
li $t5, 0xfd0100
sw $t5, 0($t3)
addi $t3, $t4,  25872
sw $t5, 0($t3)
addi $t3, $t4,  25876
sw $t5, 0($t3)
addi $t3, $t4,  25880
sw $t5, 0($t3)
addi $t3, $t4,  25884
sw $t5, 0($t3)
addi $t3, $t4,  25888
sw $t5, 0($t3)
addi $t3, $t4,  25892
sw $t5, 0($t3)
addi $t3, $t4,  25896
sw $t5, 0($t3)
addi $t3, $t4,  25900
sw $t5, 0($t3)
addi $t3, $t4,  25904
sw $t5, 0($t3)
addi $t3, $t4,  25908
sw $t5, 0($t3)
addi $t3, $t4,  25912
sw $t5, 0($t3)
addi $t3, $t4,  25916
sw $t5, 0($t3)
addi $t3, $t4,  25920
sw $t5, 0($t3)
addi $t3, $t4,  25924
sw $t5, 0($t3)
addi $t3, $t4,  25928
sw $t5, 0($t3)
addi $t3, $t4,  25932
sw $t5, 0($t3)
addi $t3, $t4,  25936
li $t5, 0xfe0400
sw $t5, 0($t3)
addi $t3, $t4,  25940
li $t5, 0x090500
sw $t5, 0($t3)
addi $t3, $t4,  25944
li $t5, 0x000300
sw $t5, 0($t3)
addi $t3, $t4,  25948
li $t5, 0xea0711
sw $t5, 0($t3)
addi $t3, $t4,  25952
li $t5, 0xfd0200
sw $t5, 0($t3)
addi $t3, $t4,  25956
li $t5, 0xfc0200
sw $t5, 0($t3)
addi $t3, $t4,  25960
li $t5, 0xfd0100
sw $t5, 0($t3)
addi $t3, $t4,  25964
sw $t5, 0($t3)
addi $t3, $t4,  25968
li $t5, 0xfd0203
sw $t5, 0($t3)
addi $t3, $t4,  25972
li $t5, 0x060100
sw $t5, 0($t3)
addi $t3, $t4,  25976
li $t5, 0x040000
sw $t5, 0($t3)
addi $t3, $t4,  25980
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  25984
sw $t5, 0($t3)
addi $t3, $t4,  25988
li $t5, 0x030000
sw $t5, 0($t3)
addi $t3, $t4,  25992
li $t5, 0x090100
sw $t5, 0($t3)
addi $t3, $t4,  25996
li $t5, 0xf60700
sw $t5, 0($t3)
addi $t3, $t4,  26000
li $t5, 0xfd0100
sw $t5, 0($t3)
addi $t3, $t4,  26004
sw $t5, 0($t3)
addi $t3, $t4,  26008
sw $t5, 0($t3)
addi $t3, $t4,  26012
sw $t5, 0($t3)
addi $t3, $t4,  26016
sw $t5, 0($t3)
addi $t3, $t4,  26020
li $t5, 0xfc0100
sw $t5, 0($t3)
addi $t3, $t4,  26024
li $t5, 0xf50500
sw $t5, 0($t3)
addi $t3, $t4,  26028
li $t5, 0x3a0000
sw $t5, 0($t3)
addi $t3, $t4,  26032
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  26036
sw $t5, 0($t3)
addi $t3, $t4,  26040
sw $t5, 0($t3)
addi $t3, $t4,  26044
sw $t5, 0($t3)
addi $t3, $t4,  26048
sw $t5, 0($t3)
addi $t3, $t4,  26052
sw $t5, 0($t3)
addi $t3, $t4,  26056
sw $t5, 0($t3)
addi $t3, $t4,  26060
sw $t5, 0($t3)
addi $t3, $t4,  26064
sw $t5, 0($t3)
addi $t3, $t4,  26068
sw $t5, 0($t3)
addi $t3, $t4,  26072
sw $t5, 0($t3)
addi $t3, $t4,  26076
sw $t5, 0($t3)
addi $t3, $t4,  26080
sw $t5, 0($t3)
addi $t3, $t4,  26084
sw $t5, 0($t3)
addi $t3, $t4,  26088
sw $t5, 0($t3)
addi $t3, $t4,  26092
sw $t5, 0($t3)
addi $t3, $t4,  26096
sw $t5, 0($t3)
addi $t3, $t4,  26100
sw $t5, 0($t3)
addi $t3, $t4,  26104
sw $t5, 0($t3)
addi $t3, $t4,  26108
sw $t5, 0($t3)
syscall #sleep for 30 ms
addi $t3, $t4,  26112
sw $t5, 0($t3)
addi $t3, $t4,  26116
sw $t5, 0($t3)
addi $t3, $t4,  26120
sw $t5, 0($t3)
addi $t3, $t4,  26124
sw $t5, 0($t3)
addi $t3, $t4,  26128
sw $t5, 0($t3)
addi $t3, $t4,  26132
sw $t5, 0($t3)
addi $t3, $t4,  26136
sw $t5, 0($t3)
addi $t3, $t4,  26140
sw $t5, 0($t3)
addi $t3, $t4,  26144
sw $t5, 0($t3)
addi $t3, $t4,  26148
sw $t5, 0($t3)
addi $t3, $t4,  26152
sw $t5, 0($t3)
addi $t3, $t4,  26156
sw $t5, 0($t3)
addi $t3, $t4,  26160
sw $t5, 0($t3)
addi $t3, $t4,  26164
sw $t5, 0($t3)
addi $t3, $t4,  26168
sw $t5, 0($t3)
addi $t3, $t4,  26172
sw $t5, 0($t3)
addi $t3, $t4,  26176
sw $t5, 0($t3)
addi $t3, $t4,  26180
sw $t5, 0($t3)
addi $t3, $t4,  26184
sw $t5, 0($t3)
addi $t3, $t4,  26188
sw $t5, 0($t3)
addi $t3, $t4,  26192
sw $t5, 0($t3)
addi $t3, $t4,  26196
sw $t5, 0($t3)
addi $t3, $t4,  26200
sw $t5, 0($t3)
addi $t3, $t4,  26204
li $t5, 0x320101
sw $t5, 0($t3)
addi $t3, $t4,  26208
li $t5, 0x360000
sw $t5, 0($t3)
addi $t3, $t4,  26212
li $t5, 0x370000
sw $t5, 0($t3)
addi $t3, $t4,  26216
li $t5, 0x310000
sw $t5, 0($t3)
addi $t3, $t4,  26220
sw $t5, 0($t3)
addi $t3, $t4,  26224
sw $t5, 0($t3)
addi $t3, $t4,  26228
sw $t5, 0($t3)
addi $t3, $t4,  26232
sw $t5, 0($t3)
addi $t3, $t4,  26236
sw $t5, 0($t3)
addi $t3, $t4,  26240
sw $t5, 0($t3)
addi $t3, $t4,  26244
sw $t5, 0($t3)
addi $t3, $t4,  26248
sw $t5, 0($t3)
addi $t3, $t4,  26252
sw $t5, 0($t3)
addi $t3, $t4,  26256
li $t5, 0x3a0000
sw $t5, 0($t3)
addi $t3, $t4,  26260
li $t5, 0x350004
sw $t5, 0($t3)
addi $t3, $t4,  26264
li $t5, 0x000102
sw $t5, 0($t3)
addi $t3, $t4,  26268
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  26272
sw $t5, 0($t3)
addi $t3, $t4,  26276
sw $t5, 0($t3)
addi $t3, $t4,  26280
sw $t5, 0($t3)
addi $t3, $t4,  26284
sw $t5, 0($t3)
addi $t3, $t4,  26288
sw $t5, 0($t3)
addi $t3, $t4,  26292
sw $t5, 0($t3)
addi $t3, $t4,  26296
sw $t5, 0($t3)
addi $t3, $t4,  26300
sw $t5, 0($t3)
addi $t3, $t4,  26304
sw $t5, 0($t3)
addi $t3, $t4,  26308
sw $t5, 0($t3)
addi $t3, $t4,  26312
sw $t5, 0($t3)
addi $t3, $t4,  26316
li $t5, 0x1d0201
sw $t5, 0($t3)
addi $t3, $t4,  26320
li $t5, 0x3d0000
sw $t5, 0($t3)
addi $t3, $t4,  26324
li $t5, 0x3c0000
sw $t5, 0($t3)
addi $t3, $t4,  26328
li $t5, 0x050200
sw $t5, 0($t3)
addi $t3, $t4,  26332
li $t5, 0x020002
sw $t5, 0($t3)
addi $t3, $t4,  26336
li $t5, 0x010000
sw $t5, 0($t3)
addi $t3, $t4,  26340
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  26344
sw $t5, 0($t3)
addi $t3, $t4,  26348
sw $t5, 0($t3)
addi $t3, $t4,  26352
sw $t5, 0($t3)
addi $t3, $t4,  26356
sw $t5, 0($t3)
addi $t3, $t4,  26360
sw $t5, 0($t3)
addi $t3, $t4,  26364
sw $t5, 0($t3)
addi $t3, $t4,  26368
li $t5, 0x02020a
sw $t5, 0($t3)
addi $t3, $t4,  26372
li $t5, 0x3b0000
sw $t5, 0($t3)
addi $t3, $t4,  26376
li $t5, 0x310000
sw $t5, 0($t3)
addi $t3, $t4,  26380
sw $t5, 0($t3)
addi $t3, $t4,  26384
sw $t5, 0($t3)
addi $t3, $t4,  26388
sw $t5, 0($t3)
addi $t3, $t4,  26392
sw $t5, 0($t3)
addi $t3, $t4,  26396
sw $t5, 0($t3)
addi $t3, $t4,  26400
sw $t5, 0($t3)
addi $t3, $t4,  26404
sw $t5, 0($t3)
addi $t3, $t4,  26408
sw $t5, 0($t3)
addi $t3, $t4,  26412
sw $t5, 0($t3)
addi $t3, $t4,  26416
sw $t5, 0($t3)
addi $t3, $t4,  26420
sw $t5, 0($t3)
addi $t3, $t4,  26424
sw $t5, 0($t3)
addi $t3, $t4,  26428
sw $t5, 0($t3)
addi $t3, $t4,  26432
sw $t5, 0($t3)
addi $t3, $t4,  26436
sw $t5, 0($t3)
addi $t3, $t4,  26440
sw $t5, 0($t3)
addi $t3, $t4,  26444
sw $t5, 0($t3)
addi $t3, $t4,  26448
li $t5, 0x3d0000
sw $t5, 0($t3)
addi $t3, $t4,  26452
li $t5, 0x000201
sw $t5, 0($t3)
addi $t3, $t4,  26456
li $t5, 0x010000
sw $t5, 0($t3)
addi $t3, $t4,  26460
li $t5, 0x2f0102
sw $t5, 0($t3)
addi $t3, $t4,  26464
li $t5, 0x380000
sw $t5, 0($t3)
addi $t3, $t4,  26468
li $t5, 0x3a0000
sw $t5, 0($t3)
addi $t3, $t4,  26472
li $t5, 0x310000
sw $t5, 0($t3)
addi $t3, $t4,  26476
sw $t5, 0($t3)
addi $t3, $t4,  26480
li $t5, 0x400000
sw $t5, 0($t3)
addi $t3, $t4,  26484
li $t5, 0x000105
sw $t5, 0($t3)
addi $t3, $t4,  26488
li $t5, 0x060006
sw $t5, 0($t3)
addi $t3, $t4,  26492
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  26496
sw $t5, 0($t3)
addi $t3, $t4,  26500
li $t5, 0x010001
sw $t5, 0($t3)
addi $t3, $t4,  26504
li $t5, 0x040102
sw $t5, 0($t3)
addi $t3, $t4,  26508
li $t5, 0x380000
sw $t5, 0($t3)
addi $t3, $t4,  26512
li $t5, 0x310000
sw $t5, 0($t3)
addi $t3, $t4,  26516
sw $t5, 0($t3)
addi $t3, $t4,  26520
sw $t5, 0($t3)
addi $t3, $t4,  26524
sw $t5, 0($t3)
addi $t3, $t4,  26528
sw $t5, 0($t3)
addi $t3, $t4,  26532
li $t5, 0x2c0000
sw $t5, 0($t3)
addi $t3, $t4,  26536
li $t5, 0x2d0000
sw $t5, 0($t3)
addi $t3, $t4,  26540
li $t5, 0x050200
sw $t5, 0($t3)
addi $t3, $t4,  26544
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  26548
sw $t5, 0($t3)
addi $t3, $t4,  26552
sw $t5, 0($t3)
addi $t3, $t4,  26556
sw $t5, 0($t3)
addi $t3, $t4,  26560
sw $t5, 0($t3)
addi $t3, $t4,  26564
sw $t5, 0($t3)
addi $t3, $t4,  26568
sw $t5, 0($t3)
addi $t3, $t4,  26572
sw $t5, 0($t3)
addi $t3, $t4,  26576
sw $t5, 0($t3)
addi $t3, $t4,  26580
sw $t5, 0($t3)
addi $t3, $t4,  26584
sw $t5, 0($t3)
addi $t3, $t4,  26588
sw $t5, 0($t3)
addi $t3, $t4,  26592
sw $t5, 0($t3)
addi $t3, $t4,  26596
sw $t5, 0($t3)
addi $t3, $t4,  26600
sw $t5, 0($t3)
addi $t3, $t4,  26604
sw $t5, 0($t3)
addi $t3, $t4,  26608
sw $t5, 0($t3)
addi $t3, $t4,  26612
sw $t5, 0($t3)
addi $t3, $t4,  26616
sw $t5, 0($t3)
addi $t3, $t4,  26620
sw $t5, 0($t3)
syscall #sleep for 30 ms
addi $t3, $t4,  26624
sw $t5, 0($t3)
addi $t3, $t4,  26628
sw $t5, 0($t3)
addi $t3, $t4,  26632
sw $t5, 0($t3)
addi $t3, $t4,  26636
sw $t5, 0($t3)
addi $t3, $t4,  26640
sw $t5, 0($t3)
addi $t3, $t4,  26644
sw $t5, 0($t3)
addi $t3, $t4,  26648
sw $t5, 0($t3)
addi $t3, $t4,  26652
sw $t5, 0($t3)
addi $t3, $t4,  26656
sw $t5, 0($t3)
addi $t3, $t4,  26660
sw $t5, 0($t3)
addi $t3, $t4,  26664
sw $t5, 0($t3)
addi $t3, $t4,  26668
sw $t5, 0($t3)
addi $t3, $t4,  26672
sw $t5, 0($t3)
addi $t3, $t4,  26676
sw $t5, 0($t3)
addi $t3, $t4,  26680
sw $t5, 0($t3)
addi $t3, $t4,  26684
sw $t5, 0($t3)
addi $t3, $t4,  26688
sw $t5, 0($t3)
addi $t3, $t4,  26692
sw $t5, 0($t3)
addi $t3, $t4,  26696
sw $t5, 0($t3)
addi $t3, $t4,  26700
sw $t5, 0($t3)
addi $t3, $t4,  26704
sw $t5, 0($t3)
addi $t3, $t4,  26708
sw $t5, 0($t3)
addi $t3, $t4,  26712
sw $t5, 0($t3)
addi $t3, $t4,  26716
sw $t5, 0($t3)
addi $t3, $t4,  26720
li $t5, 0x000001
sw $t5, 0($t3)
addi $t3, $t4,  26724
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  26728
sw $t5, 0($t3)
addi $t3, $t4,  26732
sw $t5, 0($t3)
addi $t3, $t4,  26736
sw $t5, 0($t3)
addi $t3, $t4,  26740
sw $t5, 0($t3)
addi $t3, $t4,  26744
sw $t5, 0($t3)
addi $t3, $t4,  26748
sw $t5, 0($t3)
addi $t3, $t4,  26752
sw $t5, 0($t3)
addi $t3, $t4,  26756
sw $t5, 0($t3)
addi $t3, $t4,  26760
sw $t5, 0($t3)
addi $t3, $t4,  26764
sw $t5, 0($t3)
addi $t3, $t4,  26768
li $t5, 0x000001
sw $t5, 0($t3)
addi $t3, $t4,  26772
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  26776
sw $t5, 0($t3)
addi $t3, $t4,  26780
sw $t5, 0($t3)
addi $t3, $t4,  26784
sw $t5, 0($t3)
addi $t3, $t4,  26788
sw $t5, 0($t3)
addi $t3, $t4,  26792
sw $t5, 0($t3)
addi $t3, $t4,  26796
sw $t5, 0($t3)
addi $t3, $t4,  26800
sw $t5, 0($t3)
addi $t3, $t4,  26804
sw $t5, 0($t3)
addi $t3, $t4,  26808
sw $t5, 0($t3)
addi $t3, $t4,  26812
sw $t5, 0($t3)
addi $t3, $t4,  26816
sw $t5, 0($t3)
addi $t3, $t4,  26820
sw $t5, 0($t3)
addi $t3, $t4,  26824
sw $t5, 0($t3)
addi $t3, $t4,  26828
li $t5, 0x000001
sw $t5, 0($t3)
addi $t3, $t4,  26832
li $t5, 0x010000
sw $t5, 0($t3)
addi $t3, $t4,  26836
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  26840
sw $t5, 0($t3)
addi $t3, $t4,  26844
li $t5, 0x010001
sw $t5, 0($t3)
addi $t3, $t4,  26848
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  26852
sw $t5, 0($t3)
addi $t3, $t4,  26856
sw $t5, 0($t3)
addi $t3, $t4,  26860
sw $t5, 0($t3)
addi $t3, $t4,  26864
sw $t5, 0($t3)
addi $t3, $t4,  26868
sw $t5, 0($t3)
addi $t3, $t4,  26872
sw $t5, 0($t3)
addi $t3, $t4,  26876
sw $t5, 0($t3)
addi $t3, $t4,  26880
li $t5, 0x010000
sw $t5, 0($t3)
addi $t3, $t4,  26884
sw $t5, 0($t3)
addi $t3, $t4,  26888
li $t5, 0x000001
sw $t5, 0($t3)
addi $t3, $t4,  26892
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  26896
sw $t5, 0($t3)
addi $t3, $t4,  26900
sw $t5, 0($t3)
addi $t3, $t4,  26904
sw $t5, 0($t3)
addi $t3, $t4,  26908
sw $t5, 0($t3)
addi $t3, $t4,  26912
sw $t5, 0($t3)
addi $t3, $t4,  26916
sw $t5, 0($t3)
addi $t3, $t4,  26920
sw $t5, 0($t3)
addi $t3, $t4,  26924
sw $t5, 0($t3)
addi $t3, $t4,  26928
sw $t5, 0($t3)
addi $t3, $t4,  26932
sw $t5, 0($t3)
addi $t3, $t4,  26936
sw $t5, 0($t3)
addi $t3, $t4,  26940
sw $t5, 0($t3)
addi $t3, $t4,  26944
sw $t5, 0($t3)
addi $t3, $t4,  26948
sw $t5, 0($t3)
addi $t3, $t4,  26952
sw $t5, 0($t3)
addi $t3, $t4,  26956
sw $t5, 0($t3)
addi $t3, $t4,  26960
sw $t5, 0($t3)
addi $t3, $t4,  26964
li $t5, 0x010001
sw $t5, 0($t3)
addi $t3, $t4,  26968
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  26972
sw $t5, 0($t3)
addi $t3, $t4,  26976
li $t5, 0x000001
sw $t5, 0($t3)
addi $t3, $t4,  26980
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  26984
sw $t5, 0($t3)
addi $t3, $t4,  26988
sw $t5, 0($t3)
addi $t3, $t4,  26992
sw $t5, 0($t3)
addi $t3, $t4,  26996
li $t5, 0x020000
sw $t5, 0($t3)
addi $t3, $t4,  27000
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  27004
sw $t5, 0($t3)
addi $t3, $t4,  27008
sw $t5, 0($t3)
addi $t3, $t4,  27012
sw $t5, 0($t3)
addi $t3, $t4,  27016
li $t5, 0x010000
sw $t5, 0($t3)
addi $t3, $t4,  27020
li $t5, 0x010001
sw $t5, 0($t3)
addi $t3, $t4,  27024
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  27028
sw $t5, 0($t3)
addi $t3, $t4,  27032
sw $t5, 0($t3)
addi $t3, $t4,  27036
sw $t5, 0($t3)
addi $t3, $t4,  27040
sw $t5, 0($t3)
addi $t3, $t4,  27044
li $t5, 0x000101
sw $t5, 0($t3)
addi $t3, $t4,  27048
li $t5, 0x000100
sw $t5, 0($t3)
addi $t3, $t4,  27052
li $t5, 0x000001
sw $t5, 0($t3)
addi $t3, $t4,  27056
li $t5, 0x000000
sw $t5, 0($t3)
addi $t3, $t4,  27060
sw $t5, 0($t3)
addi $t3, $t4,  27064
sw $t5, 0($t3)
addi $t3, $t4,  27068
sw $t5, 0($t3)
addi $t3, $t4,  27072
sw $t5, 0($t3)
addi $t3, $t4,  27076
sw $t5, 0($t3)
addi $t3, $t4,  27080
sw $t5, 0($t3)
addi $t3, $t4,  27084
sw $t5, 0($t3)
addi $t3, $t4,  27088
sw $t5, 0($t3)
addi $t3, $t4,  27092
sw $t5, 0($t3)
addi $t3, $t4,  27096
sw $t5, 0($t3)
addi $t3, $t4,  27100
sw $t5, 0($t3)
addi $t3, $t4,  27104
sw $t5, 0($t3)
addi $t3, $t4,  27108
sw $t5, 0($t3)
addi $t3, $t4,  27112
sw $t5, 0($t3)
addi $t3, $t4,  27116
sw $t5, 0($t3)
addi $t3, $t4,  27120
sw $t5, 0($t3)
addi $t3, $t4,  27124
sw $t5, 0($t3)
addi $t3, $t4,  27128
sw $t5, 0($t3)
addi $t3, $t4,  27132
sw $t5, 0($t3)
syscall #sleep for 30 ms
addi $t3, $t4,  27136
sw $t5, 0($t3)
addi $t3, $t4,  27140
sw $t5, 0($t3)
addi $t3, $t4,  27144
sw $t5, 0($t3)
addi $t3, $t4,  27148
sw $t5, 0($t3)
addi $t3, $t4,  27152
sw $t5, 0($t3)
addi $t3, $t4,  27156
sw $t5, 0($t3)
addi $t3, $t4,  27160
sw $t5, 0($t3)
addi $t3, $t4,  27164
sw $t5, 0($t3)
addi $t3, $t4,  27168
sw $t5, 0($t3)
addi $t3, $t4,  27172
sw $t5, 0($t3)
addi $t3, $t4,  27176
sw $t5, 0($t3)
addi $t3, $t4,  27180
sw $t5, 0($t3)
addi $t3, $t4,  27184
sw $t5, 0($t3)
addi $t3, $t4,  27188
sw $t5, 0($t3)
addi $t3, $t4,  27192
sw $t5, 0($t3)
addi $t3, $t4,  27196
sw $t5, 0($t3)
addi $t3, $t4,  27200
sw $t5, 0($t3)
addi $t3, $t4,  27204
sw $t5, 0($t3)
addi $t3, $t4,  27208
sw $t5, 0($t3)
addi $t3, $t4,  27212
sw $t5, 0($t3)
addi $t3, $t4,  27216
sw $t5, 0($t3)
addi $t3, $t4,  27220
sw $t5, 0($t3)
addi $t3, $t4,  27224
sw $t5, 0($t3)
addi $t3, $t4,  27228
sw $t5, 0($t3)
addi $t3, $t4,  27232
sw $t5, 0($t3)
addi $t3, $t4,  27236
sw $t5, 0($t3)
addi $t3, $t4,  27240
sw $t5, 0($t3)
addi $t3, $t4,  27244
sw $t5, 0($t3)
addi $t3, $t4,  27248
sw $t5, 0($t3)
addi $t3, $t4,  27252
sw $t5, 0($t3)
addi $t3, $t4,  27256
sw $t5, 0($t3)
addi $t3, $t4,  27260
sw $t5, 0($t3)
addi $t3, $t4,  27264
sw $t5, 0($t3)
addi $t3, $t4,  27268
sw $t5, 0($t3)
addi $t3, $t4,  27272
sw $t5, 0($t3)
addi $t3, $t4,  27276
sw $t5, 0($t3)
addi $t3, $t4,  27280
sw $t5, 0($t3)
addi $t3, $t4,  27284
sw $t5, 0($t3)
addi $t3, $t4,  27288
sw $t5, 0($t3)
addi $t3, $t4,  27292
sw $t5, 0($t3)
addi $t3, $t4,  27296
sw $t5, 0($t3)
addi $t3, $t4,  27300
sw $t5, 0($t3)
addi $t3, $t4,  27304
sw $t5, 0($t3)
addi $t3, $t4,  27308
sw $t5, 0($t3)
addi $t3, $t4,  27312
sw $t5, 0($t3)
addi $t3, $t4,  27316
sw $t5, 0($t3)
addi $t3, $t4,  27320
sw $t5, 0($t3)
addi $t3, $t4,  27324
sw $t5, 0($t3)
addi $t3, $t4,  27328
sw $t5, 0($t3)
addi $t3, $t4,  27332
sw $t5, 0($t3)
addi $t3, $t4,  27336
sw $t5, 0($t3)
addi $t3, $t4,  27340
sw $t5, 0($t3)
addi $t3, $t4,  27344
sw $t5, 0($t3)
addi $t3, $t4,  27348
sw $t5, 0($t3)
addi $t3, $t4,  27352
sw $t5, 0($t3)
addi $t3, $t4,  27356
sw $t5, 0($t3)
addi $t3, $t4,  27360
sw $t5, 0($t3)
addi $t3, $t4,  27364
sw $t5, 0($t3)
addi $t3, $t4,  27368
sw $t5, 0($t3)
addi $t3, $t4,  27372
sw $t5, 0($t3)
addi $t3, $t4,  27376
sw $t5, 0($t3)
addi $t3, $t4,  27380
sw $t5, 0($t3)
addi $t3, $t4,  27384
sw $t5, 0($t3)
addi $t3, $t4,  27388
sw $t5, 0($t3)
addi $t3, $t4,  27392
sw $t5, 0($t3)
addi $t3, $t4,  27396
sw $t5, 0($t3)
addi $t3, $t4,  27400
sw $t5, 0($t3)
addi $t3, $t4,  27404
sw $t5, 0($t3)
addi $t3, $t4,  27408
sw $t5, 0($t3)
addi $t3, $t4,  27412
sw $t5, 0($t3)
addi $t3, $t4,  27416
sw $t5, 0($t3)
addi $t3, $t4,  27420
sw $t5, 0($t3)
addi $t3, $t4,  27424
sw $t5, 0($t3)
addi $t3, $t4,  27428
sw $t5, 0($t3)
addi $t3, $t4,  27432
sw $t5, 0($t3)
addi $t3, $t4,  27436
sw $t5, 0($t3)
addi $t3, $t4,  27440
sw $t5, 0($t3)
addi $t3, $t4,  27444
sw $t5, 0($t3)
addi $t3, $t4,  27448
sw $t5, 0($t3)
addi $t3, $t4,  27452
sw $t5, 0($t3)
addi $t3, $t4,  27456
sw $t5, 0($t3)
addi $t3, $t4,  27460
sw $t5, 0($t3)
addi $t3, $t4,  27464
sw $t5, 0($t3)
addi $t3, $t4,  27468
sw $t5, 0($t3)
addi $t3, $t4,  27472
sw $t5, 0($t3)
addi $t3, $t4,  27476
sw $t5, 0($t3)
addi $t3, $t4,  27480
sw $t5, 0($t3)
addi $t3, $t4,  27484
sw $t5, 0($t3)
addi $t3, $t4,  27488
sw $t5, 0($t3)
addi $t3, $t4,  27492
sw $t5, 0($t3)
addi $t3, $t4,  27496
sw $t5, 0($t3)
addi $t3, $t4,  27500
sw $t5, 0($t3)
addi $t3, $t4,  27504
sw $t5, 0($t3)
addi $t3, $t4,  27508
sw $t5, 0($t3)
addi $t3, $t4,  27512
sw $t5, 0($t3)
addi $t3, $t4,  27516
sw $t5, 0($t3)
addi $t3, $t4,  27520
sw $t5, 0($t3)
addi $t3, $t4,  27524
sw $t5, 0($t3)
addi $t3, $t4,  27528
sw $t5, 0($t3)
addi $t3, $t4,  27532
sw $t5, 0($t3)
addi $t3, $t4,  27536
sw $t5, 0($t3)
addi $t3, $t4,  27540
sw $t5, 0($t3)
addi $t3, $t4,  27544
sw $t5, 0($t3)
addi $t3, $t4,  27548
sw $t5, 0($t3)
addi $t3, $t4,  27552
sw $t5, 0($t3)
addi $t3, $t4,  27556
sw $t5, 0($t3)
addi $t3, $t4,  27560
sw $t5, 0($t3)
addi $t3, $t4,  27564
sw $t5, 0($t3)
addi $t3, $t4,  27568
sw $t5, 0($t3)
addi $t3, $t4,  27572
sw $t5, 0($t3)
addi $t3, $t4,  27576
sw $t5, 0($t3)
addi $t3, $t4,  27580
sw $t5, 0($t3)
addi $t3, $t4,  27584
sw $t5, 0($t3)
addi $t3, $t4,  27588
sw $t5, 0($t3)
addi $t3, $t4,  27592
sw $t5, 0($t3)
addi $t3, $t4,  27596
sw $t5, 0($t3)
addi $t3, $t4,  27600
sw $t5, 0($t3)
addi $t3, $t4,  27604
sw $t5, 0($t3)
addi $t3, $t4,  27608
sw $t5, 0($t3)
addi $t3, $t4,  27612
sw $t5, 0($t3)
addi $t3, $t4,  27616
sw $t5, 0($t3)
addi $t3, $t4,  27620
sw $t5, 0($t3)
addi $t3, $t4,  27624
sw $t5, 0($t3)
addi $t3, $t4,  27628
sw $t5, 0($t3)
addi $t3, $t4,  27632
sw $t5, 0($t3)
addi $t3, $t4,  27636
sw $t5, 0($t3)
addi $t3, $t4,  27640
sw $t5, 0($t3)
addi $t3, $t4,  27644
sw $t5, 0($t3)
syscall #sleep for 30 ms
addi $t3, $t4,  27648
sw $t5, 0($t3)
addi $t3, $t4,  27652
sw $t5, 0($t3)
addi $t3, $t4,  27656
sw $t5, 0($t3)
addi $t3, $t4,  27660
sw $t5, 0($t3)
addi $t3, $t4,  27664
sw $t5, 0($t3)
addi $t3, $t4,  27668
sw $t5, 0($t3)
addi $t3, $t4,  27672
sw $t5, 0($t3)
addi $t3, $t4,  27676
sw $t5, 0($t3)
addi $t3, $t4,  27680
sw $t5, 0($t3)
addi $t3, $t4,  27684
sw $t5, 0($t3)
addi $t3, $t4,  27688
sw $t5, 0($t3)
addi $t3, $t4,  27692
sw $t5, 0($t3)
addi $t3, $t4,  27696
sw $t5, 0($t3)
addi $t3, $t4,  27700
sw $t5, 0($t3)
addi $t3, $t4,  27704
sw $t5, 0($t3)
addi $t3, $t4,  27708
sw $t5, 0($t3)
addi $t3, $t4,  27712
sw $t5, 0($t3)
addi $t3, $t4,  27716
sw $t5, 0($t3)
addi $t3, $t4,  27720
sw $t5, 0($t3)
addi $t3, $t4,  27724
sw $t5, 0($t3)
addi $t3, $t4,  27728
sw $t5, 0($t3)
addi $t3, $t4,  27732
sw $t5, 0($t3)
addi $t3, $t4,  27736
sw $t5, 0($t3)
addi $t3, $t4,  27740
sw $t5, 0($t3)
addi $t3, $t4,  27744
sw $t5, 0($t3)
addi $t3, $t4,  27748
sw $t5, 0($t3)
addi $t3, $t4,  27752
sw $t5, 0($t3)
addi $t3, $t4,  27756
sw $t5, 0($t3)
addi $t3, $t4,  27760
sw $t5, 0($t3)
addi $t3, $t4,  27764
sw $t5, 0($t3)
addi $t3, $t4,  27768
sw $t5, 0($t3)
addi $t3, $t4,  27772
sw $t5, 0($t3)
addi $t3, $t4,  27776
sw $t5, 0($t3)
addi $t3, $t4,  27780
sw $t5, 0($t3)
addi $t3, $t4,  27784
sw $t5, 0($t3)
addi $t3, $t4,  27788
sw $t5, 0($t3)
addi $t3, $t4,  27792
sw $t5, 0($t3)
addi $t3, $t4,  27796
sw $t5, 0($t3)
addi $t3, $t4,  27800
sw $t5, 0($t3)
addi $t3, $t4,  27804
sw $t5, 0($t3)
addi $t3, $t4,  27808
sw $t5, 0($t3)
addi $t3, $t4,  27812
sw $t5, 0($t3)
addi $t3, $t4,  27816
sw $t5, 0($t3)
addi $t3, $t4,  27820
sw $t5, 0($t3)
addi $t3, $t4,  27824
sw $t5, 0($t3)
addi $t3, $t4,  27828
sw $t5, 0($t3)
addi $t3, $t4,  27832
sw $t5, 0($t3)
addi $t3, $t4,  27836
sw $t5, 0($t3)
addi $t3, $t4,  27840
sw $t5, 0($t3)
addi $t3, $t4,  27844
sw $t5, 0($t3)
addi $t3, $t4,  27848
sw $t5, 0($t3)
addi $t3, $t4,  27852
sw $t5, 0($t3)
addi $t3, $t4,  27856
sw $t5, 0($t3)
addi $t3, $t4,  27860
sw $t5, 0($t3)
addi $t3, $t4,  27864
sw $t5, 0($t3)
addi $t3, $t4,  27868
sw $t5, 0($t3)
addi $t3, $t4,  27872
sw $t5, 0($t3)
addi $t3, $t4,  27876
sw $t5, 0($t3)
addi $t3, $t4,  27880
sw $t5, 0($t3)
addi $t3, $t4,  27884
sw $t5, 0($t3)
addi $t3, $t4,  27888
sw $t5, 0($t3)
addi $t3, $t4,  27892
sw $t5, 0($t3)
addi $t3, $t4,  27896
sw $t5, 0($t3)
addi $t3, $t4,  27900
sw $t5, 0($t3)
addi $t3, $t4,  27904
sw $t5, 0($t3)
addi $t3, $t4,  27908
sw $t5, 0($t3)
addi $t3, $t4,  27912
sw $t5, 0($t3)
addi $t3, $t4,  27916
sw $t5, 0($t3)
addi $t3, $t4,  27920
sw $t5, 0($t3)
addi $t3, $t4,  27924
sw $t5, 0($t3)
addi $t3, $t4,  27928
sw $t5, 0($t3)
addi $t3, $t4,  27932
sw $t5, 0($t3)
addi $t3, $t4,  27936
sw $t5, 0($t3)
addi $t3, $t4,  27940
sw $t5, 0($t3)
addi $t3, $t4,  27944
sw $t5, 0($t3)
addi $t3, $t4,  27948
sw $t5, 0($t3)
addi $t3, $t4,  27952
sw $t5, 0($t3)
addi $t3, $t4,  27956
sw $t5, 0($t3)
addi $t3, $t4,  27960
sw $t5, 0($t3)
addi $t3, $t4,  27964
sw $t5, 0($t3)
addi $t3, $t4,  27968
sw $t5, 0($t3)
addi $t3, $t4,  27972
sw $t5, 0($t3)
addi $t3, $t4,  27976
sw $t5, 0($t3)
addi $t3, $t4,  27980
sw $t5, 0($t3)
addi $t3, $t4,  27984
sw $t5, 0($t3)
addi $t3, $t4,  27988
sw $t5, 0($t3)
addi $t3, $t4,  27992
sw $t5, 0($t3)
addi $t3, $t4,  27996
sw $t5, 0($t3)
addi $t3, $t4,  28000
sw $t5, 0($t3)
addi $t3, $t4,  28004
sw $t5, 0($t3)
addi $t3, $t4,  28008
sw $t5, 0($t3)
addi $t3, $t4,  28012
sw $t5, 0($t3)
addi $t3, $t4,  28016
sw $t5, 0($t3)
addi $t3, $t4,  28020
sw $t5, 0($t3)
addi $t3, $t4,  28024
sw $t5, 0($t3)
addi $t3, $t4,  28028
sw $t5, 0($t3)
addi $t3, $t4,  28032
sw $t5, 0($t3)
addi $t3, $t4,  28036
sw $t5, 0($t3)
addi $t3, $t4,  28040
sw $t5, 0($t3)
addi $t3, $t4,  28044
sw $t5, 0($t3)
addi $t3, $t4,  28048
sw $t5, 0($t3)
addi $t3, $t4,  28052
sw $t5, 0($t3)
addi $t3, $t4,  28056
sw $t5, 0($t3)
addi $t3, $t4,  28060
sw $t5, 0($t3)
addi $t3, $t4,  28064
sw $t5, 0($t3)
addi $t3, $t4,  28068
sw $t5, 0($t3)
addi $t3, $t4,  28072
sw $t5, 0($t3)
addi $t3, $t4,  28076
sw $t5, 0($t3)
addi $t3, $t4,  28080
sw $t5, 0($t3)
addi $t3, $t4,  28084
sw $t5, 0($t3)
addi $t3, $t4,  28088
sw $t5, 0($t3)
addi $t3, $t4,  28092
sw $t5, 0($t3)
addi $t3, $t4,  28096
sw $t5, 0($t3)
addi $t3, $t4,  28100
sw $t5, 0($t3)
addi $t3, $t4,  28104
sw $t5, 0($t3)
addi $t3, $t4,  28108
sw $t5, 0($t3)
addi $t3, $t4,  28112
sw $t5, 0($t3)
addi $t3, $t4,  28116
sw $t5, 0($t3)
addi $t3, $t4,  28120
sw $t5, 0($t3)
addi $t3, $t4,  28124
sw $t5, 0($t3)
addi $t3, $t4,  28128
sw $t5, 0($t3)
addi $t3, $t4,  28132
sw $t5, 0($t3)
addi $t3, $t4,  28136
sw $t5, 0($t3)
addi $t3, $t4,  28140
sw $t5, 0($t3)
addi $t3, $t4,  28144
sw $t5, 0($t3)
addi $t3, $t4,  28148
sw $t5, 0($t3)
addi $t3, $t4,  28152
sw $t5, 0($t3)
addi $t3, $t4,  28156
sw $t5, 0($t3)
syscall #sleep for 30 ms
addi $t3, $t4,  28160
sw $t5, 0($t3)
addi $t3, $t4,  28164
sw $t5, 0($t3)
addi $t3, $t4,  28168
sw $t5, 0($t3)
addi $t3, $t4,  28172
sw $t5, 0($t3)
addi $t3, $t4,  28176
sw $t5, 0($t3)
addi $t3, $t4,  28180
sw $t5, 0($t3)
addi $t3, $t4,  28184
sw $t5, 0($t3)
addi $t3, $t4,  28188
sw $t5, 0($t3)
addi $t3, $t4,  28192
sw $t5, 0($t3)
addi $t3, $t4,  28196
sw $t5, 0($t3)
addi $t3, $t4,  28200
sw $t5, 0($t3)
addi $t3, $t4,  28204
sw $t5, 0($t3)
addi $t3, $t4,  28208
sw $t5, 0($t3)
addi $t3, $t4,  28212
sw $t5, 0($t3)
addi $t3, $t4,  28216
sw $t5, 0($t3)
addi $t3, $t4,  28220
sw $t5, 0($t3)
addi $t3, $t4,  28224
sw $t5, 0($t3)
addi $t3, $t4,  28228
sw $t5, 0($t3)
addi $t3, $t4,  28232
sw $t5, 0($t3)
addi $t3, $t4,  28236
sw $t5, 0($t3)
addi $t3, $t4,  28240
sw $t5, 0($t3)
addi $t3, $t4,  28244
sw $t5, 0($t3)
addi $t3, $t4,  28248
sw $t5, 0($t3)
addi $t3, $t4,  28252
sw $t5, 0($t3)
addi $t3, $t4,  28256
sw $t5, 0($t3)
addi $t3, $t4,  28260
sw $t5, 0($t3)
addi $t3, $t4,  28264
sw $t5, 0($t3)
addi $t3, $t4,  28268
sw $t5, 0($t3)
addi $t3, $t4,  28272
sw $t5, 0($t3)
addi $t3, $t4,  28276
sw $t5, 0($t3)
addi $t3, $t4,  28280
sw $t5, 0($t3)
addi $t3, $t4,  28284
sw $t5, 0($t3)
addi $t3, $t4,  28288
sw $t5, 0($t3)
addi $t3, $t4,  28292
sw $t5, 0($t3)
addi $t3, $t4,  28296
sw $t5, 0($t3)
addi $t3, $t4,  28300
sw $t5, 0($t3)
addi $t3, $t4,  28304
sw $t5, 0($t3)
addi $t3, $t4,  28308
sw $t5, 0($t3)
addi $t3, $t4,  28312
sw $t5, 0($t3)
addi $t3, $t4,  28316
sw $t5, 0($t3)
addi $t3, $t4,  28320
sw $t5, 0($t3)
addi $t3, $t4,  28324
sw $t5, 0($t3)
addi $t3, $t4,  28328
sw $t5, 0($t3)
addi $t3, $t4,  28332
sw $t5, 0($t3)
addi $t3, $t4,  28336
sw $t5, 0($t3)
addi $t3, $t4,  28340
sw $t5, 0($t3)
addi $t3, $t4,  28344
sw $t5, 0($t3)
addi $t3, $t4,  28348
sw $t5, 0($t3)
addi $t3, $t4,  28352
sw $t5, 0($t3)
addi $t3, $t4,  28356
sw $t5, 0($t3)
addi $t3, $t4,  28360
sw $t5, 0($t3)
addi $t3, $t4,  28364
sw $t5, 0($t3)
addi $t3, $t4,  28368
sw $t5, 0($t3)
addi $t3, $t4,  28372
sw $t5, 0($t3)
addi $t3, $t4,  28376
sw $t5, 0($t3)
addi $t3, $t4,  28380
sw $t5, 0($t3)
addi $t3, $t4,  28384
sw $t5, 0($t3)
addi $t3, $t4,  28388
sw $t5, 0($t3)
addi $t3, $t4,  28392
sw $t5, 0($t3)
addi $t3, $t4,  28396
sw $t5, 0($t3)
addi $t3, $t4,  28400
sw $t5, 0($t3)
addi $t3, $t4,  28404
sw $t5, 0($t3)
addi $t3, $t4,  28408
sw $t5, 0($t3)
addi $t3, $t4,  28412
sw $t5, 0($t3)
addi $t3, $t4,  28416
sw $t5, 0($t3)
addi $t3, $t4,  28420
sw $t5, 0($t3)
addi $t3, $t4,  28424
sw $t5, 0($t3)
addi $t3, $t4,  28428
sw $t5, 0($t3)
addi $t3, $t4,  28432
sw $t5, 0($t3)
addi $t3, $t4,  28436
sw $t5, 0($t3)
addi $t3, $t4,  28440
sw $t5, 0($t3)
addi $t3, $t4,  28444
sw $t5, 0($t3)
addi $t3, $t4,  28448
sw $t5, 0($t3)
addi $t3, $t4,  28452
sw $t5, 0($t3)
addi $t3, $t4,  28456
sw $t5, 0($t3)
addi $t3, $t4,  28460
sw $t5, 0($t3)
addi $t3, $t4,  28464
sw $t5, 0($t3)
addi $t3, $t4,  28468
sw $t5, 0($t3)
addi $t3, $t4,  28472
sw $t5, 0($t3)
addi $t3, $t4,  28476
sw $t5, 0($t3)
addi $t3, $t4,  28480
sw $t5, 0($t3)
addi $t3, $t4,  28484
sw $t5, 0($t3)
addi $t3, $t4,  28488
sw $t5, 0($t3)
addi $t3, $t4,  28492
sw $t5, 0($t3)
addi $t3, $t4,  28496
sw $t5, 0($t3)
addi $t3, $t4,  28500
sw $t5, 0($t3)
addi $t3, $t4,  28504
sw $t5, 0($t3)
addi $t3, $t4,  28508
sw $t5, 0($t3)
addi $t3, $t4,  28512
sw $t5, 0($t3)
addi $t3, $t4,  28516
sw $t5, 0($t3)
addi $t3, $t4,  28520
sw $t5, 0($t3)
addi $t3, $t4,  28524
sw $t5, 0($t3)
addi $t3, $t4,  28528
sw $t5, 0($t3)
addi $t3, $t4,  28532
sw $t5, 0($t3)
addi $t3, $t4,  28536
sw $t5, 0($t3)
addi $t3, $t4,  28540
sw $t5, 0($t3)
addi $t3, $t4,  28544
sw $t5, 0($t3)
addi $t3, $t4,  28548
sw $t5, 0($t3)
addi $t3, $t4,  28552
sw $t5, 0($t3)
addi $t3, $t4,  28556
sw $t5, 0($t3)
addi $t3, $t4,  28560
sw $t5, 0($t3)
addi $t3, $t4,  28564
sw $t5, 0($t3)
addi $t3, $t4,  28568
sw $t5, 0($t3)
addi $t3, $t4,  28572
sw $t5, 0($t3)
addi $t3, $t4,  28576
sw $t5, 0($t3)
addi $t3, $t4,  28580
sw $t5, 0($t3)
addi $t3, $t4,  28584
sw $t5, 0($t3)
addi $t3, $t4,  28588
sw $t5, 0($t3)
addi $t3, $t4,  28592
sw $t5, 0($t3)
addi $t3, $t4,  28596
sw $t5, 0($t3)
addi $t3, $t4,  28600
sw $t5, 0($t3)
addi $t3, $t4,  28604
sw $t5, 0($t3)
addi $t3, $t4,  28608
sw $t5, 0($t3)
addi $t3, $t4,  28612
sw $t5, 0($t3)
addi $t3, $t4,  28616
sw $t5, 0($t3)
addi $t3, $t4,  28620
sw $t5, 0($t3)
addi $t3, $t4,  28624
sw $t5, 0($t3)
addi $t3, $t4,  28628
sw $t5, 0($t3)
addi $t3, $t4,  28632
sw $t5, 0($t3)
addi $t3, $t4,  28636
sw $t5, 0($t3)
addi $t3, $t4,  28640
sw $t5, 0($t3)
addi $t3, $t4,  28644
sw $t5, 0($t3)
addi $t3, $t4,  28648
sw $t5, 0($t3)
addi $t3, $t4,  28652
sw $t5, 0($t3)
addi $t3, $t4,  28656
sw $t5, 0($t3)
addi $t3, $t4,  28660
sw $t5, 0($t3)
addi $t3, $t4,  28664
sw $t5, 0($t3)
addi $t3, $t4,  28668
sw $t5, 0($t3)
syscall #sleep for 30 ms
addi $t3, $t4,  28672
sw $t5, 0($t3)
addi $t3, $t4,  28676
sw $t5, 0($t3)
addi $t3, $t4,  28680
sw $t5, 0($t3)
addi $t3, $t4,  28684
sw $t5, 0($t3)
addi $t3, $t4,  28688
sw $t5, 0($t3)
addi $t3, $t4,  28692
sw $t5, 0($t3)
addi $t3, $t4,  28696
sw $t5, 0($t3)
addi $t3, $t4,  28700
sw $t5, 0($t3)
addi $t3, $t4,  28704
sw $t5, 0($t3)
addi $t3, $t4,  28708
sw $t5, 0($t3)
addi $t3, $t4,  28712
sw $t5, 0($t3)
addi $t3, $t4,  28716
sw $t5, 0($t3)
addi $t3, $t4,  28720
sw $t5, 0($t3)
addi $t3, $t4,  28724
sw $t5, 0($t3)
addi $t3, $t4,  28728
sw $t5, 0($t3)
addi $t3, $t4,  28732
sw $t5, 0($t3)
addi $t3, $t4,  28736
sw $t5, 0($t3)
addi $t3, $t4,  28740
sw $t5, 0($t3)
addi $t3, $t4,  28744
sw $t5, 0($t3)
addi $t3, $t4,  28748
sw $t5, 0($t3)
addi $t3, $t4,  28752
sw $t5, 0($t3)
addi $t3, $t4,  28756
sw $t5, 0($t3)
addi $t3, $t4,  28760
sw $t5, 0($t3)
addi $t3, $t4,  28764
sw $t5, 0($t3)
addi $t3, $t4,  28768
sw $t5, 0($t3)
addi $t3, $t4,  28772
sw $t5, 0($t3)
addi $t3, $t4,  28776
sw $t5, 0($t3)
addi $t3, $t4,  28780
sw $t5, 0($t3)
addi $t3, $t4,  28784
sw $t5, 0($t3)
addi $t3, $t4,  28788
sw $t5, 0($t3)
addi $t3, $t4,  28792
sw $t5, 0($t3)
addi $t3, $t4,  28796
sw $t5, 0($t3)
addi $t3, $t4,  28800
sw $t5, 0($t3)
addi $t3, $t4,  28804
sw $t5, 0($t3)
addi $t3, $t4,  28808
sw $t5, 0($t3)
addi $t3, $t4,  28812
sw $t5, 0($t3)
addi $t3, $t4,  28816
sw $t5, 0($t3)
addi $t3, $t4,  28820
sw $t5, 0($t3)
addi $t3, $t4,  28824
sw $t5, 0($t3)
addi $t3, $t4,  28828
sw $t5, 0($t3)
addi $t3, $t4,  28832
sw $t5, 0($t3)
addi $t3, $t4,  28836
sw $t5, 0($t3)
addi $t3, $t4,  28840
sw $t5, 0($t3)
addi $t3, $t4,  28844
sw $t5, 0($t3)
addi $t3, $t4,  28848
sw $t5, 0($t3)
addi $t3, $t4,  28852
sw $t5, 0($t3)
addi $t3, $t4,  28856
sw $t5, 0($t3)
addi $t3, $t4,  28860
sw $t5, 0($t3)
addi $t3, $t4,  28864
sw $t5, 0($t3)
addi $t3, $t4,  28868
sw $t5, 0($t3)
addi $t3, $t4,  28872
sw $t5, 0($t3)
addi $t3, $t4,  28876
sw $t5, 0($t3)
addi $t3, $t4,  28880
sw $t5, 0($t3)
addi $t3, $t4,  28884
sw $t5, 0($t3)
addi $t3, $t4,  28888
sw $t5, 0($t3)
addi $t3, $t4,  28892
sw $t5, 0($t3)
addi $t3, $t4,  28896
sw $t5, 0($t3)
addi $t3, $t4,  28900
sw $t5, 0($t3)
addi $t3, $t4,  28904
sw $t5, 0($t3)
addi $t3, $t4,  28908
sw $t5, 0($t3)
addi $t3, $t4,  28912
sw $t5, 0($t3)
addi $t3, $t4,  28916
sw $t5, 0($t3)
addi $t3, $t4,  28920
sw $t5, 0($t3)
addi $t3, $t4,  28924
sw $t5, 0($t3)
addi $t3, $t4,  28928
sw $t5, 0($t3)
addi $t3, $t4,  28932
sw $t5, 0($t3)
addi $t3, $t4,  28936
sw $t5, 0($t3)
addi $t3, $t4,  28940
sw $t5, 0($t3)
addi $t3, $t4,  28944
sw $t5, 0($t3)
addi $t3, $t4,  28948
sw $t5, 0($t3)
addi $t3, $t4,  28952
sw $t5, 0($t3)
addi $t3, $t4,  28956
sw $t5, 0($t3)
addi $t3, $t4,  28960
sw $t5, 0($t3)
addi $t3, $t4,  28964
sw $t5, 0($t3)
addi $t3, $t4,  28968
sw $t5, 0($t3)
addi $t3, $t4,  28972
sw $t5, 0($t3)
addi $t3, $t4,  28976
sw $t5, 0($t3)
addi $t3, $t4,  28980
sw $t5, 0($t3)
addi $t3, $t4,  28984
sw $t5, 0($t3)
addi $t3, $t4,  28988
sw $t5, 0($t3)
addi $t3, $t4,  28992
sw $t5, 0($t3)
addi $t3, $t4,  28996
sw $t5, 0($t3)
addi $t3, $t4,  29000
sw $t5, 0($t3)
addi $t3, $t4,  29004
sw $t5, 0($t3)
addi $t3, $t4,  29008
sw $t5, 0($t3)
addi $t3, $t4,  29012
sw $t5, 0($t3)
addi $t3, $t4,  29016
sw $t5, 0($t3)
addi $t3, $t4,  29020
sw $t5, 0($t3)
addi $t3, $t4,  29024
sw $t5, 0($t3)
addi $t3, $t4,  29028
sw $t5, 0($t3)
addi $t3, $t4,  29032
sw $t5, 0($t3)
addi $t3, $t4,  29036
sw $t5, 0($t3)
addi $t3, $t4,  29040
sw $t5, 0($t3)
addi $t3, $t4,  29044
sw $t5, 0($t3)
addi $t3, $t4,  29048
sw $t5, 0($t3)
addi $t3, $t4,  29052
sw $t5, 0($t3)
addi $t3, $t4,  29056
sw $t5, 0($t3)
addi $t3, $t4,  29060
sw $t5, 0($t3)
addi $t3, $t4,  29064
sw $t5, 0($t3)
addi $t3, $t4,  29068
sw $t5, 0($t3)
addi $t3, $t4,  29072
sw $t5, 0($t3)
addi $t3, $t4,  29076
sw $t5, 0($t3)
addi $t3, $t4,  29080
sw $t5, 0($t3)
addi $t3, $t4,  29084
sw $t5, 0($t3)
addi $t3, $t4,  29088
sw $t5, 0($t3)
addi $t3, $t4,  29092
sw $t5, 0($t3)
addi $t3, $t4,  29096
sw $t5, 0($t3)
addi $t3, $t4,  29100
sw $t5, 0($t3)
addi $t3, $t4,  29104
sw $t5, 0($t3)
addi $t3, $t4,  29108
sw $t5, 0($t3)
addi $t3, $t4,  29112
sw $t5, 0($t3)
addi $t3, $t4,  29116
sw $t5, 0($t3)
addi $t3, $t4,  29120
sw $t5, 0($t3)
addi $t3, $t4,  29124
sw $t5, 0($t3)
addi $t3, $t4,  29128
sw $t5, 0($t3)
addi $t3, $t4,  29132
sw $t5, 0($t3)
addi $t3, $t4,  29136
sw $t5, 0($t3)
addi $t3, $t4,  29140
sw $t5, 0($t3)
addi $t3, $t4,  29144
sw $t5, 0($t3)
addi $t3, $t4,  29148
sw $t5, 0($t3)
addi $t3, $t4,  29152
sw $t5, 0($t3)
addi $t3, $t4,  29156
sw $t5, 0($t3)
addi $t3, $t4,  29160
sw $t5, 0($t3)
addi $t3, $t4,  29164
sw $t5, 0($t3)
addi $t3, $t4,  29168
sw $t5, 0($t3)
addi $t3, $t4,  29172
sw $t5, 0($t3)
addi $t3, $t4,  29176
sw $t5, 0($t3)
addi $t3, $t4,  29180
sw $t5, 0($t3)
syscall #sleep for 30 ms
addi $t3, $t4,  29184
sw $t5, 0($t3)
addi $t3, $t4,  29188
sw $t5, 0($t3)
addi $t3, $t4,  29192
sw $t5, 0($t3)
addi $t3, $t4,  29196
sw $t5, 0($t3)
addi $t3, $t4,  29200
sw $t5, 0($t3)
addi $t3, $t4,  29204
sw $t5, 0($t3)
addi $t3, $t4,  29208
sw $t5, 0($t3)
addi $t3, $t4,  29212
sw $t5, 0($t3)
addi $t3, $t4,  29216
sw $t5, 0($t3)
addi $t3, $t4,  29220
sw $t5, 0($t3)
addi $t3, $t4,  29224
sw $t5, 0($t3)
addi $t3, $t4,  29228
sw $t5, 0($t3)
addi $t3, $t4,  29232
sw $t5, 0($t3)
addi $t3, $t4,  29236
sw $t5, 0($t3)
addi $t3, $t4,  29240
sw $t5, 0($t3)
addi $t3, $t4,  29244
sw $t5, 0($t3)
addi $t3, $t4,  29248
sw $t5, 0($t3)
addi $t3, $t4,  29252
sw $t5, 0($t3)
addi $t3, $t4,  29256
sw $t5, 0($t3)
addi $t3, $t4,  29260
sw $t5, 0($t3)
addi $t3, $t4,  29264
sw $t5, 0($t3)
addi $t3, $t4,  29268
sw $t5, 0($t3)
addi $t3, $t4,  29272
sw $t5, 0($t3)
addi $t3, $t4,  29276
sw $t5, 0($t3)
addi $t3, $t4,  29280
sw $t5, 0($t3)
addi $t3, $t4,  29284
sw $t5, 0($t3)
addi $t3, $t4,  29288
sw $t5, 0($t3)
addi $t3, $t4,  29292
sw $t5, 0($t3)
addi $t3, $t4,  29296
sw $t5, 0($t3)
addi $t3, $t4,  29300
sw $t5, 0($t3)
addi $t3, $t4,  29304
sw $t5, 0($t3)
addi $t3, $t4,  29308
sw $t5, 0($t3)
addi $t3, $t4,  29312
sw $t5, 0($t3)
addi $t3, $t4,  29316
sw $t5, 0($t3)
addi $t3, $t4,  29320
sw $t5, 0($t3)
addi $t3, $t4,  29324
sw $t5, 0($t3)
addi $t3, $t4,  29328
sw $t5, 0($t3)
addi $t3, $t4,  29332
sw $t5, 0($t3)
addi $t3, $t4,  29336
sw $t5, 0($t3)
addi $t3, $t4,  29340
sw $t5, 0($t3)
addi $t3, $t4,  29344
sw $t5, 0($t3)
addi $t3, $t4,  29348
sw $t5, 0($t3)
addi $t3, $t4,  29352
sw $t5, 0($t3)
addi $t3, $t4,  29356
sw $t5, 0($t3)
addi $t3, $t4,  29360
sw $t5, 0($t3)
addi $t3, $t4,  29364
sw $t5, 0($t3)
addi $t3, $t4,  29368
sw $t5, 0($t3)
addi $t3, $t4,  29372
sw $t5, 0($t3)
addi $t3, $t4,  29376
sw $t5, 0($t3)
addi $t3, $t4,  29380
sw $t5, 0($t3)
addi $t3, $t4,  29384
sw $t5, 0($t3)
addi $t3, $t4,  29388
sw $t5, 0($t3)
addi $t3, $t4,  29392
sw $t5, 0($t3)
addi $t3, $t4,  29396
sw $t5, 0($t3)
addi $t3, $t4,  29400
sw $t5, 0($t3)
addi $t3, $t4,  29404
sw $t5, 0($t3)
addi $t3, $t4,  29408
sw $t5, 0($t3)
addi $t3, $t4,  29412
sw $t5, 0($t3)
addi $t3, $t4,  29416
sw $t5, 0($t3)
addi $t3, $t4,  29420
sw $t5, 0($t3)
addi $t3, $t4,  29424
sw $t5, 0($t3)
addi $t3, $t4,  29428
sw $t5, 0($t3)
addi $t3, $t4,  29432
sw $t5, 0($t3)
addi $t3, $t4,  29436
sw $t5, 0($t3)
addi $t3, $t4,  29440
sw $t5, 0($t3)
addi $t3, $t4,  29444
sw $t5, 0($t3)
addi $t3, $t4,  29448
sw $t5, 0($t3)
addi $t3, $t4,  29452
sw $t5, 0($t3)
addi $t3, $t4,  29456
sw $t5, 0($t3)
addi $t3, $t4,  29460
sw $t5, 0($t3)
addi $t3, $t4,  29464
sw $t5, 0($t3)
addi $t3, $t4,  29468
sw $t5, 0($t3)
addi $t3, $t4,  29472
sw $t5, 0($t3)
addi $t3, $t4,  29476
sw $t5, 0($t3)
addi $t3, $t4,  29480
sw $t5, 0($t3)
addi $t3, $t4,  29484
sw $t5, 0($t3)
addi $t3, $t4,  29488
sw $t5, 0($t3)
addi $t3, $t4,  29492
sw $t5, 0($t3)
addi $t3, $t4,  29496
sw $t5, 0($t3)
addi $t3, $t4,  29500
sw $t5, 0($t3)
addi $t3, $t4,  29504
sw $t5, 0($t3)
addi $t3, $t4,  29508
sw $t5, 0($t3)
addi $t3, $t4,  29512
sw $t5, 0($t3)
addi $t3, $t4,  29516
sw $t5, 0($t3)
addi $t3, $t4,  29520
sw $t5, 0($t3)
addi $t3, $t4,  29524
sw $t5, 0($t3)
addi $t3, $t4,  29528
sw $t5, 0($t3)
addi $t3, $t4,  29532
sw $t5, 0($t3)
addi $t3, $t4,  29536
sw $t5, 0($t3)
addi $t3, $t4,  29540
sw $t5, 0($t3)
addi $t3, $t4,  29544
sw $t5, 0($t3)
addi $t3, $t4,  29548
sw $t5, 0($t3)
addi $t3, $t4,  29552
sw $t5, 0($t3)
addi $t3, $t4,  29556
sw $t5, 0($t3)
addi $t3, $t4,  29560
sw $t5, 0($t3)
addi $t3, $t4,  29564
sw $t5, 0($t3)
addi $t3, $t4,  29568
sw $t5, 0($t3)
addi $t3, $t4,  29572
sw $t5, 0($t3)
addi $t3, $t4,  29576
sw $t5, 0($t3)
addi $t3, $t4,  29580
sw $t5, 0($t3)
addi $t3, $t4,  29584
sw $t5, 0($t3)
addi $t3, $t4,  29588
sw $t5, 0($t3)
addi $t3, $t4,  29592
sw $t5, 0($t3)
addi $t3, $t4,  29596
sw $t5, 0($t3)
addi $t3, $t4,  29600
sw $t5, 0($t3)
addi $t3, $t4,  29604
sw $t5, 0($t3)
addi $t3, $t4,  29608
sw $t5, 0($t3)
addi $t3, $t4,  29612
sw $t5, 0($t3)
addi $t3, $t4,  29616
sw $t5, 0($t3)
addi $t3, $t4,  29620
sw $t5, 0($t3)
addi $t3, $t4,  29624
sw $t5, 0($t3)
addi $t3, $t4,  29628
sw $t5, 0($t3)
addi $t3, $t4,  29632
sw $t5, 0($t3)
addi $t3, $t4,  29636
sw $t5, 0($t3)
addi $t3, $t4,  29640
sw $t5, 0($t3)
addi $t3, $t4,  29644
sw $t5, 0($t3)
addi $t3, $t4,  29648
sw $t5, 0($t3)
addi $t3, $t4,  29652
sw $t5, 0($t3)
addi $t3, $t4,  29656
sw $t5, 0($t3)
addi $t3, $t4,  29660
sw $t5, 0($t3)
addi $t3, $t4,  29664
sw $t5, 0($t3)
addi $t3, $t4,  29668
sw $t5, 0($t3)
addi $t3, $t4,  29672
sw $t5, 0($t3)
addi $t3, $t4,  29676
sw $t5, 0($t3)
addi $t3, $t4,  29680
sw $t5, 0($t3)
addi $t3, $t4,  29684
sw $t5, 0($t3)
addi $t3, $t4,  29688
sw $t5, 0($t3)
addi $t3, $t4,  29692
sw $t5, 0($t3)
syscall #sleep for 30 ms
addi $t3, $t4,  29696
sw $t5, 0($t3)
addi $t3, $t4,  29700
sw $t5, 0($t3)
addi $t3, $t4,  29704
sw $t5, 0($t3)
addi $t3, $t4,  29708
sw $t5, 0($t3)
addi $t3, $t4,  29712
sw $t5, 0($t3)
addi $t3, $t4,  29716
sw $t5, 0($t3)
addi $t3, $t4,  29720
sw $t5, 0($t3)
addi $t3, $t4,  29724
sw $t5, 0($t3)
addi $t3, $t4,  29728
sw $t5, 0($t3)
addi $t3, $t4,  29732
sw $t5, 0($t3)
addi $t3, $t4,  29736
sw $t5, 0($t3)
addi $t3, $t4,  29740
sw $t5, 0($t3)
addi $t3, $t4,  29744
sw $t5, 0($t3)
addi $t3, $t4,  29748
sw $t5, 0($t3)
addi $t3, $t4,  29752
sw $t5, 0($t3)
addi $t3, $t4,  29756
sw $t5, 0($t3)
addi $t3, $t4,  29760
sw $t5, 0($t3)
addi $t3, $t4,  29764
sw $t5, 0($t3)
addi $t3, $t4,  29768
sw $t5, 0($t3)
addi $t3, $t4,  29772
sw $t5, 0($t3)
addi $t3, $t4,  29776
sw $t5, 0($t3)
addi $t3, $t4,  29780
sw $t5, 0($t3)
addi $t3, $t4,  29784
sw $t5, 0($t3)
addi $t3, $t4,  29788
sw $t5, 0($t3)
addi $t3, $t4,  29792
sw $t5, 0($t3)
addi $t3, $t4,  29796
sw $t5, 0($t3)
addi $t3, $t4,  29800
sw $t5, 0($t3)
addi $t3, $t4,  29804
sw $t5, 0($t3)
addi $t3, $t4,  29808
sw $t5, 0($t3)
addi $t3, $t4,  29812
sw $t5, 0($t3)
addi $t3, $t4,  29816
sw $t5, 0($t3)
addi $t3, $t4,  29820
sw $t5, 0($t3)
addi $t3, $t4,  29824
sw $t5, 0($t3)
addi $t3, $t4,  29828
sw $t5, 0($t3)
addi $t3, $t4,  29832
sw $t5, 0($t3)
addi $t3, $t4,  29836
sw $t5, 0($t3)
addi $t3, $t4,  29840
sw $t5, 0($t3)
addi $t3, $t4,  29844
sw $t5, 0($t3)
addi $t3, $t4,  29848
sw $t5, 0($t3)
addi $t3, $t4,  29852
sw $t5, 0($t3)
addi $t3, $t4,  29856
sw $t5, 0($t3)
addi $t3, $t4,  29860
sw $t5, 0($t3)
addi $t3, $t4,  29864
sw $t5, 0($t3)
addi $t3, $t4,  29868
sw $t5, 0($t3)
addi $t3, $t4,  29872
sw $t5, 0($t3)
addi $t3, $t4,  29876
sw $t5, 0($t3)
addi $t3, $t4,  29880
sw $t5, 0($t3)
addi $t3, $t4,  29884
sw $t5, 0($t3)
addi $t3, $t4,  29888
sw $t5, 0($t3)
addi $t3, $t4,  29892
sw $t5, 0($t3)
addi $t3, $t4,  29896
sw $t5, 0($t3)
addi $t3, $t4,  29900
sw $t5, 0($t3)
addi $t3, $t4,  29904
sw $t5, 0($t3)
addi $t3, $t4,  29908
sw $t5, 0($t3)
addi $t3, $t4,  29912
sw $t5, 0($t3)
addi $t3, $t4,  29916
sw $t5, 0($t3)
addi $t3, $t4,  29920
sw $t5, 0($t3)
addi $t3, $t4,  29924
sw $t5, 0($t3)
addi $t3, $t4,  29928
sw $t5, 0($t3)
addi $t3, $t4,  29932
sw $t5, 0($t3)
addi $t3, $t4,  29936
sw $t5, 0($t3)
addi $t3, $t4,  29940
sw $t5, 0($t3)
addi $t3, $t4,  29944
sw $t5, 0($t3)
addi $t3, $t4,  29948
sw $t5, 0($t3)
addi $t3, $t4,  29952
sw $t5, 0($t3)
addi $t3, $t4,  29956
sw $t5, 0($t3)
addi $t3, $t4,  29960
sw $t5, 0($t3)
addi $t3, $t4,  29964
sw $t5, 0($t3)
addi $t3, $t4,  29968
sw $t5, 0($t3)
addi $t3, $t4,  29972
sw $t5, 0($t3)
addi $t3, $t4,  29976
sw $t5, 0($t3)
addi $t3, $t4,  29980
sw $t5, 0($t3)
addi $t3, $t4,  29984
sw $t5, 0($t3)
addi $t3, $t4,  29988
sw $t5, 0($t3)
addi $t3, $t4,  29992
sw $t5, 0($t3)
addi $t3, $t4,  29996
sw $t5, 0($t3)
addi $t3, $t4,  30000
sw $t5, 0($t3)
addi $t3, $t4,  30004
sw $t5, 0($t3)
addi $t3, $t4,  30008
sw $t5, 0($t3)
addi $t3, $t4,  30012
sw $t5, 0($t3)
addi $t3, $t4,  30016
sw $t5, 0($t3)
addi $t3, $t4,  30020
sw $t5, 0($t3)
addi $t3, $t4,  30024
sw $t5, 0($t3)
addi $t3, $t4,  30028
sw $t5, 0($t3)
addi $t3, $t4,  30032
sw $t5, 0($t3)
addi $t3, $t4,  30036
sw $t5, 0($t3)
addi $t3, $t4,  30040
sw $t5, 0($t3)
addi $t3, $t4,  30044
sw $t5, 0($t3)
addi $t3, $t4,  30048
sw $t5, 0($t3)
addi $t3, $t4,  30052
sw $t5, 0($t3)
addi $t3, $t4,  30056
sw $t5, 0($t3)
addi $t3, $t4,  30060
sw $t5, 0($t3)
addi $t3, $t4,  30064
sw $t5, 0($t3)
addi $t3, $t4,  30068
sw $t5, 0($t3)
addi $t3, $t4,  30072
sw $t5, 0($t3)
addi $t3, $t4,  30076
sw $t5, 0($t3)
addi $t3, $t4,  30080
sw $t5, 0($t3)
addi $t3, $t4,  30084
sw $t5, 0($t3)
addi $t3, $t4,  30088
sw $t5, 0($t3)
addi $t3, $t4,  30092
sw $t5, 0($t3)
addi $t3, $t4,  30096
sw $t5, 0($t3)
addi $t3, $t4,  30100
sw $t5, 0($t3)
addi $t3, $t4,  30104
sw $t5, 0($t3)
addi $t3, $t4,  30108
sw $t5, 0($t3)
addi $t3, $t4,  30112
sw $t5, 0($t3)
addi $t3, $t4,  30116
sw $t5, 0($t3)
addi $t3, $t4,  30120
sw $t5, 0($t3)
addi $t3, $t4,  30124
sw $t5, 0($t3)
addi $t3, $t4,  30128
sw $t5, 0($t3)
addi $t3, $t4,  30132
sw $t5, 0($t3)
addi $t3, $t4,  30136
sw $t5, 0($t3)
addi $t3, $t4,  30140
sw $t5, 0($t3)
addi $t3, $t4,  30144
sw $t5, 0($t3)
addi $t3, $t4,  30148
sw $t5, 0($t3)
addi $t3, $t4,  30152
sw $t5, 0($t3)
addi $t3, $t4,  30156
sw $t5, 0($t3)
addi $t3, $t4,  30160
sw $t5, 0($t3)
addi $t3, $t4,  30164
sw $t5, 0($t3)
addi $t3, $t4,  30168
sw $t5, 0($t3)
addi $t3, $t4,  30172
sw $t5, 0($t3)
addi $t3, $t4,  30176
sw $t5, 0($t3)
addi $t3, $t4,  30180
sw $t5, 0($t3)
addi $t3, $t4,  30184
sw $t5, 0($t3)
addi $t3, $t4,  30188
sw $t5, 0($t3)
addi $t3, $t4,  30192
sw $t5, 0($t3)
addi $t3, $t4,  30196
sw $t5, 0($t3)
addi $t3, $t4,  30200
sw $t5, 0($t3)
addi $t3, $t4,  30204
sw $t5, 0($t3)
syscall #sleep for 30 ms
addi $t3, $t4,  30208
sw $t5, 0($t3)
addi $t3, $t4,  30212
sw $t5, 0($t3)
addi $t3, $t4,  30216
sw $t5, 0($t3)
addi $t3, $t4,  30220
sw $t5, 0($t3)
addi $t3, $t4,  30224
sw $t5, 0($t3)
addi $t3, $t4,  30228
sw $t5, 0($t3)
addi $t3, $t4,  30232
sw $t5, 0($t3)
addi $t3, $t4,  30236
sw $t5, 0($t3)
addi $t3, $t4,  30240
sw $t5, 0($t3)
addi $t3, $t4,  30244
sw $t5, 0($t3)
addi $t3, $t4,  30248
sw $t5, 0($t3)
addi $t3, $t4,  30252
sw $t5, 0($t3)
addi $t3, $t4,  30256
sw $t5, 0($t3)
addi $t3, $t4,  30260
sw $t5, 0($t3)
addi $t3, $t4,  30264
sw $t5, 0($t3)
addi $t3, $t4,  30268
sw $t5, 0($t3)
addi $t3, $t4,  30272
sw $t5, 0($t3)
addi $t3, $t4,  30276
sw $t5, 0($t3)
addi $t3, $t4,  30280
sw $t5, 0($t3)
addi $t3, $t4,  30284
sw $t5, 0($t3)
addi $t3, $t4,  30288
sw $t5, 0($t3)
addi $t3, $t4,  30292
sw $t5, 0($t3)
addi $t3, $t4,  30296
sw $t5, 0($t3)
addi $t3, $t4,  30300
sw $t5, 0($t3)
addi $t3, $t4,  30304
sw $t5, 0($t3)
addi $t3, $t4,  30308
sw $t5, 0($t3)
addi $t3, $t4,  30312
sw $t5, 0($t3)
addi $t3, $t4,  30316
sw $t5, 0($t3)
addi $t3, $t4,  30320
sw $t5, 0($t3)
addi $t3, $t4,  30324
sw $t5, 0($t3)
addi $t3, $t4,  30328
sw $t5, 0($t3)
addi $t3, $t4,  30332
sw $t5, 0($t3)
addi $t3, $t4,  30336
sw $t5, 0($t3)
addi $t3, $t4,  30340
sw $t5, 0($t3)
addi $t3, $t4,  30344
sw $t5, 0($t3)
addi $t3, $t4,  30348
sw $t5, 0($t3)
addi $t3, $t4,  30352
sw $t5, 0($t3)
addi $t3, $t4,  30356
sw $t5, 0($t3)
addi $t3, $t4,  30360
sw $t5, 0($t3)
addi $t3, $t4,  30364
sw $t5, 0($t3)
addi $t3, $t4,  30368
sw $t5, 0($t3)
addi $t3, $t4,  30372
sw $t5, 0($t3)
addi $t3, $t4,  30376
sw $t5, 0($t3)
addi $t3, $t4,  30380
sw $t5, 0($t3)
addi $t3, $t4,  30384
sw $t5, 0($t3)
addi $t3, $t4,  30388
sw $t5, 0($t3)
addi $t3, $t4,  30392
sw $t5, 0($t3)
addi $t3, $t4,  30396
sw $t5, 0($t3)
addi $t3, $t4,  30400
sw $t5, 0($t3)
addi $t3, $t4,  30404
sw $t5, 0($t3)
addi $t3, $t4,  30408
sw $t5, 0($t3)
addi $t3, $t4,  30412
sw $t5, 0($t3)
addi $t3, $t4,  30416
sw $t5, 0($t3)
addi $t3, $t4,  30420
sw $t5, 0($t3)
addi $t3, $t4,  30424
sw $t5, 0($t3)
addi $t3, $t4,  30428
sw $t5, 0($t3)
addi $t3, $t4,  30432
sw $t5, 0($t3)
addi $t3, $t4,  30436
sw $t5, 0($t3)
addi $t3, $t4,  30440
sw $t5, 0($t3)
addi $t3, $t4,  30444
sw $t5, 0($t3)
addi $t3, $t4,  30448
sw $t5, 0($t3)
addi $t3, $t4,  30452
sw $t5, 0($t3)
addi $t3, $t4,  30456
sw $t5, 0($t3)
addi $t3, $t4,  30460
sw $t5, 0($t3)
addi $t3, $t4,  30464
sw $t5, 0($t3)
addi $t3, $t4,  30468
sw $t5, 0($t3)
addi $t3, $t4,  30472
sw $t5, 0($t3)
addi $t3, $t4,  30476
sw $t5, 0($t3)
addi $t3, $t4,  30480
sw $t5, 0($t3)
addi $t3, $t4,  30484
sw $t5, 0($t3)
addi $t3, $t4,  30488
sw $t5, 0($t3)
addi $t3, $t4,  30492
sw $t5, 0($t3)
addi $t3, $t4,  30496
sw $t5, 0($t3)
addi $t3, $t4,  30500
sw $t5, 0($t3)
addi $t3, $t4,  30504
sw $t5, 0($t3)
addi $t3, $t4,  30508
sw $t5, 0($t3)
addi $t3, $t4,  30512
sw $t5, 0($t3)
addi $t3, $t4,  30516
sw $t5, 0($t3)
addi $t3, $t4,  30520
sw $t5, 0($t3)
addi $t3, $t4,  30524
sw $t5, 0($t3)
addi $t3, $t4,  30528
sw $t5, 0($t3)
addi $t3, $t4,  30532
sw $t5, 0($t3)
addi $t3, $t4,  30536
sw $t5, 0($t3)
addi $t3, $t4,  30540
sw $t5, 0($t3)
addi $t3, $t4,  30544
sw $t5, 0($t3)
addi $t3, $t4,  30548
sw $t5, 0($t3)
addi $t3, $t4,  30552
sw $t5, 0($t3)
addi $t3, $t4,  30556
sw $t5, 0($t3)
addi $t3, $t4,  30560
sw $t5, 0($t3)
addi $t3, $t4,  30564
sw $t5, 0($t3)
addi $t3, $t4,  30568
sw $t5, 0($t3)
addi $t3, $t4,  30572
sw $t5, 0($t3)
addi $t3, $t4,  30576
sw $t5, 0($t3)
addi $t3, $t4,  30580
sw $t5, 0($t3)
addi $t3, $t4,  30584
sw $t5, 0($t3)
addi $t3, $t4,  30588
sw $t5, 0($t3)
addi $t3, $t4,  30592
sw $t5, 0($t3)
addi $t3, $t4,  30596
sw $t5, 0($t3)
addi $t3, $t4,  30600
sw $t5, 0($t3)
addi $t3, $t4,  30604
sw $t5, 0($t3)
addi $t3, $t4,  30608
sw $t5, 0($t3)
addi $t3, $t4,  30612
sw $t5, 0($t3)
addi $t3, $t4,  30616
sw $t5, 0($t3)
addi $t3, $t4,  30620
sw $t5, 0($t3)
addi $t3, $t4,  30624
sw $t5, 0($t3)
addi $t3, $t4,  30628
sw $t5, 0($t3)
addi $t3, $t4,  30632
sw $t5, 0($t3)
addi $t3, $t4,  30636
sw $t5, 0($t3)
addi $t3, $t4,  30640
sw $t5, 0($t3)
addi $t3, $t4,  30644
sw $t5, 0($t3)
addi $t3, $t4,  30648
sw $t5, 0($t3)
addi $t3, $t4,  30652
sw $t5, 0($t3)
addi $t3, $t4,  30656
sw $t5, 0($t3)
addi $t3, $t4,  30660
sw $t5, 0($t3)
addi $t3, $t4,  30664
sw $t5, 0($t3)
addi $t3, $t4,  30668
sw $t5, 0($t3)
addi $t3, $t4,  30672
sw $t5, 0($t3)
addi $t3, $t4,  30676
sw $t5, 0($t3)
addi $t3, $t4,  30680
sw $t5, 0($t3)
addi $t3, $t4,  30684
sw $t5, 0($t3)
addi $t3, $t4,  30688
sw $t5, 0($t3)
addi $t3, $t4,  30692
sw $t5, 0($t3)
addi $t3, $t4,  30696
sw $t5, 0($t3)
addi $t3, $t4,  30700
sw $t5, 0($t3)
addi $t3, $t4,  30704
sw $t5, 0($t3)
addi $t3, $t4,  30708
sw $t5, 0($t3)
addi $t3, $t4,  30712
sw $t5, 0($t3)
addi $t3, $t4,  30716
sw $t5, 0($t3)
syscall #sleep for 30 ms
addi $t3, $t4,  30720
sw $t5, 0($t3)
addi $t3, $t4,  30724
sw $t5, 0($t3)
addi $t3, $t4,  30728
sw $t5, 0($t3)
addi $t3, $t4,  30732
sw $t5, 0($t3)
addi $t3, $t4,  30736
sw $t5, 0($t3)
addi $t3, $t4,  30740
sw $t5, 0($t3)
addi $t3, $t4,  30744
sw $t5, 0($t3)
addi $t3, $t4,  30748
sw $t5, 0($t3)
addi $t3, $t4,  30752
sw $t5, 0($t3)
addi $t3, $t4,  30756
sw $t5, 0($t3)
addi $t3, $t4,  30760
sw $t5, 0($t3)
addi $t3, $t4,  30764
sw $t5, 0($t3)
addi $t3, $t4,  30768
sw $t5, 0($t3)
addi $t3, $t4,  30772
sw $t5, 0($t3)
addi $t3, $t4,  30776
sw $t5, 0($t3)
addi $t3, $t4,  30780
sw $t5, 0($t3)
addi $t3, $t4,  30784
sw $t5, 0($t3)
addi $t3, $t4,  30788
sw $t5, 0($t3)
addi $t3, $t4,  30792
sw $t5, 0($t3)
addi $t3, $t4,  30796
sw $t5, 0($t3)
addi $t3, $t4,  30800
sw $t5, 0($t3)
addi $t3, $t4,  30804
sw $t5, 0($t3)
addi $t3, $t4,  30808
sw $t5, 0($t3)
addi $t3, $t4,  30812
sw $t5, 0($t3)
addi $t3, $t4,  30816
sw $t5, 0($t3)
addi $t3, $t4,  30820
sw $t5, 0($t3)
addi $t3, $t4,  30824
sw $t5, 0($t3)
addi $t3, $t4,  30828
sw $t5, 0($t3)
addi $t3, $t4,  30832
sw $t5, 0($t3)
addi $t3, $t4,  30836
sw $t5, 0($t3)
addi $t3, $t4,  30840
sw $t5, 0($t3)
addi $t3, $t4,  30844
sw $t5, 0($t3)
addi $t3, $t4,  30848
sw $t5, 0($t3)
addi $t3, $t4,  30852
sw $t5, 0($t3)
addi $t3, $t4,  30856
sw $t5, 0($t3)
addi $t3, $t4,  30860
sw $t5, 0($t3)
addi $t3, $t4,  30864
sw $t5, 0($t3)
addi $t3, $t4,  30868
sw $t5, 0($t3)
addi $t3, $t4,  30872
sw $t5, 0($t3)
addi $t3, $t4,  30876
sw $t5, 0($t3)
addi $t3, $t4,  30880
sw $t5, 0($t3)
addi $t3, $t4,  30884
sw $t5, 0($t3)
addi $t3, $t4,  30888
sw $t5, 0($t3)
addi $t3, $t4,  30892
sw $t5, 0($t3)
addi $t3, $t4,  30896
sw $t5, 0($t3)
addi $t3, $t4,  30900
sw $t5, 0($t3)
addi $t3, $t4,  30904
sw $t5, 0($t3)
addi $t3, $t4,  30908
sw $t5, 0($t3)
addi $t3, $t4,  30912
sw $t5, 0($t3)
addi $t3, $t4,  30916
sw $t5, 0($t3)
addi $t3, $t4,  30920
sw $t5, 0($t3)
addi $t3, $t4,  30924
sw $t5, 0($t3)
addi $t3, $t4,  30928
sw $t5, 0($t3)
addi $t3, $t4,  30932
sw $t5, 0($t3)
addi $t3, $t4,  30936
sw $t5, 0($t3)
addi $t3, $t4,  30940
sw $t5, 0($t3)
addi $t3, $t4,  30944
sw $t5, 0($t3)
addi $t3, $t4,  30948
sw $t5, 0($t3)
addi $t3, $t4,  30952
sw $t5, 0($t3)
addi $t3, $t4,  30956
sw $t5, 0($t3)
addi $t3, $t4,  30960
sw $t5, 0($t3)
addi $t3, $t4,  30964
sw $t5, 0($t3)
addi $t3, $t4,  30968
sw $t5, 0($t3)
addi $t3, $t4,  30972
sw $t5, 0($t3)
addi $t3, $t4,  30976
sw $t5, 0($t3)
addi $t3, $t4,  30980
sw $t5, 0($t3)
addi $t3, $t4,  30984
sw $t5, 0($t3)
addi $t3, $t4,  30988
sw $t5, 0($t3)
addi $t3, $t4,  30992
sw $t5, 0($t3)
addi $t3, $t4,  30996
sw $t5, 0($t3)
addi $t3, $t4,  31000
sw $t5, 0($t3)
addi $t3, $t4,  31004
sw $t5, 0($t3)
addi $t3, $t4,  31008
sw $t5, 0($t3)
addi $t3, $t4,  31012
sw $t5, 0($t3)
addi $t3, $t4,  31016
sw $t5, 0($t3)
addi $t3, $t4,  31020
sw $t5, 0($t3)
addi $t3, $t4,  31024
sw $t5, 0($t3)
addi $t3, $t4,  31028
sw $t5, 0($t3)
addi $t3, $t4,  31032
sw $t5, 0($t3)
addi $t3, $t4,  31036
sw $t5, 0($t3)
addi $t3, $t4,  31040
sw $t5, 0($t3)
addi $t3, $t4,  31044
sw $t5, 0($t3)
addi $t3, $t4,  31048
sw $t5, 0($t3)
addi $t3, $t4,  31052
sw $t5, 0($t3)
addi $t3, $t4,  31056
sw $t5, 0($t3)
addi $t3, $t4,  31060
sw $t5, 0($t3)
addi $t3, $t4,  31064
sw $t5, 0($t3)
addi $t3, $t4,  31068
sw $t5, 0($t3)
addi $t3, $t4,  31072
sw $t5, 0($t3)
addi $t3, $t4,  31076
sw $t5, 0($t3)
addi $t3, $t4,  31080
sw $t5, 0($t3)
addi $t3, $t4,  31084
sw $t5, 0($t3)
addi $t3, $t4,  31088
sw $t5, 0($t3)
addi $t3, $t4,  31092
sw $t5, 0($t3)
addi $t3, $t4,  31096
sw $t5, 0($t3)
addi $t3, $t4,  31100
sw $t5, 0($t3)
addi $t3, $t4,  31104
sw $t5, 0($t3)
addi $t3, $t4,  31108
sw $t5, 0($t3)
addi $t3, $t4,  31112
sw $t5, 0($t3)
addi $t3, $t4,  31116
sw $t5, 0($t3)
addi $t3, $t4,  31120
sw $t5, 0($t3)
addi $t3, $t4,  31124
sw $t5, 0($t3)
addi $t3, $t4,  31128
sw $t5, 0($t3)
addi $t3, $t4,  31132
sw $t5, 0($t3)
addi $t3, $t4,  31136
sw $t5, 0($t3)
addi $t3, $t4,  31140
sw $t5, 0($t3)
addi $t3, $t4,  31144
sw $t5, 0($t3)
addi $t3, $t4,  31148
sw $t5, 0($t3)
addi $t3, $t4,  31152
sw $t5, 0($t3)
addi $t3, $t4,  31156
sw $t5, 0($t3)
addi $t3, $t4,  31160
sw $t5, 0($t3)
addi $t3, $t4,  31164
sw $t5, 0($t3)
addi $t3, $t4,  31168
sw $t5, 0($t3)
addi $t3, $t4,  31172
sw $t5, 0($t3)
addi $t3, $t4,  31176
sw $t5, 0($t3)
addi $t3, $t4,  31180
sw $t5, 0($t3)
addi $t3, $t4,  31184
sw $t5, 0($t3)
addi $t3, $t4,  31188
sw $t5, 0($t3)
addi $t3, $t4,  31192
sw $t5, 0($t3)
addi $t3, $t4,  31196
sw $t5, 0($t3)
addi $t3, $t4,  31200
sw $t5, 0($t3)
addi $t3, $t4,  31204
sw $t5, 0($t3)
addi $t3, $t4,  31208
sw $t5, 0($t3)
addi $t3, $t4,  31212
sw $t5, 0($t3)
addi $t3, $t4,  31216
sw $t5, 0($t3)
addi $t3, $t4,  31220
sw $t5, 0($t3)
addi $t3, $t4,  31224
sw $t5, 0($t3)
addi $t3, $t4,  31228
sw $t5, 0($t3)
syscall #sleep for 30 ms
addi $t3, $t4,  31232
sw $t5, 0($t3)
addi $t3, $t4,  31236
sw $t5, 0($t3)
addi $t3, $t4,  31240
sw $t5, 0($t3)
addi $t3, $t4,  31244
sw $t5, 0($t3)
addi $t3, $t4,  31248
sw $t5, 0($t3)
addi $t3, $t4,  31252
sw $t5, 0($t3)
addi $t3, $t4,  31256
sw $t5, 0($t3)
addi $t3, $t4,  31260
sw $t5, 0($t3)
addi $t3, $t4,  31264
sw $t5, 0($t3)
addi $t3, $t4,  31268
sw $t5, 0($t3)
addi $t3, $t4,  31272
sw $t5, 0($t3)
addi $t3, $t4,  31276
sw $t5, 0($t3)
addi $t3, $t4,  31280
sw $t5, 0($t3)
addi $t3, $t4,  31284
sw $t5, 0($t3)
addi $t3, $t4,  31288
sw $t5, 0($t3)
addi $t3, $t4,  31292
sw $t5, 0($t3)
addi $t3, $t4,  31296
sw $t5, 0($t3)
addi $t3, $t4,  31300
sw $t5, 0($t3)
addi $t3, $t4,  31304
sw $t5, 0($t3)
addi $t3, $t4,  31308
sw $t5, 0($t3)
addi $t3, $t4,  31312
sw $t5, 0($t3)
addi $t3, $t4,  31316
sw $t5, 0($t3)
addi $t3, $t4,  31320
sw $t5, 0($t3)
addi $t3, $t4,  31324
sw $t5, 0($t3)
addi $t3, $t4,  31328
sw $t5, 0($t3)
addi $t3, $t4,  31332
sw $t5, 0($t3)
addi $t3, $t4,  31336
sw $t5, 0($t3)
addi $t3, $t4,  31340
sw $t5, 0($t3)
addi $t3, $t4,  31344
sw $t5, 0($t3)
addi $t3, $t4,  31348
sw $t5, 0($t3)
addi $t3, $t4,  31352
sw $t5, 0($t3)
addi $t3, $t4,  31356
sw $t5, 0($t3)
addi $t3, $t4,  31360
sw $t5, 0($t3)
addi $t3, $t4,  31364
sw $t5, 0($t3)
addi $t3, $t4,  31368
sw $t5, 0($t3)
addi $t3, $t4,  31372
sw $t5, 0($t3)
addi $t3, $t4,  31376
sw $t5, 0($t3)
addi $t3, $t4,  31380
sw $t5, 0($t3)
addi $t3, $t4,  31384
sw $t5, 0($t3)
addi $t3, $t4,  31388
sw $t5, 0($t3)
addi $t3, $t4,  31392
sw $t5, 0($t3)
addi $t3, $t4,  31396
sw $t5, 0($t3)
addi $t3, $t4,  31400
sw $t5, 0($t3)
addi $t3, $t4,  31404
sw $t5, 0($t3)
addi $t3, $t4,  31408
sw $t5, 0($t3)
addi $t3, $t4,  31412
sw $t5, 0($t3)
addi $t3, $t4,  31416
sw $t5, 0($t3)
addi $t3, $t4,  31420
sw $t5, 0($t3)
addi $t3, $t4,  31424
sw $t5, 0($t3)
addi $t3, $t4,  31428
sw $t5, 0($t3)
addi $t3, $t4,  31432
sw $t5, 0($t3)
addi $t3, $t4,  31436
sw $t5, 0($t3)
addi $t3, $t4,  31440
sw $t5, 0($t3)
addi $t3, $t4,  31444
sw $t5, 0($t3)
addi $t3, $t4,  31448
sw $t5, 0($t3)
addi $t3, $t4,  31452
sw $t5, 0($t3)
addi $t3, $t4,  31456
sw $t5, 0($t3)
addi $t3, $t4,  31460
sw $t5, 0($t3)
addi $t3, $t4,  31464
sw $t5, 0($t3)
addi $t3, $t4,  31468
sw $t5, 0($t3)
addi $t3, $t4,  31472
sw $t5, 0($t3)
addi $t3, $t4,  31476
sw $t5, 0($t3)
addi $t3, $t4,  31480
sw $t5, 0($t3)
addi $t3, $t4,  31484
sw $t5, 0($t3)
addi $t3, $t4,  31488
sw $t5, 0($t3)
addi $t3, $t4,  31492
sw $t5, 0($t3)
addi $t3, $t4,  31496
sw $t5, 0($t3)
addi $t3, $t4,  31500
sw $t5, 0($t3)
addi $t3, $t4,  31504
sw $t5, 0($t3)
addi $t3, $t4,  31508
sw $t5, 0($t3)
addi $t3, $t4,  31512
sw $t5, 0($t3)
addi $t3, $t4,  31516
sw $t5, 0($t3)
addi $t3, $t4,  31520
sw $t5, 0($t3)
addi $t3, $t4,  31524
sw $t5, 0($t3)
addi $t3, $t4,  31528
sw $t5, 0($t3)
addi $t3, $t4,  31532
sw $t5, 0($t3)
addi $t3, $t4,  31536
sw $t5, 0($t3)
addi $t3, $t4,  31540
sw $t5, 0($t3)
addi $t3, $t4,  31544
sw $t5, 0($t3)
addi $t3, $t4,  31548
sw $t5, 0($t3)
addi $t3, $t4,  31552
sw $t5, 0($t3)
addi $t3, $t4,  31556
sw $t5, 0($t3)
addi $t3, $t4,  31560
sw $t5, 0($t3)
addi $t3, $t4,  31564
sw $t5, 0($t3)
addi $t3, $t4,  31568
sw $t5, 0($t3)
addi $t3, $t4,  31572
sw $t5, 0($t3)
addi $t3, $t4,  31576
sw $t5, 0($t3)
addi $t3, $t4,  31580
sw $t5, 0($t3)
addi $t3, $t4,  31584
sw $t5, 0($t3)
addi $t3, $t4,  31588
sw $t5, 0($t3)
addi $t3, $t4,  31592
sw $t5, 0($t3)
addi $t3, $t4,  31596
sw $t5, 0($t3)
addi $t3, $t4,  31600
sw $t5, 0($t3)
addi $t3, $t4,  31604
sw $t5, 0($t3)
addi $t3, $t4,  31608
sw $t5, 0($t3)
addi $t3, $t4,  31612
sw $t5, 0($t3)
addi $t3, $t4,  31616
sw $t5, 0($t3)
addi $t3, $t4,  31620
sw $t5, 0($t3)
addi $t3, $t4,  31624
sw $t5, 0($t3)
addi $t3, $t4,  31628
sw $t5, 0($t3)
addi $t3, $t4,  31632
sw $t5, 0($t3)
addi $t3, $t4,  31636
sw $t5, 0($t3)
addi $t3, $t4,  31640
sw $t5, 0($t3)
addi $t3, $t4,  31644
sw $t5, 0($t3)
addi $t3, $t4,  31648
sw $t5, 0($t3)
addi $t3, $t4,  31652
sw $t5, 0($t3)
addi $t3, $t4,  31656
sw $t5, 0($t3)
addi $t3, $t4,  31660
sw $t5, 0($t3)
addi $t3, $t4,  31664
sw $t5, 0($t3)
addi $t3, $t4,  31668
sw $t5, 0($t3)
addi $t3, $t4,  31672
sw $t5, 0($t3)
addi $t3, $t4,  31676
sw $t5, 0($t3)
addi $t3, $t4,  31680
sw $t5, 0($t3)
addi $t3, $t4,  31684
sw $t5, 0($t3)
addi $t3, $t4,  31688
sw $t5, 0($t3)
addi $t3, $t4,  31692
sw $t5, 0($t3)
addi $t3, $t4,  31696
sw $t5, 0($t3)
addi $t3, $t4,  31700
sw $t5, 0($t3)
addi $t3, $t4,  31704
sw $t5, 0($t3)
addi $t3, $t4,  31708
sw $t5, 0($t3)
addi $t3, $t4,  31712
sw $t5, 0($t3)
addi $t3, $t4,  31716
sw $t5, 0($t3)
addi $t3, $t4,  31720
sw $t5, 0($t3)
addi $t3, $t4,  31724
sw $t5, 0($t3)
addi $t3, $t4,  31728
sw $t5, 0($t3)
addi $t3, $t4,  31732
sw $t5, 0($t3)
addi $t3, $t4,  31736
sw $t5, 0($t3)
addi $t3, $t4,  31740
sw $t5, 0($t3)
syscall #sleep for 30 ms
addi $t3, $t4,  31744
sw $t5, 0($t3)
addi $t3, $t4,  31748
sw $t5, 0($t3)
addi $t3, $t4,  31752
sw $t5, 0($t3)
addi $t3, $t4,  31756
sw $t5, 0($t3)
addi $t3, $t4,  31760
sw $t5, 0($t3)
addi $t3, $t4,  31764
sw $t5, 0($t3)
addi $t3, $t4,  31768
sw $t5, 0($t3)
addi $t3, $t4,  31772
sw $t5, 0($t3)
addi $t3, $t4,  31776
sw $t5, 0($t3)
addi $t3, $t4,  31780
sw $t5, 0($t3)
addi $t3, $t4,  31784
sw $t5, 0($t3)
addi $t3, $t4,  31788
sw $t5, 0($t3)
addi $t3, $t4,  31792
sw $t5, 0($t3)
addi $t3, $t4,  31796
sw $t5, 0($t3)
addi $t3, $t4,  31800
sw $t5, 0($t3)
addi $t3, $t4,  31804
sw $t5, 0($t3)
addi $t3, $t4,  31808
sw $t5, 0($t3)
addi $t3, $t4,  31812
sw $t5, 0($t3)
addi $t3, $t4,  31816
sw $t5, 0($t3)
addi $t3, $t4,  31820
sw $t5, 0($t3)
addi $t3, $t4,  31824
sw $t5, 0($t3)
addi $t3, $t4,  31828
sw $t5, 0($t3)
addi $t3, $t4,  31832
sw $t5, 0($t3)
addi $t3, $t4,  31836
sw $t5, 0($t3)
addi $t3, $t4,  31840
sw $t5, 0($t3)
addi $t3, $t4,  31844
sw $t5, 0($t3)
addi $t3, $t4,  31848
sw $t5, 0($t3)
addi $t3, $t4,  31852
sw $t5, 0($t3)
addi $t3, $t4,  31856
sw $t5, 0($t3)
addi $t3, $t4,  31860
sw $t5, 0($t3)
addi $t3, $t4,  31864
sw $t5, 0($t3)
addi $t3, $t4,  31868
sw $t5, 0($t3)
addi $t3, $t4,  31872
sw $t5, 0($t3)
addi $t3, $t4,  31876
sw $t5, 0($t3)
addi $t3, $t4,  31880
sw $t5, 0($t3)
addi $t3, $t4,  31884
sw $t5, 0($t3)
addi $t3, $t4,  31888
sw $t5, 0($t3)
addi $t3, $t4,  31892
sw $t5, 0($t3)
addi $t3, $t4,  31896
sw $t5, 0($t3)
addi $t3, $t4,  31900
sw $t5, 0($t3)
addi $t3, $t4,  31904
sw $t5, 0($t3)
addi $t3, $t4,  31908
sw $t5, 0($t3)
addi $t3, $t4,  31912
sw $t5, 0($t3)
addi $t3, $t4,  31916
sw $t5, 0($t3)
addi $t3, $t4,  31920
sw $t5, 0($t3)
addi $t3, $t4,  31924
sw $t5, 0($t3)
addi $t3, $t4,  31928
sw $t5, 0($t3)
addi $t3, $t4,  31932
sw $t5, 0($t3)
addi $t3, $t4,  31936
sw $t5, 0($t3)
addi $t3, $t4,  31940
sw $t5, 0($t3)
addi $t3, $t4,  31944
sw $t5, 0($t3)
addi $t3, $t4,  31948
sw $t5, 0($t3)
addi $t3, $t4,  31952
sw $t5, 0($t3)
addi $t3, $t4,  31956
sw $t5, 0($t3)
addi $t3, $t4,  31960
sw $t5, 0($t3)
addi $t3, $t4,  31964
sw $t5, 0($t3)
addi $t3, $t4,  31968
sw $t5, 0($t3)
addi $t3, $t4,  31972
sw $t5, 0($t3)
addi $t3, $t4,  31976
sw $t5, 0($t3)
addi $t3, $t4,  31980
sw $t5, 0($t3)
addi $t3, $t4,  31984
sw $t5, 0($t3)
addi $t3, $t4,  31988
sw $t5, 0($t3)
addi $t3, $t4,  31992
sw $t5, 0($t3)
addi $t3, $t4,  31996
sw $t5, 0($t3)
addi $t3, $t4,  32000
sw $t5, 0($t3)
addi $t3, $t4,  32004
sw $t5, 0($t3)
addi $t3, $t4,  32008
sw $t5, 0($t3)
addi $t3, $t4,  32012
sw $t5, 0($t3)
addi $t3, $t4,  32016
sw $t5, 0($t3)
addi $t3, $t4,  32020
sw $t5, 0($t3)
addi $t3, $t4,  32024
sw $t5, 0($t3)
addi $t3, $t4,  32028
sw $t5, 0($t3)
addi $t3, $t4,  32032
sw $t5, 0($t3)
addi $t3, $t4,  32036
sw $t5, 0($t3)
addi $t3, $t4,  32040
sw $t5, 0($t3)
addi $t3, $t4,  32044
sw $t5, 0($t3)
addi $t3, $t4,  32048
sw $t5, 0($t3)
addi $t3, $t4,  32052
sw $t5, 0($t3)
addi $t3, $t4,  32056
sw $t5, 0($t3)
addi $t3, $t4,  32060
sw $t5, 0($t3)
addi $t3, $t4,  32064
sw $t5, 0($t3)
addi $t3, $t4,  32068
sw $t5, 0($t3)
addi $t3, $t4,  32072
sw $t5, 0($t3)
addi $t3, $t4,  32076
sw $t5, 0($t3)
addi $t3, $t4,  32080
sw $t5, 0($t3)
addi $t3, $t4,  32084
sw $t5, 0($t3)
addi $t3, $t4,  32088
sw $t5, 0($t3)
addi $t3, $t4,  32092
sw $t5, 0($t3)
addi $t3, $t4,  32096
sw $t5, 0($t3)
addi $t3, $t4,  32100
sw $t5, 0($t3)
addi $t3, $t4,  32104
sw $t5, 0($t3)
addi $t3, $t4,  32108
sw $t5, 0($t3)
addi $t3, $t4,  32112
sw $t5, 0($t3)
addi $t3, $t4,  32116
sw $t5, 0($t3)
addi $t3, $t4,  32120
sw $t5, 0($t3)
addi $t3, $t4,  32124
sw $t5, 0($t3)
addi $t3, $t4,  32128
sw $t5, 0($t3)
addi $t3, $t4,  32132
sw $t5, 0($t3)
addi $t3, $t4,  32136
sw $t5, 0($t3)
addi $t3, $t4,  32140
sw $t5, 0($t3)
addi $t3, $t4,  32144
sw $t5, 0($t3)
addi $t3, $t4,  32148
sw $t5, 0($t3)
addi $t3, $t4,  32152
sw $t5, 0($t3)
addi $t3, $t4,  32156
sw $t5, 0($t3)
addi $t3, $t4,  32160
sw $t5, 0($t3)
addi $t3, $t4,  32164
sw $t5, 0($t3)
addi $t3, $t4,  32168
sw $t5, 0($t3)
addi $t3, $t4,  32172
sw $t5, 0($t3)
addi $t3, $t4,  32176
sw $t5, 0($t3)
addi $t3, $t4,  32180
sw $t5, 0($t3)
addi $t3, $t4,  32184
sw $t5, 0($t3)
addi $t3, $t4,  32188
sw $t5, 0($t3)
addi $t3, $t4,  32192
sw $t5, 0($t3)
addi $t3, $t4,  32196
sw $t5, 0($t3)
addi $t3, $t4,  32200
sw $t5, 0($t3)
addi $t3, $t4,  32204
sw $t5, 0($t3)
addi $t3, $t4,  32208
sw $t5, 0($t3)
addi $t3, $t4,  32212
sw $t5, 0($t3)
addi $t3, $t4,  32216
sw $t5, 0($t3)
addi $t3, $t4,  32220
sw $t5, 0($t3)
addi $t3, $t4,  32224
sw $t5, 0($t3)
addi $t3, $t4,  32228
sw $t5, 0($t3)
addi $t3, $t4,  32232
sw $t5, 0($t3)
addi $t3, $t4,  32236
sw $t5, 0($t3)
addi $t3, $t4,  32240
sw $t5, 0($t3)
addi $t3, $t4,  32244
sw $t5, 0($t3)
addi $t3, $t4,  32248
sw $t5, 0($t3)
addi $t3, $t4,  32252
sw $t5, 0($t3)
syscall #sleep for 30 ms
addi $t3, $t4,  32256
sw $t5, 0($t3)
addi $t3, $t4,  32260
sw $t5, 0($t3)
addi $t3, $t4,  32264
sw $t5, 0($t3)
addi $t3, $t4,  32268
sw $t5, 0($t3)
addi $t3, $t4,  32272
sw $t5, 0($t3)
addi $t3, $t4,  32276
sw $t5, 0($t3)
addi $t3, $t4,  32280
sw $t5, 0($t3)
addi $t3, $t4,  32284
sw $t5, 0($t3)
addi $t3, $t4,  32288
sw $t5, 0($t3)
addi $t3, $t4,  32292
sw $t5, 0($t3)
addi $t3, $t4,  32296
sw $t5, 0($t3)
addi $t3, $t4,  32300
sw $t5, 0($t3)
addi $t3, $t4,  32304
sw $t5, 0($t3)
addi $t3, $t4,  32308
sw $t5, 0($t3)
addi $t3, $t4,  32312
sw $t5, 0($t3)
addi $t3, $t4,  32316
sw $t5, 0($t3)
addi $t3, $t4,  32320
sw $t5, 0($t3)
addi $t3, $t4,  32324
sw $t5, 0($t3)
addi $t3, $t4,  32328
sw $t5, 0($t3)
addi $t3, $t4,  32332
sw $t5, 0($t3)
addi $t3, $t4,  32336
sw $t5, 0($t3)
addi $t3, $t4,  32340
sw $t5, 0($t3)
addi $t3, $t4,  32344
sw $t5, 0($t3)
addi $t3, $t4,  32348
sw $t5, 0($t3)
addi $t3, $t4,  32352
sw $t5, 0($t3)
addi $t3, $t4,  32356
sw $t5, 0($t3)
addi $t3, $t4,  32360
sw $t5, 0($t3)
addi $t3, $t4,  32364
sw $t5, 0($t3)
addi $t3, $t4,  32368
sw $t5, 0($t3)
addi $t3, $t4,  32372
sw $t5, 0($t3)
addi $t3, $t4,  32376
sw $t5, 0($t3)
addi $t3, $t4,  32380
sw $t5, 0($t3)
addi $t3, $t4,  32384
sw $t5, 0($t3)
addi $t3, $t4,  32388
sw $t5, 0($t3)
addi $t3, $t4,  32392
sw $t5, 0($t3)
addi $t3, $t4,  32396
sw $t5, 0($t3)
addi $t3, $t4,  32400
sw $t5, 0($t3)
addi $t3, $t4,  32404
sw $t5, 0($t3)
addi $t3, $t4,  32408
sw $t5, 0($t3)
addi $t3, $t4,  32412
sw $t5, 0($t3)
addi $t3, $t4,  32416
sw $t5, 0($t3)
addi $t3, $t4,  32420
sw $t5, 0($t3)
addi $t3, $t4,  32424
sw $t5, 0($t3)
addi $t3, $t4,  32428
sw $t5, 0($t3)
addi $t3, $t4,  32432
sw $t5, 0($t3)
addi $t3, $t4,  32436
sw $t5, 0($t3)
addi $t3, $t4,  32440
sw $t5, 0($t3)
addi $t3, $t4,  32444
sw $t5, 0($t3)
addi $t3, $t4,  32448
sw $t5, 0($t3)
addi $t3, $t4,  32452
sw $t5, 0($t3)
addi $t3, $t4,  32456
sw $t5, 0($t3)
addi $t3, $t4,  32460
sw $t5, 0($t3)
addi $t3, $t4,  32464
sw $t5, 0($t3)
addi $t3, $t4,  32468
sw $t5, 0($t3)
addi $t3, $t4,  32472
sw $t5, 0($t3)
addi $t3, $t4,  32476
sw $t5, 0($t3)
addi $t3, $t4,  32480
sw $t5, 0($t3)
addi $t3, $t4,  32484
sw $t5, 0($t3)
addi $t3, $t4,  32488
sw $t5, 0($t3)
addi $t3, $t4,  32492
sw $t5, 0($t3)
addi $t3, $t4,  32496
sw $t5, 0($t3)
addi $t3, $t4,  32500
sw $t5, 0($t3)
addi $t3, $t4,  32504
sw $t5, 0($t3)
addi $t3, $t4,  32508
sw $t5, 0($t3)
addi $t3, $t4,  32512
sw $t5, 0($t3)
addi $t3, $t4,  32516
sw $t5, 0($t3)
addi $t3, $t4,  32520
sw $t5, 0($t3)
addi $t3, $t4,  32524
sw $t5, 0($t3)
addi $t3, $t4,  32528
sw $t5, 0($t3)
addi $t3, $t4,  32532
sw $t5, 0($t3)
addi $t3, $t4,  32536
sw $t5, 0($t3)
addi $t3, $t4,  32540
sw $t5, 0($t3)
addi $t3, $t4,  32544
sw $t5, 0($t3)
addi $t3, $t4,  32548
sw $t5, 0($t3)
addi $t3, $t4,  32552
sw $t5, 0($t3)
addi $t3, $t4,  32556
sw $t5, 0($t3)
addi $t3, $t4,  32560
sw $t5, 0($t3)
addi $t3, $t4,  32564
sw $t5, 0($t3)
addi $t3, $t4,  32568
sw $t5, 0($t3)
addi $t3, $t4,  32572
sw $t5, 0($t3)
addi $t3, $t4,  32576
sw $t5, 0($t3)
addi $t3, $t4,  32580
sw $t5, 0($t3)
addi $t3, $t4,  32584
sw $t5, 0($t3)
addi $t3, $t4,  32588
sw $t5, 0($t3)
addi $t3, $t4,  32592
sw $t5, 0($t3)
addi $t3, $t4,  32596
sw $t5, 0($t3)
addi $t3, $t4,  32600
sw $t5, 0($t3)
addi $t3, $t4,  32604
sw $t5, 0($t3)
addi $t3, $t4,  32608
sw $t5, 0($t3)
addi $t3, $t4,  32612
sw $t5, 0($t3)
addi $t3, $t4,  32616
sw $t5, 0($t3)
addi $t3, $t4,  32620
sw $t5, 0($t3)
addi $t3, $t4,  32624
sw $t5, 0($t3)
addi $t3, $t4,  32628
sw $t5, 0($t3)
addi $t3, $t4,  32632
sw $t5, 0($t3)
addi $t3, $t4,  32636
sw $t5, 0($t3)
addi $t3, $t4,  32640
sw $t5, 0($t3)
addi $t3, $t4,  32644
sw $t5, 0($t3)
addi $t3, $t4,  32648
sw $t5, 0($t3)
addi $t3, $t4,  32652
sw $t5, 0($t3)
addi $t3, $t4,  32656
sw $t5, 0($t3)
addi $t3, $t4,  32660
sw $t5, 0($t3)
addi $t3, $t4,  32664
sw $t5, 0($t3)
addi $t3, $t4,  32668
sw $t5, 0($t3)
addi $t3, $t4,  32672
sw $t5, 0($t3)
addi $t3, $t4,  32676
sw $t5, 0($t3)
addi $t3, $t4,  32680
sw $t5, 0($t3)
addi $t3, $t4,  32684
sw $t5, 0($t3)
addi $t3, $t4,  32688
sw $t5, 0($t3)
addi $t3, $t4,  32692
sw $t5, 0($t3)
addi $t3, $t4,  32696
sw $t5, 0($t3)
addi $t3, $t4,  32700
sw $t5, 0($t3)
addi $t3, $t4,  32704
sw $t5, 0($t3)
addi $t3, $t4,  32708
sw $t5, 0($t3)
addi $t3, $t4,  32712
sw $t5, 0($t3)
addi $t3, $t4,  32716
sw $t5, 0($t3)
addi $t3, $t4,  32720
sw $t5, 0($t3)
addi $t3, $t4,  32724
sw $t5, 0($t3)
addi $t3, $t4,  32728
sw $t5, 0($t3)
addi $t3, $t4,  32732
sw $t5, 0($t3)
addi $t3, $t4,  32736
sw $t5, 0($t3)
addi $t3, $t4,  32740
sw $t5, 0($t3)
addi $t3, $t4,  32744
sw $t5, 0($t3)
addi $t3, $t4,  32748
sw $t5, 0($t3)
addi $t3, $t4,  32752
sw $t5, 0($t3)
addi $t3, $t4,  32756
sw $t5, 0($t3)
addi $t3, $t4,  32760
sw $t5, 0($t3)
addi $t3, $t4,  32764
sw $t5, 0($t3)
syscall #sleep for 30 ms




	
	li $v0, 32
	
	li $a0, 4000 # Sleep for 4 seconds before restart
	syscall
	
	j Restart
	
######################### Fucntion to play when win ###############################
HeartReached:
	addi $s4, $s4, 1
	bne $s4, 3, NextLevel
	###print the winning image #############

addi $t4, $zero, BASE_ADDRESS
addi $t3, $t4, 0
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 4
sw $t5, 0($t3)
addi $t3, $t4, 8
sw $t5, 0($t3)
addi $t3, $t4, 12
sw $t5, 0($t3)
addi $t3, $t4, 16
sw $t5, 0($t3)
addi $t3, $t4, 20
sw $t5, 0($t3)
addi $t3, $t4, 24
sw $t5, 0($t3)
addi $t3, $t4, 28
sw $t5, 0($t3)
addi $t3, $t4, 32
sw $t5, 0($t3)
addi $t3, $t4, 36
sw $t5, 0($t3)
addi $t3, $t4, 40
sw $t5, 0($t3)
addi $t3, $t4, 44
sw $t5, 0($t3)
addi $t3, $t4, 48
sw $t5, 0($t3)
addi $t3, $t4, 52
sw $t5, 0($t3)
addi $t3, $t4, 56
sw $t5, 0($t3)
addi $t3, $t4, 60
sw $t5, 0($t3)
addi $t3, $t4, 64
sw $t5, 0($t3)
addi $t3, $t4, 68
sw $t5, 0($t3)
addi $t3, $t4, 72
sw $t5, 0($t3)
addi $t3, $t4, 76
sw $t5, 0($t3)
addi $t3, $t4, 80
sw $t5, 0($t3)
addi $t3, $t4, 84
sw $t5, 0($t3)
addi $t3, $t4, 88
sw $t5, 0($t3)
addi $t3, $t4, 92
sw $t5, 0($t3)
addi $t3, $t4, 96
sw $t5, 0($t3)
addi $t3, $t4, 100
sw $t5, 0($t3)
addi $t3, $t4, 104
sw $t5, 0($t3)
addi $t3, $t4, 108
sw $t5, 0($t3)
addi $t3, $t4, 112
sw $t5, 0($t3)
addi $t3, $t4, 116
sw $t5, 0($t3)
addi $t3, $t4, 120
sw $t5, 0($t3)
addi $t3, $t4, 124
sw $t5, 0($t3)
addi $t3, $t4, 128
sw $t5, 0($t3)
addi $t3, $t4, 132
sw $t5, 0($t3)
addi $t3, $t4, 136
sw $t5, 0($t3)
addi $t3, $t4, 140
sw $t5, 0($t3)
addi $t3, $t4, 144
sw $t5, 0($t3)
addi $t3, $t4, 148
sw $t5, 0($t3)
addi $t3, $t4, 152
sw $t5, 0($t3)
addi $t3, $t4, 156
sw $t5, 0($t3)
addi $t3, $t4, 160
sw $t5, 0($t3)
addi $t3, $t4, 164
sw $t5, 0($t3)
addi $t3, $t4, 168
sw $t5, 0($t3)
addi $t3, $t4, 172
sw $t5, 0($t3)
addi $t3, $t4, 176
sw $t5, 0($t3)
addi $t3, $t4, 180
sw $t5, 0($t3)
addi $t3, $t4, 184
sw $t5, 0($t3)
addi $t3, $t4, 188
sw $t5, 0($t3)
addi $t3, $t4, 192
sw $t5, 0($t3)
addi $t3, $t4, 196
sw $t5, 0($t3)
addi $t3, $t4, 200
sw $t5, 0($t3)
addi $t3, $t4, 204
sw $t5, 0($t3)
addi $t3, $t4, 208
sw $t5, 0($t3)
addi $t3, $t4, 212
sw $t5, 0($t3)
addi $t3, $t4, 216
sw $t5, 0($t3)
addi $t3, $t4, 220
sw $t5, 0($t3)
addi $t3, $t4, 224
sw $t5, 0($t3)
addi $t3, $t4, 228
sw $t5, 0($t3)
addi $t3, $t4, 232
sw $t5, 0($t3)
addi $t3, $t4, 236
sw $t5, 0($t3)
addi $t3, $t4, 240
sw $t5, 0($t3)
addi $t3, $t4, 244
sw $t5, 0($t3)
addi $t3, $t4, 248
sw $t5, 0($t3)
addi $t3, $t4, 252
sw $t5, 0($t3)
addi $t3, $t4, 256
sw $t5, 0($t3)
addi $t3, $t4, 260
sw $t5, 0($t3)
addi $t3, $t4, 264
sw $t5, 0($t3)
addi $t3, $t4, 268
sw $t5, 0($t3)
addi $t3, $t4, 272
sw $t5, 0($t3)
addi $t3, $t4, 276
sw $t5, 0($t3)
addi $t3, $t4, 280
sw $t5, 0($t3)
addi $t3, $t4, 284
sw $t5, 0($t3)
addi $t3, $t4, 288
sw $t5, 0($t3)
addi $t3, $t4, 292
sw $t5, 0($t3)
addi $t3, $t4, 296
sw $t5, 0($t3)
addi $t3, $t4, 300
sw $t5, 0($t3)
addi $t3, $t4, 304
sw $t5, 0($t3)
addi $t3, $t4, 308
sw $t5, 0($t3)
addi $t3, $t4, 312
sw $t5, 0($t3)
addi $t3, $t4, 316
sw $t5, 0($t3)
addi $t3, $t4, 320
sw $t5, 0($t3)
addi $t3, $t4, 324
sw $t5, 0($t3)
addi $t3, $t4, 328
sw $t5, 0($t3)
addi $t3, $t4, 332
sw $t5, 0($t3)
addi $t3, $t4, 336
sw $t5, 0($t3)
addi $t3, $t4, 340
sw $t5, 0($t3)
addi $t3, $t4, 344
sw $t5, 0($t3)
addi $t3, $t4, 348
sw $t5, 0($t3)
addi $t3, $t4, 352
sw $t5, 0($t3)
addi $t3, $t4, 356
sw $t5, 0($t3)
addi $t3, $t4, 360
sw $t5, 0($t3)
addi $t3, $t4, 364
sw $t5, 0($t3)
addi $t3, $t4, 368
sw $t5, 0($t3)
addi $t3, $t4, 372
sw $t5, 0($t3)
addi $t3, $t4, 376
sw $t5, 0($t3)
addi $t3, $t4, 380
sw $t5, 0($t3)
addi $t3, $t4, 384
sw $t5, 0($t3)
addi $t3, $t4, 388
sw $t5, 0($t3)
addi $t3, $t4, 392
sw $t5, 0($t3)
addi $t3, $t4, 396
sw $t5, 0($t3)
addi $t3, $t4, 400
sw $t5, 0($t3)
addi $t3, $t4, 404
sw $t5, 0($t3)
addi $t3, $t4, 408
sw $t5, 0($t3)
addi $t3, $t4, 412
sw $t5, 0($t3)
addi $t3, $t4, 416
sw $t5, 0($t3)
addi $t3, $t4, 420
sw $t5, 0($t3)
addi $t3, $t4, 424
sw $t5, 0($t3)
addi $t3, $t4, 428
sw $t5, 0($t3)
addi $t3, $t4, 432
sw $t5, 0($t3)
addi $t3, $t4, 436
sw $t5, 0($t3)
addi $t3, $t4, 440
sw $t5, 0($t3)
addi $t3, $t4, 444
sw $t5, 0($t3)
addi $t3, $t4, 448
sw $t5, 0($t3)
addi $t3, $t4, 452
sw $t5, 0($t3)
addi $t3, $t4, 456
sw $t5, 0($t3)
addi $t3, $t4, 460
sw $t5, 0($t3)
addi $t3, $t4, 464
sw $t5, 0($t3)
addi $t3, $t4, 468
sw $t5, 0($t3)
addi $t3, $t4, 472
sw $t5, 0($t3)
addi $t3, $t4, 476
sw $t5, 0($t3)
addi $t3, $t4, 480
sw $t5, 0($t3)
addi $t3, $t4, 484
sw $t5, 0($t3)
addi $t3, $t4, 488
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 492
li $t5,0x050505
sw $t5, 0($t3)
addi $t3, $t4, 496
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 500
sw $t5, 0($t3)
addi $t3, $t4, 504
li $t5,0xa3a3a3
sw $t5, 0($t3)
addi $t3, $t4, 508
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 512
sw $t5, 0($t3)
addi $t3, $t4, 516
sw $t5, 0($t3)
addi $t3, $t4, 520
sw $t5, 0($t3)
addi $t3, $t4, 524
sw $t5, 0($t3)
addi $t3, $t4, 528
sw $t5, 0($t3)
addi $t3, $t4, 532
sw $t5, 0($t3)
addi $t3, $t4, 536
sw $t5, 0($t3)
addi $t3, $t4, 540
sw $t5, 0($t3)
addi $t3, $t4, 544
sw $t5, 0($t3)
addi $t3, $t4, 548
sw $t5, 0($t3)
addi $t3, $t4, 552
sw $t5, 0($t3)
addi $t3, $t4, 556
sw $t5, 0($t3)
addi $t3, $t4, 560
sw $t5, 0($t3)
addi $t3, $t4, 564
sw $t5, 0($t3)
addi $t3, $t4, 568
sw $t5, 0($t3)
addi $t3, $t4, 572
sw $t5, 0($t3)
addi $t3, $t4, 576
sw $t5, 0($t3)
addi $t3, $t4, 580
sw $t5, 0($t3)
addi $t3, $t4, 584
sw $t5, 0($t3)
addi $t3, $t4, 588
sw $t5, 0($t3)
addi $t3, $t4, 592
sw $t5, 0($t3)
addi $t3, $t4, 596
sw $t5, 0($t3)
addi $t3, $t4, 600
sw $t5, 0($t3)
addi $t3, $t4, 604
sw $t5, 0($t3)
addi $t3, $t4, 608
sw $t5, 0($t3)
addi $t3, $t4, 612
sw $t5, 0($t3)
addi $t3, $t4, 616
sw $t5, 0($t3)
addi $t3, $t4, 620
sw $t5, 0($t3)
addi $t3, $t4, 624
sw $t5, 0($t3)
addi $t3, $t4, 628
sw $t5, 0($t3)
addi $t3, $t4, 632
sw $t5, 0($t3)
addi $t3, $t4, 636
sw $t5, 0($t3)
addi $t3, $t4, 640
sw $t5, 0($t3)
addi $t3, $t4, 644
sw $t5, 0($t3)
addi $t3, $t4, 648
sw $t5, 0($t3)
addi $t3, $t4, 652
sw $t5, 0($t3)
addi $t3, $t4, 656
sw $t5, 0($t3)
addi $t3, $t4, 660
sw $t5, 0($t3)
addi $t3, $t4, 664
sw $t5, 0($t3)
addi $t3, $t4, 668
sw $t5, 0($t3)
addi $t3, $t4, 672
sw $t5, 0($t3)
addi $t3, $t4, 676
sw $t5, 0($t3)
addi $t3, $t4, 680
sw $t5, 0($t3)
addi $t3, $t4, 684
sw $t5, 0($t3)
addi $t3, $t4, 688
sw $t5, 0($t3)
addi $t3, $t4, 692
sw $t5, 0($t3)
addi $t3, $t4, 696
sw $t5, 0($t3)
addi $t3, $t4, 700
sw $t5, 0($t3)
addi $t3, $t4, 704
sw $t5, 0($t3)
addi $t3, $t4, 708
sw $t5, 0($t3)
addi $t3, $t4, 712
sw $t5, 0($t3)
addi $t3, $t4, 716
sw $t5, 0($t3)
addi $t3, $t4, 720
sw $t5, 0($t3)
addi $t3, $t4, 724
sw $t5, 0($t3)
addi $t3, $t4, 728
sw $t5, 0($t3)
addi $t3, $t4, 732
sw $t5, 0($t3)
addi $t3, $t4, 736
sw $t5, 0($t3)
addi $t3, $t4, 740
sw $t5, 0($t3)
addi $t3, $t4, 744
sw $t5, 0($t3)
addi $t3, $t4, 748
sw $t5, 0($t3)
addi $t3, $t4, 752
sw $t5, 0($t3)
addi $t3, $t4, 756
sw $t5, 0($t3)
addi $t3, $t4, 760
sw $t5, 0($t3)
addi $t3, $t4, 764
sw $t5, 0($t3)
addi $t3, $t4, 768
sw $t5, 0($t3)
addi $t3, $t4, 772
sw $t5, 0($t3)
addi $t3, $t4, 776
sw $t5, 0($t3)
addi $t3, $t4, 780
sw $t5, 0($t3)
addi $t3, $t4, 784
sw $t5, 0($t3)
addi $t3, $t4, 788
sw $t5, 0($t3)
addi $t3, $t4, 792
sw $t5, 0($t3)
addi $t3, $t4, 796
sw $t5, 0($t3)
addi $t3, $t4, 800
sw $t5, 0($t3)
addi $t3, $t4, 804
sw $t5, 0($t3)
addi $t3, $t4, 808
sw $t5, 0($t3)
addi $t3, $t4, 812
sw $t5, 0($t3)
addi $t3, $t4, 816
sw $t5, 0($t3)
addi $t3, $t4, 820
sw $t5, 0($t3)
addi $t3, $t4, 824
sw $t5, 0($t3)
addi $t3, $t4, 828
sw $t5, 0($t3)
addi $t3, $t4, 832
sw $t5, 0($t3)
addi $t3, $t4, 836
sw $t5, 0($t3)
addi $t3, $t4, 840
sw $t5, 0($t3)
addi $t3, $t4, 844
sw $t5, 0($t3)
addi $t3, $t4, 848
sw $t5, 0($t3)
addi $t3, $t4, 852
sw $t5, 0($t3)
addi $t3, $t4, 856
sw $t5, 0($t3)
addi $t3, $t4, 860
sw $t5, 0($t3)
addi $t3, $t4, 864
sw $t5, 0($t3)
addi $t3, $t4, 868
sw $t5, 0($t3)
addi $t3, $t4, 872
sw $t5, 0($t3)
addi $t3, $t4, 876
sw $t5, 0($t3)
addi $t3, $t4, 880
sw $t5, 0($t3)
addi $t3, $t4, 884
sw $t5, 0($t3)
addi $t3, $t4, 888
sw $t5, 0($t3)
addi $t3, $t4, 892
sw $t5, 0($t3)
addi $t3, $t4, 896
sw $t5, 0($t3)
addi $t3, $t4, 900
sw $t5, 0($t3)
addi $t3, $t4, 904
sw $t5, 0($t3)
addi $t3, $t4, 908
sw $t5, 0($t3)
addi $t3, $t4, 912
sw $t5, 0($t3)
addi $t3, $t4, 916
sw $t5, 0($t3)
addi $t3, $t4, 920
sw $t5, 0($t3)
addi $t3, $t4, 924
sw $t5, 0($t3)
addi $t3, $t4, 928
sw $t5, 0($t3)
addi $t3, $t4, 932
sw $t5, 0($t3)
addi $t3, $t4, 936
sw $t5, 0($t3)
addi $t3, $t4, 940
sw $t5, 0($t3)
addi $t3, $t4, 944
sw $t5, 0($t3)
addi $t3, $t4, 948
sw $t5, 0($t3)
addi $t3, $t4, 952
sw $t5, 0($t3)
addi $t3, $t4, 956
sw $t5, 0($t3)
addi $t3, $t4, 960
sw $t5, 0($t3)
addi $t3, $t4, 964
sw $t5, 0($t3)
addi $t3, $t4, 968
sw $t5, 0($t3)
addi $t3, $t4, 972
sw $t5, 0($t3)
addi $t3, $t4, 976
sw $t5, 0($t3)
addi $t3, $t4, 980
sw $t5, 0($t3)
addi $t3, $t4, 984
sw $t5, 0($t3)
addi $t3, $t4, 988
sw $t5, 0($t3)
addi $t3, $t4, 992
sw $t5, 0($t3)
addi $t3, $t4, 996
sw $t5, 0($t3)
addi $t3, $t4, 1000
li $t5,0xb4b4b4
sw $t5, 0($t3)
addi $t3, $t4, 1004
li $t5,0x020202
sw $t5, 0($t3)
addi $t3, $t4, 1008
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 1012
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 1016
li $t5,0x757575
sw $t5, 0($t3)
addi $t3, $t4, 1020
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 1024
sw $t5, 0($t3)
addi $t3, $t4, 1028
sw $t5, 0($t3)
addi $t3, $t4, 1032
sw $t5, 0($t3)
addi $t3, $t4, 1036
sw $t5, 0($t3)
addi $t3, $t4, 1040
sw $t5, 0($t3)
addi $t3, $t4, 1044
sw $t5, 0($t3)
addi $t3, $t4, 1048
sw $t5, 0($t3)
addi $t3, $t4, 1052
sw $t5, 0($t3)
addi $t3, $t4, 1056
sw $t5, 0($t3)
addi $t3, $t4, 1060
sw $t5, 0($t3)
addi $t3, $t4, 1064
sw $t5, 0($t3)
addi $t3, $t4, 1068
sw $t5, 0($t3)
addi $t3, $t4, 1072
sw $t5, 0($t3)
addi $t3, $t4, 1076
sw $t5, 0($t3)
addi $t3, $t4, 1080
sw $t5, 0($t3)
addi $t3, $t4, 1084
sw $t5, 0($t3)
addi $t3, $t4, 1088
sw $t5, 0($t3)
addi $t3, $t4, 1092
sw $t5, 0($t3)
addi $t3, $t4, 1096
sw $t5, 0($t3)
addi $t3, $t4, 1100
sw $t5, 0($t3)
addi $t3, $t4, 1104
sw $t5, 0($t3)
addi $t3, $t4, 1108
sw $t5, 0($t3)
addi $t3, $t4, 1112
sw $t5, 0($t3)
addi $t3, $t4, 1116
sw $t5, 0($t3)
addi $t3, $t4, 1120
sw $t5, 0($t3)
addi $t3, $t4, 1124
sw $t5, 0($t3)
addi $t3, $t4, 1128
sw $t5, 0($t3)
addi $t3, $t4, 1132
sw $t5, 0($t3)
addi $t3, $t4, 1136
sw $t5, 0($t3)
addi $t3, $t4, 1140
sw $t5, 0($t3)
addi $t3, $t4, 1144
sw $t5, 0($t3)
addi $t3, $t4, 1148
sw $t5, 0($t3)
addi $t3, $t4, 1152
sw $t5, 0($t3)
addi $t3, $t4, 1156
sw $t5, 0($t3)
addi $t3, $t4, 1160
sw $t5, 0($t3)
addi $t3, $t4, 1164
sw $t5, 0($t3)
addi $t3, $t4, 1168
sw $t5, 0($t3)
addi $t3, $t4, 1172
sw $t5, 0($t3)
addi $t3, $t4, 1176
sw $t5, 0($t3)
addi $t3, $t4, 1180
sw $t5, 0($t3)
addi $t3, $t4, 1184
sw $t5, 0($t3)
addi $t3, $t4, 1188
sw $t5, 0($t3)
addi $t3, $t4, 1192
sw $t5, 0($t3)
addi $t3, $t4, 1196
sw $t5, 0($t3)
addi $t3, $t4, 1200
sw $t5, 0($t3)
addi $t3, $t4, 1204
sw $t5, 0($t3)
addi $t3, $t4, 1208
sw $t5, 0($t3)
addi $t3, $t4, 1212
sw $t5, 0($t3)
addi $t3, $t4, 1216
sw $t5, 0($t3)
addi $t3, $t4, 1220
sw $t5, 0($t3)
addi $t3, $t4, 1224
sw $t5, 0($t3)
addi $t3, $t4, 1228
sw $t5, 0($t3)
addi $t3, $t4, 1232
sw $t5, 0($t3)
addi $t3, $t4, 1236
sw $t5, 0($t3)
addi $t3, $t4, 1240
sw $t5, 0($t3)
addi $t3, $t4, 1244
sw $t5, 0($t3)
addi $t3, $t4, 1248
sw $t5, 0($t3)
addi $t3, $t4, 1252
sw $t5, 0($t3)
addi $t3, $t4, 1256
sw $t5, 0($t3)
addi $t3, $t4, 1260
sw $t5, 0($t3)
addi $t3, $t4, 1264
sw $t5, 0($t3)
addi $t3, $t4, 1268
sw $t5, 0($t3)
addi $t3, $t4, 1272
sw $t5, 0($t3)
addi $t3, $t4, 1276
sw $t5, 0($t3)
addi $t3, $t4, 1280
sw $t5, 0($t3)
addi $t3, $t4, 1284
sw $t5, 0($t3)
addi $t3, $t4, 1288
sw $t5, 0($t3)
addi $t3, $t4, 1292
sw $t5, 0($t3)
addi $t3, $t4, 1296
sw $t5, 0($t3)
addi $t3, $t4, 1300
sw $t5, 0($t3)
addi $t3, $t4, 1304
sw $t5, 0($t3)
addi $t3, $t4, 1308
sw $t5, 0($t3)
addi $t3, $t4, 1312
sw $t5, 0($t3)
addi $t3, $t4, 1316
sw $t5, 0($t3)
addi $t3, $t4, 1320
sw $t5, 0($t3)
addi $t3, $t4, 1324
sw $t5, 0($t3)
addi $t3, $t4, 1328
sw $t5, 0($t3)
addi $t3, $t4, 1332
sw $t5, 0($t3)
addi $t3, $t4, 1336
sw $t5, 0($t3)
addi $t3, $t4, 1340
sw $t5, 0($t3)
addi $t3, $t4, 1344
sw $t5, 0($t3)
addi $t3, $t4, 1348
sw $t5, 0($t3)
addi $t3, $t4, 1352
sw $t5, 0($t3)
addi $t3, $t4, 1356
sw $t5, 0($t3)
addi $t3, $t4, 1360
sw $t5, 0($t3)
addi $t3, $t4, 1364
sw $t5, 0($t3)
addi $t3, $t4, 1368
sw $t5, 0($t3)
addi $t3, $t4, 1372
sw $t5, 0($t3)
addi $t3, $t4, 1376
sw $t5, 0($t3)
addi $t3, $t4, 1380
sw $t5, 0($t3)
addi $t3, $t4, 1384
sw $t5, 0($t3)
addi $t3, $t4, 1388
sw $t5, 0($t3)
addi $t3, $t4, 1392
sw $t5, 0($t3)
addi $t3, $t4, 1396
sw $t5, 0($t3)
addi $t3, $t4, 1400
sw $t5, 0($t3)
addi $t3, $t4, 1404
sw $t5, 0($t3)
addi $t3, $t4, 1408
sw $t5, 0($t3)
addi $t3, $t4, 1412
sw $t5, 0($t3)
addi $t3, $t4, 1416
sw $t5, 0($t3)
addi $t3, $t4, 1420
sw $t5, 0($t3)
addi $t3, $t4, 1424
sw $t5, 0($t3)
addi $t3, $t4, 1428
sw $t5, 0($t3)
addi $t3, $t4, 1432
sw $t5, 0($t3)
addi $t3, $t4, 1436
sw $t5, 0($t3)
addi $t3, $t4, 1440
sw $t5, 0($t3)
addi $t3, $t4, 1444
sw $t5, 0($t3)
addi $t3, $t4, 1448
sw $t5, 0($t3)
addi $t3, $t4, 1452
sw $t5, 0($t3)
addi $t3, $t4, 1456
sw $t5, 0($t3)
addi $t3, $t4, 1460
sw $t5, 0($t3)
addi $t3, $t4, 1464
sw $t5, 0($t3)
addi $t3, $t4, 1468
sw $t5, 0($t3)
addi $t3, $t4, 1472
sw $t5, 0($t3)
addi $t3, $t4, 1476
sw $t5, 0($t3)
addi $t3, $t4, 1480
sw $t5, 0($t3)
addi $t3, $t4, 1484
sw $t5, 0($t3)
addi $t3, $t4, 1488
sw $t5, 0($t3)
addi $t3, $t4, 1492
sw $t5, 0($t3)
addi $t3, $t4, 1496
sw $t5, 0($t3)
addi $t3, $t4, 1500
sw $t5, 0($t3)
addi $t3, $t4, 1504
sw $t5, 0($t3)
addi $t3, $t4, 1508
sw $t5, 0($t3)
addi $t3, $t4, 1512
li $t5,0x252525
sw $t5, 0($t3)
addi $t3, $t4, 1516
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 1520
sw $t5, 0($t3)
addi $t3, $t4, 1524
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 1528
li $t5,0x9a9a9a
sw $t5, 0($t3)
addi $t3, $t4, 1532
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 1536
sw $t5, 0($t3)
addi $t3, $t4, 1540
sw $t5, 0($t3)
addi $t3, $t4, 1544
sw $t5, 0($t3)
addi $t3, $t4, 1548
sw $t5, 0($t3)
addi $t3, $t4, 1552
sw $t5, 0($t3)
addi $t3, $t4, 1556
sw $t5, 0($t3)
addi $t3, $t4, 1560
sw $t5, 0($t3)
addi $t3, $t4, 1564
sw $t5, 0($t3)
addi $t3, $t4, 1568
sw $t5, 0($t3)
addi $t3, $t4, 1572
sw $t5, 0($t3)
addi $t3, $t4, 1576
sw $t5, 0($t3)
addi $t3, $t4, 1580
sw $t5, 0($t3)
addi $t3, $t4, 1584
sw $t5, 0($t3)
addi $t3, $t4, 1588
sw $t5, 0($t3)
addi $t3, $t4, 1592
sw $t5, 0($t3)
addi $t3, $t4, 1596
sw $t5, 0($t3)
addi $t3, $t4, 1600
sw $t5, 0($t3)
addi $t3, $t4, 1604
sw $t5, 0($t3)
addi $t3, $t4, 1608
sw $t5, 0($t3)
addi $t3, $t4, 1612
sw $t5, 0($t3)
addi $t3, $t4, 1616
sw $t5, 0($t3)
addi $t3, $t4, 1620
sw $t5, 0($t3)
addi $t3, $t4, 1624
sw $t5, 0($t3)
addi $t3, $t4, 1628
sw $t5, 0($t3)
addi $t3, $t4, 1632
sw $t5, 0($t3)
addi $t3, $t4, 1636
sw $t5, 0($t3)
addi $t3, $t4, 1640
sw $t5, 0($t3)
addi $t3, $t4, 1644
sw $t5, 0($t3)
addi $t3, $t4, 1648
sw $t5, 0($t3)
addi $t3, $t4, 1652
sw $t5, 0($t3)
addi $t3, $t4, 1656
sw $t5, 0($t3)
addi $t3, $t4, 1660
sw $t5, 0($t3)
addi $t3, $t4, 1664
sw $t5, 0($t3)
addi $t3, $t4, 1668
sw $t5, 0($t3)
addi $t3, $t4, 1672
sw $t5, 0($t3)
addi $t3, $t4, 1676
sw $t5, 0($t3)
addi $t3, $t4, 1680
sw $t5, 0($t3)
addi $t3, $t4, 1684
sw $t5, 0($t3)
addi $t3, $t4, 1688
sw $t5, 0($t3)
addi $t3, $t4, 1692
sw $t5, 0($t3)
addi $t3, $t4, 1696
sw $t5, 0($t3)
addi $t3, $t4, 1700
sw $t5, 0($t3)
addi $t3, $t4, 1704
sw $t5, 0($t3)
addi $t3, $t4, 1708
sw $t5, 0($t3)
addi $t3, $t4, 1712
sw $t5, 0($t3)
addi $t3, $t4, 1716
sw $t5, 0($t3)
addi $t3, $t4, 1720
sw $t5, 0($t3)
addi $t3, $t4, 1724
sw $t5, 0($t3)
addi $t3, $t4, 1728
sw $t5, 0($t3)
addi $t3, $t4, 1732
sw $t5, 0($t3)
addi $t3, $t4, 1736
sw $t5, 0($t3)
addi $t3, $t4, 1740
sw $t5, 0($t3)
addi $t3, $t4, 1744
sw $t5, 0($t3)
addi $t3, $t4, 1748
sw $t5, 0($t3)
addi $t3, $t4, 1752
sw $t5, 0($t3)
addi $t3, $t4, 1756
sw $t5, 0($t3)
addi $t3, $t4, 1760
sw $t5, 0($t3)
addi $t3, $t4, 1764
sw $t5, 0($t3)
addi $t3, $t4, 1768
sw $t5, 0($t3)
addi $t3, $t4, 1772
sw $t5, 0($t3)
addi $t3, $t4, 1776
sw $t5, 0($t3)
addi $t3, $t4, 1780
sw $t5, 0($t3)
addi $t3, $t4, 1784
sw $t5, 0($t3)
addi $t3, $t4, 1788
sw $t5, 0($t3)
addi $t3, $t4, 1792
sw $t5, 0($t3)
addi $t3, $t4, 1796
sw $t5, 0($t3)
addi $t3, $t4, 1800
sw $t5, 0($t3)
addi $t3, $t4, 1804
sw $t5, 0($t3)
addi $t3, $t4, 1808
sw $t5, 0($t3)
addi $t3, $t4, 1812
sw $t5, 0($t3)
addi $t3, $t4, 1816
sw $t5, 0($t3)
addi $t3, $t4, 1820
sw $t5, 0($t3)
addi $t3, $t4, 1824
sw $t5, 0($t3)
addi $t3, $t4, 1828
sw $t5, 0($t3)
addi $t3, $t4, 1832
sw $t5, 0($t3)
addi $t3, $t4, 1836
sw $t5, 0($t3)
addi $t3, $t4, 1840
sw $t5, 0($t3)
addi $t3, $t4, 1844
sw $t5, 0($t3)
addi $t3, $t4, 1848
sw $t5, 0($t3)
addi $t3, $t4, 1852
sw $t5, 0($t3)
addi $t3, $t4, 1856
sw $t5, 0($t3)
addi $t3, $t4, 1860
sw $t5, 0($t3)
addi $t3, $t4, 1864
sw $t5, 0($t3)
addi $t3, $t4, 1868
sw $t5, 0($t3)
addi $t3, $t4, 1872
sw $t5, 0($t3)
addi $t3, $t4, 1876
sw $t5, 0($t3)
addi $t3, $t4, 1880
sw $t5, 0($t3)
addi $t3, $t4, 1884
sw $t5, 0($t3)
addi $t3, $t4, 1888
sw $t5, 0($t3)
addi $t3, $t4, 1892
sw $t5, 0($t3)
addi $t3, $t4, 1896
sw $t5, 0($t3)
addi $t3, $t4, 1900
sw $t5, 0($t3)
addi $t3, $t4, 1904
sw $t5, 0($t3)
addi $t3, $t4, 1908
sw $t5, 0($t3)
addi $t3, $t4, 1912
sw $t5, 0($t3)
addi $t3, $t4, 1916
sw $t5, 0($t3)
addi $t3, $t4, 1920
sw $t5, 0($t3)
addi $t3, $t4, 1924
sw $t5, 0($t3)
addi $t3, $t4, 1928
sw $t5, 0($t3)
addi $t3, $t4, 1932
sw $t5, 0($t3)
addi $t3, $t4, 1936
sw $t5, 0($t3)
addi $t3, $t4, 1940
sw $t5, 0($t3)
addi $t3, $t4, 1944
sw $t5, 0($t3)
addi $t3, $t4, 1948
sw $t5, 0($t3)
addi $t3, $t4, 1952
sw $t5, 0($t3)
addi $t3, $t4, 1956
sw $t5, 0($t3)
addi $t3, $t4, 1960
sw $t5, 0($t3)
addi $t3, $t4, 1964
sw $t5, 0($t3)
addi $t3, $t4, 1968
sw $t5, 0($t3)
addi $t3, $t4, 1972
sw $t5, 0($t3)
addi $t3, $t4, 1976
sw $t5, 0($t3)
addi $t3, $t4, 1980
sw $t5, 0($t3)
addi $t3, $t4, 1984
sw $t5, 0($t3)
addi $t3, $t4, 1988
sw $t5, 0($t3)
addi $t3, $t4, 1992
sw $t5, 0($t3)
addi $t3, $t4, 1996
sw $t5, 0($t3)
addi $t3, $t4, 2000
sw $t5, 0($t3)
addi $t3, $t4, 2004
sw $t5, 0($t3)
addi $t3, $t4, 2008
sw $t5, 0($t3)
addi $t3, $t4, 2012
sw $t5, 0($t3)
addi $t3, $t4, 2016
sw $t5, 0($t3)
addi $t3, $t4, 2020
sw $t5, 0($t3)
addi $t3, $t4, 2024
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 2028
sw $t5, 0($t3)
addi $t3, $t4, 2032
sw $t5, 0($t3)
addi $t3, $t4, 2036
sw $t5, 0($t3)
addi $t3, $t4, 2040
li $t5,0x535353
sw $t5, 0($t3)
addi $t3, $t4, 2044
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 2048
sw $t5, 0($t3)
addi $t3, $t4, 2052
sw $t5, 0($t3)
addi $t3, $t4, 2056
sw $t5, 0($t3)
addi $t3, $t4, 2060
sw $t5, 0($t3)
addi $t3, $t4, 2064
sw $t5, 0($t3)
addi $t3, $t4, 2068
sw $t5, 0($t3)
addi $t3, $t4, 2072
sw $t5, 0($t3)
addi $t3, $t4, 2076
sw $t5, 0($t3)
addi $t3, $t4, 2080
sw $t5, 0($t3)
addi $t3, $t4, 2084
sw $t5, 0($t3)
addi $t3, $t4, 2088
sw $t5, 0($t3)
addi $t3, $t4, 2092
sw $t5, 0($t3)
addi $t3, $t4, 2096
sw $t5, 0($t3)
addi $t3, $t4, 2100
sw $t5, 0($t3)
addi $t3, $t4, 2104
sw $t5, 0($t3)
addi $t3, $t4, 2108
sw $t5, 0($t3)
addi $t3, $t4, 2112
sw $t5, 0($t3)
addi $t3, $t4, 2116
sw $t5, 0($t3)
addi $t3, $t4, 2120
sw $t5, 0($t3)
addi $t3, $t4, 2124
sw $t5, 0($t3)
addi $t3, $t4, 2128
sw $t5, 0($t3)
addi $t3, $t4, 2132
sw $t5, 0($t3)
addi $t3, $t4, 2136
sw $t5, 0($t3)
addi $t3, $t4, 2140
sw $t5, 0($t3)
addi $t3, $t4, 2144
sw $t5, 0($t3)
addi $t3, $t4, 2148
sw $t5, 0($t3)
addi $t3, $t4, 2152
sw $t5, 0($t3)
addi $t3, $t4, 2156
sw $t5, 0($t3)
addi $t3, $t4, 2160
sw $t5, 0($t3)
addi $t3, $t4, 2164
sw $t5, 0($t3)
addi $t3, $t4, 2168
sw $t5, 0($t3)
addi $t3, $t4, 2172
sw $t5, 0($t3)
addi $t3, $t4, 2176
sw $t5, 0($t3)
addi $t3, $t4, 2180
sw $t5, 0($t3)
addi $t3, $t4, 2184
sw $t5, 0($t3)
addi $t3, $t4, 2188
sw $t5, 0($t3)
addi $t3, $t4, 2192
sw $t5, 0($t3)
addi $t3, $t4, 2196
sw $t5, 0($t3)
addi $t3, $t4, 2200
sw $t5, 0($t3)
addi $t3, $t4, 2204
sw $t5, 0($t3)
addi $t3, $t4, 2208
sw $t5, 0($t3)
addi $t3, $t4, 2212
sw $t5, 0($t3)
addi $t3, $t4, 2216
sw $t5, 0($t3)
addi $t3, $t4, 2220
sw $t5, 0($t3)
addi $t3, $t4, 2224
sw $t5, 0($t3)
addi $t3, $t4, 2228
sw $t5, 0($t3)
addi $t3, $t4, 2232
sw $t5, 0($t3)
addi $t3, $t4, 2236
sw $t5, 0($t3)
addi $t3, $t4, 2240
sw $t5, 0($t3)
addi $t3, $t4, 2244
sw $t5, 0($t3)
addi $t3, $t4, 2248
sw $t5, 0($t3)
addi $t3, $t4, 2252
sw $t5, 0($t3)
addi $t3, $t4, 2256
sw $t5, 0($t3)
addi $t3, $t4, 2260
sw $t5, 0($t3)
addi $t3, $t4, 2264
sw $t5, 0($t3)
addi $t3, $t4, 2268
sw $t5, 0($t3)
addi $t3, $t4, 2272
sw $t5, 0($t3)
addi $t3, $t4, 2276
sw $t5, 0($t3)
addi $t3, $t4, 2280
sw $t5, 0($t3)
addi $t3, $t4, 2284
sw $t5, 0($t3)
addi $t3, $t4, 2288
sw $t5, 0($t3)
addi $t3, $t4, 2292
sw $t5, 0($t3)
addi $t3, $t4, 2296
sw $t5, 0($t3)
addi $t3, $t4, 2300
sw $t5, 0($t3)
addi $t3, $t4, 2304
sw $t5, 0($t3)
addi $t3, $t4, 2308
sw $t5, 0($t3)
addi $t3, $t4, 2312
sw $t5, 0($t3)
addi $t3, $t4, 2316
sw $t5, 0($t3)
addi $t3, $t4, 2320
sw $t5, 0($t3)
addi $t3, $t4, 2324
sw $t5, 0($t3)
addi $t3, $t4, 2328
sw $t5, 0($t3)
addi $t3, $t4, 2332
sw $t5, 0($t3)
addi $t3, $t4, 2336
sw $t5, 0($t3)
addi $t3, $t4, 2340
sw $t5, 0($t3)
addi $t3, $t4, 2344
sw $t5, 0($t3)
addi $t3, $t4, 2348
sw $t5, 0($t3)
addi $t3, $t4, 2352
sw $t5, 0($t3)
addi $t3, $t4, 2356
sw $t5, 0($t3)
addi $t3, $t4, 2360
sw $t5, 0($t3)
addi $t3, $t4, 2364
sw $t5, 0($t3)
addi $t3, $t4, 2368
sw $t5, 0($t3)
addi $t3, $t4, 2372
sw $t5, 0($t3)
addi $t3, $t4, 2376
sw $t5, 0($t3)
addi $t3, $t4, 2380
sw $t5, 0($t3)
addi $t3, $t4, 2384
sw $t5, 0($t3)
addi $t3, $t4, 2388
sw $t5, 0($t3)
addi $t3, $t4, 2392
sw $t5, 0($t3)
addi $t3, $t4, 2396
sw $t5, 0($t3)
addi $t3, $t4, 2400
sw $t5, 0($t3)
addi $t3, $t4, 2404
sw $t5, 0($t3)
addi $t3, $t4, 2408
sw $t5, 0($t3)
addi $t3, $t4, 2412
sw $t5, 0($t3)
addi $t3, $t4, 2416
sw $t5, 0($t3)
addi $t3, $t4, 2420
sw $t5, 0($t3)
addi $t3, $t4, 2424
sw $t5, 0($t3)
addi $t3, $t4, 2428
sw $t5, 0($t3)
addi $t3, $t4, 2432
sw $t5, 0($t3)
addi $t3, $t4, 2436
sw $t5, 0($t3)
addi $t3, $t4, 2440
sw $t5, 0($t3)
addi $t3, $t4, 2444
sw $t5, 0($t3)
addi $t3, $t4, 2448
sw $t5, 0($t3)
addi $t3, $t4, 2452
sw $t5, 0($t3)
addi $t3, $t4, 2456
sw $t5, 0($t3)
addi $t3, $t4, 2460
sw $t5, 0($t3)
addi $t3, $t4, 2464
sw $t5, 0($t3)
addi $t3, $t4, 2468
sw $t5, 0($t3)
addi $t3, $t4, 2472
sw $t5, 0($t3)
addi $t3, $t4, 2476
sw $t5, 0($t3)
addi $t3, $t4, 2480
sw $t5, 0($t3)
addi $t3, $t4, 2484
sw $t5, 0($t3)
addi $t3, $t4, 2488
sw $t5, 0($t3)
addi $t3, $t4, 2492
sw $t5, 0($t3)
addi $t3, $t4, 2496
sw $t5, 0($t3)
addi $t3, $t4, 2500
sw $t5, 0($t3)
addi $t3, $t4, 2504
sw $t5, 0($t3)
addi $t3, $t4, 2508
sw $t5, 0($t3)
addi $t3, $t4, 2512
sw $t5, 0($t3)
addi $t3, $t4, 2516
sw $t5, 0($t3)
addi $t3, $t4, 2520
sw $t5, 0($t3)
addi $t3, $t4, 2524
sw $t5, 0($t3)
addi $t3, $t4, 2528
sw $t5, 0($t3)
addi $t3, $t4, 2532
li $t5,0xdadada
sw $t5, 0($t3)
addi $t3, $t4, 2536
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 2540
sw $t5, 0($t3)
addi $t3, $t4, 2544
sw $t5, 0($t3)
addi $t3, $t4, 2548
sw $t5, 0($t3)
addi $t3, $t4, 2552
li $t5,0xc6c6c6
sw $t5, 0($t3)
addi $t3, $t4, 2556
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 2560
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 2564
sw $t5, 0($t3)
addi $t3, $t4, 2568
sw $t5, 0($t3)
addi $t3, $t4, 2572
sw $t5, 0($t3)
addi $t3, $t4, 2576
sw $t5, 0($t3)
addi $t3, $t4, 2580
sw $t5, 0($t3)
addi $t3, $t4, 2584
sw $t5, 0($t3)
addi $t3, $t4, 2588
sw $t5, 0($t3)
addi $t3, $t4, 2592
sw $t5, 0($t3)
addi $t3, $t4, 2596
sw $t5, 0($t3)
addi $t3, $t4, 2600
sw $t5, 0($t3)
addi $t3, $t4, 2604
sw $t5, 0($t3)
addi $t3, $t4, 2608
sw $t5, 0($t3)
addi $t3, $t4, 2612
sw $t5, 0($t3)
addi $t3, $t4, 2616
sw $t5, 0($t3)
addi $t3, $t4, 2620
sw $t5, 0($t3)
addi $t3, $t4, 2624
sw $t5, 0($t3)
addi $t3, $t4, 2628
sw $t5, 0($t3)
addi $t3, $t4, 2632
sw $t5, 0($t3)
addi $t3, $t4, 2636
sw $t5, 0($t3)
addi $t3, $t4, 2640
sw $t5, 0($t3)
addi $t3, $t4, 2644
sw $t5, 0($t3)
addi $t3, $t4, 2648
sw $t5, 0($t3)
addi $t3, $t4, 2652
sw $t5, 0($t3)
addi $t3, $t4, 2656
sw $t5, 0($t3)
addi $t3, $t4, 2660
sw $t5, 0($t3)
addi $t3, $t4, 2664
sw $t5, 0($t3)
addi $t3, $t4, 2668
sw $t5, 0($t3)
addi $t3, $t4, 2672
sw $t5, 0($t3)
addi $t3, $t4, 2676
sw $t5, 0($t3)
addi $t3, $t4, 2680
sw $t5, 0($t3)
addi $t3, $t4, 2684
sw $t5, 0($t3)
addi $t3, $t4, 2688
sw $t5, 0($t3)
addi $t3, $t4, 2692
sw $t5, 0($t3)
addi $t3, $t4, 2696
sw $t5, 0($t3)
addi $t3, $t4, 2700
sw $t5, 0($t3)
addi $t3, $t4, 2704
sw $t5, 0($t3)
addi $t3, $t4, 2708
sw $t5, 0($t3)
addi $t3, $t4, 2712
sw $t5, 0($t3)
addi $t3, $t4, 2716
sw $t5, 0($t3)
addi $t3, $t4, 2720
sw $t5, 0($t3)
addi $t3, $t4, 2724
sw $t5, 0($t3)
addi $t3, $t4, 2728
sw $t5, 0($t3)
addi $t3, $t4, 2732
sw $t5, 0($t3)
addi $t3, $t4, 2736
sw $t5, 0($t3)
addi $t3, $t4, 2740
sw $t5, 0($t3)
addi $t3, $t4, 2744
sw $t5, 0($t3)
addi $t3, $t4, 2748
sw $t5, 0($t3)
addi $t3, $t4, 2752
sw $t5, 0($t3)
addi $t3, $t4, 2756
sw $t5, 0($t3)
addi $t3, $t4, 2760
sw $t5, 0($t3)
addi $t3, $t4, 2764
sw $t5, 0($t3)
addi $t3, $t4, 2768
sw $t5, 0($t3)
addi $t3, $t4, 2772
sw $t5, 0($t3)
addi $t3, $t4, 2776
sw $t5, 0($t3)
addi $t3, $t4, 2780
sw $t5, 0($t3)
addi $t3, $t4, 2784
sw $t5, 0($t3)
addi $t3, $t4, 2788
sw $t5, 0($t3)
addi $t3, $t4, 2792
sw $t5, 0($t3)
addi $t3, $t4, 2796
sw $t5, 0($t3)
addi $t3, $t4, 2800
sw $t5, 0($t3)
addi $t3, $t4, 2804
sw $t5, 0($t3)
addi $t3, $t4, 2808
sw $t5, 0($t3)
addi $t3, $t4, 2812
sw $t5, 0($t3)
addi $t3, $t4, 2816
sw $t5, 0($t3)
addi $t3, $t4, 2820
sw $t5, 0($t3)
addi $t3, $t4, 2824
sw $t5, 0($t3)
addi $t3, $t4, 2828
sw $t5, 0($t3)
addi $t3, $t4, 2832
sw $t5, 0($t3)
addi $t3, $t4, 2836
sw $t5, 0($t3)
addi $t3, $t4, 2840
sw $t5, 0($t3)
addi $t3, $t4, 2844
sw $t5, 0($t3)
addi $t3, $t4, 2848
sw $t5, 0($t3)
addi $t3, $t4, 2852
sw $t5, 0($t3)
addi $t3, $t4, 2856
sw $t5, 0($t3)
addi $t3, $t4, 2860
sw $t5, 0($t3)
addi $t3, $t4, 2864
sw $t5, 0($t3)
addi $t3, $t4, 2868
sw $t5, 0($t3)
addi $t3, $t4, 2872
sw $t5, 0($t3)
addi $t3, $t4, 2876
sw $t5, 0($t3)
addi $t3, $t4, 2880
sw $t5, 0($t3)
addi $t3, $t4, 2884
sw $t5, 0($t3)
addi $t3, $t4, 2888
sw $t5, 0($t3)
addi $t3, $t4, 2892
sw $t5, 0($t3)
addi $t3, $t4, 2896
sw $t5, 0($t3)
addi $t3, $t4, 2900
sw $t5, 0($t3)
addi $t3, $t4, 2904
sw $t5, 0($t3)
addi $t3, $t4, 2908
sw $t5, 0($t3)
addi $t3, $t4, 2912
sw $t5, 0($t3)
addi $t3, $t4, 2916
sw $t5, 0($t3)
addi $t3, $t4, 2920
sw $t5, 0($t3)
addi $t3, $t4, 2924
sw $t5, 0($t3)
addi $t3, $t4, 2928
sw $t5, 0($t3)
addi $t3, $t4, 2932
sw $t5, 0($t3)
addi $t3, $t4, 2936
sw $t5, 0($t3)
addi $t3, $t4, 2940
sw $t5, 0($t3)
addi $t3, $t4, 2944
sw $t5, 0($t3)
addi $t3, $t4, 2948
sw $t5, 0($t3)
addi $t3, $t4, 2952
sw $t5, 0($t3)
addi $t3, $t4, 2956
sw $t5, 0($t3)
addi $t3, $t4, 2960
sw $t5, 0($t3)
addi $t3, $t4, 2964
sw $t5, 0($t3)
addi $t3, $t4, 2968
sw $t5, 0($t3)
addi $t3, $t4, 2972
sw $t5, 0($t3)
addi $t3, $t4, 2976
sw $t5, 0($t3)
addi $t3, $t4, 2980
sw $t5, 0($t3)
addi $t3, $t4, 2984
sw $t5, 0($t3)
addi $t3, $t4, 2988
sw $t5, 0($t3)
addi $t3, $t4, 2992
sw $t5, 0($t3)
addi $t3, $t4, 2996
sw $t5, 0($t3)
addi $t3, $t4, 3000
sw $t5, 0($t3)
addi $t3, $t4, 3004
sw $t5, 0($t3)
addi $t3, $t4, 3008
sw $t5, 0($t3)
addi $t3, $t4, 3012
sw $t5, 0($t3)
addi $t3, $t4, 3016
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 3020
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 3024
sw $t5, 0($t3)
addi $t3, $t4, 3028
sw $t5, 0($t3)
addi $t3, $t4, 3032
sw $t5, 0($t3)
addi $t3, $t4, 3036
sw $t5, 0($t3)
addi $t3, $t4, 3040
sw $t5, 0($t3)
addi $t3, $t4, 3044
li $t5,0x7d7d7d
sw $t5, 0($t3)
addi $t3, $t4, 3048
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 3052
sw $t5, 0($t3)
addi $t3, $t4, 3056
sw $t5, 0($t3)
addi $t3, $t4, 3060
sw $t5, 0($t3)
addi $t3, $t4, 3064
li $t5,0xf1f1f1
sw $t5, 0($t3)
addi $t3, $t4, 3068
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 3072
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 3076
sw $t5, 0($t3)
addi $t3, $t4, 3080
sw $t5, 0($t3)
addi $t3, $t4, 3084
sw $t5, 0($t3)
addi $t3, $t4, 3088
sw $t5, 0($t3)
addi $t3, $t4, 3092
sw $t5, 0($t3)
addi $t3, $t4, 3096
sw $t5, 0($t3)
addi $t3, $t4, 3100
sw $t5, 0($t3)
addi $t3, $t4, 3104
sw $t5, 0($t3)
addi $t3, $t4, 3108
sw $t5, 0($t3)
addi $t3, $t4, 3112
sw $t5, 0($t3)
addi $t3, $t4, 3116
sw $t5, 0($t3)
addi $t3, $t4, 3120
sw $t5, 0($t3)
addi $t3, $t4, 3124
sw $t5, 0($t3)
addi $t3, $t4, 3128
sw $t5, 0($t3)
addi $t3, $t4, 3132
sw $t5, 0($t3)
addi $t3, $t4, 3136
sw $t5, 0($t3)
addi $t3, $t4, 3140
sw $t5, 0($t3)
addi $t3, $t4, 3144
sw $t5, 0($t3)
addi $t3, $t4, 3148
sw $t5, 0($t3)
addi $t3, $t4, 3152
sw $t5, 0($t3)
addi $t3, $t4, 3156
sw $t5, 0($t3)
addi $t3, $t4, 3160
sw $t5, 0($t3)
addi $t3, $t4, 3164
sw $t5, 0($t3)
addi $t3, $t4, 3168
sw $t5, 0($t3)
addi $t3, $t4, 3172
sw $t5, 0($t3)
addi $t3, $t4, 3176
sw $t5, 0($t3)
addi $t3, $t4, 3180
sw $t5, 0($t3)
addi $t3, $t4, 3184
sw $t5, 0($t3)
addi $t3, $t4, 3188
sw $t5, 0($t3)
addi $t3, $t4, 3192
sw $t5, 0($t3)
addi $t3, $t4, 3196
sw $t5, 0($t3)
addi $t3, $t4, 3200
sw $t5, 0($t3)
addi $t3, $t4, 3204
sw $t5, 0($t3)
addi $t3, $t4, 3208
sw $t5, 0($t3)
addi $t3, $t4, 3212
sw $t5, 0($t3)
addi $t3, $t4, 3216
sw $t5, 0($t3)
addi $t3, $t4, 3220
sw $t5, 0($t3)
addi $t3, $t4, 3224
sw $t5, 0($t3)
addi $t3, $t4, 3228
sw $t5, 0($t3)
addi $t3, $t4, 3232
sw $t5, 0($t3)
addi $t3, $t4, 3236
sw $t5, 0($t3)
addi $t3, $t4, 3240
sw $t5, 0($t3)
addi $t3, $t4, 3244
sw $t5, 0($t3)
addi $t3, $t4, 3248
sw $t5, 0($t3)
addi $t3, $t4, 3252
sw $t5, 0($t3)
addi $t3, $t4, 3256
sw $t5, 0($t3)
addi $t3, $t4, 3260
sw $t5, 0($t3)
addi $t3, $t4, 3264
sw $t5, 0($t3)
addi $t3, $t4, 3268
sw $t5, 0($t3)
addi $t3, $t4, 3272
sw $t5, 0($t3)
addi $t3, $t4, 3276
sw $t5, 0($t3)
addi $t3, $t4, 3280
sw $t5, 0($t3)
addi $t3, $t4, 3284
sw $t5, 0($t3)
addi $t3, $t4, 3288
sw $t5, 0($t3)
addi $t3, $t4, 3292
sw $t5, 0($t3)
addi $t3, $t4, 3296
sw $t5, 0($t3)
addi $t3, $t4, 3300
sw $t5, 0($t3)
addi $t3, $t4, 3304
sw $t5, 0($t3)
addi $t3, $t4, 3308
sw $t5, 0($t3)
addi $t3, $t4, 3312
sw $t5, 0($t3)
addi $t3, $t4, 3316
sw $t5, 0($t3)
addi $t3, $t4, 3320
sw $t5, 0($t3)
addi $t3, $t4, 3324
sw $t5, 0($t3)
addi $t3, $t4, 3328
sw $t5, 0($t3)
addi $t3, $t4, 3332
sw $t5, 0($t3)
addi $t3, $t4, 3336
sw $t5, 0($t3)
addi $t3, $t4, 3340
sw $t5, 0($t3)
addi $t3, $t4, 3344
sw $t5, 0($t3)
addi $t3, $t4, 3348
sw $t5, 0($t3)
addi $t3, $t4, 3352
sw $t5, 0($t3)
addi $t3, $t4, 3356
sw $t5, 0($t3)
addi $t3, $t4, 3360
sw $t5, 0($t3)
addi $t3, $t4, 3364
sw $t5, 0($t3)
addi $t3, $t4, 3368
sw $t5, 0($t3)
addi $t3, $t4, 3372
sw $t5, 0($t3)
addi $t3, $t4, 3376
sw $t5, 0($t3)
addi $t3, $t4, 3380
sw $t5, 0($t3)
addi $t3, $t4, 3384
sw $t5, 0($t3)
addi $t3, $t4, 3388
sw $t5, 0($t3)
addi $t3, $t4, 3392
sw $t5, 0($t3)
addi $t3, $t4, 3396
sw $t5, 0($t3)
addi $t3, $t4, 3400
sw $t5, 0($t3)
addi $t3, $t4, 3404
sw $t5, 0($t3)
addi $t3, $t4, 3408
sw $t5, 0($t3)
addi $t3, $t4, 3412
sw $t5, 0($t3)
addi $t3, $t4, 3416
sw $t5, 0($t3)
addi $t3, $t4, 3420
sw $t5, 0($t3)
addi $t3, $t4, 3424
sw $t5, 0($t3)
addi $t3, $t4, 3428
sw $t5, 0($t3)
addi $t3, $t4, 3432
sw $t5, 0($t3)
addi $t3, $t4, 3436
sw $t5, 0($t3)
addi $t3, $t4, 3440
sw $t5, 0($t3)
addi $t3, $t4, 3444
sw $t5, 0($t3)
addi $t3, $t4, 3448
sw $t5, 0($t3)
addi $t3, $t4, 3452
sw $t5, 0($t3)
addi $t3, $t4, 3456
sw $t5, 0($t3)
addi $t3, $t4, 3460
sw $t5, 0($t3)
addi $t3, $t4, 3464
sw $t5, 0($t3)
addi $t3, $t4, 3468
sw $t5, 0($t3)
addi $t3, $t4, 3472
sw $t5, 0($t3)
addi $t3, $t4, 3476
sw $t5, 0($t3)
addi $t3, $t4, 3480
sw $t5, 0($t3)
addi $t3, $t4, 3484
sw $t5, 0($t3)
addi $t3, $t4, 3488
sw $t5, 0($t3)
addi $t3, $t4, 3492
sw $t5, 0($t3)
addi $t3, $t4, 3496
sw $t5, 0($t3)
addi $t3, $t4, 3500
sw $t5, 0($t3)
addi $t3, $t4, 3504
sw $t5, 0($t3)
addi $t3, $t4, 3508
sw $t5, 0($t3)
addi $t3, $t4, 3512
sw $t5, 0($t3)
addi $t3, $t4, 3516
sw $t5, 0($t3)
addi $t3, $t4, 3520
sw $t5, 0($t3)
addi $t3, $t4, 3524
sw $t5, 0($t3)
addi $t3, $t4, 3528
li $t5,0x0f0f0f
sw $t5, 0($t3)
addi $t3, $t4, 3532
li $t5,0x9d9d9d
sw $t5, 0($t3)
addi $t3, $t4, 3536
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 3540
sw $t5, 0($t3)
addi $t3, $t4, 3544
sw $t5, 0($t3)
addi $t3, $t4, 3548
sw $t5, 0($t3)
addi $t3, $t4, 3552
li $t5,0xfdfdfd
sw $t5, 0($t3)
addi $t3, $t4, 3556
li $t5,0x080808
sw $t5, 0($t3)
addi $t3, $t4, 3560
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 3564
sw $t5, 0($t3)
addi $t3, $t4, 3568
sw $t5, 0($t3)
addi $t3, $t4, 3572
li $t5,0x080808
sw $t5, 0($t3)
addi $t3, $t4, 3576
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 3580
sw $t5, 0($t3)
addi $t3, $t4, 3584
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 3588
sw $t5, 0($t3)
addi $t3, $t4, 3592
sw $t5, 0($t3)
addi $t3, $t4, 3596
sw $t5, 0($t3)
addi $t3, $t4, 3600
sw $t5, 0($t3)
addi $t3, $t4, 3604
sw $t5, 0($t3)
addi $t3, $t4, 3608
sw $t5, 0($t3)
addi $t3, $t4, 3612
sw $t5, 0($t3)
addi $t3, $t4, 3616
sw $t5, 0($t3)
addi $t3, $t4, 3620
sw $t5, 0($t3)
addi $t3, $t4, 3624
sw $t5, 0($t3)
addi $t3, $t4, 3628
sw $t5, 0($t3)
addi $t3, $t4, 3632
sw $t5, 0($t3)
addi $t3, $t4, 3636
sw $t5, 0($t3)
addi $t3, $t4, 3640
sw $t5, 0($t3)
addi $t3, $t4, 3644
sw $t5, 0($t3)
addi $t3, $t4, 3648
sw $t5, 0($t3)
addi $t3, $t4, 3652
sw $t5, 0($t3)
addi $t3, $t4, 3656
sw $t5, 0($t3)
addi $t3, $t4, 3660
sw $t5, 0($t3)
addi $t3, $t4, 3664
sw $t5, 0($t3)
addi $t3, $t4, 3668
sw $t5, 0($t3)
addi $t3, $t4, 3672
sw $t5, 0($t3)
addi $t3, $t4, 3676
sw $t5, 0($t3)
addi $t3, $t4, 3680
sw $t5, 0($t3)
addi $t3, $t4, 3684
sw $t5, 0($t3)
addi $t3, $t4, 3688
sw $t5, 0($t3)
addi $t3, $t4, 3692
sw $t5, 0($t3)
addi $t3, $t4, 3696
sw $t5, 0($t3)
addi $t3, $t4, 3700
sw $t5, 0($t3)
addi $t3, $t4, 3704
sw $t5, 0($t3)
addi $t3, $t4, 3708
sw $t5, 0($t3)
addi $t3, $t4, 3712
sw $t5, 0($t3)
addi $t3, $t4, 3716
sw $t5, 0($t3)
addi $t3, $t4, 3720
sw $t5, 0($t3)
addi $t3, $t4, 3724
sw $t5, 0($t3)
addi $t3, $t4, 3728
sw $t5, 0($t3)
addi $t3, $t4, 3732
sw $t5, 0($t3)
addi $t3, $t4, 3736
sw $t5, 0($t3)
addi $t3, $t4, 3740
sw $t5, 0($t3)
addi $t3, $t4, 3744
sw $t5, 0($t3)
addi $t3, $t4, 3748
sw $t5, 0($t3)
addi $t3, $t4, 3752
sw $t5, 0($t3)
addi $t3, $t4, 3756
sw $t5, 0($t3)
addi $t3, $t4, 3760
sw $t5, 0($t3)
addi $t3, $t4, 3764
sw $t5, 0($t3)
addi $t3, $t4, 3768
sw $t5, 0($t3)
addi $t3, $t4, 3772
sw $t5, 0($t3)
addi $t3, $t4, 3776
sw $t5, 0($t3)
addi $t3, $t4, 3780
sw $t5, 0($t3)
addi $t3, $t4, 3784
sw $t5, 0($t3)
addi $t3, $t4, 3788
sw $t5, 0($t3)
addi $t3, $t4, 3792
sw $t5, 0($t3)
addi $t3, $t4, 3796
sw $t5, 0($t3)
addi $t3, $t4, 3800
sw $t5, 0($t3)
addi $t3, $t4, 3804
sw $t5, 0($t3)
addi $t3, $t4, 3808
sw $t5, 0($t3)
addi $t3, $t4, 3812
sw $t5, 0($t3)
addi $t3, $t4, 3816
sw $t5, 0($t3)
addi $t3, $t4, 3820
sw $t5, 0($t3)
addi $t3, $t4, 3824
sw $t5, 0($t3)
addi $t3, $t4, 3828
sw $t5, 0($t3)
addi $t3, $t4, 3832
sw $t5, 0($t3)
addi $t3, $t4, 3836
sw $t5, 0($t3)
addi $t3, $t4, 3840
sw $t5, 0($t3)
addi $t3, $t4, 3844
sw $t5, 0($t3)
addi $t3, $t4, 3848
sw $t5, 0($t3)
addi $t3, $t4, 3852
sw $t5, 0($t3)
addi $t3, $t4, 3856
sw $t5, 0($t3)
addi $t3, $t4, 3860
sw $t5, 0($t3)
addi $t3, $t4, 3864
sw $t5, 0($t3)
addi $t3, $t4, 3868
sw $t5, 0($t3)
addi $t3, $t4, 3872
sw $t5, 0($t3)
addi $t3, $t4, 3876
sw $t5, 0($t3)
addi $t3, $t4, 3880
sw $t5, 0($t3)
addi $t3, $t4, 3884
sw $t5, 0($t3)
addi $t3, $t4, 3888
sw $t5, 0($t3)
addi $t3, $t4, 3892
sw $t5, 0($t3)
addi $t3, $t4, 3896
sw $t5, 0($t3)
addi $t3, $t4, 3900
sw $t5, 0($t3)
addi $t3, $t4, 3904
sw $t5, 0($t3)
addi $t3, $t4, 3908
sw $t5, 0($t3)
addi $t3, $t4, 3912
sw $t5, 0($t3)
addi $t3, $t4, 3916
sw $t5, 0($t3)
addi $t3, $t4, 3920
sw $t5, 0($t3)
addi $t3, $t4, 3924
sw $t5, 0($t3)
addi $t3, $t4, 3928
sw $t5, 0($t3)
addi $t3, $t4, 3932
sw $t5, 0($t3)
addi $t3, $t4, 3936
sw $t5, 0($t3)
addi $t3, $t4, 3940
sw $t5, 0($t3)
addi $t3, $t4, 3944
sw $t5, 0($t3)
addi $t3, $t4, 3948
sw $t5, 0($t3)
addi $t3, $t4, 3952
sw $t5, 0($t3)
addi $t3, $t4, 3956
sw $t5, 0($t3)
addi $t3, $t4, 3960
sw $t5, 0($t3)
addi $t3, $t4, 3964
sw $t5, 0($t3)
addi $t3, $t4, 3968
sw $t5, 0($t3)
addi $t3, $t4, 3972
sw $t5, 0($t3)
addi $t3, $t4, 3976
sw $t5, 0($t3)
addi $t3, $t4, 3980
sw $t5, 0($t3)
addi $t3, $t4, 3984
sw $t5, 0($t3)
addi $t3, $t4, 3988
sw $t5, 0($t3)
addi $t3, $t4, 3992
sw $t5, 0($t3)
addi $t3, $t4, 3996
sw $t5, 0($t3)
addi $t3, $t4, 4000
sw $t5, 0($t3)
addi $t3, $t4, 4004
sw $t5, 0($t3)
addi $t3, $t4, 4008
sw $t5, 0($t3)
addi $t3, $t4, 4012
sw $t5, 0($t3)
addi $t3, $t4, 4016
sw $t5, 0($t3)
addi $t3, $t4, 4020
sw $t5, 0($t3)
addi $t3, $t4, 4024
sw $t5, 0($t3)
addi $t3, $t4, 4028
sw $t5, 0($t3)
addi $t3, $t4, 4032
sw $t5, 0($t3)
addi $t3, $t4, 4036
li $t5,0x606060
sw $t5, 0($t3)
addi $t3, $t4, 4040
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 4044
li $t5,0x020202
sw $t5, 0($t3)
addi $t3, $t4, 4048
li $t5,0xa4a4a4
sw $t5, 0($t3)
addi $t3, $t4, 4052
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 4056
sw $t5, 0($t3)
addi $t3, $t4, 4060
sw $t5, 0($t3)
addi $t3, $t4, 4064
li $t5,0xfdfdfd
sw $t5, 0($t3)
addi $t3, $t4, 4068
li $t5,0x020202
sw $t5, 0($t3)
addi $t3, $t4, 4072
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 4076
sw $t5, 0($t3)
addi $t3, $t4, 4080
sw $t5, 0($t3)
addi $t3, $t4, 4084
li $t5,0x222222
sw $t5, 0($t3)
addi $t3, $t4, 4088
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 4092
sw $t5, 0($t3)
addi $t3, $t4, 4096
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 4100
sw $t5, 0($t3)
addi $t3, $t4, 4104
sw $t5, 0($t3)
addi $t3, $t4, 4108
sw $t5, 0($t3)
addi $t3, $t4, 4112
sw $t5, 0($t3)
addi $t3, $t4, 4116
sw $t5, 0($t3)
addi $t3, $t4, 4120
sw $t5, 0($t3)
addi $t3, $t4, 4124
sw $t5, 0($t3)
addi $t3, $t4, 4128
sw $t5, 0($t3)
addi $t3, $t4, 4132
sw $t5, 0($t3)
addi $t3, $t4, 4136
sw $t5, 0($t3)
addi $t3, $t4, 4140
sw $t5, 0($t3)
addi $t3, $t4, 4144
sw $t5, 0($t3)
addi $t3, $t4, 4148
sw $t5, 0($t3)
addi $t3, $t4, 4152
sw $t5, 0($t3)
addi $t3, $t4, 4156
sw $t5, 0($t3)
addi $t3, $t4, 4160
sw $t5, 0($t3)
addi $t3, $t4, 4164
sw $t5, 0($t3)
addi $t3, $t4, 4168
sw $t5, 0($t3)
addi $t3, $t4, 4172
sw $t5, 0($t3)
addi $t3, $t4, 4176
sw $t5, 0($t3)
addi $t3, $t4, 4180
sw $t5, 0($t3)
addi $t3, $t4, 4184
sw $t5, 0($t3)
addi $t3, $t4, 4188
sw $t5, 0($t3)
addi $t3, $t4, 4192
sw $t5, 0($t3)
addi $t3, $t4, 4196
sw $t5, 0($t3)
addi $t3, $t4, 4200
sw $t5, 0($t3)
addi $t3, $t4, 4204
sw $t5, 0($t3)
addi $t3, $t4, 4208
sw $t5, 0($t3)
addi $t3, $t4, 4212
sw $t5, 0($t3)
addi $t3, $t4, 4216
sw $t5, 0($t3)
addi $t3, $t4, 4220
sw $t5, 0($t3)
addi $t3, $t4, 4224
sw $t5, 0($t3)
addi $t3, $t4, 4228
sw $t5, 0($t3)
addi $t3, $t4, 4232
sw $t5, 0($t3)
addi $t3, $t4, 4236
sw $t5, 0($t3)
addi $t3, $t4, 4240
sw $t5, 0($t3)
addi $t3, $t4, 4244
sw $t5, 0($t3)
addi $t3, $t4, 4248
sw $t5, 0($t3)
addi $t3, $t4, 4252
sw $t5, 0($t3)
addi $t3, $t4, 4256
sw $t5, 0($t3)
addi $t3, $t4, 4260
sw $t5, 0($t3)
addi $t3, $t4, 4264
sw $t5, 0($t3)
addi $t3, $t4, 4268
sw $t5, 0($t3)
addi $t3, $t4, 4272
sw $t5, 0($t3)
addi $t3, $t4, 4276
sw $t5, 0($t3)
addi $t3, $t4, 4280
sw $t5, 0($t3)
addi $t3, $t4, 4284
sw $t5, 0($t3)
addi $t3, $t4, 4288
sw $t5, 0($t3)
addi $t3, $t4, 4292
sw $t5, 0($t3)
addi $t3, $t4, 4296
sw $t5, 0($t3)
addi $t3, $t4, 4300
sw $t5, 0($t3)
addi $t3, $t4, 4304
sw $t5, 0($t3)
addi $t3, $t4, 4308
sw $t5, 0($t3)
addi $t3, $t4, 4312
sw $t5, 0($t3)
addi $t3, $t4, 4316
sw $t5, 0($t3)
addi $t3, $t4, 4320
sw $t5, 0($t3)
addi $t3, $t4, 4324
sw $t5, 0($t3)
addi $t3, $t4, 4328
sw $t5, 0($t3)
addi $t3, $t4, 4332
sw $t5, 0($t3)
addi $t3, $t4, 4336
sw $t5, 0($t3)
addi $t3, $t4, 4340
sw $t5, 0($t3)
addi $t3, $t4, 4344
sw $t5, 0($t3)
addi $t3, $t4, 4348
sw $t5, 0($t3)
addi $t3, $t4, 4352
sw $t5, 0($t3)
addi $t3, $t4, 4356
sw $t5, 0($t3)
addi $t3, $t4, 4360
sw $t5, 0($t3)
addi $t3, $t4, 4364
sw $t5, 0($t3)
addi $t3, $t4, 4368
sw $t5, 0($t3)
addi $t3, $t4, 4372
sw $t5, 0($t3)
addi $t3, $t4, 4376
sw $t5, 0($t3)
addi $t3, $t4, 4380
sw $t5, 0($t3)
addi $t3, $t4, 4384
sw $t5, 0($t3)
addi $t3, $t4, 4388
sw $t5, 0($t3)
addi $t3, $t4, 4392
sw $t5, 0($t3)
addi $t3, $t4, 4396
sw $t5, 0($t3)
addi $t3, $t4, 4400
sw $t5, 0($t3)
addi $t3, $t4, 4404
sw $t5, 0($t3)
addi $t3, $t4, 4408
sw $t5, 0($t3)
addi $t3, $t4, 4412
sw $t5, 0($t3)
addi $t3, $t4, 4416
sw $t5, 0($t3)
addi $t3, $t4, 4420
sw $t5, 0($t3)
addi $t3, $t4, 4424
sw $t5, 0($t3)
addi $t3, $t4, 4428
sw $t5, 0($t3)
addi $t3, $t4, 4432
sw $t5, 0($t3)
addi $t3, $t4, 4436
sw $t5, 0($t3)
addi $t3, $t4, 4440
sw $t5, 0($t3)
addi $t3, $t4, 4444
sw $t5, 0($t3)
addi $t3, $t4, 4448
sw $t5, 0($t3)
addi $t3, $t4, 4452
sw $t5, 0($t3)
addi $t3, $t4, 4456
sw $t5, 0($t3)
addi $t3, $t4, 4460
sw $t5, 0($t3)
addi $t3, $t4, 4464
sw $t5, 0($t3)
addi $t3, $t4, 4468
sw $t5, 0($t3)
addi $t3, $t4, 4472
sw $t5, 0($t3)
addi $t3, $t4, 4476
sw $t5, 0($t3)
addi $t3, $t4, 4480
sw $t5, 0($t3)
addi $t3, $t4, 4484
sw $t5, 0($t3)
addi $t3, $t4, 4488
sw $t5, 0($t3)
addi $t3, $t4, 4492
sw $t5, 0($t3)
addi $t3, $t4, 4496
sw $t5, 0($t3)
addi $t3, $t4, 4500
sw $t5, 0($t3)
addi $t3, $t4, 4504
sw $t5, 0($t3)
addi $t3, $t4, 4508
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 4512
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 4516
sw $t5, 0($t3)
addi $t3, $t4, 4520
sw $t5, 0($t3)
addi $t3, $t4, 4524
sw $t5, 0($t3)
addi $t3, $t4, 4528
sw $t5, 0($t3)
addi $t3, $t4, 4532
sw $t5, 0($t3)
addi $t3, $t4, 4536
sw $t5, 0($t3)
addi $t3, $t4, 4540
sw $t5, 0($t3)
addi $t3, $t4, 4544
sw $t5, 0($t3)
addi $t3, $t4, 4548
li $t5,0x030303
sw $t5, 0($t3)
addi $t3, $t4, 4552
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 4556
sw $t5, 0($t3)
addi $t3, $t4, 4560
li $t5,0x020202
sw $t5, 0($t3)
addi $t3, $t4, 4564
li $t5,0xfcfcfc
sw $t5, 0($t3)
addi $t3, $t4, 4568
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 4572
sw $t5, 0($t3)
addi $t3, $t4, 4576
li $t5,0xf0f0f0
sw $t5, 0($t3)
addi $t3, $t4, 4580
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 4584
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 4588
sw $t5, 0($t3)
addi $t3, $t4, 4592
sw $t5, 0($t3)
addi $t3, $t4, 4596
li $t5,0x969696
sw $t5, 0($t3)
addi $t3, $t4, 4600
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 4604
sw $t5, 0($t3)
addi $t3, $t4, 4608
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 4612
sw $t5, 0($t3)
addi $t3, $t4, 4616
sw $t5, 0($t3)
addi $t3, $t4, 4620
sw $t5, 0($t3)
addi $t3, $t4, 4624
sw $t5, 0($t3)
addi $t3, $t4, 4628
sw $t5, 0($t3)
addi $t3, $t4, 4632
sw $t5, 0($t3)
addi $t3, $t4, 4636
sw $t5, 0($t3)
addi $t3, $t4, 4640
sw $t5, 0($t3)
addi $t3, $t4, 4644
sw $t5, 0($t3)
addi $t3, $t4, 4648
sw $t5, 0($t3)
addi $t3, $t4, 4652
sw $t5, 0($t3)
addi $t3, $t4, 4656
sw $t5, 0($t3)
addi $t3, $t4, 4660
sw $t5, 0($t3)
addi $t3, $t4, 4664
sw $t5, 0($t3)
addi $t3, $t4, 4668
sw $t5, 0($t3)
addi $t3, $t4, 4672
sw $t5, 0($t3)
addi $t3, $t4, 4676
sw $t5, 0($t3)
addi $t3, $t4, 4680
sw $t5, 0($t3)
addi $t3, $t4, 4684
sw $t5, 0($t3)
addi $t3, $t4, 4688
sw $t5, 0($t3)
addi $t3, $t4, 4692
sw $t5, 0($t3)
addi $t3, $t4, 4696
sw $t5, 0($t3)
addi $t3, $t4, 4700
sw $t5, 0($t3)
addi $t3, $t4, 4704
sw $t5, 0($t3)
addi $t3, $t4, 4708
sw $t5, 0($t3)
addi $t3, $t4, 4712
sw $t5, 0($t3)
addi $t3, $t4, 4716
sw $t5, 0($t3)
addi $t3, $t4, 4720
sw $t5, 0($t3)
addi $t3, $t4, 4724
sw $t5, 0($t3)
addi $t3, $t4, 4728
sw $t5, 0($t3)
addi $t3, $t4, 4732
sw $t5, 0($t3)
addi $t3, $t4, 4736
sw $t5, 0($t3)
addi $t3, $t4, 4740
sw $t5, 0($t3)
addi $t3, $t4, 4744
sw $t5, 0($t3)
addi $t3, $t4, 4748
sw $t5, 0($t3)
addi $t3, $t4, 4752
sw $t5, 0($t3)
addi $t3, $t4, 4756
sw $t5, 0($t3)
addi $t3, $t4, 4760
sw $t5, 0($t3)
addi $t3, $t4, 4764
sw $t5, 0($t3)
addi $t3, $t4, 4768
sw $t5, 0($t3)
addi $t3, $t4, 4772
sw $t5, 0($t3)
addi $t3, $t4, 4776
sw $t5, 0($t3)
addi $t3, $t4, 4780
sw $t5, 0($t3)
addi $t3, $t4, 4784
sw $t5, 0($t3)
addi $t3, $t4, 4788
sw $t5, 0($t3)
addi $t3, $t4, 4792
sw $t5, 0($t3)
addi $t3, $t4, 4796
sw $t5, 0($t3)
addi $t3, $t4, 4800
sw $t5, 0($t3)
addi $t3, $t4, 4804
sw $t5, 0($t3)
addi $t3, $t4, 4808
sw $t5, 0($t3)
addi $t3, $t4, 4812
sw $t5, 0($t3)
addi $t3, $t4, 4816
sw $t5, 0($t3)
addi $t3, $t4, 4820
sw $t5, 0($t3)
addi $t3, $t4, 4824
sw $t5, 0($t3)
addi $t3, $t4, 4828
sw $t5, 0($t3)
addi $t3, $t4, 4832
sw $t5, 0($t3)
addi $t3, $t4, 4836
sw $t5, 0($t3)
addi $t3, $t4, 4840
sw $t5, 0($t3)
addi $t3, $t4, 4844
sw $t5, 0($t3)
addi $t3, $t4, 4848
sw $t5, 0($t3)
addi $t3, $t4, 4852
sw $t5, 0($t3)
addi $t3, $t4, 4856
sw $t5, 0($t3)
addi $t3, $t4, 4860
sw $t5, 0($t3)
addi $t3, $t4, 4864
sw $t5, 0($t3)
addi $t3, $t4, 4868
sw $t5, 0($t3)
addi $t3, $t4, 4872
sw $t5, 0($t3)
addi $t3, $t4, 4876
sw $t5, 0($t3)
addi $t3, $t4, 4880
sw $t5, 0($t3)
addi $t3, $t4, 4884
sw $t5, 0($t3)
addi $t3, $t4, 4888
sw $t5, 0($t3)
addi $t3, $t4, 4892
sw $t5, 0($t3)
addi $t3, $t4, 4896
sw $t5, 0($t3)
addi $t3, $t4, 4900
sw $t5, 0($t3)
addi $t3, $t4, 4904
sw $t5, 0($t3)
addi $t3, $t4, 4908
sw $t5, 0($t3)
addi $t3, $t4, 4912
sw $t5, 0($t3)
addi $t3, $t4, 4916
sw $t5, 0($t3)
addi $t3, $t4, 4920
sw $t5, 0($t3)
addi $t3, $t4, 4924
sw $t5, 0($t3)
addi $t3, $t4, 4928
sw $t5, 0($t3)
addi $t3, $t4, 4932
sw $t5, 0($t3)
addi $t3, $t4, 4936
sw $t5, 0($t3)
addi $t3, $t4, 4940
sw $t5, 0($t3)
addi $t3, $t4, 4944
sw $t5, 0($t3)
addi $t3, $t4, 4948
sw $t5, 0($t3)
addi $t3, $t4, 4952
sw $t5, 0($t3)
addi $t3, $t4, 4956
sw $t5, 0($t3)
addi $t3, $t4, 4960
sw $t5, 0($t3)
addi $t3, $t4, 4964
sw $t5, 0($t3)
addi $t3, $t4, 4968
sw $t5, 0($t3)
addi $t3, $t4, 4972
sw $t5, 0($t3)
addi $t3, $t4, 4976
sw $t5, 0($t3)
addi $t3, $t4, 4980
sw $t5, 0($t3)
addi $t3, $t4, 4984
sw $t5, 0($t3)
addi $t3, $t4, 4988
sw $t5, 0($t3)
addi $t3, $t4, 4992
sw $t5, 0($t3)
addi $t3, $t4, 4996
sw $t5, 0($t3)
addi $t3, $t4, 5000
sw $t5, 0($t3)
addi $t3, $t4, 5004
sw $t5, 0($t3)
addi $t3, $t4, 5008
sw $t5, 0($t3)
addi $t3, $t4, 5012
sw $t5, 0($t3)
addi $t3, $t4, 5016
li $t5,0x505050
sw $t5, 0($t3)
addi $t3, $t4, 5020
li $t5,0x676767
sw $t5, 0($t3)
addi $t3, $t4, 5024
li $t5,0xfdfdfd
sw $t5, 0($t3)
addi $t3, $t4, 5028
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 5032
sw $t5, 0($t3)
addi $t3, $t4, 5036
sw $t5, 0($t3)
addi $t3, $t4, 5040
sw $t5, 0($t3)
addi $t3, $t4, 5044
sw $t5, 0($t3)
addi $t3, $t4, 5048
sw $t5, 0($t3)
addi $t3, $t4, 5052
sw $t5, 0($t3)
addi $t3, $t4, 5056
li $t5,0xdedede
sw $t5, 0($t3)
addi $t3, $t4, 5060
li $t5,0x020202
sw $t5, 0($t3)
addi $t3, $t4, 5064
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 5068
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 5072
sw $t5, 0($t3)
addi $t3, $t4, 5076
li $t5,0xfbfbfb
sw $t5, 0($t3)
addi $t3, $t4, 5080
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 5084
sw $t5, 0($t3)
addi $t3, $t4, 5088
li $t5,0xc6c6c6
sw $t5, 0($t3)
addi $t3, $t4, 5092
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 5096
sw $t5, 0($t3)
addi $t3, $t4, 5100
sw $t5, 0($t3)
addi $t3, $t4, 5104
li $t5,0x020202
sw $t5, 0($t3)
addi $t3, $t4, 5108
li $t5,0xeeeeee
sw $t5, 0($t3)
addi $t3, $t4, 5112
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 5116
sw $t5, 0($t3)
addi $t3, $t4, 5120
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 5124
sw $t5, 0($t3)
addi $t3, $t4, 5128
sw $t5, 0($t3)
addi $t3, $t4, 5132
sw $t5, 0($t3)
addi $t3, $t4, 5136
sw $t5, 0($t3)
addi $t3, $t4, 5140
sw $t5, 0($t3)
addi $t3, $t4, 5144
sw $t5, 0($t3)
addi $t3, $t4, 5148
sw $t5, 0($t3)
addi $t3, $t4, 5152
sw $t5, 0($t3)
addi $t3, $t4, 5156
sw $t5, 0($t3)
addi $t3, $t4, 5160
sw $t5, 0($t3)
addi $t3, $t4, 5164
sw $t5, 0($t3)
addi $t3, $t4, 5168
sw $t5, 0($t3)
addi $t3, $t4, 5172
sw $t5, 0($t3)
addi $t3, $t4, 5176
sw $t5, 0($t3)
addi $t3, $t4, 5180
sw $t5, 0($t3)
addi $t3, $t4, 5184
sw $t5, 0($t3)
addi $t3, $t4, 5188
sw $t5, 0($t3)
addi $t3, $t4, 5192
sw $t5, 0($t3)
addi $t3, $t4, 5196
sw $t5, 0($t3)
addi $t3, $t4, 5200
sw $t5, 0($t3)
addi $t3, $t4, 5204
sw $t5, 0($t3)
addi $t3, $t4, 5208
sw $t5, 0($t3)
addi $t3, $t4, 5212
sw $t5, 0($t3)
addi $t3, $t4, 5216
sw $t5, 0($t3)
addi $t3, $t4, 5220
sw $t5, 0($t3)
addi $t3, $t4, 5224
sw $t5, 0($t3)
addi $t3, $t4, 5228
sw $t5, 0($t3)
addi $t3, $t4, 5232
sw $t5, 0($t3)
addi $t3, $t4, 5236
sw $t5, 0($t3)
addi $t3, $t4, 5240
sw $t5, 0($t3)
addi $t3, $t4, 5244
sw $t5, 0($t3)
addi $t3, $t4, 5248
sw $t5, 0($t3)
addi $t3, $t4, 5252
sw $t5, 0($t3)
addi $t3, $t4, 5256
sw $t5, 0($t3)
addi $t3, $t4, 5260
sw $t5, 0($t3)
addi $t3, $t4, 5264
sw $t5, 0($t3)
addi $t3, $t4, 5268
sw $t5, 0($t3)
addi $t3, $t4, 5272
sw $t5, 0($t3)
addi $t3, $t4, 5276
sw $t5, 0($t3)
addi $t3, $t4, 5280
sw $t5, 0($t3)
addi $t3, $t4, 5284
sw $t5, 0($t3)
addi $t3, $t4, 5288
sw $t5, 0($t3)
addi $t3, $t4, 5292
sw $t5, 0($t3)
addi $t3, $t4, 5296
sw $t5, 0($t3)
addi $t3, $t4, 5300
sw $t5, 0($t3)
addi $t3, $t4, 5304
sw $t5, 0($t3)
addi $t3, $t4, 5308
sw $t5, 0($t3)
addi $t3, $t4, 5312
sw $t5, 0($t3)
addi $t3, $t4, 5316
sw $t5, 0($t3)
addi $t3, $t4, 5320
sw $t5, 0($t3)
addi $t3, $t4, 5324
sw $t5, 0($t3)
addi $t3, $t4, 5328
sw $t5, 0($t3)
addi $t3, $t4, 5332
sw $t5, 0($t3)
addi $t3, $t4, 5336
sw $t5, 0($t3)
addi $t3, $t4, 5340
sw $t5, 0($t3)
addi $t3, $t4, 5344
sw $t5, 0($t3)
addi $t3, $t4, 5348
sw $t5, 0($t3)
addi $t3, $t4, 5352
sw $t5, 0($t3)
addi $t3, $t4, 5356
sw $t5, 0($t3)
addi $t3, $t4, 5360
sw $t5, 0($t3)
addi $t3, $t4, 5364
sw $t5, 0($t3)
addi $t3, $t4, 5368
sw $t5, 0($t3)
addi $t3, $t4, 5372
sw $t5, 0($t3)
addi $t3, $t4, 5376
sw $t5, 0($t3)
addi $t3, $t4, 5380
sw $t5, 0($t3)
addi $t3, $t4, 5384
sw $t5, 0($t3)
addi $t3, $t4, 5388
sw $t5, 0($t3)
addi $t3, $t4, 5392
sw $t5, 0($t3)
addi $t3, $t4, 5396
sw $t5, 0($t3)
addi $t3, $t4, 5400
sw $t5, 0($t3)
addi $t3, $t4, 5404
sw $t5, 0($t3)
addi $t3, $t4, 5408
sw $t5, 0($t3)
addi $t3, $t4, 5412
sw $t5, 0($t3)
addi $t3, $t4, 5416
sw $t5, 0($t3)
addi $t3, $t4, 5420
sw $t5, 0($t3)
addi $t3, $t4, 5424
sw $t5, 0($t3)
addi $t3, $t4, 5428
sw $t5, 0($t3)
addi $t3, $t4, 5432
sw $t5, 0($t3)
addi $t3, $t4, 5436
sw $t5, 0($t3)
addi $t3, $t4, 5440
sw $t5, 0($t3)
addi $t3, $t4, 5444
sw $t5, 0($t3)
addi $t3, $t4, 5448
sw $t5, 0($t3)
addi $t3, $t4, 5452
sw $t5, 0($t3)
addi $t3, $t4, 5456
sw $t5, 0($t3)
addi $t3, $t4, 5460
sw $t5, 0($t3)
addi $t3, $t4, 5464
sw $t5, 0($t3)
addi $t3, $t4, 5468
sw $t5, 0($t3)
addi $t3, $t4, 5472
sw $t5, 0($t3)
addi $t3, $t4, 5476
sw $t5, 0($t3)
addi $t3, $t4, 5480
sw $t5, 0($t3)
addi $t3, $t4, 5484
sw $t5, 0($t3)
addi $t3, $t4, 5488
sw $t5, 0($t3)
addi $t3, $t4, 5492
sw $t5, 0($t3)
addi $t3, $t4, 5496
sw $t5, 0($t3)
addi $t3, $t4, 5500
sw $t5, 0($t3)
addi $t3, $t4, 5504
sw $t5, 0($t3)
addi $t3, $t4, 5508
sw $t5, 0($t3)
addi $t3, $t4, 5512
sw $t5, 0($t3)
addi $t3, $t4, 5516
sw $t5, 0($t3)
addi $t3, $t4, 5520
sw $t5, 0($t3)
addi $t3, $t4, 5524
li $t5,0xfdfdfd
sw $t5, 0($t3)
addi $t3, $t4, 5528
li $t5,0x181818
sw $t5, 0($t3)
addi $t3, $t4, 5532
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 5536
li $t5,0x222222
sw $t5, 0($t3)
addi $t3, $t4, 5540
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 5544
sw $t5, 0($t3)
addi $t3, $t4, 5548
sw $t5, 0($t3)
addi $t3, $t4, 5552
sw $t5, 0($t3)
addi $t3, $t4, 5556
sw $t5, 0($t3)
addi $t3, $t4, 5560
sw $t5, 0($t3)
addi $t3, $t4, 5564
sw $t5, 0($t3)
addi $t3, $t4, 5568
li $t5,0x4a4a4a
sw $t5, 0($t3)
addi $t3, $t4, 5572
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 5576
sw $t5, 0($t3)
addi $t3, $t4, 5580
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 5584
li $t5,0x050505
sw $t5, 0($t3)
addi $t3, $t4, 5588
li $t5,0xd6d6d6
sw $t5, 0($t3)
addi $t3, $t4, 5592
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 5596
sw $t5, 0($t3)
addi $t3, $t4, 5600
li $t5,0x545454
sw $t5, 0($t3)
addi $t3, $t4, 5604
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 5608
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 5612
sw $t5, 0($t3)
addi $t3, $t4, 5616
li $t5,0x090909
sw $t5, 0($t3)
addi $t3, $t4, 5620
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 5624
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 5628
sw $t5, 0($t3)
addi $t3, $t4, 5632
sw $t5, 0($t3)
addi $t3, $t4, 5636
sw $t5, 0($t3)
addi $t3, $t4, 5640
sw $t5, 0($t3)
addi $t3, $t4, 5644
sw $t5, 0($t3)
addi $t3, $t4, 5648
sw $t5, 0($t3)
addi $t3, $t4, 5652
sw $t5, 0($t3)
addi $t3, $t4, 5656
sw $t5, 0($t3)
addi $t3, $t4, 5660
sw $t5, 0($t3)
addi $t3, $t4, 5664
sw $t5, 0($t3)
addi $t3, $t4, 5668
sw $t5, 0($t3)
addi $t3, $t4, 5672
sw $t5, 0($t3)
addi $t3, $t4, 5676
sw $t5, 0($t3)
addi $t3, $t4, 5680
sw $t5, 0($t3)
addi $t3, $t4, 5684
sw $t5, 0($t3)
addi $t3, $t4, 5688
sw $t5, 0($t3)
addi $t3, $t4, 5692
sw $t5, 0($t3)
addi $t3, $t4, 5696
sw $t5, 0($t3)
addi $t3, $t4, 5700
sw $t5, 0($t3)
addi $t3, $t4, 5704
sw $t5, 0($t3)
addi $t3, $t4, 5708
sw $t5, 0($t3)
addi $t3, $t4, 5712
sw $t5, 0($t3)
addi $t3, $t4, 5716
sw $t5, 0($t3)
addi $t3, $t4, 5720
sw $t5, 0($t3)
addi $t3, $t4, 5724
sw $t5, 0($t3)
addi $t3, $t4, 5728
sw $t5, 0($t3)
addi $t3, $t4, 5732
sw $t5, 0($t3)
addi $t3, $t4, 5736
sw $t5, 0($t3)
addi $t3, $t4, 5740
sw $t5, 0($t3)
addi $t3, $t4, 5744
sw $t5, 0($t3)
addi $t3, $t4, 5748
sw $t5, 0($t3)
addi $t3, $t4, 5752
sw $t5, 0($t3)
addi $t3, $t4, 5756
sw $t5, 0($t3)
addi $t3, $t4, 5760
sw $t5, 0($t3)
addi $t3, $t4, 5764
sw $t5, 0($t3)
addi $t3, $t4, 5768
sw $t5, 0($t3)
addi $t3, $t4, 5772
sw $t5, 0($t3)
addi $t3, $t4, 5776
sw $t5, 0($t3)
addi $t3, $t4, 5780
sw $t5, 0($t3)
addi $t3, $t4, 5784
sw $t5, 0($t3)
addi $t3, $t4, 5788
sw $t5, 0($t3)
addi $t3, $t4, 5792
sw $t5, 0($t3)
addi $t3, $t4, 5796
sw $t5, 0($t3)
addi $t3, $t4, 5800
sw $t5, 0($t3)
addi $t3, $t4, 5804
sw $t5, 0($t3)
addi $t3, $t4, 5808
sw $t5, 0($t3)
addi $t3, $t4, 5812
sw $t5, 0($t3)
addi $t3, $t4, 5816
sw $t5, 0($t3)
addi $t3, $t4, 5820
sw $t5, 0($t3)
addi $t3, $t4, 5824
sw $t5, 0($t3)
addi $t3, $t4, 5828
sw $t5, 0($t3)
addi $t3, $t4, 5832
sw $t5, 0($t3)
addi $t3, $t4, 5836
sw $t5, 0($t3)
addi $t3, $t4, 5840
sw $t5, 0($t3)
addi $t3, $t4, 5844
sw $t5, 0($t3)
addi $t3, $t4, 5848
sw $t5, 0($t3)
addi $t3, $t4, 5852
sw $t5, 0($t3)
addi $t3, $t4, 5856
sw $t5, 0($t3)
addi $t3, $t4, 5860
sw $t5, 0($t3)
addi $t3, $t4, 5864
sw $t5, 0($t3)
addi $t3, $t4, 5868
sw $t5, 0($t3)
addi $t3, $t4, 5872
sw $t5, 0($t3)
addi $t3, $t4, 5876
sw $t5, 0($t3)
addi $t3, $t4, 5880
sw $t5, 0($t3)
addi $t3, $t4, 5884
sw $t5, 0($t3)
addi $t3, $t4, 5888
sw $t5, 0($t3)
addi $t3, $t4, 5892
sw $t5, 0($t3)
addi $t3, $t4, 5896
sw $t5, 0($t3)
addi $t3, $t4, 5900
sw $t5, 0($t3)
addi $t3, $t4, 5904
sw $t5, 0($t3)
addi $t3, $t4, 5908
sw $t5, 0($t3)
addi $t3, $t4, 5912
sw $t5, 0($t3)
addi $t3, $t4, 5916
sw $t5, 0($t3)
addi $t3, $t4, 5920
sw $t5, 0($t3)
addi $t3, $t4, 5924
sw $t5, 0($t3)
addi $t3, $t4, 5928
sw $t5, 0($t3)
addi $t3, $t4, 5932
sw $t5, 0($t3)
addi $t3, $t4, 5936
sw $t5, 0($t3)
addi $t3, $t4, 5940
sw $t5, 0($t3)
addi $t3, $t4, 5944
sw $t5, 0($t3)
addi $t3, $t4, 5948
sw $t5, 0($t3)
addi $t3, $t4, 5952
sw $t5, 0($t3)
addi $t3, $t4, 5956
sw $t5, 0($t3)
addi $t3, $t4, 5960
sw $t5, 0($t3)
addi $t3, $t4, 5964
sw $t5, 0($t3)
addi $t3, $t4, 5968
sw $t5, 0($t3)
addi $t3, $t4, 5972
sw $t5, 0($t3)
addi $t3, $t4, 5976
sw $t5, 0($t3)
addi $t3, $t4, 5980
sw $t5, 0($t3)
addi $t3, $t4, 5984
sw $t5, 0($t3)
addi $t3, $t4, 5988
sw $t5, 0($t3)
addi $t3, $t4, 5992
sw $t5, 0($t3)
addi $t3, $t4, 5996
sw $t5, 0($t3)
addi $t3, $t4, 6000
sw $t5, 0($t3)
addi $t3, $t4, 6004
sw $t5, 0($t3)
addi $t3, $t4, 6008
sw $t5, 0($t3)
addi $t3, $t4, 6012
sw $t5, 0($t3)
addi $t3, $t4, 6016
sw $t5, 0($t3)
addi $t3, $t4, 6020
sw $t5, 0($t3)
addi $t3, $t4, 6024
sw $t5, 0($t3)
addi $t3, $t4, 6028
sw $t5, 0($t3)
addi $t3, $t4, 6032
sw $t5, 0($t3)
addi $t3, $t4, 6036
sw $t5, 0($t3)
addi $t3, $t4, 6040
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 6044
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 6048
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 6052
li $t5,0x6e6e6e
sw $t5, 0($t3)
addi $t3, $t4, 6056
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 6060
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 6064
sw $t5, 0($t3)
addi $t3, $t4, 6068
sw $t5, 0($t3)
addi $t3, $t4, 6072
sw $t5, 0($t3)
addi $t3, $t4, 6076
sw $t5, 0($t3)
addi $t3, $t4, 6080
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 6084
sw $t5, 0($t3)
addi $t3, $t4, 6088
sw $t5, 0($t3)
addi $t3, $t4, 6092
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 6096
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 6100
li $t5,0xe5e5e5
sw $t5, 0($t3)
addi $t3, $t4, 6104
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 6108
sw $t5, 0($t3)
addi $t3, $t4, 6112
li $t5,0x1a1a1a
sw $t5, 0($t3)
addi $t3, $t4, 6116
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 6120
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 6124
sw $t5, 0($t3)
addi $t3, $t4, 6128
li $t5,0x4c4c4c
sw $t5, 0($t3)
addi $t3, $t4, 6132
li $t5,0xfcfcfc
sw $t5, 0($t3)
addi $t3, $t4, 6136
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 6140
sw $t5, 0($t3)
addi $t3, $t4, 6144
sw $t5, 0($t3)
addi $t3, $t4, 6148
sw $t5, 0($t3)
addi $t3, $t4, 6152
sw $t5, 0($t3)
addi $t3, $t4, 6156
sw $t5, 0($t3)
addi $t3, $t4, 6160
sw $t5, 0($t3)
addi $t3, $t4, 6164
sw $t5, 0($t3)
addi $t3, $t4, 6168
sw $t5, 0($t3)
addi $t3, $t4, 6172
sw $t5, 0($t3)
addi $t3, $t4, 6176
sw $t5, 0($t3)
addi $t3, $t4, 6180
sw $t5, 0($t3)
addi $t3, $t4, 6184
sw $t5, 0($t3)
addi $t3, $t4, 6188
sw $t5, 0($t3)
addi $t3, $t4, 6192
sw $t5, 0($t3)
addi $t3, $t4, 6196
sw $t5, 0($t3)
addi $t3, $t4, 6200
sw $t5, 0($t3)
addi $t3, $t4, 6204
sw $t5, 0($t3)
addi $t3, $t4, 6208
sw $t5, 0($t3)
addi $t3, $t4, 6212
sw $t5, 0($t3)
addi $t3, $t4, 6216
sw $t5, 0($t3)
addi $t3, $t4, 6220
sw $t5, 0($t3)
addi $t3, $t4, 6224
sw $t5, 0($t3)
addi $t3, $t4, 6228
sw $t5, 0($t3)
addi $t3, $t4, 6232
sw $t5, 0($t3)
addi $t3, $t4, 6236
sw $t5, 0($t3)
addi $t3, $t4, 6240
sw $t5, 0($t3)
addi $t3, $t4, 6244
sw $t5, 0($t3)
addi $t3, $t4, 6248
sw $t5, 0($t3)
addi $t3, $t4, 6252
sw $t5, 0($t3)
addi $t3, $t4, 6256
sw $t5, 0($t3)
addi $t3, $t4, 6260
sw $t5, 0($t3)
addi $t3, $t4, 6264
sw $t5, 0($t3)
addi $t3, $t4, 6268
sw $t5, 0($t3)
addi $t3, $t4, 6272
sw $t5, 0($t3)
addi $t3, $t4, 6276
sw $t5, 0($t3)
addi $t3, $t4, 6280
sw $t5, 0($t3)
addi $t3, $t4, 6284
sw $t5, 0($t3)
addi $t3, $t4, 6288
sw $t5, 0($t3)
addi $t3, $t4, 6292
sw $t5, 0($t3)
addi $t3, $t4, 6296
sw $t5, 0($t3)
addi $t3, $t4, 6300
sw $t5, 0($t3)
addi $t3, $t4, 6304
sw $t5, 0($t3)
addi $t3, $t4, 6308
sw $t5, 0($t3)
addi $t3, $t4, 6312
sw $t5, 0($t3)
addi $t3, $t4, 6316
sw $t5, 0($t3)
addi $t3, $t4, 6320
sw $t5, 0($t3)
addi $t3, $t4, 6324
sw $t5, 0($t3)
addi $t3, $t4, 6328
sw $t5, 0($t3)
addi $t3, $t4, 6332
sw $t5, 0($t3)
addi $t3, $t4, 6336
sw $t5, 0($t3)
addi $t3, $t4, 6340
sw $t5, 0($t3)
addi $t3, $t4, 6344
sw $t5, 0($t3)
addi $t3, $t4, 6348
sw $t5, 0($t3)
addi $t3, $t4, 6352
sw $t5, 0($t3)
addi $t3, $t4, 6356
sw $t5, 0($t3)
addi $t3, $t4, 6360
sw $t5, 0($t3)
addi $t3, $t4, 6364
sw $t5, 0($t3)
addi $t3, $t4, 6368
sw $t5, 0($t3)
addi $t3, $t4, 6372
sw $t5, 0($t3)
addi $t3, $t4, 6376
sw $t5, 0($t3)
addi $t3, $t4, 6380
sw $t5, 0($t3)
addi $t3, $t4, 6384
sw $t5, 0($t3)
addi $t3, $t4, 6388
sw $t5, 0($t3)
addi $t3, $t4, 6392
sw $t5, 0($t3)
addi $t3, $t4, 6396
sw $t5, 0($t3)
addi $t3, $t4, 6400
sw $t5, 0($t3)
addi $t3, $t4, 6404
sw $t5, 0($t3)
addi $t3, $t4, 6408
sw $t5, 0($t3)
addi $t3, $t4, 6412
sw $t5, 0($t3)
addi $t3, $t4, 6416
sw $t5, 0($t3)
addi $t3, $t4, 6420
sw $t5, 0($t3)
addi $t3, $t4, 6424
sw $t5, 0($t3)
addi $t3, $t4, 6428
sw $t5, 0($t3)
addi $t3, $t4, 6432
sw $t5, 0($t3)
addi $t3, $t4, 6436
sw $t5, 0($t3)
addi $t3, $t4, 6440
sw $t5, 0($t3)
addi $t3, $t4, 6444
sw $t5, 0($t3)
addi $t3, $t4, 6448
sw $t5, 0($t3)
addi $t3, $t4, 6452
sw $t5, 0($t3)
addi $t3, $t4, 6456
sw $t5, 0($t3)
addi $t3, $t4, 6460
sw $t5, 0($t3)
addi $t3, $t4, 6464
sw $t5, 0($t3)
addi $t3, $t4, 6468
sw $t5, 0($t3)
addi $t3, $t4, 6472
sw $t5, 0($t3)
addi $t3, $t4, 6476
sw $t5, 0($t3)
addi $t3, $t4, 6480
sw $t5, 0($t3)
addi $t3, $t4, 6484
sw $t5, 0($t3)
addi $t3, $t4, 6488
sw $t5, 0($t3)
addi $t3, $t4, 6492
sw $t5, 0($t3)
addi $t3, $t4, 6496
sw $t5, 0($t3)
addi $t3, $t4, 6500
sw $t5, 0($t3)
addi $t3, $t4, 6504
sw $t5, 0($t3)
addi $t3, $t4, 6508
sw $t5, 0($t3)
addi $t3, $t4, 6512
sw $t5, 0($t3)
addi $t3, $t4, 6516
sw $t5, 0($t3)
addi $t3, $t4, 6520
sw $t5, 0($t3)
addi $t3, $t4, 6524
sw $t5, 0($t3)
addi $t3, $t4, 6528
sw $t5, 0($t3)
addi $t3, $t4, 6532
sw $t5, 0($t3)
addi $t3, $t4, 6536
sw $t5, 0($t3)
addi $t3, $t4, 6540
sw $t5, 0($t3)
addi $t3, $t4, 6544
sw $t5, 0($t3)
addi $t3, $t4, 6548
li $t5,0xf4f4f4
sw $t5, 0($t3)
addi $t3, $t4, 6552
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 6556
sw $t5, 0($t3)
addi $t3, $t4, 6560
sw $t5, 0($t3)
addi $t3, $t4, 6564
li $t5,0x040404
sw $t5, 0($t3)
addi $t3, $t4, 6568
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 6572
sw $t5, 0($t3)
addi $t3, $t4, 6576
sw $t5, 0($t3)
addi $t3, $t4, 6580
sw $t5, 0($t3)
addi $t3, $t4, 6584
sw $t5, 0($t3)
addi $t3, $t4, 6588
li $t5,0xe3e3e3
sw $t5, 0($t3)
addi $t3, $t4, 6592
li $t5,0x030303
sw $t5, 0($t3)
addi $t3, $t4, 6596
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 6600
sw $t5, 0($t3)
addi $t3, $t4, 6604
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 6608
sw $t5, 0($t3)
addi $t3, $t4, 6612
li $t5,0xf9f8f8
sw $t5, 0($t3)
addi $t3, $t4, 6616
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 6620
sw $t5, 0($t3)
addi $t3, $t4, 6624
li $t5,0x080808
sw $t5, 0($t3)
addi $t3, $t4, 6628
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 6632
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 6636
sw $t5, 0($t3)
addi $t3, $t4, 6640
li $t5,0x7c7c7c
sw $t5, 0($t3)
addi $t3, $t4, 6644
li $t5,0xfffffe
sw $t5, 0($t3)
addi $t3, $t4, 6648
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 6652
sw $t5, 0($t3)
addi $t3, $t4, 6656
sw $t5, 0($t3)
addi $t3, $t4, 6660
sw $t5, 0($t3)
addi $t3, $t4, 6664
sw $t5, 0($t3)
addi $t3, $t4, 6668
sw $t5, 0($t3)
addi $t3, $t4, 6672
sw $t5, 0($t3)
addi $t3, $t4, 6676
sw $t5, 0($t3)
addi $t3, $t4, 6680
sw $t5, 0($t3)
addi $t3, $t4, 6684
sw $t5, 0($t3)
addi $t3, $t4, 6688
sw $t5, 0($t3)
addi $t3, $t4, 6692
sw $t5, 0($t3)
addi $t3, $t4, 6696
sw $t5, 0($t3)
addi $t3, $t4, 6700
sw $t5, 0($t3)
addi $t3, $t4, 6704
sw $t5, 0($t3)
addi $t3, $t4, 6708
sw $t5, 0($t3)
addi $t3, $t4, 6712
sw $t5, 0($t3)
addi $t3, $t4, 6716
sw $t5, 0($t3)
addi $t3, $t4, 6720
sw $t5, 0($t3)
addi $t3, $t4, 6724
sw $t5, 0($t3)
addi $t3, $t4, 6728
sw $t5, 0($t3)
addi $t3, $t4, 6732
sw $t5, 0($t3)
addi $t3, $t4, 6736
sw $t5, 0($t3)
addi $t3, $t4, 6740
sw $t5, 0($t3)
addi $t3, $t4, 6744
sw $t5, 0($t3)
addi $t3, $t4, 6748
sw $t5, 0($t3)
addi $t3, $t4, 6752
sw $t5, 0($t3)
addi $t3, $t4, 6756
sw $t5, 0($t3)
addi $t3, $t4, 6760
sw $t5, 0($t3)
addi $t3, $t4, 6764
sw $t5, 0($t3)
addi $t3, $t4, 6768
sw $t5, 0($t3)
addi $t3, $t4, 6772
sw $t5, 0($t3)
addi $t3, $t4, 6776
sw $t5, 0($t3)
addi $t3, $t4, 6780
sw $t5, 0($t3)
addi $t3, $t4, 6784
sw $t5, 0($t3)
addi $t3, $t4, 6788
sw $t5, 0($t3)
addi $t3, $t4, 6792
sw $t5, 0($t3)
addi $t3, $t4, 6796
sw $t5, 0($t3)
addi $t3, $t4, 6800
sw $t5, 0($t3)
addi $t3, $t4, 6804
sw $t5, 0($t3)
addi $t3, $t4, 6808
sw $t5, 0($t3)
addi $t3, $t4, 6812
sw $t5, 0($t3)
addi $t3, $t4, 6816
sw $t5, 0($t3)
addi $t3, $t4, 6820
sw $t5, 0($t3)
addi $t3, $t4, 6824
sw $t5, 0($t3)
addi $t3, $t4, 6828
sw $t5, 0($t3)
addi $t3, $t4, 6832
sw $t5, 0($t3)
addi $t3, $t4, 6836
sw $t5, 0($t3)
addi $t3, $t4, 6840
sw $t5, 0($t3)
addi $t3, $t4, 6844
sw $t5, 0($t3)
addi $t3, $t4, 6848
sw $t5, 0($t3)
addi $t3, $t4, 6852
sw $t5, 0($t3)
addi $t3, $t4, 6856
sw $t5, 0($t3)
addi $t3, $t4, 6860
sw $t5, 0($t3)
addi $t3, $t4, 6864
sw $t5, 0($t3)
addi $t3, $t4, 6868
sw $t5, 0($t3)
addi $t3, $t4, 6872
sw $t5, 0($t3)
addi $t3, $t4, 6876
sw $t5, 0($t3)
addi $t3, $t4, 6880
sw $t5, 0($t3)
addi $t3, $t4, 6884
sw $t5, 0($t3)
addi $t3, $t4, 6888
sw $t5, 0($t3)
addi $t3, $t4, 6892
sw $t5, 0($t3)
addi $t3, $t4, 6896
sw $t5, 0($t3)
addi $t3, $t4, 6900
sw $t5, 0($t3)
addi $t3, $t4, 6904
sw $t5, 0($t3)
addi $t3, $t4, 6908
sw $t5, 0($t3)
addi $t3, $t4, 6912
sw $t5, 0($t3)
addi $t3, $t4, 6916
sw $t5, 0($t3)
addi $t3, $t4, 6920
sw $t5, 0($t3)
addi $t3, $t4, 6924
sw $t5, 0($t3)
addi $t3, $t4, 6928
sw $t5, 0($t3)
addi $t3, $t4, 6932
sw $t5, 0($t3)
addi $t3, $t4, 6936
sw $t5, 0($t3)
addi $t3, $t4, 6940
sw $t5, 0($t3)
addi $t3, $t4, 6944
sw $t5, 0($t3)
addi $t3, $t4, 6948
sw $t5, 0($t3)
addi $t3, $t4, 6952
sw $t5, 0($t3)
addi $t3, $t4, 6956
sw $t5, 0($t3)
addi $t3, $t4, 6960
sw $t5, 0($t3)
addi $t3, $t4, 6964
sw $t5, 0($t3)
addi $t3, $t4, 6968
sw $t5, 0($t3)
addi $t3, $t4, 6972
sw $t5, 0($t3)
addi $t3, $t4, 6976
sw $t5, 0($t3)
addi $t3, $t4, 6980
sw $t5, 0($t3)
addi $t3, $t4, 6984
sw $t5, 0($t3)
addi $t3, $t4, 6988
sw $t5, 0($t3)
addi $t3, $t4, 6992
li $t5,0xfdfdfd
sw $t5, 0($t3)
addi $t3, $t4, 6996
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 7000
li $t5,0xfffffe
sw $t5, 0($t3)
addi $t3, $t4, 7004
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 7008
sw $t5, 0($t3)
addi $t3, $t4, 7012
sw $t5, 0($t3)
addi $t3, $t4, 7016
sw $t5, 0($t3)
addi $t3, $t4, 7020
sw $t5, 0($t3)
addi $t3, $t4, 7024
li $t5,0xfdfdfd
sw $t5, 0($t3)
addi $t3, $t4, 7028
li $t5,0xe6e6e6
sw $t5, 0($t3)
addi $t3, $t4, 7032
li $t5,0x020202
sw $t5, 0($t3)
addi $t3, $t4, 7036
li $t5,0xa2a2a2
sw $t5, 0($t3)
addi $t3, $t4, 7040
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 7044
sw $t5, 0($t3)
addi $t3, $t4, 7048
sw $t5, 0($t3)
addi $t3, $t4, 7052
sw $t5, 0($t3)
addi $t3, $t4, 7056
sw $t5, 0($t3)
addi $t3, $t4, 7060
li $t5,0x818181
sw $t5, 0($t3)
addi $t3, $t4, 7064
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 7068
sw $t5, 0($t3)
addi $t3, $t4, 7072
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 7076
sw $t5, 0($t3)
addi $t3, $t4, 7080
li $t5,0x9b9b9b
sw $t5, 0($t3)
addi $t3, $t4, 7084
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 7088
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 7092
sw $t5, 0($t3)
addi $t3, $t4, 7096
sw $t5, 0($t3)
addi $t3, $t4, 7100
li $t5,0x686868
sw $t5, 0($t3)
addi $t3, $t4, 7104
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 7108
sw $t5, 0($t3)
addi $t3, $t4, 7112
sw $t5, 0($t3)
addi $t3, $t4, 7116
sw $t5, 0($t3)
addi $t3, $t4, 7120
li $t5,0x020202
sw $t5, 0($t3)
addi $t3, $t4, 7124
li $t5,0xfbfbfb
sw $t5, 0($t3)
addi $t3, $t4, 7128
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 7132
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 7136
li $t5,0x030303
sw $t5, 0($t3)
addi $t3, $t4, 7140
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 7144
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 7148
sw $t5, 0($t3)
addi $t3, $t4, 7152
li $t5,0xf4f4f4
sw $t5, 0($t3)
addi $t3, $t4, 7156
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 7160
sw $t5, 0($t3)
addi $t3, $t4, 7164
sw $t5, 0($t3)
addi $t3, $t4, 7168
sw $t5, 0($t3)
addi $t3, $t4, 7172
sw $t5, 0($t3)
addi $t3, $t4, 7176
sw $t5, 0($t3)
addi $t3, $t4, 7180
sw $t5, 0($t3)
addi $t3, $t4, 7184
sw $t5, 0($t3)
addi $t3, $t4, 7188
sw $t5, 0($t3)
addi $t3, $t4, 7192
sw $t5, 0($t3)
addi $t3, $t4, 7196
sw $t5, 0($t3)
addi $t3, $t4, 7200
sw $t5, 0($t3)
addi $t3, $t4, 7204
sw $t5, 0($t3)
addi $t3, $t4, 7208
sw $t5, 0($t3)
addi $t3, $t4, 7212
sw $t5, 0($t3)
addi $t3, $t4, 7216
sw $t5, 0($t3)
addi $t3, $t4, 7220
sw $t5, 0($t3)
addi $t3, $t4, 7224
sw $t5, 0($t3)
addi $t3, $t4, 7228
sw $t5, 0($t3)
addi $t3, $t4, 7232
sw $t5, 0($t3)
addi $t3, $t4, 7236
sw $t5, 0($t3)
addi $t3, $t4, 7240
sw $t5, 0($t3)
addi $t3, $t4, 7244
sw $t5, 0($t3)
addi $t3, $t4, 7248
sw $t5, 0($t3)
addi $t3, $t4, 7252
sw $t5, 0($t3)
addi $t3, $t4, 7256
sw $t5, 0($t3)
addi $t3, $t4, 7260
sw $t5, 0($t3)
addi $t3, $t4, 7264
sw $t5, 0($t3)
addi $t3, $t4, 7268
sw $t5, 0($t3)
addi $t3, $t4, 7272
sw $t5, 0($t3)
addi $t3, $t4, 7276
sw $t5, 0($t3)
addi $t3, $t4, 7280
sw $t5, 0($t3)
addi $t3, $t4, 7284
sw $t5, 0($t3)
addi $t3, $t4, 7288
sw $t5, 0($t3)
addi $t3, $t4, 7292
sw $t5, 0($t3)
addi $t3, $t4, 7296
sw $t5, 0($t3)
addi $t3, $t4, 7300
sw $t5, 0($t3)
addi $t3, $t4, 7304
sw $t5, 0($t3)
addi $t3, $t4, 7308
sw $t5, 0($t3)
addi $t3, $t4, 7312
sw $t5, 0($t3)
addi $t3, $t4, 7316
sw $t5, 0($t3)
addi $t3, $t4, 7320
sw $t5, 0($t3)
addi $t3, $t4, 7324
sw $t5, 0($t3)
addi $t3, $t4, 7328
sw $t5, 0($t3)
addi $t3, $t4, 7332
sw $t5, 0($t3)
addi $t3, $t4, 7336
sw $t5, 0($t3)
addi $t3, $t4, 7340
sw $t5, 0($t3)
addi $t3, $t4, 7344
sw $t5, 0($t3)
addi $t3, $t4, 7348
sw $t5, 0($t3)
addi $t3, $t4, 7352
sw $t5, 0($t3)
addi $t3, $t4, 7356
sw $t5, 0($t3)
addi $t3, $t4, 7360
sw $t5, 0($t3)
addi $t3, $t4, 7364
sw $t5, 0($t3)
addi $t3, $t4, 7368
sw $t5, 0($t3)
addi $t3, $t4, 7372
sw $t5, 0($t3)
addi $t3, $t4, 7376
sw $t5, 0($t3)
addi $t3, $t4, 7380
sw $t5, 0($t3)
addi $t3, $t4, 7384
sw $t5, 0($t3)
addi $t3, $t4, 7388
sw $t5, 0($t3)
addi $t3, $t4, 7392
sw $t5, 0($t3)
addi $t3, $t4, 7396
sw $t5, 0($t3)
addi $t3, $t4, 7400
sw $t5, 0($t3)
addi $t3, $t4, 7404
sw $t5, 0($t3)
addi $t3, $t4, 7408
sw $t5, 0($t3)
addi $t3, $t4, 7412
sw $t5, 0($t3)
addi $t3, $t4, 7416
sw $t5, 0($t3)
addi $t3, $t4, 7420
sw $t5, 0($t3)
addi $t3, $t4, 7424
sw $t5, 0($t3)
addi $t3, $t4, 7428
sw $t5, 0($t3)
addi $t3, $t4, 7432
sw $t5, 0($t3)
addi $t3, $t4, 7436
sw $t5, 0($t3)
addi $t3, $t4, 7440
sw $t5, 0($t3)
addi $t3, $t4, 7444
sw $t5, 0($t3)
addi $t3, $t4, 7448
sw $t5, 0($t3)
addi $t3, $t4, 7452
sw $t5, 0($t3)
addi $t3, $t4, 7456
sw $t5, 0($t3)
addi $t3, $t4, 7460
sw $t5, 0($t3)
addi $t3, $t4, 7464
sw $t5, 0($t3)
addi $t3, $t4, 7468
sw $t5, 0($t3)
addi $t3, $t4, 7472
sw $t5, 0($t3)
addi $t3, $t4, 7476
sw $t5, 0($t3)
addi $t3, $t4, 7480
sw $t5, 0($t3)
addi $t3, $t4, 7484
sw $t5, 0($t3)
addi $t3, $t4, 7488
sw $t5, 0($t3)
addi $t3, $t4, 7492
sw $t5, 0($t3)
addi $t3, $t4, 7496
sw $t5, 0($t3)
addi $t3, $t4, 7500
sw $t5, 0($t3)
addi $t3, $t4, 7504
li $t5,0x787878
sw $t5, 0($t3)
addi $t3, $t4, 7508
li $t5,0x1a1a1a
sw $t5, 0($t3)
addi $t3, $t4, 7512
li $t5,0xeeeeee
sw $t5, 0($t3)
addi $t3, $t4, 7516
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 7520
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 7524
sw $t5, 0($t3)
addi $t3, $t4, 7528
sw $t5, 0($t3)
addi $t3, $t4, 7532
sw $t5, 0($t3)
addi $t3, $t4, 7536
li $t5,0xfdfdfd
sw $t5, 0($t3)
addi $t3, $t4, 7540
li $t5,0x1c1c1c
sw $t5, 0($t3)
addi $t3, $t4, 7544
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 7548
li $t5,0x101010
sw $t5, 0($t3)
addi $t3, $t4, 7552
li $t5,0x979797
sw $t5, 0($t3)
addi $t3, $t4, 7556
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 7560
sw $t5, 0($t3)
addi $t3, $t4, 7564
sw $t5, 0($t3)
addi $t3, $t4, 7568
sw $t5, 0($t3)
addi $t3, $t4, 7572
li $t5,0x373737
sw $t5, 0($t3)
addi $t3, $t4, 7576
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 7580
sw $t5, 0($t3)
addi $t3, $t4, 7584
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 7588
sw $t5, 0($t3)
addi $t3, $t4, 7592
li $t5,0x343434
sw $t5, 0($t3)
addi $t3, $t4, 7596
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 7600
sw $t5, 0($t3)
addi $t3, $t4, 7604
sw $t5, 0($t3)
addi $t3, $t4, 7608
li $t5,0xfdfdfd
sw $t5, 0($t3)
addi $t3, $t4, 7612
li $t5,0x181818
sw $t5, 0($t3)
addi $t3, $t4, 7616
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 7620
sw $t5, 0($t3)
addi $t3, $t4, 7624
sw $t5, 0($t3)
addi $t3, $t4, 7628
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 7632
li $t5,0x191919
sw $t5, 0($t3)
addi $t3, $t4, 7636
li $t5,0xfffffe
sw $t5, 0($t3)
addi $t3, $t4, 7640
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 7644
li $t5,0xfcfcfc
sw $t5, 0($t3)
addi $t3, $t4, 7648
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 7652
sw $t5, 0($t3)
addi $t3, $t4, 7656
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 7660
sw $t5, 0($t3)
addi $t3, $t4, 7664
li $t5,0xfdfdfd
sw $t5, 0($t3)
addi $t3, $t4, 7668
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 7672
sw $t5, 0($t3)
addi $t3, $t4, 7676
sw $t5, 0($t3)
addi $t3, $t4, 7680
sw $t5, 0($t3)
addi $t3, $t4, 7684
sw $t5, 0($t3)
addi $t3, $t4, 7688
sw $t5, 0($t3)
addi $t3, $t4, 7692
sw $t5, 0($t3)
addi $t3, $t4, 7696
sw $t5, 0($t3)
addi $t3, $t4, 7700
sw $t5, 0($t3)
addi $t3, $t4, 7704
sw $t5, 0($t3)
addi $t3, $t4, 7708
sw $t5, 0($t3)
addi $t3, $t4, 7712
sw $t5, 0($t3)
addi $t3, $t4, 7716
sw $t5, 0($t3)
addi $t3, $t4, 7720
sw $t5, 0($t3)
addi $t3, $t4, 7724
sw $t5, 0($t3)
addi $t3, $t4, 7728
sw $t5, 0($t3)
addi $t3, $t4, 7732
sw $t5, 0($t3)
addi $t3, $t4, 7736
sw $t5, 0($t3)
addi $t3, $t4, 7740
sw $t5, 0($t3)
addi $t3, $t4, 7744
sw $t5, 0($t3)
addi $t3, $t4, 7748
sw $t5, 0($t3)
addi $t3, $t4, 7752
sw $t5, 0($t3)
addi $t3, $t4, 7756
sw $t5, 0($t3)
addi $t3, $t4, 7760
sw $t5, 0($t3)
addi $t3, $t4, 7764
sw $t5, 0($t3)
addi $t3, $t4, 7768
sw $t5, 0($t3)
addi $t3, $t4, 7772
sw $t5, 0($t3)
addi $t3, $t4, 7776
sw $t5, 0($t3)
addi $t3, $t4, 7780
sw $t5, 0($t3)
addi $t3, $t4, 7784
sw $t5, 0($t3)
addi $t3, $t4, 7788
sw $t5, 0($t3)
addi $t3, $t4, 7792
sw $t5, 0($t3)
addi $t3, $t4, 7796
sw $t5, 0($t3)
addi $t3, $t4, 7800
sw $t5, 0($t3)
addi $t3, $t4, 7804
sw $t5, 0($t3)
addi $t3, $t4, 7808
sw $t5, 0($t3)
addi $t3, $t4, 7812
sw $t5, 0($t3)
addi $t3, $t4, 7816
sw $t5, 0($t3)
addi $t3, $t4, 7820
sw $t5, 0($t3)
addi $t3, $t4, 7824
sw $t5, 0($t3)
addi $t3, $t4, 7828
sw $t5, 0($t3)
addi $t3, $t4, 7832
sw $t5, 0($t3)
addi $t3, $t4, 7836
sw $t5, 0($t3)
addi $t3, $t4, 7840
sw $t5, 0($t3)
addi $t3, $t4, 7844
sw $t5, 0($t3)
addi $t3, $t4, 7848
sw $t5, 0($t3)
addi $t3, $t4, 7852
sw $t5, 0($t3)
addi $t3, $t4, 7856
sw $t5, 0($t3)
addi $t3, $t4, 7860
sw $t5, 0($t3)
addi $t3, $t4, 7864
sw $t5, 0($t3)
addi $t3, $t4, 7868
sw $t5, 0($t3)
addi $t3, $t4, 7872
sw $t5, 0($t3)
addi $t3, $t4, 7876
sw $t5, 0($t3)
addi $t3, $t4, 7880
sw $t5, 0($t3)
addi $t3, $t4, 7884
sw $t5, 0($t3)
addi $t3, $t4, 7888
sw $t5, 0($t3)
addi $t3, $t4, 7892
sw $t5, 0($t3)
addi $t3, $t4, 7896
sw $t5, 0($t3)
addi $t3, $t4, 7900
sw $t5, 0($t3)
addi $t3, $t4, 7904
sw $t5, 0($t3)
addi $t3, $t4, 7908
sw $t5, 0($t3)
addi $t3, $t4, 7912
sw $t5, 0($t3)
addi $t3, $t4, 7916
sw $t5, 0($t3)
addi $t3, $t4, 7920
sw $t5, 0($t3)
addi $t3, $t4, 7924
sw $t5, 0($t3)
addi $t3, $t4, 7928
sw $t5, 0($t3)
addi $t3, $t4, 7932
sw $t5, 0($t3)
addi $t3, $t4, 7936
sw $t5, 0($t3)
addi $t3, $t4, 7940
sw $t5, 0($t3)
addi $t3, $t4, 7944
sw $t5, 0($t3)
addi $t3, $t4, 7948
sw $t5, 0($t3)
addi $t3, $t4, 7952
sw $t5, 0($t3)
addi $t3, $t4, 7956
sw $t5, 0($t3)
addi $t3, $t4, 7960
sw $t5, 0($t3)
addi $t3, $t4, 7964
sw $t5, 0($t3)
addi $t3, $t4, 7968
sw $t5, 0($t3)
addi $t3, $t4, 7972
sw $t5, 0($t3)
addi $t3, $t4, 7976
sw $t5, 0($t3)
addi $t3, $t4, 7980
sw $t5, 0($t3)
addi $t3, $t4, 7984
sw $t5, 0($t3)
addi $t3, $t4, 7988
sw $t5, 0($t3)
addi $t3, $t4, 7992
sw $t5, 0($t3)
addi $t3, $t4, 7996
sw $t5, 0($t3)
addi $t3, $t4, 8000
sw $t5, 0($t3)
addi $t3, $t4, 8004
sw $t5, 0($t3)
addi $t3, $t4, 8008
sw $t5, 0($t3)
addi $t3, $t4, 8012
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 8016
li $t5,0x1c1c1c
sw $t5, 0($t3)
addi $t3, $t4, 8020
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 8024
li $t5,0x111111
sw $t5, 0($t3)
addi $t3, $t4, 8028
li $t5,0xe2e2e2
sw $t5, 0($t3)
addi $t3, $t4, 8032
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 8036
sw $t5, 0($t3)
addi $t3, $t4, 8040
sw $t5, 0($t3)
addi $t3, $t4, 8044
sw $t5, 0($t3)
addi $t3, $t4, 8048
li $t5,0xf2f2f2
sw $t5, 0($t3)
addi $t3, $t4, 8052
li $t5,0x030303
sw $t5, 0($t3)
addi $t3, $t4, 8056
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 8060
sw $t5, 0($t3)
addi $t3, $t4, 8064
li $t5,0x0f0f0f
sw $t5, 0($t3)
addi $t3, $t4, 8068
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 8072
sw $t5, 0($t3)
addi $t3, $t4, 8076
sw $t5, 0($t3)
addi $t3, $t4, 8080
sw $t5, 0($t3)
addi $t3, $t4, 8084
li $t5,0x030303
sw $t5, 0($t3)
addi $t3, $t4, 8088
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 8092
sw $t5, 0($t3)
addi $t3, $t4, 8096
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 8100
sw $t5, 0($t3)
addi $t3, $t4, 8104
li $t5,0x030303
sw $t5, 0($t3)
addi $t3, $t4, 8108
li $t5,0xfdfdfd
sw $t5, 0($t3)
addi $t3, $t4, 8112
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 8116
sw $t5, 0($t3)
addi $t3, $t4, 8120
li $t5,0xfdfdfd
sw $t5, 0($t3)
addi $t3, $t4, 8124
li $t5,0x040404
sw $t5, 0($t3)
addi $t3, $t4, 8128
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 8132
sw $t5, 0($t3)
addi $t3, $t4, 8136
sw $t5, 0($t3)
addi $t3, $t4, 8140
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 8144
li $t5,0x232323
sw $t5, 0($t3)
addi $t3, $t4, 8148
li $t5,0xfbfbfb
sw $t5, 0($t3)
addi $t3, $t4, 8152
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 8156
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 8160
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 8164
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 8168
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 8172
li $t5,0x070707
sw $t5, 0($t3)
addi $t3, $t4, 8176
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 8180
sw $t5, 0($t3)
addi $t3, $t4, 8184
sw $t5, 0($t3)
addi $t3, $t4, 8188
sw $t5, 0($t3)
addi $t3, $t4, 8192
sw $t5, 0($t3)
addi $t3, $t4, 8196
sw $t5, 0($t3)
addi $t3, $t4, 8200
sw $t5, 0($t3)
addi $t3, $t4, 8204
sw $t5, 0($t3)
addi $t3, $t4, 8208
sw $t5, 0($t3)
addi $t3, $t4, 8212
sw $t5, 0($t3)
addi $t3, $t4, 8216
sw $t5, 0($t3)
addi $t3, $t4, 8220
sw $t5, 0($t3)
addi $t3, $t4, 8224
sw $t5, 0($t3)
addi $t3, $t4, 8228
sw $t5, 0($t3)
addi $t3, $t4, 8232
sw $t5, 0($t3)
addi $t3, $t4, 8236
sw $t5, 0($t3)
addi $t3, $t4, 8240
sw $t5, 0($t3)
addi $t3, $t4, 8244
sw $t5, 0($t3)
addi $t3, $t4, 8248
sw $t5, 0($t3)
addi $t3, $t4, 8252
sw $t5, 0($t3)
addi $t3, $t4, 8256
sw $t5, 0($t3)
addi $t3, $t4, 8260
sw $t5, 0($t3)
addi $t3, $t4, 8264
sw $t5, 0($t3)
addi $t3, $t4, 8268
sw $t5, 0($t3)
addi $t3, $t4, 8272
sw $t5, 0($t3)
addi $t3, $t4, 8276
sw $t5, 0($t3)
addi $t3, $t4, 8280
sw $t5, 0($t3)
addi $t3, $t4, 8284
sw $t5, 0($t3)
addi $t3, $t4, 8288
sw $t5, 0($t3)
addi $t3, $t4, 8292
sw $t5, 0($t3)
addi $t3, $t4, 8296
sw $t5, 0($t3)
addi $t3, $t4, 8300
sw $t5, 0($t3)
addi $t3, $t4, 8304
sw $t5, 0($t3)
addi $t3, $t4, 8308
sw $t5, 0($t3)
addi $t3, $t4, 8312
sw $t5, 0($t3)
addi $t3, $t4, 8316
sw $t5, 0($t3)
addi $t3, $t4, 8320
sw $t5, 0($t3)
addi $t3, $t4, 8324
sw $t5, 0($t3)
addi $t3, $t4, 8328
sw $t5, 0($t3)
addi $t3, $t4, 8332
sw $t5, 0($t3)
addi $t3, $t4, 8336
sw $t5, 0($t3)
addi $t3, $t4, 8340
sw $t5, 0($t3)
addi $t3, $t4, 8344
sw $t5, 0($t3)
addi $t3, $t4, 8348
sw $t5, 0($t3)
addi $t3, $t4, 8352
sw $t5, 0($t3)
addi $t3, $t4, 8356
sw $t5, 0($t3)
addi $t3, $t4, 8360
sw $t5, 0($t3)
addi $t3, $t4, 8364
sw $t5, 0($t3)
addi $t3, $t4, 8368
sw $t5, 0($t3)
addi $t3, $t4, 8372
sw $t5, 0($t3)
addi $t3, $t4, 8376
sw $t5, 0($t3)
addi $t3, $t4, 8380
sw $t5, 0($t3)
addi $t3, $t4, 8384
sw $t5, 0($t3)
addi $t3, $t4, 8388
sw $t5, 0($t3)
addi $t3, $t4, 8392
sw $t5, 0($t3)
addi $t3, $t4, 8396
sw $t5, 0($t3)
addi $t3, $t4, 8400
sw $t5, 0($t3)
addi $t3, $t4, 8404
sw $t5, 0($t3)
addi $t3, $t4, 8408
sw $t5, 0($t3)
addi $t3, $t4, 8412
sw $t5, 0($t3)
addi $t3, $t4, 8416
sw $t5, 0($t3)
addi $t3, $t4, 8420
sw $t5, 0($t3)
addi $t3, $t4, 8424
sw $t5, 0($t3)
addi $t3, $t4, 8428
sw $t5, 0($t3)
addi $t3, $t4, 8432
sw $t5, 0($t3)
addi $t3, $t4, 8436
sw $t5, 0($t3)
addi $t3, $t4, 8440
sw $t5, 0($t3)
addi $t3, $t4, 8444
sw $t5, 0($t3)
addi $t3, $t4, 8448
sw $t5, 0($t3)
addi $t3, $t4, 8452
sw $t5, 0($t3)
addi $t3, $t4, 8456
sw $t5, 0($t3)
addi $t3, $t4, 8460
sw $t5, 0($t3)
addi $t3, $t4, 8464
sw $t5, 0($t3)
addi $t3, $t4, 8468
sw $t5, 0($t3)
addi $t3, $t4, 8472
sw $t5, 0($t3)
addi $t3, $t4, 8476
sw $t5, 0($t3)
addi $t3, $t4, 8480
sw $t5, 0($t3)
addi $t3, $t4, 8484
sw $t5, 0($t3)
addi $t3, $t4, 8488
sw $t5, 0($t3)
addi $t3, $t4, 8492
sw $t5, 0($t3)
addi $t3, $t4, 8496
sw $t5, 0($t3)
addi $t3, $t4, 8500
sw $t5, 0($t3)
addi $t3, $t4, 8504
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 8508
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 8512
sw $t5, 0($t3)
addi $t3, $t4, 8516
sw $t5, 0($t3)
addi $t3, $t4, 8520
sw $t5, 0($t3)
addi $t3, $t4, 8524
li $t5,0xfdfdfd
sw $t5, 0($t3)
addi $t3, $t4, 8528
li $t5,0x020202
sw $t5, 0($t3)
addi $t3, $t4, 8532
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 8536
li $t5,0x020202
sw $t5, 0($t3)
addi $t3, $t4, 8540
li $t5,0x030303
sw $t5, 0($t3)
addi $t3, $t4, 8544
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 8548
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 8552
sw $t5, 0($t3)
addi $t3, $t4, 8556
sw $t5, 0($t3)
addi $t3, $t4, 8560
li $t5,0x636363
sw $t5, 0($t3)
addi $t3, $t4, 8564
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 8568
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 8572
sw $t5, 0($t3)
addi $t3, $t4, 8576
li $t5,0x020202
sw $t5, 0($t3)
addi $t3, $t4, 8580
li $t5,0xd0d0d0
sw $t5, 0($t3)
addi $t3, $t4, 8584
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 8588
sw $t5, 0($t3)
addi $t3, $t4, 8592
li $t5,0xf8f8f8
sw $t5, 0($t3)
addi $t3, $t4, 8596
li $t5,0x020202
sw $t5, 0($t3)
addi $t3, $t4, 8600
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 8604
sw $t5, 0($t3)
addi $t3, $t4, 8608
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 8612
sw $t5, 0($t3)
addi $t3, $t4, 8616
sw $t5, 0($t3)
addi $t3, $t4, 8620
li $t5,0xcccccc
sw $t5, 0($t3)
addi $t3, $t4, 8624
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 8628
sw $t5, 0($t3)
addi $t3, $t4, 8632
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 8636
li $t5,0x030303
sw $t5, 0($t3)
addi $t3, $t4, 8640
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 8644
sw $t5, 0($t3)
addi $t3, $t4, 8648
sw $t5, 0($t3)
addi $t3, $t4, 8652
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 8656
li $t5,0x3e3e3e
sw $t5, 0($t3)
addi $t3, $t4, 8660
li $t5,0xfdfdfd
sw $t5, 0($t3)
addi $t3, $t4, 8664
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 8668
li $t5,0xf4f4f4
sw $t5, 0($t3)
addi $t3, $t4, 8672
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 8676
sw $t5, 0($t3)
addi $t3, $t4, 8680
li $t5,0x020202
sw $t5, 0($t3)
addi $t3, $t4, 8684
li $t5,0x3f3f3f
sw $t5, 0($t3)
addi $t3, $t4, 8688
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 8692
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 8696
sw $t5, 0($t3)
addi $t3, $t4, 8700
sw $t5, 0($t3)
addi $t3, $t4, 8704
sw $t5, 0($t3)
addi $t3, $t4, 8708
sw $t5, 0($t3)
addi $t3, $t4, 8712
sw $t5, 0($t3)
addi $t3, $t4, 8716
sw $t5, 0($t3)
addi $t3, $t4, 8720
sw $t5, 0($t3)
addi $t3, $t4, 8724
sw $t5, 0($t3)
addi $t3, $t4, 8728
sw $t5, 0($t3)
addi $t3, $t4, 8732
sw $t5, 0($t3)
addi $t3, $t4, 8736
sw $t5, 0($t3)
addi $t3, $t4, 8740
sw $t5, 0($t3)
addi $t3, $t4, 8744
sw $t5, 0($t3)
addi $t3, $t4, 8748
sw $t5, 0($t3)
addi $t3, $t4, 8752
sw $t5, 0($t3)
addi $t3, $t4, 8756
sw $t5, 0($t3)
addi $t3, $t4, 8760
sw $t5, 0($t3)
addi $t3, $t4, 8764
sw $t5, 0($t3)
addi $t3, $t4, 8768
sw $t5, 0($t3)
addi $t3, $t4, 8772
sw $t5, 0($t3)
addi $t3, $t4, 8776
sw $t5, 0($t3)
addi $t3, $t4, 8780
sw $t5, 0($t3)
addi $t3, $t4, 8784
sw $t5, 0($t3)
addi $t3, $t4, 8788
sw $t5, 0($t3)
addi $t3, $t4, 8792
sw $t5, 0($t3)
addi $t3, $t4, 8796
sw $t5, 0($t3)
addi $t3, $t4, 8800
sw $t5, 0($t3)
addi $t3, $t4, 8804
sw $t5, 0($t3)
addi $t3, $t4, 8808
sw $t5, 0($t3)
addi $t3, $t4, 8812
sw $t5, 0($t3)
addi $t3, $t4, 8816
sw $t5, 0($t3)
addi $t3, $t4, 8820
sw $t5, 0($t3)
addi $t3, $t4, 8824
sw $t5, 0($t3)
addi $t3, $t4, 8828
sw $t5, 0($t3)
addi $t3, $t4, 8832
sw $t5, 0($t3)
addi $t3, $t4, 8836
sw $t5, 0($t3)
addi $t3, $t4, 8840
sw $t5, 0($t3)
addi $t3, $t4, 8844
sw $t5, 0($t3)
addi $t3, $t4, 8848
sw $t5, 0($t3)
addi $t3, $t4, 8852
sw $t5, 0($t3)
addi $t3, $t4, 8856
sw $t5, 0($t3)
addi $t3, $t4, 8860
sw $t5, 0($t3)
addi $t3, $t4, 8864
sw $t5, 0($t3)
addi $t3, $t4, 8868
sw $t5, 0($t3)
addi $t3, $t4, 8872
sw $t5, 0($t3)
addi $t3, $t4, 8876
sw $t5, 0($t3)
addi $t3, $t4, 8880
sw $t5, 0($t3)
addi $t3, $t4, 8884
sw $t5, 0($t3)
addi $t3, $t4, 8888
sw $t5, 0($t3)
addi $t3, $t4, 8892
sw $t5, 0($t3)
addi $t3, $t4, 8896
sw $t5, 0($t3)
addi $t3, $t4, 8900
sw $t5, 0($t3)
addi $t3, $t4, 8904
sw $t5, 0($t3)
addi $t3, $t4, 8908
sw $t5, 0($t3)
addi $t3, $t4, 8912
sw $t5, 0($t3)
addi $t3, $t4, 8916
sw $t5, 0($t3)
addi $t3, $t4, 8920
sw $t5, 0($t3)
addi $t3, $t4, 8924
sw $t5, 0($t3)
addi $t3, $t4, 8928
sw $t5, 0($t3)
addi $t3, $t4, 8932
sw $t5, 0($t3)
addi $t3, $t4, 8936
sw $t5, 0($t3)
addi $t3, $t4, 8940
sw $t5, 0($t3)
addi $t3, $t4, 8944
sw $t5, 0($t3)
addi $t3, $t4, 8948
sw $t5, 0($t3)
addi $t3, $t4, 8952
sw $t5, 0($t3)
addi $t3, $t4, 8956
sw $t5, 0($t3)
addi $t3, $t4, 8960
sw $t5, 0($t3)
addi $t3, $t4, 8964
sw $t5, 0($t3)
addi $t3, $t4, 8968
sw $t5, 0($t3)
addi $t3, $t4, 8972
sw $t5, 0($t3)
addi $t3, $t4, 8976
sw $t5, 0($t3)
addi $t3, $t4, 8980
sw $t5, 0($t3)
addi $t3, $t4, 8984
sw $t5, 0($t3)
addi $t3, $t4, 8988
sw $t5, 0($t3)
addi $t3, $t4, 8992
sw $t5, 0($t3)
addi $t3, $t4, 8996
sw $t5, 0($t3)
addi $t3, $t4, 9000
sw $t5, 0($t3)
addi $t3, $t4, 9004
sw $t5, 0($t3)
addi $t3, $t4, 9008
li $t5,0x5d5d5d
sw $t5, 0($t3)
addi $t3, $t4, 9012
li $t5,0xcccccc
sw $t5, 0($t3)
addi $t3, $t4, 9016
li $t5,0xfdfdfd
sw $t5, 0($t3)
addi $t3, $t4, 9020
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 9024
sw $t5, 0($t3)
addi $t3, $t4, 9028
sw $t5, 0($t3)
addi $t3, $t4, 9032
sw $t5, 0($t3)
addi $t3, $t4, 9036
li $t5,0xfbfbfb
sw $t5, 0($t3)
addi $t3, $t4, 9040
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 9044
sw $t5, 0($t3)
addi $t3, $t4, 9048
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 9052
sw $t5, 0($t3)
addi $t3, $t4, 9056
li $t5,0xf9f9f9
sw $t5, 0($t3)
addi $t3, $t4, 9060
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 9064
sw $t5, 0($t3)
addi $t3, $t4, 9068
li $t5,0xfdfdfd
sw $t5, 0($t3)
addi $t3, $t4, 9072
li $t5,0x030303
sw $t5, 0($t3)
addi $t3, $t4, 9076
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 9080
sw $t5, 0($t3)
addi $t3, $t4, 9084
sw $t5, 0($t3)
addi $t3, $t4, 9088
sw $t5, 0($t3)
addi $t3, $t4, 9092
li $t5,0x898989
sw $t5, 0($t3)
addi $t3, $t4, 9096
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 9100
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 9104
li $t5,0xd7d7d7
sw $t5, 0($t3)
addi $t3, $t4, 9108
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 9112
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 9116
sw $t5, 0($t3)
addi $t3, $t4, 9120
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 9124
sw $t5, 0($t3)
addi $t3, $t4, 9128
sw $t5, 0($t3)
addi $t3, $t4, 9132
li $t5,0x616161
sw $t5, 0($t3)
addi $t3, $t4, 9136
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 9140
sw $t5, 0($t3)
addi $t3, $t4, 9144
li $t5,0xd5d5d5
sw $t5, 0($t3)
addi $t3, $t4, 9148
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 9152
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 9156
sw $t5, 0($t3)
addi $t3, $t4, 9160
sw $t5, 0($t3)
addi $t3, $t4, 9164
sw $t5, 0($t3)
addi $t3, $t4, 9168
li $t5,0x505050
sw $t5, 0($t3)
addi $t3, $t4, 9172
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 9176
sw $t5, 0($t3)
addi $t3, $t4, 9180
li $t5,0xe0e0e0
sw $t5, 0($t3)
addi $t3, $t4, 9184
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 9188
sw $t5, 0($t3)
addi $t3, $t4, 9192
li $t5,0x020202
sw $t5, 0($t3)
addi $t3, $t4, 9196
li $t5,0xc5c5c5
sw $t5, 0($t3)
addi $t3, $t4, 9200
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 9204
sw $t5, 0($t3)
addi $t3, $t4, 9208
sw $t5, 0($t3)
addi $t3, $t4, 9212
sw $t5, 0($t3)
addi $t3, $t4, 9216
sw $t5, 0($t3)
addi $t3, $t4, 9220
sw $t5, 0($t3)
addi $t3, $t4, 9224
sw $t5, 0($t3)
addi $t3, $t4, 9228
sw $t5, 0($t3)
addi $t3, $t4, 9232
sw $t5, 0($t3)
addi $t3, $t4, 9236
sw $t5, 0($t3)
addi $t3, $t4, 9240
sw $t5, 0($t3)
addi $t3, $t4, 9244
sw $t5, 0($t3)
addi $t3, $t4, 9248
sw $t5, 0($t3)
addi $t3, $t4, 9252
sw $t5, 0($t3)
addi $t3, $t4, 9256
sw $t5, 0($t3)
addi $t3, $t4, 9260
sw $t5, 0($t3)
addi $t3, $t4, 9264
sw $t5, 0($t3)
addi $t3, $t4, 9268
sw $t5, 0($t3)
addi $t3, $t4, 9272
sw $t5, 0($t3)
addi $t3, $t4, 9276
sw $t5, 0($t3)
addi $t3, $t4, 9280
sw $t5, 0($t3)
addi $t3, $t4, 9284
sw $t5, 0($t3)
addi $t3, $t4, 9288
sw $t5, 0($t3)
addi $t3, $t4, 9292
sw $t5, 0($t3)
addi $t3, $t4, 9296
sw $t5, 0($t3)
addi $t3, $t4, 9300
sw $t5, 0($t3)
addi $t3, $t4, 9304
sw $t5, 0($t3)
addi $t3, $t4, 9308
sw $t5, 0($t3)
addi $t3, $t4, 9312
sw $t5, 0($t3)
addi $t3, $t4, 9316
sw $t5, 0($t3)
addi $t3, $t4, 9320
sw $t5, 0($t3)
addi $t3, $t4, 9324
sw $t5, 0($t3)
addi $t3, $t4, 9328
sw $t5, 0($t3)
addi $t3, $t4, 9332
sw $t5, 0($t3)
addi $t3, $t4, 9336
sw $t5, 0($t3)
addi $t3, $t4, 9340
sw $t5, 0($t3)
addi $t3, $t4, 9344
sw $t5, 0($t3)
addi $t3, $t4, 9348
sw $t5, 0($t3)
addi $t3, $t4, 9352
sw $t5, 0($t3)
addi $t3, $t4, 9356
sw $t5, 0($t3)
addi $t3, $t4, 9360
sw $t5, 0($t3)
addi $t3, $t4, 9364
sw $t5, 0($t3)
addi $t3, $t4, 9368
sw $t5, 0($t3)
addi $t3, $t4, 9372
sw $t5, 0($t3)
addi $t3, $t4, 9376
sw $t5, 0($t3)
addi $t3, $t4, 9380
sw $t5, 0($t3)
addi $t3, $t4, 9384
sw $t5, 0($t3)
addi $t3, $t4, 9388
sw $t5, 0($t3)
addi $t3, $t4, 9392
sw $t5, 0($t3)
addi $t3, $t4, 9396
sw $t5, 0($t3)
addi $t3, $t4, 9400
sw $t5, 0($t3)
addi $t3, $t4, 9404
sw $t5, 0($t3)
addi $t3, $t4, 9408
sw $t5, 0($t3)
addi $t3, $t4, 9412
sw $t5, 0($t3)
addi $t3, $t4, 9416
sw $t5, 0($t3)
addi $t3, $t4, 9420
sw $t5, 0($t3)
addi $t3, $t4, 9424
sw $t5, 0($t3)
addi $t3, $t4, 9428
sw $t5, 0($t3)
addi $t3, $t4, 9432
sw $t5, 0($t3)
addi $t3, $t4, 9436
sw $t5, 0($t3)
addi $t3, $t4, 9440
sw $t5, 0($t3)
addi $t3, $t4, 9444
sw $t5, 0($t3)
addi $t3, $t4, 9448
sw $t5, 0($t3)
addi $t3, $t4, 9452
sw $t5, 0($t3)
addi $t3, $t4, 9456
sw $t5, 0($t3)
addi $t3, $t4, 9460
sw $t5, 0($t3)
addi $t3, $t4, 9464
sw $t5, 0($t3)
addi $t3, $t4, 9468
sw $t5, 0($t3)
addi $t3, $t4, 9472
sw $t5, 0($t3)
addi $t3, $t4, 9476
li $t5,0xd1d1d1
sw $t5, 0($t3)
addi $t3, $t4, 9480
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 9484
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 9488
sw $t5, 0($t3)
addi $t3, $t4, 9492
sw $t5, 0($t3)
addi $t3, $t4, 9496
sw $t5, 0($t3)
addi $t3, $t4, 9500
sw $t5, 0($t3)
addi $t3, $t4, 9504
sw $t5, 0($t3)
addi $t3, $t4, 9508
sw $t5, 0($t3)
addi $t3, $t4, 9512
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 9516
li $t5,0xf3f3f3
sw $t5, 0($t3)
addi $t3, $t4, 9520
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 9524
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 9528
li $t5,0xafafaf
sw $t5, 0($t3)
addi $t3, $t4, 9532
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 9536
sw $t5, 0($t3)
addi $t3, $t4, 9540
sw $t5, 0($t3)
addi $t3, $t4, 9544
sw $t5, 0($t3)
addi $t3, $t4, 9548
li $t5,0xb8b8b8
sw $t5, 0($t3)
addi $t3, $t4, 9552
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 9556
sw $t5, 0($t3)
addi $t3, $t4, 9560
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 9564
sw $t5, 0($t3)
addi $t3, $t4, 9568
li $t5,0x040404
sw $t5, 0($t3)
addi $t3, $t4, 9572
li $t5,0xfdfdfd
sw $t5, 0($t3)
addi $t3, $t4, 9576
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 9580
li $t5,0xbebebe
sw $t5, 0($t3)
addi $t3, $t4, 9584
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 9588
sw $t5, 0($t3)
addi $t3, $t4, 9592
sw $t5, 0($t3)
addi $t3, $t4, 9596
sw $t5, 0($t3)
addi $t3, $t4, 9600
sw $t5, 0($t3)
addi $t3, $t4, 9604
li $t5,0x999999
sw $t5, 0($t3)
addi $t3, $t4, 9608
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 9612
sw $t5, 0($t3)
addi $t3, $t4, 9616
li $t5,0xa6a6a6
sw $t5, 0($t3)
addi $t3, $t4, 9620
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 9624
sw $t5, 0($t3)
addi $t3, $t4, 9628
sw $t5, 0($t3)
addi $t3, $t4, 9632
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 9636
sw $t5, 0($t3)
addi $t3, $t4, 9640
sw $t5, 0($t3)
addi $t3, $t4, 9644
li $t5,0x030303
sw $t5, 0($t3)
addi $t3, $t4, 9648
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 9652
sw $t5, 0($t3)
addi $t3, $t4, 9656
li $t5,0xb4b4b4
sw $t5, 0($t3)
addi $t3, $t4, 9660
li $t5,0x020202
sw $t5, 0($t3)
addi $t3, $t4, 9664
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 9668
sw $t5, 0($t3)
addi $t3, $t4, 9672
sw $t5, 0($t3)
addi $t3, $t4, 9676
li $t5,0x030303
sw $t5, 0($t3)
addi $t3, $t4, 9680
li $t5,0xa9a9a9
sw $t5, 0($t3)
addi $t3, $t4, 9684
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 9688
sw $t5, 0($t3)
addi $t3, $t4, 9692
li $t5,0xd5d5d5
sw $t5, 0($t3)
addi $t3, $t4, 9696
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 9700
sw $t5, 0($t3)
addi $t3, $t4, 9704
sw $t5, 0($t3)
addi $t3, $t4, 9708
li $t5,0xe9e9e9
sw $t5, 0($t3)
addi $t3, $t4, 9712
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 9716
sw $t5, 0($t3)
addi $t3, $t4, 9720
sw $t5, 0($t3)
addi $t3, $t4, 9724
sw $t5, 0($t3)
addi $t3, $t4, 9728
sw $t5, 0($t3)
addi $t3, $t4, 9732
sw $t5, 0($t3)
addi $t3, $t4, 9736
sw $t5, 0($t3)
addi $t3, $t4, 9740
sw $t5, 0($t3)
addi $t3, $t4, 9744
sw $t5, 0($t3)
addi $t3, $t4, 9748
sw $t5, 0($t3)
addi $t3, $t4, 9752
sw $t5, 0($t3)
addi $t3, $t4, 9756
sw $t5, 0($t3)
addi $t3, $t4, 9760
sw $t5, 0($t3)
addi $t3, $t4, 9764
sw $t5, 0($t3)
addi $t3, $t4, 9768
sw $t5, 0($t3)
addi $t3, $t4, 9772
sw $t5, 0($t3)
addi $t3, $t4, 9776
sw $t5, 0($t3)
addi $t3, $t4, 9780
sw $t5, 0($t3)
addi $t3, $t4, 9784
sw $t5, 0($t3)
addi $t3, $t4, 9788
sw $t5, 0($t3)
addi $t3, $t4, 9792
sw $t5, 0($t3)
addi $t3, $t4, 9796
sw $t5, 0($t3)
addi $t3, $t4, 9800
sw $t5, 0($t3)
addi $t3, $t4, 9804
sw $t5, 0($t3)
addi $t3, $t4, 9808
sw $t5, 0($t3)
addi $t3, $t4, 9812
sw $t5, 0($t3)
addi $t3, $t4, 9816
sw $t5, 0($t3)
addi $t3, $t4, 9820
sw $t5, 0($t3)
addi $t3, $t4, 9824
sw $t5, 0($t3)
addi $t3, $t4, 9828
sw $t5, 0($t3)
addi $t3, $t4, 9832
sw $t5, 0($t3)
addi $t3, $t4, 9836
sw $t5, 0($t3)
addi $t3, $t4, 9840
sw $t5, 0($t3)
addi $t3, $t4, 9844
sw $t5, 0($t3)
addi $t3, $t4, 9848
sw $t5, 0($t3)
addi $t3, $t4, 9852
sw $t5, 0($t3)
addi $t3, $t4, 9856
sw $t5, 0($t3)
addi $t3, $t4, 9860
sw $t5, 0($t3)
addi $t3, $t4, 9864
sw $t5, 0($t3)
addi $t3, $t4, 9868
sw $t5, 0($t3)
addi $t3, $t4, 9872
sw $t5, 0($t3)
addi $t3, $t4, 9876
sw $t5, 0($t3)
addi $t3, $t4, 9880
sw $t5, 0($t3)
addi $t3, $t4, 9884
sw $t5, 0($t3)
addi $t3, $t4, 9888
sw $t5, 0($t3)
addi $t3, $t4, 9892
sw $t5, 0($t3)
addi $t3, $t4, 9896
sw $t5, 0($t3)
addi $t3, $t4, 9900
sw $t5, 0($t3)
addi $t3, $t4, 9904
sw $t5, 0($t3)
addi $t3, $t4, 9908
sw $t5, 0($t3)
addi $t3, $t4, 9912
sw $t5, 0($t3)
addi $t3, $t4, 9916
sw $t5, 0($t3)
addi $t3, $t4, 9920
sw $t5, 0($t3)
addi $t3, $t4, 9924
sw $t5, 0($t3)
addi $t3, $t4, 9928
sw $t5, 0($t3)
addi $t3, $t4, 9932
sw $t5, 0($t3)
addi $t3, $t4, 9936
sw $t5, 0($t3)
addi $t3, $t4, 9940
sw $t5, 0($t3)
addi $t3, $t4, 9944
sw $t5, 0($t3)
addi $t3, $t4, 9948
sw $t5, 0($t3)
addi $t3, $t4, 9952
sw $t5, 0($t3)
addi $t3, $t4, 9956
sw $t5, 0($t3)
addi $t3, $t4, 9960
sw $t5, 0($t3)
addi $t3, $t4, 9964
sw $t5, 0($t3)
addi $t3, $t4, 9968
sw $t5, 0($t3)
addi $t3, $t4, 9972
sw $t5, 0($t3)
addi $t3, $t4, 9976
sw $t5, 0($t3)
addi $t3, $t4, 9980
sw $t5, 0($t3)
addi $t3, $t4, 9984
li $t5,0xd6d6d6
sw $t5, 0($t3)
addi $t3, $t4, 9988
li $t5,0x080808
sw $t5, 0($t3)
addi $t3, $t4, 9992
li $t5,0x2d2d2d
sw $t5, 0($t3)
addi $t3, $t4, 9996
li $t5,0xf8f8f8
sw $t5, 0($t3)
addi $t3, $t4, 10000
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 10004
sw $t5, 0($t3)
addi $t3, $t4, 10008
sw $t5, 0($t3)
addi $t3, $t4, 10012
sw $t5, 0($t3)
addi $t3, $t4, 10016
sw $t5, 0($t3)
addi $t3, $t4, 10020
sw $t5, 0($t3)
addi $t3, $t4, 10024
sw $t5, 0($t3)
addi $t3, $t4, 10028
li $t5,0x4c4c4c
sw $t5, 0($t3)
addi $t3, $t4, 10032
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 10036
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 10040
li $t5,0x101010
sw $t5, 0($t3)
addi $t3, $t4, 10044
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 10048
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 10052
sw $t5, 0($t3)
addi $t3, $t4, 10056
sw $t5, 0($t3)
addi $t3, $t4, 10060
li $t5,0x5a5a5a
sw $t5, 0($t3)
addi $t3, $t4, 10064
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 10068
sw $t5, 0($t3)
addi $t3, $t4, 10072
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 10076
sw $t5, 0($t3)
addi $t3, $t4, 10080
li $t5,0x090909
sw $t5, 0($t3)
addi $t3, $t4, 10084
li $t5,0xfdfdfd
sw $t5, 0($t3)
addi $t3, $t4, 10088
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 10092
li $t5,0x383838
sw $t5, 0($t3)
addi $t3, $t4, 10096
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 10100
sw $t5, 0($t3)
addi $t3, $t4, 10104
sw $t5, 0($t3)
addi $t3, $t4, 10108
sw $t5, 0($t3)
addi $t3, $t4, 10112
sw $t5, 0($t3)
addi $t3, $t4, 10116
li $t5,0xd8d8d8
sw $t5, 0($t3)
addi $t3, $t4, 10120
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 10124
sw $t5, 0($t3)
addi $t3, $t4, 10128
li $t5,0x555555
sw $t5, 0($t3)
addi $t3, $t4, 10132
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 10136
sw $t5, 0($t3)
addi $t3, $t4, 10140
sw $t5, 0($t3)
addi $t3, $t4, 10144
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 10148
sw $t5, 0($t3)
addi $t3, $t4, 10152
sw $t5, 0($t3)
addi $t3, $t4, 10156
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 10160
li $t5,0xfcfcfc
sw $t5, 0($t3)
addi $t3, $t4, 10164
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 10168
li $t5,0x757575
sw $t5, 0($t3)
addi $t3, $t4, 10172
li $t5,0x020202
sw $t5, 0($t3)
addi $t3, $t4, 10176
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 10180
sw $t5, 0($t3)
addi $t3, $t4, 10184
sw $t5, 0($t3)
addi $t3, $t4, 10188
li $t5,0x0e0e0e
sw $t5, 0($t3)
addi $t3, $t4, 10192
li $t5,0xd3d2d2
sw $t5, 0($t3)
addi $t3, $t4, 10196
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 10200
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 10204
li $t5,0xdedede
sw $t5, 0($t3)
addi $t3, $t4, 10208
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 10212
sw $t5, 0($t3)
addi $t3, $t4, 10216
sw $t5, 0($t3)
addi $t3, $t4, 10220
li $t5,0xf5f5f5
sw $t5, 0($t3)
addi $t3, $t4, 10224
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 10228
sw $t5, 0($t3)
addi $t3, $t4, 10232
sw $t5, 0($t3)
addi $t3, $t4, 10236
sw $t5, 0($t3)
addi $t3, $t4, 10240
sw $t5, 0($t3)
addi $t3, $t4, 10244
sw $t5, 0($t3)
addi $t3, $t4, 10248
sw $t5, 0($t3)
addi $t3, $t4, 10252
sw $t5, 0($t3)
addi $t3, $t4, 10256
sw $t5, 0($t3)
addi $t3, $t4, 10260
sw $t5, 0($t3)
addi $t3, $t4, 10264
sw $t5, 0($t3)
addi $t3, $t4, 10268
sw $t5, 0($t3)
addi $t3, $t4, 10272
sw $t5, 0($t3)
addi $t3, $t4, 10276
sw $t5, 0($t3)
addi $t3, $t4, 10280
sw $t5, 0($t3)
addi $t3, $t4, 10284
sw $t5, 0($t3)
addi $t3, $t4, 10288
sw $t5, 0($t3)
addi $t3, $t4, 10292
sw $t5, 0($t3)
addi $t3, $t4, 10296
sw $t5, 0($t3)
addi $t3, $t4, 10300
sw $t5, 0($t3)
addi $t3, $t4, 10304
sw $t5, 0($t3)
addi $t3, $t4, 10308
sw $t5, 0($t3)
addi $t3, $t4, 10312
sw $t5, 0($t3)
addi $t3, $t4, 10316
sw $t5, 0($t3)
addi $t3, $t4, 10320
sw $t5, 0($t3)
addi $t3, $t4, 10324
sw $t5, 0($t3)
addi $t3, $t4, 10328
sw $t5, 0($t3)
addi $t3, $t4, 10332
sw $t5, 0($t3)
addi $t3, $t4, 10336
sw $t5, 0($t3)
addi $t3, $t4, 10340
sw $t5, 0($t3)
addi $t3, $t4, 10344
sw $t5, 0($t3)
addi $t3, $t4, 10348
sw $t5, 0($t3)
addi $t3, $t4, 10352
sw $t5, 0($t3)
addi $t3, $t4, 10356
sw $t5, 0($t3)
addi $t3, $t4, 10360
sw $t5, 0($t3)
addi $t3, $t4, 10364
sw $t5, 0($t3)
addi $t3, $t4, 10368
sw $t5, 0($t3)
addi $t3, $t4, 10372
sw $t5, 0($t3)
addi $t3, $t4, 10376
sw $t5, 0($t3)
addi $t3, $t4, 10380
sw $t5, 0($t3)
addi $t3, $t4, 10384
sw $t5, 0($t3)
addi $t3, $t4, 10388
sw $t5, 0($t3)
addi $t3, $t4, 10392
sw $t5, 0($t3)
addi $t3, $t4, 10396
sw $t5, 0($t3)
addi $t3, $t4, 10400
sw $t5, 0($t3)
addi $t3, $t4, 10404
sw $t5, 0($t3)
addi $t3, $t4, 10408
sw $t5, 0($t3)
addi $t3, $t4, 10412
sw $t5, 0($t3)
addi $t3, $t4, 10416
sw $t5, 0($t3)
addi $t3, $t4, 10420
sw $t5, 0($t3)
addi $t3, $t4, 10424
sw $t5, 0($t3)
addi $t3, $t4, 10428
sw $t5, 0($t3)
addi $t3, $t4, 10432
sw $t5, 0($t3)
addi $t3, $t4, 10436
sw $t5, 0($t3)
addi $t3, $t4, 10440
sw $t5, 0($t3)
addi $t3, $t4, 10444
sw $t5, 0($t3)
addi $t3, $t4, 10448
sw $t5, 0($t3)
addi $t3, $t4, 10452
sw $t5, 0($t3)
addi $t3, $t4, 10456
sw $t5, 0($t3)
addi $t3, $t4, 10460
sw $t5, 0($t3)
addi $t3, $t4, 10464
sw $t5, 0($t3)
addi $t3, $t4, 10468
sw $t5, 0($t3)
addi $t3, $t4, 10472
sw $t5, 0($t3)
addi $t3, $t4, 10476
sw $t5, 0($t3)
addi $t3, $t4, 10480
sw $t5, 0($t3)
addi $t3, $t4, 10484
sw $t5, 0($t3)
addi $t3, $t4, 10488
sw $t5, 0($t3)
addi $t3, $t4, 10492
sw $t5, 0($t3)
addi $t3, $t4, 10496
li $t5,0x848484
sw $t5, 0($t3)
addi $t3, $t4, 10500
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 10504
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 10508
li $t5,0x262626
sw $t5, 0($t3)
addi $t3, $t4, 10512
li $t5,0xfcfcfc
sw $t5, 0($t3)
addi $t3, $t4, 10516
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 10520
sw $t5, 0($t3)
addi $t3, $t4, 10524
sw $t5, 0($t3)
addi $t3, $t4, 10528
sw $t5, 0($t3)
addi $t3, $t4, 10532
sw $t5, 0($t3)
addi $t3, $t4, 10536
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 10540
li $t5,0x040404
sw $t5, 0($t3)
addi $t3, $t4, 10544
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 10548
sw $t5, 0($t3)
addi $t3, $t4, 10552
sw $t5, 0($t3)
addi $t3, $t4, 10556
li $t5,0xfdfdfd
sw $t5, 0($t3)
addi $t3, $t4, 10560
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 10564
sw $t5, 0($t3)
addi $t3, $t4, 10568
sw $t5, 0($t3)
addi $t3, $t4, 10572
li $t5,0x131313
sw $t5, 0($t3)
addi $t3, $t4, 10576
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 10580
sw $t5, 0($t3)
addi $t3, $t4, 10584
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 10588
li $t5,0x060606
sw $t5, 0($t3)
addi $t3, $t4, 10592
li $t5,0x1c1c1c
sw $t5, 0($t3)
addi $t3, $t4, 10596
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 10600
li $t5,0xfdfdfd
sw $t5, 0($t3)
addi $t3, $t4, 10604
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 10608
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 10612
sw $t5, 0($t3)
addi $t3, $t4, 10616
sw $t5, 0($t3)
addi $t3, $t4, 10620
sw $t5, 0($t3)
addi $t3, $t4, 10624
li $t5,0x0b0b0b
sw $t5, 0($t3)
addi $t3, $t4, 10628
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 10632
sw $t5, 0($t3)
addi $t3, $t4, 10636
sw $t5, 0($t3)
addi $t3, $t4, 10640
li $t5,0x0b0b0b
sw $t5, 0($t3)
addi $t3, $t4, 10644
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 10648
sw $t5, 0($t3)
addi $t3, $t4, 10652
sw $t5, 0($t3)
addi $t3, $t4, 10656
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 10660
sw $t5, 0($t3)
addi $t3, $t4, 10664
sw $t5, 0($t3)
addi $t3, $t4, 10668
sw $t5, 0($t3)
addi $t3, $t4, 10672
li $t5,0xeaeaea
sw $t5, 0($t3)
addi $t3, $t4, 10676
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 10680
li $t5,0x262626
sw $t5, 0($t3)
addi $t3, $t4, 10684
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 10688
sw $t5, 0($t3)
addi $t3, $t4, 10692
sw $t5, 0($t3)
addi $t3, $t4, 10696
sw $t5, 0($t3)
addi $t3, $t4, 10700
li $t5,0x292929
sw $t5, 0($t3)
addi $t3, $t4, 10704
li $t5,0xf6f6f6
sw $t5, 0($t3)
addi $t3, $t4, 10708
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 10712
sw $t5, 0($t3)
addi $t3, $t4, 10716
li $t5,0xfbfbfb
sw $t5, 0($t3)
addi $t3, $t4, 10720
li $t5,0x040404
sw $t5, 0($t3)
addi $t3, $t4, 10724
li $t5,0x020202
sw $t5, 0($t3)
addi $t3, $t4, 10728
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 10732
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 10736
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 10740
sw $t5, 0($t3)
addi $t3, $t4, 10744
sw $t5, 0($t3)
addi $t3, $t4, 10748
sw $t5, 0($t3)
addi $t3, $t4, 10752
sw $t5, 0($t3)
addi $t3, $t4, 10756
sw $t5, 0($t3)
addi $t3, $t4, 10760
sw $t5, 0($t3)
addi $t3, $t4, 10764
sw $t5, 0($t3)
addi $t3, $t4, 10768
sw $t5, 0($t3)
addi $t3, $t4, 10772
sw $t5, 0($t3)
addi $t3, $t4, 10776
sw $t5, 0($t3)
addi $t3, $t4, 10780
sw $t5, 0($t3)
addi $t3, $t4, 10784
sw $t5, 0($t3)
addi $t3, $t4, 10788
sw $t5, 0($t3)
addi $t3, $t4, 10792
sw $t5, 0($t3)
addi $t3, $t4, 10796
sw $t5, 0($t3)
addi $t3, $t4, 10800
sw $t5, 0($t3)
addi $t3, $t4, 10804
sw $t5, 0($t3)
addi $t3, $t4, 10808
sw $t5, 0($t3)
addi $t3, $t4, 10812
sw $t5, 0($t3)
addi $t3, $t4, 10816
sw $t5, 0($t3)
addi $t3, $t4, 10820
sw $t5, 0($t3)
addi $t3, $t4, 10824
sw $t5, 0($t3)
addi $t3, $t4, 10828
sw $t5, 0($t3)
addi $t3, $t4, 10832
sw $t5, 0($t3)
addi $t3, $t4, 10836
sw $t5, 0($t3)
addi $t3, $t4, 10840
sw $t5, 0($t3)
addi $t3, $t4, 10844
sw $t5, 0($t3)
addi $t3, $t4, 10848
sw $t5, 0($t3)
addi $t3, $t4, 10852
sw $t5, 0($t3)
addi $t3, $t4, 10856
sw $t5, 0($t3)
addi $t3, $t4, 10860
sw $t5, 0($t3)
addi $t3, $t4, 10864
sw $t5, 0($t3)
addi $t3, $t4, 10868
sw $t5, 0($t3)
addi $t3, $t4, 10872
sw $t5, 0($t3)
addi $t3, $t4, 10876
sw $t5, 0($t3)
addi $t3, $t4, 10880
sw $t5, 0($t3)
addi $t3, $t4, 10884
sw $t5, 0($t3)
addi $t3, $t4, 10888
sw $t5, 0($t3)
addi $t3, $t4, 10892
sw $t5, 0($t3)
addi $t3, $t4, 10896
sw $t5, 0($t3)
addi $t3, $t4, 10900
sw $t5, 0($t3)
addi $t3, $t4, 10904
sw $t5, 0($t3)
addi $t3, $t4, 10908
sw $t5, 0($t3)
addi $t3, $t4, 10912
sw $t5, 0($t3)
addi $t3, $t4, 10916
li $t5,0xfffefe
sw $t5, 0($t3)
addi $t3, $t4, 10920
li $t5,0xfefdfd
sw $t5, 0($t3)
addi $t3, $t4, 10924
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 10928
sw $t5, 0($t3)
addi $t3, $t4, 10932
sw $t5, 0($t3)
addi $t3, $t4, 10936
sw $t5, 0($t3)
addi $t3, $t4, 10940
sw $t5, 0($t3)
addi $t3, $t4, 10944
sw $t5, 0($t3)
addi $t3, $t4, 10948
sw $t5, 0($t3)
addi $t3, $t4, 10952
sw $t5, 0($t3)
addi $t3, $t4, 10956
sw $t5, 0($t3)
addi $t3, $t4, 10960
sw $t5, 0($t3)
addi $t3, $t4, 10964
sw $t5, 0($t3)
addi $t3, $t4, 10968
sw $t5, 0($t3)
addi $t3, $t4, 10972
sw $t5, 0($t3)
addi $t3, $t4, 10976
sw $t5, 0($t3)
addi $t3, $t4, 10980
sw $t5, 0($t3)
addi $t3, $t4, 10984
sw $t5, 0($t3)
addi $t3, $t4, 10988
sw $t5, 0($t3)
addi $t3, $t4, 10992
sw $t5, 0($t3)
addi $t3, $t4, 10996
sw $t5, 0($t3)
addi $t3, $t4, 11000
sw $t5, 0($t3)
addi $t3, $t4, 11004
sw $t5, 0($t3)
addi $t3, $t4, 11008
li $t5,0x2f2f2f
sw $t5, 0($t3)
addi $t3, $t4, 11012
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 11016
sw $t5, 0($t3)
addi $t3, $t4, 11020
li $t5,0x020202
sw $t5, 0($t3)
addi $t3, $t4, 11024
li $t5,0xd8d8d8
sw $t5, 0($t3)
addi $t3, $t4, 11028
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 11032
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 11036
sw $t5, 0($t3)
addi $t3, $t4, 11040
sw $t5, 0($t3)
addi $t3, $t4, 11044
sw $t5, 0($t3)
addi $t3, $t4, 11048
li $t5,0xd3d3d3
sw $t5, 0($t3)
addi $t3, $t4, 11052
li $t5,0x030303
sw $t5, 0($t3)
addi $t3, $t4, 11056
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 11060
sw $t5, 0($t3)
addi $t3, $t4, 11064
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 11068
li $t5,0xd0cfcf
sw $t5, 0($t3)
addi $t3, $t4, 11072
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 11076
sw $t5, 0($t3)
addi $t3, $t4, 11080
li $t5,0xfafafa
sw $t5, 0($t3)
addi $t3, $t4, 11084
li $t5,0x020202
sw $t5, 0($t3)
addi $t3, $t4, 11088
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 11092
sw $t5, 0($t3)
addi $t3, $t4, 11096
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 11100
sw $t5, 0($t3)
addi $t3, $t4, 11104
li $t5,0x2e2e2e
sw $t5, 0($t3)
addi $t3, $t4, 11108
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 11112
li $t5,0xf2f2f2
sw $t5, 0($t3)
addi $t3, $t4, 11116
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 11120
sw $t5, 0($t3)
addi $t3, $t4, 11124
sw $t5, 0($t3)
addi $t3, $t4, 11128
sw $t5, 0($t3)
addi $t3, $t4, 11132
sw $t5, 0($t3)
addi $t3, $t4, 11136
li $t5,0x080808
sw $t5, 0($t3)
addi $t3, $t4, 11140
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 11144
sw $t5, 0($t3)
addi $t3, $t4, 11148
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 11152
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 11156
sw $t5, 0($t3)
addi $t3, $t4, 11160
sw $t5, 0($t3)
addi $t3, $t4, 11164
sw $t5, 0($t3)
addi $t3, $t4, 11168
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 11172
sw $t5, 0($t3)
addi $t3, $t4, 11176
sw $t5, 0($t3)
addi $t3, $t4, 11180
sw $t5, 0($t3)
addi $t3, $t4, 11184
li $t5,0xbab9b9
sw $t5, 0($t3)
addi $t3, $t4, 11188
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 11192
li $t5,0x050505
sw $t5, 0($t3)
addi $t3, $t4, 11196
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 11200
sw $t5, 0($t3)
addi $t3, $t4, 11204
sw $t5, 0($t3)
addi $t3, $t4, 11208
sw $t5, 0($t3)
addi $t3, $t4, 11212
li $t5,0x6e6e6e
sw $t5, 0($t3)
addi $t3, $t4, 11216
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 11220
sw $t5, 0($t3)
addi $t3, $t4, 11224
sw $t5, 0($t3)
addi $t3, $t4, 11228
sw $t5, 0($t3)
addi $t3, $t4, 11232
li $t5,0x7e7e7e
sw $t5, 0($t3)
addi $t3, $t4, 11236
li $t5,0x020202
sw $t5, 0($t3)
addi $t3, $t4, 11240
li $t5,0x3c3c3c
sw $t5, 0($t3)
addi $t3, $t4, 11244
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 11248
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 11252
sw $t5, 0($t3)
addi $t3, $t4, 11256
sw $t5, 0($t3)
addi $t3, $t4, 11260
sw $t5, 0($t3)
addi $t3, $t4, 11264
sw $t5, 0($t3)
addi $t3, $t4, 11268
sw $t5, 0($t3)
addi $t3, $t4, 11272
sw $t5, 0($t3)
addi $t3, $t4, 11276
sw $t5, 0($t3)
addi $t3, $t4, 11280
sw $t5, 0($t3)
addi $t3, $t4, 11284
sw $t5, 0($t3)
addi $t3, $t4, 11288
sw $t5, 0($t3)
addi $t3, $t4, 11292
sw $t5, 0($t3)
addi $t3, $t4, 11296
sw $t5, 0($t3)
addi $t3, $t4, 11300
sw $t5, 0($t3)
addi $t3, $t4, 11304
sw $t5, 0($t3)
addi $t3, $t4, 11308
sw $t5, 0($t3)
addi $t3, $t4, 11312
sw $t5, 0($t3)
addi $t3, $t4, 11316
sw $t5, 0($t3)
addi $t3, $t4, 11320
sw $t5, 0($t3)
addi $t3, $t4, 11324
sw $t5, 0($t3)
addi $t3, $t4, 11328
sw $t5, 0($t3)
addi $t3, $t4, 11332
sw $t5, 0($t3)
addi $t3, $t4, 11336
sw $t5, 0($t3)
addi $t3, $t4, 11340
sw $t5, 0($t3)
addi $t3, $t4, 11344
sw $t5, 0($t3)
addi $t3, $t4, 11348
sw $t5, 0($t3)
addi $t3, $t4, 11352
sw $t5, 0($t3)
addi $t3, $t4, 11356
sw $t5, 0($t3)
addi $t3, $t4, 11360
sw $t5, 0($t3)
addi $t3, $t4, 11364
sw $t5, 0($t3)
addi $t3, $t4, 11368
sw $t5, 0($t3)
addi $t3, $t4, 11372
sw $t5, 0($t3)
addi $t3, $t4, 11376
sw $t5, 0($t3)
addi $t3, $t4, 11380
sw $t5, 0($t3)
addi $t3, $t4, 11384
sw $t5, 0($t3)
addi $t3, $t4, 11388
sw $t5, 0($t3)
addi $t3, $t4, 11392
sw $t5, 0($t3)
addi $t3, $t4, 11396
sw $t5, 0($t3)
addi $t3, $t4, 11400
sw $t5, 0($t3)
addi $t3, $t4, 11404
sw $t5, 0($t3)
addi $t3, $t4, 11408
sw $t5, 0($t3)
addi $t3, $t4, 11412
sw $t5, 0($t3)
addi $t3, $t4, 11416
sw $t5, 0($t3)
addi $t3, $t4, 11420
sw $t5, 0($t3)
addi $t3, $t4, 11424
sw $t5, 0($t3)
addi $t3, $t4, 11428
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 11432
li $t5,0x393939
sw $t5, 0($t3)
addi $t3, $t4, 11436
li $t5,0xf9f9f9
sw $t5, 0($t3)
addi $t3, $t4, 11440
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 11444
sw $t5, 0($t3)
addi $t3, $t4, 11448
sw $t5, 0($t3)
addi $t3, $t4, 11452
sw $t5, 0($t3)
addi $t3, $t4, 11456
sw $t5, 0($t3)
addi $t3, $t4, 11460
sw $t5, 0($t3)
addi $t3, $t4, 11464
sw $t5, 0($t3)
addi $t3, $t4, 11468
sw $t5, 0($t3)
addi $t3, $t4, 11472
sw $t5, 0($t3)
addi $t3, $t4, 11476
sw $t5, 0($t3)
addi $t3, $t4, 11480
sw $t5, 0($t3)
addi $t3, $t4, 11484
sw $t5, 0($t3)
addi $t3, $t4, 11488
sw $t5, 0($t3)
addi $t3, $t4, 11492
sw $t5, 0($t3)
addi $t3, $t4, 11496
sw $t5, 0($t3)
addi $t3, $t4, 11500
sw $t5, 0($t3)
addi $t3, $t4, 11504
sw $t5, 0($t3)
addi $t3, $t4, 11508
sw $t5, 0($t3)
addi $t3, $t4, 11512
sw $t5, 0($t3)
addi $t3, $t4, 11516
sw $t5, 0($t3)
addi $t3, $t4, 11520
li $t5,0x090909
sw $t5, 0($t3)
addi $t3, $t4, 11524
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 11528
sw $t5, 0($t3)
addi $t3, $t4, 11532
sw $t5, 0($t3)
addi $t3, $t4, 11536
li $t5,0x353534
sw $t5, 0($t3)
addi $t3, $t4, 11540
li $t5,0xfcfcfc
sw $t5, 0($t3)
addi $t3, $t4, 11544
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 11548
sw $t5, 0($t3)
addi $t3, $t4, 11552
sw $t5, 0($t3)
addi $t3, $t4, 11556
sw $t5, 0($t3)
addi $t3, $t4, 11560
li $t5,0x434343
sw $t5, 0($t3)
addi $t3, $t4, 11564
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 11568
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 11572
sw $t5, 0($t3)
addi $t3, $t4, 11576
sw $t5, 0($t3)
addi $t3, $t4, 11580
li $t5,0x474747
sw $t5, 0($t3)
addi $t3, $t4, 11584
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 11588
sw $t5, 0($t3)
addi $t3, $t4, 11592
li $t5,0xdcdcdc
sw $t5, 0($t3)
addi $t3, $t4, 11596
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 11600
sw $t5, 0($t3)
addi $t3, $t4, 11604
sw $t5, 0($t3)
addi $t3, $t4, 11608
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 11612
sw $t5, 0($t3)
addi $t3, $t4, 11616
li $t5,0x888888
sw $t5, 0($t3)
addi $t3, $t4, 11620
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 11624
li $t5,0x9a9a9a
sw $t5, 0($t3)
addi $t3, $t4, 11628
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 11632
sw $t5, 0($t3)
addi $t3, $t4, 11636
sw $t5, 0($t3)
addi $t3, $t4, 11640
sw $t5, 0($t3)
addi $t3, $t4, 11644
sw $t5, 0($t3)
addi $t3, $t4, 11648
li $t5,0x535353
sw $t5, 0($t3)
addi $t3, $t4, 11652
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 11656
sw $t5, 0($t3)
addi $t3, $t4, 11660
li $t5,0xf0f0f0
sw $t5, 0($t3)
addi $t3, $t4, 11664
li $t5,0x040404
sw $t5, 0($t3)
addi $t3, $t4, 11668
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 11672
sw $t5, 0($t3)
addi $t3, $t4, 11676
sw $t5, 0($t3)
addi $t3, $t4, 11680
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 11684
sw $t5, 0($t3)
addi $t3, $t4, 11688
sw $t5, 0($t3)
addi $t3, $t4, 11692
sw $t5, 0($t3)
addi $t3, $t4, 11696
li $t5,0x505050
sw $t5, 0($t3)
addi $t3, $t4, 11700
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 11704
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 11708
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 11712
sw $t5, 0($t3)
addi $t3, $t4, 11716
sw $t5, 0($t3)
addi $t3, $t4, 11720
sw $t5, 0($t3)
addi $t3, $t4, 11724
li $t5,0xbbbbbb
sw $t5, 0($t3)
addi $t3, $t4, 11728
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 11732
sw $t5, 0($t3)
addi $t3, $t4, 11736
sw $t5, 0($t3)
addi $t3, $t4, 11740
sw $t5, 0($t3)
addi $t3, $t4, 11744
li $t5,0xf8f8f8
sw $t5, 0($t3)
addi $t3, $t4, 11748
li $t5,0x9d9d9d
sw $t5, 0($t3)
addi $t3, $t4, 11752
li $t5,0xb4b4b4
sw $t5, 0($t3)
addi $t3, $t4, 11756
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 11760
sw $t5, 0($t3)
addi $t3, $t4, 11764
sw $t5, 0($t3)
addi $t3, $t4, 11768
sw $t5, 0($t3)
addi $t3, $t4, 11772
sw $t5, 0($t3)
addi $t3, $t4, 11776
sw $t5, 0($t3)
addi $t3, $t4, 11780
sw $t5, 0($t3)
addi $t3, $t4, 11784
sw $t5, 0($t3)
addi $t3, $t4, 11788
sw $t5, 0($t3)
addi $t3, $t4, 11792
sw $t5, 0($t3)
addi $t3, $t4, 11796
sw $t5, 0($t3)
addi $t3, $t4, 11800
sw $t5, 0($t3)
addi $t3, $t4, 11804
sw $t5, 0($t3)
addi $t3, $t4, 11808
sw $t5, 0($t3)
addi $t3, $t4, 11812
sw $t5, 0($t3)
addi $t3, $t4, 11816
sw $t5, 0($t3)
addi $t3, $t4, 11820
sw $t5, 0($t3)
addi $t3, $t4, 11824
sw $t5, 0($t3)
addi $t3, $t4, 11828
sw $t5, 0($t3)
addi $t3, $t4, 11832
sw $t5, 0($t3)
addi $t3, $t4, 11836
sw $t5, 0($t3)
addi $t3, $t4, 11840
sw $t5, 0($t3)
addi $t3, $t4, 11844
sw $t5, 0($t3)
addi $t3, $t4, 11848
sw $t5, 0($t3)
addi $t3, $t4, 11852
sw $t5, 0($t3)
addi $t3, $t4, 11856
sw $t5, 0($t3)
addi $t3, $t4, 11860
sw $t5, 0($t3)
addi $t3, $t4, 11864
sw $t5, 0($t3)
addi $t3, $t4, 11868
sw $t5, 0($t3)
addi $t3, $t4, 11872
sw $t5, 0($t3)
addi $t3, $t4, 11876
sw $t5, 0($t3)
addi $t3, $t4, 11880
sw $t5, 0($t3)
addi $t3, $t4, 11884
sw $t5, 0($t3)
addi $t3, $t4, 11888
sw $t5, 0($t3)
addi $t3, $t4, 11892
sw $t5, 0($t3)
addi $t3, $t4, 11896
sw $t5, 0($t3)
addi $t3, $t4, 11900
sw $t5, 0($t3)
addi $t3, $t4, 11904
sw $t5, 0($t3)
addi $t3, $t4, 11908
sw $t5, 0($t3)
addi $t3, $t4, 11912
sw $t5, 0($t3)
addi $t3, $t4, 11916
sw $t5, 0($t3)
addi $t3, $t4, 11920
sw $t5, 0($t3)
addi $t3, $t4, 11924
sw $t5, 0($t3)
addi $t3, $t4, 11928
sw $t5, 0($t3)
addi $t3, $t4, 11932
sw $t5, 0($t3)
addi $t3, $t4, 11936
sw $t5, 0($t3)
addi $t3, $t4, 11940
li $t5,0xa9a9a9
sw $t5, 0($t3)
addi $t3, $t4, 11944
li $t5,0x020202
sw $t5, 0($t3)
addi $t3, $t4, 11948
li $t5,0x2f2f2f
sw $t5, 0($t3)
addi $t3, $t4, 11952
li $t5,0xfdfdfd
sw $t5, 0($t3)
addi $t3, $t4, 11956
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 11960
sw $t5, 0($t3)
addi $t3, $t4, 11964
sw $t5, 0($t3)
addi $t3, $t4, 11968
sw $t5, 0($t3)
addi $t3, $t4, 11972
sw $t5, 0($t3)
addi $t3, $t4, 11976
sw $t5, 0($t3)
addi $t3, $t4, 11980
sw $t5, 0($t3)
addi $t3, $t4, 11984
li $t5,0x0c0c0c
sw $t5, 0($t3)
addi $t3, $t4, 11988
li $t5,0xe4e4e4
sw $t5, 0($t3)
addi $t3, $t4, 11992
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 11996
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 12000
sw $t5, 0($t3)
addi $t3, $t4, 12004
sw $t5, 0($t3)
addi $t3, $t4, 12008
sw $t5, 0($t3)
addi $t3, $t4, 12012
sw $t5, 0($t3)
addi $t3, $t4, 12016
sw $t5, 0($t3)
addi $t3, $t4, 12020
sw $t5, 0($t3)
addi $t3, $t4, 12024
sw $t5, 0($t3)
addi $t3, $t4, 12028
sw $t5, 0($t3)
addi $t3, $t4, 12032
li $t5,0x050505
sw $t5, 0($t3)
addi $t3, $t4, 12036
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 12040
sw $t5, 0($t3)
addi $t3, $t4, 12044
sw $t5, 0($t3)
addi $t3, $t4, 12048
li $t5,0x0d0d0d
sw $t5, 0($t3)
addi $t3, $t4, 12052
li $t5,0xfdfdfd
sw $t5, 0($t3)
addi $t3, $t4, 12056
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 12060
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 12064
sw $t5, 0($t3)
addi $t3, $t4, 12068
li $t5,0xfdfdfd
sw $t5, 0($t3)
addi $t3, $t4, 12072
li $t5,0x020202
sw $t5, 0($t3)
addi $t3, $t4, 12076
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 12080
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 12084
sw $t5, 0($t3)
addi $t3, $t4, 12088
sw $t5, 0($t3)
addi $t3, $t4, 12092
li $t5,0x131313
sw $t5, 0($t3)
addi $t3, $t4, 12096
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 12100
sw $t5, 0($t3)
addi $t3, $t4, 12104
li $t5,0x949494
sw $t5, 0($t3)
addi $t3, $t4, 12108
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 12112
sw $t5, 0($t3)
addi $t3, $t4, 12116
sw $t5, 0($t3)
addi $t3, $t4, 12120
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 12124
sw $t5, 0($t3)
addi $t3, $t4, 12128
li $t5,0xfbfbfb
sw $t5, 0($t3)
addi $t3, $t4, 12132
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 12136
li $t5,0x2d2d2d
sw $t5, 0($t3)
addi $t3, $t4, 12140
li $t5,0x020202
sw $t5, 0($t3)
addi $t3, $t4, 12144
li $t5,0x323232
sw $t5, 0($t3)
addi $t3, $t4, 12148
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 12152
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 12156
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 12160
li $t5,0x585858
sw $t5, 0($t3)
addi $t3, $t4, 12164
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 12168
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 12172
li $t5,0xaaaaaa
sw $t5, 0($t3)
addi $t3, $t4, 12176
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 12180
sw $t5, 0($t3)
addi $t3, $t4, 12184
sw $t5, 0($t3)
addi $t3, $t4, 12188
sw $t5, 0($t3)
addi $t3, $t4, 12192
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 12196
sw $t5, 0($t3)
addi $t3, $t4, 12200
sw $t5, 0($t3)
addi $t3, $t4, 12204
sw $t5, 0($t3)
addi $t3, $t4, 12208
li $t5,0x121212
sw $t5, 0($t3)
addi $t3, $t4, 12212
li $t5,0xfafafa
sw $t5, 0($t3)
addi $t3, $t4, 12216
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 12220
sw $t5, 0($t3)
addi $t3, $t4, 12224
sw $t5, 0($t3)
addi $t3, $t4, 12228
sw $t5, 0($t3)
addi $t3, $t4, 12232
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 12236
li $t5,0xfcfcfc
sw $t5, 0($t3)
addi $t3, $t4, 12240
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 12244
sw $t5, 0($t3)
addi $t3, $t4, 12248
sw $t5, 0($t3)
addi $t3, $t4, 12252
sw $t5, 0($t3)
addi $t3, $t4, 12256
sw $t5, 0($t3)
addi $t3, $t4, 12260
sw $t5, 0($t3)
addi $t3, $t4, 12264
li $t5,0xfffffe
sw $t5, 0($t3)
addi $t3, $t4, 12268
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 12272
sw $t5, 0($t3)
addi $t3, $t4, 12276
sw $t5, 0($t3)
addi $t3, $t4, 12280
sw $t5, 0($t3)
addi $t3, $t4, 12284
sw $t5, 0($t3)
addi $t3, $t4, 12288
sw $t5, 0($t3)
addi $t3, $t4, 12292
sw $t5, 0($t3)
addi $t3, $t4, 12296
sw $t5, 0($t3)
addi $t3, $t4, 12300
sw $t5, 0($t3)
addi $t3, $t4, 12304
sw $t5, 0($t3)
addi $t3, $t4, 12308
sw $t5, 0($t3)
addi $t3, $t4, 12312
sw $t5, 0($t3)
addi $t3, $t4, 12316
sw $t5, 0($t3)
addi $t3, $t4, 12320
sw $t5, 0($t3)
addi $t3, $t4, 12324
sw $t5, 0($t3)
addi $t3, $t4, 12328
sw $t5, 0($t3)
addi $t3, $t4, 12332
sw $t5, 0($t3)
addi $t3, $t4, 12336
sw $t5, 0($t3)
addi $t3, $t4, 12340
sw $t5, 0($t3)
addi $t3, $t4, 12344
sw $t5, 0($t3)
addi $t3, $t4, 12348
sw $t5, 0($t3)
addi $t3, $t4, 12352
sw $t5, 0($t3)
addi $t3, $t4, 12356
sw $t5, 0($t3)
addi $t3, $t4, 12360
sw $t5, 0($t3)
addi $t3, $t4, 12364
sw $t5, 0($t3)
addi $t3, $t4, 12368
sw $t5, 0($t3)
addi $t3, $t4, 12372
sw $t5, 0($t3)
addi $t3, $t4, 12376
sw $t5, 0($t3)
addi $t3, $t4, 12380
sw $t5, 0($t3)
addi $t3, $t4, 12384
sw $t5, 0($t3)
addi $t3, $t4, 12388
sw $t5, 0($t3)
addi $t3, $t4, 12392
sw $t5, 0($t3)
addi $t3, $t4, 12396
sw $t5, 0($t3)
addi $t3, $t4, 12400
sw $t5, 0($t3)
addi $t3, $t4, 12404
sw $t5, 0($t3)
addi $t3, $t4, 12408
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 12412
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 12416
sw $t5, 0($t3)
addi $t3, $t4, 12420
sw $t5, 0($t3)
addi $t3, $t4, 12424
sw $t5, 0($t3)
addi $t3, $t4, 12428
sw $t5, 0($t3)
addi $t3, $t4, 12432
sw $t5, 0($t3)
addi $t3, $t4, 12436
sw $t5, 0($t3)
addi $t3, $t4, 12440
sw $t5, 0($t3)
addi $t3, $t4, 12444
sw $t5, 0($t3)
addi $t3, $t4, 12448
li $t5,0xfdfdfd
sw $t5, 0($t3)
addi $t3, $t4, 12452
li $t5,0x040404
sw $t5, 0($t3)
addi $t3, $t4, 12456
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 12460
li $t5,0x020202
sw $t5, 0($t3)
addi $t3, $t4, 12464
li $t5,0xebebeb
sw $t5, 0($t3)
addi $t3, $t4, 12468
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 12472
sw $t5, 0($t3)
addi $t3, $t4, 12476
sw $t5, 0($t3)
addi $t3, $t4, 12480
sw $t5, 0($t3)
addi $t3, $t4, 12484
sw $t5, 0($t3)
addi $t3, $t4, 12488
sw $t5, 0($t3)
addi $t3, $t4, 12492
sw $t5, 0($t3)
addi $t3, $t4, 12496
li $t5,0x030303
sw $t5, 0($t3)
addi $t3, $t4, 12500
li $t5,0x090909
sw $t5, 0($t3)
addi $t3, $t4, 12504
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 12508
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 12512
sw $t5, 0($t3)
addi $t3, $t4, 12516
sw $t5, 0($t3)
addi $t3, $t4, 12520
sw $t5, 0($t3)
addi $t3, $t4, 12524
sw $t5, 0($t3)
addi $t3, $t4, 12528
sw $t5, 0($t3)
addi $t3, $t4, 12532
sw $t5, 0($t3)
addi $t3, $t4, 12536
sw $t5, 0($t3)
addi $t3, $t4, 12540
sw $t5, 0($t3)
addi $t3, $t4, 12544
li $t5,0x020202
sw $t5, 0($t3)
addi $t3, $t4, 12548
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 12552
sw $t5, 0($t3)
addi $t3, $t4, 12556
sw $t5, 0($t3)
addi $t3, $t4, 12560
sw $t5, 0($t3)
addi $t3, $t4, 12564
li $t5,0xfdfdfd
sw $t5, 0($t3)
addi $t3, $t4, 12568
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 12572
sw $t5, 0($t3)
addi $t3, $t4, 12576
sw $t5, 0($t3)
addi $t3, $t4, 12580
li $t5,0xd3d3d3
sw $t5, 0($t3)
addi $t3, $t4, 12584
li $t5,0x030303
sw $t5, 0($t3)
addi $t3, $t4, 12588
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 12592
sw $t5, 0($t3)
addi $t3, $t4, 12596
sw $t5, 0($t3)
addi $t3, $t4, 12600
sw $t5, 0($t3)
addi $t3, $t4, 12604
li $t5,0x020202
sw $t5, 0($t3)
addi $t3, $t4, 12608
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 12612
sw $t5, 0($t3)
addi $t3, $t4, 12616
li $t5,0x0a0a0a
sw $t5, 0($t3)
addi $t3, $t4, 12620
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 12624
sw $t5, 0($t3)
addi $t3, $t4, 12628
sw $t5, 0($t3)
addi $t3, $t4, 12632
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 12636
li $t5,0x0a0a0a
sw $t5, 0($t3)
addi $t3, $t4, 12640
li $t5,0xfbfbfb
sw $t5, 0($t3)
addi $t3, $t4, 12644
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 12648
li $t5,0x121212
sw $t5, 0($t3)
addi $t3, $t4, 12652
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 12656
li $t5,0x333333
sw $t5, 0($t3)
addi $t3, $t4, 12660
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 12664
sw $t5, 0($t3)
addi $t3, $t4, 12668
li $t5,0x040404
sw $t5, 0($t3)
addi $t3, $t4, 12672
li $t5,0xaeadad
sw $t5, 0($t3)
addi $t3, $t4, 12676
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 12680
sw $t5, 0($t3)
addi $t3, $t4, 12684
li $t5,0x515151
sw $t5, 0($t3)
addi $t3, $t4, 12688
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 12692
sw $t5, 0($t3)
addi $t3, $t4, 12696
sw $t5, 0($t3)
addi $t3, $t4, 12700
sw $t5, 0($t3)
addi $t3, $t4, 12704
li $t5,0x020202
sw $t5, 0($t3)
addi $t3, $t4, 12708
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 12712
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 12716
sw $t5, 0($t3)
addi $t3, $t4, 12720
li $t5,0x020202
sw $t5, 0($t3)
addi $t3, $t4, 12724
li $t5,0xf5f4f4
sw $t5, 0($t3)
addi $t3, $t4, 12728
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 12732
sw $t5, 0($t3)
addi $t3, $t4, 12736
sw $t5, 0($t3)
addi $t3, $t4, 12740
sw $t5, 0($t3)
addi $t3, $t4, 12744
li $t5,0x050505
sw $t5, 0($t3)
addi $t3, $t4, 12748
li $t5,0xcccccc
sw $t5, 0($t3)
addi $t3, $t4, 12752
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 12756
sw $t5, 0($t3)
addi $t3, $t4, 12760
sw $t5, 0($t3)
addi $t3, $t4, 12764
sw $t5, 0($t3)
addi $t3, $t4, 12768
sw $t5, 0($t3)
addi $t3, $t4, 12772
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 12776
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 12780
sw $t5, 0($t3)
addi $t3, $t4, 12784
sw $t5, 0($t3)
addi $t3, $t4, 12788
sw $t5, 0($t3)
addi $t3, $t4, 12792
sw $t5, 0($t3)
addi $t3, $t4, 12796
sw $t5, 0($t3)
addi $t3, $t4, 12800
sw $t5, 0($t3)
addi $t3, $t4, 12804
sw $t5, 0($t3)
addi $t3, $t4, 12808
sw $t5, 0($t3)
addi $t3, $t4, 12812
sw $t5, 0($t3)
addi $t3, $t4, 12816
sw $t5, 0($t3)
addi $t3, $t4, 12820
sw $t5, 0($t3)
addi $t3, $t4, 12824
sw $t5, 0($t3)
addi $t3, $t4, 12828
sw $t5, 0($t3)
addi $t3, $t4, 12832
sw $t5, 0($t3)
addi $t3, $t4, 12836
sw $t5, 0($t3)
addi $t3, $t4, 12840
sw $t5, 0($t3)
addi $t3, $t4, 12844
sw $t5, 0($t3)
addi $t3, $t4, 12848
sw $t5, 0($t3)
addi $t3, $t4, 12852
sw $t5, 0($t3)
addi $t3, $t4, 12856
sw $t5, 0($t3)
addi $t3, $t4, 12860
sw $t5, 0($t3)
addi $t3, $t4, 12864
sw $t5, 0($t3)
addi $t3, $t4, 12868
sw $t5, 0($t3)
addi $t3, $t4, 12872
sw $t5, 0($t3)
addi $t3, $t4, 12876
sw $t5, 0($t3)
addi $t3, $t4, 12880
sw $t5, 0($t3)
addi $t3, $t4, 12884
sw $t5, 0($t3)
addi $t3, $t4, 12888
sw $t5, 0($t3)
addi $t3, $t4, 12892
sw $t5, 0($t3)
addi $t3, $t4, 12896
sw $t5, 0($t3)
addi $t3, $t4, 12900
sw $t5, 0($t3)
addi $t3, $t4, 12904
sw $t5, 0($t3)
addi $t3, $t4, 12908
sw $t5, 0($t3)
addi $t3, $t4, 12912
sw $t5, 0($t3)
addi $t3, $t4, 12916
li $t5,0xc9c9c9
sw $t5, 0($t3)
addi $t3, $t4, 12920
li $t5,0x585858
sw $t5, 0($t3)
addi $t3, $t4, 12924
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 12928
li $t5,0xfbfbfb
sw $t5, 0($t3)
addi $t3, $t4, 12932
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 12936
sw $t5, 0($t3)
addi $t3, $t4, 12940
sw $t5, 0($t3)
addi $t3, $t4, 12944
sw $t5, 0($t3)
addi $t3, $t4, 12948
sw $t5, 0($t3)
addi $t3, $t4, 12952
sw $t5, 0($t3)
addi $t3, $t4, 12956
sw $t5, 0($t3)
addi $t3, $t4, 12960
li $t5,0xf6f6f6
sw $t5, 0($t3)
addi $t3, $t4, 12964
li $t5,0x020202
sw $t5, 0($t3)
addi $t3, $t4, 12968
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 12972
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 12976
li $t5,0x797979
sw $t5, 0($t3)
addi $t3, $t4, 12980
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 12984
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 12988
sw $t5, 0($t3)
addi $t3, $t4, 12992
sw $t5, 0($t3)
addi $t3, $t4, 12996
sw $t5, 0($t3)
addi $t3, $t4, 13000
sw $t5, 0($t3)
addi $t3, $t4, 13004
li $t5,0xfbfbfb
sw $t5, 0($t3)
addi $t3, $t4, 13008
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 13012
li $t5,0x030303
sw $t5, 0($t3)
addi $t3, $t4, 13016
li $t5,0xebebeb
sw $t5, 0($t3)
addi $t3, $t4, 13020
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 13024
sw $t5, 0($t3)
addi $t3, $t4, 13028
sw $t5, 0($t3)
addi $t3, $t4, 13032
sw $t5, 0($t3)
addi $t3, $t4, 13036
sw $t5, 0($t3)
addi $t3, $t4, 13040
sw $t5, 0($t3)
addi $t3, $t4, 13044
sw $t5, 0($t3)
addi $t3, $t4, 13048
sw $t5, 0($t3)
addi $t3, $t4, 13052
sw $t5, 0($t3)
addi $t3, $t4, 13056
li $t5,0x030303
sw $t5, 0($t3)
addi $t3, $t4, 13060
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 13064
sw $t5, 0($t3)
addi $t3, $t4, 13068
sw $t5, 0($t3)
addi $t3, $t4, 13072
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 13076
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 13080
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 13084
sw $t5, 0($t3)
addi $t3, $t4, 13088
sw $t5, 0($t3)
addi $t3, $t4, 13092
li $t5,0x323232
sw $t5, 0($t3)
addi $t3, $t4, 13096
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 13100
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 13104
sw $t5, 0($t3)
addi $t3, $t4, 13108
sw $t5, 0($t3)
addi $t3, $t4, 13112
sw $t5, 0($t3)
addi $t3, $t4, 13116
li $t5,0x050505
sw $t5, 0($t3)
addi $t3, $t4, 13120
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 13124
li $t5,0xfbfbfb
sw $t5, 0($t3)
addi $t3, $t4, 13128
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 13132
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 13136
sw $t5, 0($t3)
addi $t3, $t4, 13140
sw $t5, 0($t3)
addi $t3, $t4, 13144
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 13148
li $t5,0x040404
sw $t5, 0($t3)
addi $t3, $t4, 13152
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 13156
sw $t5, 0($t3)
addi $t3, $t4, 13160
li $t5,0x050505
sw $t5, 0($t3)
addi $t3, $t4, 13164
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 13168
li $t5,0x040404
sw $t5, 0($t3)
addi $t3, $t4, 13172
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 13176
sw $t5, 0($t3)
addi $t3, $t4, 13180
li $t5,0x5c5c5c
sw $t5, 0($t3)
addi $t3, $t4, 13184
li $t5,0xededed
sw $t5, 0($t3)
addi $t3, $t4, 13188
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 13192
li $t5,0xfcfcfc
sw $t5, 0($t3)
addi $t3, $t4, 13196
li $t5,0x1e1e1e
sw $t5, 0($t3)
addi $t3, $t4, 13200
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 13204
sw $t5, 0($t3)
addi $t3, $t4, 13208
sw $t5, 0($t3)
addi $t3, $t4, 13212
sw $t5, 0($t3)
addi $t3, $t4, 13216
li $t5,0x1d1d1d
sw $t5, 0($t3)
addi $t3, $t4, 13220
li $t5,0x020202
sw $t5, 0($t3)
addi $t3, $t4, 13224
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 13228
sw $t5, 0($t3)
addi $t3, $t4, 13232
sw $t5, 0($t3)
addi $t3, $t4, 13236
li $t5,0xd8d8d8
sw $t5, 0($t3)
addi $t3, $t4, 13240
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 13244
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 13248
sw $t5, 0($t3)
addi $t3, $t4, 13252
sw $t5, 0($t3)
addi $t3, $t4, 13256
li $t5,0x020202
sw $t5, 0($t3)
addi $t3, $t4, 13260
li $t5,0xf9f9f9
sw $t5, 0($t3)
addi $t3, $t4, 13264
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 13268
sw $t5, 0($t3)
addi $t3, $t4, 13272
sw $t5, 0($t3)
addi $t3, $t4, 13276
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 13280
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 13284
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 13288
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 13292
sw $t5, 0($t3)
addi $t3, $t4, 13296
sw $t5, 0($t3)
addi $t3, $t4, 13300
sw $t5, 0($t3)
addi $t3, $t4, 13304
sw $t5, 0($t3)
addi $t3, $t4, 13308
sw $t5, 0($t3)
addi $t3, $t4, 13312
sw $t5, 0($t3)
addi $t3, $t4, 13316
sw $t5, 0($t3)
addi $t3, $t4, 13320
sw $t5, 0($t3)
addi $t3, $t4, 13324
sw $t5, 0($t3)
addi $t3, $t4, 13328
sw $t5, 0($t3)
addi $t3, $t4, 13332
sw $t5, 0($t3)
addi $t3, $t4, 13336
sw $t5, 0($t3)
addi $t3, $t4, 13340
sw $t5, 0($t3)
addi $t3, $t4, 13344
sw $t5, 0($t3)
addi $t3, $t4, 13348
sw $t5, 0($t3)
addi $t3, $t4, 13352
sw $t5, 0($t3)
addi $t3, $t4, 13356
sw $t5, 0($t3)
addi $t3, $t4, 13360
sw $t5, 0($t3)
addi $t3, $t4, 13364
sw $t5, 0($t3)
addi $t3, $t4, 13368
sw $t5, 0($t3)
addi $t3, $t4, 13372
sw $t5, 0($t3)
addi $t3, $t4, 13376
sw $t5, 0($t3)
addi $t3, $t4, 13380
sw $t5, 0($t3)
addi $t3, $t4, 13384
sw $t5, 0($t3)
addi $t3, $t4, 13388
sw $t5, 0($t3)
addi $t3, $t4, 13392
sw $t5, 0($t3)
addi $t3, $t4, 13396
sw $t5, 0($t3)
addi $t3, $t4, 13400
sw $t5, 0($t3)
addi $t3, $t4, 13404
sw $t5, 0($t3)
addi $t3, $t4, 13408
sw $t5, 0($t3)
addi $t3, $t4, 13412
sw $t5, 0($t3)
addi $t3, $t4, 13416
sw $t5, 0($t3)
addi $t3, $t4, 13420
sw $t5, 0($t3)
addi $t3, $t4, 13424
li $t5,0x898989
sw $t5, 0($t3)
addi $t3, $t4, 13428
li $t5,0x040404
sw $t5, 0($t3)
addi $t3, $t4, 13432
li $t5,0x828282
sw $t5, 0($t3)
addi $t3, $t4, 13436
li $t5,0x373737
sw $t5, 0($t3)
addi $t3, $t4, 13440
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 13444
li $t5,0x7e7e7e
sw $t5, 0($t3)
addi $t3, $t4, 13448
li $t5,0xfdfdfd
sw $t5, 0($t3)
addi $t3, $t4, 13452
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 13456
sw $t5, 0($t3)
addi $t3, $t4, 13460
sw $t5, 0($t3)
addi $t3, $t4, 13464
sw $t5, 0($t3)
addi $t3, $t4, 13468
sw $t5, 0($t3)
addi $t3, $t4, 13472
li $t5,0xcecece
sw $t5, 0($t3)
addi $t3, $t4, 13476
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 13480
sw $t5, 0($t3)
addi $t3, $t4, 13484
sw $t5, 0($t3)
addi $t3, $t4, 13488
li $t5,0x535353
sw $t5, 0($t3)
addi $t3, $t4, 13492
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 13496
sw $t5, 0($t3)
addi $t3, $t4, 13500
sw $t5, 0($t3)
addi $t3, $t4, 13504
sw $t5, 0($t3)
addi $t3, $t4, 13508
sw $t5, 0($t3)
addi $t3, $t4, 13512
sw $t5, 0($t3)
addi $t3, $t4, 13516
li $t5,0xc4c4c4
sw $t5, 0($t3)
addi $t3, $t4, 13520
li $t5,0x020202
sw $t5, 0($t3)
addi $t3, $t4, 13524
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 13528
li $t5,0xe2e2e2
sw $t5, 0($t3)
addi $t3, $t4, 13532
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 13536
sw $t5, 0($t3)
addi $t3, $t4, 13540
sw $t5, 0($t3)
addi $t3, $t4, 13544
sw $t5, 0($t3)
addi $t3, $t4, 13548
sw $t5, 0($t3)
addi $t3, $t4, 13552
sw $t5, 0($t3)
addi $t3, $t4, 13556
sw $t5, 0($t3)
addi $t3, $t4, 13560
sw $t5, 0($t3)
addi $t3, $t4, 13564
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 13568
li $t5,0x020202
sw $t5, 0($t3)
addi $t3, $t4, 13572
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 13576
sw $t5, 0($t3)
addi $t3, $t4, 13580
sw $t5, 0($t3)
addi $t3, $t4, 13584
li $t5,0x020202
sw $t5, 0($t3)
addi $t3, $t4, 13588
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 13592
sw $t5, 0($t3)
addi $t3, $t4, 13596
sw $t5, 0($t3)
addi $t3, $t4, 13600
li $t5,0xfdfdfd
sw $t5, 0($t3)
addi $t3, $t4, 13604
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 13608
sw $t5, 0($t3)
addi $t3, $t4, 13612
sw $t5, 0($t3)
addi $t3, $t4, 13616
sw $t5, 0($t3)
addi $t3, $t4, 13620
sw $t5, 0($t3)
addi $t3, $t4, 13624
sw $t5, 0($t3)
addi $t3, $t4, 13628
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 13632
li $t5,0xededed
sw $t5, 0($t3)
addi $t3, $t4, 13636
li $t5,0xebebeb
sw $t5, 0($t3)
addi $t3, $t4, 13640
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 13644
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 13648
sw $t5, 0($t3)
addi $t3, $t4, 13652
sw $t5, 0($t3)
addi $t3, $t4, 13656
sw $t5, 0($t3)
addi $t3, $t4, 13660
li $t5,0xa4a4a4
sw $t5, 0($t3)
addi $t3, $t4, 13664
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 13668
li $t5,0xd3d3d3
sw $t5, 0($t3)
addi $t3, $t4, 13672
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 13676
sw $t5, 0($t3)
addi $t3, $t4, 13680
sw $t5, 0($t3)
addi $t3, $t4, 13684
sw $t5, 0($t3)
addi $t3, $t4, 13688
sw $t5, 0($t3)
addi $t3, $t4, 13692
li $t5,0x6f6f6f
sw $t5, 0($t3)
addi $t3, $t4, 13696
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 13700
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 13704
sw $t5, 0($t3)
addi $t3, $t4, 13708
li $t5,0x090909
sw $t5, 0($t3)
addi $t3, $t4, 13712
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 13716
sw $t5, 0($t3)
addi $t3, $t4, 13720
sw $t5, 0($t3)
addi $t3, $t4, 13724
sw $t5, 0($t3)
addi $t3, $t4, 13728
li $t5,0x797979
sw $t5, 0($t3)
addi $t3, $t4, 13732
li $t5,0x696969
sw $t5, 0($t3)
addi $t3, $t4, 13736
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 13740
sw $t5, 0($t3)
addi $t3, $t4, 13744
sw $t5, 0($t3)
addi $t3, $t4, 13748
li $t5,0x080808
sw $t5, 0($t3)
addi $t3, $t4, 13752
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 13756
sw $t5, 0($t3)
addi $t3, $t4, 13760
sw $t5, 0($t3)
addi $t3, $t4, 13764
sw $t5, 0($t3)
addi $t3, $t4, 13768
li $t5,0x161616
sw $t5, 0($t3)
addi $t3, $t4, 13772
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 13776
sw $t5, 0($t3)
addi $t3, $t4, 13780
sw $t5, 0($t3)
addi $t3, $t4, 13784
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 13788
li $t5,0x2b2b2b
sw $t5, 0($t3)
addi $t3, $t4, 13792
li $t5,0x939393
sw $t5, 0($t3)
addi $t3, $t4, 13796
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 13800
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 13804
sw $t5, 0($t3)
addi $t3, $t4, 13808
sw $t5, 0($t3)
addi $t3, $t4, 13812
sw $t5, 0($t3)
addi $t3, $t4, 13816
sw $t5, 0($t3)
addi $t3, $t4, 13820
sw $t5, 0($t3)
addi $t3, $t4, 13824
sw $t5, 0($t3)
addi $t3, $t4, 13828
sw $t5, 0($t3)
addi $t3, $t4, 13832
sw $t5, 0($t3)
addi $t3, $t4, 13836
sw $t5, 0($t3)
addi $t3, $t4, 13840
sw $t5, 0($t3)
addi $t3, $t4, 13844
sw $t5, 0($t3)
addi $t3, $t4, 13848
sw $t5, 0($t3)
addi $t3, $t4, 13852
sw $t5, 0($t3)
addi $t3, $t4, 13856
sw $t5, 0($t3)
addi $t3, $t4, 13860
sw $t5, 0($t3)
addi $t3, $t4, 13864
sw $t5, 0($t3)
addi $t3, $t4, 13868
sw $t5, 0($t3)
addi $t3, $t4, 13872
sw $t5, 0($t3)
addi $t3, $t4, 13876
sw $t5, 0($t3)
addi $t3, $t4, 13880
sw $t5, 0($t3)
addi $t3, $t4, 13884
sw $t5, 0($t3)
addi $t3, $t4, 13888
sw $t5, 0($t3)
addi $t3, $t4, 13892
sw $t5, 0($t3)
addi $t3, $t4, 13896
sw $t5, 0($t3)
addi $t3, $t4, 13900
sw $t5, 0($t3)
addi $t3, $t4, 13904
sw $t5, 0($t3)
addi $t3, $t4, 13908
sw $t5, 0($t3)
addi $t3, $t4, 13912
sw $t5, 0($t3)
addi $t3, $t4, 13916
sw $t5, 0($t3)
addi $t3, $t4, 13920
sw $t5, 0($t3)
addi $t3, $t4, 13924
sw $t5, 0($t3)
addi $t3, $t4, 13928
sw $t5, 0($t3)
addi $t3, $t4, 13932
li $t5,0xd1d1d1
sw $t5, 0($t3)
addi $t3, $t4, 13936
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 13940
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 13944
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 13948
li $t5,0x353535
sw $t5, 0($t3)
addi $t3, $t4, 13952
li $t5,0x070707
sw $t5, 0($t3)
addi $t3, $t4, 13956
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 13960
sw $t5, 0($t3)
addi $t3, $t4, 13964
li $t5,0x979797
sw $t5, 0($t3)
addi $t3, $t4, 13968
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 13972
sw $t5, 0($t3)
addi $t3, $t4, 13976
sw $t5, 0($t3)
addi $t3, $t4, 13980
sw $t5, 0($t3)
addi $t3, $t4, 13984
li $t5,0x535353
sw $t5, 0($t3)
addi $t3, $t4, 13988
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 13992
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 13996
li $t5,0x020202
sw $t5, 0($t3)
addi $t3, $t4, 14000
li $t5,0x3d3d3d
sw $t5, 0($t3)
addi $t3, $t4, 14004
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 14008
sw $t5, 0($t3)
addi $t3, $t4, 14012
sw $t5, 0($t3)
addi $t3, $t4, 14016
sw $t5, 0($t3)
addi $t3, $t4, 14020
sw $t5, 0($t3)
addi $t3, $t4, 14024
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 14028
li $t5,0x474747
sw $t5, 0($t3)
addi $t3, $t4, 14032
li $t5,0x020202
sw $t5, 0($t3)
addi $t3, $t4, 14036
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 14040
li $t5,0xeeeeee
sw $t5, 0($t3)
addi $t3, $t4, 14044
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 14048
sw $t5, 0($t3)
addi $t3, $t4, 14052
sw $t5, 0($t3)
addi $t3, $t4, 14056
sw $t5, 0($t3)
addi $t3, $t4, 14060
sw $t5, 0($t3)
addi $t3, $t4, 14064
sw $t5, 0($t3)
addi $t3, $t4, 14068
sw $t5, 0($t3)
addi $t3, $t4, 14072
sw $t5, 0($t3)
addi $t3, $t4, 14076
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 14080
li $t5,0x020202
sw $t5, 0($t3)
addi $t3, $t4, 14084
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 14088
sw $t5, 0($t3)
addi $t3, $t4, 14092
sw $t5, 0($t3)
addi $t3, $t4, 14096
li $t5,0x020202
sw $t5, 0($t3)
addi $t3, $t4, 14100
li $t5,0xfdfdfd
sw $t5, 0($t3)
addi $t3, $t4, 14104
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 14108
sw $t5, 0($t3)
addi $t3, $t4, 14112
li $t5,0xd7d7d7
sw $t5, 0($t3)
addi $t3, $t4, 14116
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 14120
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 14124
sw $t5, 0($t3)
addi $t3, $t4, 14128
sw $t5, 0($t3)
addi $t3, $t4, 14132
sw $t5, 0($t3)
addi $t3, $t4, 14136
sw $t5, 0($t3)
addi $t3, $t4, 14140
li $t5,0x030303
sw $t5, 0($t3)
addi $t3, $t4, 14144
li $t5,0xbcbcbc
sw $t5, 0($t3)
addi $t3, $t4, 14148
li $t5,0x717171
sw $t5, 0($t3)
addi $t3, $t4, 14152
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 14156
sw $t5, 0($t3)
addi $t3, $t4, 14160
sw $t5, 0($t3)
addi $t3, $t4, 14164
sw $t5, 0($t3)
addi $t3, $t4, 14168
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 14172
li $t5,0x8b8b8b
sw $t5, 0($t3)
addi $t3, $t4, 14176
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 14180
li $t5,0x8d8d8d
sw $t5, 0($t3)
addi $t3, $t4, 14184
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 14188
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 14192
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 14196
sw $t5, 0($t3)
addi $t3, $t4, 14200
sw $t5, 0($t3)
addi $t3, $t4, 14204
li $t5,0x5d5d5d
sw $t5, 0($t3)
addi $t3, $t4, 14208
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 14212
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 14216
sw $t5, 0($t3)
addi $t3, $t4, 14220
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 14224
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 14228
sw $t5, 0($t3)
addi $t3, $t4, 14232
sw $t5, 0($t3)
addi $t3, $t4, 14236
li $t5,0x020202
sw $t5, 0($t3)
addi $t3, $t4, 14240
li $t5,0xaaa9a9
sw $t5, 0($t3)
addi $t3, $t4, 14244
li $t5,0xededed
sw $t5, 0($t3)
addi $t3, $t4, 14248
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 14252
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 14256
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 14260
sw $t5, 0($t3)
addi $t3, $t4, 14264
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 14268
sw $t5, 0($t3)
addi $t3, $t4, 14272
sw $t5, 0($t3)
addi $t3, $t4, 14276
sw $t5, 0($t3)
addi $t3, $t4, 14280
li $t5,0x3a3a3a
sw $t5, 0($t3)
addi $t3, $t4, 14284
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 14288
sw $t5, 0($t3)
addi $t3, $t4, 14292
sw $t5, 0($t3)
addi $t3, $t4, 14296
li $t5,0xd0d0d0
sw $t5, 0($t3)
addi $t3, $t4, 14300
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 14304
sw $t5, 0($t3)
addi $t3, $t4, 14308
li $t5,0x1c1c1c
sw $t5, 0($t3)
addi $t3, $t4, 14312
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 14316
sw $t5, 0($t3)
addi $t3, $t4, 14320
sw $t5, 0($t3)
addi $t3, $t4, 14324
sw $t5, 0($t3)
addi $t3, $t4, 14328
sw $t5, 0($t3)
addi $t3, $t4, 14332
sw $t5, 0($t3)
addi $t3, $t4, 14336
sw $t5, 0($t3)
addi $t3, $t4, 14340
sw $t5, 0($t3)
addi $t3, $t4, 14344
sw $t5, 0($t3)
addi $t3, $t4, 14348
sw $t5, 0($t3)
addi $t3, $t4, 14352
sw $t5, 0($t3)
addi $t3, $t4, 14356
sw $t5, 0($t3)
addi $t3, $t4, 14360
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 14364
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 14368
sw $t5, 0($t3)
addi $t3, $t4, 14372
sw $t5, 0($t3)
addi $t3, $t4, 14376
sw $t5, 0($t3)
addi $t3, $t4, 14380
sw $t5, 0($t3)
addi $t3, $t4, 14384
sw $t5, 0($t3)
addi $t3, $t4, 14388
sw $t5, 0($t3)
addi $t3, $t4, 14392
sw $t5, 0($t3)
addi $t3, $t4, 14396
sw $t5, 0($t3)
addi $t3, $t4, 14400
sw $t5, 0($t3)
addi $t3, $t4, 14404
sw $t5, 0($t3)
addi $t3, $t4, 14408
sw $t5, 0($t3)
addi $t3, $t4, 14412
sw $t5, 0($t3)
addi $t3, $t4, 14416
sw $t5, 0($t3)
addi $t3, $t4, 14420
sw $t5, 0($t3)
addi $t3, $t4, 14424
sw $t5, 0($t3)
addi $t3, $t4, 14428
sw $t5, 0($t3)
addi $t3, $t4, 14432
sw $t5, 0($t3)
addi $t3, $t4, 14436
sw $t5, 0($t3)
addi $t3, $t4, 14440
li $t5,0xf3f3f3
sw $t5, 0($t3)
addi $t3, $t4, 14444
li $t5,0x040404
sw $t5, 0($t3)
addi $t3, $t4, 14448
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 14452
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 14456
sw $t5, 0($t3)
addi $t3, $t4, 14460
li $t5,0x5d5d5d
sw $t5, 0($t3)
addi $t3, $t4, 14464
li $t5,0xe8e8e8
sw $t5, 0($t3)
addi $t3, $t4, 14468
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 14472
sw $t5, 0($t3)
addi $t3, $t4, 14476
li $t5,0x030303
sw $t5, 0($t3)
addi $t3, $t4, 14480
li $t5,0xc6c6c6
sw $t5, 0($t3)
addi $t3, $t4, 14484
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 14488
sw $t5, 0($t3)
addi $t3, $t4, 14492
sw $t5, 0($t3)
addi $t3, $t4, 14496
li $t5,0x080808
sw $t5, 0($t3)
addi $t3, $t4, 14500
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 14504
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 14508
li $t5,0x020202
sw $t5, 0($t3)
addi $t3, $t4, 14512
li $t5,0x141414
sw $t5, 0($t3)
addi $t3, $t4, 14516
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 14520
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 14524
sw $t5, 0($t3)
addi $t3, $t4, 14528
sw $t5, 0($t3)
addi $t3, $t4, 14532
sw $t5, 0($t3)
addi $t3, $t4, 14536
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 14540
li $t5,0x131313
sw $t5, 0($t3)
addi $t3, $t4, 14544
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 14548
sw $t5, 0($t3)
addi $t3, $t4, 14552
li $t5,0xf9f9f9
sw $t5, 0($t3)
addi $t3, $t4, 14556
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 14560
sw $t5, 0($t3)
addi $t3, $t4, 14564
sw $t5, 0($t3)
addi $t3, $t4, 14568
sw $t5, 0($t3)
addi $t3, $t4, 14572
sw $t5, 0($t3)
addi $t3, $t4, 14576
sw $t5, 0($t3)
addi $t3, $t4, 14580
sw $t5, 0($t3)
addi $t3, $t4, 14584
sw $t5, 0($t3)
addi $t3, $t4, 14588
sw $t5, 0($t3)
addi $t3, $t4, 14592
li $t5,0x020202
sw $t5, 0($t3)
addi $t3, $t4, 14596
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 14600
sw $t5, 0($t3)
addi $t3, $t4, 14604
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 14608
sw $t5, 0($t3)
addi $t3, $t4, 14612
li $t5,0xf7f7f7
sw $t5, 0($t3)
addi $t3, $t4, 14616
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 14620
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 14624
li $t5,0x323232
sw $t5, 0($t3)
addi $t3, $t4, 14628
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 14632
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 14636
sw $t5, 0($t3)
addi $t3, $t4, 14640
sw $t5, 0($t3)
addi $t3, $t4, 14644
sw $t5, 0($t3)
addi $t3, $t4, 14648
sw $t5, 0($t3)
addi $t3, $t4, 14652
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 14656
li $t5,0x979797
sw $t5, 0($t3)
addi $t3, $t4, 14660
li $t5,0x161616
sw $t5, 0($t3)
addi $t3, $t4, 14664
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 14668
sw $t5, 0($t3)
addi $t3, $t4, 14672
sw $t5, 0($t3)
addi $t3, $t4, 14676
sw $t5, 0($t3)
addi $t3, $t4, 14680
li $t5,0x020202
sw $t5, 0($t3)
addi $t3, $t4, 14684
li $t5,0xd4d4d4
sw $t5, 0($t3)
addi $t3, $t4, 14688
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 14692
li $t5,0x424242
sw $t5, 0($t3)
addi $t3, $t4, 14696
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 14700
li $t5,0x141414
sw $t5, 0($t3)
addi $t3, $t4, 14704
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 14708
sw $t5, 0($t3)
addi $t3, $t4, 14712
li $t5,0x040404
sw $t5, 0($t3)
addi $t3, $t4, 14716
li $t5,0x878787
sw $t5, 0($t3)
addi $t3, $t4, 14720
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 14724
li $t5,0xfffffe
sw $t5, 0($t3)
addi $t3, $t4, 14728
li $t5,0xdedede
sw $t5, 0($t3)
addi $t3, $t4, 14732
li $t5,0x020202
sw $t5, 0($t3)
addi $t3, $t4, 14736
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 14740
sw $t5, 0($t3)
addi $t3, $t4, 14744
sw $t5, 0($t3)
addi $t3, $t4, 14748
sw $t5, 0($t3)
addi $t3, $t4, 14752
li $t5,0x979797
sw $t5, 0($t3)
addi $t3, $t4, 14756
li $t5,0xfdfdfd
sw $t5, 0($t3)
addi $t3, $t4, 14760
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 14764
sw $t5, 0($t3)
addi $t3, $t4, 14768
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 14772
sw $t5, 0($t3)
addi $t3, $t4, 14776
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 14780
sw $t5, 0($t3)
addi $t3, $t4, 14784
sw $t5, 0($t3)
addi $t3, $t4, 14788
sw $t5, 0($t3)
addi $t3, $t4, 14792
li $t5,0x5e5e5e
sw $t5, 0($t3)
addi $t3, $t4, 14796
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 14800
sw $t5, 0($t3)
addi $t3, $t4, 14804
sw $t5, 0($t3)
addi $t3, $t4, 14808
li $t5,0xa1a1a1
sw $t5, 0($t3)
addi $t3, $t4, 14812
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 14816
sw $t5, 0($t3)
addi $t3, $t4, 14820
sw $t5, 0($t3)
addi $t3, $t4, 14824
li $t5,0xf7f7f7
sw $t5, 0($t3)
addi $t3, $t4, 14828
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 14832
sw $t5, 0($t3)
addi $t3, $t4, 14836
sw $t5, 0($t3)
addi $t3, $t4, 14840
sw $t5, 0($t3)
addi $t3, $t4, 14844
sw $t5, 0($t3)
addi $t3, $t4, 14848
sw $t5, 0($t3)
addi $t3, $t4, 14852
sw $t5, 0($t3)
addi $t3, $t4, 14856
sw $t5, 0($t3)
addi $t3, $t4, 14860
sw $t5, 0($t3)
addi $t3, $t4, 14864
sw $t5, 0($t3)
addi $t3, $t4, 14868
sw $t5, 0($t3)
addi $t3, $t4, 14872
sw $t5, 0($t3)
addi $t3, $t4, 14876
li $t5,0xe8e8e8
sw $t5, 0($t3)
addi $t3, $t4, 14880
li $t5,0xdedede
sw $t5, 0($t3)
addi $t3, $t4, 14884
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 14888
sw $t5, 0($t3)
addi $t3, $t4, 14892
sw $t5, 0($t3)
addi $t3, $t4, 14896
sw $t5, 0($t3)
addi $t3, $t4, 14900
sw $t5, 0($t3)
addi $t3, $t4, 14904
sw $t5, 0($t3)
addi $t3, $t4, 14908
sw $t5, 0($t3)
addi $t3, $t4, 14912
sw $t5, 0($t3)
addi $t3, $t4, 14916
li $t5,0xe0e0e0
sw $t5, 0($t3)
addi $t3, $t4, 14920
li $t5,0x737373
sw $t5, 0($t3)
addi $t3, $t4, 14924
li $t5,0xfcfcfc
sw $t5, 0($t3)
addi $t3, $t4, 14928
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 14932
sw $t5, 0($t3)
addi $t3, $t4, 14936
sw $t5, 0($t3)
addi $t3, $t4, 14940
sw $t5, 0($t3)
addi $t3, $t4, 14944
sw $t5, 0($t3)
addi $t3, $t4, 14948
li $t5,0xfcfcfc
sw $t5, 0($t3)
addi $t3, $t4, 14952
li $t5,0x161616
sw $t5, 0($t3)
addi $t3, $t4, 14956
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 14960
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 14964
sw $t5, 0($t3)
addi $t3, $t4, 14968
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 14972
li $t5,0xf4f4f4
sw $t5, 0($t3)
addi $t3, $t4, 14976
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 14980
li $t5,0x030303
sw $t5, 0($t3)
addi $t3, $t4, 14984
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 14988
sw $t5, 0($t3)
addi $t3, $t4, 14992
sw $t5, 0($t3)
addi $t3, $t4, 14996
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 15000
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 15004
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 15008
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 15012
sw $t5, 0($t3)
addi $t3, $t4, 15016
sw $t5, 0($t3)
addi $t3, $t4, 15020
sw $t5, 0($t3)
addi $t3, $t4, 15024
li $t5,0x0a0a0a
sw $t5, 0($t3)
addi $t3, $t4, 15028
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 15032
sw $t5, 0($t3)
addi $t3, $t4, 15036
sw $t5, 0($t3)
addi $t3, $t4, 15040
sw $t5, 0($t3)
addi $t3, $t4, 15044
sw $t5, 0($t3)
addi $t3, $t4, 15048
sw $t5, 0($t3)
addi $t3, $t4, 15052
li $t5,0x030303
sw $t5, 0($t3)
addi $t3, $t4, 15056
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 15060
sw $t5, 0($t3)
addi $t3, $t4, 15064
li $t5,0xfdfdfd
sw $t5, 0($t3)
addi $t3, $t4, 15068
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 15072
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 15076
sw $t5, 0($t3)
addi $t3, $t4, 15080
sw $t5, 0($t3)
addi $t3, $t4, 15084
sw $t5, 0($t3)
addi $t3, $t4, 15088
sw $t5, 0($t3)
addi $t3, $t4, 15092
sw $t5, 0($t3)
addi $t3, $t4, 15096
sw $t5, 0($t3)
addi $t3, $t4, 15100
sw $t5, 0($t3)
addi $t3, $t4, 15104
li $t5,0x050505
sw $t5, 0($t3)
addi $t3, $t4, 15108
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 15112
sw $t5, 0($t3)
addi $t3, $t4, 15116
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 15120
li $t5,0x030303
sw $t5, 0($t3)
addi $t3, $t4, 15124
li $t5,0xececec
sw $t5, 0($t3)
addi $t3, $t4, 15128
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 15132
sw $t5, 0($t3)
addi $t3, $t4, 15136
li $t5,0x050505
sw $t5, 0($t3)
addi $t3, $t4, 15140
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 15144
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 15148
sw $t5, 0($t3)
addi $t3, $t4, 15152
sw $t5, 0($t3)
addi $t3, $t4, 15156
sw $t5, 0($t3)
addi $t3, $t4, 15160
sw $t5, 0($t3)
addi $t3, $t4, 15164
li $t5,0x050505
sw $t5, 0($t3)
addi $t3, $t4, 15168
li $t5,0x080808
sw $t5, 0($t3)
addi $t3, $t4, 15172
li $t5,0x030303
sw $t5, 0($t3)
addi $t3, $t4, 15176
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 15180
sw $t5, 0($t3)
addi $t3, $t4, 15184
sw $t5, 0($t3)
addi $t3, $t4, 15188
sw $t5, 0($t3)
addi $t3, $t4, 15192
li $t5,0x414141
sw $t5, 0($t3)
addi $t3, $t4, 15196
li $t5,0xf3f3f3
sw $t5, 0($t3)
addi $t3, $t4, 15200
li $t5,0xfdfdfd
sw $t5, 0($t3)
addi $t3, $t4, 15204
li $t5,0x030303
sw $t5, 0($t3)
addi $t3, $t4, 15208
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 15212
sw $t5, 0($t3)
addi $t3, $t4, 15216
sw $t5, 0($t3)
addi $t3, $t4, 15220
sw $t5, 0($t3)
addi $t3, $t4, 15224
li $t5,0x303030
sw $t5, 0($t3)
addi $t3, $t4, 15228
li $t5,0xd4d4d4
sw $t5, 0($t3)
addi $t3, $t4, 15232
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 15236
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 15240
li $t5,0x808080
sw $t5, 0($t3)
addi $t3, $t4, 15244
li $t5,0x030303
sw $t5, 0($t3)
addi $t3, $t4, 15248
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 15252
sw $t5, 0($t3)
addi $t3, $t4, 15256
sw $t5, 0($t3)
addi $t3, $t4, 15260
sw $t5, 0($t3)
addi $t3, $t4, 15264
li $t5,0xa9a9a9
sw $t5, 0($t3)
addi $t3, $t4, 15268
li $t5,0xfdfdfd
sw $t5, 0($t3)
addi $t3, $t4, 15272
li $t5,0x030303
sw $t5, 0($t3)
addi $t3, $t4, 15276
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 15280
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 15284
sw $t5, 0($t3)
addi $t3, $t4, 15288
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 15292
sw $t5, 0($t3)
addi $t3, $t4, 15296
sw $t5, 0($t3)
addi $t3, $t4, 15300
sw $t5, 0($t3)
addi $t3, $t4, 15304
li $t5,0xb5b5b5
sw $t5, 0($t3)
addi $t3, $t4, 15308
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 15312
sw $t5, 0($t3)
addi $t3, $t4, 15316
sw $t5, 0($t3)
addi $t3, $t4, 15320
li $t5,0x545454
sw $t5, 0($t3)
addi $t3, $t4, 15324
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 15328
sw $t5, 0($t3)
addi $t3, $t4, 15332
sw $t5, 0($t3)
addi $t3, $t4, 15336
li $t5,0x343434
sw $t5, 0($t3)
addi $t3, $t4, 15340
li $t5,0xfdfdfd
sw $t5, 0($t3)
addi $t3, $t4, 15344
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 15348
sw $t5, 0($t3)
addi $t3, $t4, 15352
sw $t5, 0($t3)
addi $t3, $t4, 15356
sw $t5, 0($t3)
addi $t3, $t4, 15360
sw $t5, 0($t3)
addi $t3, $t4, 15364
sw $t5, 0($t3)
addi $t3, $t4, 15368
sw $t5, 0($t3)
addi $t3, $t4, 15372
sw $t5, 0($t3)
addi $t3, $t4, 15376
sw $t5, 0($t3)
addi $t3, $t4, 15380
sw $t5, 0($t3)
addi $t3, $t4, 15384
li $t5,0xfcfcfc
sw $t5, 0($t3)
addi $t3, $t4, 15388
li $t5,0x020202
sw $t5, 0($t3)
addi $t3, $t4, 15392
sw $t5, 0($t3)
addi $t3, $t4, 15396
li $t5,0x7c7c7c
sw $t5, 0($t3)
addi $t3, $t4, 15400
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 15404
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 15408
sw $t5, 0($t3)
addi $t3, $t4, 15412
sw $t5, 0($t3)
addi $t3, $t4, 15416
sw $t5, 0($t3)
addi $t3, $t4, 15420
sw $t5, 0($t3)
addi $t3, $t4, 15424
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 15428
li $t5,0x141414
sw $t5, 0($t3)
addi $t3, $t4, 15432
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 15436
li $t5,0x808080
sw $t5, 0($t3)
addi $t3, $t4, 15440
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 15444
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 15448
sw $t5, 0($t3)
addi $t3, $t4, 15452
sw $t5, 0($t3)
addi $t3, $t4, 15456
sw $t5, 0($t3)
addi $t3, $t4, 15460
li $t5,0xbbbbbb
sw $t5, 0($t3)
addi $t3, $t4, 15464
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 15468
sw $t5, 0($t3)
addi $t3, $t4, 15472
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 15476
sw $t5, 0($t3)
addi $t3, $t4, 15480
li $t5,0x1a1a1a
sw $t5, 0($t3)
addi $t3, $t4, 15484
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 15488
sw $t5, 0($t3)
addi $t3, $t4, 15492
li $t5,0x030303
sw $t5, 0($t3)
addi $t3, $t4, 15496
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 15500
sw $t5, 0($t3)
addi $t3, $t4, 15504
li $t5,0x020202
sw $t5, 0($t3)
addi $t3, $t4, 15508
li $t5,0xd9d9d9
sw $t5, 0($t3)
addi $t3, $t4, 15512
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 15516
li $t5,0xaeaeae
sw $t5, 0($t3)
addi $t3, $t4, 15520
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 15524
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 15528
sw $t5, 0($t3)
addi $t3, $t4, 15532
sw $t5, 0($t3)
addi $t3, $t4, 15536
li $t5,0x2b2b2b
sw $t5, 0($t3)
addi $t3, $t4, 15540
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 15544
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 15548
sw $t5, 0($t3)
addi $t3, $t4, 15552
sw $t5, 0($t3)
addi $t3, $t4, 15556
sw $t5, 0($t3)
addi $t3, $t4, 15560
li $t5,0xdddddd
sw $t5, 0($t3)
addi $t3, $t4, 15564
li $t5,0x030303
sw $t5, 0($t3)
addi $t3, $t4, 15568
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 15572
li $t5,0x020202
sw $t5, 0($t3)
addi $t3, $t4, 15576
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 15580
sw $t5, 0($t3)
addi $t3, $t4, 15584
sw $t5, 0($t3)
addi $t3, $t4, 15588
sw $t5, 0($t3)
addi $t3, $t4, 15592
sw $t5, 0($t3)
addi $t3, $t4, 15596
sw $t5, 0($t3)
addi $t3, $t4, 15600
sw $t5, 0($t3)
addi $t3, $t4, 15604
sw $t5, 0($t3)
addi $t3, $t4, 15608
sw $t5, 0($t3)
addi $t3, $t4, 15612
sw $t5, 0($t3)
addi $t3, $t4, 15616
li $t5,0x080808
sw $t5, 0($t3)
addi $t3, $t4, 15620
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 15624
sw $t5, 0($t3)
addi $t3, $t4, 15628
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 15632
li $t5,0x030303
sw $t5, 0($t3)
addi $t3, $t4, 15636
li $t5,0xe7e7e7
sw $t5, 0($t3)
addi $t3, $t4, 15640
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 15644
li $t5,0xd9d9d9
sw $t5, 0($t3)
addi $t3, $t4, 15648
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 15652
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 15656
sw $t5, 0($t3)
addi $t3, $t4, 15660
li $t5,0x030303
sw $t5, 0($t3)
addi $t3, $t4, 15664
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 15668
sw $t5, 0($t3)
addi $t3, $t4, 15672
sw $t5, 0($t3)
addi $t3, $t4, 15676
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 15680
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 15684
sw $t5, 0($t3)
addi $t3, $t4, 15688
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 15692
sw $t5, 0($t3)
addi $t3, $t4, 15696
sw $t5, 0($t3)
addi $t3, $t4, 15700
li $t5,0x030303
sw $t5, 0($t3)
addi $t3, $t4, 15704
li $t5,0x787878
sw $t5, 0($t3)
addi $t3, $t4, 15708
li $t5,0xfffffe
sw $t5, 0($t3)
addi $t3, $t4, 15712
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 15716
li $t5,0x020202
sw $t5, 0($t3)
addi $t3, $t4, 15720
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 15724
sw $t5, 0($t3)
addi $t3, $t4, 15728
sw $t5, 0($t3)
addi $t3, $t4, 15732
sw $t5, 0($t3)
addi $t3, $t4, 15736
li $t5,0x939393
sw $t5, 0($t3)
addi $t3, $t4, 15740
li $t5,0xfcfcfc
sw $t5, 0($t3)
addi $t3, $t4, 15744
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 15748
li $t5,0xfffffe
sw $t5, 0($t3)
addi $t3, $t4, 15752
li $t5,0x373737
sw $t5, 0($t3)
addi $t3, $t4, 15756
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 15760
sw $t5, 0($t3)
addi $t3, $t4, 15764
sw $t5, 0($t3)
addi $t3, $t4, 15768
sw $t5, 0($t3)
addi $t3, $t4, 15772
li $t5,0x1b1b1b
sw $t5, 0($t3)
addi $t3, $t4, 15776
li $t5,0xd2d2d2
sw $t5, 0($t3)
addi $t3, $t4, 15780
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 15784
li $t5,0x444444
sw $t5, 0($t3)
addi $t3, $t4, 15788
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 15792
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 15796
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 15800
sw $t5, 0($t3)
addi $t3, $t4, 15804
sw $t5, 0($t3)
addi $t3, $t4, 15808
sw $t5, 0($t3)
addi $t3, $t4, 15812
li $t5,0x030303
sw $t5, 0($t3)
addi $t3, $t4, 15816
li $t5,0x9c9c9c
sw $t5, 0($t3)
addi $t3, $t4, 15820
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 15824
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 15828
sw $t5, 0($t3)
addi $t3, $t4, 15832
li $t5,0x191919
sw $t5, 0($t3)
addi $t3, $t4, 15836
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 15840
sw $t5, 0($t3)
addi $t3, $t4, 15844
sw $t5, 0($t3)
addi $t3, $t4, 15848
li $t5,0x404040
sw $t5, 0($t3)
addi $t3, $t4, 15852
li $t5,0xfcfcfc
sw $t5, 0($t3)
addi $t3, $t4, 15856
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 15860
sw $t5, 0($t3)
addi $t3, $t4, 15864
sw $t5, 0($t3)
addi $t3, $t4, 15868
sw $t5, 0($t3)
addi $t3, $t4, 15872
sw $t5, 0($t3)
addi $t3, $t4, 15876
sw $t5, 0($t3)
addi $t3, $t4, 15880
sw $t5, 0($t3)
addi $t3, $t4, 15884
sw $t5, 0($t3)
addi $t3, $t4, 15888
sw $t5, 0($t3)
addi $t3, $t4, 15892
sw $t5, 0($t3)
addi $t3, $t4, 15896
li $t5,0x525151
sw $t5, 0($t3)
addi $t3, $t4, 15900
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 15904
sw $t5, 0($t3)
addi $t3, $t4, 15908
li $t5,0x030303
sw $t5, 0($t3)
addi $t3, $t4, 15912
li $t5,0xf0f0f0
sw $t5, 0($t3)
addi $t3, $t4, 15916
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 15920
sw $t5, 0($t3)
addi $t3, $t4, 15924
sw $t5, 0($t3)
addi $t3, $t4, 15928
sw $t5, 0($t3)
addi $t3, $t4, 15932
sw $t5, 0($t3)
addi $t3, $t4, 15936
li $t5,0xf4f4f4
sw $t5, 0($t3)
addi $t3, $t4, 15940
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 15944
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 15948
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 15952
li $t5,0x6a6a6a
sw $t5, 0($t3)
addi $t3, $t4, 15956
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 15960
sw $t5, 0($t3)
addi $t3, $t4, 15964
sw $t5, 0($t3)
addi $t3, $t4, 15968
sw $t5, 0($t3)
addi $t3, $t4, 15972
li $t5,0x080808
sw $t5, 0($t3)
addi $t3, $t4, 15976
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 15980
sw $t5, 0($t3)
addi $t3, $t4, 15984
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 15988
li $t5,0x020202
sw $t5, 0($t3)
addi $t3, $t4, 15992
li $t5,0xf1f1f1
sw $t5, 0($t3)
addi $t3, $t4, 15996
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 16000
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 16004
li $t5,0x030303
sw $t5, 0($t3)
addi $t3, $t4, 16008
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 16012
sw $t5, 0($t3)
addi $t3, $t4, 16016
sw $t5, 0($t3)
addi $t3, $t4, 16020
li $t5,0x8f8f8f
sw $t5, 0($t3)
addi $t3, $t4, 16024
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 16028
li $t5,0x383838
sw $t5, 0($t3)
addi $t3, $t4, 16032
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 16036
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 16040
sw $t5, 0($t3)
addi $t3, $t4, 16044
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 16048
li $t5,0x8a8a8a
sw $t5, 0($t3)
addi $t3, $t4, 16052
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 16056
sw $t5, 0($t3)
addi $t3, $t4, 16060
sw $t5, 0($t3)
addi $t3, $t4, 16064
sw $t5, 0($t3)
addi $t3, $t4, 16068
sw $t5, 0($t3)
addi $t3, $t4, 16072
li $t5,0x7f7f7f
sw $t5, 0($t3)
addi $t3, $t4, 16076
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 16080
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 16084
li $t5,0x020202
sw $t5, 0($t3)
addi $t3, $t4, 16088
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 16092
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 16096
sw $t5, 0($t3)
addi $t3, $t4, 16100
sw $t5, 0($t3)
addi $t3, $t4, 16104
sw $t5, 0($t3)
addi $t3, $t4, 16108
sw $t5, 0($t3)
addi $t3, $t4, 16112
sw $t5, 0($t3)
addi $t3, $t4, 16116
sw $t5, 0($t3)
addi $t3, $t4, 16120
sw $t5, 0($t3)
addi $t3, $t4, 16124
sw $t5, 0($t3)
addi $t3, $t4, 16128
li $t5,0x080808
sw $t5, 0($t3)
addi $t3, $t4, 16132
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 16136
sw $t5, 0($t3)
addi $t3, $t4, 16140
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 16144
sw $t5, 0($t3)
addi $t3, $t4, 16148
li $t5,0xc3c3c3
sw $t5, 0($t3)
addi $t3, $t4, 16152
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 16156
li $t5,0x575757
sw $t5, 0($t3)
addi $t3, $t4, 16160
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 16164
sw $t5, 0($t3)
addi $t3, $t4, 16168
sw $t5, 0($t3)
addi $t3, $t4, 16172
li $t5,0x808080
sw $t5, 0($t3)
addi $t3, $t4, 16176
li $t5,0x030303
sw $t5, 0($t3)
addi $t3, $t4, 16180
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 16184
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 16188
sw $t5, 0($t3)
addi $t3, $t4, 16192
li $t5,0x030303
sw $t5, 0($t3)
addi $t3, $t4, 16196
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 16200
sw $t5, 0($t3)
addi $t3, $t4, 16204
sw $t5, 0($t3)
addi $t3, $t4, 16208
sw $t5, 0($t3)
addi $t3, $t4, 16212
sw $t5, 0($t3)
addi $t3, $t4, 16216
li $t5,0x9d9d9d
sw $t5, 0($t3)
addi $t3, $t4, 16220
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 16224
li $t5,0xf7f7f7
sw $t5, 0($t3)
addi $t3, $t4, 16228
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 16232
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 16236
sw $t5, 0($t3)
addi $t3, $t4, 16240
sw $t5, 0($t3)
addi $t3, $t4, 16244
sw $t5, 0($t3)
addi $t3, $t4, 16248
li $t5,0xa2a2a2
sw $t5, 0($t3)
addi $t3, $t4, 16252
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 16256
sw $t5, 0($t3)
addi $t3, $t4, 16260
li $t5,0xfdfdfd
sw $t5, 0($t3)
addi $t3, $t4, 16264
li $t5,0x050505
sw $t5, 0($t3)
addi $t3, $t4, 16268
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 16272
sw $t5, 0($t3)
addi $t3, $t4, 16276
sw $t5, 0($t3)
addi $t3, $t4, 16280
sw $t5, 0($t3)
addi $t3, $t4, 16284
li $t5,0x4e4e4e
sw $t5, 0($t3)
addi $t3, $t4, 16288
li $t5,0xfbfbfb
sw $t5, 0($t3)
addi $t3, $t4, 16292
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 16296
li $t5,0xc7c7c7
sw $t5, 0($t3)
addi $t3, $t4, 16300
li $t5,0x020202
sw $t5, 0($t3)
addi $t3, $t4, 16304
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 16308
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 16312
sw $t5, 0($t3)
addi $t3, $t4, 16316
sw $t5, 0($t3)
addi $t3, $t4, 16320
sw $t5, 0($t3)
addi $t3, $t4, 16324
li $t5,0x030303
sw $t5, 0($t3)
addi $t3, $t4, 16328
li $t5,0xe2e2e2
sw $t5, 0($t3)
addi $t3, $t4, 16332
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 16336
sw $t5, 0($t3)
addi $t3, $t4, 16340
sw $t5, 0($t3)
addi $t3, $t4, 16344
li $t5,0x050505
sw $t5, 0($t3)
addi $t3, $t4, 16348
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 16352
sw $t5, 0($t3)
addi $t3, $t4, 16356
sw $t5, 0($t3)
addi $t3, $t4, 16360
li $t5,0x3c3c3c
sw $t5, 0($t3)
addi $t3, $t4, 16364
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 16368
sw $t5, 0($t3)
addi $t3, $t4, 16372
sw $t5, 0($t3)
addi $t3, $t4, 16376
sw $t5, 0($t3)
addi $t3, $t4, 16380
sw $t5, 0($t3)
addi $t3, $t4, 16384
sw $t5, 0($t3)
addi $t3, $t4, 16388
sw $t5, 0($t3)
addi $t3, $t4, 16392
sw $t5, 0($t3)
addi $t3, $t4, 16396
sw $t5, 0($t3)
addi $t3, $t4, 16400
sw $t5, 0($t3)
addi $t3, $t4, 16404
sw $t5, 0($t3)
addi $t3, $t4, 16408
li $t5,0x080808
sw $t5, 0($t3)
addi $t3, $t4, 16412
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 16416
sw $t5, 0($t3)
addi $t3, $t4, 16420
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 16424
li $t5,0x9b9b9b
sw $t5, 0($t3)
addi $t3, $t4, 16428
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 16432
sw $t5, 0($t3)
addi $t3, $t4, 16436
sw $t5, 0($t3)
addi $t3, $t4, 16440
sw $t5, 0($t3)
addi $t3, $t4, 16444
sw $t5, 0($t3)
addi $t3, $t4, 16448
li $t5,0x7d7d7d
sw $t5, 0($t3)
addi $t3, $t4, 16452
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 16456
sw $t5, 0($t3)
addi $t3, $t4, 16460
sw $t5, 0($t3)
addi $t3, $t4, 16464
li $t5,0x050505
sw $t5, 0($t3)
addi $t3, $t4, 16468
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 16472
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 16476
sw $t5, 0($t3)
addi $t3, $t4, 16480
li $t5,0x7a7a7a
sw $t5, 0($t3)
addi $t3, $t4, 16484
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 16488
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 16492
sw $t5, 0($t3)
addi $t3, $t4, 16496
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 16500
li $t5,0x3b3b3b
sw $t5, 0($t3)
addi $t3, $t4, 16504
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 16508
sw $t5, 0($t3)
addi $t3, $t4, 16512
li $t5,0xfafafa
sw $t5, 0($t3)
addi $t3, $t4, 16516
li $t5,0x020202
sw $t5, 0($t3)
addi $t3, $t4, 16520
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 16524
sw $t5, 0($t3)
addi $t3, $t4, 16528
sw $t5, 0($t3)
addi $t3, $t4, 16532
li $t5,0x888888
sw $t5, 0($t3)
addi $t3, $t4, 16536
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 16540
li $t5,0x0a0a0a
sw $t5, 0($t3)
addi $t3, $t4, 16544
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 16548
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 16552
sw $t5, 0($t3)
addi $t3, $t4, 16556
sw $t5, 0($t3)
addi $t3, $t4, 16560
li $t5,0xd7d7d7
sw $t5, 0($t3)
addi $t3, $t4, 16564
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 16568
sw $t5, 0($t3)
addi $t3, $t4, 16572
sw $t5, 0($t3)
addi $t3, $t4, 16576
sw $t5, 0($t3)
addi $t3, $t4, 16580
li $t5,0xfdfdfd
sw $t5, 0($t3)
addi $t3, $t4, 16584
li $t5,0x181818
sw $t5, 0($t3)
addi $t3, $t4, 16588
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 16592
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 16596
sw $t5, 0($t3)
addi $t3, $t4, 16600
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 16604
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 16608
sw $t5, 0($t3)
addi $t3, $t4, 16612
sw $t5, 0($t3)
addi $t3, $t4, 16616
sw $t5, 0($t3)
addi $t3, $t4, 16620
sw $t5, 0($t3)
addi $t3, $t4, 16624
sw $t5, 0($t3)
addi $t3, $t4, 16628
sw $t5, 0($t3)
addi $t3, $t4, 16632
sw $t5, 0($t3)
addi $t3, $t4, 16636
sw $t5, 0($t3)
addi $t3, $t4, 16640
li $t5,0x1e1e1e
sw $t5, 0($t3)
addi $t3, $t4, 16644
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 16648
sw $t5, 0($t3)
addi $t3, $t4, 16652
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 16656
sw $t5, 0($t3)
addi $t3, $t4, 16660
li $t5,0xb7b7b7
sw $t5, 0($t3)
addi $t3, $t4, 16664
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 16668
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 16672
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 16676
sw $t5, 0($t3)
addi $t3, $t4, 16680
li $t5,0x020202
sw $t5, 0($t3)
addi $t3, $t4, 16684
li $t5,0xf4f4f4
sw $t5, 0($t3)
addi $t3, $t4, 16688
li $t5,0x040404
sw $t5, 0($t3)
addi $t3, $t4, 16692
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 16696
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 16700
sw $t5, 0($t3)
addi $t3, $t4, 16704
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 16708
sw $t5, 0($t3)
addi $t3, $t4, 16712
sw $t5, 0($t3)
addi $t3, $t4, 16716
sw $t5, 0($t3)
addi $t3, $t4, 16720
sw $t5, 0($t3)
addi $t3, $t4, 16724
li $t5,0x1c1c1c
sw $t5, 0($t3)
addi $t3, $t4, 16728
li $t5,0xc9c9c9
sw $t5, 0($t3)
addi $t3, $t4, 16732
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 16736
li $t5,0xdfdfdf
sw $t5, 0($t3)
addi $t3, $t4, 16740
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 16744
li $t5,0x202020
sw $t5, 0($t3)
addi $t3, $t4, 16748
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 16752
sw $t5, 0($t3)
addi $t3, $t4, 16756
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 16760
li $t5,0x666666
sw $t5, 0($t3)
addi $t3, $t4, 16764
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 16768
sw $t5, 0($t3)
addi $t3, $t4, 16772
li $t5,0xfdfdfd
sw $t5, 0($t3)
addi $t3, $t4, 16776
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 16780
sw $t5, 0($t3)
addi $t3, $t4, 16784
sw $t5, 0($t3)
addi $t3, $t4, 16788
sw $t5, 0($t3)
addi $t3, $t4, 16792
li $t5,0x020202
sw $t5, 0($t3)
addi $t3, $t4, 16796
li $t5,0x9b9b9b
sw $t5, 0($t3)
addi $t3, $t4, 16800
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 16804
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 16808
li $t5,0xfbfbfb
sw $t5, 0($t3)
addi $t3, $t4, 16812
li $t5,0x030303
sw $t5, 0($t3)
addi $t3, $t4, 16816
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 16820
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 16824
sw $t5, 0($t3)
addi $t3, $t4, 16828
sw $t5, 0($t3)
addi $t3, $t4, 16832
sw $t5, 0($t3)
addi $t3, $t4, 16836
sw $t5, 0($t3)
addi $t3, $t4, 16840
li $t5,0xe2e2e2
sw $t5, 0($t3)
addi $t3, $t4, 16844
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 16848
sw $t5, 0($t3)
addi $t3, $t4, 16852
sw $t5, 0($t3)
addi $t3, $t4, 16856
li $t5,0x020202
sw $t5, 0($t3)
addi $t3, $t4, 16860
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 16864
sw $t5, 0($t3)
addi $t3, $t4, 16868
li $t5,0x030303
sw $t5, 0($t3)
addi $t3, $t4, 16872
li $t5,0x868686
sw $t5, 0($t3)
addi $t3, $t4, 16876
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 16880
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 16884
sw $t5, 0($t3)
addi $t3, $t4, 16888
sw $t5, 0($t3)
addi $t3, $t4, 16892
sw $t5, 0($t3)
addi $t3, $t4, 16896
sw $t5, 0($t3)
addi $t3, $t4, 16900
sw $t5, 0($t3)
addi $t3, $t4, 16904
sw $t5, 0($t3)
addi $t3, $t4, 16908
sw $t5, 0($t3)
addi $t3, $t4, 16912
sw $t5, 0($t3)
addi $t3, $t4, 16916
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 16920
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 16924
sw $t5, 0($t3)
addi $t3, $t4, 16928
sw $t5, 0($t3)
addi $t3, $t4, 16932
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 16936
li $t5,0x121212
sw $t5, 0($t3)
addi $t3, $t4, 16940
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 16944
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 16948
sw $t5, 0($t3)
addi $t3, $t4, 16952
sw $t5, 0($t3)
addi $t3, $t4, 16956
sw $t5, 0($t3)
addi $t3, $t4, 16960
li $t5,0x050505
sw $t5, 0($t3)
addi $t3, $t4, 16964
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 16968
sw $t5, 0($t3)
addi $t3, $t4, 16972
sw $t5, 0($t3)
addi $t3, $t4, 16976
li $t5,0x060606
sw $t5, 0($t3)
addi $t3, $t4, 16980
li $t5,0xf8f8f8
sw $t5, 0($t3)
addi $t3, $t4, 16984
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 16988
sw $t5, 0($t3)
addi $t3, $t4, 16992
li $t5,0x050505
sw $t5, 0($t3)
addi $t3, $t4, 16996
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 17000
sw $t5, 0($t3)
addi $t3, $t4, 17004
sw $t5, 0($t3)
addi $t3, $t4, 17008
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 17012
li $t5,0x939393
sw $t5, 0($t3)
addi $t3, $t4, 17016
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 17020
sw $t5, 0($t3)
addi $t3, $t4, 17024
li $t5,0xe5e5e5
sw $t5, 0($t3)
addi $t3, $t4, 17028
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 17032
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 17036
sw $t5, 0($t3)
addi $t3, $t4, 17040
li $t5,0x020202
sw $t5, 0($t3)
addi $t3, $t4, 17044
li $t5,0xd3d3d3
sw $t5, 0($t3)
addi $t3, $t4, 17048
li $t5,0xfcfcfc
sw $t5, 0($t3)
addi $t3, $t4, 17052
li $t5,0x040404
sw $t5, 0($t3)
addi $t3, $t4, 17056
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 17060
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 17064
sw $t5, 0($t3)
addi $t3, $t4, 17068
li $t5,0x030303
sw $t5, 0($t3)
addi $t3, $t4, 17072
li $t5,0xfdfdfd
sw $t5, 0($t3)
addi $t3, $t4, 17076
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 17080
sw $t5, 0($t3)
addi $t3, $t4, 17084
sw $t5, 0($t3)
addi $t3, $t4, 17088
sw $t5, 0($t3)
addi $t3, $t4, 17092
sw $t5, 0($t3)
addi $t3, $t4, 17096
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 17100
sw $t5, 0($t3)
addi $t3, $t4, 17104
sw $t5, 0($t3)
addi $t3, $t4, 17108
li $t5,0x040404
sw $t5, 0($t3)
addi $t3, $t4, 17112
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 17116
sw $t5, 0($t3)
addi $t3, $t4, 17120
sw $t5, 0($t3)
addi $t3, $t4, 17124
sw $t5, 0($t3)
addi $t3, $t4, 17128
sw $t5, 0($t3)
addi $t3, $t4, 17132
sw $t5, 0($t3)
addi $t3, $t4, 17136
sw $t5, 0($t3)
addi $t3, $t4, 17140
sw $t5, 0($t3)
addi $t3, $t4, 17144
sw $t5, 0($t3)
addi $t3, $t4, 17148
sw $t5, 0($t3)
addi $t3, $t4, 17152
li $t5,0x535353
sw $t5, 0($t3)
addi $t3, $t4, 17156
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 17160
sw $t5, 0($t3)
addi $t3, $t4, 17164
sw $t5, 0($t3)
addi $t3, $t4, 17168
sw $t5, 0($t3)
addi $t3, $t4, 17172
li $t5,0xb6b6b6
sw $t5, 0($t3)
addi $t3, $t4, 17176
li $t5,0xdcdcdc
sw $t5, 0($t3)
addi $t3, $t4, 17180
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 17184
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 17188
li $t5,0x030303
sw $t5, 0($t3)
addi $t3, $t4, 17192
li $t5,0x3d3d3d
sw $t5, 0($t3)
addi $t3, $t4, 17196
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 17200
li $t5,0x040404
sw $t5, 0($t3)
addi $t3, $t4, 17204
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 17208
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 17212
sw $t5, 0($t3)
addi $t3, $t4, 17216
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 17220
sw $t5, 0($t3)
addi $t3, $t4, 17224
sw $t5, 0($t3)
addi $t3, $t4, 17228
sw $t5, 0($t3)
addi $t3, $t4, 17232
sw $t5, 0($t3)
addi $t3, $t4, 17236
li $t5,0x7e7e7e
sw $t5, 0($t3)
addi $t3, $t4, 17240
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 17244
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 17248
li $t5,0xaeaeae
sw $t5, 0($t3)
addi $t3, $t4, 17252
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 17256
li $t5,0x2b2b2b
sw $t5, 0($t3)
addi $t3, $t4, 17260
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 17264
sw $t5, 0($t3)
addi $t3, $t4, 17268
li $t5,0x0e0e0e
sw $t5, 0($t3)
addi $t3, $t4, 17272
li $t5,0xb6b6b6
sw $t5, 0($t3)
addi $t3, $t4, 17276
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 17280
sw $t5, 0($t3)
addi $t3, $t4, 17284
li $t5,0xdfdfdf
sw $t5, 0($t3)
addi $t3, $t4, 17288
li $t5,0x020202
sw $t5, 0($t3)
addi $t3, $t4, 17292
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 17296
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 17300
sw $t5, 0($t3)
addi $t3, $t4, 17304
li $t5,0x030303
sw $t5, 0($t3)
addi $t3, $t4, 17308
li $t5,0x797979
sw $t5, 0($t3)
addi $t3, $t4, 17312
li $t5,0xfdfdfd
sw $t5, 0($t3)
addi $t3, $t4, 17316
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 17320
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 17324
li $t5,0x131313
sw $t5, 0($t3)
addi $t3, $t4, 17328
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 17332
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 17336
sw $t5, 0($t3)
addi $t3, $t4, 17340
sw $t5, 0($t3)
addi $t3, $t4, 17344
sw $t5, 0($t3)
addi $t3, $t4, 17348
sw $t5, 0($t3)
addi $t3, $t4, 17352
li $t5,0xb8b8b8
sw $t5, 0($t3)
addi $t3, $t4, 17356
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 17360
sw $t5, 0($t3)
addi $t3, $t4, 17364
sw $t5, 0($t3)
addi $t3, $t4, 17368
li $t5,0x020202
sw $t5, 0($t3)
addi $t3, $t4, 17372
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 17376
sw $t5, 0($t3)
addi $t3, $t4, 17380
li $t5,0x020202
sw $t5, 0($t3)
addi $t3, $t4, 17384
li $t5,0xbebebe
sw $t5, 0($t3)
addi $t3, $t4, 17388
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 17392
sw $t5, 0($t3)
addi $t3, $t4, 17396
sw $t5, 0($t3)
addi $t3, $t4, 17400
sw $t5, 0($t3)
addi $t3, $t4, 17404
sw $t5, 0($t3)
addi $t3, $t4, 17408
sw $t5, 0($t3)
addi $t3, $t4, 17412
sw $t5, 0($t3)
addi $t3, $t4, 17416
sw $t5, 0($t3)
addi $t3, $t4, 17420
sw $t5, 0($t3)
addi $t3, $t4, 17424
sw $t5, 0($t3)
addi $t3, $t4, 17428
li $t5,0xf5f5f5
sw $t5, 0($t3)
addi $t3, $t4, 17432
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 17436
sw $t5, 0($t3)
addi $t3, $t4, 17440
sw $t5, 0($t3)
addi $t3, $t4, 17444
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 17448
li $t5,0x0b0b0b
sw $t5, 0($t3)
addi $t3, $t4, 17452
li $t5,0xfdfdfd
sw $t5, 0($t3)
addi $t3, $t4, 17456
li $t5,0xfffffe
sw $t5, 0($t3)
addi $t3, $t4, 17460
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 17464
li $t5,0xfffffe
sw $t5, 0($t3)
addi $t3, $t4, 17468
li $t5,0xdbdbdb
sw $t5, 0($t3)
addi $t3, $t4, 17472
li $t5,0x020202
sw $t5, 0($t3)
addi $t3, $t4, 17476
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 17480
sw $t5, 0($t3)
addi $t3, $t4, 17484
sw $t5, 0($t3)
addi $t3, $t4, 17488
li $t5,0x020202
sw $t5, 0($t3)
addi $t3, $t4, 17492
li $t5,0xc8c8c8
sw $t5, 0($t3)
addi $t3, $t4, 17496
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 17500
li $t5,0xb8b8b8
sw $t5, 0($t3)
addi $t3, $t4, 17504
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 17508
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 17512
sw $t5, 0($t3)
addi $t3, $t4, 17516
sw $t5, 0($t3)
addi $t3, $t4, 17520
li $t5,0x020202
sw $t5, 0($t3)
addi $t3, $t4, 17524
li $t5,0xeaeaea
sw $t5, 0($t3)
addi $t3, $t4, 17528
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 17532
sw $t5, 0($t3)
addi $t3, $t4, 17536
li $t5,0xc6c6c6
sw $t5, 0($t3)
addi $t3, $t4, 17540
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 17544
sw $t5, 0($t3)
addi $t3, $t4, 17548
sw $t5, 0($t3)
addi $t3, $t4, 17552
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 17556
li $t5,0xc8c8c8
sw $t5, 0($t3)
addi $t3, $t4, 17560
li $t5,0xd3d3d3
sw $t5, 0($t3)
addi $t3, $t4, 17564
li $t5,0x030303
sw $t5, 0($t3)
addi $t3, $t4, 17568
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 17572
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 17576
sw $t5, 0($t3)
addi $t3, $t4, 17580
li $t5,0x080808
sw $t5, 0($t3)
addi $t3, $t4, 17584
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 17588
sw $t5, 0($t3)
addi $t3, $t4, 17592
sw $t5, 0($t3)
addi $t3, $t4, 17596
sw $t5, 0($t3)
addi $t3, $t4, 17600
sw $t5, 0($t3)
addi $t3, $t4, 17604
li $t5,0xe2e2e2
sw $t5, 0($t3)
addi $t3, $t4, 17608
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 17612
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 17616
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 17620
li $t5,0x111111
sw $t5, 0($t3)
addi $t3, $t4, 17624
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 17628
sw $t5, 0($t3)
addi $t3, $t4, 17632
sw $t5, 0($t3)
addi $t3, $t4, 17636
sw $t5, 0($t3)
addi $t3, $t4, 17640
sw $t5, 0($t3)
addi $t3, $t4, 17644
sw $t5, 0($t3)
addi $t3, $t4, 17648
sw $t5, 0($t3)
addi $t3, $t4, 17652
sw $t5, 0($t3)
addi $t3, $t4, 17656
sw $t5, 0($t3)
addi $t3, $t4, 17660
sw $t5, 0($t3)
addi $t3, $t4, 17664
li $t5,0x909090
sw $t5, 0($t3)
addi $t3, $t4, 17668
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 17672
sw $t5, 0($t3)
addi $t3, $t4, 17676
sw $t5, 0($t3)
addi $t3, $t4, 17680
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 17684
li $t5,0xbdbdbd
sw $t5, 0($t3)
addi $t3, $t4, 17688
li $t5,0x2b2b2b
sw $t5, 0($t3)
addi $t3, $t4, 17692
li $t5,0x060606
sw $t5, 0($t3)
addi $t3, $t4, 17696
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 17700
sw $t5, 0($t3)
addi $t3, $t4, 17704
li $t5,0x8d8d8d
sw $t5, 0($t3)
addi $t3, $t4, 17708
li $t5,0xfdfdfd
sw $t5, 0($t3)
addi $t3, $t4, 17712
li $t5,0x030303
sw $t5, 0($t3)
addi $t3, $t4, 17716
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 17720
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 17724
sw $t5, 0($t3)
addi $t3, $t4, 17728
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 17732
sw $t5, 0($t3)
addi $t3, $t4, 17736
sw $t5, 0($t3)
addi $t3, $t4, 17740
sw $t5, 0($t3)
addi $t3, $t4, 17744
li $t5,0x020202
sw $t5, 0($t3)
addi $t3, $t4, 17748
li $t5,0x898989
sw $t5, 0($t3)
addi $t3, $t4, 17752
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 17756
sw $t5, 0($t3)
addi $t3, $t4, 17760
li $t5,0x6e6e6e
sw $t5, 0($t3)
addi $t3, $t4, 17764
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 17768
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 17772
sw $t5, 0($t3)
addi $t3, $t4, 17776
sw $t5, 0($t3)
addi $t3, $t4, 17780
li $t5,0x6c6c6c
sw $t5, 0($t3)
addi $t3, $t4, 17784
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 17788
sw $t5, 0($t3)
addi $t3, $t4, 17792
sw $t5, 0($t3)
addi $t3, $t4, 17796
li $t5,0xa2a2a2
sw $t5, 0($t3)
addi $t3, $t4, 17800
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 17804
sw $t5, 0($t3)
addi $t3, $t4, 17808
sw $t5, 0($t3)
addi $t3, $t4, 17812
sw $t5, 0($t3)
addi $t3, $t4, 17816
li $t5,0x080808
sw $t5, 0($t3)
addi $t3, $t4, 17820
li $t5,0x898989
sw $t5, 0($t3)
addi $t3, $t4, 17824
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 17828
sw $t5, 0($t3)
addi $t3, $t4, 17832
sw $t5, 0($t3)
addi $t3, $t4, 17836
li $t5,0x828282
sw $t5, 0($t3)
addi $t3, $t4, 17840
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 17844
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 17848
sw $t5, 0($t3)
addi $t3, $t4, 17852
sw $t5, 0($t3)
addi $t3, $t4, 17856
sw $t5, 0($t3)
addi $t3, $t4, 17860
sw $t5, 0($t3)
addi $t3, $t4, 17864
li $t5,0xebebeb
sw $t5, 0($t3)
addi $t3, $t4, 17868
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 17872
sw $t5, 0($t3)
addi $t3, $t4, 17876
sw $t5, 0($t3)
addi $t3, $t4, 17880
li $t5,0x2d2d2d
sw $t5, 0($t3)
addi $t3, $t4, 17884
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 17888
sw $t5, 0($t3)
addi $t3, $t4, 17892
li $t5,0x020202
sw $t5, 0($t3)
addi $t3, $t4, 17896
li $t5,0xe8e8e8
sw $t5, 0($t3)
addi $t3, $t4, 17900
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 17904
sw $t5, 0($t3)
addi $t3, $t4, 17908
sw $t5, 0($t3)
addi $t3, $t4, 17912
sw $t5, 0($t3)
addi $t3, $t4, 17916
sw $t5, 0($t3)
addi $t3, $t4, 17920
sw $t5, 0($t3)
addi $t3, $t4, 17924
sw $t5, 0($t3)
addi $t3, $t4, 17928
sw $t5, 0($t3)
addi $t3, $t4, 17932
sw $t5, 0($t3)
addi $t3, $t4, 17936
sw $t5, 0($t3)
addi $t3, $t4, 17940
li $t5,0xe7e7e7
sw $t5, 0($t3)
addi $t3, $t4, 17944
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 17948
sw $t5, 0($t3)
addi $t3, $t4, 17952
sw $t5, 0($t3)
addi $t3, $t4, 17956
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 17960
li $t5,0x080808
sw $t5, 0($t3)
addi $t3, $t4, 17964
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 17968
sw $t5, 0($t3)
addi $t3, $t4, 17972
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 17976
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 17980
li $t5,0x292929
sw $t5, 0($t3)
addi $t3, $t4, 17984
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 17988
sw $t5, 0($t3)
addi $t3, $t4, 17992
sw $t5, 0($t3)
addi $t3, $t4, 17996
sw $t5, 0($t3)
addi $t3, $t4, 18000
sw $t5, 0($t3)
addi $t3, $t4, 18004
li $t5,0xe3e3e3
sw $t5, 0($t3)
addi $t3, $t4, 18008
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 18012
li $t5,0x141414
sw $t5, 0($t3)
addi $t3, $t4, 18016
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 18020
sw $t5, 0($t3)
addi $t3, $t4, 18024
sw $t5, 0($t3)
addi $t3, $t4, 18028
sw $t5, 0($t3)
addi $t3, $t4, 18032
li $t5,0x373737
sw $t5, 0($t3)
addi $t3, $t4, 18036
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 18040
sw $t5, 0($t3)
addi $t3, $t4, 18044
sw $t5, 0($t3)
addi $t3, $t4, 18048
li $t5,0xa7a7a7
sw $t5, 0($t3)
addi $t3, $t4, 18052
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 18056
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 18060
sw $t5, 0($t3)
addi $t3, $t4, 18064
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 18068
li $t5,0xe2e2e2
sw $t5, 0($t3)
addi $t3, $t4, 18072
li $t5,0xaaaaaa
sw $t5, 0($t3)
addi $t3, $t4, 18076
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 18080
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 18084
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 18088
sw $t5, 0($t3)
addi $t3, $t4, 18092
li $t5,0x191919
sw $t5, 0($t3)
addi $t3, $t4, 18096
li $t5,0xfbfbfb
sw $t5, 0($t3)
addi $t3, $t4, 18100
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 18104
sw $t5, 0($t3)
addi $t3, $t4, 18108
sw $t5, 0($t3)
addi $t3, $t4, 18112
sw $t5, 0($t3)
addi $t3, $t4, 18116
li $t5,0x5f5f5f
sw $t5, 0($t3)
addi $t3, $t4, 18120
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 18124
sw $t5, 0($t3)
addi $t3, $t4, 18128
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 18132
li $t5,0x434343
sw $t5, 0($t3)
addi $t3, $t4, 18136
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 18140
sw $t5, 0($t3)
addi $t3, $t4, 18144
sw $t5, 0($t3)
addi $t3, $t4, 18148
sw $t5, 0($t3)
addi $t3, $t4, 18152
sw $t5, 0($t3)
addi $t3, $t4, 18156
sw $t5, 0($t3)
addi $t3, $t4, 18160
sw $t5, 0($t3)
addi $t3, $t4, 18164
sw $t5, 0($t3)
addi $t3, $t4, 18168
sw $t5, 0($t3)
addi $t3, $t4, 18172
sw $t5, 0($t3)
addi $t3, $t4, 18176
li $t5,0xbfbfbf
sw $t5, 0($t3)
addi $t3, $t4, 18180
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 18184
sw $t5, 0($t3)
addi $t3, $t4, 18188
sw $t5, 0($t3)
addi $t3, $t4, 18192
sw $t5, 0($t3)
addi $t3, $t4, 18196
li $t5,0xd5d5d5
sw $t5, 0($t3)
addi $t3, $t4, 18200
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 18204
li $t5,0x202020
sw $t5, 0($t3)
addi $t3, $t4, 18208
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 18212
li $t5,0x030303
sw $t5, 0($t3)
addi $t3, $t4, 18216
li $t5,0xbebebe
sw $t5, 0($t3)
addi $t3, $t4, 18220
li $t5,0xfbfbfb
sw $t5, 0($t3)
addi $t3, $t4, 18224
li $t5,0x060606
sw $t5, 0($t3)
addi $t3, $t4, 18228
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 18232
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 18236
sw $t5, 0($t3)
addi $t3, $t4, 18240
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 18244
sw $t5, 0($t3)
addi $t3, $t4, 18248
sw $t5, 0($t3)
addi $t3, $t4, 18252
sw $t5, 0($t3)
addi $t3, $t4, 18256
li $t5,0x090909
sw $t5, 0($t3)
addi $t3, $t4, 18260
li $t5,0xb3b3b3
sw $t5, 0($t3)
addi $t3, $t4, 18264
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 18268
sw $t5, 0($t3)
addi $t3, $t4, 18272
li $t5,0x303030
sw $t5, 0($t3)
addi $t3, $t4, 18276
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 18280
sw $t5, 0($t3)
addi $t3, $t4, 18284
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 18288
li $t5,0x030303
sw $t5, 0($t3)
addi $t3, $t4, 18292
li $t5,0x9e9e9e
sw $t5, 0($t3)
addi $t3, $t4, 18296
li $t5,0xfcfcfc
sw $t5, 0($t3)
addi $t3, $t4, 18300
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 18304
sw $t5, 0($t3)
addi $t3, $t4, 18308
li $t5,0x545454
sw $t5, 0($t3)
addi $t3, $t4, 18312
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 18316
sw $t5, 0($t3)
addi $t3, $t4, 18320
sw $t5, 0($t3)
addi $t3, $t4, 18324
sw $t5, 0($t3)
addi $t3, $t4, 18328
li $t5,0x1e1e1e
sw $t5, 0($t3)
addi $t3, $t4, 18332
li $t5,0xe9e9e9
sw $t5, 0($t3)
addi $t3, $t4, 18336
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 18340
sw $t5, 0($t3)
addi $t3, $t4, 18344
sw $t5, 0($t3)
addi $t3, $t4, 18348
li $t5,0xf9f9f9
sw $t5, 0($t3)
addi $t3, $t4, 18352
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 18356
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 18360
sw $t5, 0($t3)
addi $t3, $t4, 18364
sw $t5, 0($t3)
addi $t3, $t4, 18368
sw $t5, 0($t3)
addi $t3, $t4, 18372
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 18376
li $t5,0xfbfbfb
sw $t5, 0($t3)
addi $t3, $t4, 18380
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 18384
sw $t5, 0($t3)
addi $t3, $t4, 18388
sw $t5, 0($t3)
addi $t3, $t4, 18392
li $t5,0xbababa
sw $t5, 0($t3)
addi $t3, $t4, 18396
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 18400
sw $t5, 0($t3)
addi $t3, $t4, 18404
li $t5,0x020202
sw $t5, 0($t3)
addi $t3, $t4, 18408
li $t5,0xf9f9f9
sw $t5, 0($t3)
addi $t3, $t4, 18412
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 18416
sw $t5, 0($t3)
addi $t3, $t4, 18420
sw $t5, 0($t3)
addi $t3, $t4, 18424
sw $t5, 0($t3)
addi $t3, $t4, 18428
sw $t5, 0($t3)
addi $t3, $t4, 18432
sw $t5, 0($t3)
addi $t3, $t4, 18436
sw $t5, 0($t3)
addi $t3, $t4, 18440
sw $t5, 0($t3)
addi $t3, $t4, 18444
sw $t5, 0($t3)
addi $t3, $t4, 18448
sw $t5, 0($t3)
addi $t3, $t4, 18452
li $t5,0xe2e2e2
sw $t5, 0($t3)
addi $t3, $t4, 18456
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 18460
sw $t5, 0($t3)
addi $t3, $t4, 18464
sw $t5, 0($t3)
addi $t3, $t4, 18468
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 18472
li $t5,0x020202
sw $t5, 0($t3)
addi $t3, $t4, 18476
li $t5,0xfdfdfd
sw $t5, 0($t3)
addi $t3, $t4, 18480
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 18484
sw $t5, 0($t3)
addi $t3, $t4, 18488
sw $t5, 0($t3)
addi $t3, $t4, 18492
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 18496
sw $t5, 0($t3)
addi $t3, $t4, 18500
sw $t5, 0($t3)
addi $t3, $t4, 18504
sw $t5, 0($t3)
addi $t3, $t4, 18508
sw $t5, 0($t3)
addi $t3, $t4, 18512
sw $t5, 0($t3)
addi $t3, $t4, 18516
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 18520
li $t5,0xf8f8f8
sw $t5, 0($t3)
addi $t3, $t4, 18524
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 18528
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 18532
sw $t5, 0($t3)
addi $t3, $t4, 18536
sw $t5, 0($t3)
addi $t3, $t4, 18540
sw $t5, 0($t3)
addi $t3, $t4, 18544
li $t5,0x666666
sw $t5, 0($t3)
addi $t3, $t4, 18548
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 18552
sw $t5, 0($t3)
addi $t3, $t4, 18556
sw $t5, 0($t3)
addi $t3, $t4, 18560
li $t5,0x565656
sw $t5, 0($t3)
addi $t3, $t4, 18564
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 18568
sw $t5, 0($t3)
addi $t3, $t4, 18572
sw $t5, 0($t3)
addi $t3, $t4, 18576
li $t5,0x030303
sw $t5, 0($t3)
addi $t3, $t4, 18580
li $t5,0xf2f2f2
sw $t5, 0($t3)
addi $t3, $t4, 18584
li $t5,0x676767
sw $t5, 0($t3)
addi $t3, $t4, 18588
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 18592
sw $t5, 0($t3)
addi $t3, $t4, 18596
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 18600
sw $t5, 0($t3)
addi $t3, $t4, 18604
li $t5,0x515151
sw $t5, 0($t3)
addi $t3, $t4, 18608
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 18612
sw $t5, 0($t3)
addi $t3, $t4, 18616
sw $t5, 0($t3)
addi $t3, $t4, 18620
sw $t5, 0($t3)
addi $t3, $t4, 18624
li $t5,0xfcfcfc
sw $t5, 0($t3)
addi $t3, $t4, 18628
li $t5,0x060606
sw $t5, 0($t3)
addi $t3, $t4, 18632
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 18636
sw $t5, 0($t3)
addi $t3, $t4, 18640
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 18644
li $t5,0x757575
sw $t5, 0($t3)
addi $t3, $t4, 18648
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 18652
sw $t5, 0($t3)
addi $t3, $t4, 18656
sw $t5, 0($t3)
addi $t3, $t4, 18660
sw $t5, 0($t3)
addi $t3, $t4, 18664
sw $t5, 0($t3)
addi $t3, $t4, 18668
sw $t5, 0($t3)
addi $t3, $t4, 18672
sw $t5, 0($t3)
addi $t3, $t4, 18676
sw $t5, 0($t3)
addi $t3, $t4, 18680
sw $t5, 0($t3)
addi $t3, $t4, 18684
sw $t5, 0($t3)
addi $t3, $t4, 18688
li $t5,0xdfdfdf
sw $t5, 0($t3)
addi $t3, $t4, 18692
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 18696
sw $t5, 0($t3)
addi $t3, $t4, 18700
sw $t5, 0($t3)
addi $t3, $t4, 18704
sw $t5, 0($t3)
addi $t3, $t4, 18708
sw $t5, 0($t3)
addi $t3, $t4, 18712
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 18716
li $t5,0x020202
sw $t5, 0($t3)
addi $t3, $t4, 18720
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 18724
li $t5,0x171717
sw $t5, 0($t3)
addi $t3, $t4, 18728
li $t5,0xf8f8f8
sw $t5, 0($t3)
addi $t3, $t4, 18732
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 18736
li $t5,0x1f1f1f
sw $t5, 0($t3)
addi $t3, $t4, 18740
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 18744
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 18748
sw $t5, 0($t3)
addi $t3, $t4, 18752
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 18756
sw $t5, 0($t3)
addi $t3, $t4, 18760
sw $t5, 0($t3)
addi $t3, $t4, 18764
sw $t5, 0($t3)
addi $t3, $t4, 18768
li $t5,0x737373
sw $t5, 0($t3)
addi $t3, $t4, 18772
li $t5,0xfdfdfd
sw $t5, 0($t3)
addi $t3, $t4, 18776
sw $t5, 0($t3)
addi $t3, $t4, 18780
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 18784
li $t5,0x020202
sw $t5, 0($t3)
addi $t3, $t4, 18788
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 18792
sw $t5, 0($t3)
addi $t3, $t4, 18796
sw $t5, 0($t3)
addi $t3, $t4, 18800
li $t5,0x030303
sw $t5, 0($t3)
addi $t3, $t4, 18804
li $t5,0x6d6d6d
sw $t5, 0($t3)
addi $t3, $t4, 18808
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 18812
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 18816
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 18820
li $t5,0x1b1b1b
sw $t5, 0($t3)
addi $t3, $t4, 18824
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 18828
sw $t5, 0($t3)
addi $t3, $t4, 18832
sw $t5, 0($t3)
addi $t3, $t4, 18836
sw $t5, 0($t3)
addi $t3, $t4, 18840
li $t5,0x767676
sw $t5, 0($t3)
addi $t3, $t4, 18844
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 18848
sw $t5, 0($t3)
addi $t3, $t4, 18852
sw $t5, 0($t3)
addi $t3, $t4, 18856
sw $t5, 0($t3)
addi $t3, $t4, 18860
sw $t5, 0($t3)
addi $t3, $t4, 18864
li $t5,0x4d4d4d
sw $t5, 0($t3)
addi $t3, $t4, 18868
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 18872
sw $t5, 0($t3)
addi $t3, $t4, 18876
sw $t5, 0($t3)
addi $t3, $t4, 18880
sw $t5, 0($t3)
addi $t3, $t4, 18884
li $t5,0x020202
sw $t5, 0($t3)
addi $t3, $t4, 18888
li $t5,0xf2f2f2
sw $t5, 0($t3)
addi $t3, $t4, 18892
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 18896
sw $t5, 0($t3)
addi $t3, $t4, 18900
sw $t5, 0($t3)
addi $t3, $t4, 18904
li $t5,0xfdfdfd
sw $t5, 0($t3)
addi $t3, $t4, 18908
li $t5,0x636363
sw $t5, 0($t3)
addi $t3, $t4, 18912
li $t5,0x020202
sw $t5, 0($t3)
addi $t3, $t4, 18916
li $t5,0x272727
sw $t5, 0($t3)
addi $t3, $t4, 18920
li $t5,0xfbfbfb
sw $t5, 0($t3)
addi $t3, $t4, 18924
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 18928
sw $t5, 0($t3)
addi $t3, $t4, 18932
sw $t5, 0($t3)
addi $t3, $t4, 18936
sw $t5, 0($t3)
addi $t3, $t4, 18940
sw $t5, 0($t3)
addi $t3, $t4, 18944
sw $t5, 0($t3)
addi $t3, $t4, 18948
sw $t5, 0($t3)
addi $t3, $t4, 18952
sw $t5, 0($t3)
addi $t3, $t4, 18956
sw $t5, 0($t3)
addi $t3, $t4, 18960
sw $t5, 0($t3)
addi $t3, $t4, 18964
li $t5,0xe9e9e9
sw $t5, 0($t3)
addi $t3, $t4, 18968
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 18972
sw $t5, 0($t3)
addi $t3, $t4, 18976
sw $t5, 0($t3)
addi $t3, $t4, 18980
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 18984
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 18988
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 18992
sw $t5, 0($t3)
addi $t3, $t4, 18996
sw $t5, 0($t3)
addi $t3, $t4, 19000
li $t5,0xcacaca
sw $t5, 0($t3)
addi $t3, $t4, 19004
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 19008
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 19012
sw $t5, 0($t3)
addi $t3, $t4, 19016
sw $t5, 0($t3)
addi $t3, $t4, 19020
sw $t5, 0($t3)
addi $t3, $t4, 19024
li $t5,0x070707
sw $t5, 0($t3)
addi $t3, $t4, 19028
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 19032
li $t5,0xcccccc
sw $t5, 0($t3)
addi $t3, $t4, 19036
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 19040
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 19044
sw $t5, 0($t3)
addi $t3, $t4, 19048
sw $t5, 0($t3)
addi $t3, $t4, 19052
sw $t5, 0($t3)
addi $t3, $t4, 19056
li $t5,0xececec
sw $t5, 0($t3)
addi $t3, $t4, 19060
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 19064
sw $t5, 0($t3)
addi $t3, $t4, 19068
li $t5,0xfdfdfd
sw $t5, 0($t3)
addi $t3, $t4, 19072
li $t5,0x131313
sw $t5, 0($t3)
addi $t3, $t4, 19076
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 19080
sw $t5, 0($t3)
addi $t3, $t4, 19084
sw $t5, 0($t3)
addi $t3, $t4, 19088
li $t5,0x020202
sw $t5, 0($t3)
addi $t3, $t4, 19092
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 19096
li $t5,0x252525
sw $t5, 0($t3)
addi $t3, $t4, 19100
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 19104
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 19108
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 19112
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 19116
li $t5,0x929292
sw $t5, 0($t3)
addi $t3, $t4, 19120
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 19124
sw $t5, 0($t3)
addi $t3, $t4, 19128
sw $t5, 0($t3)
addi $t3, $t4, 19132
sw $t5, 0($t3)
addi $t3, $t4, 19136
li $t5,0xfafafa
sw $t5, 0($t3)
addi $t3, $t4, 19140
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 19144
sw $t5, 0($t3)
addi $t3, $t4, 19148
sw $t5, 0($t3)
addi $t3, $t4, 19152
sw $t5, 0($t3)
addi $t3, $t4, 19156
li $t5,0xacacac
sw $t5, 0($t3)
addi $t3, $t4, 19160
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 19164
sw $t5, 0($t3)
addi $t3, $t4, 19168
sw $t5, 0($t3)
addi $t3, $t4, 19172
sw $t5, 0($t3)
addi $t3, $t4, 19176
sw $t5, 0($t3)
addi $t3, $t4, 19180
sw $t5, 0($t3)
addi $t3, $t4, 19184
sw $t5, 0($t3)
addi $t3, $t4, 19188
sw $t5, 0($t3)
addi $t3, $t4, 19192
sw $t5, 0($t3)
addi $t3, $t4, 19196
sw $t5, 0($t3)
addi $t3, $t4, 19200
li $t5,0xededed
sw $t5, 0($t3)
addi $t3, $t4, 19204
li $t5,0x020202
sw $t5, 0($t3)
addi $t3, $t4, 19208
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 19212
sw $t5, 0($t3)
addi $t3, $t4, 19216
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 19220
sw $t5, 0($t3)
addi $t3, $t4, 19224
sw $t5, 0($t3)
addi $t3, $t4, 19228
sw $t5, 0($t3)
addi $t3, $t4, 19232
sw $t5, 0($t3)
addi $t3, $t4, 19236
li $t5,0x717171
sw $t5, 0($t3)
addi $t3, $t4, 19240
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 19244
sw $t5, 0($t3)
addi $t3, $t4, 19248
li $t5,0x636363
sw $t5, 0($t3)
addi $t3, $t4, 19252
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 19256
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 19260
sw $t5, 0($t3)
addi $t3, $t4, 19264
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 19268
sw $t5, 0($t3)
addi $t3, $t4, 19272
sw $t5, 0($t3)
addi $t3, $t4, 19276
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 19280
li $t5,0x7c7c7c
sw $t5, 0($t3)
addi $t3, $t4, 19284
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 19288
sw $t5, 0($t3)
addi $t3, $t4, 19292
sw $t5, 0($t3)
addi $t3, $t4, 19296
li $t5,0x030303
sw $t5, 0($t3)
addi $t3, $t4, 19300
sw $t5, 0($t3)
addi $t3, $t4, 19304
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 19308
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 19312
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 19316
li $t5,0x989898
sw $t5, 0($t3)
addi $t3, $t4, 19320
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 19324
sw $t5, 0($t3)
addi $t3, $t4, 19328
li $t5,0xfcfcfc
sw $t5, 0($t3)
addi $t3, $t4, 19332
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 19336
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 19340
sw $t5, 0($t3)
addi $t3, $t4, 19344
sw $t5, 0($t3)
addi $t3, $t4, 19348
li $t5,0x020202
sw $t5, 0($t3)
addi $t3, $t4, 19352
li $t5,0x7f7f7f
sw $t5, 0($t3)
addi $t3, $t4, 19356
li $t5,0xfdfdfd
sw $t5, 0($t3)
addi $t3, $t4, 19360
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 19364
sw $t5, 0($t3)
addi $t3, $t4, 19368
sw $t5, 0($t3)
addi $t3, $t4, 19372
sw $t5, 0($t3)
addi $t3, $t4, 19376
li $t5,0xfafafa
sw $t5, 0($t3)
addi $t3, $t4, 19380
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 19384
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 19388
sw $t5, 0($t3)
addi $t3, $t4, 19392
sw $t5, 0($t3)
addi $t3, $t4, 19396
li $t5,0x020202
sw $t5, 0($t3)
addi $t3, $t4, 19400
li $t5,0xf5f5f5
sw $t5, 0($t3)
addi $t3, $t4, 19404
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 19408
sw $t5, 0($t3)
addi $t3, $t4, 19412
sw $t5, 0($t3)
addi $t3, $t4, 19416
sw $t5, 0($t3)
addi $t3, $t4, 19420
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 19424
li $t5,0x5b5b5b
sw $t5, 0($t3)
addi $t3, $t4, 19428
li $t5,0x575757
sw $t5, 0($t3)
addi $t3, $t4, 19432
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 19436
sw $t5, 0($t3)
addi $t3, $t4, 19440
sw $t5, 0($t3)
addi $t3, $t4, 19444
sw $t5, 0($t3)
addi $t3, $t4, 19448
sw $t5, 0($t3)
addi $t3, $t4, 19452
sw $t5, 0($t3)
addi $t3, $t4, 19456
sw $t5, 0($t3)
addi $t3, $t4, 19460
sw $t5, 0($t3)
addi $t3, $t4, 19464
sw $t5, 0($t3)
addi $t3, $t4, 19468
sw $t5, 0($t3)
addi $t3, $t4, 19472
sw $t5, 0($t3)
addi $t3, $t4, 19476
li $t5,0xeeeeee
sw $t5, 0($t3)
addi $t3, $t4, 19480
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 19484
sw $t5, 0($t3)
addi $t3, $t4, 19488
sw $t5, 0($t3)
addi $t3, $t4, 19492
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 19496
li $t5,0x040404
sw $t5, 0($t3)
addi $t3, $t4, 19500
li $t5,0xfffffe
sw $t5, 0($t3)
addi $t3, $t4, 19504
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 19508
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 19512
li $t5,0x515151
sw $t5, 0($t3)
addi $t3, $t4, 19516
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 19520
sw $t5, 0($t3)
addi $t3, $t4, 19524
sw $t5, 0($t3)
addi $t3, $t4, 19528
sw $t5, 0($t3)
addi $t3, $t4, 19532
sw $t5, 0($t3)
addi $t3, $t4, 19536
li $t5,0x585858
sw $t5, 0($t3)
addi $t3, $t4, 19540
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 19544
li $t5,0x1f1f1f
sw $t5, 0($t3)
addi $t3, $t4, 19548
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 19552
sw $t5, 0($t3)
addi $t3, $t4, 19556
sw $t5, 0($t3)
addi $t3, $t4, 19560
sw $t5, 0($t3)
addi $t3, $t4, 19564
sw $t5, 0($t3)
addi $t3, $t4, 19568
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 19572
sw $t5, 0($t3)
addi $t3, $t4, 19576
sw $t5, 0($t3)
addi $t3, $t4, 19580
li $t5,0xfcfcfc
sw $t5, 0($t3)
addi $t3, $t4, 19584
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 19588
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 19592
sw $t5, 0($t3)
addi $t3, $t4, 19596
sw $t5, 0($t3)
addi $t3, $t4, 19600
li $t5,0x030303
sw $t5, 0($t3)
addi $t3, $t4, 19604
li $t5,0xfdfdfd
sw $t5, 0($t3)
addi $t3, $t4, 19608
li $t5,0x0e0e0e
sw $t5, 0($t3)
addi $t3, $t4, 19612
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 19616
sw $t5, 0($t3)
addi $t3, $t4, 19620
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 19624
sw $t5, 0($t3)
addi $t3, $t4, 19628
li $t5,0xe9e9e9
sw $t5, 0($t3)
addi $t3, $t4, 19632
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 19636
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 19640
sw $t5, 0($t3)
addi $t3, $t4, 19644
sw $t5, 0($t3)
addi $t3, $t4, 19648
li $t5,0x888888
sw $t5, 0($t3)
addi $t3, $t4, 19652
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 19656
sw $t5, 0($t3)
addi $t3, $t4, 19660
sw $t5, 0($t3)
addi $t3, $t4, 19664
sw $t5, 0($t3)
addi $t3, $t4, 19668
li $t5,0xebebeb
sw $t5, 0($t3)
addi $t3, $t4, 19672
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 19676
sw $t5, 0($t3)
addi $t3, $t4, 19680
sw $t5, 0($t3)
addi $t3, $t4, 19684
sw $t5, 0($t3)
addi $t3, $t4, 19688
sw $t5, 0($t3)
addi $t3, $t4, 19692
sw $t5, 0($t3)
addi $t3, $t4, 19696
sw $t5, 0($t3)
addi $t3, $t4, 19700
sw $t5, 0($t3)
addi $t3, $t4, 19704
sw $t5, 0($t3)
addi $t3, $t4, 19708
sw $t5, 0($t3)
addi $t3, $t4, 19712
li $t5,0xfbfbfb
sw $t5, 0($t3)
addi $t3, $t4, 19716
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 19720
sw $t5, 0($t3)
addi $t3, $t4, 19724
sw $t5, 0($t3)
addi $t3, $t4, 19728
sw $t5, 0($t3)
addi $t3, $t4, 19732
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 19736
sw $t5, 0($t3)
addi $t3, $t4, 19740
sw $t5, 0($t3)
addi $t3, $t4, 19744
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 19748
li $t5,0x919191
sw $t5, 0($t3)
addi $t3, $t4, 19752
li $t5,0xfdfcfc
sw $t5, 0($t3)
addi $t3, $t4, 19756
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 19760
li $t5,0xadadad
sw $t5, 0($t3)
addi $t3, $t4, 19764
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 19768
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 19772
sw $t5, 0($t3)
addi $t3, $t4, 19776
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 19780
sw $t5, 0($t3)
addi $t3, $t4, 19784
sw $t5, 0($t3)
addi $t3, $t4, 19788
li $t5,0x060606
sw $t5, 0($t3)
addi $t3, $t4, 19792
li $t5,0xcbcbcb
sw $t5, 0($t3)
addi $t3, $t4, 19796
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 19800
sw $t5, 0($t3)
addi $t3, $t4, 19804
sw $t5, 0($t3)
addi $t3, $t4, 19808
li $t5,0xd8d8d8
sw $t5, 0($t3)
addi $t3, $t4, 19812
li $t5,0x8e8e8e
sw $t5, 0($t3)
addi $t3, $t4, 19816
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 19820
li $t5,0x020202
sw $t5, 0($t3)
addi $t3, $t4, 19824
li $t5,0x1a1a1a
sw $t5, 0($t3)
addi $t3, $t4, 19828
li $t5,0xe1e1e1
sw $t5, 0($t3)
addi $t3, $t4, 19832
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 19836
sw $t5, 0($t3)
addi $t3, $t4, 19840
sw $t5, 0($t3)
addi $t3, $t4, 19844
li $t5,0x020202
sw $t5, 0($t3)
addi $t3, $t4, 19848
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 19852
sw $t5, 0($t3)
addi $t3, $t4, 19856
sw $t5, 0($t3)
addi $t3, $t4, 19860
sw $t5, 0($t3)
addi $t3, $t4, 19864
li $t5,0x656565
sw $t5, 0($t3)
addi $t3, $t4, 19868
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 19872
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 19876
sw $t5, 0($t3)
addi $t3, $t4, 19880
sw $t5, 0($t3)
addi $t3, $t4, 19884
sw $t5, 0($t3)
addi $t3, $t4, 19888
sw $t5, 0($t3)
addi $t3, $t4, 19892
li $t5,0x818181
sw $t5, 0($t3)
addi $t3, $t4, 19896
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 19900
sw $t5, 0($t3)
addi $t3, $t4, 19904
sw $t5, 0($t3)
addi $t3, $t4, 19908
li $t5,0x020202
sw $t5, 0($t3)
addi $t3, $t4, 19912
li $t5,0xfdfdfd
sw $t5, 0($t3)
addi $t3, $t4, 19916
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 19920
sw $t5, 0($t3)
addi $t3, $t4, 19924
sw $t5, 0($t3)
addi $t3, $t4, 19928
sw $t5, 0($t3)
addi $t3, $t4, 19932
sw $t5, 0($t3)
addi $t3, $t4, 19936
sw $t5, 0($t3)
addi $t3, $t4, 19940
li $t5,0xfefdfd
sw $t5, 0($t3)
addi $t3, $t4, 19944
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 19948
sw $t5, 0($t3)
addi $t3, $t4, 19952
sw $t5, 0($t3)
addi $t3, $t4, 19956
sw $t5, 0($t3)
addi $t3, $t4, 19960
sw $t5, 0($t3)
addi $t3, $t4, 19964
sw $t5, 0($t3)
addi $t3, $t4, 19968
sw $t5, 0($t3)
addi $t3, $t4, 19972
sw $t5, 0($t3)
addi $t3, $t4, 19976
sw $t5, 0($t3)
addi $t3, $t4, 19980
sw $t5, 0($t3)
addi $t3, $t4, 19984
sw $t5, 0($t3)
addi $t3, $t4, 19988
li $t5,0xf8f8f8
sw $t5, 0($t3)
addi $t3, $t4, 19992
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 19996
sw $t5, 0($t3)
addi $t3, $t4, 20000
sw $t5, 0($t3)
addi $t3, $t4, 20004
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 20008
sw $t5, 0($t3)
addi $t3, $t4, 20012
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 20016
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 20020
li $t5,0xe5e5e5
sw $t5, 0($t3)
addi $t3, $t4, 20024
li $t5,0x020202
sw $t5, 0($t3)
addi $t3, $t4, 20028
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 20032
sw $t5, 0($t3)
addi $t3, $t4, 20036
sw $t5, 0($t3)
addi $t3, $t4, 20040
sw $t5, 0($t3)
addi $t3, $t4, 20044
li $t5,0x1b1b1b
sw $t5, 0($t3)
addi $t3, $t4, 20048
li $t5,0xe3e3e3
sw $t5, 0($t3)
addi $t3, $t4, 20052
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 20056
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 20060
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 20064
sw $t5, 0($t3)
addi $t3, $t4, 20068
sw $t5, 0($t3)
addi $t3, $t4, 20072
sw $t5, 0($t3)
addi $t3, $t4, 20076
li $t5,0x1d1d1d
sw $t5, 0($t3)
addi $t3, $t4, 20080
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 20084
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 20088
sw $t5, 0($t3)
addi $t3, $t4, 20092
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 20096
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 20100
sw $t5, 0($t3)
addi $t3, $t4, 20104
sw $t5, 0($t3)
addi $t3, $t4, 20108
sw $t5, 0($t3)
addi $t3, $t4, 20112
li $t5,0x515151
sw $t5, 0($t3)
addi $t3, $t4, 20116
li $t5,0xfdfdfd
sw $t5, 0($t3)
addi $t3, $t4, 20120
li $t5,0x090909
sw $t5, 0($t3)
addi $t3, $t4, 20124
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 20128
sw $t5, 0($t3)
addi $t3, $t4, 20132
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 20136
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 20140
li $t5,0xfafafa
sw $t5, 0($t3)
addi $t3, $t4, 20144
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 20148
sw $t5, 0($t3)
addi $t3, $t4, 20152
sw $t5, 0($t3)
addi $t3, $t4, 20156
sw $t5, 0($t3)
addi $t3, $t4, 20160
li $t5,0x131313
sw $t5, 0($t3)
addi $t3, $t4, 20164
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 20168
sw $t5, 0($t3)
addi $t3, $t4, 20172
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 20176
sw $t5, 0($t3)
addi $t3, $t4, 20180
li $t5,0xfdfdfd
sw $t5, 0($t3)
addi $t3, $t4, 20184
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 20188
sw $t5, 0($t3)
addi $t3, $t4, 20192
sw $t5, 0($t3)
addi $t3, $t4, 20196
sw $t5, 0($t3)
addi $t3, $t4, 20200
sw $t5, 0($t3)
addi $t3, $t4, 20204
sw $t5, 0($t3)
addi $t3, $t4, 20208
sw $t5, 0($t3)
addi $t3, $t4, 20212
sw $t5, 0($t3)
addi $t3, $t4, 20216
sw $t5, 0($t3)
addi $t3, $t4, 20220
sw $t5, 0($t3)
addi $t3, $t4, 20224
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 20228
li $t5,0x020202
sw $t5, 0($t3)
addi $t3, $t4, 20232
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 20236
sw $t5, 0($t3)
addi $t3, $t4, 20240
sw $t5, 0($t3)
addi $t3, $t4, 20244
sw $t5, 0($t3)
addi $t3, $t4, 20248
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 20252
sw $t5, 0($t3)
addi $t3, $t4, 20256
li $t5,0x060606
sw $t5, 0($t3)
addi $t3, $t4, 20260
li $t5,0xcfcfcf
sw $t5, 0($t3)
addi $t3, $t4, 20264
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 20268
sw $t5, 0($t3)
addi $t3, $t4, 20272
li $t5,0xe1e1e1
sw $t5, 0($t3)
addi $t3, $t4, 20276
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 20280
sw $t5, 0($t3)
addi $t3, $t4, 20284
sw $t5, 0($t3)
addi $t3, $t4, 20288
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 20292
sw $t5, 0($t3)
addi $t3, $t4, 20296
sw $t5, 0($t3)
addi $t3, $t4, 20300
li $t5,0x6c6c6c
sw $t5, 0($t3)
addi $t3, $t4, 20304
li $t5,0xfbfbfb
sw $t5, 0($t3)
addi $t3, $t4, 20308
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 20312
sw $t5, 0($t3)
addi $t3, $t4, 20316
sw $t5, 0($t3)
addi $t3, $t4, 20320
sw $t5, 0($t3)
addi $t3, $t4, 20324
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 20328
li $t5,0x181818
sw $t5, 0($t3)
addi $t3, $t4, 20332
li $t5,0xc5c5c5
sw $t5, 0($t3)
addi $t3, $t4, 20336
li $t5,0x868686
sw $t5, 0($t3)
addi $t3, $t4, 20340
li $t5,0xfdfdfd
sw $t5, 0($t3)
addi $t3, $t4, 20344
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 20348
sw $t5, 0($t3)
addi $t3, $t4, 20352
li $t5,0xfdfdfd
sw $t5, 0($t3)
addi $t3, $t4, 20356
li $t5,0xb7b7b7
sw $t5, 0($t3)
addi $t3, $t4, 20360
li $t5,0x070707
sw $t5, 0($t3)
addi $t3, $t4, 20364
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 20368
sw $t5, 0($t3)
addi $t3, $t4, 20372
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 20376
li $t5,0xc9c9c9
sw $t5, 0($t3)
addi $t3, $t4, 20380
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 20384
sw $t5, 0($t3)
addi $t3, $t4, 20388
sw $t5, 0($t3)
addi $t3, $t4, 20392
sw $t5, 0($t3)
addi $t3, $t4, 20396
sw $t5, 0($t3)
addi $t3, $t4, 20400
sw $t5, 0($t3)
addi $t3, $t4, 20404
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 20408
li $t5,0xcccccc
sw $t5, 0($t3)
addi $t3, $t4, 20412
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 20416
sw $t5, 0($t3)
addi $t3, $t4, 20420
li $t5,0x040404
sw $t5, 0($t3)
addi $t3, $t4, 20424
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 20428
sw $t5, 0($t3)
addi $t3, $t4, 20432
sw $t5, 0($t3)
addi $t3, $t4, 20436
sw $t5, 0($t3)
addi $t3, $t4, 20440
sw $t5, 0($t3)
addi $t3, $t4, 20444
sw $t5, 0($t3)
addi $t3, $t4, 20448
sw $t5, 0($t3)
addi $t3, $t4, 20452
sw $t5, 0($t3)
addi $t3, $t4, 20456
sw $t5, 0($t3)
addi $t3, $t4, 20460
sw $t5, 0($t3)
addi $t3, $t4, 20464
sw $t5, 0($t3)
addi $t3, $t4, 20468
sw $t5, 0($t3)
addi $t3, $t4, 20472
sw $t5, 0($t3)
addi $t3, $t4, 20476
sw $t5, 0($t3)
addi $t3, $t4, 20480
sw $t5, 0($t3)
addi $t3, $t4, 20484
sw $t5, 0($t3)
addi $t3, $t4, 20488
sw $t5, 0($t3)
addi $t3, $t4, 20492
sw $t5, 0($t3)
addi $t3, $t4, 20496
sw $t5, 0($t3)
addi $t3, $t4, 20500
li $t5,0xfcfcfc
sw $t5, 0($t3)
addi $t3, $t4, 20504
li $t5,0x030303
sw $t5, 0($t3)
addi $t3, $t4, 20508
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 20512
sw $t5, 0($t3)
addi $t3, $t4, 20516
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 20520
sw $t5, 0($t3)
addi $t3, $t4, 20524
li $t5,0xfdfdfd
sw $t5, 0($t3)
addi $t3, $t4, 20528
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 20532
li $t5,0x202020
sw $t5, 0($t3)
addi $t3, $t4, 20536
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 20540
li $t5,0x101010
sw $t5, 0($t3)
addi $t3, $t4, 20544
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 20548
sw $t5, 0($t3)
addi $t3, $t4, 20552
sw $t5, 0($t3)
addi $t3, $t4, 20556
li $t5,0x7b7b7b
sw $t5, 0($t3)
addi $t3, $t4, 20560
li $t5,0xfcfcfc
sw $t5, 0($t3)
addi $t3, $t4, 20564
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 20568
li $t5,0x050505
sw $t5, 0($t3)
addi $t3, $t4, 20572
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 20576
sw $t5, 0($t3)
addi $t3, $t4, 20580
sw $t5, 0($t3)
addi $t3, $t4, 20584
sw $t5, 0($t3)
addi $t3, $t4, 20588
li $t5,0x989898
sw $t5, 0($t3)
addi $t3, $t4, 20592
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 20596
sw $t5, 0($t3)
addi $t3, $t4, 20600
sw $t5, 0($t3)
addi $t3, $t4, 20604
li $t5,0xe6e6e6
sw $t5, 0($t3)
addi $t3, $t4, 20608
li $t5,0x020202
sw $t5, 0($t3)
addi $t3, $t4, 20612
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 20616
sw $t5, 0($t3)
addi $t3, $t4, 20620
sw $t5, 0($t3)
addi $t3, $t4, 20624
li $t5,0xc5c5c5
sw $t5, 0($t3)
addi $t3, $t4, 20628
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 20632
li $t5,0x0b0b0b
sw $t5, 0($t3)
addi $t3, $t4, 20636
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 20640
sw $t5, 0($t3)
addi $t3, $t4, 20644
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 20648
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 20652
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 20656
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 20660
sw $t5, 0($t3)
addi $t3, $t4, 20664
sw $t5, 0($t3)
addi $t3, $t4, 20668
li $t5,0xe3e3e3
sw $t5, 0($t3)
addi $t3, $t4, 20672
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 20676
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 20680
sw $t5, 0($t3)
addi $t3, $t4, 20684
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 20688
sw $t5, 0($t3)
addi $t3, $t4, 20692
li $t5,0xfbfbfb
sw $t5, 0($t3)
addi $t3, $t4, 20696
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 20700
sw $t5, 0($t3)
addi $t3, $t4, 20704
sw $t5, 0($t3)
addi $t3, $t4, 20708
sw $t5, 0($t3)
addi $t3, $t4, 20712
sw $t5, 0($t3)
addi $t3, $t4, 20716
sw $t5, 0($t3)
addi $t3, $t4, 20720
sw $t5, 0($t3)
addi $t3, $t4, 20724
sw $t5, 0($t3)
addi $t3, $t4, 20728
sw $t5, 0($t3)
addi $t3, $t4, 20732
sw $t5, 0($t3)
addi $t3, $t4, 20736
sw $t5, 0($t3)
addi $t3, $t4, 20740
li $t5,0x050505
sw $t5, 0($t3)
addi $t3, $t4, 20744
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 20748
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 20752
sw $t5, 0($t3)
addi $t3, $t4, 20756
sw $t5, 0($t3)
addi $t3, $t4, 20760
sw $t5, 0($t3)
addi $t3, $t4, 20764
sw $t5, 0($t3)
addi $t3, $t4, 20768
li $t5,0x464646
sw $t5, 0($t3)
addi $t3, $t4, 20772
li $t5,0xfbfbfb
sw $t5, 0($t3)
addi $t3, $t4, 20776
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 20780
sw $t5, 0($t3)
addi $t3, $t4, 20784
li $t5,0xfcfcfc
sw $t5, 0($t3)
addi $t3, $t4, 20788
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 20792
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 20796
sw $t5, 0($t3)
addi $t3, $t4, 20800
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 20804
sw $t5, 0($t3)
addi $t3, $t4, 20808
sw $t5, 0($t3)
addi $t3, $t4, 20812
li $t5,0x808080
sw $t5, 0($t3)
addi $t3, $t4, 20816
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 20820
sw $t5, 0($t3)
addi $t3, $t4, 20824
sw $t5, 0($t3)
addi $t3, $t4, 20828
sw $t5, 0($t3)
addi $t3, $t4, 20832
sw $t5, 0($t3)
addi $t3, $t4, 20836
sw $t5, 0($t3)
addi $t3, $t4, 20840
sw $t5, 0($t3)
addi $t3, $t4, 20844
sw $t5, 0($t3)
addi $t3, $t4, 20848
li $t5,0xfdfdfd
sw $t5, 0($t3)
addi $t3, $t4, 20852
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 20856
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 20860
sw $t5, 0($t3)
addi $t3, $t4, 20864
sw $t5, 0($t3)
addi $t3, $t4, 20868
sw $t5, 0($t3)
addi $t3, $t4, 20872
li $t5,0xe4e4e4
sw $t5, 0($t3)
addi $t3, $t4, 20876
li $t5,0x040404
sw $t5, 0($t3)
addi $t3, $t4, 20880
li $t5,0x4f4f4f
sw $t5, 0($t3)
addi $t3, $t4, 20884
li $t5,0x2d2d2d
sw $t5, 0($t3)
addi $t3, $t4, 20888
li $t5,0xededed
sw $t5, 0($t3)
addi $t3, $t4, 20892
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 20896
sw $t5, 0($t3)
addi $t3, $t4, 20900
sw $t5, 0($t3)
addi $t3, $t4, 20904
sw $t5, 0($t3)
addi $t3, $t4, 20908
sw $t5, 0($t3)
addi $t3, $t4, 20912
sw $t5, 0($t3)
addi $t3, $t4, 20916
sw $t5, 0($t3)
addi $t3, $t4, 20920
sw $t5, 0($t3)
addi $t3, $t4, 20924
li $t5,0x5c5c5c
sw $t5, 0($t3)
addi $t3, $t4, 20928
li $t5,0xcdcdcd
sw $t5, 0($t3)
addi $t3, $t4, 20932
li $t5,0x959595
sw $t5, 0($t3)
addi $t3, $t4, 20936
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 20940
sw $t5, 0($t3)
addi $t3, $t4, 20944
sw $t5, 0($t3)
addi $t3, $t4, 20948
sw $t5, 0($t3)
addi $t3, $t4, 20952
sw $t5, 0($t3)
addi $t3, $t4, 20956
sw $t5, 0($t3)
addi $t3, $t4, 20960
sw $t5, 0($t3)
addi $t3, $t4, 20964
sw $t5, 0($t3)
addi $t3, $t4, 20968
sw $t5, 0($t3)
addi $t3, $t4, 20972
sw $t5, 0($t3)
addi $t3, $t4, 20976
sw $t5, 0($t3)
addi $t3, $t4, 20980
sw $t5, 0($t3)
addi $t3, $t4, 20984
sw $t5, 0($t3)
addi $t3, $t4, 20988
sw $t5, 0($t3)
addi $t3, $t4, 20992
sw $t5, 0($t3)
addi $t3, $t4, 20996
sw $t5, 0($t3)
addi $t3, $t4, 21000
sw $t5, 0($t3)
addi $t3, $t4, 21004
sw $t5, 0($t3)
addi $t3, $t4, 21008
sw $t5, 0($t3)
addi $t3, $t4, 21012
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 21016
li $t5,0x020202
sw $t5, 0($t3)
addi $t3, $t4, 21020
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 21024
sw $t5, 0($t3)
addi $t3, $t4, 21028
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 21032
sw $t5, 0($t3)
addi $t3, $t4, 21036
li $t5,0xfcfcfc
sw $t5, 0($t3)
addi $t3, $t4, 21040
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 21044
li $t5,0x020202
sw $t5, 0($t3)
addi $t3, $t4, 21048
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 21052
li $t5,0x030303
sw $t5, 0($t3)
addi $t3, $t4, 21056
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 21060
sw $t5, 0($t3)
addi $t3, $t4, 21064
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 21068
li $t5,0x949494
sw $t5, 0($t3)
addi $t3, $t4, 21072
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 21076
li $t5,0x848484
sw $t5, 0($t3)
addi $t3, $t4, 21080
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 21084
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 21088
sw $t5, 0($t3)
addi $t3, $t4, 21092
sw $t5, 0($t3)
addi $t3, $t4, 21096
sw $t5, 0($t3)
addi $t3, $t4, 21100
li $t5,0xf6f6f6
sw $t5, 0($t3)
addi $t3, $t4, 21104
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 21108
sw $t5, 0($t3)
addi $t3, $t4, 21112
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 21116
li $t5,0x929292
sw $t5, 0($t3)
addi $t3, $t4, 21120
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 21124
sw $t5, 0($t3)
addi $t3, $t4, 21128
sw $t5, 0($t3)
addi $t3, $t4, 21132
sw $t5, 0($t3)
addi $t3, $t4, 21136
li $t5,0xefefef
sw $t5, 0($t3)
addi $t3, $t4, 21140
li $t5,0xfbfbfb
sw $t5, 0($t3)
addi $t3, $t4, 21144
li $t5,0x070707
sw $t5, 0($t3)
addi $t3, $t4, 21148
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 21152
sw $t5, 0($t3)
addi $t3, $t4, 21156
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 21160
li $t5,0x020202
sw $t5, 0($t3)
addi $t3, $t4, 21164
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 21168
sw $t5, 0($t3)
addi $t3, $t4, 21172
sw $t5, 0($t3)
addi $t3, $t4, 21176
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 21180
li $t5,0x424242
sw $t5, 0($t3)
addi $t3, $t4, 21184
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 21188
sw $t5, 0($t3)
addi $t3, $t4, 21192
sw $t5, 0($t3)
addi $t3, $t4, 21196
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 21200
li $t5,0x3d3d3d
sw $t5, 0($t3)
addi $t3, $t4, 21204
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 21208
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 21212
sw $t5, 0($t3)
addi $t3, $t4, 21216
sw $t5, 0($t3)
addi $t3, $t4, 21220
sw $t5, 0($t3)
addi $t3, $t4, 21224
sw $t5, 0($t3)
addi $t3, $t4, 21228
sw $t5, 0($t3)
addi $t3, $t4, 21232
sw $t5, 0($t3)
addi $t3, $t4, 21236
sw $t5, 0($t3)
addi $t3, $t4, 21240
sw $t5, 0($t3)
addi $t3, $t4, 21244
sw $t5, 0($t3)
addi $t3, $t4, 21248
sw $t5, 0($t3)
addi $t3, $t4, 21252
li $t5,0x363636
sw $t5, 0($t3)
addi $t3, $t4, 21256
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 21260
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 21264
sw $t5, 0($t3)
addi $t3, $t4, 21268
sw $t5, 0($t3)
addi $t3, $t4, 21272
sw $t5, 0($t3)
addi $t3, $t4, 21276
li $t5,0x030303
sw $t5, 0($t3)
addi $t3, $t4, 21280
li $t5,0x7f7f7f
sw $t5, 0($t3)
addi $t3, $t4, 21284
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 21288
sw $t5, 0($t3)
addi $t3, $t4, 21292
sw $t5, 0($t3)
addi $t3, $t4, 21296
li $t5,0xfdfdfd
sw $t5, 0($t3)
addi $t3, $t4, 21300
li $t5,0x020202
sw $t5, 0($t3)
addi $t3, $t4, 21304
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 21308
sw $t5, 0($t3)
addi $t3, $t4, 21312
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 21316
li $t5,0x0f0f0f
sw $t5, 0($t3)
addi $t3, $t4, 21320
li $t5,0x191919
sw $t5, 0($t3)
addi $t3, $t4, 21324
li $t5,0xd1d1d1
sw $t5, 0($t3)
addi $t3, $t4, 21328
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 21332
sw $t5, 0($t3)
addi $t3, $t4, 21336
sw $t5, 0($t3)
addi $t3, $t4, 21340
sw $t5, 0($t3)
addi $t3, $t4, 21344
sw $t5, 0($t3)
addi $t3, $t4, 21348
sw $t5, 0($t3)
addi $t3, $t4, 21352
sw $t5, 0($t3)
addi $t3, $t4, 21356
sw $t5, 0($t3)
addi $t3, $t4, 21360
li $t5,0xfdfdfd
sw $t5, 0($t3)
addi $t3, $t4, 21364
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 21368
sw $t5, 0($t3)
addi $t3, $t4, 21372
sw $t5, 0($t3)
addi $t3, $t4, 21376
sw $t5, 0($t3)
addi $t3, $t4, 21380
sw $t5, 0($t3)
addi $t3, $t4, 21384
sw $t5, 0($t3)
addi $t3, $t4, 21388
li $t5,0xb6b6b6
sw $t5, 0($t3)
addi $t3, $t4, 21392
li $t5,0xd6d6d6
sw $t5, 0($t3)
addi $t3, $t4, 21396
li $t5,0xf3f3f3
sw $t5, 0($t3)
addi $t3, $t4, 21400
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 21404
sw $t5, 0($t3)
addi $t3, $t4, 21408
sw $t5, 0($t3)
addi $t3, $t4, 21412
sw $t5, 0($t3)
addi $t3, $t4, 21416
sw $t5, 0($t3)
addi $t3, $t4, 21420
sw $t5, 0($t3)
addi $t3, $t4, 21424
sw $t5, 0($t3)
addi $t3, $t4, 21428
sw $t5, 0($t3)
addi $t3, $t4, 21432
sw $t5, 0($t3)
addi $t3, $t4, 21436
li $t5,0xfdfdfd
sw $t5, 0($t3)
addi $t3, $t4, 21440
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 21444
li $t5,0xfdfdfd
sw $t5, 0($t3)
addi $t3, $t4, 21448
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 21452
sw $t5, 0($t3)
addi $t3, $t4, 21456
sw $t5, 0($t3)
addi $t3, $t4, 21460
sw $t5, 0($t3)
addi $t3, $t4, 21464
sw $t5, 0($t3)
addi $t3, $t4, 21468
sw $t5, 0($t3)
addi $t3, $t4, 21472
sw $t5, 0($t3)
addi $t3, $t4, 21476
sw $t5, 0($t3)
addi $t3, $t4, 21480
sw $t5, 0($t3)
addi $t3, $t4, 21484
sw $t5, 0($t3)
addi $t3, $t4, 21488
sw $t5, 0($t3)
addi $t3, $t4, 21492
sw $t5, 0($t3)
addi $t3, $t4, 21496
sw $t5, 0($t3)
addi $t3, $t4, 21500
sw $t5, 0($t3)
addi $t3, $t4, 21504
sw $t5, 0($t3)
addi $t3, $t4, 21508
sw $t5, 0($t3)
addi $t3, $t4, 21512
sw $t5, 0($t3)
addi $t3, $t4, 21516
sw $t5, 0($t3)
addi $t3, $t4, 21520
sw $t5, 0($t3)
addi $t3, $t4, 21524
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 21528
li $t5,0x141414
sw $t5, 0($t3)
addi $t3, $t4, 21532
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 21536
sw $t5, 0($t3)
addi $t3, $t4, 21540
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 21544
sw $t5, 0($t3)
addi $t3, $t4, 21548
li $t5,0xe8e8e8
sw $t5, 0($t3)
addi $t3, $t4, 21552
li $t5,0x4c4c4c
sw $t5, 0($t3)
addi $t3, $t4, 21556
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 21560
sw $t5, 0($t3)
addi $t3, $t4, 21564
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 21568
sw $t5, 0($t3)
addi $t3, $t4, 21572
sw $t5, 0($t3)
addi $t3, $t4, 21576
li $t5,0x939393
sw $t5, 0($t3)
addi $t3, $t4, 21580
li $t5,0xf9f8f8
sw $t5, 0($t3)
addi $t3, $t4, 21584
li $t5,0xfdfdfd
sw $t5, 0($t3)
addi $t3, $t4, 21588
li $t5,0x2a2a2a
sw $t5, 0($t3)
addi $t3, $t4, 21592
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 21596
sw $t5, 0($t3)
addi $t3, $t4, 21600
sw $t5, 0($t3)
addi $t3, $t4, 21604
sw $t5, 0($t3)
addi $t3, $t4, 21608
sw $t5, 0($t3)
addi $t3, $t4, 21612
li $t5,0xfdfdfd
sw $t5, 0($t3)
addi $t3, $t4, 21616
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 21620
sw $t5, 0($t3)
addi $t3, $t4, 21624
sw $t5, 0($t3)
addi $t3, $t4, 21628
li $t5,0x282828
sw $t5, 0($t3)
addi $t3, $t4, 21632
li $t5,0x020202
sw $t5, 0($t3)
addi $t3, $t4, 21636
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 21640
sw $t5, 0($t3)
addi $t3, $t4, 21644
li $t5,0x050505
sw $t5, 0($t3)
addi $t3, $t4, 21648
li $t5,0xfbfbfb
sw $t5, 0($t3)
addi $t3, $t4, 21652
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 21656
li $t5,0x151515
sw $t5, 0($t3)
addi $t3, $t4, 21660
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 21664
sw $t5, 0($t3)
addi $t3, $t4, 21668
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 21672
li $t5,0x020202
sw $t5, 0($t3)
addi $t3, $t4, 21676
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 21680
sw $t5, 0($t3)
addi $t3, $t4, 21684
sw $t5, 0($t3)
addi $t3, $t4, 21688
li $t5,0xf3f3f3
sw $t5, 0($t3)
addi $t3, $t4, 21692
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 21696
sw $t5, 0($t3)
addi $t3, $t4, 21700
sw $t5, 0($t3)
addi $t3, $t4, 21704
sw $t5, 0($t3)
addi $t3, $t4, 21708
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 21712
li $t5,0x525252
sw $t5, 0($t3)
addi $t3, $t4, 21716
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 21720
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 21724
sw $t5, 0($t3)
addi $t3, $t4, 21728
sw $t5, 0($t3)
addi $t3, $t4, 21732
sw $t5, 0($t3)
addi $t3, $t4, 21736
sw $t5, 0($t3)
addi $t3, $t4, 21740
sw $t5, 0($t3)
addi $t3, $t4, 21744
sw $t5, 0($t3)
addi $t3, $t4, 21748
sw $t5, 0($t3)
addi $t3, $t4, 21752
sw $t5, 0($t3)
addi $t3, $t4, 21756
sw $t5, 0($t3)
addi $t3, $t4, 21760
sw $t5, 0($t3)
addi $t3, $t4, 21764
li $t5,0x797979
sw $t5, 0($t3)
addi $t3, $t4, 21768
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 21772
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 21776
sw $t5, 0($t3)
addi $t3, $t4, 21780
sw $t5, 0($t3)
addi $t3, $t4, 21784
sw $t5, 0($t3)
addi $t3, $t4, 21788
li $t5,0x0d0d0d
sw $t5, 0($t3)
addi $t3, $t4, 21792
li $t5,0x9e9e9e
sw $t5, 0($t3)
addi $t3, $t4, 21796
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 21800
sw $t5, 0($t3)
addi $t3, $t4, 21804
sw $t5, 0($t3)
addi $t3, $t4, 21808
sw $t5, 0($t3)
addi $t3, $t4, 21812
li $t5,0x3d3d3d
sw $t5, 0($t3)
addi $t3, $t4, 21816
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 21820
sw $t5, 0($t3)
addi $t3, $t4, 21824
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 21828
li $t5,0x1a1a1a
sw $t5, 0($t3)
addi $t3, $t4, 21832
li $t5,0x939393
sw $t5, 0($t3)
addi $t3, $t4, 21836
li $t5,0xfcfcfc
sw $t5, 0($t3)
addi $t3, $t4, 21840
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 21844
sw $t5, 0($t3)
addi $t3, $t4, 21848
sw $t5, 0($t3)
addi $t3, $t4, 21852
sw $t5, 0($t3)
addi $t3, $t4, 21856
sw $t5, 0($t3)
addi $t3, $t4, 21860
sw $t5, 0($t3)
addi $t3, $t4, 21864
sw $t5, 0($t3)
addi $t3, $t4, 21868
sw $t5, 0($t3)
addi $t3, $t4, 21872
sw $t5, 0($t3)
addi $t3, $t4, 21876
sw $t5, 0($t3)
addi $t3, $t4, 21880
sw $t5, 0($t3)
addi $t3, $t4, 21884
sw $t5, 0($t3)
addi $t3, $t4, 21888
sw $t5, 0($t3)
addi $t3, $t4, 21892
sw $t5, 0($t3)
addi $t3, $t4, 21896
sw $t5, 0($t3)
addi $t3, $t4, 21900
sw $t5, 0($t3)
addi $t3, $t4, 21904
sw $t5, 0($t3)
addi $t3, $t4, 21908
sw $t5, 0($t3)
addi $t3, $t4, 21912
sw $t5, 0($t3)
addi $t3, $t4, 21916
sw $t5, 0($t3)
addi $t3, $t4, 21920
sw $t5, 0($t3)
addi $t3, $t4, 21924
sw $t5, 0($t3)
addi $t3, $t4, 21928
sw $t5, 0($t3)
addi $t3, $t4, 21932
sw $t5, 0($t3)
addi $t3, $t4, 21936
sw $t5, 0($t3)
addi $t3, $t4, 21940
sw $t5, 0($t3)
addi $t3, $t4, 21944
sw $t5, 0($t3)
addi $t3, $t4, 21948
sw $t5, 0($t3)
addi $t3, $t4, 21952
sw $t5, 0($t3)
addi $t3, $t4, 21956
sw $t5, 0($t3)
addi $t3, $t4, 21960
sw $t5, 0($t3)
addi $t3, $t4, 21964
sw $t5, 0($t3)
addi $t3, $t4, 21968
sw $t5, 0($t3)
addi $t3, $t4, 21972
sw $t5, 0($t3)
addi $t3, $t4, 21976
sw $t5, 0($t3)
addi $t3, $t4, 21980
sw $t5, 0($t3)
addi $t3, $t4, 21984
sw $t5, 0($t3)
addi $t3, $t4, 21988
sw $t5, 0($t3)
addi $t3, $t4, 21992
sw $t5, 0($t3)
addi $t3, $t4, 21996
sw $t5, 0($t3)
addi $t3, $t4, 22000
sw $t5, 0($t3)
addi $t3, $t4, 22004
sw $t5, 0($t3)
addi $t3, $t4, 22008
sw $t5, 0($t3)
addi $t3, $t4, 22012
sw $t5, 0($t3)
addi $t3, $t4, 22016
sw $t5, 0($t3)
addi $t3, $t4, 22020
sw $t5, 0($t3)
addi $t3, $t4, 22024
sw $t5, 0($t3)
addi $t3, $t4, 22028
sw $t5, 0($t3)
addi $t3, $t4, 22032
sw $t5, 0($t3)
addi $t3, $t4, 22036
sw $t5, 0($t3)
addi $t3, $t4, 22040
li $t5,0x444444
sw $t5, 0($t3)
addi $t3, $t4, 22044
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 22048
sw $t5, 0($t3)
addi $t3, $t4, 22052
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 22056
sw $t5, 0($t3)
addi $t3, $t4, 22060
li $t5,0x6d6d6d
sw $t5, 0($t3)
addi $t3, $t4, 22064
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 22068
sw $t5, 0($t3)
addi $t3, $t4, 22072
sw $t5, 0($t3)
addi $t3, $t4, 22076
sw $t5, 0($t3)
addi $t3, $t4, 22080
sw $t5, 0($t3)
addi $t3, $t4, 22084
li $t5,0x040404
sw $t5, 0($t3)
addi $t3, $t4, 22088
li $t5,0x585858
sw $t5, 0($t3)
addi $t3, $t4, 22092
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 22096
sw $t5, 0($t3)
addi $t3, $t4, 22100
li $t5,0x090909
sw $t5, 0($t3)
addi $t3, $t4, 22104
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 22108
sw $t5, 0($t3)
addi $t3, $t4, 22112
sw $t5, 0($t3)
addi $t3, $t4, 22116
sw $t5, 0($t3)
addi $t3, $t4, 22120
sw $t5, 0($t3)
addi $t3, $t4, 22124
li $t5,0xfcfcfc
sw $t5, 0($t3)
addi $t3, $t4, 22128
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 22132
sw $t5, 0($t3)
addi $t3, $t4, 22136
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 22140
li $t5,0x060606
sw $t5, 0($t3)
addi $t3, $t4, 22144
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 22148
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 22152
sw $t5, 0($t3)
addi $t3, $t4, 22156
li $t5,0x1d1d1d
sw $t5, 0($t3)
addi $t3, $t4, 22160
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 22164
li $t5,0xfdfdfd
sw $t5, 0($t3)
addi $t3, $t4, 22168
li $t5,0x3b3b3b
sw $t5, 0($t3)
addi $t3, $t4, 22172
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 22176
sw $t5, 0($t3)
addi $t3, $t4, 22180
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 22184
sw $t5, 0($t3)
addi $t3, $t4, 22188
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 22192
sw $t5, 0($t3)
addi $t3, $t4, 22196
sw $t5, 0($t3)
addi $t3, $t4, 22200
li $t5,0x767676
sw $t5, 0($t3)
addi $t3, $t4, 22204
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 22208
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 22212
sw $t5, 0($t3)
addi $t3, $t4, 22216
sw $t5, 0($t3)
addi $t3, $t4, 22220
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 22224
li $t5,0xd9d9d9
sw $t5, 0($t3)
addi $t3, $t4, 22228
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 22232
sw $t5, 0($t3)
addi $t3, $t4, 22236
sw $t5, 0($t3)
addi $t3, $t4, 22240
sw $t5, 0($t3)
addi $t3, $t4, 22244
sw $t5, 0($t3)
addi $t3, $t4, 22248
sw $t5, 0($t3)
addi $t3, $t4, 22252
sw $t5, 0($t3)
addi $t3, $t4, 22256
sw $t5, 0($t3)
addi $t3, $t4, 22260
sw $t5, 0($t3)
addi $t3, $t4, 22264
sw $t5, 0($t3)
addi $t3, $t4, 22268
sw $t5, 0($t3)
addi $t3, $t4, 22272
sw $t5, 0($t3)
addi $t3, $t4, 22276
li $t5,0xd2d2d2
sw $t5, 0($t3)
addi $t3, $t4, 22280
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 22284
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 22288
sw $t5, 0($t3)
addi $t3, $t4, 22292
sw $t5, 0($t3)
addi $t3, $t4, 22296
li $t5,0x0e0e0e
sw $t5, 0($t3)
addi $t3, $t4, 22300
li $t5,0x383838
sw $t5, 0($t3)
addi $t3, $t4, 22304
li $t5,0xe7e7e7
sw $t5, 0($t3)
addi $t3, $t4, 22308
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 22312
sw $t5, 0($t3)
addi $t3, $t4, 22316
sw $t5, 0($t3)
addi $t3, $t4, 22320
sw $t5, 0($t3)
addi $t3, $t4, 22324
li $t5,0xd3d3d3
sw $t5, 0($t3)
addi $t3, $t4, 22328
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 22332
sw $t5, 0($t3)
addi $t3, $t4, 22336
sw $t5, 0($t3)
addi $t3, $t4, 22340
li $t5,0x0f0f0f
sw $t5, 0($t3)
addi $t3, $t4, 22344
li $t5,0xf9f9f9
sw $t5, 0($t3)
addi $t3, $t4, 22348
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 22352
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 22356
sw $t5, 0($t3)
addi $t3, $t4, 22360
sw $t5, 0($t3)
addi $t3, $t4, 22364
sw $t5, 0($t3)
addi $t3, $t4, 22368
sw $t5, 0($t3)
addi $t3, $t4, 22372
sw $t5, 0($t3)
addi $t3, $t4, 22376
sw $t5, 0($t3)
addi $t3, $t4, 22380
sw $t5, 0($t3)
addi $t3, $t4, 22384
sw $t5, 0($t3)
addi $t3, $t4, 22388
sw $t5, 0($t3)
addi $t3, $t4, 22392
sw $t5, 0($t3)
addi $t3, $t4, 22396
sw $t5, 0($t3)
addi $t3, $t4, 22400
sw $t5, 0($t3)
addi $t3, $t4, 22404
sw $t5, 0($t3)
addi $t3, $t4, 22408
sw $t5, 0($t3)
addi $t3, $t4, 22412
sw $t5, 0($t3)
addi $t3, $t4, 22416
sw $t5, 0($t3)
addi $t3, $t4, 22420
sw $t5, 0($t3)
addi $t3, $t4, 22424
sw $t5, 0($t3)
addi $t3, $t4, 22428
sw $t5, 0($t3)
addi $t3, $t4, 22432
sw $t5, 0($t3)
addi $t3, $t4, 22436
sw $t5, 0($t3)
addi $t3, $t4, 22440
sw $t5, 0($t3)
addi $t3, $t4, 22444
sw $t5, 0($t3)
addi $t3, $t4, 22448
sw $t5, 0($t3)
addi $t3, $t4, 22452
sw $t5, 0($t3)
addi $t3, $t4, 22456
sw $t5, 0($t3)
addi $t3, $t4, 22460
sw $t5, 0($t3)
addi $t3, $t4, 22464
sw $t5, 0($t3)
addi $t3, $t4, 22468
sw $t5, 0($t3)
addi $t3, $t4, 22472
sw $t5, 0($t3)
addi $t3, $t4, 22476
sw $t5, 0($t3)
addi $t3, $t4, 22480
sw $t5, 0($t3)
addi $t3, $t4, 22484
sw $t5, 0($t3)
addi $t3, $t4, 22488
sw $t5, 0($t3)
addi $t3, $t4, 22492
sw $t5, 0($t3)
addi $t3, $t4, 22496
sw $t5, 0($t3)
addi $t3, $t4, 22500
sw $t5, 0($t3)
addi $t3, $t4, 22504
sw $t5, 0($t3)
addi $t3, $t4, 22508
sw $t5, 0($t3)
addi $t3, $t4, 22512
sw $t5, 0($t3)
addi $t3, $t4, 22516
sw $t5, 0($t3)
addi $t3, $t4, 22520
sw $t5, 0($t3)
addi $t3, $t4, 22524
sw $t5, 0($t3)
addi $t3, $t4, 22528
sw $t5, 0($t3)
addi $t3, $t4, 22532
sw $t5, 0($t3)
addi $t3, $t4, 22536
sw $t5, 0($t3)
addi $t3, $t4, 22540
sw $t5, 0($t3)
addi $t3, $t4, 22544
sw $t5, 0($t3)
addi $t3, $t4, 22548
sw $t5, 0($t3)
addi $t3, $t4, 22552
li $t5,0x929292
sw $t5, 0($t3)
addi $t3, $t4, 22556
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 22560
sw $t5, 0($t3)
addi $t3, $t4, 22564
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 22568
sw $t5, 0($t3)
addi $t3, $t4, 22572
sw $t5, 0($t3)
addi $t3, $t4, 22576
sw $t5, 0($t3)
addi $t3, $t4, 22580
sw $t5, 0($t3)
addi $t3, $t4, 22584
sw $t5, 0($t3)
addi $t3, $t4, 22588
sw $t5, 0($t3)
addi $t3, $t4, 22592
sw $t5, 0($t3)
addi $t3, $t4, 22596
li $t5,0x424242
sw $t5, 0($t3)
addi $t3, $t4, 22600
li $t5,0xcfcfcf
sw $t5, 0($t3)
addi $t3, $t4, 22604
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 22608
sw $t5, 0($t3)
addi $t3, $t4, 22612
li $t5,0x020202
sw $t5, 0($t3)
addi $t3, $t4, 22616
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 22620
sw $t5, 0($t3)
addi $t3, $t4, 22624
sw $t5, 0($t3)
addi $t3, $t4, 22628
sw $t5, 0($t3)
addi $t3, $t4, 22632
li $t5,0x070707
sw $t5, 0($t3)
addi $t3, $t4, 22636
li $t5,0xfdfdfd
sw $t5, 0($t3)
addi $t3, $t4, 22640
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 22644
sw $t5, 0($t3)
addi $t3, $t4, 22648
li $t5,0xfafafa
sw $t5, 0($t3)
addi $t3, $t4, 22652
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 22656
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 22660
sw $t5, 0($t3)
addi $t3, $t4, 22664
sw $t5, 0($t3)
addi $t3, $t4, 22668
li $t5,0x7b7b7b
sw $t5, 0($t3)
addi $t3, $t4, 22672
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 22676
sw $t5, 0($t3)
addi $t3, $t4, 22680
li $t5,0x6a6a6a
sw $t5, 0($t3)
addi $t3, $t4, 22684
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 22688
sw $t5, 0($t3)
addi $t3, $t4, 22692
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 22696
sw $t5, 0($t3)
addi $t3, $t4, 22700
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 22704
sw $t5, 0($t3)
addi $t3, $t4, 22708
li $t5,0xfcfcfc
sw $t5, 0($t3)
addi $t3, $t4, 22712
li $t5,0x030303
sw $t5, 0($t3)
addi $t3, $t4, 22716
li $t5,0x040404
sw $t5, 0($t3)
addi $t3, $t4, 22720
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 22724
sw $t5, 0($t3)
addi $t3, $t4, 22728
sw $t5, 0($t3)
addi $t3, $t4, 22732
li $t5,0x181818
sw $t5, 0($t3)
addi $t3, $t4, 22736
li $t5,0xfbfbfb
sw $t5, 0($t3)
addi $t3, $t4, 22740
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 22744
sw $t5, 0($t3)
addi $t3, $t4, 22748
sw $t5, 0($t3)
addi $t3, $t4, 22752
sw $t5, 0($t3)
addi $t3, $t4, 22756
sw $t5, 0($t3)
addi $t3, $t4, 22760
sw $t5, 0($t3)
addi $t3, $t4, 22764
sw $t5, 0($t3)
addi $t3, $t4, 22768
sw $t5, 0($t3)
addi $t3, $t4, 22772
sw $t5, 0($t3)
addi $t3, $t4, 22776
sw $t5, 0($t3)
addi $t3, $t4, 22780
sw $t5, 0($t3)
addi $t3, $t4, 22784
sw $t5, 0($t3)
addi $t3, $t4, 22788
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 22792
li $t5,0x050505
sw $t5, 0($t3)
addi $t3, $t4, 22796
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 22800
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 22804
sw $t5, 0($t3)
addi $t3, $t4, 22808
li $t5,0x4a4a4a
sw $t5, 0($t3)
addi $t3, $t4, 22812
li $t5,0x757575
sw $t5, 0($t3)
addi $t3, $t4, 22816
li $t5,0xfcfcfc
sw $t5, 0($t3)
addi $t3, $t4, 22820
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 22824
sw $t5, 0($t3)
addi $t3, $t4, 22828
sw $t5, 0($t3)
addi $t3, $t4, 22832
sw $t5, 0($t3)
addi $t3, $t4, 22836
sw $t5, 0($t3)
addi $t3, $t4, 22840
li $t5,0xeaeaea
sw $t5, 0($t3)
addi $t3, $t4, 22844
li $t5,0x060606
sw $t5, 0($t3)
addi $t3, $t4, 22848
li $t5,0x020202
sw $t5, 0($t3)
addi $t3, $t4, 22852
li $t5,0x5e5e5e
sw $t5, 0($t3)
addi $t3, $t4, 22856
li $t5,0xfdfdfd
sw $t5, 0($t3)
addi $t3, $t4, 22860
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 22864
sw $t5, 0($t3)
addi $t3, $t4, 22868
sw $t5, 0($t3)
addi $t3, $t4, 22872
sw $t5, 0($t3)
addi $t3, $t4, 22876
sw $t5, 0($t3)
addi $t3, $t4, 22880
sw $t5, 0($t3)
addi $t3, $t4, 22884
sw $t5, 0($t3)
addi $t3, $t4, 22888
sw $t5, 0($t3)
addi $t3, $t4, 22892
sw $t5, 0($t3)
addi $t3, $t4, 22896
sw $t5, 0($t3)
addi $t3, $t4, 22900
sw $t5, 0($t3)
addi $t3, $t4, 22904
sw $t5, 0($t3)
addi $t3, $t4, 22908
sw $t5, 0($t3)
addi $t3, $t4, 22912
sw $t5, 0($t3)
addi $t3, $t4, 22916
sw $t5, 0($t3)
addi $t3, $t4, 22920
sw $t5, 0($t3)
addi $t3, $t4, 22924
sw $t5, 0($t3)
addi $t3, $t4, 22928
sw $t5, 0($t3)
addi $t3, $t4, 22932
sw $t5, 0($t3)
addi $t3, $t4, 22936
sw $t5, 0($t3)
addi $t3, $t4, 22940
sw $t5, 0($t3)
addi $t3, $t4, 22944
sw $t5, 0($t3)
addi $t3, $t4, 22948
sw $t5, 0($t3)
addi $t3, $t4, 22952
sw $t5, 0($t3)
addi $t3, $t4, 22956
sw $t5, 0($t3)
addi $t3, $t4, 22960
sw $t5, 0($t3)
addi $t3, $t4, 22964
sw $t5, 0($t3)
addi $t3, $t4, 22968
sw $t5, 0($t3)
addi $t3, $t4, 22972
sw $t5, 0($t3)
addi $t3, $t4, 22976
sw $t5, 0($t3)
addi $t3, $t4, 22980
sw $t5, 0($t3)
addi $t3, $t4, 22984
sw $t5, 0($t3)
addi $t3, $t4, 22988
sw $t5, 0($t3)
addi $t3, $t4, 22992
sw $t5, 0($t3)
addi $t3, $t4, 22996
sw $t5, 0($t3)
addi $t3, $t4, 23000
sw $t5, 0($t3)
addi $t3, $t4, 23004
sw $t5, 0($t3)
addi $t3, $t4, 23008
sw $t5, 0($t3)
addi $t3, $t4, 23012
sw $t5, 0($t3)
addi $t3, $t4, 23016
sw $t5, 0($t3)
addi $t3, $t4, 23020
sw $t5, 0($t3)
addi $t3, $t4, 23024
sw $t5, 0($t3)
addi $t3, $t4, 23028
sw $t5, 0($t3)
addi $t3, $t4, 23032
sw $t5, 0($t3)
addi $t3, $t4, 23036
sw $t5, 0($t3)
addi $t3, $t4, 23040
sw $t5, 0($t3)
addi $t3, $t4, 23044
sw $t5, 0($t3)
addi $t3, $t4, 23048
sw $t5, 0($t3)
addi $t3, $t4, 23052
sw $t5, 0($t3)
addi $t3, $t4, 23056
sw $t5, 0($t3)
addi $t3, $t4, 23060
sw $t5, 0($t3)
addi $t3, $t4, 23064
li $t5,0xe9e9e9
sw $t5, 0($t3)
addi $t3, $t4, 23068
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 23072
sw $t5, 0($t3)
addi $t3, $t4, 23076
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 23080
sw $t5, 0($t3)
addi $t3, $t4, 23084
sw $t5, 0($t3)
addi $t3, $t4, 23088
sw $t5, 0($t3)
addi $t3, $t4, 23092
sw $t5, 0($t3)
addi $t3, $t4, 23096
sw $t5, 0($t3)
addi $t3, $t4, 23100
sw $t5, 0($t3)
addi $t3, $t4, 23104
sw $t5, 0($t3)
addi $t3, $t4, 23108
li $t5,0x8e8e8e
sw $t5, 0($t3)
addi $t3, $t4, 23112
li $t5,0xfbfbfb
sw $t5, 0($t3)
addi $t3, $t4, 23116
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 23120
sw $t5, 0($t3)
addi $t3, $t4, 23124
li $t5,0x020202
sw $t5, 0($t3)
addi $t3, $t4, 23128
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 23132
sw $t5, 0($t3)
addi $t3, $t4, 23136
sw $t5, 0($t3)
addi $t3, $t4, 23140
sw $t5, 0($t3)
addi $t3, $t4, 23144
li $t5,0x252525
sw $t5, 0($t3)
addi $t3, $t4, 23148
li $t5,0xfcfcfc
sw $t5, 0($t3)
addi $t3, $t4, 23152
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 23156
sw $t5, 0($t3)
addi $t3, $t4, 23160
li $t5,0x525252
sw $t5, 0($t3)
addi $t3, $t4, 23164
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 23168
sw $t5, 0($t3)
addi $t3, $t4, 23172
sw $t5, 0($t3)
addi $t3, $t4, 23176
sw $t5, 0($t3)
addi $t3, $t4, 23180
li $t5,0xf2f2f2
sw $t5, 0($t3)
addi $t3, $t4, 23184
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 23188
sw $t5, 0($t3)
addi $t3, $t4, 23192
li $t5,0x9c9c9c
sw $t5, 0($t3)
addi $t3, $t4, 23196
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 23200
sw $t5, 0($t3)
addi $t3, $t4, 23204
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 23208
li $t5,0x040404
sw $t5, 0($t3)
addi $t3, $t4, 23212
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 23216
li $t5,0xfdfdfd
sw $t5, 0($t3)
addi $t3, $t4, 23220
li $t5,0x414141
sw $t5, 0($t3)
addi $t3, $t4, 23224
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 23228
li $t5,0x1c1c1c
sw $t5, 0($t3)
addi $t3, $t4, 23232
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 23236
sw $t5, 0($t3)
addi $t3, $t4, 23240
sw $t5, 0($t3)
addi $t3, $t4, 23244
li $t5,0x4a4a4a
sw $t5, 0($t3)
addi $t3, $t4, 23248
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 23252
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 23256
sw $t5, 0($t3)
addi $t3, $t4, 23260
sw $t5, 0($t3)
addi $t3, $t4, 23264
sw $t5, 0($t3)
addi $t3, $t4, 23268
sw $t5, 0($t3)
addi $t3, $t4, 23272
sw $t5, 0($t3)
addi $t3, $t4, 23276
sw $t5, 0($t3)
addi $t3, $t4, 23280
sw $t5, 0($t3)
addi $t3, $t4, 23284
sw $t5, 0($t3)
addi $t3, $t4, 23288
sw $t5, 0($t3)
addi $t3, $t4, 23292
sw $t5, 0($t3)
addi $t3, $t4, 23296
sw $t5, 0($t3)
addi $t3, $t4, 23300
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 23304
li $t5,0x555555
sw $t5, 0($t3)
addi $t3, $t4, 23308
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 23312
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 23316
sw $t5, 0($t3)
addi $t3, $t4, 23320
li $t5,0x040404
sw $t5, 0($t3)
addi $t3, $t4, 23324
li $t5,0xa7a7a7
sw $t5, 0($t3)
addi $t3, $t4, 23328
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 23332
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 23336
sw $t5, 0($t3)
addi $t3, $t4, 23340
sw $t5, 0($t3)
addi $t3, $t4, 23344
sw $t5, 0($t3)
addi $t3, $t4, 23348
sw $t5, 0($t3)
addi $t3, $t4, 23352
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 23356
li $t5,0xe2e2e2
sw $t5, 0($t3)
addi $t3, $t4, 23360
li $t5,0xf0f0f0
sw $t5, 0($t3)
addi $t3, $t4, 23364
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 23368
sw $t5, 0($t3)
addi $t3, $t4, 23372
sw $t5, 0($t3)
addi $t3, $t4, 23376
sw $t5, 0($t3)
addi $t3, $t4, 23380
sw $t5, 0($t3)
addi $t3, $t4, 23384
sw $t5, 0($t3)
addi $t3, $t4, 23388
sw $t5, 0($t3)
addi $t3, $t4, 23392
sw $t5, 0($t3)
addi $t3, $t4, 23396
sw $t5, 0($t3)
addi $t3, $t4, 23400
sw $t5, 0($t3)
addi $t3, $t4, 23404
sw $t5, 0($t3)
addi $t3, $t4, 23408
sw $t5, 0($t3)
addi $t3, $t4, 23412
sw $t5, 0($t3)
addi $t3, $t4, 23416
sw $t5, 0($t3)
addi $t3, $t4, 23420
sw $t5, 0($t3)
addi $t3, $t4, 23424
sw $t5, 0($t3)
addi $t3, $t4, 23428
sw $t5, 0($t3)
addi $t3, $t4, 23432
sw $t5, 0($t3)
addi $t3, $t4, 23436
sw $t5, 0($t3)
addi $t3, $t4, 23440
sw $t5, 0($t3)
addi $t3, $t4, 23444
sw $t5, 0($t3)
addi $t3, $t4, 23448
sw $t5, 0($t3)
addi $t3, $t4, 23452
sw $t5, 0($t3)
addi $t3, $t4, 23456
sw $t5, 0($t3)
addi $t3, $t4, 23460
sw $t5, 0($t3)
addi $t3, $t4, 23464
sw $t5, 0($t3)
addi $t3, $t4, 23468
sw $t5, 0($t3)
addi $t3, $t4, 23472
sw $t5, 0($t3)
addi $t3, $t4, 23476
sw $t5, 0($t3)
addi $t3, $t4, 23480
sw $t5, 0($t3)
addi $t3, $t4, 23484
sw $t5, 0($t3)
addi $t3, $t4, 23488
sw $t5, 0($t3)
addi $t3, $t4, 23492
sw $t5, 0($t3)
addi $t3, $t4, 23496
sw $t5, 0($t3)
addi $t3, $t4, 23500
sw $t5, 0($t3)
addi $t3, $t4, 23504
sw $t5, 0($t3)
addi $t3, $t4, 23508
sw $t5, 0($t3)
addi $t3, $t4, 23512
sw $t5, 0($t3)
addi $t3, $t4, 23516
sw $t5, 0($t3)
addi $t3, $t4, 23520
sw $t5, 0($t3)
addi $t3, $t4, 23524
sw $t5, 0($t3)
addi $t3, $t4, 23528
sw $t5, 0($t3)
addi $t3, $t4, 23532
sw $t5, 0($t3)
addi $t3, $t4, 23536
sw $t5, 0($t3)
addi $t3, $t4, 23540
sw $t5, 0($t3)
addi $t3, $t4, 23544
sw $t5, 0($t3)
addi $t3, $t4, 23548
sw $t5, 0($t3)
addi $t3, $t4, 23552
sw $t5, 0($t3)
addi $t3, $t4, 23556
sw $t5, 0($t3)
addi $t3, $t4, 23560
sw $t5, 0($t3)
addi $t3, $t4, 23564
sw $t5, 0($t3)
addi $t3, $t4, 23568
sw $t5, 0($t3)
addi $t3, $t4, 23572
sw $t5, 0($t3)
addi $t3, $t4, 23576
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 23580
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 23584
sw $t5, 0($t3)
addi $t3, $t4, 23588
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 23592
sw $t5, 0($t3)
addi $t3, $t4, 23596
sw $t5, 0($t3)
addi $t3, $t4, 23600
sw $t5, 0($t3)
addi $t3, $t4, 23604
sw $t5, 0($t3)
addi $t3, $t4, 23608
sw $t5, 0($t3)
addi $t3, $t4, 23612
sw $t5, 0($t3)
addi $t3, $t4, 23616
li $t5,0x161616
sw $t5, 0($t3)
addi $t3, $t4, 23620
li $t5,0x959595
sw $t5, 0($t3)
addi $t3, $t4, 23624
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 23628
sw $t5, 0($t3)
addi $t3, $t4, 23632
sw $t5, 0($t3)
addi $t3, $t4, 23636
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 23640
sw $t5, 0($t3)
addi $t3, $t4, 23644
sw $t5, 0($t3)
addi $t3, $t4, 23648
sw $t5, 0($t3)
addi $t3, $t4, 23652
sw $t5, 0($t3)
addi $t3, $t4, 23656
li $t5,0x414141
sw $t5, 0($t3)
addi $t3, $t4, 23660
li $t5,0xfdfdfd
sw $t5, 0($t3)
addi $t3, $t4, 23664
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 23668
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 23672
li $t5,0x040404
sw $t5, 0($t3)
addi $t3, $t4, 23676
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 23680
sw $t5, 0($t3)
addi $t3, $t4, 23684
sw $t5, 0($t3)
addi $t3, $t4, 23688
li $t5,0x030303
sw $t5, 0($t3)
addi $t3, $t4, 23692
li $t5,0xfdfdfd
sw $t5, 0($t3)
addi $t3, $t4, 23696
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 23700
sw $t5, 0($t3)
addi $t3, $t4, 23704
li $t5,0xdedede
sw $t5, 0($t3)
addi $t3, $t4, 23708
li $t5,0x020202
sw $t5, 0($t3)
addi $t3, $t4, 23712
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 23716
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 23720
li $t5,0x020202
sw $t5, 0($t3)
addi $t3, $t4, 23724
li $t5,0xfdfdfd
sw $t5, 0($t3)
addi $t3, $t4, 23728
li $t5,0xadadad
sw $t5, 0($t3)
addi $t3, $t4, 23732
li $t5,0x040404
sw $t5, 0($t3)
addi $t3, $t4, 23736
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 23740
sw $t5, 0($t3)
addi $t3, $t4, 23744
sw $t5, 0($t3)
addi $t3, $t4, 23748
sw $t5, 0($t3)
addi $t3, $t4, 23752
li $t5,0x020202
sw $t5, 0($t3)
addi $t3, $t4, 23756
li $t5,0xa7a7a7
sw $t5, 0($t3)
addi $t3, $t4, 23760
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 23764
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 23768
sw $t5, 0($t3)
addi $t3, $t4, 23772
sw $t5, 0($t3)
addi $t3, $t4, 23776
sw $t5, 0($t3)
addi $t3, $t4, 23780
sw $t5, 0($t3)
addi $t3, $t4, 23784
sw $t5, 0($t3)
addi $t3, $t4, 23788
sw $t5, 0($t3)
addi $t3, $t4, 23792
sw $t5, 0($t3)
addi $t3, $t4, 23796
sw $t5, 0($t3)
addi $t3, $t4, 23800
sw $t5, 0($t3)
addi $t3, $t4, 23804
sw $t5, 0($t3)
addi $t3, $t4, 23808
sw $t5, 0($t3)
addi $t3, $t4, 23812
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 23816
sw $t5, 0($t3)
addi $t3, $t4, 23820
li $t5,0x141414
sw $t5, 0($t3)
addi $t3, $t4, 23824
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 23828
sw $t5, 0($t3)
addi $t3, $t4, 23832
li $t5,0x050505
sw $t5, 0($t3)
addi $t3, $t4, 23836
li $t5,0xe7e7e7
sw $t5, 0($t3)
addi $t3, $t4, 23840
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 23844
sw $t5, 0($t3)
addi $t3, $t4, 23848
sw $t5, 0($t3)
addi $t3, $t4, 23852
sw $t5, 0($t3)
addi $t3, $t4, 23856
sw $t5, 0($t3)
addi $t3, $t4, 23860
sw $t5, 0($t3)
addi $t3, $t4, 23864
sw $t5, 0($t3)
addi $t3, $t4, 23868
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 23872
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 23876
sw $t5, 0($t3)
addi $t3, $t4, 23880
sw $t5, 0($t3)
addi $t3, $t4, 23884
sw $t5, 0($t3)
addi $t3, $t4, 23888
sw $t5, 0($t3)
addi $t3, $t4, 23892
sw $t5, 0($t3)
addi $t3, $t4, 23896
sw $t5, 0($t3)
addi $t3, $t4, 23900
sw $t5, 0($t3)
addi $t3, $t4, 23904
sw $t5, 0($t3)
addi $t3, $t4, 23908
sw $t5, 0($t3)
addi $t3, $t4, 23912
sw $t5, 0($t3)
addi $t3, $t4, 23916
sw $t5, 0($t3)
addi $t3, $t4, 23920
sw $t5, 0($t3)
addi $t3, $t4, 23924
sw $t5, 0($t3)
addi $t3, $t4, 23928
sw $t5, 0($t3)
addi $t3, $t4, 23932
sw $t5, 0($t3)
addi $t3, $t4, 23936
sw $t5, 0($t3)
addi $t3, $t4, 23940
sw $t5, 0($t3)
addi $t3, $t4, 23944
sw $t5, 0($t3)
addi $t3, $t4, 23948
sw $t5, 0($t3)
addi $t3, $t4, 23952
sw $t5, 0($t3)
addi $t3, $t4, 23956
sw $t5, 0($t3)
addi $t3, $t4, 23960
sw $t5, 0($t3)
addi $t3, $t4, 23964
sw $t5, 0($t3)
addi $t3, $t4, 23968
sw $t5, 0($t3)
addi $t3, $t4, 23972
sw $t5, 0($t3)
addi $t3, $t4, 23976
sw $t5, 0($t3)
addi $t3, $t4, 23980
sw $t5, 0($t3)
addi $t3, $t4, 23984
sw $t5, 0($t3)
addi $t3, $t4, 23988
sw $t5, 0($t3)
addi $t3, $t4, 23992
sw $t5, 0($t3)
addi $t3, $t4, 23996
sw $t5, 0($t3)
addi $t3, $t4, 24000
sw $t5, 0($t3)
addi $t3, $t4, 24004
sw $t5, 0($t3)
addi $t3, $t4, 24008
sw $t5, 0($t3)
addi $t3, $t4, 24012
sw $t5, 0($t3)
addi $t3, $t4, 24016
sw $t5, 0($t3)
addi $t3, $t4, 24020
sw $t5, 0($t3)
addi $t3, $t4, 24024
sw $t5, 0($t3)
addi $t3, $t4, 24028
sw $t5, 0($t3)
addi $t3, $t4, 24032
sw $t5, 0($t3)
addi $t3, $t4, 24036
sw $t5, 0($t3)
addi $t3, $t4, 24040
sw $t5, 0($t3)
addi $t3, $t4, 24044
sw $t5, 0($t3)
addi $t3, $t4, 24048
sw $t5, 0($t3)
addi $t3, $t4, 24052
sw $t5, 0($t3)
addi $t3, $t4, 24056
sw $t5, 0($t3)
addi $t3, $t4, 24060
sw $t5, 0($t3)
addi $t3, $t4, 24064
sw $t5, 0($t3)
addi $t3, $t4, 24068
sw $t5, 0($t3)
addi $t3, $t4, 24072
sw $t5, 0($t3)
addi $t3, $t4, 24076
sw $t5, 0($t3)
addi $t3, $t4, 24080
sw $t5, 0($t3)
addi $t3, $t4, 24084
sw $t5, 0($t3)
addi $t3, $t4, 24088
sw $t5, 0($t3)
addi $t3, $t4, 24092
li $t5,0x050505
sw $t5, 0($t3)
addi $t3, $t4, 24096
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 24100
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 24104
sw $t5, 0($t3)
addi $t3, $t4, 24108
sw $t5, 0($t3)
addi $t3, $t4, 24112
sw $t5, 0($t3)
addi $t3, $t4, 24116
sw $t5, 0($t3)
addi $t3, $t4, 24120
sw $t5, 0($t3)
addi $t3, $t4, 24124
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 24128
li $t5,0x9a9a9a
sw $t5, 0($t3)
addi $t3, $t4, 24132
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 24136
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 24140
sw $t5, 0($t3)
addi $t3, $t4, 24144
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 24148
li $t5,0x070707
sw $t5, 0($t3)
addi $t3, $t4, 24152
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 24156
sw $t5, 0($t3)
addi $t3, $t4, 24160
sw $t5, 0($t3)
addi $t3, $t4, 24164
sw $t5, 0($t3)
addi $t3, $t4, 24168
li $t5,0x6d6d6c
sw $t5, 0($t3)
addi $t3, $t4, 24172
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 24176
sw $t5, 0($t3)
addi $t3, $t4, 24180
li $t5,0xcdcccc
sw $t5, 0($t3)
addi $t3, $t4, 24184
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 24188
sw $t5, 0($t3)
addi $t3, $t4, 24192
sw $t5, 0($t3)
addi $t3, $t4, 24196
sw $t5, 0($t3)
addi $t3, $t4, 24200
li $t5,0x2b2b2b
sw $t5, 0($t3)
addi $t3, $t4, 24204
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 24208
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 24212
sw $t5, 0($t3)
addi $t3, $t4, 24216
sw $t5, 0($t3)
addi $t3, $t4, 24220
li $t5,0x030303
sw $t5, 0($t3)
addi $t3, $t4, 24224
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 24228
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 24232
sw $t5, 0($t3)
addi $t3, $t4, 24236
sw $t5, 0($t3)
addi $t3, $t4, 24240
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 24244
li $t5,0x070707
sw $t5, 0($t3)
addi $t3, $t4, 24248
li $t5,0x090909
sw $t5, 0($t3)
addi $t3, $t4, 24252
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 24256
sw $t5, 0($t3)
addi $t3, $t4, 24260
li $t5,0x020202
sw $t5, 0($t3)
addi $t3, $t4, 24264
li $t5,0x6d6d6d
sw $t5, 0($t3)
addi $t3, $t4, 24268
li $t5,0xf9f9f9
sw $t5, 0($t3)
addi $t3, $t4, 24272
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 24276
sw $t5, 0($t3)
addi $t3, $t4, 24280
sw $t5, 0($t3)
addi $t3, $t4, 24284
sw $t5, 0($t3)
addi $t3, $t4, 24288
sw $t5, 0($t3)
addi $t3, $t4, 24292
sw $t5, 0($t3)
addi $t3, $t4, 24296
sw $t5, 0($t3)
addi $t3, $t4, 24300
sw $t5, 0($t3)
addi $t3, $t4, 24304
sw $t5, 0($t3)
addi $t3, $t4, 24308
sw $t5, 0($t3)
addi $t3, $t4, 24312
sw $t5, 0($t3)
addi $t3, $t4, 24316
sw $t5, 0($t3)
addi $t3, $t4, 24320
sw $t5, 0($t3)
addi $t3, $t4, 24324
sw $t5, 0($t3)
addi $t3, $t4, 24328
sw $t5, 0($t3)
addi $t3, $t4, 24332
li $t5,0xfcfcfc
sw $t5, 0($t3)
addi $t3, $t4, 24336
li $t5,0x222222
sw $t5, 0($t3)
addi $t3, $t4, 24340
li $t5,0x020202
sw $t5, 0($t3)
addi $t3, $t4, 24344
li $t5,0x121212
sw $t5, 0($t3)
addi $t3, $t4, 24348
li $t5,0xfcfcfc
sw $t5, 0($t3)
addi $t3, $t4, 24352
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 24356
sw $t5, 0($t3)
addi $t3, $t4, 24360
sw $t5, 0($t3)
addi $t3, $t4, 24364
sw $t5, 0($t3)
addi $t3, $t4, 24368
sw $t5, 0($t3)
addi $t3, $t4, 24372
sw $t5, 0($t3)
addi $t3, $t4, 24376
sw $t5, 0($t3)
addi $t3, $t4, 24380
sw $t5, 0($t3)
addi $t3, $t4, 24384
sw $t5, 0($t3)
addi $t3, $t4, 24388
sw $t5, 0($t3)
addi $t3, $t4, 24392
sw $t5, 0($t3)
addi $t3, $t4, 24396
sw $t5, 0($t3)
addi $t3, $t4, 24400
sw $t5, 0($t3)
addi $t3, $t4, 24404
sw $t5, 0($t3)
addi $t3, $t4, 24408
sw $t5, 0($t3)
addi $t3, $t4, 24412
sw $t5, 0($t3)
addi $t3, $t4, 24416
sw $t5, 0($t3)
addi $t3, $t4, 24420
sw $t5, 0($t3)
addi $t3, $t4, 24424
sw $t5, 0($t3)
addi $t3, $t4, 24428
sw $t5, 0($t3)
addi $t3, $t4, 24432
sw $t5, 0($t3)
addi $t3, $t4, 24436
sw $t5, 0($t3)
addi $t3, $t4, 24440
sw $t5, 0($t3)
addi $t3, $t4, 24444
sw $t5, 0($t3)
addi $t3, $t4, 24448
sw $t5, 0($t3)
addi $t3, $t4, 24452
sw $t5, 0($t3)
addi $t3, $t4, 24456
sw $t5, 0($t3)
addi $t3, $t4, 24460
sw $t5, 0($t3)
addi $t3, $t4, 24464
sw $t5, 0($t3)
addi $t3, $t4, 24468
sw $t5, 0($t3)
addi $t3, $t4, 24472
sw $t5, 0($t3)
addi $t3, $t4, 24476
sw $t5, 0($t3)
addi $t3, $t4, 24480
sw $t5, 0($t3)
addi $t3, $t4, 24484
sw $t5, 0($t3)
addi $t3, $t4, 24488
sw $t5, 0($t3)
addi $t3, $t4, 24492
sw $t5, 0($t3)
addi $t3, $t4, 24496
sw $t5, 0($t3)
addi $t3, $t4, 24500
sw $t5, 0($t3)
addi $t3, $t4, 24504
sw $t5, 0($t3)
addi $t3, $t4, 24508
sw $t5, 0($t3)
addi $t3, $t4, 24512
sw $t5, 0($t3)
addi $t3, $t4, 24516
sw $t5, 0($t3)
addi $t3, $t4, 24520
sw $t5, 0($t3)
addi $t3, $t4, 24524
sw $t5, 0($t3)
addi $t3, $t4, 24528
sw $t5, 0($t3)
addi $t3, $t4, 24532
sw $t5, 0($t3)
addi $t3, $t4, 24536
sw $t5, 0($t3)
addi $t3, $t4, 24540
sw $t5, 0($t3)
addi $t3, $t4, 24544
sw $t5, 0($t3)
addi $t3, $t4, 24548
sw $t5, 0($t3)
addi $t3, $t4, 24552
sw $t5, 0($t3)
addi $t3, $t4, 24556
sw $t5, 0($t3)
addi $t3, $t4, 24560
sw $t5, 0($t3)
addi $t3, $t4, 24564
sw $t5, 0($t3)
addi $t3, $t4, 24568
sw $t5, 0($t3)
addi $t3, $t4, 24572
sw $t5, 0($t3)
addi $t3, $t4, 24576
sw $t5, 0($t3)
addi $t3, $t4, 24580
sw $t5, 0($t3)
addi $t3, $t4, 24584
sw $t5, 0($t3)
addi $t3, $t4, 24588
sw $t5, 0($t3)
addi $t3, $t4, 24592
sw $t5, 0($t3)
addi $t3, $t4, 24596
sw $t5, 0($t3)
addi $t3, $t4, 24600
sw $t5, 0($t3)
addi $t3, $t4, 24604
li $t5,0x161616
sw $t5, 0($t3)
addi $t3, $t4, 24608
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 24612
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 24616
sw $t5, 0($t3)
addi $t3, $t4, 24620
sw $t5, 0($t3)
addi $t3, $t4, 24624
sw $t5, 0($t3)
addi $t3, $t4, 24628
sw $t5, 0($t3)
addi $t3, $t4, 24632
li $t5,0x343434
sw $t5, 0($t3)
addi $t3, $t4, 24636
li $t5,0x040404
sw $t5, 0($t3)
addi $t3, $t4, 24640
li $t5,0x6d6d6d
sw $t5, 0($t3)
addi $t3, $t4, 24644
li $t5,0xfdfdfd
sw $t5, 0($t3)
addi $t3, $t4, 24648
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 24652
sw $t5, 0($t3)
addi $t3, $t4, 24656
sw $t5, 0($t3)
addi $t3, $t4, 24660
li $t5,0x1e1e1e
sw $t5, 0($t3)
addi $t3, $t4, 24664
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 24668
sw $t5, 0($t3)
addi $t3, $t4, 24672
sw $t5, 0($t3)
addi $t3, $t4, 24676
li $t5,0x020202
sw $t5, 0($t3)
addi $t3, $t4, 24680
li $t5,0xb1b1b1
sw $t5, 0($t3)
addi $t3, $t4, 24684
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 24688
li $t5,0xfffffe
sw $t5, 0($t3)
addi $t3, $t4, 24692
li $t5,0x0f0f0f
sw $t5, 0($t3)
addi $t3, $t4, 24696
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 24700
sw $t5, 0($t3)
addi $t3, $t4, 24704
sw $t5, 0($t3)
addi $t3, $t4, 24708
sw $t5, 0($t3)
addi $t3, $t4, 24712
li $t5,0xe0e0e0
sw $t5, 0($t3)
addi $t3, $t4, 24716
li $t5,0xfdfdfd
sw $t5, 0($t3)
addi $t3, $t4, 24720
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 24724
sw $t5, 0($t3)
addi $t3, $t4, 24728
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 24732
li $t5,0x676767
sw $t5, 0($t3)
addi $t3, $t4, 24736
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 24740
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 24744
sw $t5, 0($t3)
addi $t3, $t4, 24748
sw $t5, 0($t3)
addi $t3, $t4, 24752
li $t5,0x040404
sw $t5, 0($t3)
addi $t3, $t4, 24756
li $t5,0x8d8d8d
sw $t5, 0($t3)
addi $t3, $t4, 24760
li $t5,0x454545
sw $t5, 0($t3)
addi $t3, $t4, 24764
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 24768
li $t5,0x020202
sw $t5, 0($t3)
addi $t3, $t4, 24772
li $t5,0x090909
sw $t5, 0($t3)
addi $t3, $t4, 24776
li $t5,0x5e5e5e
sw $t5, 0($t3)
addi $t3, $t4, 24780
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 24784
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 24788
sw $t5, 0($t3)
addi $t3, $t4, 24792
sw $t5, 0($t3)
addi $t3, $t4, 24796
sw $t5, 0($t3)
addi $t3, $t4, 24800
sw $t5, 0($t3)
addi $t3, $t4, 24804
sw $t5, 0($t3)
addi $t3, $t4, 24808
sw $t5, 0($t3)
addi $t3, $t4, 24812
sw $t5, 0($t3)
addi $t3, $t4, 24816
sw $t5, 0($t3)
addi $t3, $t4, 24820
sw $t5, 0($t3)
addi $t3, $t4, 24824
sw $t5, 0($t3)
addi $t3, $t4, 24828
sw $t5, 0($t3)
addi $t3, $t4, 24832
sw $t5, 0($t3)
addi $t3, $t4, 24836
sw $t5, 0($t3)
addi $t3, $t4, 24840
sw $t5, 0($t3)
addi $t3, $t4, 24844
sw $t5, 0($t3)
addi $t3, $t4, 24848
li $t5,0xfdfdfd
sw $t5, 0($t3)
addi $t3, $t4, 24852
li $t5,0xf8f8f8
sw $t5, 0($t3)
addi $t3, $t4, 24856
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 24860
sw $t5, 0($t3)
addi $t3, $t4, 24864
sw $t5, 0($t3)
addi $t3, $t4, 24868
sw $t5, 0($t3)
addi $t3, $t4, 24872
sw $t5, 0($t3)
addi $t3, $t4, 24876
sw $t5, 0($t3)
addi $t3, $t4, 24880
sw $t5, 0($t3)
addi $t3, $t4, 24884
sw $t5, 0($t3)
addi $t3, $t4, 24888
sw $t5, 0($t3)
addi $t3, $t4, 24892
sw $t5, 0($t3)
addi $t3, $t4, 24896
sw $t5, 0($t3)
addi $t3, $t4, 24900
sw $t5, 0($t3)
addi $t3, $t4, 24904
sw $t5, 0($t3)
addi $t3, $t4, 24908
sw $t5, 0($t3)
addi $t3, $t4, 24912
sw $t5, 0($t3)
addi $t3, $t4, 24916
sw $t5, 0($t3)
addi $t3, $t4, 24920
sw $t5, 0($t3)
addi $t3, $t4, 24924
sw $t5, 0($t3)
addi $t3, $t4, 24928
sw $t5, 0($t3)
addi $t3, $t4, 24932
sw $t5, 0($t3)
addi $t3, $t4, 24936
sw $t5, 0($t3)
addi $t3, $t4, 24940
sw $t5, 0($t3)
addi $t3, $t4, 24944
sw $t5, 0($t3)
addi $t3, $t4, 24948
sw $t5, 0($t3)
addi $t3, $t4, 24952
sw $t5, 0($t3)
addi $t3, $t4, 24956
sw $t5, 0($t3)
addi $t3, $t4, 24960
sw $t5, 0($t3)
addi $t3, $t4, 24964
sw $t5, 0($t3)
addi $t3, $t4, 24968
sw $t5, 0($t3)
addi $t3, $t4, 24972
sw $t5, 0($t3)
addi $t3, $t4, 24976
sw $t5, 0($t3)
addi $t3, $t4, 24980
sw $t5, 0($t3)
addi $t3, $t4, 24984
sw $t5, 0($t3)
addi $t3, $t4, 24988
sw $t5, 0($t3)
addi $t3, $t4, 24992
sw $t5, 0($t3)
addi $t3, $t4, 24996
sw $t5, 0($t3)
addi $t3, $t4, 25000
sw $t5, 0($t3)
addi $t3, $t4, 25004
sw $t5, 0($t3)
addi $t3, $t4, 25008
sw $t5, 0($t3)
addi $t3, $t4, 25012
sw $t5, 0($t3)
addi $t3, $t4, 25016
sw $t5, 0($t3)
addi $t3, $t4, 25020
sw $t5, 0($t3)
addi $t3, $t4, 25024
sw $t5, 0($t3)
addi $t3, $t4, 25028
sw $t5, 0($t3)
addi $t3, $t4, 25032
sw $t5, 0($t3)
addi $t3, $t4, 25036
sw $t5, 0($t3)
addi $t3, $t4, 25040
sw $t5, 0($t3)
addi $t3, $t4, 25044
sw $t5, 0($t3)
addi $t3, $t4, 25048
sw $t5, 0($t3)
addi $t3, $t4, 25052
sw $t5, 0($t3)
addi $t3, $t4, 25056
sw $t5, 0($t3)
addi $t3, $t4, 25060
sw $t5, 0($t3)
addi $t3, $t4, 25064
sw $t5, 0($t3)
addi $t3, $t4, 25068
sw $t5, 0($t3)
addi $t3, $t4, 25072
sw $t5, 0($t3)
addi $t3, $t4, 25076
sw $t5, 0($t3)
addi $t3, $t4, 25080
sw $t5, 0($t3)
addi $t3, $t4, 25084
sw $t5, 0($t3)
addi $t3, $t4, 25088
sw $t5, 0($t3)
addi $t3, $t4, 25092
sw $t5, 0($t3)
addi $t3, $t4, 25096
sw $t5, 0($t3)
addi $t3, $t4, 25100
sw $t5, 0($t3)
addi $t3, $t4, 25104
sw $t5, 0($t3)
addi $t3, $t4, 25108
sw $t5, 0($t3)
addi $t3, $t4, 25112
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 25116
li $t5,0x686868
sw $t5, 0($t3)
addi $t3, $t4, 25120
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 25124
sw $t5, 0($t3)
addi $t3, $t4, 25128
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 25132
sw $t5, 0($t3)
addi $t3, $t4, 25136
sw $t5, 0($t3)
addi $t3, $t4, 25140
li $t5,0x030303
sw $t5, 0($t3)
addi $t3, $t4, 25144
li $t5,0x7f7f7f
sw $t5, 0($t3)
addi $t3, $t4, 25148
li $t5,0x9a9a9a
sw $t5, 0($t3)
addi $t3, $t4, 25152
li $t5,0xf2f2f2
sw $t5, 0($t3)
addi $t3, $t4, 25156
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 25160
sw $t5, 0($t3)
addi $t3, $t4, 25164
sw $t5, 0($t3)
addi $t3, $t4, 25168
sw $t5, 0($t3)
addi $t3, $t4, 25172
li $t5,0x7f7f7f
sw $t5, 0($t3)
addi $t3, $t4, 25176
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 25180
sw $t5, 0($t3)
addi $t3, $t4, 25184
sw $t5, 0($t3)
addi $t3, $t4, 25188
sw $t5, 0($t3)
addi $t3, $t4, 25192
li $t5,0xbbbbbb
sw $t5, 0($t3)
addi $t3, $t4, 25196
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 25200
li $t5,0xa0a0a0
sw $t5, 0($t3)
addi $t3, $t4, 25204
li $t5,0x030303
sw $t5, 0($t3)
addi $t3, $t4, 25208
li $t5,0x1d1d1d
sw $t5, 0($t3)
addi $t3, $t4, 25212
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 25216
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 25220
li $t5,0x6a6a6a
sw $t5, 0($t3)
addi $t3, $t4, 25224
li $t5,0xfbfbfb
sw $t5, 0($t3)
addi $t3, $t4, 25228
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 25232
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 25236
sw $t5, 0($t3)
addi $t3, $t4, 25240
sw $t5, 0($t3)
addi $t3, $t4, 25244
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 25248
li $t5,0x030303
sw $t5, 0($t3)
addi $t3, $t4, 25252
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 25256
sw $t5, 0($t3)
addi $t3, $t4, 25260
sw $t5, 0($t3)
addi $t3, $t4, 25264
sw $t5, 0($t3)
addi $t3, $t4, 25268
li $t5,0x0b0b0b
sw $t5, 0($t3)
addi $t3, $t4, 25272
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 25276
li $t5,0x080808
sw $t5, 0($t3)
addi $t3, $t4, 25280
li $t5,0x383737
sw $t5, 0($t3)
addi $t3, $t4, 25284
li $t5,0x999999
sw $t5, 0($t3)
addi $t3, $t4, 25288
li $t5,0xf8f8f8
sw $t5, 0($t3)
addi $t3, $t4, 25292
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 25296
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 25300
sw $t5, 0($t3)
addi $t3, $t4, 25304
sw $t5, 0($t3)
addi $t3, $t4, 25308
sw $t5, 0($t3)
addi $t3, $t4, 25312
sw $t5, 0($t3)
addi $t3, $t4, 25316
sw $t5, 0($t3)
addi $t3, $t4, 25320
sw $t5, 0($t3)
addi $t3, $t4, 25324
sw $t5, 0($t3)
addi $t3, $t4, 25328
sw $t5, 0($t3)
addi $t3, $t4, 25332
sw $t5, 0($t3)
addi $t3, $t4, 25336
sw $t5, 0($t3)
addi $t3, $t4, 25340
sw $t5, 0($t3)
addi $t3, $t4, 25344
sw $t5, 0($t3)
addi $t3, $t4, 25348
sw $t5, 0($t3)
addi $t3, $t4, 25352
sw $t5, 0($t3)
addi $t3, $t4, 25356
sw $t5, 0($t3)
addi $t3, $t4, 25360
sw $t5, 0($t3)
addi $t3, $t4, 25364
sw $t5, 0($t3)
addi $t3, $t4, 25368
sw $t5, 0($t3)
addi $t3, $t4, 25372
sw $t5, 0($t3)
addi $t3, $t4, 25376
sw $t5, 0($t3)
addi $t3, $t4, 25380
sw $t5, 0($t3)
addi $t3, $t4, 25384
sw $t5, 0($t3)
addi $t3, $t4, 25388
sw $t5, 0($t3)
addi $t3, $t4, 25392
sw $t5, 0($t3)
addi $t3, $t4, 25396
sw $t5, 0($t3)
addi $t3, $t4, 25400
sw $t5, 0($t3)
addi $t3, $t4, 25404
sw $t5, 0($t3)
addi $t3, $t4, 25408
sw $t5, 0($t3)
addi $t3, $t4, 25412
sw $t5, 0($t3)
addi $t3, $t4, 25416
sw $t5, 0($t3)
addi $t3, $t4, 25420
sw $t5, 0($t3)
addi $t3, $t4, 25424
sw $t5, 0($t3)
addi $t3, $t4, 25428
sw $t5, 0($t3)
addi $t3, $t4, 25432
sw $t5, 0($t3)
addi $t3, $t4, 25436
sw $t5, 0($t3)
addi $t3, $t4, 25440
sw $t5, 0($t3)
addi $t3, $t4, 25444
sw $t5, 0($t3)
addi $t3, $t4, 25448
sw $t5, 0($t3)
addi $t3, $t4, 25452
sw $t5, 0($t3)
addi $t3, $t4, 25456
sw $t5, 0($t3)
addi $t3, $t4, 25460
sw $t5, 0($t3)
addi $t3, $t4, 25464
sw $t5, 0($t3)
addi $t3, $t4, 25468
sw $t5, 0($t3)
addi $t3, $t4, 25472
sw $t5, 0($t3)
addi $t3, $t4, 25476
sw $t5, 0($t3)
addi $t3, $t4, 25480
sw $t5, 0($t3)
addi $t3, $t4, 25484
sw $t5, 0($t3)
addi $t3, $t4, 25488
sw $t5, 0($t3)
addi $t3, $t4, 25492
sw $t5, 0($t3)
addi $t3, $t4, 25496
sw $t5, 0($t3)
addi $t3, $t4, 25500
sw $t5, 0($t3)
addi $t3, $t4, 25504
sw $t5, 0($t3)
addi $t3, $t4, 25508
sw $t5, 0($t3)
addi $t3, $t4, 25512
sw $t5, 0($t3)
addi $t3, $t4, 25516
sw $t5, 0($t3)
addi $t3, $t4, 25520
sw $t5, 0($t3)
addi $t3, $t4, 25524
sw $t5, 0($t3)
addi $t3, $t4, 25528
sw $t5, 0($t3)
addi $t3, $t4, 25532
sw $t5, 0($t3)
addi $t3, $t4, 25536
sw $t5, 0($t3)
addi $t3, $t4, 25540
sw $t5, 0($t3)
addi $t3, $t4, 25544
sw $t5, 0($t3)
addi $t3, $t4, 25548
sw $t5, 0($t3)
addi $t3, $t4, 25552
sw $t5, 0($t3)
addi $t3, $t4, 25556
sw $t5, 0($t3)
addi $t3, $t4, 25560
sw $t5, 0($t3)
addi $t3, $t4, 25564
sw $t5, 0($t3)
addi $t3, $t4, 25568
sw $t5, 0($t3)
addi $t3, $t4, 25572
sw $t5, 0($t3)
addi $t3, $t4, 25576
sw $t5, 0($t3)
addi $t3, $t4, 25580
sw $t5, 0($t3)
addi $t3, $t4, 25584
sw $t5, 0($t3)
addi $t3, $t4, 25588
sw $t5, 0($t3)
addi $t3, $t4, 25592
sw $t5, 0($t3)
addi $t3, $t4, 25596
sw $t5, 0($t3)
addi $t3, $t4, 25600
sw $t5, 0($t3)
addi $t3, $t4, 25604
sw $t5, 0($t3)
addi $t3, $t4, 25608
sw $t5, 0($t3)
addi $t3, $t4, 25612
sw $t5, 0($t3)
addi $t3, $t4, 25616
sw $t5, 0($t3)
addi $t3, $t4, 25620
sw $t5, 0($t3)
addi $t3, $t4, 25624
sw $t5, 0($t3)
addi $t3, $t4, 25628
li $t5,0xdedede
sw $t5, 0($t3)
addi $t3, $t4, 25632
li $t5,0x020202
sw $t5, 0($t3)
addi $t3, $t4, 25636
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 25640
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 25644
sw $t5, 0($t3)
addi $t3, $t4, 25648
sw $t5, 0($t3)
addi $t3, $t4, 25652
li $t5,0x161616
sw $t5, 0($t3)
addi $t3, $t4, 25656
li $t5,0x040404
sw $t5, 0($t3)
addi $t3, $t4, 25660
li $t5,0x5b5b5b
sw $t5, 0($t3)
addi $t3, $t4, 25664
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 25668
sw $t5, 0($t3)
addi $t3, $t4, 25672
sw $t5, 0($t3)
addi $t3, $t4, 25676
sw $t5, 0($t3)
addi $t3, $t4, 25680
sw $t5, 0($t3)
addi $t3, $t4, 25684
sw $t5, 0($t3)
addi $t3, $t4, 25688
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 25692
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 25696
sw $t5, 0($t3)
addi $t3, $t4, 25700
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 25704
li $t5,0x606060
sw $t5, 0($t3)
addi $t3, $t4, 25708
li $t5,0xcbcbcb
sw $t5, 0($t3)
addi $t3, $t4, 25712
li $t5,0x020202
sw $t5, 0($t3)
addi $t3, $t4, 25716
li $t5,0x6f6f6f
sw $t5, 0($t3)
addi $t3, $t4, 25720
li $t5,0x5e5e5e
sw $t5, 0($t3)
addi $t3, $t4, 25724
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 25728
li $t5,0x545454
sw $t5, 0($t3)
addi $t3, $t4, 25732
li $t5,0x7a7a7a
sw $t5, 0($t3)
addi $t3, $t4, 25736
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 25740
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 25744
sw $t5, 0($t3)
addi $t3, $t4, 25748
sw $t5, 0($t3)
addi $t3, $t4, 25752
sw $t5, 0($t3)
addi $t3, $t4, 25756
sw $t5, 0($t3)
addi $t3, $t4, 25760
li $t5,0xa4a4a4
sw $t5, 0($t3)
addi $t3, $t4, 25764
li $t5,0x020202
sw $t5, 0($t3)
addi $t3, $t4, 25768
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 25772
sw $t5, 0($t3)
addi $t3, $t4, 25776
sw $t5, 0($t3)
addi $t3, $t4, 25780
sw $t5, 0($t3)
addi $t3, $t4, 25784
li $t5,0x020202
sw $t5, 0($t3)
addi $t3, $t4, 25788
li $t5,0xcacaca
sw $t5, 0($t3)
addi $t3, $t4, 25792
li $t5,0x2b2b2b
sw $t5, 0($t3)
addi $t3, $t4, 25796
li $t5,0x959595
sw $t5, 0($t3)
addi $t3, $t4, 25800
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 25804
sw $t5, 0($t3)
addi $t3, $t4, 25808
sw $t5, 0($t3)
addi $t3, $t4, 25812
sw $t5, 0($t3)
addi $t3, $t4, 25816
sw $t5, 0($t3)
addi $t3, $t4, 25820
sw $t5, 0($t3)
addi $t3, $t4, 25824
sw $t5, 0($t3)
addi $t3, $t4, 25828
sw $t5, 0($t3)
addi $t3, $t4, 25832
sw $t5, 0($t3)
addi $t3, $t4, 25836
sw $t5, 0($t3)
addi $t3, $t4, 25840
sw $t5, 0($t3)
addi $t3, $t4, 25844
sw $t5, 0($t3)
addi $t3, $t4, 25848
sw $t5, 0($t3)
addi $t3, $t4, 25852
sw $t5, 0($t3)
addi $t3, $t4, 25856
sw $t5, 0($t3)
addi $t3, $t4, 25860
sw $t5, 0($t3)
addi $t3, $t4, 25864
sw $t5, 0($t3)
addi $t3, $t4, 25868
sw $t5, 0($t3)
addi $t3, $t4, 25872
sw $t5, 0($t3)
addi $t3, $t4, 25876
sw $t5, 0($t3)
addi $t3, $t4, 25880
sw $t5, 0($t3)
addi $t3, $t4, 25884
sw $t5, 0($t3)
addi $t3, $t4, 25888
sw $t5, 0($t3)
addi $t3, $t4, 25892
sw $t5, 0($t3)
addi $t3, $t4, 25896
sw $t5, 0($t3)
addi $t3, $t4, 25900
sw $t5, 0($t3)
addi $t3, $t4, 25904
sw $t5, 0($t3)
addi $t3, $t4, 25908
sw $t5, 0($t3)
addi $t3, $t4, 25912
sw $t5, 0($t3)
addi $t3, $t4, 25916
sw $t5, 0($t3)
addi $t3, $t4, 25920
sw $t5, 0($t3)
addi $t3, $t4, 25924
sw $t5, 0($t3)
addi $t3, $t4, 25928
sw $t5, 0($t3)
addi $t3, $t4, 25932
sw $t5, 0($t3)
addi $t3, $t4, 25936
sw $t5, 0($t3)
addi $t3, $t4, 25940
sw $t5, 0($t3)
addi $t3, $t4, 25944
sw $t5, 0($t3)
addi $t3, $t4, 25948
sw $t5, 0($t3)
addi $t3, $t4, 25952
sw $t5, 0($t3)
addi $t3, $t4, 25956
sw $t5, 0($t3)
addi $t3, $t4, 25960
sw $t5, 0($t3)
addi $t3, $t4, 25964
sw $t5, 0($t3)
addi $t3, $t4, 25968
sw $t5, 0($t3)
addi $t3, $t4, 25972
sw $t5, 0($t3)
addi $t3, $t4, 25976
sw $t5, 0($t3)
addi $t3, $t4, 25980
sw $t5, 0($t3)
addi $t3, $t4, 25984
sw $t5, 0($t3)
addi $t3, $t4, 25988
sw $t5, 0($t3)
addi $t3, $t4, 25992
sw $t5, 0($t3)
addi $t3, $t4, 25996
sw $t5, 0($t3)
addi $t3, $t4, 26000
sw $t5, 0($t3)
addi $t3, $t4, 26004
sw $t5, 0($t3)
addi $t3, $t4, 26008
sw $t5, 0($t3)
addi $t3, $t4, 26012
sw $t5, 0($t3)
addi $t3, $t4, 26016
sw $t5, 0($t3)
addi $t3, $t4, 26020
sw $t5, 0($t3)
addi $t3, $t4, 26024
sw $t5, 0($t3)
addi $t3, $t4, 26028
sw $t5, 0($t3)
addi $t3, $t4, 26032
sw $t5, 0($t3)
addi $t3, $t4, 26036
sw $t5, 0($t3)
addi $t3, $t4, 26040
sw $t5, 0($t3)
addi $t3, $t4, 26044
sw $t5, 0($t3)
addi $t3, $t4, 26048
sw $t5, 0($t3)
addi $t3, $t4, 26052
sw $t5, 0($t3)
addi $t3, $t4, 26056
sw $t5, 0($t3)
addi $t3, $t4, 26060
sw $t5, 0($t3)
addi $t3, $t4, 26064
sw $t5, 0($t3)
addi $t3, $t4, 26068
sw $t5, 0($t3)
addi $t3, $t4, 26072
sw $t5, 0($t3)
addi $t3, $t4, 26076
sw $t5, 0($t3)
addi $t3, $t4, 26080
sw $t5, 0($t3)
addi $t3, $t4, 26084
sw $t5, 0($t3)
addi $t3, $t4, 26088
sw $t5, 0($t3)
addi $t3, $t4, 26092
sw $t5, 0($t3)
addi $t3, $t4, 26096
sw $t5, 0($t3)
addi $t3, $t4, 26100
sw $t5, 0($t3)
addi $t3, $t4, 26104
sw $t5, 0($t3)
addi $t3, $t4, 26108
sw $t5, 0($t3)
addi $t3, $t4, 26112
sw $t5, 0($t3)
addi $t3, $t4, 26116
sw $t5, 0($t3)
addi $t3, $t4, 26120
sw $t5, 0($t3)
addi $t3, $t4, 26124
sw $t5, 0($t3)
addi $t3, $t4, 26128
sw $t5, 0($t3)
addi $t3, $t4, 26132
sw $t5, 0($t3)
addi $t3, $t4, 26136
sw $t5, 0($t3)
addi $t3, $t4, 26140
li $t5,0xfdfdfd
sw $t5, 0($t3)
addi $t3, $t4, 26144
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 26148
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 26152
sw $t5, 0($t3)
addi $t3, $t4, 26156
sw $t5, 0($t3)
addi $t3, $t4, 26160
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 26164
li $t5,0x929292
sw $t5, 0($t3)
addi $t3, $t4, 26168
li $t5,0x6d6d6d
sw $t5, 0($t3)
addi $t3, $t4, 26172
li $t5,0xebebeb
sw $t5, 0($t3)
addi $t3, $t4, 26176
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 26180
sw $t5, 0($t3)
addi $t3, $t4, 26184
sw $t5, 0($t3)
addi $t3, $t4, 26188
sw $t5, 0($t3)
addi $t3, $t4, 26192
sw $t5, 0($t3)
addi $t3, $t4, 26196
sw $t5, 0($t3)
addi $t3, $t4, 26200
li $t5,0x727272
sw $t5, 0($t3)
addi $t3, $t4, 26204
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 26208
sw $t5, 0($t3)
addi $t3, $t4, 26212
sw $t5, 0($t3)
addi $t3, $t4, 26216
li $t5,0x020202
sw $t5, 0($t3)
addi $t3, $t4, 26220
sw $t5, 0($t3)
addi $t3, $t4, 26224
li $t5,0x0d0d0d
sw $t5, 0($t3)
addi $t3, $t4, 26228
li $t5,0x6d6d6d
sw $t5, 0($t3)
addi $t3, $t4, 26232
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 26236
li $t5,0x3b3b3b
sw $t5, 0($t3)
addi $t3, $t4, 26240
li $t5,0x393939
sw $t5, 0($t3)
addi $t3, $t4, 26244
li $t5,0xe9e9e9
sw $t5, 0($t3)
addi $t3, $t4, 26248
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 26252
sw $t5, 0($t3)
addi $t3, $t4, 26256
sw $t5, 0($t3)
addi $t3, $t4, 26260
sw $t5, 0($t3)
addi $t3, $t4, 26264
sw $t5, 0($t3)
addi $t3, $t4, 26268
sw $t5, 0($t3)
addi $t3, $t4, 26272
sw $t5, 0($t3)
addi $t3, $t4, 26276
li $t5,0x2b2b2b
sw $t5, 0($t3)
addi $t3, $t4, 26280
li $t5,0x020202
sw $t5, 0($t3)
addi $t3, $t4, 26284
sw $t5, 0($t3)
addi $t3, $t4, 26288
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 26292
sw $t5, 0($t3)
addi $t3, $t4, 26296
li $t5,0x232323
sw $t5, 0($t3)
addi $t3, $t4, 26300
li $t5,0x090909
sw $t5, 0($t3)
addi $t3, $t4, 26304
li $t5,0x717171
sw $t5, 0($t3)
addi $t3, $t4, 26308
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 26312
sw $t5, 0($t3)
addi $t3, $t4, 26316
sw $t5, 0($t3)
addi $t3, $t4, 26320
sw $t5, 0($t3)
addi $t3, $t4, 26324
sw $t5, 0($t3)
addi $t3, $t4, 26328
sw $t5, 0($t3)
addi $t3, $t4, 26332
sw $t5, 0($t3)
addi $t3, $t4, 26336
sw $t5, 0($t3)
addi $t3, $t4, 26340
sw $t5, 0($t3)
addi $t3, $t4, 26344
sw $t5, 0($t3)
addi $t3, $t4, 26348
sw $t5, 0($t3)
addi $t3, $t4, 26352
sw $t5, 0($t3)
addi $t3, $t4, 26356
sw $t5, 0($t3)
addi $t3, $t4, 26360
sw $t5, 0($t3)
addi $t3, $t4, 26364
sw $t5, 0($t3)
addi $t3, $t4, 26368
sw $t5, 0($t3)
addi $t3, $t4, 26372
sw $t5, 0($t3)
addi $t3, $t4, 26376
sw $t5, 0($t3)
addi $t3, $t4, 26380
sw $t5, 0($t3)
addi $t3, $t4, 26384
sw $t5, 0($t3)
addi $t3, $t4, 26388
sw $t5, 0($t3)
addi $t3, $t4, 26392
sw $t5, 0($t3)
addi $t3, $t4, 26396
sw $t5, 0($t3)
addi $t3, $t4, 26400
sw $t5, 0($t3)
addi $t3, $t4, 26404
sw $t5, 0($t3)
addi $t3, $t4, 26408
sw $t5, 0($t3)
addi $t3, $t4, 26412
sw $t5, 0($t3)
addi $t3, $t4, 26416
sw $t5, 0($t3)
addi $t3, $t4, 26420
sw $t5, 0($t3)
addi $t3, $t4, 26424
sw $t5, 0($t3)
addi $t3, $t4, 26428
sw $t5, 0($t3)
addi $t3, $t4, 26432
sw $t5, 0($t3)
addi $t3, $t4, 26436
sw $t5, 0($t3)
addi $t3, $t4, 26440
sw $t5, 0($t3)
addi $t3, $t4, 26444
sw $t5, 0($t3)
addi $t3, $t4, 26448
sw $t5, 0($t3)
addi $t3, $t4, 26452
sw $t5, 0($t3)
addi $t3, $t4, 26456
sw $t5, 0($t3)
addi $t3, $t4, 26460
sw $t5, 0($t3)
addi $t3, $t4, 26464
sw $t5, 0($t3)
addi $t3, $t4, 26468
sw $t5, 0($t3)
addi $t3, $t4, 26472
sw $t5, 0($t3)
addi $t3, $t4, 26476
sw $t5, 0($t3)
addi $t3, $t4, 26480
sw $t5, 0($t3)
addi $t3, $t4, 26484
sw $t5, 0($t3)
addi $t3, $t4, 26488
sw $t5, 0($t3)
addi $t3, $t4, 26492
sw $t5, 0($t3)
addi $t3, $t4, 26496
sw $t5, 0($t3)
addi $t3, $t4, 26500
sw $t5, 0($t3)
addi $t3, $t4, 26504
sw $t5, 0($t3)
addi $t3, $t4, 26508
sw $t5, 0($t3)
addi $t3, $t4, 26512
sw $t5, 0($t3)
addi $t3, $t4, 26516
sw $t5, 0($t3)
addi $t3, $t4, 26520
sw $t5, 0($t3)
addi $t3, $t4, 26524
sw $t5, 0($t3)
addi $t3, $t4, 26528
sw $t5, 0($t3)
addi $t3, $t4, 26532
sw $t5, 0($t3)
addi $t3, $t4, 26536
sw $t5, 0($t3)
addi $t3, $t4, 26540
sw $t5, 0($t3)
addi $t3, $t4, 26544
sw $t5, 0($t3)
addi $t3, $t4, 26548
sw $t5, 0($t3)
addi $t3, $t4, 26552
sw $t5, 0($t3)
addi $t3, $t4, 26556
sw $t5, 0($t3)
addi $t3, $t4, 26560
sw $t5, 0($t3)
addi $t3, $t4, 26564
sw $t5, 0($t3)
addi $t3, $t4, 26568
sw $t5, 0($t3)
addi $t3, $t4, 26572
sw $t5, 0($t3)
addi $t3, $t4, 26576
sw $t5, 0($t3)
addi $t3, $t4, 26580
sw $t5, 0($t3)
addi $t3, $t4, 26584
sw $t5, 0($t3)
addi $t3, $t4, 26588
sw $t5, 0($t3)
addi $t3, $t4, 26592
sw $t5, 0($t3)
addi $t3, $t4, 26596
sw $t5, 0($t3)
addi $t3, $t4, 26600
sw $t5, 0($t3)
addi $t3, $t4, 26604
sw $t5, 0($t3)
addi $t3, $t4, 26608
sw $t5, 0($t3)
addi $t3, $t4, 26612
sw $t5, 0($t3)
addi $t3, $t4, 26616
sw $t5, 0($t3)
addi $t3, $t4, 26620
sw $t5, 0($t3)
addi $t3, $t4, 26624
sw $t5, 0($t3)
addi $t3, $t4, 26628
sw $t5, 0($t3)
addi $t3, $t4, 26632
sw $t5, 0($t3)
addi $t3, $t4, 26636
sw $t5, 0($t3)
addi $t3, $t4, 26640
sw $t5, 0($t3)
addi $t3, $t4, 26644
sw $t5, 0($t3)
addi $t3, $t4, 26648
sw $t5, 0($t3)
addi $t3, $t4, 26652
li $t5,0xfcfcfc
sw $t5, 0($t3)
addi $t3, $t4, 26656
li $t5,0x020202
sw $t5, 0($t3)
addi $t3, $t4, 26660
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 26664
sw $t5, 0($t3)
addi $t3, $t4, 26668
sw $t5, 0($t3)
addi $t3, $t4, 26672
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 26676
li $t5,0x0e0e0e
sw $t5, 0($t3)
addi $t3, $t4, 26680
li $t5,0x7b7b7b
sw $t5, 0($t3)
addi $t3, $t4, 26684
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 26688
sw $t5, 0($t3)
addi $t3, $t4, 26692
sw $t5, 0($t3)
addi $t3, $t4, 26696
sw $t5, 0($t3)
addi $t3, $t4, 26700
sw $t5, 0($t3)
addi $t3, $t4, 26704
sw $t5, 0($t3)
addi $t3, $t4, 26708
sw $t5, 0($t3)
addi $t3, $t4, 26712
li $t5,0xfdfdfd
sw $t5, 0($t3)
addi $t3, $t4, 26716
li $t5,0x1b1b1b
sw $t5, 0($t3)
addi $t3, $t4, 26720
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 26724
sw $t5, 0($t3)
addi $t3, $t4, 26728
sw $t5, 0($t3)
addi $t3, $t4, 26732
sw $t5, 0($t3)
addi $t3, $t4, 26736
sw $t5, 0($t3)
addi $t3, $t4, 26740
sw $t5, 0($t3)
addi $t3, $t4, 26744
sw $t5, 0($t3)
addi $t3, $t4, 26748
li $t5,0x939393
sw $t5, 0($t3)
addi $t3, $t4, 26752
li $t5,0x8e8e8e
sw $t5, 0($t3)
addi $t3, $t4, 26756
li $t5,0xfdfdfd
sw $t5, 0($t3)
addi $t3, $t4, 26760
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 26764
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 26768
sw $t5, 0($t3)
addi $t3, $t4, 26772
sw $t5, 0($t3)
addi $t3, $t4, 26776
sw $t5, 0($t3)
addi $t3, $t4, 26780
sw $t5, 0($t3)
addi $t3, $t4, 26784
sw $t5, 0($t3)
addi $t3, $t4, 26788
sw $t5, 0($t3)
addi $t3, $t4, 26792
li $t5,0x7e7e7e
sw $t5, 0($t3)
addi $t3, $t4, 26796
li $t5,0x040404
sw $t5, 0($t3)
addi $t3, $t4, 26800
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 26804
sw $t5, 0($t3)
addi $t3, $t4, 26808
li $t5,0x060606
sw $t5, 0($t3)
addi $t3, $t4, 26812
li $t5,0xf1f1f1
sw $t5, 0($t3)
addi $t3, $t4, 26816
li $t5,0xfdfdfd
sw $t5, 0($t3)
addi $t3, $t4, 26820
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 26824
sw $t5, 0($t3)
addi $t3, $t4, 26828
sw $t5, 0($t3)
addi $t3, $t4, 26832
sw $t5, 0($t3)
addi $t3, $t4, 26836
sw $t5, 0($t3)
addi $t3, $t4, 26840
sw $t5, 0($t3)
addi $t3, $t4, 26844
sw $t5, 0($t3)
addi $t3, $t4, 26848
sw $t5, 0($t3)
addi $t3, $t4, 26852
sw $t5, 0($t3)
addi $t3, $t4, 26856
sw $t5, 0($t3)
addi $t3, $t4, 26860
sw $t5, 0($t3)
addi $t3, $t4, 26864
sw $t5, 0($t3)
addi $t3, $t4, 26868
sw $t5, 0($t3)
addi $t3, $t4, 26872
sw $t5, 0($t3)
addi $t3, $t4, 26876
sw $t5, 0($t3)
addi $t3, $t4, 26880
sw $t5, 0($t3)
addi $t3, $t4, 26884
sw $t5, 0($t3)
addi $t3, $t4, 26888
sw $t5, 0($t3)
addi $t3, $t4, 26892
sw $t5, 0($t3)
addi $t3, $t4, 26896
sw $t5, 0($t3)
addi $t3, $t4, 26900
sw $t5, 0($t3)
addi $t3, $t4, 26904
sw $t5, 0($t3)
addi $t3, $t4, 26908
sw $t5, 0($t3)
addi $t3, $t4, 26912
sw $t5, 0($t3)
addi $t3, $t4, 26916
sw $t5, 0($t3)
addi $t3, $t4, 26920
sw $t5, 0($t3)
addi $t3, $t4, 26924
sw $t5, 0($t3)
addi $t3, $t4, 26928
sw $t5, 0($t3)
addi $t3, $t4, 26932
sw $t5, 0($t3)
addi $t3, $t4, 26936
sw $t5, 0($t3)
addi $t3, $t4, 26940
sw $t5, 0($t3)
addi $t3, $t4, 26944
sw $t5, 0($t3)
addi $t3, $t4, 26948
sw $t5, 0($t3)
addi $t3, $t4, 26952
sw $t5, 0($t3)
addi $t3, $t4, 26956
sw $t5, 0($t3)
addi $t3, $t4, 26960
sw $t5, 0($t3)
addi $t3, $t4, 26964
sw $t5, 0($t3)
addi $t3, $t4, 26968
sw $t5, 0($t3)
addi $t3, $t4, 26972
sw $t5, 0($t3)
addi $t3, $t4, 26976
sw $t5, 0($t3)
addi $t3, $t4, 26980
sw $t5, 0($t3)
addi $t3, $t4, 26984
sw $t5, 0($t3)
addi $t3, $t4, 26988
sw $t5, 0($t3)
addi $t3, $t4, 26992
sw $t5, 0($t3)
addi $t3, $t4, 26996
sw $t5, 0($t3)
addi $t3, $t4, 27000
sw $t5, 0($t3)
addi $t3, $t4, 27004
sw $t5, 0($t3)
addi $t3, $t4, 27008
sw $t5, 0($t3)
addi $t3, $t4, 27012
sw $t5, 0($t3)
addi $t3, $t4, 27016
sw $t5, 0($t3)
addi $t3, $t4, 27020
sw $t5, 0($t3)
addi $t3, $t4, 27024
sw $t5, 0($t3)
addi $t3, $t4, 27028
sw $t5, 0($t3)
addi $t3, $t4, 27032
sw $t5, 0($t3)
addi $t3, $t4, 27036
sw $t5, 0($t3)
addi $t3, $t4, 27040
sw $t5, 0($t3)
addi $t3, $t4, 27044
sw $t5, 0($t3)
addi $t3, $t4, 27048
sw $t5, 0($t3)
addi $t3, $t4, 27052
sw $t5, 0($t3)
addi $t3, $t4, 27056
sw $t5, 0($t3)
addi $t3, $t4, 27060
sw $t5, 0($t3)
addi $t3, $t4, 27064
sw $t5, 0($t3)
addi $t3, $t4, 27068
sw $t5, 0($t3)
addi $t3, $t4, 27072
sw $t5, 0($t3)
addi $t3, $t4, 27076
sw $t5, 0($t3)
addi $t3, $t4, 27080
sw $t5, 0($t3)
addi $t3, $t4, 27084
sw $t5, 0($t3)
addi $t3, $t4, 27088
sw $t5, 0($t3)
addi $t3, $t4, 27092
sw $t5, 0($t3)
addi $t3, $t4, 27096
sw $t5, 0($t3)
addi $t3, $t4, 27100
sw $t5, 0($t3)
addi $t3, $t4, 27104
sw $t5, 0($t3)
addi $t3, $t4, 27108
sw $t5, 0($t3)
addi $t3, $t4, 27112
sw $t5, 0($t3)
addi $t3, $t4, 27116
sw $t5, 0($t3)
addi $t3, $t4, 27120
sw $t5, 0($t3)
addi $t3, $t4, 27124
sw $t5, 0($t3)
addi $t3, $t4, 27128
sw $t5, 0($t3)
addi $t3, $t4, 27132
sw $t5, 0($t3)
addi $t3, $t4, 27136
sw $t5, 0($t3)
addi $t3, $t4, 27140
sw $t5, 0($t3)
addi $t3, $t4, 27144
sw $t5, 0($t3)
addi $t3, $t4, 27148
sw $t5, 0($t3)
addi $t3, $t4, 27152
sw $t5, 0($t3)
addi $t3, $t4, 27156
sw $t5, 0($t3)
addi $t3, $t4, 27160
sw $t5, 0($t3)
addi $t3, $t4, 27164
li $t5,0xbababa
sw $t5, 0($t3)
addi $t3, $t4, 27168
li $t5,0x020202
sw $t5, 0($t3)
addi $t3, $t4, 27172
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 27176
sw $t5, 0($t3)
addi $t3, $t4, 27180
sw $t5, 0($t3)
addi $t3, $t4, 27184
sw $t5, 0($t3)
addi $t3, $t4, 27188
li $t5,0x4d4d4d
sw $t5, 0($t3)
addi $t3, $t4, 27192
li $t5,0xdbdbdb
sw $t5, 0($t3)
addi $t3, $t4, 27196
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 27200
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 27204
sw $t5, 0($t3)
addi $t3, $t4, 27208
sw $t5, 0($t3)
addi $t3, $t4, 27212
sw $t5, 0($t3)
addi $t3, $t4, 27216
sw $t5, 0($t3)
addi $t3, $t4, 27220
sw $t5, 0($t3)
addi $t3, $t4, 27224
sw $t5, 0($t3)
addi $t3, $t4, 27228
li $t5,0xfafafa
sw $t5, 0($t3)
addi $t3, $t4, 27232
li $t5,0x0b0b0b
sw $t5, 0($t3)
addi $t3, $t4, 27236
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 27240
sw $t5, 0($t3)
addi $t3, $t4, 27244
sw $t5, 0($t3)
addi $t3, $t4, 27248
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 27252
sw $t5, 0($t3)
addi $t3, $t4, 27256
li $t5,0x7f7f7f
sw $t5, 0($t3)
addi $t3, $t4, 27260
li $t5,0x060606
sw $t5, 0($t3)
addi $t3, $t4, 27264
li $t5,0xf2f2f2
sw $t5, 0($t3)
addi $t3, $t4, 27268
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 27272
sw $t5, 0($t3)
addi $t3, $t4, 27276
sw $t5, 0($t3)
addi $t3, $t4, 27280
sw $t5, 0($t3)
addi $t3, $t4, 27284
sw $t5, 0($t3)
addi $t3, $t4, 27288
sw $t5, 0($t3)
addi $t3, $t4, 27292
sw $t5, 0($t3)
addi $t3, $t4, 27296
sw $t5, 0($t3)
addi $t3, $t4, 27300
sw $t5, 0($t3)
addi $t3, $t4, 27304
sw $t5, 0($t3)
addi $t3, $t4, 27308
li $t5,0xfcfcfc
sw $t5, 0($t3)
addi $t3, $t4, 27312
li $t5,0xefefef
sw $t5, 0($t3)
addi $t3, $t4, 27316
li $t5,0xf4f4f4
sw $t5, 0($t3)
addi $t3, $t4, 27320
li $t5,0xfcfcfc
sw $t5, 0($t3)
addi $t3, $t4, 27324
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 27328
sw $t5, 0($t3)
addi $t3, $t4, 27332
sw $t5, 0($t3)
addi $t3, $t4, 27336
sw $t5, 0($t3)
addi $t3, $t4, 27340
sw $t5, 0($t3)
addi $t3, $t4, 27344
sw $t5, 0($t3)
addi $t3, $t4, 27348
sw $t5, 0($t3)
addi $t3, $t4, 27352
sw $t5, 0($t3)
addi $t3, $t4, 27356
sw $t5, 0($t3)
addi $t3, $t4, 27360
sw $t5, 0($t3)
addi $t3, $t4, 27364
sw $t5, 0($t3)
addi $t3, $t4, 27368
sw $t5, 0($t3)
addi $t3, $t4, 27372
sw $t5, 0($t3)
addi $t3, $t4, 27376
sw $t5, 0($t3)
addi $t3, $t4, 27380
sw $t5, 0($t3)
addi $t3, $t4, 27384
sw $t5, 0($t3)
addi $t3, $t4, 27388
sw $t5, 0($t3)
addi $t3, $t4, 27392
sw $t5, 0($t3)
addi $t3, $t4, 27396
sw $t5, 0($t3)
addi $t3, $t4, 27400
sw $t5, 0($t3)
addi $t3, $t4, 27404
sw $t5, 0($t3)
addi $t3, $t4, 27408
sw $t5, 0($t3)
addi $t3, $t4, 27412
sw $t5, 0($t3)
addi $t3, $t4, 27416
sw $t5, 0($t3)
addi $t3, $t4, 27420
sw $t5, 0($t3)
addi $t3, $t4, 27424
sw $t5, 0($t3)
addi $t3, $t4, 27428
sw $t5, 0($t3)
addi $t3, $t4, 27432
sw $t5, 0($t3)
addi $t3, $t4, 27436
sw $t5, 0($t3)
addi $t3, $t4, 27440
sw $t5, 0($t3)
addi $t3, $t4, 27444
sw $t5, 0($t3)
addi $t3, $t4, 27448
sw $t5, 0($t3)
addi $t3, $t4, 27452
sw $t5, 0($t3)
addi $t3, $t4, 27456
sw $t5, 0($t3)
addi $t3, $t4, 27460
sw $t5, 0($t3)
addi $t3, $t4, 27464
sw $t5, 0($t3)
addi $t3, $t4, 27468
sw $t5, 0($t3)
addi $t3, $t4, 27472
sw $t5, 0($t3)
addi $t3, $t4, 27476
sw $t5, 0($t3)
addi $t3, $t4, 27480
sw $t5, 0($t3)
addi $t3, $t4, 27484
sw $t5, 0($t3)
addi $t3, $t4, 27488
sw $t5, 0($t3)
addi $t3, $t4, 27492
sw $t5, 0($t3)
addi $t3, $t4, 27496
sw $t5, 0($t3)
addi $t3, $t4, 27500
sw $t5, 0($t3)
addi $t3, $t4, 27504
sw $t5, 0($t3)
addi $t3, $t4, 27508
sw $t5, 0($t3)
addi $t3, $t4, 27512
sw $t5, 0($t3)
addi $t3, $t4, 27516
sw $t5, 0($t3)
addi $t3, $t4, 27520
sw $t5, 0($t3)
addi $t3, $t4, 27524
sw $t5, 0($t3)
addi $t3, $t4, 27528
sw $t5, 0($t3)
addi $t3, $t4, 27532
sw $t5, 0($t3)
addi $t3, $t4, 27536
sw $t5, 0($t3)
addi $t3, $t4, 27540
sw $t5, 0($t3)
addi $t3, $t4, 27544
sw $t5, 0($t3)
addi $t3, $t4, 27548
sw $t5, 0($t3)
addi $t3, $t4, 27552
sw $t5, 0($t3)
addi $t3, $t4, 27556
sw $t5, 0($t3)
addi $t3, $t4, 27560
sw $t5, 0($t3)
addi $t3, $t4, 27564
sw $t5, 0($t3)
addi $t3, $t4, 27568
sw $t5, 0($t3)
addi $t3, $t4, 27572
sw $t5, 0($t3)
addi $t3, $t4, 27576
sw $t5, 0($t3)
addi $t3, $t4, 27580
sw $t5, 0($t3)
addi $t3, $t4, 27584
sw $t5, 0($t3)
addi $t3, $t4, 27588
sw $t5, 0($t3)
addi $t3, $t4, 27592
sw $t5, 0($t3)
addi $t3, $t4, 27596
sw $t5, 0($t3)
addi $t3, $t4, 27600
sw $t5, 0($t3)
addi $t3, $t4, 27604
sw $t5, 0($t3)
addi $t3, $t4, 27608
sw $t5, 0($t3)
addi $t3, $t4, 27612
sw $t5, 0($t3)
addi $t3, $t4, 27616
sw $t5, 0($t3)
addi $t3, $t4, 27620
sw $t5, 0($t3)
addi $t3, $t4, 27624
sw $t5, 0($t3)
addi $t3, $t4, 27628
sw $t5, 0($t3)
addi $t3, $t4, 27632
sw $t5, 0($t3)
addi $t3, $t4, 27636
sw $t5, 0($t3)
addi $t3, $t4, 27640
sw $t5, 0($t3)
addi $t3, $t4, 27644
sw $t5, 0($t3)
addi $t3, $t4, 27648
sw $t5, 0($t3)
addi $t3, $t4, 27652
sw $t5, 0($t3)
addi $t3, $t4, 27656
sw $t5, 0($t3)
addi $t3, $t4, 27660
sw $t5, 0($t3)
addi $t3, $t4, 27664
sw $t5, 0($t3)
addi $t3, $t4, 27668
sw $t5, 0($t3)
addi $t3, $t4, 27672
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 27676
li $t5,0x181818
sw $t5, 0($t3)
addi $t3, $t4, 27680
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 27684
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 27688
sw $t5, 0($t3)
addi $t3, $t4, 27692
sw $t5, 0($t3)
addi $t3, $t4, 27696
sw $t5, 0($t3)
addi $t3, $t4, 27700
li $t5,0x6a6a6a
sw $t5, 0($t3)
addi $t3, $t4, 27704
li $t5,0xfcfcfc
sw $t5, 0($t3)
addi $t3, $t4, 27708
li $t5,0xfffffe
sw $t5, 0($t3)
addi $t3, $t4, 27712
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 27716
sw $t5, 0($t3)
addi $t3, $t4, 27720
sw $t5, 0($t3)
addi $t3, $t4, 27724
sw $t5, 0($t3)
addi $t3, $t4, 27728
sw $t5, 0($t3)
addi $t3, $t4, 27732
sw $t5, 0($t3)
addi $t3, $t4, 27736
sw $t5, 0($t3)
addi $t3, $t4, 27740
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 27744
li $t5,0xefefef
sw $t5, 0($t3)
addi $t3, $t4, 27748
li $t5,0x0b0b0b
sw $t5, 0($t3)
addi $t3, $t4, 27752
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 27756
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 27760
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 27764
li $t5,0x020202
sw $t5, 0($t3)
addi $t3, $t4, 27768
li $t5,0x080808
sw $t5, 0($t3)
addi $t3, $t4, 27772
li $t5,0xc3c3c3
sw $t5, 0($t3)
addi $t3, $t4, 27776
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 27780
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 27784
sw $t5, 0($t3)
addi $t3, $t4, 27788
sw $t5, 0($t3)
addi $t3, $t4, 27792
sw $t5, 0($t3)
addi $t3, $t4, 27796
sw $t5, 0($t3)
addi $t3, $t4, 27800
sw $t5, 0($t3)
addi $t3, $t4, 27804
sw $t5, 0($t3)
addi $t3, $t4, 27808
sw $t5, 0($t3)
addi $t3, $t4, 27812
sw $t5, 0($t3)
addi $t3, $t4, 27816
sw $t5, 0($t3)
addi $t3, $t4, 27820
sw $t5, 0($t3)
addi $t3, $t4, 27824
sw $t5, 0($t3)
addi $t3, $t4, 27828
sw $t5, 0($t3)
addi $t3, $t4, 27832
sw $t5, 0($t3)
addi $t3, $t4, 27836
sw $t5, 0($t3)
addi $t3, $t4, 27840
sw $t5, 0($t3)
addi $t3, $t4, 27844
sw $t5, 0($t3)
addi $t3, $t4, 27848
sw $t5, 0($t3)
addi $t3, $t4, 27852
sw $t5, 0($t3)
addi $t3, $t4, 27856
sw $t5, 0($t3)
addi $t3, $t4, 27860
sw $t5, 0($t3)
addi $t3, $t4, 27864
sw $t5, 0($t3)
addi $t3, $t4, 27868
sw $t5, 0($t3)
addi $t3, $t4, 27872
sw $t5, 0($t3)
addi $t3, $t4, 27876
sw $t5, 0($t3)
addi $t3, $t4, 27880
sw $t5, 0($t3)
addi $t3, $t4, 27884
sw $t5, 0($t3)
addi $t3, $t4, 27888
sw $t5, 0($t3)
addi $t3, $t4, 27892
sw $t5, 0($t3)
addi $t3, $t4, 27896
sw $t5, 0($t3)
addi $t3, $t4, 27900
sw $t5, 0($t3)
addi $t3, $t4, 27904
sw $t5, 0($t3)
addi $t3, $t4, 27908
sw $t5, 0($t3)
addi $t3, $t4, 27912
sw $t5, 0($t3)
addi $t3, $t4, 27916
sw $t5, 0($t3)
addi $t3, $t4, 27920
sw $t5, 0($t3)
addi $t3, $t4, 27924
sw $t5, 0($t3)
addi $t3, $t4, 27928
sw $t5, 0($t3)
addi $t3, $t4, 27932
sw $t5, 0($t3)
addi $t3, $t4, 27936
sw $t5, 0($t3)
addi $t3, $t4, 27940
sw $t5, 0($t3)
addi $t3, $t4, 27944
sw $t5, 0($t3)
addi $t3, $t4, 27948
sw $t5, 0($t3)
addi $t3, $t4, 27952
sw $t5, 0($t3)
addi $t3, $t4, 27956
sw $t5, 0($t3)
addi $t3, $t4, 27960
sw $t5, 0($t3)
addi $t3, $t4, 27964
sw $t5, 0($t3)
addi $t3, $t4, 27968
sw $t5, 0($t3)
addi $t3, $t4, 27972
sw $t5, 0($t3)
addi $t3, $t4, 27976
sw $t5, 0($t3)
addi $t3, $t4, 27980
sw $t5, 0($t3)
addi $t3, $t4, 27984
sw $t5, 0($t3)
addi $t3, $t4, 27988
sw $t5, 0($t3)
addi $t3, $t4, 27992
sw $t5, 0($t3)
addi $t3, $t4, 27996
sw $t5, 0($t3)
addi $t3, $t4, 28000
sw $t5, 0($t3)
addi $t3, $t4, 28004
sw $t5, 0($t3)
addi $t3, $t4, 28008
sw $t5, 0($t3)
addi $t3, $t4, 28012
sw $t5, 0($t3)
addi $t3, $t4, 28016
sw $t5, 0($t3)
addi $t3, $t4, 28020
sw $t5, 0($t3)
addi $t3, $t4, 28024
sw $t5, 0($t3)
addi $t3, $t4, 28028
sw $t5, 0($t3)
addi $t3, $t4, 28032
sw $t5, 0($t3)
addi $t3, $t4, 28036
sw $t5, 0($t3)
addi $t3, $t4, 28040
sw $t5, 0($t3)
addi $t3, $t4, 28044
sw $t5, 0($t3)
addi $t3, $t4, 28048
sw $t5, 0($t3)
addi $t3, $t4, 28052
sw $t5, 0($t3)
addi $t3, $t4, 28056
sw $t5, 0($t3)
addi $t3, $t4, 28060
sw $t5, 0($t3)
addi $t3, $t4, 28064
sw $t5, 0($t3)
addi $t3, $t4, 28068
sw $t5, 0($t3)
addi $t3, $t4, 28072
sw $t5, 0($t3)
addi $t3, $t4, 28076
sw $t5, 0($t3)
addi $t3, $t4, 28080
sw $t5, 0($t3)
addi $t3, $t4, 28084
sw $t5, 0($t3)
addi $t3, $t4, 28088
sw $t5, 0($t3)
addi $t3, $t4, 28092
sw $t5, 0($t3)
addi $t3, $t4, 28096
sw $t5, 0($t3)
addi $t3, $t4, 28100
sw $t5, 0($t3)
addi $t3, $t4, 28104
sw $t5, 0($t3)
addi $t3, $t4, 28108
sw $t5, 0($t3)
addi $t3, $t4, 28112
sw $t5, 0($t3)
addi $t3, $t4, 28116
sw $t5, 0($t3)
addi $t3, $t4, 28120
sw $t5, 0($t3)
addi $t3, $t4, 28124
sw $t5, 0($t3)
addi $t3, $t4, 28128
sw $t5, 0($t3)
addi $t3, $t4, 28132
sw $t5, 0($t3)
addi $t3, $t4, 28136
sw $t5, 0($t3)
addi $t3, $t4, 28140
sw $t5, 0($t3)
addi $t3, $t4, 28144
sw $t5, 0($t3)
addi $t3, $t4, 28148
sw $t5, 0($t3)
addi $t3, $t4, 28152
sw $t5, 0($t3)
addi $t3, $t4, 28156
sw $t5, 0($t3)
addi $t3, $t4, 28160
sw $t5, 0($t3)
addi $t3, $t4, 28164
sw $t5, 0($t3)
addi $t3, $t4, 28168
sw $t5, 0($t3)
addi $t3, $t4, 28172
sw $t5, 0($t3)
addi $t3, $t4, 28176
sw $t5, 0($t3)
addi $t3, $t4, 28180
sw $t5, 0($t3)
addi $t3, $t4, 28184
li $t5,0xfdfdfd
sw $t5, 0($t3)
addi $t3, $t4, 28188
li $t5,0x020202
sw $t5, 0($t3)
addi $t3, $t4, 28192
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 28196
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 28200
sw $t5, 0($t3)
addi $t3, $t4, 28204
sw $t5, 0($t3)
addi $t3, $t4, 28208
li $t5,0x0a0a0a
sw $t5, 0($t3)
addi $t3, $t4, 28212
li $t5,0xdddddd
sw $t5, 0($t3)
addi $t3, $t4, 28216
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 28220
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 28224
sw $t5, 0($t3)
addi $t3, $t4, 28228
sw $t5, 0($t3)
addi $t3, $t4, 28232
sw $t5, 0($t3)
addi $t3, $t4, 28236
sw $t5, 0($t3)
addi $t3, $t4, 28240
sw $t5, 0($t3)
addi $t3, $t4, 28244
sw $t5, 0($t3)
addi $t3, $t4, 28248
sw $t5, 0($t3)
addi $t3, $t4, 28252
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 28256
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 28260
li $t5,0xfbfbfb
sw $t5, 0($t3)
addi $t3, $t4, 28264
li $t5,0x959595
sw $t5, 0($t3)
addi $t3, $t4, 28268
li $t5,0x101010
sw $t5, 0($t3)
addi $t3, $t4, 28272
li $t5,0x040404
sw $t5, 0($t3)
addi $t3, $t4, 28276
li $t5,0x474747
sw $t5, 0($t3)
addi $t3, $t4, 28280
li $t5,0xe4e4e4
sw $t5, 0($t3)
addi $t3, $t4, 28284
li $t5,0xfdfdfd
sw $t5, 0($t3)
addi $t3, $t4, 28288
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 28292
sw $t5, 0($t3)
addi $t3, $t4, 28296
sw $t5, 0($t3)
addi $t3, $t4, 28300
sw $t5, 0($t3)
addi $t3, $t4, 28304
sw $t5, 0($t3)
addi $t3, $t4, 28308
sw $t5, 0($t3)
addi $t3, $t4, 28312
sw $t5, 0($t3)
addi $t3, $t4, 28316
sw $t5, 0($t3)
addi $t3, $t4, 28320
sw $t5, 0($t3)
addi $t3, $t4, 28324
sw $t5, 0($t3)
addi $t3, $t4, 28328
sw $t5, 0($t3)
addi $t3, $t4, 28332
sw $t5, 0($t3)
addi $t3, $t4, 28336
sw $t5, 0($t3)
addi $t3, $t4, 28340
sw $t5, 0($t3)
addi $t3, $t4, 28344
sw $t5, 0($t3)
addi $t3, $t4, 28348
sw $t5, 0($t3)
addi $t3, $t4, 28352
sw $t5, 0($t3)
addi $t3, $t4, 28356
sw $t5, 0($t3)
addi $t3, $t4, 28360
sw $t5, 0($t3)
addi $t3, $t4, 28364
sw $t5, 0($t3)
addi $t3, $t4, 28368
sw $t5, 0($t3)
addi $t3, $t4, 28372
sw $t5, 0($t3)
addi $t3, $t4, 28376
sw $t5, 0($t3)
addi $t3, $t4, 28380
sw $t5, 0($t3)
addi $t3, $t4, 28384
sw $t5, 0($t3)
addi $t3, $t4, 28388
sw $t5, 0($t3)
addi $t3, $t4, 28392
sw $t5, 0($t3)
addi $t3, $t4, 28396
sw $t5, 0($t3)
addi $t3, $t4, 28400
sw $t5, 0($t3)
addi $t3, $t4, 28404
sw $t5, 0($t3)
addi $t3, $t4, 28408
sw $t5, 0($t3)
addi $t3, $t4, 28412
sw $t5, 0($t3)
addi $t3, $t4, 28416
sw $t5, 0($t3)
addi $t3, $t4, 28420
sw $t5, 0($t3)
addi $t3, $t4, 28424
sw $t5, 0($t3)
addi $t3, $t4, 28428
sw $t5, 0($t3)
addi $t3, $t4, 28432
sw $t5, 0($t3)
addi $t3, $t4, 28436
sw $t5, 0($t3)
addi $t3, $t4, 28440
sw $t5, 0($t3)
addi $t3, $t4, 28444
sw $t5, 0($t3)
addi $t3, $t4, 28448
sw $t5, 0($t3)
addi $t3, $t4, 28452
sw $t5, 0($t3)
addi $t3, $t4, 28456
sw $t5, 0($t3)
addi $t3, $t4, 28460
sw $t5, 0($t3)
addi $t3, $t4, 28464
sw $t5, 0($t3)
addi $t3, $t4, 28468
sw $t5, 0($t3)
addi $t3, $t4, 28472
sw $t5, 0($t3)
addi $t3, $t4, 28476
sw $t5, 0($t3)
addi $t3, $t4, 28480
sw $t5, 0($t3)
addi $t3, $t4, 28484
sw $t5, 0($t3)
addi $t3, $t4, 28488
sw $t5, 0($t3)
addi $t3, $t4, 28492
sw $t5, 0($t3)
addi $t3, $t4, 28496
sw $t5, 0($t3)
addi $t3, $t4, 28500
sw $t5, 0($t3)
addi $t3, $t4, 28504
sw $t5, 0($t3)
addi $t3, $t4, 28508
sw $t5, 0($t3)
addi $t3, $t4, 28512
sw $t5, 0($t3)
addi $t3, $t4, 28516
sw $t5, 0($t3)
addi $t3, $t4, 28520
sw $t5, 0($t3)
addi $t3, $t4, 28524
sw $t5, 0($t3)
addi $t3, $t4, 28528
sw $t5, 0($t3)
addi $t3, $t4, 28532
sw $t5, 0($t3)
addi $t3, $t4, 28536
sw $t5, 0($t3)
addi $t3, $t4, 28540
sw $t5, 0($t3)
addi $t3, $t4, 28544
sw $t5, 0($t3)
addi $t3, $t4, 28548
sw $t5, 0($t3)
addi $t3, $t4, 28552
sw $t5, 0($t3)
addi $t3, $t4, 28556
sw $t5, 0($t3)
addi $t3, $t4, 28560
sw $t5, 0($t3)
addi $t3, $t4, 28564
sw $t5, 0($t3)
addi $t3, $t4, 28568
sw $t5, 0($t3)
addi $t3, $t4, 28572
sw $t5, 0($t3)
addi $t3, $t4, 28576
sw $t5, 0($t3)
addi $t3, $t4, 28580
sw $t5, 0($t3)
addi $t3, $t4, 28584
sw $t5, 0($t3)
addi $t3, $t4, 28588
sw $t5, 0($t3)
addi $t3, $t4, 28592
sw $t5, 0($t3)
addi $t3, $t4, 28596
sw $t5, 0($t3)
addi $t3, $t4, 28600
sw $t5, 0($t3)
addi $t3, $t4, 28604
sw $t5, 0($t3)
addi $t3, $t4, 28608
sw $t5, 0($t3)
addi $t3, $t4, 28612
sw $t5, 0($t3)
addi $t3, $t4, 28616
sw $t5, 0($t3)
addi $t3, $t4, 28620
sw $t5, 0($t3)
addi $t3, $t4, 28624
sw $t5, 0($t3)
addi $t3, $t4, 28628
sw $t5, 0($t3)
addi $t3, $t4, 28632
sw $t5, 0($t3)
addi $t3, $t4, 28636
sw $t5, 0($t3)
addi $t3, $t4, 28640
sw $t5, 0($t3)
addi $t3, $t4, 28644
sw $t5, 0($t3)
addi $t3, $t4, 28648
sw $t5, 0($t3)
addi $t3, $t4, 28652
sw $t5, 0($t3)
addi $t3, $t4, 28656
sw $t5, 0($t3)
addi $t3, $t4, 28660
sw $t5, 0($t3)
addi $t3, $t4, 28664
sw $t5, 0($t3)
addi $t3, $t4, 28668
sw $t5, 0($t3)
addi $t3, $t4, 28672
sw $t5, 0($t3)
addi $t3, $t4, 28676
sw $t5, 0($t3)
addi $t3, $t4, 28680
sw $t5, 0($t3)
addi $t3, $t4, 28684
sw $t5, 0($t3)
addi $t3, $t4, 28688
sw $t5, 0($t3)
addi $t3, $t4, 28692
sw $t5, 0($t3)
addi $t3, $t4, 28696
li $t5,0x969696
sw $t5, 0($t3)
addi $t3, $t4, 28700
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 28704
sw $t5, 0($t3)
addi $t3, $t4, 28708
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 28712
li $t5,0x040404
sw $t5, 0($t3)
addi $t3, $t4, 28716
sw $t5, 0($t3)
addi $t3, $t4, 28720
li $t5,0x6c6c6c
sw $t5, 0($t3)
addi $t3, $t4, 28724
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 28728
sw $t5, 0($t3)
addi $t3, $t4, 28732
sw $t5, 0($t3)
addi $t3, $t4, 28736
sw $t5, 0($t3)
addi $t3, $t4, 28740
sw $t5, 0($t3)
addi $t3, $t4, 28744
sw $t5, 0($t3)
addi $t3, $t4, 28748
sw $t5, 0($t3)
addi $t3, $t4, 28752
sw $t5, 0($t3)
addi $t3, $t4, 28756
sw $t5, 0($t3)
addi $t3, $t4, 28760
sw $t5, 0($t3)
addi $t3, $t4, 28764
sw $t5, 0($t3)
addi $t3, $t4, 28768
sw $t5, 0($t3)
addi $t3, $t4, 28772
sw $t5, 0($t3)
addi $t3, $t4, 28776
sw $t5, 0($t3)
addi $t3, $t4, 28780
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 28784
li $t5,0xfbfbfb
sw $t5, 0($t3)
addi $t3, $t4, 28788
li $t5,0xfdfdfd
sw $t5, 0($t3)
addi $t3, $t4, 28792
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 28796
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 28800
sw $t5, 0($t3)
addi $t3, $t4, 28804
sw $t5, 0($t3)
addi $t3, $t4, 28808
sw $t5, 0($t3)
addi $t3, $t4, 28812
sw $t5, 0($t3)
addi $t3, $t4, 28816
sw $t5, 0($t3)
addi $t3, $t4, 28820
sw $t5, 0($t3)
addi $t3, $t4, 28824
sw $t5, 0($t3)
addi $t3, $t4, 28828
sw $t5, 0($t3)
addi $t3, $t4, 28832
sw $t5, 0($t3)
addi $t3, $t4, 28836
sw $t5, 0($t3)
addi $t3, $t4, 28840
sw $t5, 0($t3)
addi $t3, $t4, 28844
sw $t5, 0($t3)
addi $t3, $t4, 28848
sw $t5, 0($t3)
addi $t3, $t4, 28852
sw $t5, 0($t3)
addi $t3, $t4, 28856
sw $t5, 0($t3)
addi $t3, $t4, 28860
sw $t5, 0($t3)
addi $t3, $t4, 28864
sw $t5, 0($t3)
addi $t3, $t4, 28868
sw $t5, 0($t3)
addi $t3, $t4, 28872
sw $t5, 0($t3)
addi $t3, $t4, 28876
sw $t5, 0($t3)
addi $t3, $t4, 28880
sw $t5, 0($t3)
addi $t3, $t4, 28884
sw $t5, 0($t3)
addi $t3, $t4, 28888
sw $t5, 0($t3)
addi $t3, $t4, 28892
sw $t5, 0($t3)
addi $t3, $t4, 28896
sw $t5, 0($t3)
addi $t3, $t4, 28900
sw $t5, 0($t3)
addi $t3, $t4, 28904
sw $t5, 0($t3)
addi $t3, $t4, 28908
sw $t5, 0($t3)
addi $t3, $t4, 28912
sw $t5, 0($t3)
addi $t3, $t4, 28916
sw $t5, 0($t3)
addi $t3, $t4, 28920
sw $t5, 0($t3)
addi $t3, $t4, 28924
sw $t5, 0($t3)
addi $t3, $t4, 28928
sw $t5, 0($t3)
addi $t3, $t4, 28932
sw $t5, 0($t3)
addi $t3, $t4, 28936
sw $t5, 0($t3)
addi $t3, $t4, 28940
sw $t5, 0($t3)
addi $t3, $t4, 28944
sw $t5, 0($t3)
addi $t3, $t4, 28948
sw $t5, 0($t3)
addi $t3, $t4, 28952
sw $t5, 0($t3)
addi $t3, $t4, 28956
sw $t5, 0($t3)
addi $t3, $t4, 28960
sw $t5, 0($t3)
addi $t3, $t4, 28964
sw $t5, 0($t3)
addi $t3, $t4, 28968
sw $t5, 0($t3)
addi $t3, $t4, 28972
sw $t5, 0($t3)
addi $t3, $t4, 28976
sw $t5, 0($t3)
addi $t3, $t4, 28980
sw $t5, 0($t3)
addi $t3, $t4, 28984
sw $t5, 0($t3)
addi $t3, $t4, 28988
sw $t5, 0($t3)
addi $t3, $t4, 28992
sw $t5, 0($t3)
addi $t3, $t4, 28996
sw $t5, 0($t3)
addi $t3, $t4, 29000
sw $t5, 0($t3)
addi $t3, $t4, 29004
sw $t5, 0($t3)
addi $t3, $t4, 29008
sw $t5, 0($t3)
addi $t3, $t4, 29012
sw $t5, 0($t3)
addi $t3, $t4, 29016
sw $t5, 0($t3)
addi $t3, $t4, 29020
sw $t5, 0($t3)
addi $t3, $t4, 29024
sw $t5, 0($t3)
addi $t3, $t4, 29028
sw $t5, 0($t3)
addi $t3, $t4, 29032
sw $t5, 0($t3)
addi $t3, $t4, 29036
sw $t5, 0($t3)
addi $t3, $t4, 29040
sw $t5, 0($t3)
addi $t3, $t4, 29044
sw $t5, 0($t3)
addi $t3, $t4, 29048
sw $t5, 0($t3)
addi $t3, $t4, 29052
sw $t5, 0($t3)
addi $t3, $t4, 29056
sw $t5, 0($t3)
addi $t3, $t4, 29060
sw $t5, 0($t3)
addi $t3, $t4, 29064
sw $t5, 0($t3)
addi $t3, $t4, 29068
sw $t5, 0($t3)
addi $t3, $t4, 29072
sw $t5, 0($t3)
addi $t3, $t4, 29076
sw $t5, 0($t3)
addi $t3, $t4, 29080
sw $t5, 0($t3)
addi $t3, $t4, 29084
sw $t5, 0($t3)
addi $t3, $t4, 29088
sw $t5, 0($t3)
addi $t3, $t4, 29092
sw $t5, 0($t3)
addi $t3, $t4, 29096
sw $t5, 0($t3)
addi $t3, $t4, 29100
sw $t5, 0($t3)
addi $t3, $t4, 29104
sw $t5, 0($t3)
addi $t3, $t4, 29108
sw $t5, 0($t3)
addi $t3, $t4, 29112
sw $t5, 0($t3)
addi $t3, $t4, 29116
sw $t5, 0($t3)
addi $t3, $t4, 29120
sw $t5, 0($t3)
addi $t3, $t4, 29124
sw $t5, 0($t3)
addi $t3, $t4, 29128
sw $t5, 0($t3)
addi $t3, $t4, 29132
sw $t5, 0($t3)
addi $t3, $t4, 29136
sw $t5, 0($t3)
addi $t3, $t4, 29140
sw $t5, 0($t3)
addi $t3, $t4, 29144
sw $t5, 0($t3)
addi $t3, $t4, 29148
sw $t5, 0($t3)
addi $t3, $t4, 29152
sw $t5, 0($t3)
addi $t3, $t4, 29156
sw $t5, 0($t3)
addi $t3, $t4, 29160
sw $t5, 0($t3)
addi $t3, $t4, 29164
sw $t5, 0($t3)
addi $t3, $t4, 29168
sw $t5, 0($t3)
addi $t3, $t4, 29172
sw $t5, 0($t3)
addi $t3, $t4, 29176
sw $t5, 0($t3)
addi $t3, $t4, 29180
sw $t5, 0($t3)
addi $t3, $t4, 29184
sw $t5, 0($t3)
addi $t3, $t4, 29188
sw $t5, 0($t3)
addi $t3, $t4, 29192
sw $t5, 0($t3)
addi $t3, $t4, 29196
sw $t5, 0($t3)
addi $t3, $t4, 29200
sw $t5, 0($t3)
addi $t3, $t4, 29204
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 29208
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 29212
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 29216
sw $t5, 0($t3)
addi $t3, $t4, 29220
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 29224
li $t5,0x818181
sw $t5, 0($t3)
addi $t3, $t4, 29228
li $t5,0x414141
sw $t5, 0($t3)
addi $t3, $t4, 29232
li $t5,0xbdbdbd
sw $t5, 0($t3)
addi $t3, $t4, 29236
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 29240
sw $t5, 0($t3)
addi $t3, $t4, 29244
sw $t5, 0($t3)
addi $t3, $t4, 29248
sw $t5, 0($t3)
addi $t3, $t4, 29252
sw $t5, 0($t3)
addi $t3, $t4, 29256
sw $t5, 0($t3)
addi $t3, $t4, 29260
sw $t5, 0($t3)
addi $t3, $t4, 29264
sw $t5, 0($t3)
addi $t3, $t4, 29268
sw $t5, 0($t3)
addi $t3, $t4, 29272
sw $t5, 0($t3)
addi $t3, $t4, 29276
sw $t5, 0($t3)
addi $t3, $t4, 29280
sw $t5, 0($t3)
addi $t3, $t4, 29284
sw $t5, 0($t3)
addi $t3, $t4, 29288
sw $t5, 0($t3)
addi $t3, $t4, 29292
sw $t5, 0($t3)
addi $t3, $t4, 29296
sw $t5, 0($t3)
addi $t3, $t4, 29300
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 29304
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 29308
sw $t5, 0($t3)
addi $t3, $t4, 29312
sw $t5, 0($t3)
addi $t3, $t4, 29316
sw $t5, 0($t3)
addi $t3, $t4, 29320
sw $t5, 0($t3)
addi $t3, $t4, 29324
sw $t5, 0($t3)
addi $t3, $t4, 29328
sw $t5, 0($t3)
addi $t3, $t4, 29332
sw $t5, 0($t3)
addi $t3, $t4, 29336
sw $t5, 0($t3)
addi $t3, $t4, 29340
sw $t5, 0($t3)
addi $t3, $t4, 29344
sw $t5, 0($t3)
addi $t3, $t4, 29348
sw $t5, 0($t3)
addi $t3, $t4, 29352
sw $t5, 0($t3)
addi $t3, $t4, 29356
sw $t5, 0($t3)
addi $t3, $t4, 29360
sw $t5, 0($t3)
addi $t3, $t4, 29364
sw $t5, 0($t3)
addi $t3, $t4, 29368
sw $t5, 0($t3)
addi $t3, $t4, 29372
sw $t5, 0($t3)
addi $t3, $t4, 29376
sw $t5, 0($t3)
addi $t3, $t4, 29380
sw $t5, 0($t3)
addi $t3, $t4, 29384
sw $t5, 0($t3)
addi $t3, $t4, 29388
sw $t5, 0($t3)
addi $t3, $t4, 29392
sw $t5, 0($t3)
addi $t3, $t4, 29396
sw $t5, 0($t3)
addi $t3, $t4, 29400
sw $t5, 0($t3)
addi $t3, $t4, 29404
sw $t5, 0($t3)
addi $t3, $t4, 29408
sw $t5, 0($t3)
addi $t3, $t4, 29412
sw $t5, 0($t3)
addi $t3, $t4, 29416
sw $t5, 0($t3)
addi $t3, $t4, 29420
sw $t5, 0($t3)
addi $t3, $t4, 29424
sw $t5, 0($t3)
addi $t3, $t4, 29428
sw $t5, 0($t3)
addi $t3, $t4, 29432
sw $t5, 0($t3)
addi $t3, $t4, 29436
sw $t5, 0($t3)
addi $t3, $t4, 29440
sw $t5, 0($t3)
addi $t3, $t4, 29444
sw $t5, 0($t3)
addi $t3, $t4, 29448
sw $t5, 0($t3)
addi $t3, $t4, 29452
sw $t5, 0($t3)
addi $t3, $t4, 29456
sw $t5, 0($t3)
addi $t3, $t4, 29460
sw $t5, 0($t3)
addi $t3, $t4, 29464
sw $t5, 0($t3)
addi $t3, $t4, 29468
sw $t5, 0($t3)
addi $t3, $t4, 29472
sw $t5, 0($t3)
addi $t3, $t4, 29476
sw $t5, 0($t3)
addi $t3, $t4, 29480
sw $t5, 0($t3)
addi $t3, $t4, 29484
sw $t5, 0($t3)
addi $t3, $t4, 29488
sw $t5, 0($t3)
addi $t3, $t4, 29492
sw $t5, 0($t3)
addi $t3, $t4, 29496
sw $t5, 0($t3)
addi $t3, $t4, 29500
sw $t5, 0($t3)
addi $t3, $t4, 29504
sw $t5, 0($t3)
addi $t3, $t4, 29508
sw $t5, 0($t3)
addi $t3, $t4, 29512
sw $t5, 0($t3)
addi $t3, $t4, 29516
sw $t5, 0($t3)
addi $t3, $t4, 29520
sw $t5, 0($t3)
addi $t3, $t4, 29524
sw $t5, 0($t3)
addi $t3, $t4, 29528
sw $t5, 0($t3)
addi $t3, $t4, 29532
sw $t5, 0($t3)
addi $t3, $t4, 29536
sw $t5, 0($t3)
addi $t3, $t4, 29540
sw $t5, 0($t3)
addi $t3, $t4, 29544
sw $t5, 0($t3)
addi $t3, $t4, 29548
sw $t5, 0($t3)
addi $t3, $t4, 29552
sw $t5, 0($t3)
addi $t3, $t4, 29556
sw $t5, 0($t3)
addi $t3, $t4, 29560
sw $t5, 0($t3)
addi $t3, $t4, 29564
sw $t5, 0($t3)
addi $t3, $t4, 29568
sw $t5, 0($t3)
addi $t3, $t4, 29572
sw $t5, 0($t3)
addi $t3, $t4, 29576
sw $t5, 0($t3)
addi $t3, $t4, 29580
sw $t5, 0($t3)
addi $t3, $t4, 29584
sw $t5, 0($t3)
addi $t3, $t4, 29588
sw $t5, 0($t3)
addi $t3, $t4, 29592
sw $t5, 0($t3)
addi $t3, $t4, 29596
sw $t5, 0($t3)
addi $t3, $t4, 29600
sw $t5, 0($t3)
addi $t3, $t4, 29604
sw $t5, 0($t3)
addi $t3, $t4, 29608
sw $t5, 0($t3)
addi $t3, $t4, 29612
sw $t5, 0($t3)
addi $t3, $t4, 29616
sw $t5, 0($t3)
addi $t3, $t4, 29620
sw $t5, 0($t3)
addi $t3, $t4, 29624
sw $t5, 0($t3)
addi $t3, $t4, 29628
sw $t5, 0($t3)
addi $t3, $t4, 29632
sw $t5, 0($t3)
addi $t3, $t4, 29636
sw $t5, 0($t3)
addi $t3, $t4, 29640
sw $t5, 0($t3)
addi $t3, $t4, 29644
sw $t5, 0($t3)
addi $t3, $t4, 29648
sw $t5, 0($t3)
addi $t3, $t4, 29652
sw $t5, 0($t3)
addi $t3, $t4, 29656
sw $t5, 0($t3)
addi $t3, $t4, 29660
sw $t5, 0($t3)
addi $t3, $t4, 29664
sw $t5, 0($t3)
addi $t3, $t4, 29668
sw $t5, 0($t3)
addi $t3, $t4, 29672
sw $t5, 0($t3)
addi $t3, $t4, 29676
sw $t5, 0($t3)
addi $t3, $t4, 29680
sw $t5, 0($t3)
addi $t3, $t4, 29684
sw $t5, 0($t3)
addi $t3, $t4, 29688
sw $t5, 0($t3)
addi $t3, $t4, 29692
sw $t5, 0($t3)
addi $t3, $t4, 29696
sw $t5, 0($t3)
addi $t3, $t4, 29700
sw $t5, 0($t3)
addi $t3, $t4, 29704
sw $t5, 0($t3)
addi $t3, $t4, 29708
sw $t5, 0($t3)
addi $t3, $t4, 29712
sw $t5, 0($t3)
addi $t3, $t4, 29716
li $t5,0xd9d9d9
sw $t5, 0($t3)
addi $t3, $t4, 29720
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 29724
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 29728
sw $t5, 0($t3)
addi $t3, $t4, 29732
li $t5,0x010101
sw $t5, 0($t3)
addi $t3, $t4, 29736
li $t5,0x424242
sw $t5, 0($t3)
addi $t3, $t4, 29740
li $t5,0x8e8e8e
sw $t5, 0($t3)
addi $t3, $t4, 29744
li $t5,0xfcfcfc
sw $t5, 0($t3)
addi $t3, $t4, 29748
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 29752
sw $t5, 0($t3)
addi $t3, $t4, 29756
sw $t5, 0($t3)
addi $t3, $t4, 29760
sw $t5, 0($t3)
addi $t3, $t4, 29764
sw $t5, 0($t3)
addi $t3, $t4, 29768
sw $t5, 0($t3)
addi $t3, $t4, 29772
sw $t5, 0($t3)
addi $t3, $t4, 29776
sw $t5, 0($t3)
addi $t3, $t4, 29780
sw $t5, 0($t3)
addi $t3, $t4, 29784
sw $t5, 0($t3)
addi $t3, $t4, 29788
sw $t5, 0($t3)
addi $t3, $t4, 29792
sw $t5, 0($t3)
addi $t3, $t4, 29796
sw $t5, 0($t3)
addi $t3, $t4, 29800
sw $t5, 0($t3)
addi $t3, $t4, 29804
sw $t5, 0($t3)
addi $t3, $t4, 29808
sw $t5, 0($t3)
addi $t3, $t4, 29812
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 29816
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 29820
sw $t5, 0($t3)
addi $t3, $t4, 29824
sw $t5, 0($t3)
addi $t3, $t4, 29828
sw $t5, 0($t3)
addi $t3, $t4, 29832
sw $t5, 0($t3)
addi $t3, $t4, 29836
sw $t5, 0($t3)
addi $t3, $t4, 29840
sw $t5, 0($t3)
addi $t3, $t4, 29844
sw $t5, 0($t3)
addi $t3, $t4, 29848
sw $t5, 0($t3)
addi $t3, $t4, 29852
sw $t5, 0($t3)
addi $t3, $t4, 29856
sw $t5, 0($t3)
addi $t3, $t4, 29860
sw $t5, 0($t3)
addi $t3, $t4, 29864
sw $t5, 0($t3)
addi $t3, $t4, 29868
sw $t5, 0($t3)
addi $t3, $t4, 29872
sw $t5, 0($t3)
addi $t3, $t4, 29876
sw $t5, 0($t3)
addi $t3, $t4, 29880
sw $t5, 0($t3)
addi $t3, $t4, 29884
sw $t5, 0($t3)
addi $t3, $t4, 29888
sw $t5, 0($t3)
addi $t3, $t4, 29892
sw $t5, 0($t3)
addi $t3, $t4, 29896
sw $t5, 0($t3)
addi $t3, $t4, 29900
sw $t5, 0($t3)
addi $t3, $t4, 29904
sw $t5, 0($t3)
addi $t3, $t4, 29908
sw $t5, 0($t3)
addi $t3, $t4, 29912
sw $t5, 0($t3)
addi $t3, $t4, 29916
sw $t5, 0($t3)
addi $t3, $t4, 29920
sw $t5, 0($t3)
addi $t3, $t4, 29924
sw $t5, 0($t3)
addi $t3, $t4, 29928
sw $t5, 0($t3)
addi $t3, $t4, 29932
sw $t5, 0($t3)
addi $t3, $t4, 29936
sw $t5, 0($t3)
addi $t3, $t4, 29940
sw $t5, 0($t3)
addi $t3, $t4, 29944
sw $t5, 0($t3)
addi $t3, $t4, 29948
sw $t5, 0($t3)
addi $t3, $t4, 29952
sw $t5, 0($t3)
addi $t3, $t4, 29956
sw $t5, 0($t3)
addi $t3, $t4, 29960
sw $t5, 0($t3)
addi $t3, $t4, 29964
sw $t5, 0($t3)
addi $t3, $t4, 29968
sw $t5, 0($t3)
addi $t3, $t4, 29972
sw $t5, 0($t3)
addi $t3, $t4, 29976
sw $t5, 0($t3)
addi $t3, $t4, 29980
sw $t5, 0($t3)
addi $t3, $t4, 29984
sw $t5, 0($t3)
addi $t3, $t4, 29988
sw $t5, 0($t3)
addi $t3, $t4, 29992
sw $t5, 0($t3)
addi $t3, $t4, 29996
sw $t5, 0($t3)
addi $t3, $t4, 30000
sw $t5, 0($t3)
addi $t3, $t4, 30004
sw $t5, 0($t3)
addi $t3, $t4, 30008
sw $t5, 0($t3)
addi $t3, $t4, 30012
sw $t5, 0($t3)
addi $t3, $t4, 30016
sw $t5, 0($t3)
addi $t3, $t4, 30020
sw $t5, 0($t3)
addi $t3, $t4, 30024
sw $t5, 0($t3)
addi $t3, $t4, 30028
sw $t5, 0($t3)
addi $t3, $t4, 30032
sw $t5, 0($t3)
addi $t3, $t4, 30036
sw $t5, 0($t3)
addi $t3, $t4, 30040
sw $t5, 0($t3)
addi $t3, $t4, 30044
sw $t5, 0($t3)
addi $t3, $t4, 30048
sw $t5, 0($t3)
addi $t3, $t4, 30052
sw $t5, 0($t3)
addi $t3, $t4, 30056
sw $t5, 0($t3)
addi $t3, $t4, 30060
sw $t5, 0($t3)
addi $t3, $t4, 30064
sw $t5, 0($t3)
addi $t3, $t4, 30068
sw $t5, 0($t3)
addi $t3, $t4, 30072
sw $t5, 0($t3)
addi $t3, $t4, 30076
sw $t5, 0($t3)
addi $t3, $t4, 30080
sw $t5, 0($t3)
addi $t3, $t4, 30084
sw $t5, 0($t3)
addi $t3, $t4, 30088
sw $t5, 0($t3)
addi $t3, $t4, 30092
sw $t5, 0($t3)
addi $t3, $t4, 30096
sw $t5, 0($t3)
addi $t3, $t4, 30100
sw $t5, 0($t3)
addi $t3, $t4, 30104
sw $t5, 0($t3)
addi $t3, $t4, 30108
sw $t5, 0($t3)
addi $t3, $t4, 30112
sw $t5, 0($t3)
addi $t3, $t4, 30116
sw $t5, 0($t3)
addi $t3, $t4, 30120
sw $t5, 0($t3)
addi $t3, $t4, 30124
sw $t5, 0($t3)
addi $t3, $t4, 30128
sw $t5, 0($t3)
addi $t3, $t4, 30132
sw $t5, 0($t3)
addi $t3, $t4, 30136
sw $t5, 0($t3)
addi $t3, $t4, 30140
sw $t5, 0($t3)
addi $t3, $t4, 30144
sw $t5, 0($t3)
addi $t3, $t4, 30148
sw $t5, 0($t3)
addi $t3, $t4, 30152
sw $t5, 0($t3)
addi $t3, $t4, 30156
sw $t5, 0($t3)
addi $t3, $t4, 30160
sw $t5, 0($t3)
addi $t3, $t4, 30164
sw $t5, 0($t3)
addi $t3, $t4, 30168
sw $t5, 0($t3)
addi $t3, $t4, 30172
sw $t5, 0($t3)
addi $t3, $t4, 30176
sw $t5, 0($t3)
addi $t3, $t4, 30180
sw $t5, 0($t3)
addi $t3, $t4, 30184
sw $t5, 0($t3)
addi $t3, $t4, 30188
sw $t5, 0($t3)
addi $t3, $t4, 30192
sw $t5, 0($t3)
addi $t3, $t4, 30196
sw $t5, 0($t3)
addi $t3, $t4, 30200
sw $t5, 0($t3)
addi $t3, $t4, 30204
sw $t5, 0($t3)
addi $t3, $t4, 30208
sw $t5, 0($t3)
addi $t3, $t4, 30212
sw $t5, 0($t3)
addi $t3, $t4, 30216
sw $t5, 0($t3)
addi $t3, $t4, 30220
sw $t5, 0($t3)
addi $t3, $t4, 30224
sw $t5, 0($t3)
addi $t3, $t4, 30228
li $t5,0xe5e5e5
sw $t5, 0($t3)
addi $t3, $t4, 30232
li $t5,0x373737
sw $t5, 0($t3)
addi $t3, $t4, 30236
li $t5,0x040404
sw $t5, 0($t3)
addi $t3, $t4, 30240
li $t5,0x000000
sw $t5, 0($t3)
addi $t3, $t4, 30244
li $t5,0x808080
sw $t5, 0($t3)
addi $t3, $t4, 30248
li $t5,0x363636
sw $t5, 0($t3)
addi $t3, $t4, 30252
li $t5,0xd9d9d9
sw $t5, 0($t3)
addi $t3, $t4, 30256
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 30260
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 30264
sw $t5, 0($t3)
addi $t3, $t4, 30268
sw $t5, 0($t3)
addi $t3, $t4, 30272
sw $t5, 0($t3)
addi $t3, $t4, 30276
sw $t5, 0($t3)
addi $t3, $t4, 30280
sw $t5, 0($t3)
addi $t3, $t4, 30284
sw $t5, 0($t3)
addi $t3, $t4, 30288
sw $t5, 0($t3)
addi $t3, $t4, 30292
sw $t5, 0($t3)
addi $t3, $t4, 30296
sw $t5, 0($t3)
addi $t3, $t4, 30300
sw $t5, 0($t3)
addi $t3, $t4, 30304
sw $t5, 0($t3)
addi $t3, $t4, 30308
sw $t5, 0($t3)
addi $t3, $t4, 30312
sw $t5, 0($t3)
addi $t3, $t4, 30316
sw $t5, 0($t3)
addi $t3, $t4, 30320
sw $t5, 0($t3)
addi $t3, $t4, 30324
sw $t5, 0($t3)
addi $t3, $t4, 30328
sw $t5, 0($t3)
addi $t3, $t4, 30332
sw $t5, 0($t3)
addi $t3, $t4, 30336
sw $t5, 0($t3)
addi $t3, $t4, 30340
sw $t5, 0($t3)
addi $t3, $t4, 30344
sw $t5, 0($t3)
addi $t3, $t4, 30348
sw $t5, 0($t3)
addi $t3, $t4, 30352
sw $t5, 0($t3)
addi $t3, $t4, 30356
sw $t5, 0($t3)
addi $t3, $t4, 30360
sw $t5, 0($t3)
addi $t3, $t4, 30364
sw $t5, 0($t3)
addi $t3, $t4, 30368
sw $t5, 0($t3)
addi $t3, $t4, 30372
sw $t5, 0($t3)
addi $t3, $t4, 30376
sw $t5, 0($t3)
addi $t3, $t4, 30380
sw $t5, 0($t3)
addi $t3, $t4, 30384
sw $t5, 0($t3)
addi $t3, $t4, 30388
sw $t5, 0($t3)
addi $t3, $t4, 30392
sw $t5, 0($t3)
addi $t3, $t4, 30396
sw $t5, 0($t3)
addi $t3, $t4, 30400
sw $t5, 0($t3)
addi $t3, $t4, 30404
sw $t5, 0($t3)
addi $t3, $t4, 30408
sw $t5, 0($t3)
addi $t3, $t4, 30412
sw $t5, 0($t3)
addi $t3, $t4, 30416
sw $t5, 0($t3)
addi $t3, $t4, 30420
sw $t5, 0($t3)
addi $t3, $t4, 30424
sw $t5, 0($t3)
addi $t3, $t4, 30428
sw $t5, 0($t3)
addi $t3, $t4, 30432
sw $t5, 0($t3)
addi $t3, $t4, 30436
sw $t5, 0($t3)
addi $t3, $t4, 30440
sw $t5, 0($t3)
addi $t3, $t4, 30444
sw $t5, 0($t3)
addi $t3, $t4, 30448
sw $t5, 0($t3)
addi $t3, $t4, 30452
sw $t5, 0($t3)
addi $t3, $t4, 30456
sw $t5, 0($t3)
addi $t3, $t4, 30460
sw $t5, 0($t3)
addi $t3, $t4, 30464
sw $t5, 0($t3)
addi $t3, $t4, 30468
sw $t5, 0($t3)
addi $t3, $t4, 30472
sw $t5, 0($t3)
addi $t3, $t4, 30476
sw $t5, 0($t3)
addi $t3, $t4, 30480
sw $t5, 0($t3)
addi $t3, $t4, 30484
sw $t5, 0($t3)
addi $t3, $t4, 30488
sw $t5, 0($t3)
addi $t3, $t4, 30492
sw $t5, 0($t3)
addi $t3, $t4, 30496
sw $t5, 0($t3)
addi $t3, $t4, 30500
sw $t5, 0($t3)
addi $t3, $t4, 30504
sw $t5, 0($t3)
addi $t3, $t4, 30508
sw $t5, 0($t3)
addi $t3, $t4, 30512
sw $t5, 0($t3)
addi $t3, $t4, 30516
sw $t5, 0($t3)
addi $t3, $t4, 30520
sw $t5, 0($t3)
addi $t3, $t4, 30524
sw $t5, 0($t3)
addi $t3, $t4, 30528
sw $t5, 0($t3)
addi $t3, $t4, 30532
sw $t5, 0($t3)
addi $t3, $t4, 30536
sw $t5, 0($t3)
addi $t3, $t4, 30540
sw $t5, 0($t3)
addi $t3, $t4, 30544
sw $t5, 0($t3)
addi $t3, $t4, 30548
sw $t5, 0($t3)
addi $t3, $t4, 30552
sw $t5, 0($t3)
addi $t3, $t4, 30556
sw $t5, 0($t3)
addi $t3, $t4, 30560
sw $t5, 0($t3)
addi $t3, $t4, 30564
sw $t5, 0($t3)
addi $t3, $t4, 30568
sw $t5, 0($t3)
addi $t3, $t4, 30572
sw $t5, 0($t3)
addi $t3, $t4, 30576
sw $t5, 0($t3)
addi $t3, $t4, 30580
sw $t5, 0($t3)
addi $t3, $t4, 30584
sw $t5, 0($t3)
addi $t3, $t4, 30588
sw $t5, 0($t3)
addi $t3, $t4, 30592
sw $t5, 0($t3)
addi $t3, $t4, 30596
sw $t5, 0($t3)
addi $t3, $t4, 30600
sw $t5, 0($t3)
addi $t3, $t4, 30604
sw $t5, 0($t3)
addi $t3, $t4, 30608
sw $t5, 0($t3)
addi $t3, $t4, 30612
sw $t5, 0($t3)
addi $t3, $t4, 30616
sw $t5, 0($t3)
addi $t3, $t4, 30620
sw $t5, 0($t3)
addi $t3, $t4, 30624
sw $t5, 0($t3)
addi $t3, $t4, 30628
sw $t5, 0($t3)
addi $t3, $t4, 30632
sw $t5, 0($t3)
addi $t3, $t4, 30636
sw $t5, 0($t3)
addi $t3, $t4, 30640
sw $t5, 0($t3)
addi $t3, $t4, 30644
sw $t5, 0($t3)
addi $t3, $t4, 30648
sw $t5, 0($t3)
addi $t3, $t4, 30652
sw $t5, 0($t3)
addi $t3, $t4, 30656
sw $t5, 0($t3)
addi $t3, $t4, 30660
sw $t5, 0($t3)
addi $t3, $t4, 30664
sw $t5, 0($t3)
addi $t3, $t4, 30668
sw $t5, 0($t3)
addi $t3, $t4, 30672
sw $t5, 0($t3)
addi $t3, $t4, 30676
sw $t5, 0($t3)
addi $t3, $t4, 30680
sw $t5, 0($t3)
addi $t3, $t4, 30684
sw $t5, 0($t3)
addi $t3, $t4, 30688
sw $t5, 0($t3)
addi $t3, $t4, 30692
sw $t5, 0($t3)
addi $t3, $t4, 30696
sw $t5, 0($t3)
addi $t3, $t4, 30700
sw $t5, 0($t3)
addi $t3, $t4, 30704
sw $t5, 0($t3)
addi $t3, $t4, 30708
sw $t5, 0($t3)
addi $t3, $t4, 30712
sw $t5, 0($t3)
addi $t3, $t4, 30716
sw $t5, 0($t3)
addi $t3, $t4, 30720
sw $t5, 0($t3)
addi $t3, $t4, 30724
sw $t5, 0($t3)
addi $t3, $t4, 30728
sw $t5, 0($t3)
addi $t3, $t4, 30732
sw $t5, 0($t3)
addi $t3, $t4, 30736
sw $t5, 0($t3)
addi $t3, $t4, 30740
sw $t5, 0($t3)
addi $t3, $t4, 30744
li $t5,0xf7f7f7
sw $t5, 0($t3)
addi $t3, $t4, 30748
li $t5,0x101010
sw $t5, 0($t3)
addi $t3, $t4, 30752
li $t5,0x030303
sw $t5, 0($t3)
addi $t3, $t4, 30756
li $t5,0x4e4e4e
sw $t5, 0($t3)
addi $t3, $t4, 30760
li $t5,0x818181
sw $t5, 0($t3)
addi $t3, $t4, 30764
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 30768
sw $t5, 0($t3)
addi $t3, $t4, 30772
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 30776
sw $t5, 0($t3)
addi $t3, $t4, 30780
sw $t5, 0($t3)
addi $t3, $t4, 30784
sw $t5, 0($t3)
addi $t3, $t4, 30788
sw $t5, 0($t3)
addi $t3, $t4, 30792
sw $t5, 0($t3)
addi $t3, $t4, 30796
sw $t5, 0($t3)
addi $t3, $t4, 30800
sw $t5, 0($t3)
addi $t3, $t4, 30804
sw $t5, 0($t3)
addi $t3, $t4, 30808
sw $t5, 0($t3)
addi $t3, $t4, 30812
sw $t5, 0($t3)
addi $t3, $t4, 30816
sw $t5, 0($t3)
addi $t3, $t4, 30820
sw $t5, 0($t3)
addi $t3, $t4, 30824
sw $t5, 0($t3)
addi $t3, $t4, 30828
sw $t5, 0($t3)
addi $t3, $t4, 30832
sw $t5, 0($t3)
addi $t3, $t4, 30836
sw $t5, 0($t3)
addi $t3, $t4, 30840
sw $t5, 0($t3)
addi $t3, $t4, 30844
sw $t5, 0($t3)
addi $t3, $t4, 30848
sw $t5, 0($t3)
addi $t3, $t4, 30852
sw $t5, 0($t3)
addi $t3, $t4, 30856
sw $t5, 0($t3)
addi $t3, $t4, 30860
sw $t5, 0($t3)
addi $t3, $t4, 30864
sw $t5, 0($t3)
addi $t3, $t4, 30868
sw $t5, 0($t3)
addi $t3, $t4, 30872
sw $t5, 0($t3)
addi $t3, $t4, 30876
sw $t5, 0($t3)
addi $t3, $t4, 30880
sw $t5, 0($t3)
addi $t3, $t4, 30884
sw $t5, 0($t3)
addi $t3, $t4, 30888
sw $t5, 0($t3)
addi $t3, $t4, 30892
sw $t5, 0($t3)
addi $t3, $t4, 30896
sw $t5, 0($t3)
addi $t3, $t4, 30900
sw $t5, 0($t3)
addi $t3, $t4, 30904
sw $t5, 0($t3)
addi $t3, $t4, 30908
sw $t5, 0($t3)
addi $t3, $t4, 30912
sw $t5, 0($t3)
addi $t3, $t4, 30916
sw $t5, 0($t3)
addi $t3, $t4, 30920
sw $t5, 0($t3)
addi $t3, $t4, 30924
sw $t5, 0($t3)
addi $t3, $t4, 30928
sw $t5, 0($t3)
addi $t3, $t4, 30932
sw $t5, 0($t3)
addi $t3, $t4, 30936
sw $t5, 0($t3)
addi $t3, $t4, 30940
sw $t5, 0($t3)
addi $t3, $t4, 30944
sw $t5, 0($t3)
addi $t3, $t4, 30948
sw $t5, 0($t3)
addi $t3, $t4, 30952
sw $t5, 0($t3)
addi $t3, $t4, 30956
sw $t5, 0($t3)
addi $t3, $t4, 30960
sw $t5, 0($t3)
addi $t3, $t4, 30964
sw $t5, 0($t3)
addi $t3, $t4, 30968
sw $t5, 0($t3)
addi $t3, $t4, 30972
sw $t5, 0($t3)
addi $t3, $t4, 30976
sw $t5, 0($t3)
addi $t3, $t4, 30980
sw $t5, 0($t3)
addi $t3, $t4, 30984
sw $t5, 0($t3)
addi $t3, $t4, 30988
sw $t5, 0($t3)
addi $t3, $t4, 30992
sw $t5, 0($t3)
addi $t3, $t4, 30996
sw $t5, 0($t3)
addi $t3, $t4, 31000
sw $t5, 0($t3)
addi $t3, $t4, 31004
sw $t5, 0($t3)
addi $t3, $t4, 31008
sw $t5, 0($t3)
addi $t3, $t4, 31012
sw $t5, 0($t3)
addi $t3, $t4, 31016
sw $t5, 0($t3)
addi $t3, $t4, 31020
sw $t5, 0($t3)
addi $t3, $t4, 31024
sw $t5, 0($t3)
addi $t3, $t4, 31028
sw $t5, 0($t3)
addi $t3, $t4, 31032
sw $t5, 0($t3)
addi $t3, $t4, 31036
sw $t5, 0($t3)
addi $t3, $t4, 31040
sw $t5, 0($t3)
addi $t3, $t4, 31044
sw $t5, 0($t3)
addi $t3, $t4, 31048
sw $t5, 0($t3)
addi $t3, $t4, 31052
sw $t5, 0($t3)
addi $t3, $t4, 31056
sw $t5, 0($t3)
addi $t3, $t4, 31060
sw $t5, 0($t3)
addi $t3, $t4, 31064
sw $t5, 0($t3)
addi $t3, $t4, 31068
sw $t5, 0($t3)
addi $t3, $t4, 31072
sw $t5, 0($t3)
addi $t3, $t4, 31076
sw $t5, 0($t3)
addi $t3, $t4, 31080
sw $t5, 0($t3)
addi $t3, $t4, 31084
sw $t5, 0($t3)
addi $t3, $t4, 31088
sw $t5, 0($t3)
addi $t3, $t4, 31092
sw $t5, 0($t3)
addi $t3, $t4, 31096
sw $t5, 0($t3)
addi $t3, $t4, 31100
sw $t5, 0($t3)
addi $t3, $t4, 31104
sw $t5, 0($t3)
addi $t3, $t4, 31108
sw $t5, 0($t3)
addi $t3, $t4, 31112
sw $t5, 0($t3)
addi $t3, $t4, 31116
sw $t5, 0($t3)
addi $t3, $t4, 31120
sw $t5, 0($t3)
addi $t3, $t4, 31124
sw $t5, 0($t3)
addi $t3, $t4, 31128
sw $t5, 0($t3)
addi $t3, $t4, 31132
sw $t5, 0($t3)
addi $t3, $t4, 31136
sw $t5, 0($t3)
addi $t3, $t4, 31140
sw $t5, 0($t3)
addi $t3, $t4, 31144
sw $t5, 0($t3)
addi $t3, $t4, 31148
sw $t5, 0($t3)
addi $t3, $t4, 31152
sw $t5, 0($t3)
addi $t3, $t4, 31156
sw $t5, 0($t3)
addi $t3, $t4, 31160
sw $t5, 0($t3)
addi $t3, $t4, 31164
sw $t5, 0($t3)
addi $t3, $t4, 31168
sw $t5, 0($t3)
addi $t3, $t4, 31172
sw $t5, 0($t3)
addi $t3, $t4, 31176
sw $t5, 0($t3)
addi $t3, $t4, 31180
sw $t5, 0($t3)
addi $t3, $t4, 31184
sw $t5, 0($t3)
addi $t3, $t4, 31188
sw $t5, 0($t3)
addi $t3, $t4, 31192
sw $t5, 0($t3)
addi $t3, $t4, 31196
sw $t5, 0($t3)
addi $t3, $t4, 31200
sw $t5, 0($t3)
addi $t3, $t4, 31204
sw $t5, 0($t3)
addi $t3, $t4, 31208
sw $t5, 0($t3)
addi $t3, $t4, 31212
sw $t5, 0($t3)
addi $t3, $t4, 31216
sw $t5, 0($t3)
addi $t3, $t4, 31220
sw $t5, 0($t3)
addi $t3, $t4, 31224
sw $t5, 0($t3)
addi $t3, $t4, 31228
sw $t5, 0($t3)
addi $t3, $t4, 31232
sw $t5, 0($t3)
addi $t3, $t4, 31236
sw $t5, 0($t3)
addi $t3, $t4, 31240
sw $t5, 0($t3)
addi $t3, $t4, 31244
sw $t5, 0($t3)
addi $t3, $t4, 31248
sw $t5, 0($t3)
addi $t3, $t4, 31252
sw $t5, 0($t3)
addi $t3, $t4, 31256
li $t5,0xfdfdfd
sw $t5, 0($t3)
addi $t3, $t4, 31260
li $t5,0x626262
sw $t5, 0($t3)
addi $t3, $t4, 31264
li $t5,0xcbcbcb
sw $t5, 0($t3)
addi $t3, $t4, 31268
li $t5,0x575757
sw $t5, 0($t3)
addi $t3, $t4, 31272
li $t5,0xf1f1f1
sw $t5, 0($t3)
addi $t3, $t4, 31276
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 31280
sw $t5, 0($t3)
addi $t3, $t4, 31284
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 31288
sw $t5, 0($t3)
addi $t3, $t4, 31292
sw $t5, 0($t3)
addi $t3, $t4, 31296
sw $t5, 0($t3)
addi $t3, $t4, 31300
sw $t5, 0($t3)
addi $t3, $t4, 31304
sw $t5, 0($t3)
addi $t3, $t4, 31308
sw $t5, 0($t3)
addi $t3, $t4, 31312
sw $t5, 0($t3)
addi $t3, $t4, 31316
sw $t5, 0($t3)
addi $t3, $t4, 31320
sw $t5, 0($t3)
addi $t3, $t4, 31324
sw $t5, 0($t3)
addi $t3, $t4, 31328
sw $t5, 0($t3)
addi $t3, $t4, 31332
sw $t5, 0($t3)
addi $t3, $t4, 31336
sw $t5, 0($t3)
addi $t3, $t4, 31340
sw $t5, 0($t3)
addi $t3, $t4, 31344
sw $t5, 0($t3)
addi $t3, $t4, 31348
sw $t5, 0($t3)
addi $t3, $t4, 31352
sw $t5, 0($t3)
addi $t3, $t4, 31356
sw $t5, 0($t3)
addi $t3, $t4, 31360
sw $t5, 0($t3)
addi $t3, $t4, 31364
sw $t5, 0($t3)
addi $t3, $t4, 31368
sw $t5, 0($t3)
addi $t3, $t4, 31372
sw $t5, 0($t3)
addi $t3, $t4, 31376
sw $t5, 0($t3)
addi $t3, $t4, 31380
sw $t5, 0($t3)
addi $t3, $t4, 31384
sw $t5, 0($t3)
addi $t3, $t4, 31388
sw $t5, 0($t3)
addi $t3, $t4, 31392
sw $t5, 0($t3)
addi $t3, $t4, 31396
sw $t5, 0($t3)
addi $t3, $t4, 31400
sw $t5, 0($t3)
addi $t3, $t4, 31404
sw $t5, 0($t3)
addi $t3, $t4, 31408
sw $t5, 0($t3)
addi $t3, $t4, 31412
sw $t5, 0($t3)
addi $t3, $t4, 31416
sw $t5, 0($t3)
addi $t3, $t4, 31420
sw $t5, 0($t3)
addi $t3, $t4, 31424
sw $t5, 0($t3)
addi $t3, $t4, 31428
sw $t5, 0($t3)
addi $t3, $t4, 31432
sw $t5, 0($t3)
addi $t3, $t4, 31436
sw $t5, 0($t3)
addi $t3, $t4, 31440
sw $t5, 0($t3)
addi $t3, $t4, 31444
sw $t5, 0($t3)
addi $t3, $t4, 31448
sw $t5, 0($t3)
addi $t3, $t4, 31452
sw $t5, 0($t3)
addi $t3, $t4, 31456
sw $t5, 0($t3)
addi $t3, $t4, 31460
sw $t5, 0($t3)
addi $t3, $t4, 31464
sw $t5, 0($t3)
addi $t3, $t4, 31468
sw $t5, 0($t3)
addi $t3, $t4, 31472
sw $t5, 0($t3)
addi $t3, $t4, 31476
sw $t5, 0($t3)
addi $t3, $t4, 31480
sw $t5, 0($t3)
addi $t3, $t4, 31484
sw $t5, 0($t3)
addi $t3, $t4, 31488
sw $t5, 0($t3)
addi $t3, $t4, 31492
sw $t5, 0($t3)
addi $t3, $t4, 31496
sw $t5, 0($t3)
addi $t3, $t4, 31500
sw $t5, 0($t3)
addi $t3, $t4, 31504
sw $t5, 0($t3)
addi $t3, $t4, 31508
sw $t5, 0($t3)
addi $t3, $t4, 31512
sw $t5, 0($t3)
addi $t3, $t4, 31516
sw $t5, 0($t3)
addi $t3, $t4, 31520
sw $t5, 0($t3)
addi $t3, $t4, 31524
sw $t5, 0($t3)
addi $t3, $t4, 31528
sw $t5, 0($t3)
addi $t3, $t4, 31532
sw $t5, 0($t3)
addi $t3, $t4, 31536
sw $t5, 0($t3)
addi $t3, $t4, 31540
sw $t5, 0($t3)
addi $t3, $t4, 31544
sw $t5, 0($t3)
addi $t3, $t4, 31548
sw $t5, 0($t3)
addi $t3, $t4, 31552
sw $t5, 0($t3)
addi $t3, $t4, 31556
sw $t5, 0($t3)
addi $t3, $t4, 31560
sw $t5, 0($t3)
addi $t3, $t4, 31564
sw $t5, 0($t3)
addi $t3, $t4, 31568
sw $t5, 0($t3)
addi $t3, $t4, 31572
sw $t5, 0($t3)
addi $t3, $t4, 31576
sw $t5, 0($t3)
addi $t3, $t4, 31580
sw $t5, 0($t3)
addi $t3, $t4, 31584
sw $t5, 0($t3)
addi $t3, $t4, 31588
sw $t5, 0($t3)
addi $t3, $t4, 31592
sw $t5, 0($t3)
addi $t3, $t4, 31596
sw $t5, 0($t3)
addi $t3, $t4, 31600
sw $t5, 0($t3)
addi $t3, $t4, 31604
sw $t5, 0($t3)
addi $t3, $t4, 31608
sw $t5, 0($t3)
addi $t3, $t4, 31612
sw $t5, 0($t3)
addi $t3, $t4, 31616
sw $t5, 0($t3)
addi $t3, $t4, 31620
sw $t5, 0($t3)
addi $t3, $t4, 31624
sw $t5, 0($t3)
addi $t3, $t4, 31628
sw $t5, 0($t3)
addi $t3, $t4, 31632
sw $t5, 0($t3)
addi $t3, $t4, 31636
sw $t5, 0($t3)
addi $t3, $t4, 31640
sw $t5, 0($t3)
addi $t3, $t4, 31644
sw $t5, 0($t3)
addi $t3, $t4, 31648
sw $t5, 0($t3)
addi $t3, $t4, 31652
sw $t5, 0($t3)
addi $t3, $t4, 31656
sw $t5, 0($t3)
addi $t3, $t4, 31660
sw $t5, 0($t3)
addi $t3, $t4, 31664
sw $t5, 0($t3)
addi $t3, $t4, 31668
sw $t5, 0($t3)
addi $t3, $t4, 31672
sw $t5, 0($t3)
addi $t3, $t4, 31676
sw $t5, 0($t3)
addi $t3, $t4, 31680
sw $t5, 0($t3)
addi $t3, $t4, 31684
sw $t5, 0($t3)
addi $t3, $t4, 31688
sw $t5, 0($t3)
addi $t3, $t4, 31692
sw $t5, 0($t3)
addi $t3, $t4, 31696
sw $t5, 0($t3)
addi $t3, $t4, 31700
sw $t5, 0($t3)
addi $t3, $t4, 31704
sw $t5, 0($t3)
addi $t3, $t4, 31708
sw $t5, 0($t3)
addi $t3, $t4, 31712
sw $t5, 0($t3)
addi $t3, $t4, 31716
sw $t5, 0($t3)
addi $t3, $t4, 31720
sw $t5, 0($t3)
addi $t3, $t4, 31724
sw $t5, 0($t3)
addi $t3, $t4, 31728
sw $t5, 0($t3)
addi $t3, $t4, 31732
sw $t5, 0($t3)
addi $t3, $t4, 31736
sw $t5, 0($t3)
addi $t3, $t4, 31740
sw $t5, 0($t3)
addi $t3, $t4, 31744
sw $t5, 0($t3)
addi $t3, $t4, 31748
sw $t5, 0($t3)
addi $t3, $t4, 31752
sw $t5, 0($t3)
addi $t3, $t4, 31756
sw $t5, 0($t3)
addi $t3, $t4, 31760
sw $t5, 0($t3)
addi $t3, $t4, 31764
sw $t5, 0($t3)
addi $t3, $t4, 31768
sw $t5, 0($t3)
addi $t3, $t4, 31772
sw $t5, 0($t3)
addi $t3, $t4, 31776
sw $t5, 0($t3)
addi $t3, $t4, 31780
sw $t5, 0($t3)
addi $t3, $t4, 31784
li $t5,0xfefefe
sw $t5, 0($t3)
addi $t3, $t4, 31788
sw $t5, 0($t3)
addi $t3, $t4, 31792
sw $t5, 0($t3)
addi $t3, $t4, 31796
li $t5,0xffffff
sw $t5, 0($t3)
addi $t3, $t4, 31800
sw $t5, 0($t3)
addi $t3, $t4, 31804
sw $t5, 0($t3)
addi $t3, $t4, 31808
sw $t5, 0($t3)
addi $t3, $t4, 31812
sw $t5, 0($t3)
addi $t3, $t4, 31816
sw $t5, 0($t3)
addi $t3, $t4, 31820
sw $t5, 0($t3)
addi $t3, $t4, 31824
sw $t5, 0($t3)
addi $t3, $t4, 31828
sw $t5, 0($t3)
addi $t3, $t4, 31832
sw $t5, 0($t3)
addi $t3, $t4, 31836
sw $t5, 0($t3)
addi $t3, $t4, 31840
sw $t5, 0($t3)
addi $t3, $t4, 31844
sw $t5, 0($t3)
addi $t3, $t4, 31848
sw $t5, 0($t3)
addi $t3, $t4, 31852
sw $t5, 0($t3)
addi $t3, $t4, 31856
sw $t5, 0($t3)
addi $t3, $t4, 31860
sw $t5, 0($t3)
addi $t3, $t4, 31864
sw $t5, 0($t3)
addi $t3, $t4, 31868
sw $t5, 0($t3)
addi $t3, $t4, 31872
sw $t5, 0($t3)
addi $t3, $t4, 31876
sw $t5, 0($t3)
addi $t3, $t4, 31880
sw $t5, 0($t3)
addi $t3, $t4, 31884
sw $t5, 0($t3)
addi $t3, $t4, 31888
sw $t5, 0($t3)
addi $t3, $t4, 31892
sw $t5, 0($t3)
addi $t3, $t4, 31896
sw $t5, 0($t3)
addi $t3, $t4, 31900
sw $t5, 0($t3)
addi $t3, $t4, 31904
sw $t5, 0($t3)
addi $t3, $t4, 31908
sw $t5, 0($t3)
addi $t3, $t4, 31912
sw $t5, 0($t3)
addi $t3, $t4, 31916
sw $t5, 0($t3)
addi $t3, $t4, 31920
sw $t5, 0($t3)
addi $t3, $t4, 31924
sw $t5, 0($t3)
addi $t3, $t4, 31928
sw $t5, 0($t3)
addi $t3, $t4, 31932
sw $t5, 0($t3)
addi $t3, $t4, 31936
sw $t5, 0($t3)
addi $t3, $t4, 31940
sw $t5, 0($t3)
addi $t3, $t4, 31944
sw $t5, 0($t3)
addi $t3, $t4, 31948
sw $t5, 0($t3)
addi $t3, $t4, 31952
sw $t5, 0($t3)
addi $t3, $t4, 31956
sw $t5, 0($t3)
addi $t3, $t4, 31960
sw $t5, 0($t3)
addi $t3, $t4, 31964
sw $t5, 0($t3)
addi $t3, $t4, 31968
sw $t5, 0($t3)
addi $t3, $t4, 31972
sw $t5, 0($t3)
addi $t3, $t4, 31976
sw $t5, 0($t3)
addi $t3, $t4, 31980
sw $t5, 0($t3)
addi $t3, $t4, 31984
sw $t5, 0($t3)
addi $t3, $t4, 31988
sw $t5, 0($t3)
addi $t3, $t4, 31992
sw $t5, 0($t3)
addi $t3, $t4, 31996
sw $t5, 0($t3)
addi $t3, $t4, 32000
sw $t5, 0($t3)
addi $t3, $t4, 32004
sw $t5, 0($t3)
addi $t3, $t4, 32008
sw $t5, 0($t3)
addi $t3, $t4, 32012
sw $t5, 0($t3)
addi $t3, $t4, 32016
sw $t5, 0($t3)
addi $t3, $t4, 32020
sw $t5, 0($t3)
addi $t3, $t4, 32024
sw $t5, 0($t3)
addi $t3, $t4, 32028
sw $t5, 0($t3)
addi $t3, $t4, 32032
sw $t5, 0($t3)
addi $t3, $t4, 32036
sw $t5, 0($t3)
addi $t3, $t4, 32040
sw $t5, 0($t3)
addi $t3, $t4, 32044
sw $t5, 0($t3)
addi $t3, $t4, 32048
sw $t5, 0($t3)
addi $t3, $t4, 32052
sw $t5, 0($t3)
addi $t3, $t4, 32056
sw $t5, 0($t3)
addi $t3, $t4, 32060
sw $t5, 0($t3)
addi $t3, $t4, 32064
sw $t5, 0($t3)
addi $t3, $t4, 32068
sw $t5, 0($t3)
addi $t3, $t4, 32072
sw $t5, 0($t3)
addi $t3, $t4, 32076
sw $t5, 0($t3)
addi $t3, $t4, 32080
sw $t5, 0($t3)
addi $t3, $t4, 32084
sw $t5, 0($t3)
addi $t3, $t4, 32088
sw $t5, 0($t3)
addi $t3, $t4, 32092
sw $t5, 0($t3)
addi $t3, $t4, 32096
sw $t5, 0($t3)
addi $t3, $t4, 32100
sw $t5, 0($t3)
addi $t3, $t4, 32104
sw $t5, 0($t3)
addi $t3, $t4, 32108
sw $t5, 0($t3)
addi $t3, $t4, 32112
sw $t5, 0($t3)
addi $t3, $t4, 32116
sw $t5, 0($t3)
addi $t3, $t4, 32120
sw $t5, 0($t3)
addi $t3, $t4, 32124
sw $t5, 0($t3)
addi $t3, $t4, 32128
sw $t5, 0($t3)
addi $t3, $t4, 32132
sw $t5, 0($t3)
addi $t3, $t4, 32136
sw $t5, 0($t3)
addi $t3, $t4, 32140
sw $t5, 0($t3)
addi $t3, $t4, 32144
sw $t5, 0($t3)
addi $t3, $t4, 32148
sw $t5, 0($t3)
addi $t3, $t4, 32152
sw $t5, 0($t3)
addi $t3, $t4, 32156
sw $t5, 0($t3)
addi $t3, $t4, 32160
sw $t5, 0($t3)
addi $t3, $t4, 32164
sw $t5, 0($t3)
addi $t3, $t4, 32168
sw $t5, 0($t3)
addi $t3, $t4, 32172
sw $t5, 0($t3)
addi $t3, $t4, 32176
sw $t5, 0($t3)
addi $t3, $t4, 32180
sw $t5, 0($t3)
addi $t3, $t4, 32184
sw $t5, 0($t3)
addi $t3, $t4, 32188
sw $t5, 0($t3)
addi $t3, $t4, 32192
sw $t5, 0($t3)
addi $t3, $t4, 32196
sw $t5, 0($t3)
addi $t3, $t4, 32200
sw $t5, 0($t3)
addi $t3, $t4, 32204
sw $t5, 0($t3)
addi $t3, $t4, 32208
sw $t5, 0($t3)
addi $t3, $t4, 32212
sw $t5, 0($t3)
addi $t3, $t4, 32216
sw $t5, 0($t3)
addi $t3, $t4, 32220
sw $t5, 0($t3)
addi $t3, $t4, 32224
sw $t5, 0($t3)
addi $t3, $t4, 32228
sw $t5, 0($t3)
addi $t3, $t4, 32232
sw $t5, 0($t3)
addi $t3, $t4, 32236
sw $t5, 0($t3)
addi $t3, $t4, 32240
sw $t5, 0($t3)
addi $t3, $t4, 32244
sw $t5, 0($t3)
addi $t3, $t4, 32248
sw $t5, 0($t3)
addi $t3, $t4, 32252
sw $t5, 0($t3)
addi $t3, $t4, 32256
sw $t5, 0($t3)
addi $t3, $t4, 32260
sw $t5, 0($t3)
addi $t3, $t4, 32264
sw $t5, 0($t3)
addi $t3, $t4, 32268
sw $t5, 0($t3)
addi $t3, $t4, 32272
sw $t5, 0($t3)
addi $t3, $t4, 32276
sw $t5, 0($t3)
addi $t3, $t4, 32280
sw $t5, 0($t3)
addi $t3, $t4, 32284
sw $t5, 0($t3)
addi $t3, $t4, 32288
sw $t5, 0($t3)
addi $t3, $t4, 32292
sw $t5, 0($t3)
addi $t3, $t4, 32296
sw $t5, 0($t3)
addi $t3, $t4, 32300
sw $t5, 0($t3)
addi $t3, $t4, 32304
sw $t5, 0($t3)
addi $t3, $t4, 32308
sw $t5, 0($t3)
addi $t3, $t4, 32312
sw $t5, 0($t3)
addi $t3, $t4, 32316
sw $t5, 0($t3)
addi $t3, $t4, 32320
sw $t5, 0($t3)
addi $t3, $t4, 32324
sw $t5, 0($t3)
addi $t3, $t4, 32328
sw $t5, 0($t3)
addi $t3, $t4, 32332
sw $t5, 0($t3)
addi $t3, $t4, 32336
sw $t5, 0($t3)
addi $t3, $t4, 32340
sw $t5, 0($t3)
addi $t3, $t4, 32344
sw $t5, 0($t3)
addi $t3, $t4, 32348
sw $t5, 0($t3)
addi $t3, $t4, 32352
sw $t5, 0($t3)
addi $t3, $t4, 32356
sw $t5, 0($t3)
addi $t3, $t4, 32360
sw $t5, 0($t3)
addi $t3, $t4, 32364
sw $t5, 0($t3)
addi $t3, $t4, 32368
sw $t5, 0($t3)
addi $t3, $t4, 32372
sw $t5, 0($t3)
addi $t3, $t4, 32376
sw $t5, 0($t3)
addi $t3, $t4, 32380
sw $t5, 0($t3)
addi $t3, $t4, 32384
sw $t5, 0($t3)
addi $t3, $t4, 32388
sw $t5, 0($t3)
addi $t3, $t4, 32392
sw $t5, 0($t3)
addi $t3, $t4, 32396
sw $t5, 0($t3)
addi $t3, $t4, 32400
sw $t5, 0($t3)
addi $t3, $t4, 32404
sw $t5, 0($t3)
addi $t3, $t4, 32408
sw $t5, 0($t3)
addi $t3, $t4, 32412
sw $t5, 0($t3)
addi $t3, $t4, 32416
sw $t5, 0($t3)
addi $t3, $t4, 32420
sw $t5, 0($t3)
addi $t3, $t4, 32424
sw $t5, 0($t3)
addi $t3, $t4, 32428
sw $t5, 0($t3)
addi $t3, $t4, 32432
sw $t5, 0($t3)
addi $t3, $t4, 32436
sw $t5, 0($t3)
addi $t3, $t4, 32440
sw $t5, 0($t3)
addi $t3, $t4, 32444
sw $t5, 0($t3)
addi $t3, $t4, 32448
sw $t5, 0($t3)
addi $t3, $t4, 32452
sw $t5, 0($t3)
addi $t3, $t4, 32456
sw $t5, 0($t3)
addi $t3, $t4, 32460
sw $t5, 0($t3)
addi $t3, $t4, 32464
sw $t5, 0($t3)
addi $t3, $t4, 32468
sw $t5, 0($t3)
addi $t3, $t4, 32472
sw $t5, 0($t3)
addi $t3, $t4, 32476
sw $t5, 0($t3)
addi $t3, $t4, 32480
sw $t5, 0($t3)
addi $t3, $t4, 32484
sw $t5, 0($t3)
addi $t3, $t4, 32488
sw $t5, 0($t3)
addi $t3, $t4, 32492
sw $t5, 0($t3)
addi $t3, $t4, 32496
sw $t5, 0($t3)
addi $t3, $t4, 32500
sw $t5, 0($t3)
addi $t3, $t4, 32504
sw $t5, 0($t3)
addi $t3, $t4, 32508
sw $t5, 0($t3)
addi $t3, $t4, 32512
sw $t5, 0($t3)
addi $t3, $t4, 32516
sw $t5, 0($t3)
addi $t3, $t4, 32520
sw $t5, 0($t3)
addi $t3, $t4, 32524
sw $t5, 0($t3)
addi $t3, $t4, 32528
sw $t5, 0($t3)
addi $t3, $t4, 32532
sw $t5, 0($t3)
addi $t3, $t4, 32536
sw $t5, 0($t3)
addi $t3, $t4, 32540
sw $t5, 0($t3)
addi $t3, $t4, 32544
sw $t5, 0($t3)
addi $t3, $t4, 32548
sw $t5, 0($t3)
addi $t3, $t4, 32552
sw $t5, 0($t3)
addi $t3, $t4, 32556
sw $t5, 0($t3)
addi $t3, $t4, 32560
sw $t5, 0($t3)
addi $t3, $t4, 32564
sw $t5, 0($t3)
addi $t3, $t4, 32568
sw $t5, 0($t3)
addi $t3, $t4, 32572
sw $t5, 0($t3)
addi $t3, $t4, 32576
sw $t5, 0($t3)
addi $t3, $t4, 32580
sw $t5, 0($t3)
addi $t3, $t4, 32584
sw $t5, 0($t3)
addi $t3, $t4, 32588
sw $t5, 0($t3)
addi $t3, $t4, 32592
sw $t5, 0($t3)
addi $t3, $t4, 32596
sw $t5, 0($t3)
addi $t3, $t4, 32600
sw $t5, 0($t3)
addi $t3, $t4, 32604
sw $t5, 0($t3)
addi $t3, $t4, 32608
sw $t5, 0($t3)
addi $t3, $t4, 32612
sw $t5, 0($t3)
addi $t3, $t4, 32616
sw $t5, 0($t3)
addi $t3, $t4, 32620
sw $t5, 0($t3)
addi $t3, $t4, 32624
sw $t5, 0($t3)
addi $t3, $t4, 32628
sw $t5, 0($t3)
addi $t3, $t4, 32632
sw $t5, 0($t3)
addi $t3, $t4, 32636
sw $t5, 0($t3)
addi $t3, $t4, 32640
sw $t5, 0($t3)
addi $t3, $t4, 32644
sw $t5, 0($t3)
addi $t3, $t4, 32648
sw $t5, 0($t3)
addi $t3, $t4, 32652
sw $t5, 0($t3)
addi $t3, $t4, 32656
sw $t5, 0($t3)
addi $t3, $t4, 32660
sw $t5, 0($t3)
addi $t3, $t4, 32664
sw $t5, 0($t3)
addi $t3, $t4, 32668
sw $t5, 0($t3)
addi $t3, $t4, 32672
sw $t5, 0($t3)
addi $t3, $t4, 32676
sw $t5, 0($t3)
addi $t3, $t4, 32680
sw $t5, 0($t3)
addi $t3, $t4, 32684
sw $t5, 0($t3)
addi $t3, $t4, 32688
sw $t5, 0($t3)
addi $t3, $t4, 32692
sw $t5, 0($t3)
addi $t3, $t4, 32696
sw $t5, 0($t3)
addi $t3, $t4, 32700
sw $t5, 0($t3)
addi $t3, $t4, 32704
sw $t5, 0($t3)
addi $t3, $t4, 32708
sw $t5, 0($t3)
addi $t3, $t4, 32712
sw $t5, 0($t3)
addi $t3, $t4, 32716
sw $t5, 0($t3)
addi $t3, $t4, 32720
sw $t5, 0($t3)
addi $t3, $t4, 32724
sw $t5, 0($t3)
addi $t3, $t4, 32728
sw $t5, 0($t3)
addi $t3, $t4, 32732
sw $t5, 0($t3)
addi $t3, $t4, 32736
sw $t5, 0($t3)
addi $t3, $t4, 32740
sw $t5, 0($t3)
addi $t3, $t4, 32744
sw $t5, 0($t3)
addi $t3, $t4, 32748
sw $t5, 0($t3)
addi $t3, $t4, 32752
sw $t5, 0($t3)
addi $t3, $t4, 32756
sw $t5, 0($t3)
addi $t3, $t4, 32760
sw $t5, 0($t3)
addi $t3, $t4, 32764
sw $t5, 0($t3)

	li $v0, 32
	
	li $a0, 4000 # Sleep for 4 seconds before restart
	syscall
	
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
	
	li $a3, HeartPosHex
	
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

	li $a2, 0xFFC0CB	# store red color $a2
	
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

########### function to clear one platform ####################
ClearPlatform:
	lw $a0, 0($sp) 		# $a0 stores the base address for display
	addi $sp, $sp, 4

	li $a2, 0x000000  	# store red color $a2
	
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
	
################################### use this to clear screen when game is not finished ###############
NextLevel:
	
NextLevelClearScreen:
	li $a0, BASE_ADDRESS
	li $a2, 0	#counter
	li $a1, 0x000000	#hex for black
	
NextLevelClearScreenLoop:
	beq $a2, 32768, NextLevelClearScreenEnds
	
	sw $a1, 0($a0) #clear
NextLevelClearScreenLoopAdvance:

	addi $a0, $a0, 4
	addi $a2, $a2, 4
	j NextLevelClearScreenLoop
	
NextLevelClearScreenEnds:
	li $v0, 32
	li $a0, 3000 # Wait one second (1000 milliseconds)
	syscall
	
	
	
	j Start
	
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
	la $t1, Level
	sw $zero, 0($t1)
	add $s4, $zero, $zero
	

	j Start


	
	


	li $v0, 10 # terminate the program gracefully
	syscall

