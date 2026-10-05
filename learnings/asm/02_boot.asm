; jmp $

; Printing A to Z
mov ah, 0x0e ; teletype mode
mov al, 65 ; 'A'
int 0x10 ; create an interrupt
loop:
        inc al
        int 0x10
        cmp al, 90 ; 'Z'
        jne loop ; jump if not equal
mov al, 13 ; Carriage Return: reset position to the beginning of line
int 0x10
mov al, 10 ; LF: new line
int 0x10


; Printing Alphabets while altering the caps
mov ah, 0x0e
; Starting with 'A'
mov al, 65
int 0x10
mov ch, 0 ; Caps TRUE if 255(0xff), FALSE if 0
jmp loopSmall
loopCap: 
        cmp ch, 0
        je loopSmall
        sub al, 31 ; 32 for small to cap then 1 decrement to next char
        int 0x10
        mov ch, 0 ; Caps false
        cmp al, 90 ; Z
        jne loopCap
loopSmall:
        cmp ch, 0xff
        je loopCap
        add al, 33 ; 32 for cap to small then 1 for incrementing to next char 
        int 0x10
        mov ch, 0xff ; Caps true now
        cmp al, 122 ; z
        jne loopSmall

times 510 - ($ - $$) db 0

db 0x55, 0xAA
