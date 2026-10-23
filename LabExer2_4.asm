%macro printf 2
    mov eax, 4
    mov ebx, 1
    mov ecx, %1
    mov edx, %2
    int 0x80
%endmacro

%macro scanf 2
    mov eax, 3
    mov ebx, 0
    mov ecx, %1
    mov edx, %2
    int 0x80

    cmp eax, 0
    jle %%done
    mov esi, %1
    mov byte [esi + eax - 1], 0
%%done:
%endmacro

%macro Exit 0
    mov eax, 1
    mov ebx, 0
    int 0x80
%endmacro

section .data
    promptExpression db 'Enter Expression: '
    promptExpression_Len equ $ - promptExpression

    result db 'Binary representation: '
    result_Len equ $ - result

    newLine db 0xA, 0xA
    newLine_Len equ 2

section .bss
    Input resb 10
    Binary resb 20

section .text
    global _start

_start:
    printf newLine, newLine_Len
    printf promptExpression, promptExpression_Len
    scanf Input, 256

    xor ax, ax
    mov esi, Input

    .ascii_to_int_Loop:
        movzx bx, byte [esi]
        cmp bl, 0
        je .ascii_to_int_Done
        sub bl, '0'
        imul ax, ax, 10
        add ax, bx
        inc esi
        jmp .ascii_to_int_Loop

    .ascii_to_int_Done:
        xor cx, cx

    .divide_Loop:
        xor dx, dx
        mov bx, 2
        div bx
        
        add dl, '0'
        movzx edx, dl
        push edx
        inc cx
        
        cmp ax, 0
        jnz .divide_Loop

    movzx ecx, cx
    mov esi, ecx
    mov edi, Binary

    .pop_loop:
        pop edx
        mov [edi], dl
        inc edi
        dec ecx
        jnz .pop_loop

    mov byte [edi], 10
    inc esi

    printf result, result_Len
    printf Binary, esi
    printf newLine, newLine_Len

    Exit