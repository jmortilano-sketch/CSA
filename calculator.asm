


global _start

section .data
    menu db "--------------------------------", 10
         db "MENU", 10, 10
         db "[A]dd", 10
         db "[S]ubtract", 10
         db "[M]ultiply", 10
         db "[D]ivide", 10
         db "--------------------------------", 10
         db "Enter your choice: ", 0

    first_prompt  db 10, "Enter first number: ", 0
    second_prompt db "Enter second number: ", 0

    sum_msg        db 10, "The sum is ", 0
    difference_msg db 10, "The difference is ", 0
    product_msg    db 10, "The product is ", 0
    quotient_msg   db 10, "The quotient is ", 0
    remainder_msg  db " with remainder ", 0

    choice_error db "Invalid choice. Enter A, S, M, or D.", 10, 0
    number_error db "Invalid input. Enter a number from 0 to 99: ", 0
    zero_error   db 10, "Cannot divide by zero.", 10, 0

    again_prompt db 10, "Do you want to try again (Y/N)? ", 0
    again_error  db "Please enter Y or N.", 10, 0
    goodbye      db 10, "Program terminated.", 10, 0
    newline      db 10, 0

    ; ANSI escape codes: clear screen and move cursor to the top
    clear_code db 27, "[2J", 27, "[H", 0

section .bss
    input_buffer resb 32
    input_char   resb 1
    choice       resb 1

    number1      resd 1
    number2      resd 1
    remainder    resd 1

    output_buffer resb 12
    output_end:

section .text

_start:
    call clear_screen

main_menu:
    mov ecx, menu
    call print_string
    call read_line

    cmp eax, 1
    jne invalid_choice

    mov al, [input_buffer]
    and al, 11011111b       ; Convert lowercase to uppercase

    cmp al, 'A'
    je valid_choice
    cmp al, 'S'
    je valid_choice
    cmp al, 'M'
    je valid_choice
    cmp al, 'D'
    je valid_choice

invalid_choice:
    mov ecx, choice_error
    call print_string
    jmp main_menu

valid_choice:
    mov [choice], al

    mov ecx, first_prompt
    call print_string
    call read_number
    mov [number1], eax

    mov ecx, second_prompt
    call print_string
    call read_number
    mov [number2], eax

    cmp byte [choice], 'A'
    je do_add
    cmp byte [choice], 'S'
    je do_subtract
    cmp byte [choice], 'M'
    je do_multiply
    jmp do_divide

do_add:
    call add_numbers
    mov ecx, sum_msg
    call print_string
    call print_integer
    jmp result_done

do_subtract:
    call subtract_numbers
    mov ecx, difference_msg
    call print_string
    call print_integer
    jmp result_done

do_multiply:
    call multiply_numbers
    mov ecx, product_msg
    call print_string
    call print_integer
    jmp result_done

do_divide:
    cmp dword [number2], 0
    je division_error

    call divide_numbers
    mov [remainder], edx

    mov ecx, quotient_msg
    call print_string
    call print_integer

    mov ecx, remainder_msg
    call print_string
    mov eax, [remainder]
    call print_integer

result_done:
    mov ecx, newline
    call print_string
    jmp ask_again

division_error:
    mov ecx, zero_error
    call print_string

ask_again:
    mov ecx, again_prompt
    call print_string
    call read_line

    cmp eax, 1
    jne invalid_again

    mov al, [input_buffer]
    and al, 11011111b

    cmp al, 'Y'
    je restart
    cmp al, 'N'
    je finish

invalid_again:
    mov ecx, again_error
    call print_string
    jmp ask_again

restart:
    call clear_screen
    jmp main_menu

finish:
    mov ecx, goodbye
    call print_string

exit_program:
    mov eax, 1             ; sys_exit
    xor ebx, ebx
    int 0x80


; Arithmetic procedures


add_numbers:
    mov eax, [number1]
    add eax, [number2]
    ret

subtract_numbers:
    mov eax, [number1]
    sub eax, [number2]
    ret

multiply_numbers:
    mov eax, [number1]
    imul eax, [number2]
    ret

divide_numbers:
    mov eax, [number1]
    xor edx, edx
    div dword [number2]
    ret



print_string:
    pushad

    xor edx, edx

.count:
    cmp byte [ecx + edx], 0
    je .write
    inc edx
    jmp .count

.write:
    mov eax, 4             ; sys_write
    mov ebx, 1             ; Standard output
    int 0x80

    popad
    ret



read_line:
    push ebx
    push ecx
    push edx
    push edi

    xor edi, edi

.read:
    mov eax, 3             ; sys_read
    xor ebx, ebx           ; Standard input
    mov ecx, input_char
    mov edx, 1
    int 0x80

    cmp eax, 0
    jle exit_program

    mov al, [input_char]
    cmp al, 10
    je .done

    cmp edi, 31
    jae .skip_store
    mov [input_buffer + edi], al

.skip_store:
    inc edi
    jmp .read

.done:
    mov eax, edi
    cmp edi, 31
    jbe .terminate
    mov edi, 31

.terminate:
    mov byte [input_buffer + edi], 0

    pop edi
    pop edx
    pop ecx
    pop ebx
    ret


; Read and validate a one- or two-digit number.
; Returns the numeric value in EAX.


read_number:
.retry:
    call read_line

    cmp eax, 1
    jb .invalid
    cmp eax, 2
    ja .invalid

    mov ecx, eax           ; Number of characters
    xor eax, eax
    xor esi, esi

.convert:
    movzx edx, byte [input_buffer + esi]

    cmp edx, '0'
    jb .invalid
    cmp edx, '9'
    ja .invalid

    sub edx, '0'
    imul eax, eax, 10
    add eax, edx

    inc esi
    cmp esi, ecx
    jb .convert
    ret

.invalid:
    mov ecx, number_error
    call print_string
    jmp .retry


; Print a signed integer.


print_integer:
    pushad

    mov edi, output_end
    xor esi, esi           ; Negative-number flag

    test eax, eax
    jns .prepare

    mov esi, 1
    neg eax

.prepare:
    mov ebx, 10

.convert:
    xor edx, edx
    div ebx

    add dl, '0'
    dec edi
    mov [edi], dl

    test eax, eax
    jnz .convert

    test esi, esi
    jz .write

    dec edi
    mov byte [edi], '-'

.write:
    mov ecx, edi
    mov edx, output_end
    sub edx, edi

    mov eax, 4
    mov ebx, 1
    int 0x80

    popad
    ret

clear_screen:
    mov ecx, clear_code
    call print_string
    ret