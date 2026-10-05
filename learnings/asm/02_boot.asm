; jmp $

; Printing A to Z
mov ah, 0x0e ; teletype mode
mov al, 65 ; 'A'
int 0x10 ; create an interrupt
loop:
        inc al
        int 0x10
        cmp al, 90 ; 'Z'
        jne loop // jump if not equal

times 510 - ($ - $$) db 0

db 0x55, 0xAA
