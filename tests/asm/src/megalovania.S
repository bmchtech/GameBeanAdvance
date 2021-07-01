.arm
.text
.global main

main:
	mov     r7, #0x4000000  @ base I/O address
    mov     r8, #0x3000000  @ work RAM - audio will be stored here

fill_up_audio:
    mov     r6, #0x56       @ 0x5622: 1 second worth of audio
    lsl     r6, #0x8
    orr     r6, #0x22

    mov     r9, #0x80       @ we want waves of this frequency
    mov     r4, #0x0        @ audio offset = 0
    ldr     r5, =audio

fill_up_audio_loop:
    mov     r0, r4
    mov     r1, r9
    swi     #0x60000
    strb    r1, [r8, r4]    @ should produce a nice saw wave  
    add     r4, #0x1
    strb    r1, [r8, r4]
    add     r4, #0x1

    cmp     r4, r6
    beq     setup_sound

    b       fill_up_audio_loop

setup_sound:
    mov     r1, #0x80       @ I/O offset for SOUNDCNT_L
    mov     r2, #0x0        @ audio channels 1-4 shouldn't play
    strh    r2, [r7, r1]

    mov     r1, #0x82       @ I/O offset for SOUNDCNT_H
    mov     r2, #0xB        @ 0xB04: connect Timer 0 to DMA, set volume to 100%, reset FIFO
    lsl     r2, #0x8
    orr     r2, #0x04
    strh    r2, [r7, r1]

setup_timers:
    mov     r1, #0x0
    sub     r1, #0x1        @ 0xFFFF, the max timer value

    mov     r3, #0x2
    lsl     r3, #0x8
    orr     r3, #0xF9
    sub     r1, r3          @ 0x2F9: ticks per sample

    mov     r2, #0x100      @ I/O offset for TM0CNT_L
    strh    r1, [r7, r2]

    mov     r2, #0x1        @ 0x102: I/O offset for TM0CNT_H
    lsl     r2, #0x8
    orr     r2, #0x2
    mov     r1, #0x80       @ Timer Enable
    strh    r1, [r7, r2]

setup_audio_dma:
    
    mov     r1, #0xBC       @ I/O offset for DMA1SAD
	str     r8, [r7, r1]
    
    mov     r1, #0xC0       @ I/O offset for DMA1DAD
    mov     r2, #0xA0       @ I/O offset for FIFO_A
    add     r2, r7, r2
	str     r2, [r7, r1]
    
    mov     r1, #0xC4       @ I/O offset for DMA1CNT
    mov     r2, #0xB6000000 @ DMA enable, Audio Mode
	str     r2, [r7, r1]

infin:
    b infin

audio: