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
    promptMessage db 'Enter a number: '
    promptMessage_Len equ $ - promptMessage

    revArrayMsg db 'Expected Reversed Array: '
    revArrayMsg_Len equ $ - revArrayMsg

    sumMsg db 'Expected Sum: '
    sumMsg_Len equ $ - sumMsg

    commaSpace db ', '
    commaSpace_Len equ 2

    newLine db 0xA
    newLine_Len equ 1

section .bss
    Input resb 12
    Array resd 5
    RevArray resd 5
    PrintBuffer resb 12

section .text
    global _start

_start:
    xor ecx, ecx

    .Input_Loop:
        cmp ecx, 5
        jge .Input_Done
        push ecx
        printf promptMessage, promptMessage_Len
        scanf Input, 12
        mov esi, Input
        call .ascii_to_int
        pop ecx
        mov [Array + ecx * 4], eax
        inc ecx
        jmp .Input_Loop

    .Input_Done:
        xor ecx, ecx

    .Push_Loop:
        cmp ecx, 5
        jge .Push_Done
        mov eax, [Array + ecx * 4]
        push eax
        inc ecx
        jmp .Push_Loop

    .Push_Done:
        xor ecx, ecx
        xor eax, eax

    .Pop_Loop:
        cmp ecx, 5
        jge .Pop_Done
        pop edx
        mov [RevArray + ecx * 4], edx
        add eax, edx
        inc ecx
        jmp .Pop_Loop

    .Pop_Done:
        push eax

        printf revArrayMsg, revArrayMsg_Len
        xor ecx, ecx

    .Print_Loop:
        cmp ecx, 5
        jge .Print_Loop_Done
        push ecx
        mov eax, [RevArray + ecx * 4]
        mov edi, PrintBuffer + 11
        mov byte [edi], 0
        dec edi
        mov ebx, 10
    .Convert_Loop:
        xor edx, edx
        div ebx
        add dl, '0'
        mov [edi], dl
        dec edi
        test eax, eax
        jnz .Convert_Loop
        inc edi
        mov edx, PrintBuffer + 12
        sub edx, edi
        printf edi, edx

        pop ecx
        cmp ecx, 4
        jge .Skip_Comma
        push ecx
        printf commaSpace, commaSpace_Len
        pop ecx
    .Skip_Comma:
        inc ecx
        jmp .Print_Loop

    .Print_Loop_Done:
        printf newLine, newLine_Len
        printf sumMsg, sumMsg_Len

        pop eax
        mov edi, PrintBuffer + 11
        mov byte [edi], 0
        dec edi
        mov ebx, 10
    .Convert_Sum:
        xor edx, edx
        div ebx
        add dl, '0'
        mov [edi], dl
        dec edi
        test eax, eax
        jnz .Convert_Sum
        inc edi
        mov edx, PrintBuffer + 12
        sub edx, edi
        printf edi, edx
        printf newLine, newLine_Len

        Exit

    .ascii_to_int:
        xor eax, eax
        xor ebx, ebx
    .ascii_to_int_Loop:
        movzx ebx, byte [esi]
        cmp bl, 0
        je .ascii_to_int_Done
        sub bl, '0'
        imul eax, eax, 10
        add eax, ebx
        inc esi
        jmp .ascii_to_int_Loop
    .ascii_to_int_Done:
        ret