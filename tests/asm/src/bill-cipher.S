.arm
.text
.global main

main:
	mov     r7, #0x4000000  @ base I/O address
    mov     r8, #0x3000000  @ work RAM - audio will be stored here

infin:
    b infin

audio: