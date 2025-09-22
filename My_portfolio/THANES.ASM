.model small
.stack 100h

.data

   banner_art db 13,10
    db ' _______ __    __   ___   __    ______    _______ _______ __   __',13,10
    db '|   _   |  |  |  | |   | |  |  |    _ |  |   _   |       |  |_|  |',13,10
    db '|  |_|  |  |__|  | |   | |  |  |   | ||  |  |_|  |   _   |       |',13,10
    db '|       |       | |   | |  |_|   |_||_| |       |  | |  |       |',13,10
    db '|       |       | |   | |       |   |   |       |  |_|  |       |',13,10
    db '|   _   |   _   | |   | |       |   |   |   _   |       | ||_|| |',13,10
    db '|__| |__|__| |__| |___| |_______|   |___|__| |__|_______|_|   |_|',13,10
    db '     T  H  A  N  E  S   A  T  M   S  Y  S  T  E  M',13,10, '$'

    username_prompt db 'Enter Username: $'
    password_prompt db 13,10,'Enter Password: $'
    login_success db 13,10,'Login successful!',13,10,'$'
    login_fail db 13,10,'Invalid credentials. Try again.',13,10,'$'

    stored_user db 'USER$'
    stored_pass db 'PASS$'

    user_buffer db 10,0,10 dup(0)
    pass_buffer db 10,0,10 dup(0)
    newline db 13,10,'$'

    balance dw 1000
    line1 db 13,10,'THANES ATM SYSTEM',13,10,'$'
    line2 db '1. Check Balance',13,10,'$'
    line3 db '2. Withdraw Cash',13,10,'$'
    line4 db '3. Cash Deposit',13,10,'$'
    line5 db '4. Cheque Deposit',13,10,'$'
    line6 db '5. Change PIN',13,10,'$'
    line7 db '6. Transfer to Another Account',13,10,'$'
    line8 db '7. Print Receipt',13,10,'$'
    line9 db '8. Exit',13,10,'$'

    
    savings_balance dw 1000     ; Initial savings account balance
    investment_balance dw 1000  ; Initial investment account balance
    
    msg_balance db 13,10,'Current Balance: $'
    msg_withdraw db 13,10,'Enter amount to withdraw: $'
    msg_success  db 13,10,'Transaction successful!',13,10,'$'
    msg_insufficient db 13,10,'Insufficient funds!',13,10,'$'
    input_buffer db 9,0,9 dup(0)

    msg_deposit db 13,10,'Enter amount to deposit: $'

    msg_cheque_id db 13,10,'Enter Cheque ID: $'
    msg_cheque_added db 13,10,'Cheque RM1000 deposited successfully!',13,10,'$'
    invalid_cheque_msg db 'Invalid Cheque ID. Must be 8 digits.',13,10,'$'

    msg_transfer_from db 13,10,'Transfer from:',13,10,'1. Savings Account',13,10,'2. Investment Account',13,10,'Choice: $'
    msg_transfer_to db 13,10,'Enter recipient 12-digit account number: $'
    msg_transfer_amt db 13,10,'Enter amount to transfer: $'
    msg_transfer_done db 13,10,'Transfer completed!',13,10,'$'
    msg_pin_updated db 13,10,'PIN changed successfully!',13,10,'$'

    stored_pin_hash dw 202    ; Optional: if using hashed PINs
    account_number_buffer db 14,0,14 dup(0)
    msg_change_pin db 13,10,'Enter NEW PIN: $'
    msg_transfer_log db 'Transfer', 0
    

    msg_wrong_pin db 13,10, 'Incorrect current PIN. Try again.',13,10,'$'
    
    check_balance_menu db 13,10,'Check from:',13,10,'1. Savings Account',13,10,'2. Investment Account',13,10,'Choice: $'
    msg_savings_balance db 13,10,'Savings Balance: $'
    msg_investment_balance db 13,10,'Investment Balance: $'
    
    receipt_msg db 13,10, '--- Receipt ---',13,10,'$'
    amount_msg db 'Amount: $'
    tax_msg db 13,10, 'Tax (6%): $'
    total_msg db 13,10, 'Total: $'
    last_transaction_amount dw 0
    
.code
start:
    mov ax, @data
    mov ds, ax
    jmp login_screen

login_screen:
    mov dx, offset newline
    mov ah, 09h
    int 21h

    mov dx, offset username_prompt
    mov ah, 09h
    int 21h
    lea dx, user_buffer
    mov ah, 0Ah
    int 21h

     mov dx, offset password_prompt
    mov ah, 09h
    int 21h

    ; Masked password input
    xor cx, cx
    lea di, pass_buffer + 2
.mask_loop:
    mov ah, 08h    ; Read char without echo
    int 21h
    cmp al, 13     ; Enter key?
    je .done_input
    mov [di], al
    inc di
    inc cx
    mov ah, 02h
    mov dl, '*'
    int 21h
    cmp cx, 10
    jb .mask_loop
.done_input:
    mov byte ptr pass_buffer[1], cl
    jmp continue_login_validation

continue_login_validation:
    lea si, stored_user
    lea di, user_buffer + 2
    call compare_strings
    cmp ax, 0
    jne login_jump_failed

    lea si, stored_pass
    lea di, pass_buffer + 2
    call compare_strings
    cmp ax, 0
    jne login_jump_failed

    mov dx, offset login_success
    mov ah, 09h
    int 21h
    
    mov dx, offset banner_art
    mov ah, 09h
    int 21h

    ; spacing after banner
    mov dx, offset newline
    mov ah, 09h
    int 21h
    int 21h
    jmp main_menu
    

    jmp main_menu


login_jump_failed:
    jmp login_failed
    
main_menu:
    ; Print menu header
    mov dx, offset line1
    mov ah, 09h
    int 21h

    ; Print options
    mov dx, offset line2
    int 21h
    mov dx, offset line3
    int 21h
    mov dx, offset line4
    int 21h
    mov dx, offset line5
    int 21h
    mov dx, offset line6
    int 21h
    mov dx, offset line7
    int 21h
    mov dx, offset line8
    int 21h
    mov dx, offset line9
    mov ah, 09h
    int 21h

    ; Get user input
    mov ah, 01h
    int 21h
    sub al, '0'

    cmp al, 1
    jne check2
    jmp check_balance


check2:
    cmp al, 2
    jne check3
    jmp withdraw_cash

check3:
    cmp al, 3
    jne check4
    jmp cash_deposit

check4:
    cmp al, 4
    jne check5
    jmp cheque_deposit

check5:
    cmp al, 5
    jne check6
    jmp change_pin

check6:
    cmp al, 6
    jne check7
    jmp transfer_account

check7:
    cmp al, 7
    jne check8
    jmp print_receipt

check8:
    cmp al, 8
    jne main_menu
    jmp exit_program

    
check_balance:
    mov dx, offset check_balance_menu
    mov ah, 09h
    int 21h

    mov ah, 01h
    int 21h
    sub al, '0'

    cmp al, 1
    je show_savings_balance
    cmp al, 2
    je show_investment_balance
    jmp main_menu

show_savings_balance:
    mov dx, offset msg_savings_balance
    mov ah, 09h
    int 21h

    mov ax, savings_balance
    call print_number

    mov dx, offset newline
    mov ah, 09h
    int 21h

    jmp main_menu

show_investment_balance:
    mov dx, offset msg_investment_balance
    mov ah, 09h
    int 21h

    mov ax, investment_balance
    call print_number

    mov dx, offset newline
    mov ah, 09h
    int 21h

    jmp main_menu

withdraw_cash:
    ; Ask which account to withdraw from
    mov dx, offset check_balance_menu
    mov ah, 09h
    int 21h

    mov ah, 01h
    int 21h
    sub al, '0'
    cmp al, 1
    je withdraw_from_savings
    cmp al, 2
    je withdraw_from_investment
    jmp main_menu

withdraw_from_savings:
    mov si, offset savings_balance
    jmp do_withdraw

withdraw_from_investment:
    mov si, offset investment_balance
    jmp do_withdraw

do_withdraw:
    mov dx, offset msg_withdraw
    mov ah, 09h
    int 21h

    lea dx, input_buffer
    mov ah, 0Ah
    int 21h

    ; Save SI before using string_to_number
    push si

    lea si, input_buffer + 2
    call string_to_number
    mov bx, ax           ; withdrawal amount
    mov [last_transaction_amount], bx

    
    pop si               ; restore SI (which holds address of account)

    mov ax, [si]         ; load selected balance
    cmp ax, bx
    jb withdraw_insufficient

    sub ax, bx
    mov [si], ax         ; store new balance
    
    mov al, 2            ; type = 2 (withdraw)
    mov dx, 0            ; no tax for withdraw
  


    mov dx, offset msg_success
    mov ah, 09h
    int 21h
    jmp main_menu


withdraw_insufficient:
    mov dx, offset msg_insufficient
    mov ah, 09h
    int 21h
    jmp main_menu


cash_deposit:
    mov dx, offset check_balance_menu
    mov ah, 09h
    int 21h

    mov ah, 01h
    int 21h
    sub al, '0'
    cmp al, 1
    je deposit_to_savings
    cmp al, 2
    je deposit_to_investment
    jmp main_menu

deposit_to_savings:
    mov si, offset savings_balance
    jmp do_deposit

deposit_to_investment:
    mov si, offset investment_balance
    jmp do_deposit

do_deposit:
    mov dx, offset msg_deposit
    mov ah, 09h
    int 21h

    lea dx, input_buffer
    mov ah, 0Ah
    int 21h

    push si              ; save SI before call
    lea si, input_buffer + 2
    call string_to_number
    mov bx, ax ; deposit amount
    mov [last_transaction_amount], bx
    pop si ; restore SI

    mov ax, [si]
    add ax, bx
    mov [si], ax         ; update selected account
    mov al, 1            ; type = 1 (deposit)
    mov dx, 0            ; no tax for deposit
    


    mov dx, offset msg_success
    mov ah, 09h
    int 21h
    jmp main_menu

    
cheque_deposit:
    ; Ask which account to deposit into
    mov dx, offset check_balance_menu
    mov ah, 09h
    int 21h

    mov ah, 01h
    int 21h
    sub al, '0'
    cmp al, 1
    je cheque_to_savings
    cmp al, 2
    je cheque_to_investment
    jmp main_menu

cheque_to_savings:
    mov si, offset savings_balance
    jmp cheque_enter_id

cheque_to_investment:
    mov si, offset investment_balance
    jmp cheque_enter_id

cheque_enter_id:
    mov dx, offset msg_cheque_id
    mov ah, 09h
    int 21h

    lea dx, input_buffer
    mov ah, 0Ah
    int 21h

    ; Validate cheque ID length = 8
    mov al, input_buffer[1]
    cmp al, 8
    jne invalid_cheque_id

    ; Deposit RM1000 into selected account (SI points to balance)
    mov ax, [si]
    add ax, 1000
    mov [si], ax

    mov dx, offset msg_cheque_added
    mov ah, 09h
    int 21h
    jmp main_menu

invalid_cheque_id:
    mov dx, offset newline
    mov ah, 09h
    int 21h
    mov dx, offset invalid_cheque_msg
    mov ah, 09h
    int 21h
    jmp main_menu

    
change_pin:
    mov dx, offset newline
    mov ah, 09h
    int 21h

    ; Ask for current PIN
    mov dx, offset password_prompt
    mov ah, 09h
    int 21h
    lea dx, pass_buffer
    mov ah, 0Ah
    int 21h

    lea si, pass_buffer + 2
    mov bl, [pass_buffer + 1]
    add si, bx
    mov byte ptr [si], 0
    lea si, pass_buffer + 2
    call hash_pin_input
    cmp ax, stored_pin_hash
    jne wrong_pin_change

    ; Clear buffer
    mov cx, 10
    lea di, pass_buffer + 2
clear_loop1:
    mov byte ptr [di], 0
    inc di
    loop clear_loop1

    ; Ask for new PIN
    mov dx, offset msg_change_pin
    mov ah, 09h
    int 21h
    lea dx, pass_buffer
    mov ah, 0Ah
    int 21h

    lea si, pass_buffer + 2
    mov bl, [pass_buffer + 1]
    add si, bx
    mov byte ptr [si], 0
    lea si, pass_buffer + 2
    call hash_pin_input
    mov stored_pin_hash, ax

    mov dx, offset msg_pin_updated
    mov ah, 09h
    int 21h
    jmp main_menu

wrong_pin_change:
    mov dx, offset msg_wrong_pin
    mov ah, 09h
    int 21h
    jmp main_menu

transfer_account:
    ; Ask from which account to transfer
    mov dx, offset msg_transfer_from
    mov ah, 09h
    int 21h

    mov ah, 01h         ; Read single character (1 or 2)
    int 21h
    sub al, '0'
    cmp al, 1
    je set_transfer_savings
    cmp al, 2
    je set_transfer_investment
    jmp main_menu       ; Invalid input

set_transfer_savings:
    mov si, offset savings_balance
    jmp continue_transfer

set_transfer_investment:
    mov si, offset investment_balance
    jmp continue_transfer

continue_transfer:
    ; Ask for recipient account number
    mov dx, offset msg_transfer_to
    mov ah, 09h
    int 21h
    lea dx, account_number_buffer
    mov ah, 0Ah
    int 21h

    ; Ask for amount
    mov dx, offset msg_transfer_amt
    mov ah, 09h
    int 21h
    lea dx, input_buffer
    mov ah, 0Ah
    int 21h

    ; Convert amount from input buffer
    push si                 ; preserve SI which holds account address
    lea si, input_buffer + 2
    call string_to_number
    mov bx, ax              ; BX = amount to transfer
    mov [last_transaction_amount], bx
    pop si                  ; restore account pointer

    ; Calculate tax = amount * 6 / 100
    mov ax, bx              ; AX = amount
    mov cx, ax              ; CX = original amount
    mov dx, 0
    mov bx, 6
    mul bx                  ; AX = amount * 6
    mov bx, 100
    div bx                  ; AX = tax
    mov dx, ax              ; DX = tax

    ; Total to deduct = amount + tax
    mov ax, cx              ; AX = amount
    add ax, dx              ; AX = total deduction

    ; Check if account has enough balance
    mov bx, ax              ; BX = amount + tax
    mov ax, [si]
    cmp ax, bx
    jae transfer_continue_logic
    jmp not_enough_transfer
    
transfer_continue_logic:
    ; Deduct total (amount + tax)
    sub ax, bx
    mov [si], ax
    mov al, 3            ; type = 3 (transfer)
    ; BX already contains amount + tax
    ; DX already contains tax
   


    ; ?? ADD THIS BLOCK HERE
    mov al, 3                ; type: transfer
    mov bx, cx               ; cx = original amount
    ; dx = tax already set

    ; Show success message
    mov dx, offset msg_transfer_done
    mov ah, 09h
    int 21h
    jmp main_menu
   ; Appends string at SI to DI (ends with 0)
copy_str:
    push ax
.next_char:
    lodsb
    cmp al, 0
    je .done
    stosb
    jmp .next_char
.done:
    pop ax
    ret

; Converts AX to ASCII and appends to DI
append_number:
    push ax
    push bx
    push cx
    push dx
    xor cx, cx
    mov bx, 10
.conv_loop:
    xor dx, dx
    div bx
    push dx
    inc cx
    cmp ax, 0
    jne .conv_loop
.print_digits:
    pop dx
    add dl, '0'
    mov [di], dl
    inc di
    loop .print_digits
    pop dx
    pop cx
    pop bx
    pop ax
    ret

    
not_enough:
    mov dx, offset msg_insufficient
    mov ah, 09h
    int 21h
    jmp main_menu

login_failed:
    mov dx, offset login_fail
    mov ah, 09h
    int 21h
    jmp login_screen

compare_strings:
    push cx
    push si
    push di
compare_loop:
    mov al, [si]
    cmp al, '$'
    je compare_done
    cmp al, [di]
    jne not_equal
    inc si
    inc di
    jmp compare_loop
compare_done:
    cmp byte ptr [di], '$'
    jne not_equal
    xor ax, ax
    jmp cmp_end
not_equal:
    mov ax, 1
cmp_end:
    pop di
    pop si
    pop cx
    ret

print_number:
    mov cx, 0
    mov bx, 10
    
    
    
    
.next_digit:
    xor dx, dx
    div bx
    push dx
    inc cx
    cmp ax, 0
    jne .next_digit
    
print_loop:
    pop dx
    add dl, '0'
    mov ah, 02h
    int 21h
    loop print_loop
    ret

string_to_number:
    xor ax, ax
    xor cx, cx
str_loop:
    mov cl, [si]
    cmp cl, 13
    je str_done
    cmp cl, 10
    je str_done
    sub cl, '0'
    mov bx, ax
    shl ax, 1
    mov dx, ax
    shl ax, 2
    add ax, dx
    add ax, cx
    inc si
    jmp str_loop
str_done:
    ret
    
not_enough_transfer:
    mov dx, offset msg_insufficient
    mov ah, 09h
    int 21h
    jmp main_menu
    
print_receipt:
    mov dx, offset receipt_msg
    mov ah, 09h
    int 21h

    ; Show Amount
    mov dx, offset amount_msg
    mov ah, 09h
    int 21h

    mov ax, [last_transaction_amount]
    call print_number

    ; Calculate Tax (Amount * 6)
    mov dx, offset tax_msg
    mov ah, 09h
    int 21h

    mov ax, [last_transaction_amount]
    mov bx, 6
    mul bx              ; AX = AX * 6 (result in AX)
    call print_number

    jmp main_menu


exit_program:
    mov ah, 4Ch
    int 21h
    
hash_pin_input:
    xor ax, ax
    ; DS:SI must point to buffer data (pass_buffer + 2)
    ; length is at pass_buffer + 1 (1 byte)
    ; since SI = pass_buffer + 2, the length byte is at SI - 1

    mov cl, [si - 1]   ; input length from buffer
    xor ch, ch         ; clear upper byte of CX

    xor bx, bx
.hash_loop:
    mov bl, [si]
    add ax, bx
    inc si
    loop .hash_loop  
    ret


hash_done:
    ret

    ; ax = number to print blinking in green



   
    
end start
