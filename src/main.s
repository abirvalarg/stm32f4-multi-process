.syntax unified
.thumb

.section .text

.global main0
.thumb_func
main0:
	ldr r4, =0x11111111
9:
	ldr r0, =#100000
0:
	cmp r0, 0x0
	beq 1f
	sub r0, 1
	b 0b
1:
	svc 0x0
	b 9b

.global main1
.thumb_func
main1:
	ldr r4, =0x22222222
9:
	ldr r0, =#1000000
0:
	cmp r0, 0x0
	beq 1f
	sub r0, 1
	b 0b
1:
	mov r0, 0x1
	svc 0x0
	b 9b
