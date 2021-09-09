.syntax unified
.thumb

.section .rodata

.org 0x0
	.word _STACK
	.word reset
	.word NMI
	.word hard_fault

.org 0x0000002c
	.word sys_call

.org 0x0000003c
	.word sys_tick
