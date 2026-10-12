[org 0x7c00]
; https://stanislavs.org/helppc/int_13.html

jmp _start

; Fact: Bootloader occupies address from 0x7C00 to 0x7DFF
_start:
        mov ah, 0x0e
        mov al, 'W'
        int 0x10

        call newLine

        call accessCodeBeyondCurrentBootsector
        jmp exit ; to prevent cpu to look at following things..

accessCodeBeyondCurrentBootsector: ; Access code and execute which is beyond current bootsector through loading more sectors into memory
        ; CHS Address: In BIOS, data is read from the hard drive(mainly) using CHS (Cylinder, Head, Sector) addressing. A hard drive is like multiple cassettes (platters) stacked vertically, with a read/write head(like needle) for each surface. If we view a platter from the top, we can see many concentric circles called tracks. If we consider the tracks at the same radius across all the platter surfaces, they form a cylinder. Each track is divided into sectors, and each sector stores 512 bytes of data. We identify sector through: Cylindrical number, head number and sector number -- CHS
        mov ah, 2
        mov al, 1 ; number of sectors we wanna read
        mov ch, 0 ; cylinder no. - 0 since we reading beginning js after bootloader.
        mov dh, 0 ; head number - we want first
        mov cl, 2 ; sector number(starts from 2), bootloader is 1, it is 2
        mov dl, 0x80 ; C drive mainly
        ; es:bx is the pointer where we wanna load the sector in memory - 0x7e00 here (since its js after our bootloader last byte - 0x7dFF) | js like ss, es is extra segment register and will be 0 since 0x7e00 can be represented in 16 bits(0*16+bx)
        mov bx, 0
        mov es, bx 
        mov bx, 0x7e00

        int 0x13 ; int for disk access

        jc handleErr ; jc checks if CF is 1 | btw cf is a flag register

        cmp al, 1 ; checking if it read the sector no. correctly or not
        jne handleErr


        mov ah, 0x0e
        mov al, [0x7e00]
        int 0x10 ; 'W' as we filled this sector with W
        call newLine
        ret


        handleErr:
                mov bx, errStr
                mov ah, 0x0e
                jmp printErr

                printErr: 
                        cmp [bx], 0
                        je exitPrintErr

                        mov al, [bx]
                        int 0x10
                        inc bx
                        jmp printErr
                errStr: 
                        db "Something went wrong while reading data from disk!!", 0
        

        exitPrintErr:

        call newLine
        ret


newLine:
        push ax

        mov ah, 0x0e
        
        mov al, 13
        int 0x10

        mov al, 10
        int 0x10

        pop ax

        ret


exit:

times 510 - ($ - $$) db 0
db 0x55, 0xAA
times 512 db 'W' ; filling the next disk with W
