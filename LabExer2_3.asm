; nasm -f elf32 LabExer2_3.asm -o LabExer2_3.o
; ld -m elf_i386 LabExer2_3.o -o LabExer2_3
; ./LabExer2_3

section .data
    msg_before db "Calling calculate_foo...", 10
    before_len equ $ - msg_before

    msg_after db "Returned from calculate_foo.", 10
    after_len equ $ - msg_after

    msg_balanced db "Final ESP offset: 0 bytes (Balanced)", 10
    balanced_len equ $ - msg_balanced

section .text
    global _start

_start:
    mov eax, 0
    mov ebx, 15
    mov ecx, 15
    mov edx, 0

    ; Save ESP before calling the subroutine
    mov esi, esp

    ; Display message
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_before
    mov edx, before_len
    int 80h

    ; Restore the test values because sys_write changed registers
    mov eax, 10
    mov ebx, 20
    mov ecx, 30
    mov edx, 40

    ; Call arithmetic subroutine
    call calculate_foo

    ; Check ESP difference
    cmp esp, esi
    jne stack_error

    ; Display successful return message
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_after
    mov edx, after_len
    int 80h

    ; Display balanced-stack message
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_balanced
    mov edx, balanced_len
    int 80h

    jmp exit_program

; -------------------------------------------------------
; calculate_foo
;
; Operation:
;   EAX = EAX * EBX
;   EAX = EAX + ECX
;   EDX = EDX - 1
;
; All modified registers are preserved.
; -------------------------------------------------------
calculate_foo:
    ; Preserve all registers modified by this procedure
    push eax
    push ebx
    push ecx
    push edx

    ; Multiply and add operation
    imul eax, ebx
    add eax, ecx

    ; Additional modification
    dec edx

    ; Restore registers in reverse order
    pop edx
    pop ecx
    pop ebx
    pop eax

    ret

stack_error:
    ; This branch should never execute if the stack is balanced.
    mov eax, 1
    mov ebx, 1
    int 80h

exit_program:
    mov eax, 1
    xor ebx, ebx
    int 80h