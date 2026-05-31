[bits 16]
[org 0x8000]

BOARD_X equ 70
BOARD_Y equ 10
CELL_SIZE equ 12

DICE_X equ 260
DICE_Y equ 80

RED_START_INDEX equ 13
GREEN_START_INDEX equ 26
YELLOW_START_INDEX equ 0
BLUE_START_INDEX equ 39

active_token_dots db 0
dot_count db 0
dot_base_x dw 0
dot_base_y dw 0

cell_token_color db 0
cell_token_x db 0
cell_token_y db 0
start:
    cld

    xor ax, ax
    mov ds, ax

    ; Set VGA graphics mode 13h
    mov ax, 0x0013
    int 0x10

    ; Set ES to VGA memory
    mov ax, 0xA000
    mov es, ax

    mov byte [dice_value], 0

    call draw_full_screen

main_loop:
    ; If game is over, only allow ESC
    mov al, [game_over]
    cmp al, 1
    je game_over_loop

    ; Wait for key press
    mov ah, 0x00
    int 0x16

    ; D or d = roll dice
    cmp al, 'D'
    je roll_key
    cmp al, 'd'
    je roll_key

    ; 1-4 = move current player's tokens
    cmp al, '1'
    je select_token_1

    cmp al, '2'
    je select_token_2

    cmp al, '3'
    je select_token_3

    cmp al, '4'
    je select_token_4

    ; ESC = stop
    cmp al, 27
    je stop_game

    ; ESC = stop
    cmp al, 27
    je stop_game

    jmp main_loop

game_over_loop:
    mov ah, 0x00
    int 0x16

    cmp al, 27
    je stop_game

    jmp game_over_loop


roll_key:
    ; If dice is already available, do not roll again
    mov al, [dice_available]
    cmp al, 1
    je main_loop

    call roll_dice
    mov byte [dice_available], 1
    call draw_dice

    ; Check only current player's valid moves
    call current_player_has_valid_move
    cmp al, 1
    je main_loop

    ; No valid move available, pass turn
    call consume_dice
    call next_player
    call draw_full_screen
    jmp main_loop
    
; -----------------------------------------
; Current player token selection
; current_player:
; 0 = Red
; 1 = Green
; 2 = Blue
; 3 = Yellow
; -----------------------------------------

select_token_1:
    mov al, [current_player]

    cmp al, 0
    je .red
    cmp al, 1
    je .green
    cmp al, 2
    je .blue
    cmp al, 3
    je .yellow

.red:
    mov si, red_token_1_progress
    call move_red_token_by_si
    jmp main_loop

.green:
    mov si, green_token_1_progress
    call move_red_token_by_si
    jmp main_loop

.blue:
    mov si, blue_token_1_progress
    call move_red_token_by_si
    jmp main_loop

.yellow:
    mov si, yellow_token_1_progress
    call move_red_token_by_si
    jmp main_loop


select_token_2:
    mov al, [current_player]

    cmp al, 0
    je .red
    cmp al, 1
    je .green
    cmp al, 2
    je .blue
    cmp al, 3
    je .yellow

.red:
    mov si, red_token_2_progress
    call move_red_token_by_si
    jmp main_loop

.green:
    mov si, green_token_2_progress
    call move_red_token_by_si
    jmp main_loop

.blue:
    mov si, blue_token_2_progress
    call move_red_token_by_si
    jmp main_loop

.yellow:
    mov si, yellow_token_2_progress
    call move_red_token_by_si
    jmp main_loop


select_token_3:
    mov al, [current_player]

    cmp al, 0
    je .red
    cmp al, 1
    je .green
    cmp al, 2
    je .blue
    cmp al, 3
    je .yellow

.red:
    mov si, red_token_3_progress
    call move_red_token_by_si
    jmp main_loop

.green:
    mov si, green_token_3_progress
    call move_red_token_by_si
    jmp main_loop

.blue:
    mov si, blue_token_3_progress
    call move_red_token_by_si
    jmp main_loop

.yellow:
    mov si, yellow_token_3_progress
    call move_red_token_by_si
    jmp main_loop


select_token_4:
    mov al, [current_player]

    cmp al, 0
    je .red
    cmp al, 1
    je .green
    cmp al, 2
    je .blue
    cmp al, 3
    je .yellow

.red:
    mov si, red_token_4_progress
    call move_red_token_by_si
    jmp main_loop

.green:
    mov si, green_token_4_progress
    call move_red_token_by_si
    jmp main_loop

.blue:
    mov si, blue_token_4_progress
    call move_red_token_by_si
    jmp main_loop

.yellow:
    mov si, yellow_token_4_progress
    call move_red_token_by_si
    jmp main_loop

; -----------------------------------------
; Red token movement wrappers
; -----------------------------------------
move_red_token_1:
    mov si, red_token_1_progress
    call move_red_token_by_si
    jmp main_loop

move_red_token_2:
    mov si, red_token_2_progress
    call move_red_token_by_si
    jmp main_loop

move_red_token_3:
    mov si, red_token_3_progress
    call move_red_token_by_si
    jmp main_loop

move_red_token_4:
    mov si, red_token_4_progress
    call move_red_token_by_si
    jmp main_loop


; -----------------------------------------
; Green token movement wrappers
; Temporary controls:
; 5 = Green Token 1
; 6 = Green Token 2
; 7 = Green Token 3
; 8 = Green Token 4
; -----------------------------------------
move_green_token_1:
    mov si, green_token_1_progress
    call move_red_token_by_si
    jmp main_loop

move_green_token_2:
    mov si, green_token_2_progress
    call move_red_token_by_si
    jmp main_loop

move_green_token_3:
    mov si, green_token_3_progress
    call move_red_token_by_si
    jmp main_loop

move_green_token_4:
    mov si, green_token_4_progress
    call move_red_token_by_si
    jmp main_loop

; -----------------------------------------
; Yellow token movement wrappers
; Temporary controls:
; Q = Yellow Token 1
; W = Yellow Token 2
; E = Yellow Token 3
; R = Yellow Token 4
; -----------------------------------------
move_yellow_token_1:
    mov si, yellow_token_1_progress
    call move_red_token_by_si
    jmp main_loop

move_yellow_token_2:
    mov si, yellow_token_2_progress
    call move_red_token_by_si
    jmp main_loop

move_yellow_token_3:
    mov si, yellow_token_3_progress
    call move_red_token_by_si
    jmp main_loop

move_yellow_token_4:
    mov si, yellow_token_4_progress
    call move_red_token_by_si
    jmp main_loop


; -----------------------------------------
; Blue token movement wrappers
; Temporary controls:
; A = Blue Token 1
; S = Blue Token 2
; F = Blue Token 3
; G = Blue Token 4
; -----------------------------------------
move_blue_token_1:
    mov si, blue_token_1_progress
    call move_red_token_by_si
    jmp main_loop

move_blue_token_2:
    mov si, blue_token_2_progress
    call move_red_token_by_si
    jmp main_loop

move_blue_token_3:
    mov si, blue_token_3_progress
    call move_red_token_by_si
    jmp main_loop

move_blue_token_4:
    mov si, blue_token_4_progress
    call move_red_token_by_si
    jmp main_loop

; -----------------------------------------
; move_red_token_by_si
; input:
; SI = address of selected token progress
;
; Rules:
; 1. Token can move only after fresh dice roll
; 2. Home token can leave only on dice 6
; 3. Unlocking a token consumes the dice
; 4. Already-out token moves by dice value
; -----------------------------------------
move_red_token_by_si:
    ; Check if dice is available
    mov al, [dice_available]
    cmp al, 1
    jne .invalid_move

    ; Check if selected token is at home
    mov al, [si]
    cmp al, 255
    jne .already_out

    ; If token is home, dice must be 6
    mov al, [dice_value]
    cmp al, 6
    jne .invalid_move

    ; Dice is 6 and token is home:
    ; Bring token only to starting position
    mov byte [si], 0

    jmp .successful_move


.already_out:
    ; Token is already on board, so move by dice value
    mov al, [si]
    add al, [dice_value]

    ; Token can move up to progress 56 only
    ; 0-50  = main path
    ; 51-55 = home lane
    ; 56    = finished/final cell
    cmp al, 56
    ja .invalid_move

    mov [si], al

    jmp .successful_move


.successful_move:

    call handle_capture_for_current_move
    ; Save dice before clearing it
    mov al, [dice_value]
    mov [last_dice], al

    ; Consume dice after successful move
    call consume_dice

    ; Check if current player has won
    call check_current_player_winner
    cmp al, 1
    je .player_won


.turn_logic:
    ; Capture gives one extra turn
    cmp byte [capture_happened], 1
    je .same_player_turn

    ; Dice 6 also gives one extra turn
    mov al, [last_dice]
    cmp al, 6
    je .same_player_turn

    ; No capture and dice was not 6, pass turn
    call next_player

.same_player_turn:
    call draw_full_screen
    ret

.player_won:
    ; Current player has finished
    call mark_current_player_finished

    ; If 3 players have finished, the remaining player is 4th
    cmp byte [finished_player_count], 3
    je .show_final_results

    ; Otherwise continue with next unfinished player
    call next_player
    call draw_full_screen
    ret


.show_final_results:
    call find_fourth_place
    mov byte [game_over], 1
    call draw_final_result_screen
    ret


.all_players_finished:
    mov byte [game_over], 1
    call draw_full_screen
    ret


.invalid_move:
    ; Invalid token selection does not consume dice
    ret

; -----------------------------------------
; consume_dice
; Marks dice as used and clears dice display value
; -----------------------------------------
consume_dice:
    mov byte [dice_available], 0
    mov byte [dice_value], 0
    ret

; -----------------------------------------
; red_has_valid_move
; output:
; AL = 1 if at least one Red token can move
; AL = 0 if no Red token can move
;
; Rules checked:
; 1. Home token can move only if dice is 6
; 2. Out token can move only if progress + dice <= 57
; -----------------------------------------
red_has_valid_move:
    ; Check token 1
    mov si, red_token_1_progress
    call check_one_red_token_valid
    cmp al, 1
    je .yes

    ; Check token 2
    mov si, red_token_2_progress
    call check_one_red_token_valid
    cmp al, 1
    je .yes

    ; Check token 3
    mov si, red_token_3_progress
    call check_one_red_token_valid
    cmp al, 1
    je .yes

    ; Check token 4
    mov si, red_token_4_progress
    call check_one_red_token_valid
    cmp al, 1
    je .yes

    ; No token can move
    mov al, 0
    ret

.yes:
    mov al, 1
    ret


; -----------------------------------------
; check_one_red_token_valid
; input:
; SI = token progress address
; output:
; AL = 1 valid
; AL = 0 invalid
; -----------------------------------------
check_one_red_token_valid:
    ; If token is home
    mov al, [si]
    cmp al, 255
    jne .already_out

    ; Home token can move only on dice 6
    mov al, [dice_value]
    cmp al, 6
    je .valid

    mov al, 0
    ret

.already_out:
    ; Finished token cannot move
    mov al, [si]
    cmp al, 57
    je .invalid

    ; Check progress + dice <= 57
    mov al, [si]
    add al, [dice_value]
    cmp al, 56
    ja .invalid

.valid:
    mov al, 1
    ret

.invalid:
    mov al, 0
    ret

; -----------------------------------------
; check_red_winner
; output:
; AL = 1 if all 4 Red tokens are finished
; AL = 0 otherwise
; -----------------------------------------
check_red_winner:
    mov al, [red_token_1_progress]
    cmp al, 56
    jne .no

    mov al, [red_token_2_progress]
    cmp al, 56
    jne .no

    mov al, [red_token_3_progress]
    cmp al, 56
    jne .no

    mov al, [red_token_4_progress]
    cmp al, 56
    jne .no

    mov al, 1
    ret

.no:
    mov al, 0
    ret


; -----------------------------------------
; draw_red_win_screen
; Simple graphics victory screen for Red
; -----------------------------------------
draw_red_win_screen:
    ; Fill screen with red
    xor di, di
    mov al, 4
    mov cx, 64000
    rep stosb

    ; White center panel
    mov bx, 90
    mov dx, 60
    mov si, 140
    mov bp, 80
    mov al, 15
    call draw_rect

    ; Red tokens inside panel
    mov bx, 125
    mov dx, 85
    mov al, 4
    call draw_token

    mov bx, 155
    mov dx, 85
    mov al, 4
    call draw_token

    mov bx, 125
    mov dx, 110
    mov al, 4
    call draw_token

    mov bx, 155
    mov dx, 110
    mov al, 4
    call draw_token

    ret


; -----------------------------------------
; red_or_green_has_valid_move
; output:
; AL = 1 if Red or Green has at least one valid move
; AL = 0 if neither can move
; -----------------------------------------
red_or_green_has_valid_move:
    call red_has_valid_move
    cmp al, 1
    je .yes

    call green_has_valid_move
    cmp al, 1
    je .yes

    mov al, 0
    ret

.yes:
    mov al, 1
    ret

; -----------------------------------------
; green_has_valid_move
; output:
; AL = 1 if at least one Green token can move
; AL = 0 if no Green token can move
; -----------------------------------------
green_has_valid_move:
    mov si, green_token_1_progress
    call check_one_red_token_valid
    cmp al, 1
    je .yes

    mov si, green_token_2_progress
    call check_one_red_token_valid
    cmp al, 1
    je .yes

    mov si, green_token_3_progress
    call check_one_red_token_valid
    cmp al, 1
    je .yes

    mov si, green_token_4_progress
    call check_one_red_token_valid
    cmp al, 1
    je .yes

    mov al, 0
    ret

.yes:
    mov al, 1
    ret

; -----------------------------------------
; red_green_yellow_has_valid_move
; output:
; AL = 1 if any Red/Green/Yellow token can move
; AL = 0 if none can move
; -----------------------------------------
red_green_yellow_has_valid_move:
    call red_has_valid_move
    cmp al, 1
    je .yes

    call green_has_valid_move
    cmp al, 1
    je .yes

    call yellow_has_valid_move
    cmp al, 1
    je .yes

    mov al, 0
    ret

.yes:
    mov al, 1
    ret


; -----------------------------------------
; yellow_has_valid_move
; output:
; AL = 1 if at least one Yellow token can move
; AL = 0 if no Yellow token can move
; -----------------------------------------
yellow_has_valid_move:
    mov si, yellow_token_1_progress
    call check_one_red_token_valid
    cmp al, 1
    je .yes

    mov si, yellow_token_2_progress
    call check_one_red_token_valid
    cmp al, 1
    je .yes

    mov si, yellow_token_3_progress
    call check_one_red_token_valid
    cmp al, 1
    je .yes

    mov si, yellow_token_4_progress
    call check_one_red_token_valid
    cmp al, 1
    je .yes

    mov al, 0
    ret

.yes:
    mov al, 1
    ret


; -----------------------------------------
; any_player_has_valid_move
; output:
; AL = 1 if any token from any color can move
; AL = 0 if no token can move
; -----------------------------------------
any_player_has_valid_move:
    call red_has_valid_move
    cmp al, 1
    je .yes

    call green_has_valid_move
    cmp al, 1
    je .yes

    call yellow_has_valid_move
    cmp al, 1
    je .yes

    call blue_has_valid_move
    cmp al, 1
    je .yes

    mov al, 0
    ret

.yes:
    mov al, 1
    ret


; -----------------------------------------
; blue_has_valid_move
; output:
; AL = 1 if at least one Blue token can move
; AL = 0 if no Blue token can move
; -----------------------------------------
blue_has_valid_move:
    mov si, blue_token_1_progress
    call check_one_red_token_valid
    cmp al, 1
    je .yes

    mov si, blue_token_2_progress
    call check_one_red_token_valid
    cmp al, 1
    je .yes

    mov si, blue_token_3_progress
    call check_one_red_token_valid
    cmp al, 1
    je .yes

    mov si, blue_token_4_progress
    call check_one_red_token_valid
    cmp al, 1
    je .yes

    mov al, 0
    ret

.yes:
    mov al, 1
    ret


; -----------------------------------------
; next_player
; Turn order:
; Red -> Green -> Blue -> Yellow -> Red
;
; Skips players who have already finished.
; -----------------------------------------
next_player:
    mov byte [next_player_checks], 0

.next_try:
    inc byte [current_player]

    cmp byte [current_player], 4
    jb .check_player

    mov byte [current_player], 0

.check_player:
    inc byte [next_player_checks]

    call current_player_is_finished
    cmp al, 0
    je .done

    cmp byte [next_player_checks], 4
    jb .next_try

    ; All players are finished
    mov byte [game_over], 1

.done:
    ret
; -----------------------------------------
; current_player_has_valid_move
; output:
; AL = 1 if current player has a valid move
; AL = 0 if current player has no valid move
;
; current_player:
; 0 = Red
; 1 = Green
; 2 = Blue
; 3 = Yellow
; -----------------------------------------
current_player_has_valid_move:
    mov al, [current_player]

    cmp al, 0
    je .red

    cmp al, 1
    je .green

    cmp al, 2
    je .blue

    cmp al, 3
    je .yellow

.red:
    call red_has_valid_move
    ret

.green:
    call green_has_valid_move
    ret

.blue:
    call blue_has_valid_move
    ret

.yellow:
    call yellow_has_valid_move
    ret

; -----------------------------------------
; check_current_player_winner
; output:
; AL = 1 if current player has won
; AL = 0 if not
;
; current_player:
; 0 = Red
; 1 = Green
; 2 = Blue
; 3 = Yellow
; -----------------------------------------
check_current_player_winner:
    mov al, [current_player]

    cmp al, 0
    je .red

    cmp al, 1
    je .green

    cmp al, 2
    je .blue

    cmp al, 3
    je .yellow

.red:
    call check_red_winner
    ret

.green:
    call check_green_winner
    ret

.blue:
    call check_blue_winner
    ret

.yellow:
    call check_yellow_winner
    ret



; -----------------------------------------
; Green winner check
; -----------------------------------------
check_green_winner:
    mov al, [green_token_1_progress]
    cmp al, 56
    jne .no

    mov al, [green_token_2_progress]
    cmp al, 56
    jne .no

    mov al, [green_token_3_progress]
    cmp al, 56
    jne .no

    mov al, [green_token_4_progress]
    cmp al, 56
    jne .no

    mov al, 1
    ret

.no:
    mov al, 0
    ret


; -----------------------------------------
; Blue winner check
; -----------------------------------------
check_blue_winner:
    mov al, [blue_token_1_progress]
    cmp al, 56
    jne .no

    mov al, [blue_token_2_progress]
    cmp al, 56
    jne .no

    mov al, [blue_token_3_progress]
    cmp al, 56
    jne .no

    mov al, [blue_token_4_progress]
    cmp al, 56
    jne .no

    mov al, 1
    ret

.no:
    mov al, 0
    ret


; -----------------------------------------
; Yellow winner check
; -----------------------------------------
check_yellow_winner:
    mov al, [yellow_token_1_progress]
    cmp al, 56
    jne .no

    mov al, [yellow_token_2_progress]
    cmp al, 56
    jne .no

    mov al, [yellow_token_3_progress]
    cmp al, 56
    jne .no

    mov al, [yellow_token_4_progress]
    cmp al, 56
    jne .no

    mov al, 1
    ret

.no:
    mov al, 0
    ret

; -----------------------------------------
; draw_current_player_win_screen
; Shows winner screen based on current_player
; -----------------------------------------
draw_current_player_win_screen:
    mov al, [current_player]

    cmp al, 0
    je .red

    cmp al, 1
    je .green

    cmp al, 2
    je .blue

    cmp al, 3
    je .yellow

.red:
    mov byte [win_color], 4
    jmp .draw

.green:
    mov byte [win_color], 2
    jmp .draw

.blue:
    mov byte [win_color], 1
    jmp .draw

.yellow:
    mov byte [win_color], 14


.draw:
    ; Full screen winner color
    mov bx, 0
    mov dx, 0
    mov si, 320
    mov bp, 200
    mov al, [win_color]
    call draw_rect

    ; White center panel
    mov bx, 70
    mov dx, 50
    mov si, 180
    mov bp, 100
    mov al, 15
    call draw_rect

    ; Winner color block inside panel
    mov bx, 105
    mov dx, 75
    mov si, 110
    mov bp, 50
    mov al, [win_color]
    call draw_rect

    ; Four winner tokens
    mov bx, 120
    mov dx, 88
    mov al, [win_color]
    mov cl, 1
    call draw_token_with_dots

    mov bx, 145
    mov dx, 88
    mov al, [win_color]
    mov cl, 2
    call draw_token_with_dots

    mov bx, 170
    mov dx, 88
    mov al, [win_color]
    mov cl, 3
    call draw_token_with_dots

    mov bx, 195
    mov dx, 88
    mov al, [win_color]
    mov cl, 4
    call draw_token_with_dots

    ret    

; -----------------------------------------
; current_player_is_finished
; output:
; AL = 1 if current player has already finished
; AL = 0 if current player is still playing
; -----------------------------------------
current_player_is_finished:
    mov al, [current_player]

    cmp al, 0
    je .red

    cmp al, 1
    je .green

    cmp al, 2
    je .blue

    cmp al, 3
    je .yellow

.red:
    mov al, [red_finished]
    ret

.green:
    mov al, [green_finished]
    ret

.blue:
    mov al, [blue_finished]
    ret

.yellow:
    mov al, [yellow_finished]
    ret

; -----------------------------------------
; mark_current_player_finished
; Marks current player as finished/winner.
; Also stores finishing rank.
;
; current_player:
; 0 = Red
; 1 = Green
; 2 = Blue
; 3 = Yellow
; -----------------------------------------
mark_current_player_finished:
    mov al, [current_player]

    cmp al, 0
    je .red

    cmp al, 1
    je .green

    cmp al, 2
    je .blue

    cmp al, 3
    je .yellow


.red:
    cmp byte [red_finished], 1
    je .done

    mov byte [red_finished], 1
    jmp .store_rank


.green:
    cmp byte [green_finished], 1
    je .done

    mov byte [green_finished], 1
    jmp .store_rank


.blue:
    cmp byte [blue_finished], 1
    je .done

    mov byte [blue_finished], 1
    jmp .store_rank


.yellow:
    cmp byte [yellow_finished], 1
    je .done

    mov byte [yellow_finished], 1
    jmp .store_rank


.store_rank:
    ; finished_player_count is still old value here
    ; 0 means this player is 1st
    ; 1 means this player is 2nd
    ; 2 means this player is 3rd

    mov al, [finished_player_count]

    cmp al, 0
    je .first

    cmp al, 1
    je .second

    cmp al, 2
    je .third

    jmp .increase_count


.first:
    mov al, [current_player]
    mov [first_place], al
    jmp .increase_count


.second:
    mov al, [current_player]
    mov [second_place], al
    jmp .increase_count


.third:
    mov al, [current_player]
    mov [third_place], al
    jmp .increase_count


.increase_count:
    inc byte [finished_player_count]

.done:
    ret

; -----------------------------------------
; find_fourth_place
; The player who has not finished after 3 players
; becomes 4th place automatically.
; -----------------------------------------
find_fourth_place:
    cmp byte [red_finished], 0
    je .red

    cmp byte [green_finished], 0
    je .green

    cmp byte [blue_finished], 0
    je .blue

    cmp byte [yellow_finished], 0
    je .yellow

    ret


.red:
    mov byte [fourth_place], 0
    ret


.green:
    mov byte [fourth_place], 1
    ret


.blue:
    mov byte [fourth_place], 2
    ret


.yellow:
    mov byte [fourth_place], 3
    ret

; -----------------------------------------
; get_player_color
; input:
; AL = player id
;      0 = Red
;      1 = Green
;      2 = Blue
;      3 = Yellow
;
; output:
; AL = VGA color
; -----------------------------------------
get_player_color:
    cmp al, 0
    je .red

    cmp al, 1
    je .green

    cmp al, 2
    je .blue

    cmp al, 3
    je .yellow

    mov al, 15
    ret


.red:
    mov al, 4
    ret


.green:
    mov al, 2
    ret


.blue:
    mov al, 1
    ret


.yellow:
    mov al, 14
    ret


; -----------------------------------------
; draw_final_result_screen
; Shows 1st, 2nd, 3rd, 4th place using rows.
;
; Row 1 = first_place
; Row 2 = second_place
; Row 3 = third_place
; Row 4 = fourth_place
; -----------------------------------------
draw_final_result_screen:
    ; Clear screen black
    mov bx, 0
    mov dx, 0
    mov si, 320
    mov bp, 200
    mov al, 0
    call draw_rect

    ; White panel
    mov bx, 45
    mov dx, 20
    mov si, 230
    mov bp, 160
    mov al, 15
    call draw_rect

    ; Black border/header area
    mov bx, 55
    mov dx, 28
    mov si, 210
    mov bp, 18
    mov al, 0
    call draw_rect

    ; -------------------------
    ; 1st place row
    ; -------------------------
    mov al, [first_place]
    call get_player_color
    mov [result_color], al

    mov bx, 75
    mov dx, 58
    mov si, 170
    mov bp, 22
    mov al, [result_color]
    call draw_rect

    ; Rank marker: 1 black block
    mov bx, 58
    mov dx, 64
    mov si, 5
    mov bp, 5
    mov al, 0
    call draw_rect

    ; Winner tokens
    mov bx, 100
    mov dx, 64
    mov al, [result_color]
    mov cl, 1
    call draw_token_with_dots

    mov bx, 125
    mov dx, 64
    mov al, [result_color]
    mov cl, 2
    call draw_token_with_dots

    mov bx, 150
    mov dx, 64
    mov al, [result_color]
    mov cl, 3
    call draw_token_with_dots

    mov bx, 175
    mov dx, 64
    mov al, [result_color]
    mov cl, 4
    call draw_token_with_dots


    ; -------------------------
    ; 2nd place row
    ; -------------------------
    mov al, [second_place]
    call get_player_color
    mov [result_color], al

    mov bx, 75
    mov dx, 90
    mov si, 170
    mov bp, 22
    mov al, [result_color]
    call draw_rect

    ; Rank marker: 2 black blocks
    mov bx, 58
    mov dx, 93
    mov si, 5
    mov bp, 5
    mov al, 0
    call draw_rect

    mov bx, 58
    mov dx, 102
    mov si, 5
    mov bp, 5
    mov al, 0
    call draw_rect

    mov bx, 100
    mov dx, 96
    mov al, [result_color]
    mov cl, 1
    call draw_token_with_dots

    mov bx, 125
    mov dx, 96
    mov al, [result_color]
    mov cl, 2
    call draw_token_with_dots

    mov bx, 150
    mov dx, 96
    mov al, [result_color]
    mov cl, 3
    call draw_token_with_dots

    mov bx, 175
    mov dx, 96
    mov al, [result_color]
    mov cl, 4
    call draw_token_with_dots


    ; -------------------------
    ; 3rd place row
    ; -------------------------
    mov al, [third_place]
    call get_player_color
    mov [result_color], al

    mov bx, 75
    mov dx, 122
    mov si, 170
    mov bp, 22
    mov al, [result_color]
    call draw_rect

    ; Rank marker: 3 black blocks
    mov bx, 58
    mov dx, 124
    mov si, 5
    mov bp, 5
    mov al, 0
    call draw_rect

    mov bx, 58
    mov dx, 132
    mov si, 5
    mov bp, 5
    mov al, 0
    call draw_rect

    mov bx, 58
    mov dx, 140
    mov si, 5
    mov bp, 5
    mov al, 0
    call draw_rect

    mov bx, 100
    mov dx, 128
    mov al, [result_color]
    mov cl, 1
    call draw_token_with_dots

    mov bx, 125
    mov dx, 128
    mov al, [result_color]
    mov cl, 2
    call draw_token_with_dots

    mov bx, 150
    mov dx, 128
    mov al, [result_color]
    mov cl, 3
    call draw_token_with_dots

    mov bx, 175
    mov dx, 128
    mov al, [result_color]
    mov cl, 4
    call draw_token_with_dots


    ; -------------------------
    ; 4th place row
    ; -------------------------
    mov al, [fourth_place]
    call get_player_color
    mov [result_color], al

    mov bx, 75
    mov dx, 154
    mov si, 170
    mov bp, 22
    mov al, [result_color]
    call draw_rect

    ; Rank marker: 4 black blocks
    mov bx, 58
    mov dx, 155
    mov si, 5
    mov bp, 5
    mov al, 0
    call draw_rect

    mov bx, 58
    mov dx, 161
    mov si, 5
    mov bp, 5
    mov al, 0
    call draw_rect

    mov bx, 58
    mov dx, 167
    mov si, 5
    mov bp, 5
    mov al, 0
    call draw_rect

    mov bx, 58
    mov dx, 173
    mov si, 5
    mov bp, 5
    mov al, 0
    call draw_rect

    mov bx, 100
    mov dx, 160
    mov al, [result_color]
    mov cl, 1
    call draw_token_with_dots

    mov bx, 125
    mov dx, 160
    mov al, [result_color]
    mov cl, 2
    call draw_token_with_dots

    mov bx, 150
    mov dx, 160
    mov al, [result_color]
    mov cl, 3
    call draw_token_with_dots

    mov bx, 175
    mov dx, 160
    mov al, [result_color]
    mov cl, 4
    call draw_token_with_dots

    ret

; -----------------------------------------
; compute_current_capture_path_index
; input:
; AL = current player's token progress
;
; output:
; capture_path_index = absolute main path index
;
; current_player:
; 0 = Red
; 1 = Green
; 2 = Blue
; 3 = Yellow
; -----------------------------------------
compute_current_capture_path_index:
    mov bl, al

    mov al, [current_player]

    cmp al, 0
    je .red

    cmp al, 1
    je .green

    cmp al, 2
    je .blue

    cmp al, 3
    je .yellow


.red:
    mov al, bl
    add al, RED_START_INDEX
    jmp .wrap


.green:
    mov al, bl
    add al, GREEN_START_INDEX
    jmp .wrap


.blue:
    mov al, bl
    add al, BLUE_START_INDEX
    jmp .wrap


.yellow:
    mov al, bl
    add al, YELLOW_START_INDEX


.wrap:
    cmp al, 52
    jb .save

    sub al, 52


.save:
    mov [capture_path_index], al
    ret


; -----------------------------------------
; capture_path_is_safe
; output:
; AL = 1 if capture cell is safe
; AL = 0 if capture cell is not safe
;
; 8 safe cells:
; 0, 8, 13, 21, 26, 34, 39, 47
; -----------------------------------------
capture_path_is_safe:
    mov al, [capture_path_index]

    ; Yellow safe cells
    cmp al, YELLOW_START_INDEX
    je .safe

    cmp al, YELLOW_SAFE_2
    je .safe

    ; Red safe cells
    cmp al, RED_START_INDEX
    je .safe

    cmp al, RED_SAFE_2
    je .safe

    ; Green safe cells
    cmp al, GREEN_START_INDEX
    je .safe

    cmp al, GREEN_SAFE_2
    je .safe

    ; Blue safe cells
    cmp al, BLUE_START_INDEX
    je .safe

    cmp al, BLUE_SAFE_2
    je .safe

    mov al, 0
    ret


.safe:
    mov al, 1
    ret

; -----------------------------------------
; capture_target_token
; input:
; SI = opponent token progress variable
; BL = opponent start index
;
; If opponent token is on the same non-safe path cell,
; send it back home.
; -----------------------------------------
capture_target_token:
    mov al, [si]

    ; Only main path tokens can be captured
    ; 0-50 = main path
    ; 51+  = home lane, finished, or home 255
    cmp al, 51
    jae .done

    ; Convert opponent progress to absolute path index
    add al, bl

    cmp al, 52
    jb .index_ready

    sub al, 52


.index_ready:
    cmp al, [capture_path_index]
    jne .done

    ; Capture opponent token
    mov byte [si], 255
    mov byte [capture_happened], 1


.done:
    ret

; -----------------------------------------
; Capture Red tokens
; -----------------------------------------
capture_red_tokens:
    mov bl, RED_START_INDEX

    mov si, red_token_1_progress
    call capture_target_token

    mov si, red_token_2_progress
    call capture_target_token

    mov si, red_token_3_progress
    call capture_target_token

    mov si, red_token_4_progress
    call capture_target_token

    ret


; -----------------------------------------
; Capture Green tokens
; -----------------------------------------
capture_green_tokens:
    mov bl, GREEN_START_INDEX

    mov si, green_token_1_progress
    call capture_target_token

    mov si, green_token_2_progress
    call capture_target_token

    mov si, green_token_3_progress
    call capture_target_token

    mov si, green_token_4_progress
    call capture_target_token

    ret


; -----------------------------------------
; Capture Blue tokens
; -----------------------------------------
capture_blue_tokens:
    mov bl, BLUE_START_INDEX

    mov si, blue_token_1_progress
    call capture_target_token

    mov si, blue_token_2_progress
    call capture_target_token

    mov si, blue_token_3_progress
    call capture_target_token

    mov si, blue_token_4_progress
    call capture_target_token

    ret


; -----------------------------------------
; Capture Yellow tokens
; -----------------------------------------
capture_yellow_tokens:
    mov bl, YELLOW_START_INDEX

    mov si, yellow_token_1_progress
    call capture_target_token

    mov si, yellow_token_2_progress
    call capture_target_token

    mov si, yellow_token_3_progress
    call capture_target_token

    mov si, yellow_token_4_progress
    call capture_target_token

    ret


; -----------------------------------------
; handle_capture_for_current_move
; input:
; SI = current moved token progress variable
;
; Captures opponent tokens if current token lands
; on the same non-safe main path cell.
; -----------------------------------------
handle_capture_for_current_move:
    
    mov byte [capture_happened], 0
    mov al, [si]

    ; Capture only happens on main path
    cmp al, 51
    jae .done

    ; Get current moved token's absolute path index
    call compute_current_capture_path_index

    ; No capture on safe cells
    call capture_path_is_safe
    cmp al, 1
    je .done

    ; Capture opponents only, not own color
    mov al, [current_player]

    cmp al, 0
    je .current_red

    cmp al, 1
    je .current_green

    cmp al, 2
    je .current_blue

    cmp al, 3
    je .current_yellow


.current_red:
    call capture_green_tokens
    call capture_blue_tokens
    call capture_yellow_tokens
    ret


.current_green:
    call capture_red_tokens
    call capture_blue_tokens
    call capture_yellow_tokens
    ret


.current_blue:
    call capture_red_tokens
    call capture_green_tokens
    call capture_yellow_tokens
    ret


.current_yellow:
    call capture_red_tokens
    call capture_green_tokens
    call capture_blue_tokens
    ret


.done:
    ret


stop_game:
    ; Return to text mode
    mov ax, 0x0003
    int 0x10

hang:
    hlt
    jmp hang

; -----------------------------------------
; draw_current_player_indicator
; Shows whose turn it is using a color box
;
; current_player:
; 0 = Red
; 1 = Green
; 2 = Blue
; 3 = Yellow
; -----------------------------------------
draw_current_player_indicator:
    ; Black outer box
    mov bx, 260
    mov dx, 25
    mov si, 42
    mov bp, 42
    mov al, 0
    call draw_rect

    ; Choose color based on current_player
    mov al, [current_player]

    cmp al, 0
    je .red

    cmp al, 1
    je .green

    cmp al, 2
    je .blue

    cmp al, 3
    je .yellow

.red:
    mov al, 4
    jmp .draw

.green:
    mov al, 2
    jmp .draw

.blue:
    mov al, 1
    jmp .draw

.yellow:
    mov al, 14

.draw:
    ; Inner color box
    mov bx, 264
    mov dx, 29
    mov si, 34
    mov bp, 34
    call draw_rect

    ret

; -----------------------------------------
; reset_token_stack
; Clears token stack tracking for the new frame
; -----------------------------------------
reset_token_stack:
    mov byte [token_stack_count], 0
    ret


; -----------------------------------------
; register_token_cell
; input:
; BL = board cell X
; BH = board cell Y
;
; This counts how many tokens are on each cell.
; -----------------------------------------
register_token_cell:
    mov [stack_cell_x], bl
    mov [stack_cell_y], bh

    xor cx, cx
    mov cl, [token_stack_count]
    xor si, si

.search_loop:
    cmp si, cx
    jae .new_cell

    mov al, [token_stack_x + si]
    cmp al, [stack_cell_x]
    jne .next_entry

    mov al, [token_stack_y + si]
    cmp al, [stack_cell_y]
    jne .next_entry

    ; Same cell found, increase total count
    inc byte [token_stack_slots + si]
    ret

.next_entry:
    inc si
    jmp .search_loop

.new_cell:
    mov al, [token_stack_count]
    cmp al, 64
    jae .done

    xor ah, ah
    mov si, ax

    mov al, [stack_cell_x]
    mov [token_stack_x + si], al

    mov al, [stack_cell_y]
    mov [token_stack_y + si], al

    ; total tokens on this cell = 1
    mov byte [token_stack_slots + si], 1

    ; drawn tokens on this cell = 0
    mov byte [token_stack_drawn + si], 0

    inc byte [token_stack_count]

.done:
    ret


; -----------------------------------------
; find_stack_info_for_cell
; input:
; BL = board cell X
; BH = board cell Y
;
; output:
; AL = total tokens on this cell
; CL = drawing slot for this token
; -----------------------------------------
find_stack_info_for_cell:
    mov [stack_cell_x], bl
    mov [stack_cell_y], bh

    xor cx, cx
    mov cl, [token_stack_count]
    xor si, si

.search_loop:
    cmp si, cx
    jae .fallback

    mov al, [token_stack_x + si]
    cmp al, [stack_cell_x]
    jne .next_entry

    mov al, [token_stack_y + si]
    cmp al, [stack_cell_y]
    jne .next_entry

    ; Found cell
    mov al, [token_stack_slots + si]
    mov [stack_total], al

    mov cl, [token_stack_drawn + si]

    ; Max visible slots = 4
    cmp cl, 4
    jb .slot_ok

    mov cl, 3

.slot_ok:
    inc byte [token_stack_drawn + si]

    mov al, [stack_total]
    ret

.next_entry:
    inc si
    jmp .search_loop

.fallback:
    mov al, 1
    mov cl, 0
    ret


; -----------------------------------------
; Draw complete screen
; -----------------------------------------
draw_full_screen:
    call clear_screen
    call draw_board_base
    call draw_main_path
    call draw_safe_cells
    call draw_home_lanes
    call draw_center_box
    call reset_token_stack
    call prepare_token_stacks
    call draw_all_tokens
    call draw_dice
    call draw_current_player_indicator
    ret


; -----------------------------------------
; Clear screen with gray color
; -----------------------------------------
clear_screen:
    xor di, di
    mov al, 7
    mov cx, 64000
    rep stosb
    ret


; -----------------------------------------
; Roll dice from 1 to 6
; Uses BIOS timer for pseudo-random value
; -----------------------------------------
roll_dice:
    push ax
    push bx
    push cx
    push dx

    mov ah, 0x00
    int 0x1A            ; BIOS timer, ticks returned in CX:DX

    mov ax, dx
    add ax, [random_seed]
    add ax, cx
    mov [random_seed], ax

    xor dx, dx
    mov bx, 6
    div bx              ; DX = remainder 0 to 5

    mov al, dl
    inc al              ; convert 0-5 to 1-6
    mov [dice_value], al

    pop dx
    pop cx
    pop bx
    pop ax
    ret


; -----------------------------------------
; Draw dice box
; -----------------------------------------
draw_dice:
    push ax
    push bx
    push dx
    push si
    push bp

    ; black outer dice box
    mov bx, DICE_X
    mov dx, DICE_Y
    mov si, 42
    mov bp, 42
    mov al, 0
    call draw_rect

    ; white inner dice box
    mov bx, DICE_X + 2
    mov dx, DICE_Y + 2
    mov si, 38
    mov bp, 38
    mov al, 15
    call draw_rect

    mov al, [dice_value]

    cmp al, 1
    je .one

    cmp al, 2
    je .two

    cmp al, 3
    je .three

    cmp al, 4
    je .four

    cmp al, 5
    je .five

    cmp al, 6
    je .six

    jmp .done

.one:
    call pip_center
    jmp .done

.two:
    call pip_top_left
    call pip_bottom_right
    jmp .done

.three:
    call pip_top_left
    call pip_center
    call pip_bottom_right
    jmp .done

.four:
    call pip_top_left
    call pip_top_right
    call pip_bottom_left
    call pip_bottom_right
    jmp .done

.five:
    call pip_top_left
    call pip_top_right
    call pip_center
    call pip_bottom_left
    call pip_bottom_right
    jmp .done

.six:
    call pip_top_left
    call pip_top_right
    call pip_middle_left
    call pip_middle_right
    call pip_bottom_left
    call pip_bottom_right
    jmp .done

.done:
    pop bp
    pop si
    pop dx
    pop bx
    pop ax
    ret


; -----------------------------------------
; Dice pip positions
; -----------------------------------------
pip_top_left:
    mov bx, DICE_X + 10
    mov dx, DICE_Y + 10
    call draw_pip
    ret

pip_top_right:
    mov bx, DICE_X + 28
    mov dx, DICE_Y + 10
    call draw_pip
    ret

pip_middle_left:
    mov bx, DICE_X + 10
    mov dx, DICE_Y + 19
    call draw_pip
    ret

pip_middle_right:
    mov bx, DICE_X + 28
    mov dx, DICE_Y + 19
    call draw_pip
    ret

pip_center:
    mov bx, DICE_X + 19
    mov dx, DICE_Y + 19
    call draw_pip
    ret

pip_bottom_left:
    mov bx, DICE_X + 10
    mov dx, DICE_Y + 28
    call draw_pip
    ret

pip_bottom_right:
    mov bx, DICE_X + 28
    mov dx, DICE_Y + 28
    call draw_pip
    ret


; -----------------------------------------
; Draw one black dice pip
; BX = x
; DX = y
; -----------------------------------------
draw_pip:
    push ax
    push bx
    push dx
    push si
    push bp

    mov si, 5
    mov bp, 5
    mov al, 0
    call draw_rect

    pop bp
    pop si
    pop dx
    pop bx
    pop ax
    ret


; -----------------------------------------
; Draw big player home areas
; -----------------------------------------
draw_board_base:
    ; Red home - top left
    mov bx, BOARD_X
    mov dx, BOARD_Y
    mov si, 72
    mov bp, 72
    mov al, 4
    call draw_rect

    ; Green home - top right
    mov bx, BOARD_X + 108
    mov dx, BOARD_Y
    mov si, 72
    mov bp, 72
    mov al, 2
    call draw_rect

    ; Yellow home - bottom left
    mov bx, BOARD_X
    mov dx, BOARD_Y + 108
    mov si, 72
    mov bp, 72
    mov al, 14
    call draw_rect

    ; Blue home - bottom right
    mov bx, BOARD_X + 108
    mov dx, BOARD_Y + 108
    mov si, 72
    mov bp, 72
    mov al, 1
    call draw_rect

    ret


; -----------------------------------------
; Draw all 52 main path cells
; -----------------------------------------
draw_main_path:
    mov si, path_x
    mov di, path_y
    mov cx, 52
    mov al, 15

.next_cell:
    mov bl, [si]
    mov bh, [di]
    call draw_cell

    inc si
    inc di
    loop .next_cell

    ret


; -----------------------------------------
; Draw colored home lanes
; -----------------------------------------
draw_home_lanes:
    ; Red lane
    mov si, red_lane_x
    mov di, red_lane_y
    mov cx, 6
    mov al, 4
    call draw_cells_from_table

    ; Green lane
    mov si, green_lane_x
    mov di, green_lane_y
    mov cx, 6
    mov al, 2
    call draw_cells_from_table

    ; Yellow lane
    mov si, yellow_lane_x
    mov di, yellow_lane_y
    mov cx, 6
    mov al, 14
    call draw_cells_from_table

    ; Blue lane
    mov si, blue_lane_x
    mov di, blue_lane_y
    mov cx, 6
    mov al, 1
    call draw_cells_from_table

    ret

draw_cells_from_table:
.next:
    mov bl, [si]
    mov bh, [di]
    call draw_cell

    inc si
    inc di
    loop .next

    ret


; -----------------------------------------
; Draw center box
; -----------------------------------------
draw_center_box:
    mov bx, BOARD_X + 72
    mov dx, BOARD_Y + 72
    mov si, 36
    mov bp, 36
    mov al, 15
    call draw_rect

    mov bx, BOARD_X + 78
    mov dx, BOARD_Y + 78
    mov si, 24
    mov bp, 24
    mov al, 0
    call draw_rect

    mov bx, BOARD_X + 82
    mov dx, BOARD_Y + 82
    mov si, 16
    mov bp, 16
    mov al, 15
    call draw_rect

    ret

; -----------------------------------------
; Draw Red Token 1
; -----------------------------------------
draw_red_token_1:
    
    mov byte [active_token_dots], 1
    
    mov al, [red_token_1_progress]
    cmp al, 255
    je .home

    call draw_red_token_on_path
    ret

.home:
    mov bx, BOARD_X + 18
    mov dx, BOARD_Y + 18
    mov al, 4
    mov cl, [active_token_dots]
    call draw_token_with_dots
    ret


; -----------------------------------------
; Draw Red Token 2
; -----------------------------------------
draw_red_token_2:
    mov byte [active_token_dots], 2

    mov al, [red_token_2_progress]
    cmp al, 255
    je .home

    call draw_red_token_on_path
    ret

.home:
    mov bx, BOARD_X + 42
    mov dx, BOARD_Y + 18
    mov al, 4
    mov cl, [active_token_dots]
    call draw_token_with_dots
    ret


; -----------------------------------------
; Draw Red Token 3
; -----------------------------------------
draw_red_token_3:
    mov byte [active_token_dots], 3
    mov al, [red_token_3_progress]
    cmp al, 255
    je .home

    call draw_red_token_on_path
    ret

.home:
    mov bx, BOARD_X + 18
    mov dx, BOARD_Y + 42
    mov al, 4
    mov cl, [active_token_dots]
    call draw_token_with_dots
    ret


; -----------------------------------------
; Draw Red Token 4
; -----------------------------------------
draw_red_token_4:
    mov byte [active_token_dots], 4
    mov al, [red_token_4_progress]
    cmp al, 255
    je .home

    call draw_red_token_on_path
    ret

.home:
    mov bx, BOARD_X + 42
    mov dx, BOARD_Y + 42
    mov al, 4
    mov cl, [active_token_dots]
    call draw_token_with_dots
    ret


; -----------------------------------------
; Draw Red token based on progress
; input:
; AL = token progress
;
; 0-50  = main path
; 51-55 = red home lane
; 56    = finished area
; -----------------------------------------
draw_red_token_on_path:
    cmp al, 51
    jb .main_path

    cmp al, 56
    je .finished

    ; Home lane: progress 51-56
    ; lane_index = progress - 51
    sub al, 51
    xor ah, ah
    mov si, ax

    mov bl, [red_lane_x + si]
    mov bh, [red_lane_y + si]
    mov al, 4
    call draw_token_on_cell
    ret


.main_path:
    ; path_index = RED_START_INDEX + progress
    add al, RED_START_INDEX

    ; If path_index >= 52, subtract 52
    cmp al, 52
    jb .index_ready
    sub al, 52

.index_ready:
    xor ah, ah
    mov si, ax

    mov bl, [path_x + si]
    mov bh, [path_y + si]
    mov al, 4
    call draw_token_on_cell
    ret


.finished:
    ; Red finished token stays at the last red home-lane cell near center
    mov bl, 6
    mov bh, 7
    mov al, 4
    call draw_token_on_cell
    ret

; -----------------------------------------
; Draw Green Token 1
; -----------------------------------------
draw_green_token_1:
    mov byte [active_token_dots], 1
    mov al, [green_token_1_progress]
    cmp al, 255
    je .home

    call draw_green_token_on_path
    ret

.home:
    mov bx, BOARD_X + 126
    mov dx, BOARD_Y + 18
    mov al, 2
    mov cl, [active_token_dots]
    call draw_token_with_dots
    ret


; -----------------------------------------
; Draw Green Token 2
; -----------------------------------------
draw_green_token_2:
    mov byte [active_token_dots], 2
    mov al, [green_token_2_progress]
    cmp al, 255
    je .home

    call draw_green_token_on_path
    ret

.home:
    mov bx, BOARD_X + 150
    mov dx, BOARD_Y + 18
    mov al, 2
    mov cl, [active_token_dots]
    call draw_token_with_dots
    ret


; -----------------------------------------
; Draw Green Token 3
; -----------------------------------------
draw_green_token_3:
    mov byte [active_token_dots], 3
    mov al, [green_token_3_progress]
    cmp al, 255
    je .home

    call draw_green_token_on_path
    ret

.home:
    mov bx, BOARD_X + 126
    mov dx, BOARD_Y + 42
    mov al, 2
    mov cl, [active_token_dots]
    call draw_token_with_dots
    ret


; -----------------------------------------
; Draw Green Token 4
; -----------------------------------------
draw_green_token_4:
    mov byte [active_token_dots], 4
    mov al, [green_token_4_progress]
    cmp al, 255
    je .home

    call draw_green_token_on_path
    ret

.home:
    mov bx, BOARD_X + 150
    mov dx, BOARD_Y + 42
    mov al, 2
    mov cl, [active_token_dots]
    call draw_token_with_dots
    ret


; -----------------------------------------
; Draw Green token based on progress
; input:
; AL = token progress
;
; 0-50  = main path
; 51-55 = green home lane
; 56    = finished area
; -----------------------------------------
draw_green_token_on_path:
    cmp al, 51
    jb .main_path

    cmp al, 56
    je .finished

    ; Home lane: progress 51-56
    ; lane_index = progress - 51
    sub al, 51
    xor ah, ah
    mov si, ax

    mov bl, [green_lane_x + si]
    mov bh, [green_lane_y + si]
    mov al, 2
    call draw_token_on_cell
    ret


.main_path:
    ; path_index = GREEN_START_INDEX + progress
    add al, GREEN_START_INDEX

    ; If path_index >= 52, subtract 52
    cmp al, 52
    jb .index_ready
    sub al, 52

.index_ready:
    xor ah, ah
    mov si, ax

    mov bl, [path_x + si]
    mov bh, [path_y + si]
    mov al, 2
    call draw_token_on_cell
    ret


.finished:
    ; Green finished token stays at the last green home-lane cell near center
    mov bl, 7
    mov bh, 6
    mov al, 2
    call draw_token_on_cell
    ret



; -----------------------------------------
; Draw Yellow Token 1
; -----------------------------------------
draw_yellow_token_1:

    mov byte [active_token_dots], 1
    mov al, [yellow_token_1_progress]
    cmp al, 255
    je .home

    call draw_yellow_token_on_path
    ret

.home:
    mov bx, BOARD_X + 18
    mov dx, BOARD_Y + 126
    mov al, 14
    mov cl, [active_token_dots]
    call draw_token_with_dots
    ret


; -----------------------------------------
; Draw Yellow Token 2
; -----------------------------------------
draw_yellow_token_2:
    mov byte [active_token_dots], 2
    mov al, [yellow_token_2_progress]
    cmp al, 255
    je .home

    call draw_yellow_token_on_path
    ret

.home:
    mov bx, BOARD_X + 42
    mov dx, BOARD_Y + 126
    mov al, 14
    mov cl, [active_token_dots]
    call draw_token_with_dots
    ret


; -----------------------------------------
; Draw Yellow Token 3
; -----------------------------------------
draw_yellow_token_3:
    mov byte [active_token_dots], 3
    mov al, [yellow_token_3_progress]
    cmp al, 255
    je .home

    call draw_yellow_token_on_path
    ret

.home:
    mov bx, BOARD_X + 18
    mov dx, BOARD_Y + 150
    mov al, 14
    mov cl, [active_token_dots]
    call draw_token_with_dots
    ret


; -----------------------------------------
; Draw Yellow Token 4
; -----------------------------------------
draw_yellow_token_4:
    mov byte [active_token_dots], 4
    mov al, [yellow_token_4_progress]
    cmp al, 255
    je .home

    call draw_yellow_token_on_path
    ret

.home:
    mov bx, BOARD_X + 42
    mov dx, BOARD_Y + 150
    mov al, 14
    mov cl, [active_token_dots]
    call draw_token_with_dots
    ret


; -----------------------------------------
; Draw Yellow token based on progress
; input:
; AL = token progress
;
; 0-50  = main path
; 51-55 = yellow home lane
; 56    = finished/final cell
; -----------------------------------------
draw_yellow_token_on_path:
    cmp al, 51
    jb .main_path

    cmp al, 56
    je .finished

    ; Home lane: progress 51-55
    ; lane_index = progress - 51
    sub al, 51
    xor ah, ah
    mov si, ax

    mov bl, [yellow_lane_x + si]
    mov bh, [yellow_lane_y + si]
    mov al, 14
    call draw_token_on_cell
    ret


.main_path:
    ; path_index = YELLOW_START_INDEX + progress
    add al, YELLOW_START_INDEX

    ; If path_index >= 52, subtract 52
    cmp al, 52
    jb .index_ready
    sub al, 52

.index_ready:
    xor ah, ah
    mov si, ax

    mov bl, [path_x + si]
    mov bh, [path_y + si]
    mov al, 14
    call draw_token_on_cell
    ret


.finished:
    ; Yellow finished token stays at final cell near center
    mov bl, 7
    mov bh, 8
    mov al, 14
    call draw_token_on_cell
    ret


; -----------------------------------------
; Draw Blue Token 1
; -----------------------------------------
draw_blue_token_1:
    mov byte [active_token_dots], 1
    mov al, [blue_token_1_progress]
    cmp al, 255
    je .home

    call draw_blue_token_on_path
    ret

.home:
    mov bx, BOARD_X + 126
    mov dx, BOARD_Y + 126
    mov al, 1
    mov cl, [active_token_dots]
    call draw_token_with_dots
    ret


; -----------------------------------------
; Draw Blue Token 2
; -----------------------------------------
draw_blue_token_2:
    mov byte [active_token_dots], 2
    mov al, [blue_token_2_progress]
    cmp al, 255
    je .home

    call draw_blue_token_on_path
    ret

.home:
    mov bx, BOARD_X + 150
    mov dx, BOARD_Y + 126
    mov al, 1
    mov cl, [active_token_dots]
    call draw_token_with_dots
    ret


; -----------------------------------------
; Draw Blue Token 3
; -----------------------------------------
draw_blue_token_3:
    mov byte [active_token_dots], 3
    mov al, [blue_token_3_progress]
    cmp al, 255
    je .home

    call draw_blue_token_on_path
    ret

.home:
    mov bx, BOARD_X + 126
    mov dx, BOARD_Y + 150
    mov al, 1
    mov cl, [active_token_dots]
    call draw_token_with_dots
    ret


; -----------------------------------------
; Draw Blue Token 4
; -----------------------------------------
draw_blue_token_4:
    mov byte [active_token_dots], 4
    mov al, [blue_token_4_progress]
    cmp al, 255
    je .home

    call draw_blue_token_on_path
    ret

.home:
    mov bx, BOARD_X + 150
    mov dx, BOARD_Y + 150
    mov al, 1
    mov cl, [active_token_dots]
    call draw_token_with_dots
    ret


; -----------------------------------------
; Draw Blue token based on progress
; input:
; AL = token progress
;
; 0-50  = main path
; 51-55 = blue home lane
; 56    = finished/final cell
; -----------------------------------------
draw_blue_token_on_path:
    cmp al, 51
    jb .main_path

    cmp al, 56
    je .finished

    ; Home lane: progress 51-55
    ; lane_index = progress - 51
    sub al, 51
    xor ah, ah
    mov si, ax

    mov bl, [blue_lane_x + si]
    mov bh, [blue_lane_y + si]
    mov al, 1
    call draw_token_on_cell
    ret


.main_path:
    ; path_index = BLUE_START_INDEX + progress
    add al, BLUE_START_INDEX

    ; If path_index >= 52, subtract 52
    cmp al, 52
    jb .index_ready
    sub al, 52

.index_ready:
    xor ah, ah
    mov si, ax

    mov bl, [path_x + si]
    mov bh, [path_y + si]
    mov al, 1
    call draw_token_on_cell
    ret


.finished:
    ; Blue finished token stays at final cell near center
    mov bl, 8
    mov bh, 7
    mov al, 1
    call draw_token_on_cell
    ret

; -----------------------------------------
; prepare_token_stacks
; Counts all non-home token positions before drawing.
; -----------------------------------------
prepare_token_stacks:
    ; Red tokens
    mov al, [red_token_1_progress]
    call register_red_token_cell

    mov al, [red_token_2_progress]
    call register_red_token_cell

    mov al, [red_token_3_progress]
    call register_red_token_cell

    mov al, [red_token_4_progress]
    call register_red_token_cell

    ; Green tokens
    mov al, [green_token_1_progress]
    call register_green_token_cell

    mov al, [green_token_2_progress]
    call register_green_token_cell

    mov al, [green_token_3_progress]
    call register_green_token_cell

    mov al, [green_token_4_progress]
    call register_green_token_cell

    ; Blue tokens
    mov al, [blue_token_1_progress]
    call register_blue_token_cell

    mov al, [blue_token_2_progress]
    call register_blue_token_cell

    mov al, [blue_token_3_progress]
    call register_blue_token_cell

    mov al, [blue_token_4_progress]
    call register_blue_token_cell

    ; Yellow tokens
    mov al, [yellow_token_1_progress]
    call register_yellow_token_cell

    mov al, [yellow_token_2_progress]
    call register_yellow_token_cell

    mov al, [yellow_token_3_progress]
    call register_yellow_token_cell

    mov al, [yellow_token_4_progress]
    call register_yellow_token_cell

    ret

; -----------------------------------------
; Register Red token cell
; input:
; AL = token progress
; -----------------------------------------
register_red_token_cell:
    cmp al, 255
    je .done

    cmp al, 51
    jb .main_path

    cmp al, 56
    je .finished

    sub al, 51
    xor ah, ah
    mov si, ax

    mov bl, [red_lane_x + si]
    mov bh, [red_lane_y + si]
    call register_token_cell
    ret

.main_path:
    add al, RED_START_INDEX

    cmp al, 52
    jb .index_ready
    sub al, 52

.index_ready:
    xor ah, ah
    mov si, ax

    mov bl, [path_x + si]
    mov bh, [path_y + si]
    call register_token_cell
    ret

.finished:
    mov bl, 6
    mov bh, 7
    call register_token_cell

.done:
    ret


; -----------------------------------------
; Register Green token cell
; input:
; AL = token progress
; -----------------------------------------
register_green_token_cell:
    cmp al, 255
    je .done

    cmp al, 51
    jb .main_path

    cmp al, 56
    je .finished

    sub al, 51
    xor ah, ah
    mov si, ax

    mov bl, [green_lane_x + si]
    mov bh, [green_lane_y + si]
    call register_token_cell
    ret

.main_path:
    add al, GREEN_START_INDEX

    cmp al, 52
    jb .index_ready
    sub al, 52

.index_ready:
    xor ah, ah
    mov si, ax

    mov bl, [path_x + si]
    mov bh, [path_y + si]
    call register_token_cell
    ret

.finished:
    mov bl, 7
    mov bh, 6
    call register_token_cell

.done:
    ret


; -----------------------------------------
; Register Blue token cell
; input:
; AL = token progress
; -----------------------------------------
register_blue_token_cell:
    cmp al, 255
    je .done

    cmp al, 51
    jb .main_path

    cmp al, 56
    je .finished

    sub al, 51
    xor ah, ah
    mov si, ax

    mov bl, [blue_lane_x + si]
    mov bh, [blue_lane_y + si]
    call register_token_cell
    ret

.main_path:
    add al, BLUE_START_INDEX

    cmp al, 52
    jb .index_ready
    sub al, 52

.index_ready:
    xor ah, ah
    mov si, ax

    mov bl, [path_x + si]
    mov bh, [path_y + si]
    call register_token_cell
    ret

.finished:
    mov bl, 8
    mov bh, 7
    call register_token_cell

.done:
    ret


; -----------------------------------------
; Register Yellow token cell
; input:
; AL = token progress
; -----------------------------------------
register_yellow_token_cell:
    cmp al, 255
    je .done

    cmp al, 51
    jb .main_path

    cmp al, 56
    je .finished

    sub al, 51
    xor ah, ah
    mov si, ax

    mov bl, [yellow_lane_x + si]
    mov bh, [yellow_lane_y + si]
    call register_token_cell
    ret

.main_path:
    add al, YELLOW_START_INDEX

    cmp al, 52
    jb .index_ready
    sub al, 52

.index_ready:
    xor ah, ah
    mov si, ax

    mov bl, [path_x + si]
    mov bh, [path_y + si]
    call register_token_cell
    ret

.finished:
    mov bl, 7
    mov bh, 8
    call register_token_cell

.done:
    ret

; -----------------------------------------
; draw_safe_cells
; Draws all 8 safe cells as colored cells.
;
; Color mapping is based on visual lane position:
;
; Yellow safe cells = 0, 47
; Red safe cells    = 13, 8
; Green safe cells  = 26, 21
; Blue safe cells   = 39, 34
; -----------------------------------------
draw_safe_cells:
    ; Yellow safe cells
    mov al, YELLOW_START_INDEX      ; 0
    mov cl, 14
    call draw_safe_cell_by_path_index

    mov al, BLUE_SAFE_2             ; 47
    mov cl, 14
    call draw_safe_cell_by_path_index


    ; Red safe cells
    mov al, RED_START_INDEX         ; 13
    mov cl, 4
    call draw_safe_cell_by_path_index

    mov al, YELLOW_SAFE_2           ; 8
    mov cl, 4
    call draw_safe_cell_by_path_index


    ; Green safe cells
    mov al, GREEN_START_INDEX       ; 26
    mov cl, 2
    call draw_safe_cell_by_path_index

    mov al, RED_SAFE_2              ; 21
    mov cl, 2
    call draw_safe_cell_by_path_index


    ; Blue safe cells
    mov al, BLUE_START_INDEX        ; 39
    mov cl, 1
    call draw_safe_cell_by_path_index

    mov al, GREEN_SAFE_2            ; 34
    mov cl, 1
    call draw_safe_cell_by_path_index

    ret

    
; -----------------------------------------
; draw_safe_cell_by_path_index
; input:
; AL = main path index
; CL = safe cell color
;
; Draws the safe cell as a colored board cell.
; -----------------------------------------
draw_safe_cell_by_path_index:
    mov [safe_index], al
    mov [safe_color], cl

    xor ah, ah
    mov si, ax

    mov bl, [path_x + si]
    mov bh, [path_y + si]

    mov al, [safe_color]
    call draw_cell

    ret


; -----------------------------------------
; Draw all 16 tokens
; Red tokens are dynamic/movable
; Green, Yellow, Blue tokens are still fixed in home
; -----------------------------------------
draw_all_tokens:
    ; Red tokens
    call draw_red_token_1
    call draw_red_token_2
    call draw_red_token_3
    call draw_red_token_4

    ; Green tokens
    call draw_green_token_1
    call draw_green_token_2
    call draw_green_token_3
    call draw_green_token_4

    ; Yellow tokens
    call draw_yellow_token_1
    call draw_yellow_token_2
    call draw_yellow_token_3
    call draw_yellow_token_4

    ; Blue tokens
    call draw_blue_token_1
    call draw_blue_token_2
    call draw_blue_token_3
    call draw_blue_token_4

    ret

; -----------------------------------------
; draw_token_with_dots
; input:
; BX = token pixel X
; DX = token pixel Y
; AL = token color
; CL = number of white dots: 1, 2, 3, or 4
; -----------------------------------------
draw_token_with_dots:
    mov [dot_base_x], bx
    mov [dot_base_y], dx
    mov [dot_count], cl

    ; Draw normal colored token first
    call draw_token

    ; If dot count is 0, draw no dots
    cmp byte [dot_count], 0
    je .done

    ; Dot 1 - top left
    mov bx, [dot_base_x]
    add bx, 2
    mov dx, [dot_base_y]
    add dx, 2
    mov si, 2
    mov bp, 2
    mov al, 15
    call draw_rect

    cmp byte [dot_count], 1
    je .done

    ; Dot 2 - top right
    mov bx, [dot_base_x]
    add bx, 6
    mov dx, [dot_base_y]
    add dx, 2
    mov si, 2
    mov bp, 2
    mov al, 15
    call draw_rect

    cmp byte [dot_count], 2
    je .done

    ; Dot 3 - bottom left
    mov bx, [dot_base_x]
    add bx, 2
    mov dx, [dot_base_y]
    add dx, 6
    mov si, 2
    mov bp, 2
    mov al, 15
    call draw_rect

    cmp byte [dot_count], 3
    je .done

    ; Dot 4 - bottom right
    mov bx, [dot_base_x]
    add bx, 6
    mov dx, [dot_base_y]
    add dx, 6
    mov si, 2
    mov bp, 2
    mov al, 15
    call draw_rect

.done:
    ret    


; -----------------------------------------
; draw_small_token_with_dots
; input:
; BX = token pixel X
; DX = token pixel Y
; AL = token color
; CL = number of white dots
; -----------------------------------------
draw_small_token_with_dots:
    mov [dot_base_x], bx
    mov [dot_base_y], dx
    mov [dot_count], cl

    ; Draw small colored token body: 5x5
    mov si, 5
    mov bp, 5
    call draw_rect

    cmp byte [dot_count], 0
    je .done

    ; Dot 1
    mov bx, [dot_base_x]
    add bx, 1
    mov dx, [dot_base_y]
    add dx, 1
    mov si, 1
    mov bp, 1
    mov al, 15
    call draw_rect

    cmp byte [dot_count], 1
    je .done

    ; Dot 2
    mov bx, [dot_base_x]
    add bx, 3
    mov dx, [dot_base_y]
    add dx, 1
    mov si, 1
    mov bp, 1
    mov al, 15
    call draw_rect

    cmp byte [dot_count], 2
    je .done

    ; Dot 3
    mov bx, [dot_base_x]
    add bx, 1
    mov dx, [dot_base_y]
    add dx, 3
    mov si, 1
    mov bp, 1
    mov al, 15
    call draw_rect

    cmp byte [dot_count], 3
    je .done

    ; Dot 4
    mov bx, [dot_base_x]
    add bx, 3
    mov dx, [dot_base_y]
    add dx, 3
    mov si, 1
    mov bp, 1
    mov al, 15
    call draw_rect

.done:
    ret

; -----------------------------------------
; Draw one token
; BX = x
; DX = y
; AL = token color
; -----------------------------------------
draw_token:
    push ax
    push bx
    push dx
    push si
    push bp

    mov [token_color], al

    ; black outer border
    mov si, 10
    mov bp, 10
    mov al, 0
    call draw_rect

    ; colored inner token
    inc bx
    inc dx
    mov si, 8
    mov bp, 8
    mov al, [token_color]
    call draw_rect

    pop bp
    pop si
    pop dx
    pop bx
    pop ax
    ret

; -----------------------------------------
; draw_token_on_cell
; input:
; BL = board cell X
; BH = board cell Y
; AL = token color
;
; If only one token is on the cell:
;     draw normal token
;
; If multiple tokens are on the cell:
;     draw small stacked token
; -----------------------------------------
draw_token_on_cell:
    mov [cell_token_color], al
    mov [cell_token_x], bl
    mov [cell_token_y], bh

    mov al, [active_token_dots]
    mov [stack_token_dots], al

    ; Check how many tokens are on this cell
    mov bl, [cell_token_x]
    mov bh, [cell_token_y]
    call find_stack_info_for_cell

    ; AL = total tokens on cell
    ; CL = slot number
    mov [stack_total], al
    mov [stack_slot], cl

    ; If only one token is here, draw normal-size token
    cmp byte [stack_total], 1
    je .draw_normal

    ; Otherwise draw small stacked token
    jmp .draw_stacked


.draw_normal:
    ; Convert cell X to normal centered token pixel X
    xor ax, ax
    mov al, [cell_token_x]
    mov cl, CELL_SIZE
    mul cl
    add ax, BOARD_X + 2
    mov bx, ax

    ; Convert cell Y to normal centered token pixel Y
    xor ax, ax
    mov al, [cell_token_y]
    mov cl, CELL_SIZE
    mul cl
    add ax, BOARD_Y + 2
    mov dx, ax

    mov al, [cell_token_color]
    mov cl, [stack_token_dots]
    call draw_token_with_dots
    ret


.draw_stacked:
    ; Convert cell X to pixel X
    xor ax, ax
    mov al, [cell_token_x]
    mov cl, CELL_SIZE
    mul cl
    add ax, BOARD_X
    mov bx, ax

    ; Convert cell Y to pixel Y
    xor ax, ax
    mov al, [cell_token_y]
    mov cl, CELL_SIZE
    mul cl
    add ax, BOARD_Y
    mov dx, ax

    ; Apply stack slot offset inside 12x12 cell
    mov al, [stack_slot]

    cmp al, 0
    je .slot_top_left

    cmp al, 1
    je .slot_top_right

    cmp al, 2
    je .slot_bottom_left

    ; Slot 3 = bottom-right
    add bx, 6
    add dx, 6
    jmp .draw_small


.slot_top_left:
    add bx, 1
    add dx, 1
    jmp .draw_small


.slot_top_right:
    add bx, 6
    add dx, 1
    jmp .draw_small


.slot_bottom_left:
    add bx, 1
    add dx, 6


.draw_small:
    mov al, [cell_token_color]
    mov cl, [stack_token_dots]
    call draw_small_token_with_dots
    ret



; -----------------------------------------
; draw_cell
; BL = grid x
; BH = grid y
; AL = color
; -----------------------------------------
draw_cell:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push bp

    mov [cell_color], al
    mov [grid_x], bl
    mov [grid_y], bh

    ; pixel x = BOARD_X + grid_x * CELL_SIZE
    xor ax, ax
    mov al, [grid_x]
    mov cl, CELL_SIZE
    mul cl
    add ax, BOARD_X
    mov bx, ax

    ; pixel y = BOARD_Y + grid_y * CELL_SIZE
    xor ax, ax
    mov al, [grid_y]
    mov cl, CELL_SIZE
    mul cl
    add ax, BOARD_Y
    mov dx, ax

    ; black outer cell
    mov si, CELL_SIZE
    mov bp, CELL_SIZE
    mov al, 0
    call draw_rect

    ; inner colored cell
    inc bx
    inc dx
    mov si, CELL_SIZE - 2
    mov bp, CELL_SIZE - 2
    mov al, [cell_color]
    call draw_rect

    pop bp
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret


; -----------------------------------------
; draw_rect
; BX = x
; DX = y
; SI = width
; BP = height
; AL = color
; -----------------------------------------
draw_rect:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push bp

    mov [rect_color], al
    mov cx, bp

.row_loop:
    push cx

    ; offset = y * 320 + x
    mov ax, dx
    mov di, ax
    shl ax, 8
    shl di, 6
    add ax, di
    add ax, bx
    mov di, ax

    mov al, [rect_color]
    mov cx, si
    rep stosb

    inc dx

    pop cx
    loop .row_loop

    pop bp
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret


; -----------------------------------------
; Main path coordinates, 52 cells
; -----------------------------------------
path_x:
    db 6,6,6,6,6,5,4,3,2,1,0,0,0
    db 1,2,3,4,5,6,6,6,6,6,6,7,8
    db 8,8,8,8,8,9,10,11,12,13,14,14,14
    db 13,12,11,10,9,8,8,8,8,8,8,7,6

path_y:
    db 13,12,11,10,9,8,8,8,8,8,8,7,6
    db 6,6,6,6,6,5,4,3,2,1,0,0,0
    db 1,2,3,4,5,6,6,6,6,6,6,7,8
    db 8,8,8,8,8,9,10,11,12,13,14,14,14


; -----------------------------------------
; Home lane coordinates
; 6 cells each because progress 51-56 = home lane
; -----------------------------------------

red_lane_x:
    db 1,2,3,4,5,6
red_lane_y:
    db 7,7,7,7,7,7

green_lane_x:
    db 7,7,7,7,7,7
green_lane_y:
    db 1,2,3,4,5,6

yellow_lane_x:
    db 7,7,7,7,7,7
yellow_lane_y:
    db 13,12,11,10,9,8

blue_lane_x:
    db 13,12,11,10,9,8
blue_lane_y:
    db 7,7,7,7,7,7

; -----------------------------------------
; Variables
; -----------------------------------------
rect_color db 0
cell_color db 0
grid_x db 0
grid_y db 0
token_color db 0

dice_value db 0
random_seed dw 1234

red_token_1_progress db 0
red_token_2_progress db 0
red_token_3_progress db 0
red_token_4_progress db 0

green_token_1_progress db 0
green_token_2_progress db 0
green_token_3_progress db 0
green_token_4_progress db 0

yellow_token_1_progress db 0
yellow_token_2_progress db 0
yellow_token_3_progress db 0
yellow_token_4_progress db 0

blue_token_1_progress db 0
blue_token_2_progress db 0
blue_token_3_progress db 0
blue_token_4_progress db 0

current_player db 0
last_dice db 0

token_stack_count db 0
token_stack_x times 64 db 0
token_stack_y times 64 db 0
token_stack_slots times 64 db 0

stack_cell_x db 0
stack_cell_y db 0
stack_token_color db 0
stack_token_dots db 0
stack_slot db 0

token_stack_drawn times 64 db 0
stack_total db 0

dice_available db 0
game_over db 0

red_finished db 0
green_finished db 0
blue_finished db 0
yellow_finished db 0

finished_player_count db 0
next_player_checks db 0

win_color db 0

first_place db 255
second_place db 255
third_place db 255
fourth_place db 255

result_color db 0

capture_path_index db 0

YELLOW_START_INDEX equ 0
RED_START_INDEX equ 13
GREEN_START_INDEX equ 26
BLUE_START_INDEX equ 39

YELLOW_SAFE_2 equ 8
RED_SAFE_2 equ 21
GREEN_SAFE_2 equ 34
BLUE_SAFE_2 equ 47

safe_color db 0
safe_index db 0

capture_happened db 0
