.arm 
.text
.global main
main:
    ldr r0, =0x4000000
    ldr r1, =0x6000000
    ldr r2, yoshi
    ldr r3, =0xA0
    ldr r4, =0xa600
    mov r5, #0x400
    add r5, r5, #3
    ldr r6, =0x00
    
    ldr r7, =0x10
    str r7, [r0, #4]
    
    str r5, [r0]

    str r1, [r0 , #b0] 
    str r2, [r0 , #b4] 
    strh r3, [r0, #b8] 
    strh r4, [r0, #ba] 
    
    b loop
    ldrh r7, [r0, #BA]
    ldrh r8, =#0x7fff
    and r7, r7, r8
    strh r7, [r0, #BA]
    .pool
    
loop:
    ldr r6, [r0, #6]
    cmp r6, #120
    bne loop
    
yoshi:
    .incbin "yoshi_image.bin"