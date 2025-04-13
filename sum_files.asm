; sum_files.asm — reads integers from file and sums them (Linux + NASM + glibc)

section .data
    format_in   db "%d", 0
    format_out  db "Sum: %d", 10, 0
    error_msg   db "Failed to open file.", 10, 0

section .bss
    num resd 1
    sum resd 1
    file resq 1

section .text
    global main
    extern fopen, fscanf, printf, fclose

main:
    push ebp
    mov ebp, esp

    ; argc check
    mov eax, [ebp + 8]
    cmp eax, 2
    jne show_error

    ; argv[1] = filename
    mov eax, [ebp + 12]    ; pointer to argv
    add eax, 4             ; argv[1]
    mov eax, [eax]         ; dereference to get string pointer
    push r_mode
    push eax
    call fopen
    add esp, 8
    test eax, eax
    je show_error
    mov [file], eax        ; save FILE*

    ; initialize sum = 0
    mov dword [sum], 0

read_loop:
    push num
    push format_in
    push dword [file]
    call fscanf
    add esp, 12

    cmp eax, 1             ; fscanf returns 1 if one item read
    jne done

    ; add num to sum
    mov eax, [num]
    add [sum], eax
    jmp read_loop

done:
    push dword [sum]
    push format_out
    call printf
    add esp, 8

    ; close file
    push dword [file]
    call fclose
    add esp, 4

    mov eax, 0             ; return 0
    pop ebp
    ret

show_error:
    push error_msg
    call printf
    add esp, 4
    mov eax, 1             ; return 1
    pop ebp
    ret

section .data
    r_mode db "r", 0
