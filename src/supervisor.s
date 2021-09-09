.syntax unified
.thumb

.section .text

.equ GPIOB, 0x40020400
.equ RCC, 0x40023800
.equ STK, 0xE000E010

.global reset
.thumb_func
reset:
	ldr r0, =_DATA_VAL_START
	ldr r1, =_DATA_START
	ldr r2, =_DATA_END

0:
	cmp r1, r2
	beq 1f
	ldrb r3, [r0], 0x1
	strb r3, [r1], 0x1
	b 0b
1:

	ldr r0, =_BSS_START
	ldr r1, =_BSS_END
	eor r2, r2

0:
	cmp r0, r1
	beq 1f
	strb r2, [r0], 0x1
	b 0b
1:

	ldr r0, =RCC + 0x30
	ldr r1, [r0]
	orr r1, 0b10
	str r1, [r0]

	ldr r0, =GPIOB
	ldr r1, =0x5280
	str r1, [r0]

	ldr r0, =_STACK - 0x8000 - 0x4000
	ldr r1, =0x01000000
	str r1, [r0, -0x4]
	ldr r1, =main1
	str r1, [r0, -0x8]
	sub r0, 0x20
	ldr r1, =procData
	str r0, [r1, 0x44]

	ldr r0, =STK
	ldr r1, =0x7d0
	str r1, [r0, 0x4]
	ldr r1, =0b011
	str r1, [r0]

	ldr r0, =0b11
	msr CONTROL, r0

	sub sp, 0x8000
	isb

	bl main0
	b halt

.global NMI
.thumb_func
NMI:
	mov r0, 0b1
	msr PRIMASK, r0
	b halt

.global sys_call
.thumb_func
sys_call:
	push {lr}

	lsl r0, 0x2
	ldr r1, =sysCalls
	ldr r0, [r0, r1]
	blx r0

	pop {lr}
	bx lr

.global sys_tick
.thumb_func
sys_tick:
	ldr r0, =currentProc
	ldr r2, [r0]
	ldr r3, =0x24
	mul r3, r2
	ldr r1, =procData
	add r1, r3

	mrs r12, PSP
	stm r1, {r4, r5, r6, r7, r8, r9, r10, r11, r12}

	ldr r4, =STK
	ldr r5, =0b011
	str r5, [r4]

	eor r2, 0b1
	str r2, [r0]

	ldr r3, =0x24
	mul r3, r2
	ldr r1, =procData
	add r3, r1

	ldm r3, {r4, r5, r6, r7, r8, r9, r10, r11, r12}
	msr PSP, r12
	isb
	bx lr

.thumb_func
switch0:
	ldr r0, =GPIOB + 0x14
	ldr r1, [r0]
	eor r1, 0b1000000
	str r1, [r0]
	bx lr

.thumb_func
switch1:
	ldr r0, =GPIOB + 0x14
	ldr r1, [r0]
	eor r1, 0b10000000
	str r1, [r0]
	bx lr

.global hard_fault
.equ hard_fault, NMI

.global halt
.thumb_func
halt:
	wfi
	b halt

.section .rodata
sysCalls:
	.word switch0
	.word switch1

.section .bss
procData:
.rept 2

.rept 9
.word 0x0
.endr

.endr

currentProc:
	.word 0x0
