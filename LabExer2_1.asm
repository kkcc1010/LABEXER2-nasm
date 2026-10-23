; nasm -f elf32 LabExer2_1.asm -o LabExer2_1.o
; ld -m elf_i386 LabExer2_1.o -o LabExer2_1
; ./LabExer2_1

section .data
    prompt      db  "Enter a string: "
    prompt_len  equ $ - prompt

    result_msg  db  "Reversed string: "
    result_len  equ $ - result_msg

    newline     db  10

    ; Input string is stored in the .data section.
    input       times 128 db 0
    reversed    times 128 db 0

section .text
    global _start

_start:
    ; Display input prompt
    mov eax, 4              ; sys_write
    mov ebx, 1              ; stdout
    mov ecx, prompt
    mov edx, prompt_len
    int 80h

    ; Read user input
    mov eax, 3              ; sys_read
    mov ebx, 0              ; stdin
    mov ecx, input
    mov edx, 127
    int 80h

    ; Exit if no input was entered
    cmp eax, 0
    jle exit_program

    ; Add null terminator after the input
    mov byte [input + eax], 0

    ; Find the string length and remove newline characters
    mov esi, input
    xor ecx, ecx

find_length:
    mov al, [esi + ecx]

    cmp al, 0
    je length_found

    cmp al, 10              ; newline character
    je remove_newline

    cmp al, 13              ; carriage return
    je remove_newline

    inc ecx
    jmp find_length

remove_newline:
    mov byte [esi + ecx], 0

length_found:
    mov ebp, ecx            ; EBX/EBP stores string length

    ; Push every character onto the stack.
    ; Each byte is zero-extended and pushed as a doubleword.
    mov esi, input
    mov ecx, ebp

push_characters:
    cmp ecx, 0
    je pop_characters_start

    movzx eax, byte [esi]
    push eax

    inc esi
    dec ecx
    jmp push_characters

    ; Pop characters into the reversed buffer.
pop_characters_start:
    mov edi, reversed
    mov ecx, ebp

pop_characters:
    cmp ecx, 0
    je display_result

    pop eax
    mov [edi], al           ; Store only the character byte

    inc edi
    dec ecx
    jmp pop_characters

display_result:
    ; Display result message
    mov eax, 4              ; sys_write
    mov ebx, 1              ; stdout
    mov ecx, result_msg
    mov edx, result_len
    int 80h

    ; Display reversed string
    mov eax, 4              ; sys_write
    mov ebx, 1              ; stdout
    mov ecx, reversed
    mov edx, ebp
    int 80h

    ; Display newline
    mov eax, 4              ; sys_write
    mov ebx, 1              ; stdout
    mov ecx, newline
    mov edx, 1
    int 80h

exit_program:
    mov eax, 1              ; sys_exit
    xor ebx, ebx
    int 80h