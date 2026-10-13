[org 0x7c00]

jmp _start

_start:
        mov ah, 0x0e
        mov al, 'A'
        int 0x10

        call new_line

        call switchToProtectedMode

        jmp exit

switchToProtectedMode:
        ; Protected Mode is a 32 bit mode hence we can address up to 4 gb of memory, we can do things like paging and multitasking.
        ; For switching to Protected mode, we need to disable interrupts, enable A20 line, load the GDT Table and set the register CR0
        ; Every Segment has some properties that is called Descriptor, that we need to set in Global Descriptor Table(GDT). There are many ways to implement Descriptor like flat memory model, segmentation, paging etc, here we choose flat memory model where we assume memory to be a single long running address space. Descriptor is 8 byte data structure. We need at least 2 descriptor in GDT: Code segment Descriptor and Data segment Descriptor
        ; In Descriptor Properties, we have flags which are 1 bit boolean property, they are categorized into two flags group: Type flags and Other flags, both 4 bits long(contains 4 flags)
        ; Descriptor Properties:
        ;   - Limit: Limit of segment (20 bit)
        ;   - Base: The starting address of segment (32 bit)
        ;   - Present: Is segment used(must be high for all valid segments) (1 bit - 0|1)
        ;   - Privilage: Uses for memory protection, highest privilage is 00, lowest is 11 (2 bit - 00|01|10|11)
        ;   - Type: 1 if its (code || data) segment or else 0 (1 bit - 0|1)
        ;   - Type Flags
        ;       - Code: Does this seg. contains code
        ;       - Conforming: Can this code be executed from lower privilege seg. (For data segment, its Direction flag, if high, segment becomes exand down segment that grows downwards)
        ;       - Readable: Can this be read or is it only executable, we can read contants if set to high (It becomes writable in Data segment)
        ;       - Accessed: Used by CPU when segment is used by it, we should set it low
        ;   - Other Flags
        ;       - Granularity: The limit is multiplied by 0x1000 so it spans whole 4 GB of memory
        ;       - 32 bit: Is this segment going to use 32 bit mem
        ;       - 64 bits: Is this going to use 64 bit mem.
        ;       - AVL: Stand for "Available for Software Use", if set high, OS or Kernel can use this for their own purposes.
 
        ; equ is used to define constants
        CODE_SEGMENT equ (code_descriptor - GDT_Start) ; size of the Code Segment
        DATA_SEGMENT equ (data_descriptor - GDT_Start) ; size of the Data Segment


        ret

        GDT_Start:
                null_descriptor: ; we need a null descriptor in the init of GDT
                        dd 0 ; dd: Double define word: define 4 bytes
                        dd 0 ; 4 byte+4 byte = 8 byte total
                code_descriptor:
                        dw 0xffff ; first 16 bit of limit (0xfffff is 20 bit)
                        dw 0 ; 16 bits +     (dw stands for define word which define 2 bytes)
                        dd 0 ; 8 bits = 24 bits of base
                        db 10011010 ; present, privilage, type and type flags
                        db 11001111 ; Other flags and last 4 bits of limit
                        db 0 ; last 8 bit of base
                data_descriptor:
                        dw 0xffff
                        dw 0
                        dd 0
                        db 10010010
                        db 11001111
                        db 0
        GDT_End:

        GDT_Descriptor:
                dw GDT_End - GDT_Start - 1 ; size of the GDT
                dd GDT_Start ; base or start address of GDT


new_line:
        push ax
        mov ah, 0x0e

        mov al, 10
        int 0x10

        mov al, 13
        int 0x10
        
        pop ax
        
        ret

exit:

times 510 - ($ - $$) db 0
db 0x55, 0xAA
