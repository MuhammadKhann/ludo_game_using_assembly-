#include <efi.h>
#include <efilib.h>

#define HOME 255
#define FINISHED 56

static UINT8 current_player = 0;
static UINT8 dice_value = 0;
static UINT8 dice_available = 0;
static UINT8 token[4][4];
static UINT32 seed = 12345;

static CHAR16 *player_name(UINT8 p)
{
    if (p == 0) return L"RED";
    if (p == 1) return L"GREEN";
    if (p == 2) return L"BLUE";
    return L"YELLOW";
}

static void init_game(void)
{
    for (UINTN p = 0; p < 4; p++) {
        for (UINTN t = 0; t < 4; t++) {
            token[p][t] = HOME;
        }
    }

    current_player = 0;
    dice_value = 0;
    dice_available = 0;
}

static void next_player(void)
{
    current_player++;
    if (current_player >= 4) {
        current_player = 0;
    }
}

static void draw_screen(void)
{
    uefi_call_wrapper(ST->ConOut->ClearScreen, 1, ST->ConOut);

    Print(L"UEFI LUDO | D=ROLL | 1-4=MOVE | R=RESET | ESC=EXIT\r\n");
    Print(L"====================================================\r\n\r\n");

    Print(L"Current Player: %s\r\n", player_name(current_player));

    if (dice_value == 0) {
        Print(L"Dice: Not rolled\r\n\r\n");
    } else {
        Print(L"Dice: %d\r\n\r\n", dice_value);
    }

    Print(L"Token Progress:\r\n\r\n");

    for (UINTN p = 0; p < 4; p++) {
        Print(L"%s: ", player_name(p));

        for (UINTN t = 0; t < 4; t++) {
            UINT8 v = token[p][t];

            if (v == HOME) {
                Print(L"[T%d:HOME] ", t + 1);
            } else if (v == FINISHED) {
                Print(L"[T%d:FINISH] ", t + 1);
            } else {
                Print(L"[T%d:%d] ", t + 1, v);
            }
        }

        Print(L"\r\n");
    }

    Print(L"\r\nRules:\r\n");
    Print(L"- Press D to roll dice.\r\n");
    Print(L"- Press 1, 2, 3, or 4 to move current player's token.\r\n");
    Print(L"- A token leaves HOME only on dice 6.\r\n");
    Print(L"- Dice 6 gives another turn.\r\n");
    Print(L"- R resets the game.\r\n");
}

static void roll_dice(void)
{
    if (dice_available) {
        return;
    }

    seed = seed * 1103515245 + 12345;
    dice_value = ((seed >> 16) % 6) + 1;
    dice_available = 1;

    UINT8 has_move = 0;

    for (UINTN t = 0; t < 4; t++) {
        UINT8 v = token[current_player][t];

        if (v == HOME && dice_value == 6) {
            has_move = 1;
        }

        if (v != HOME && v != FINISHED && v + dice_value <= FINISHED) {
            has_move = 1;
        }
    }

    if (!has_move) {
        dice_available = 0;
        dice_value = 0;
        next_player();
    }
}

static void move_token(UINT8 index)
{
    if (!dice_available) {
        return;
    }

    if (index > 3) {
        return;
    }

    UINT8 v = token[current_player][index];

    if (v == HOME) {
        if (dice_value != 6) {
            return;
        }

        token[current_player][index] = 0;
    } else {
        if (v == FINISHED) {
            return;
        }

        if (v + dice_value > FINISHED) {
            return;
        }

        token[current_player][index] = v + dice_value;
    }

    UINT8 last = dice_value;

    dice_available = 0;
    dice_value = 0;

    if (last != 6) {
        next_player();
    }
}

static EFI_INPUT_KEY wait_key(void)
{
    EFI_INPUT_KEY key;
    UINTN index;

    uefi_call_wrapper(BS->WaitForEvent, 3, 1, &ST->ConIn->WaitForKey, &index);
    uefi_call_wrapper(ST->ConIn->ReadKeyStroke, 2, ST->ConIn, &key);

    return key;
}

EFI_STATUS EFIAPI efi_main(EFI_HANDLE ImageHandle, EFI_SYSTEM_TABLE *SystemTable)
{
    InitializeLib(ImageHandle, SystemTable);

    init_game();
    draw_screen();

    while (1) {
        EFI_INPUT_KEY key = wait_key();

        if (key.UnicodeChar == L'D' || key.UnicodeChar == L'd') {
            roll_dice();
            draw_screen();
        } else if (key.UnicodeChar >= L'1' && key.UnicodeChar <= L'4') {
            move_token((UINT8)(key.UnicodeChar - L'1'));
            draw_screen();
        } else if (key.UnicodeChar == L'R' || key.UnicodeChar == L'r') {
            init_game();
            draw_screen();
        } else if (key.UnicodeChar == 0x1B) {
            break;
        }
    }

    return EFI_SUCCESS;
}
