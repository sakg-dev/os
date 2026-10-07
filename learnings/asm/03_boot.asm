[org 0x7c00]

mov ah, 0x0e

; manual print instead of loop
;mov al, [bx]
;int 0x10
;inc bx
;mov al, [bx]
;int 0x10
;inc bx
;mov al, [bx]
;int 0x10
;inc bx
;mov al, [bx]
;int 0x10
;inc bx

; new line
mov al, 13
int 0x10
mov al, 10
int 0x10

mov bx, string ; move the starting(of 'H' here) address of string into bx
printString:
        mov al, [bx] ; [] means we want value not address -- dereferance
        int 0x10
        inc bx ; inc the pointer
        cmp [bx], 0 ; if the value is null - 0
        je exit
        jmp printString
string:
        db "Hellow World", 0
exit:

; new line
mov al, 13
int 0x10
mov al, 10
int 0x10

; single character printing from key input
mov ah, 0 ; wait for key to be pressed
int 0x16 ; key interrupt
mov ah, 0x0e ; switch to teletyper mode again
int 0x10 ; we got key value in al and scan code in ah, print key value

; new line
mov al, 13
int 0x10
mov al, 10
int 0x10

; words printing(1+ chars) from key input
mov bx, buffer ; bx contains the starting address of buffer
mov si, bx ; initial address stored in case later needed for printing of smthing
printChar:
        ; keyboard wait and int
        mov ah, 0
        int 0x16
        ; teletyper mode
        mov ah, 0x0e
        ; conditional jmp if enter pressed
        cmp al, 13
        je enterPressed
        ; buffer full so ignore chars
        cmp bx, buffer + 10
        je printChar ; it would complete loop but won't do following
        ; store al value in buffer and inc
        mov [bx], al
        inc bx
        ; printing the char
        int 0x10
        ; repeat
        jmp printChar
enterPressed:
        mov [bx], 0 ; null terminated string -- adding 0 at last
        ; new line
        mov al, 13
        int 0x10
        mov al, 10
        int 0x10
buffer:
        times 11 db 0 ; 10 for chars, 1 for 0-null terminated str

times 510 - ($-$$) db 0

db 0x55, 0xAA
