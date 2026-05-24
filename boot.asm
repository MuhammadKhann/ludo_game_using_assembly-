[bits 16]
[org 0x7C00]

start:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00
    sti

    mov [BOOT_DRIVE], dl

    ; Load game from sector 2 into memory at 0000:8000
    mov ah, 0x02        ; BIOS read sector function
    mov al, 20          ; read 20 sectors
    mov ch, 0           ; cylinder 0
    mov cl, 2           ; start from sector 2
    mov dh, 0           ; head 0
    mov dl, [BOOT_DRIVE]
    mov bx, 0x8000
    int 0x13

    jc disk_error

    jmp 0x0000:0x8000

disk_error:
    mov si, error_msg
    call print_string
    jmp $

print_string:
    mov ah, 0x0E

.next:
    lodsb
    cmp al, 0
    je .done
    int 0x10
    jmp .next

.done:
    ret

BOOT_DRIVE db 0
error_msg db "Disk read error!", 0

times 510 - ($ - $$) db 0
dw 0xAA55