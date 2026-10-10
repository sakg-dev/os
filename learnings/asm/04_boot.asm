mov ah, 0x0e

; 16 bit register and its 8 bit registers
mov bx, 'H'
mov al, bl ; 'H' (low is 0-7)
mov al, bh ; '' (high is 8-15)
int 0x10
mov bl, 'A'
mov bh, 'B'
; mov al, bx ; can't do cz al is 8 bit, bx is 16
int 0x10

; stack
mov bp, 0x8765 ; rand addr i chose
mov sp, bp ; bp: base pointer, sp: stack pointer(that changes ig)
push bx ; we already have values from up
mov bl, 'X' ; bx changes here
mov bh, 'Y'
mov al, bl ; X
int 0x10
mov al, bh ; Y
int 0x10
pop bx ; get the top value of stack in bx
mov al, bl ; A
int 0x10
mov al, bh ; B
int 0x10
;push bl ; can't do 8 bit register

push ax
mov al, 13
int 0x10
mov al, 10
int 0x10
pop ax

; pusha - push ax, cx, dx, bx, sp, bp, si, di | popa - pop di, si, bp, sp, bx, dx, cx, ax (no need to manually do for all, js do one!)
mov cx, 1
mov dx, 0xff
mov bx, 'A'
mov si, 0
mov di, 0x10
pusha
jmp smProcedure ; values changed
smProcedure:
        mov al, 'X'
        mov dx, 0
        mov di, 0
popa
int 0x10 ; B
pusha
cmp dx, 0xff
je printSuccess
printSuccess:
        mov bx, string
        jmp printLoop
        printLoop:
                mov al, [bx+0x7c00]
                int 0x10
                inc bx
                cmp [bx+0x7c00], 0
                je end
                jmp printLoop
        string:
                db "Success! value was changed in procedure but after popa, it returned as it was!", 0
end:
popa

push ax
mov al, 13
int 0x10
mov al, 10
int 0x10
pop ax

; Functions: instead of writing the upper mess, write reusable code
call smOtherProcedure
int 0x10 ; address of ts instruction is pushed into the stack | 'X'

mov ax, 215
call printNumber

smOtherProcedure:
        mov al, 'X'
        mov dx, 0
        mov di, 0
        ret ; <- its kinda like pop [register] -> jmp [register]

; Segmentation
; in real mode we can access upto 2^16 bits which is 64 kilobytes thats not a lot
; Hence we have segmentation that devides memory intro segments, each upto 64kb.
; we have data, code, stack and other segments
; we have segment registers like ds, cs, ss etc that stores the address of the segment


printNumber:
        pusha
        
        mov cx, 0 ; as counter -- number of int pushed into stack
        mov bx, 10
        mov dx, 0
        loop:
                inc cx
                cmp ax, 10
                jl singleDigit
                div bl ; dividend is ax, divisor is bl(10) | al=ax/bl, ah=ax%bl
                mov dx, ax
                mov dl, dh ; put value of dh(remainder) in dl for accessibility while printing as we are pushing the whole register not just high or low
                mov dh, 0 ; empty dh as we have its val in dl
                push dx
                mov ah, 0 ; now ax contains the digits without last one like 562 from 5628
                jmp loop
        singleDigit:
                push ax ; simple push
                mov ah, 0x0e ; teletyper mode
                jmp printStackNumber
        printStackNumber:
                cmp cx, 0
                je exit

                pop dx
                add dx, 48 ; 48 is 0 in ascii
                mov al, dl
                int 0x10

                dec cx ; decreament
                jmp printStackNumber
        exit:
        ;mov ax, 'H'
        ;mov dx, ax
        ;mov dl, 'X'
        ;mov ah, 0x0e
        ;int 0x10 ; H
        ; --------
        ; mov ah, 0x0e
        ; mov al, 'W'
        ; int 0x10
        popa
        ret


times 510 - ($-$$) db 0
db 0x55, 0xAA
