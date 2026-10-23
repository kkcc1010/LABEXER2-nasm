;--- macro to print data easier --- 
%macro printf 2
    mov eax, 4
    mov ebx, 1
    mov ecx, %1                                                     ;First input holds the variable to print
    mov edx, %2                                                     ;Second input holds the length of the variable
    int 0x80
%endmacro

;--- macro to get input from user easier --- 
%macro scanf 2
    mov eax, 3
    mov ebx, 0
    mov ecx, %1                                                     ;Variable to save user input into
    mov edx, %2                                                     ;Value of reserved data for variable
    int 0x80

    cmp eax, 0
    jle %%done
    mov esi, %1
    mov byte [esi + eax - 1], 0
%%done:
%endmacro

;--- Macro to exit program ---
%macro Exit 0
    mov eax, 1
    mov ebx, 0
    int 0x80
%endmacro

section .data
    promptExpression db 'Enter Expression: '
    promptExpression_Len equ $ - promptExpression

    balanced db '1 (Balanced)', 0xA, 0xA
    balanced_Len equ $ - balanced

    unbalanced db '0 (Unbalanced)', 0xA, 0xA
    unbalanced_Len equ $ - unbalanced

    newLine db 0xA
    newLine_Len equ 2

section .bss
    Expression resb 256

section .text
    global _start

_start:
    printf newLine, newLine_Len
    printf promptExpression, promptExpression_Len
    scanf Expression, 256

    mov esi, Expression
    call check_Balanced

    cmp eax, 1
    je .print_Balanced

    printf unbalanced, unbalanced_Len
    jmp .exit_Program

    .print_Balanced:
        printf balanced, balanced_Len
        jmp .exit_Program

    .exit_Program:
        Exit

check_Balanced:
    xor ebx, ebx

.loop_start:
    mov al, [esi]
    cmp al, 0
    je .check_Final

    cmp al, '('
    je .if_OpenBracket

    cmp al, ')'
    je .if_CloseBracket

    jmp .next_Char

.if_OpenBracket:
    movzx eax, al
    push eax
    inc ebx
    jmp .next_Char

.if_CloseBracket:
    cmp ebx, 0
    je .unbalanced_Early
    
    pop edx
    dec ebx
    jmp .next_Char

.next_Char:
    inc esi
    jmp .loop_start

.check_Final:
    cmp ebx, 0
    jne .unbalanced_Cleanup
    mov eax, 1
    ret

.unbalanced_Early:
    mov eax, 0
    ret

.unbalanced_Cleanup:
    mov ecx, ebx
    .cleanup_Loop:
        cmp ecx, 0
        je .cleanup_Done
        pop edx
        dec ecx
        jmp .cleanup_Loop
    
.cleanup_Done:
    mov eax, 0
    ret