
BITS 32

; MACRO: write text and preserve all general-purpose registers.
%macro PRINT 2
    pushad
    mov eax, 4
    mov ebx, 1
    mov ecx, %1
    mov edx, %2
    int 0x80
    popad
%endmacro

; MACRO: prompt, call the input procedure, and save the text length.
%macro INPUT 3
    PRINT %1, %1Len
    mov edi, %2
    call ReadLine
    mov [%3], eax
%endmacro

; MACRO: display a student field and its entered value.
%macro DISPLAY 3
    PRINT %1, %1Len
    PRINT %2, [%3]
    PRINT newline, 1
%endmacro

TOTAL_UNITS equ 21
; All financial amounts are stored in centavos for exact decimal output.
RATE_PER_UNIT equ 210800
MISC_FEE equ 1230500
ID_FEE equ 8000
COMPUTER_LAB_FEE equ 400800
SCIENCE_LAB_FEE equ 410400

section .data
    heading db 'ENTER STUDENT ENROLLMENT DETAILS', 10
    headingLen equ $ - heading
    resultHeading db 10, '========== ENROLLMENT INFORMATION ==========', 10
    resultHeadingLen equ $ - resultHeading
    feeHeading db '========== TUITION FEE ASSESSMENT ==========', 10
    feeHeadingLen equ $ - feeHeading
    newline db 10
    dot db '.'
    tooLong db 'Maximum 255 characters. Please enter this field again: '
    tooLongLen equ $ - tooLong
    statusPrompt db 'Enrollment Status : '
    statusPromptLen equ $ - statusPrompt
    studentPrompt db 'Student # : '
    studentPromptLen equ $ - studentPrompt
    collegePrompt db 'College : '
    collegePromptLen equ $ - collegePrompt
    programPrompt db 'Program : '
    programPromptLen equ $ - programPrompt
    namePrompt db 'Name : '
    namePromptLen equ $ - namePrompt
    yearPrompt db 'Year Level : '
    yearPromptLen equ $ - yearPrompt
    termPrompt db 'Term : '
    termPromptLen equ $ - termPrompt
    schoolYearPrompt db 'School Year : '
    schoolYearPromptLen equ $ - schoolYearPrompt
    phonePrompt db 'Phone : '
    phonePromptLen equ $ - phonePrompt
    zipPrompt db 'Zip Code : '
    zipPromptLen equ $ - zipPrompt
    addressPrompt db 'Address : '
    addressPromptLen equ $ - addressPrompt
    classificationPrompt db 'Classification : '
    classificationPromptLen equ $ - classificationPrompt

    Courses db '------------------------------------------------------------------------------------------------------------------------', 10
        db 'COURSES   TITLE                                     SECTION UNITS DAYS TIME                ROOM', 10
        db '------------------------------------------------------------------------------------------------------------------------', 10
        db 'CCS0021   INFORMATION MANAGEMENT (LEC)              TN24    2     T    16:00:00-18:40:00   ONLINE', 10
        db 'CCS0021L  INFORMATION MANAGEMENT (LAB)              TN24    1     F    16:00:00-18:50:00   ONLINE', 10
        db 'CS0001    DISCRETE STRUCTURES 1                     TN24    3     S/W  15:00:00-16:50:00   F710 / F710', 10
        db 'CS0003    COMPUTER SYSTEMS & ARCHITECTURE           TN24    2     F    10:00:00-12:40:00   ONLINE', 10
        db 'CS0003L   COMPUTER SYSTEMS & ARCHITECTURE (LAB)     TN24    1     TH   10:00:00-12:50:00   E610', 10
        db 'CS0070    OBJECT ORIENTED PROGRAMMING               TN24    2     F    07:00:00-09:40:00   ONLINE', 10
        db 'CS0070L   OBJECT ORIENTED PROGRAMMING-LAB           TN24    1     TH   07:00:00-09:50:00   E609', 10
        db 'GED0021   SPECIALIZED ENGLISH PROGRAM 2             TN24    3     S/W  11:00:00-12:50:00   F807 / F807', 10
        db 'GED0075   LINEAR ALGEBRA                           TN24    3     F/T  13:00:00-14:50:00   ONLINE / ONLINE', 10
        db 'GED0081   COLLEGE PHYSICS 1 LECTURE                 TN24    2     T    07:00:00-09:40:00   ONLINE', 10
        db 'GED0081L  COLLEGE PHYSICS 1 LABORATORY              TN24    1     S    07:00:00-09:50:00   F1003', 10
        db '------------------------------------------------------------------------------------------------------------------------', 10
        db 'TOTAL UNITS: 21', 10, 10
    CoursesLen equ $ - Courses

    tuitionLabel db 'Tuition Fee (21 units)                       : PHP '
    tuitionLabelLen equ $ - tuitionLabel
    miscLabel db 'Miscellaneous Fee                            : PHP '
    miscLabelLen equ $ - miscLabel
    idLabel db 'ID Validation Fee                            : PHP '
    idLabelLen equ $ - idLabel
    lab1Label db 'ITE Computer Laboratory Fee (CCS0021)        : PHP '
    lab1LabelLen equ $ - lab1Label
    lab2Label db 'ITE Computer Laboratory Fee (CS0003)         : PHP '
    lab2LabelLen equ $ - lab2Label
    lab3Label db 'ITE Computer Laboratory Fee (CS0070)         : PHP '
    lab3LabelLen equ $ - lab3Label
    scienceLabel db 'Science Lab Fee (GED0081)                    : PHP '
    scienceLabelLen equ $ - scienceLabel
    totalLabel db 'TOTAL ASSESSMENT                             : PHP '
    totalLabelLen equ $ - totalLabel
    downLabel db 'Down Payment (Upon Enrollment) 40%           : PHP '
    downLabelLen equ $ - downLabel
    midLabel db 'Midterm (Oct 05 - Oct 07 2026) 30%           : PHP '
    midLabelLen equ $ - midLabel
    finalLabel db 'Final (Nov 26 - Dec 03 2026) 30%             : PHP '
    finalLabelLen equ $ - finalLabel

section .bss
    statusInput resb 256
    statusLength resd 1
    studentInput resb 256
    studentLength resd 1
    collegeInput resb 256
    collegeLength resd 1
    programInput resb 256
    programLength resd 1
    nameInput resb 256
    nameLength resd 1
    yearInput resb 256
    yearLength resd 1
    termInput resb 256
    termLength resd 1
    schoolYearInput resb 256
    schoolYearLength resd 1
    phoneInput resb 256
    phoneLength resd 1
    zipInput resb 256
    zipLength resd 1
    addressInput resb 256
    addressLength resd 1
    classificationInput resb 256
    classificationLength resd 1
    inputChar resb 1
    numberBuffer resb 16
    decimalDigits resb 2
    tuitionAmount resd 1
    totalAmount resd 1
    downAmount resd 1
    installmentAmount resd 1
    finalAmount resd 1

section .text
global _start

_start:
    PRINT heading, headingLen
    INPUT statusPrompt, statusInput, statusLength
    INPUT studentPrompt, studentInput, studentLength
    INPUT collegePrompt, collegeInput, collegeLength
    INPUT programPrompt, programInput, programLength
    INPUT namePrompt, nameInput, nameLength
    INPUT yearPrompt, yearInput, yearLength
    INPUT termPrompt, termInput, termLength
    INPUT schoolYearPrompt, schoolYearInput, schoolYearLength
    INPUT phonePrompt, phoneInput, phoneLength
    INPUT zipPrompt, zipInput, zipLength
    INPUT addressPrompt, addressInput, addressLength
    INPUT classificationPrompt, classificationInput, classificationLength

    PRINT resultHeading, resultHeadingLen
    DISPLAY statusPrompt, statusInput, statusLength
    DISPLAY studentPrompt, studentInput, studentLength
    DISPLAY collegePrompt, collegeInput, collegeLength
    DISPLAY programPrompt, programInput, programLength
    DISPLAY namePrompt, nameInput, nameLength
    DISPLAY yearPrompt, yearInput, yearLength
    DISPLAY termPrompt, termInput, termLength
    DISPLAY schoolYearPrompt, schoolYearInput, schoolYearLength
    DISPLAY phonePrompt, phoneInput, phoneLength
    DISPLAY zipPrompt, zipInput, zipLength
    DISPLAY addressPrompt, addressInput, addressLength
    DISPLAY classificationPrompt, classificationInput, classificationLength
    PRINT newline, 1
    PRINT Courses, CoursesLen
    call ComputeTuition
    PRINT feeHeading, feeHeadingLen
    PRINT tuitionLabel, tuitionLabelLen
    mov eax, [tuitionAmount]
    call PrintMoney
    PRINT miscLabel, miscLabelLen
    mov eax, MISC_FEE
    call PrintMoney
    PRINT idLabel, idLabelLen
    mov eax, ID_FEE
    call PrintMoney
    PRINT lab1Label, lab1LabelLen
    mov eax, COMPUTER_LAB_FEE
    call PrintMoney
    PRINT lab2Label, lab2LabelLen
    mov eax, COMPUTER_LAB_FEE
    call PrintMoney
    PRINT lab3Label, lab3LabelLen
    mov eax, COMPUTER_LAB_FEE
    call PrintMoney
    PRINT scienceLabel, scienceLabelLen
    mov eax, SCIENCE_LAB_FEE
    call PrintMoney
    PRINT totalLabel, totalLabelLen
    mov eax, [totalAmount]
    call PrintMoney
    PRINT newline, 1
    PRINT downLabel, downLabelLen
    mov eax, [downAmount]
    call PrintMoney
    PRINT midLabel, midLabelLen
    mov eax, [installmentAmount]
    call PrintMoney
    PRINT finalLabel, finalLabelLen
    mov eax, [finalAmount]
    call PrintMoney

    mov eax, 1
    xor ebx, ebx
    int 0x80

; PROCEDURE: compute tuition, total assessment, and 40%/30%/30% payments.
ComputeTuition:
    mov eax, RATE_PER_UNIT
    imul eax, TOTAL_UNITS
    mov [tuitionAmount], eax
    add eax, MISC_FEE
    add eax, ID_FEE
    add eax, COMPUTER_LAB_FEE * 3
    add eax, SCIENCE_LAB_FEE
    mov [totalAmount], eax

    ; Calculate payments in centavos. The final payment absorbs any rounding.
    imul eax, 40
    xor edx, edx
    mov ebx, 100
    div ebx
    mov [downAmount], eax
    mov eax, [totalAmount]
    imul eax, 30
    xor edx, edx
    div ebx
    mov [installmentAmount], eax
    mov eax, [totalAmount]
    sub eax, [downAmount]
    sub eax, [installmentAmount]
    mov [finalAmount], eax
    ret


ReadLine:
    push ebx
    push ecx
    push edx
    push esi
    push edi
    push ebp
.restart:
    xor esi, esi
    xor ebp, ebp
.read:
    mov eax, 3
    xor ebx, ebx
    mov ecx, inputChar
    mov edx, 1
    int 0x80
    cmp eax, 1
    jne .inputEnded
    mov al, [inputChar]
    cmp al, 10
    je .lineEnd
    cmp al, 13
    je .read
    cmp esi, 255
    jae .overflow
    mov [edi + esi], al
    inc esi
    jmp .read
.overflow:
    mov ebp, 1
    jmp .read
.lineEnd:
    test ebp, ebp
    jz .done
    PRINT tooLong, tooLongLen
    jmp .restart
.inputEnded:
    ; Stop on missing input instead of repeatedly prompting at EOF.
    mov eax, 1
    mov ebx, 1
    int 0x80
.done:
    mov byte [edi + esi], 0
    mov eax, esi
    pop ebp
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret

; PROCEDURE
PrintNumber:
    pushad
    mov edi, numberBuffer + 16
    mov ebx, 10
    xor ecx, ecx
    xor ebp, ebp
.convert:
    xor edx, edx
    div ebx
    add dl, '0'
    dec edi
    mov [edi], dl
    inc ecx
    inc ebp
    test eax, eax
    jz .write
    cmp ebp, 3
    jne .convert
    dec edi
    mov byte [edi], ','
    inc ecx
    xor ebp, ebp
    jmp .convert
.write:
    mov edx, ecx
    mov ecx, edi
    mov eax, 4
    mov ebx, 1
    int 0x80
    popad
    ret

; PROCEDURE: print the centavo value in EAX as pesos
PrintMoney:
    pushad
    xor edx, edx
    mov ebx, 100
    div ebx
    push edx
    call PrintNumber
    PRINT dot, 1
    pop eax
    xor edx, edx
    mov ebx, 10
    div ebx
    add al, '0'
    add dl, '0'
    mov [decimalDigits], al
    mov [decimalDigits + 1], dl
    PRINT decimalDigits, 2
    PRINT newline, 1
    popad
    ret
