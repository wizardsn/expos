; MBR bootloader
; We should load  stage2 bootloader at fixed address STAGE2_LMA
; stage2 bootloader is placed at sectors 2-8 (7 sectors)
    
; BIOS loads us at physical address 0x7C00
; Register DL contains the boot device
    
%ifndef STAGE2_LMA
    %error "STAGE2 address is not defined"
%endif

section .bootloader
    use16                       ; want real mode code
    org     0x7C00
    
_start:
    jmp     0x0:_entry          ; skip variables and set CS = 0
    
; Boot drive number from BIOS
b_boot_drive:    db  0x0
    
; real entry point
_entry:
    cli
    xor     ax, ax              ; setup segmenet registers
    mov     ds, ax
    mov     es, ax
    mov     ss, ax
    mov     sp, ax              ; setup stack pointer 0x0:0x0000
    sti
    mov     [b_boot_drive], dl  ; store BIOS boot drive

   

    mov     si, hello           ; say hello
    call    kputs

    ;; we need to read out 7 next sectors from the disk

    ; stop
    jmp $
    
; print ds:si string using teletype BIOS service
kputs:
	mov ah, 0xE
.puts:   
	lodsb
	test    al, al
	jz  .exit
	int 0x10
	jmp .puts
.exit:
	ret

; messages
hello:
    db "Hello world!", 13, 10, 0
    
; boot sector signature
    times 510-$+_start	db 0
	dw 0xAA55

