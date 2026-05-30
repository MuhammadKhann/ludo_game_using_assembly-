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

    ; 1-4 = move Red tokens
    cmp al, '1'
    je move_red_token_1

    cmp al, '2'
    je move_red_token_2

    cmp al, '3'
    je move_red_token_3

    cmp al, '4'
    je move_red_token_4

    ; 5-8 = move Green tokens temporarily
    cmp al, '5'
    je move_green_token_1

    cmp al, '6'
    je move_green_token_2

    cmp al, '7'
    je move_green_token_3

    cmp al, '8'
    je move_green_token_4

    ; Q/W/E/R = move Yellow tokens temporarily
    cmp al, 'q'
    je move_yellow_token_1
    cmp al, 'Q'
    je move_yellow_token_1

    cmp al, 'w'
    je move_yellow_token_2
    cmp al, 'W'
    je move_yellow_token_2

    cmp al, 'e'
    je move_yellow_token_3
    cmp al, 'E'
    je move_yellow_token_3

    cmp al, 'r'
    je move_yellow_token_4
    cmp al, 'R'
    je move_yellow_token_4


    ; A/S/F/G = move Blue tokens temporarily
    cmp al, 'a'
    je move_blue_token_1
    cmp al, 'A'
    je move_blue_token_1

    cmp al, 's'
    je move_blue_token_2
    cmp al, 'S'
    je move_blue_token_2

    cmp al, 'f'
    je move_blue_token_3
    cmp al, 'F'
    je move_blue_token_3

    cmp al, 'g'
    je move_blue_token_4
    cmp al, 'G'
    je move_blue_token_4

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

    ; If Red player has no valid move, consume dice automatically
    call any_player_has_valid_move
    cmp al, 1
    je main_loop

    ; No valid move available
    call consume_dice
    call draw_full_screen
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

    ; Consume dice immediately
    ; This prevents using the same 6 again
   call consume_dice

    call check_red_winner
    cmp al, 1
    je .red_won

    call draw_full_screen
    ret 


.already_out:
    ; Token is already on board, so move by dice value
    mov al, [si]
    add al, [dice_value]

    ; Token can move up to progress 57 only
    ; 0-50  = main path
    ; 51-56 = home lane
    ; 57    = finished
    cmp al, 56
    ja .invalid_move

    mov [si], al

    ; Consume dice after movement
    call consume_dice

    call check_red_winner
    cmp al, 1
    je .red_won

    call draw_full_screen
    ret

.red_won:
    mov byte [game_over], 1
    call draw_red_win_screen
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


stop_game:
    ; Return to text mode
    mov ax, 0x0003
    int 0x10

hang:
    hlt
    jmp hang


; -----------------------------------------
; Draw complete screen
; -----------------------------------------
draw_full_screen:
    call clear_screen
    call draw_board_base
    call draw_main_path
    call draw_home_lanes
    call draw_center_box
    call draw_all_tokens
    call draw_dice
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
    mov al, [red_token_1_progress]
    cmp al, 255
    je .home

    call draw_red_token_on_path
    ret

.home:
    mov bx, BOARD_X + 18
    mov dx, BOARD_Y + 18
    mov al, 4
    call draw_token
    ret


; -----------------------------------------
; Draw Red Token 2
; -----------------------------------------
draw_red_token_2:
    mov al, [red_token_2_progress]
    cmp al, 255
    je .home

    call draw_red_token_on_path
    ret

.home:
    mov bx, BOARD_X + 42
    mov dx, BOARD_Y + 18
    mov al, 4
    call draw_token
    ret


; -----------------------------------------
; Draw Red Token 3
; -----------------------------------------
draw_red_token_3:
    mov al, [red_token_3_progress]
    cmp al, 255
    je .home

    call draw_red_token_on_path
    ret

.home:
    mov bx, BOARD_X + 18
    mov dx, BOARD_Y + 42
    mov al, 4
    call draw_token
    ret


; -----------------------------------------
; Draw Red Token 4
; -----------------------------------------
draw_red_token_4:
    mov al, [red_token_4_progress]
    cmp al, 255
    je .home

    call draw_red_token_on_path
    ret

.home:
    mov bx, BOARD_X + 42
    mov dx, BOARD_Y + 42
    mov al, 4
    call draw_token
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
    mov al, [green_token_1_progress]
    cmp al, 255
    je .home

    call draw_green_token_on_path
    ret

.home:
    mov bx, BOARD_X + 126
    mov dx, BOARD_Y + 18
    mov al, 2
    call draw_token
    ret


; -----------------------------------------
; Draw Green Token 2
; -----------------------------------------
draw_green_token_2:
    mov al, [green_token_2_progress]
    cmp al, 255
    je .home

    call draw_green_token_on_path
    ret

.home:
    mov bx, BOARD_X + 150
    mov dx, BOARD_Y + 18
    mov al, 2
    call draw_token
    ret


; -----------------------------------------
; Draw Green Token 3
; -----------------------------------------
draw_green_token_3:
    mov al, [green_token_3_progress]
    cmp al, 255
    je .home

    call draw_green_token_on_path
    ret

.home:
    mov bx, BOARD_X + 126
    mov dx, BOARD_Y + 42
    mov al, 2
    call draw_token
    ret


; -----------------------------------------
; Draw Green Token 4
; -----------------------------------------
draw_green_token_4:
    mov al, [green_token_4_progress]
    cmp al, 255
    je .home

    call draw_green_token_on_path
    ret

.home:
    mov bx, BOARD_X + 150
    mov dx, BOARD_Y + 42
    mov al, 2
    call draw_token
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
    mov al, [yellow_token_1_progress]
    cmp al, 255
    je .home

    call draw_yellow_token_on_path
    ret

.home:
    mov bx, BOARD_X + 18
    mov dx, BOARD_Y + 126
    mov al, 14
    call draw_token
    ret


; -----------------------------------------
; Draw Yellow Token 2
; -----------------------------------------
draw_yellow_token_2:
    mov al, [yellow_token_2_progress]
    cmp al, 255
    je .home

    call draw_yellow_token_on_path
    ret

.home:
    mov bx, BOARD_X + 42
    mov dx, BOARD_Y + 126
    mov al, 14
    call draw_token
    ret


; -----------------------------------------
; Draw Yellow Token 3
; -----------------------------------------
draw_yellow_token_3:
    mov al, [yellow_token_3_progress]
    cmp al, 255
    je .home

    call draw_yellow_token_on_path
    ret

.home:
    mov bx, BOARD_X + 18
    mov dx, BOARD_Y + 150
    mov al, 14
    call draw_token
    ret


; -----------------------------------------
; Draw Yellow Token 4
; -----------------------------------------
draw_yellow_token_4:
    mov al, [yellow_token_4_progress]
    cmp al, 255
    je .home

    call draw_yellow_token_on_path
    ret

.home:
    mov bx, BOARD_X + 42
    mov dx, BOARD_Y + 150
    mov al, 14
    call draw_token
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
    mov al, [blue_token_1_progress]
    cmp al, 255
    je .home

    call draw_blue_token_on_path
    ret

.home:
    mov bx, BOARD_X + 126
    mov dx, BOARD_Y + 126
    mov al, 1
    call draw_token
    ret


; -----------------------------------------
; Draw Blue Token 2
; -----------------------------------------
draw_blue_token_2:
    mov al, [blue_token_2_progress]
    cmp al, 255
    je .home

    call draw_blue_token_on_path
    ret

.home:
    mov bx, BOARD_X + 150
    mov dx, BOARD_Y + 126
    mov al, 1
    call draw_token
    ret


; -----------------------------------------
; Draw Blue Token 3
; -----------------------------------------
draw_blue_token_3:
    mov al, [blue_token_3_progress]
    cmp al, 255
    je .home

    call draw_blue_token_on_path
    ret

.home:
    mov bx, BOARD_X + 126
    mov dx, BOARD_Y + 150
    mov al, 1
    call draw_token
    ret


; -----------------------------------------
; Draw Blue Token 4
; -----------------------------------------
draw_blue_token_4:
    mov al, [blue_token_4_progress]
    cmp al, 255
    je .home

    call draw_blue_token_on_path
    ret

.home:
    mov bx, BOARD_X + 150
    mov dx, BOARD_Y + 150
    mov al, 1
    call draw_token
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
; BL = grid x
; BH = grid y
; AL = token color
; Draws token centered inside a board cell
; -----------------------------------------
draw_token_on_cell:
    push ax
    push bx
    push cx
    push dx

    mov [token_color], al
    mov [grid_x], bl
    mov [grid_y], bh

    ; pixel x = BOARD_X + grid_x * CELL_SIZE + 2
    xor ax, ax
    mov al, [grid_x]
    mov cl, CELL_SIZE
    mul cl
    add ax, BOARD_X
    add ax, 2
    mov bx, ax

    ; pixel y = BOARD_Y + grid_y * CELL_SIZE + 2
    xor ax, ax
    mov al, [grid_y]
    mov cl, CELL_SIZE
    mul cl
    add ax, BOARD_Y
    add ax, 2
    mov dx, ax

    mov al, [token_color]
    call draw_token

    pop dx
    pop cx
    pop bx
    pop ax
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

red_token_1_progress db 255
red_token_2_progress db 255
red_token_3_progress db 255
red_token_4_progress db 255

green_token_1_progress db 255
green_token_2_progress db 255
green_token_3_progress db 255
green_token_4_progress db 255

yellow_token_1_progress db 255
yellow_token_2_progress db 255
yellow_token_3_progress db 255
yellow_token_4_progress db 255

blue_token_1_progress db 255
blue_token_2_progress db 255
blue_token_3_progress db 255
blue_token_4_progress db 255


dice_available db 0
game_over db 0