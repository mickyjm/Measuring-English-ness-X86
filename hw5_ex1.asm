; Assignment 5: Control Structures
; Exercise 1: Measuring English-ness of a corpus
; Author: Michael (Micky) Mangrobang

%include "asm_io.inc"

segment .data
    msg01     db "Enter a string written in some language:", 0    ; startup message
    enarray   db "etaoinshrdlcumwfgypbvkjxqz", 0                  ; the english-ness score array
    msg02     db "The English-ness score is: ", 0                 ; final output message for part 3

segment .bss
    myarray     resd 26         ; counter array for each character
    scarray     resb 27         ; sorted character array for printing, and comparing for part 3

segment .text
    global      asm_main

asm_main:
    enter	0,0                         ; setup
    pusha                               ; setup

; Question 1: Inputing a (large) string and printing character counts

    mov     eax, msg01                  ; point eax to startup message
    call    print_string                ; print startup message

read_next:                              ; read for A-Z ([41h-5Ah] ASCII), a-z ([61h-7Ah] ASCII)
    call    read_char
    cmp     al, 00Ah                    ; check if input==00Ah (\n), if al==00Ah ZF set
    jz      stop_reading                ; if ZF set (al==00Ah), jump to stop_reading
    cmp     al, 041h                    ; check if input<041h (A), if al<041h CF set
    jc      read_next                   ; if CF set (al<041h), jump to read_next
    cmp     al, 07Ah                    ; check if input>07Ah (z), if al>07Ah CF not set
    jnc     read_next                   ; if CF not set (al>07Ah), jump to read_next
    cmp     al, 060h                    ; check if input>060h (`), if al>060h CF not set
    jnc     inc_index                   ; if CF not set (al>060h), jump to inc_index, else al is within [61h-7Ah] (lowercase letters)
    cmp     al, 05Bh                    ; check if input<05Bh ([), if input<05Bh CF set
    jnc     read_next                   ; if CF not set (input>=05Bh), jump to read_next, else al is within [41h-5Ah] (captial letters)
    xor     eax, 020h                   ; XOR input buy 0x20, to convert letter to lowercase

inc_index:                              ; loop to compare character
    mov     dx, 0                       ; set dx = 0
    mov     bx, 061h                    ; set bx = 061h (letter 'a' ASCII)
    div     bx                          ; div ax / bx (lowercase letter ASCII hex value / 061h)
    movzx   ebx, dl                     ; store remainder(modulas value) in eax
    inc     dword [myarray + ebx * 4]   ; increment by 1 in myarray at index (ebx * 4)
    jmp     read_next                   ; jump back to read_next

stop_reading:                           ; stop reading input and prepare output
    call    print_nl                    ; print newline
    mov     ebx, 000h                   ; set ebx for loop & array index counter

print_output:                           ; print final output for HW05 Question 1
    mov     eax, 061h                   ; set eax=061h (a)
    add     eax, ebx                    ; eax +=ebx (next lowercase letter in hex ASCII)
    call    print_char                  ; print current lowercase letter
    mov     eax, 03Ah                   ; set eax=03Ah (:)
    call    print_char                  ; print colon
    mov     eax, [myarray + ebx * 4]    ; set eax to value at index ebx * 4 in myarray
    call    print_int                   ; print integer value
    mov     eax, 020h                   ; set eax=020h (space)
    call    print_char                  ; print space
    inc     ebx                         ; increment index
    cmp     ebx, 01Ah                   ; check if ebx<26, if ebx<26 CF set
    jc      print_output                ; if CF set, jump back to print_output, else move to Question 2 output

; Question 2: Print characters sorted by number of occurrences

    call    print_nl                    ; print newline
    mov     ecx, 000h                   ; set ecx = 0, outer loop counter, scarray index counter

storeMax_loop:                          ; outer for loop, to set inner loop variables and store max character
    mov     ebx, 000h                   ; set ebx = 0, array index counter
    mov     edx, ebx                    ; set edx = ebx, EDX is index of current Max
    mov     eax, [myarray]              ; set eax = first number in myarray

findMax_loop:                           ; inner for loop, to find max
    inc     ebx
    cmp     eax, [myarray + ebx * 4]    ; compare eax value to value in myarray at index * 4 (4 byte values)
    jns     findMax_done                ; if eax < myarray value, SF set (max values get set to -1 after found), jump to findMax_done to store
    mov     eax, [myarray + ebx * 4]    ; store new max into eax
    mov     edx, ebx                    ; store new max index into edx

findMax_done:
    cmp     ebx, 019h                   ; compare ebx counter to 25, set ZF
    jz      storeMax_done               ; if ZF set, inner loop done, jump to storeMax_done
    jmp     findMax_loop                ; else jump back to findMax_loop

storeMax_done:                          ; store max value character into scarray, and set max value to -1
    mov     ebx, edx                    ; set ebx = edx, the max index
    mov     eax, scarray                ; point eax to sorted character array
    mov     edx, 061h                   ; set edx=061h (a)
    add     edx, ebx                    ; edx += ebx (a + ebx)
    mov     [eax + ecx], dl             ; set scarray at index ecx to dl (character value), to build it's own English-ness array
    mov     eax, -1                     ; set eax = -1
    mov     [myarray + ebx * 4], eax    ; store -1 in myarray at index
    inc     ecx                         ; ecx += 1
    cmp     ecx, 01Ah                   ; compare if ecx==26, set ZF
    jnz     storeMax_loop               ; if ZF not set (ecx<26), jump back to storeMax_loop (beginning of outer loop)
    mov     eax, scarray                ; else characters are sorted, eax points to sorted character array
    call    print_string                ; print sorted character array
    call    print_nl                    ; prints newline
    mov     ebx, 000h                   ; set ebx = 0, array index & score counter

; Question 3: Determining English-ness

calc_score:                             ; loop to iterate through both scarray and score, to calculate english-ness score
    mov     al, [scarray + ebx]         ; store scarray value at index in al
    mov     cl, [enarray + ebx]          ; store enarray value at index in cl
    cmp     al, cl                      ; compare al to cl, ZF set if al = cl
    jnz     exit_program                ; if ZF not set, jump to exit_program
    inc     ebx                         ; if al=cl, ebx += 1 (index & score counter)
    cmp     ebx, 01Ah                   ; check if ebx<26, if score ever reaches there
    jc      calc_score                  ; if ebx<26, jump back to calc_score

exit_program:                           ; exit program
    mov     eax, msg02                  ; points eax to msg02
    call    print_string                ; print msg2
    mov     eax, ebx                    ; set eax = ebx value (the score)
    call    print_int                   ; print score
    call    print_nl                    ; prints final newline, for easier to read text in terminal

    popa                    ; cleanup
    mov	    eax, 0          ; cleanup
    mov     ebx, 0          ; cleanup
    mov     ecx, 0          ; cleanup
    mov     edx, 0          ; cleanup
    leave                   ; cleanup
    ret                     ; cleanup
