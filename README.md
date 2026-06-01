# Bootable Ludo Game – COAL Project

A dual-mode bootable Ludo game developed as a **Computer Organization and Assembly Language (COAL)** semester project.

This project can run directly from a USB drive without requiring an operating system. It supports both:

- **Legacy BIOS mode** using a 16-bit x86 Assembly graphical Ludo game
- **UEFI mode** using a separate `BOOTX64.EFI` UEFI application

---

## Project Information

**Project Title:** Bootable Ludo Game  
**Course:** Computer Organization and Assembly Language  
**Project Type:** Bare-metal bootable game  
**Platform:** BIOS / UEFI bootable USB  

### Group Members

- Muhammad
- Shahmeer
- Abdullah

### Instructor

- Ma’am Mamoona

---

## Project Overview

This project is a bootable Ludo game that runs directly from a USB drive. Unlike normal games that require Windows, Linux, or another operating system, this game starts before any operating system loads.

The main version is written in **16-bit x86 Assembly** and runs in **Legacy BIOS mode**. It uses BIOS interrupts for graphics, keyboard input, and timer-based dice generation.

The project also includes a separate **UEFI boot version** using `BOOTX64.EFI`, so the same USB can boot on modern UEFI-based systems.

---

## Main Objective

The main objective of this project is to demonstrate low-level system programming concepts, including:

- Boot sector programming
- Real mode Assembly programming
- BIOS interrupt usage
- VGA graphics programming
- Keyboard input handling without an operating system
- USB boot image creation
- Dual BIOS and UEFI boot support

---

## Key Features

### BIOS / Legacy Assembly Version

The BIOS version is the main graphical version of the project.

Features include:

- Bootable directly from USB
- Runs without any operating system
- 16-bit x86 Assembly implementation
- VGA Mode 13h graphics
- Full Ludo board
- Four-player gameplay
- Red, Green, Blue, and Yellow players
- Dice rolling system
- Token movement system
- Turn-based logic
- Token unlocking only on dice 6
- Extra turn on dice 6
- Token capture system
- Safe cells
- Home lanes
- Token dot markers
- Stacked token rendering
- Winner detection
- Ranking system
- Final result screen
- Restart option after result screen

---

### UEFI Version

The UEFI version is a separate boot application.

Features include:

- UEFI boot support
- Uses `/EFI/BOOT/BOOTX64.EFI`
- Runs on UEFI systems
- Keyboard-based controls
- Dice rolling
- Token movement
- Reset option
- Exit option

The UEFI version is separate because pure UEFI does not support BIOS interrupts such as:

```asm
int 0x10    ; BIOS video services
int 0x16    ; BIOS keyboard services
int 0x1A    ; BIOS timer services
```

---

## Why Two Versions Are Needed

BIOS and UEFI use different boot methods.

The BIOS version uses:

```text
Boot sector
16-bit real mode
BIOS interrupts
VGA Mode 13h
```

The UEFI version uses:

```text
EFI executable
BOOTX64.EFI
UEFI firmware services
UEFI-compatible keyboard input
```

Because of this difference, the same Assembly binary cannot run directly in both BIOS and UEFI modes.

The final USB contains two boot paths:

```text
Dual-Mode USB
│
├── Legacy BIOS Boot
│   ├── Boot sector
│   └── Assembly Ludo game
│
└── UEFI Boot
    └── /EFI/BOOT/BOOTX64.EFI
```

---

## Technologies Used

### Programming Languages

- x86 Assembly
- C language for UEFI application

### Tools

- NASM
- GCC
- GNU-EFI
- QEMU
- OVMF
- mtools
- dosfstools
- Git
- Ubuntu Linux

---

## Project Structure

```text
ludo-coal-project/
│
├── boot.asm
├── build.sh
├── README.md
│
├── src/
│   └── game.asm
│
├── uefi/
│   └── main.c
│
└── build/
    ├── boot.bin
    ├── game.bin
    ├── ludo.img
    ├── ludo_usb.img
    ├── ludo_dual.img
    ├── BOOTX64.EFI
    └── EFI/
        └── BOOT/
            └── BOOTX64.EFI
```

---

## File Descriptions

### `boot.asm`

This file contains the BIOS bootloader.

Responsibilities:

- Works as the first-stage boot sector
- Loads the game binary into memory
- Transfers control to the Assembly game
- Allows the program to run without an operating system

---

### `src/game.asm`

This is the main Assembly game file.

It contains:

- VGA graphics setup
- Main Ludo board drawing
- Dice drawing
- Token drawing
- Keyboard input handling
- Turn management
- Token movement logic
- Capture logic
- Safe cell logic
- Winner detection
- Ranking system
- Restart logic

---

### `uefi/main.c`

This file contains the UEFI-compatible version of the project.

It is compiled into:

```text
BOOTX64.EFI
```

The UEFI firmware loads this file from:

```text
/EFI/BOOT/BOOTX64.EFI
```

---

### `build.sh`

This script builds the project and creates bootable images.

It generates:

```text
build/boot.bin
build/game.bin
build/ludo.img
build/ludo_usb.img
build/ludo_dual.img
build/BOOTX64.EFI
```

---

## Game Rules Implemented

### Player Order

The turn order is:

```text
Red → Green → Blue → Yellow → Red
```

Internally, players are represented as:

```text
0 = Red
1 = Green
2 = Blue
3 = Yellow
```

---

### Token States

Each token has a progress value.

| Value | Meaning |
|---|---|
| `255` | Token is at home |
| `0-50` | Token is on the main path |
| `51-55` | Token is in the home lane |
| `56` | Token has finished |

---

### Dice Rules

- A player rolls the dice using `D` or `d`.
- A token can leave home only when the dice value is `6`.
- Rolling a `6` gives the same player another turn.
- If no valid move is available, the turn automatically passes to the next player.

---

### Movement Rule

A token can move only if:

```text
token_progress + dice_value <= 56
```

If the move would go beyond `56`, the move is invalid.

---

### Capture Rule

If a token lands on an opponent token on a non-safe cell, the opponent token is captured.

Captured token returns home:

```text
progress = 255
```

A successful capture gives the current player an extra turn.

---

### Safe Cells

Safe cells are positions where tokens cannot be captured.

Safe cell indexes:

```text
0, 8, 13, 21, 26, 34, 39, 47
```

---

### Winning Rule

A player finishes when all four tokens reach:

```text
progress = 56
```

The game continues after the first player finishes so that all rankings can be calculated.

Final ranking includes:

```text
1st place
2nd place
3rd place
4th place
```

---

## Controls

### BIOS / Legacy Version Controls

| Key | Action |
|---|---|
| `Enter` | Start game |
| `D` / `d` | Roll dice |
| `1` | Move token 1 |
| `2` | Move token 2 |
| `3` | Move token 3 |
| `4` | Move token 4 |
| `R` / `r` | Restart after final result |
| `Esc` | Exit |

---

### UEFI Version Controls

| Key | Action |
|---|---|
| `D` / `d` | Roll dice |
| `1` | Move token 1 |
| `2` | Move token 2 |
| `3` | Move token 3 |
| `4` | Move token 4 |
| `R` / `r` | Reset game |
| `Esc` | Exit |

---

## Installation Requirements

Install required packages on Ubuntu:

```bash
sudo apt update
sudo apt install nasm qemu-system-x86 gnu-efi ovmf mtools dosfstools build-essential
```

If `apt` is interrupted, repair it using:

```bash
sudo dpkg --configure -a
```

---

## Building the Project

Give execution permission to the build script:

```bash
chmod +x build.sh
```

Run the build script:

```bash
./build.sh
```

After a successful build, the `build/` folder should contain:

```text
boot.bin
game.bin
ludo.img
ludo_usb.img
ludo_dual.img
BOOTX64.EFI
```

---

## Testing in QEMU

### Test BIOS / Legacy Mode

```bash
env -i \
PATH=/usr/bin:/bin \
HOME="$HOME" \
DISPLAY="$DISPLAY" \
XAUTHORITY="$XAUTHORITY" \
XDG_RUNTIME_DIR="$XDG_RUNTIME_DIR" \
/usr/bin/qemu-system-i386 \
-drive file=build/ludo_dual.img,format=raw,if=ide \
-display gtk,zoom-to-fit=on
```

Expected result:

```text
The graphical Assembly Ludo game starts.
```

---

### Test UEFI Mode

Copy OVMF variables:

```bash
cp /usr/share/OVMF/OVMF_VARS_4M.fd build/OVMF_VARS.fd
```

Run UEFI QEMU:

```bash
env -i \
PATH=/usr/bin:/bin \
HOME="$HOME" \
DISPLAY="$DISPLAY" \
XAUTHORITY="$XAUTHORITY" \
XDG_RUNTIME_DIR="$XDG_RUNTIME_DIR" \
/usr/bin/qemu-system-x86_64 \
-drive if=pflash,format=raw,readonly=on,file=/usr/share/OVMF/OVMF_CODE_4M.fd \
-drive if=pflash,format=raw,file=build/OVMF_VARS.fd \
-drive file=build/ludo_dual.img,format=raw,if=ide \
-display gtk,zoom-to-fit=on
```

Expected result:

```text
The UEFI Ludo version starts.
```

---

## Creating the Dual-Mode Image Manually

The final dual-mode image is:

```text
build/ludo_dual.img
```

It contains:

```text
BIOS boot sector
Assembly game binary
FAT EFI partition
BOOTX64.EFI
```

Manual image creation commands:

```bash
rm -f build/ludo_dual.img

dd if=/dev/zero of=build/ludo_dual.img bs=1M count=128 status=none

printf "label: dos\nunit: sectors\n\nbuild/ludo_dual.img1 : start=2048, type=ef, bootable\n" | sfdisk build/ludo_dual.img

dd if=build/boot.bin of=build/ludo_dual.img bs=446 count=1 conv=notrunc status=none

dd if=build/game.bin of=build/ludo_dual.img bs=512 seek=1 conv=notrunc status=none

mformat -i build/ludo_dual.img@@1048576 -F ::

mmd -i build/ludo_dual.img@@1048576 ::/EFI
mmd -i build/ludo_dual.img@@1048576 ::/EFI/BOOT

mcopy -i build/ludo_dual.img@@1048576 build/BOOTX64.EFI ::/EFI/BOOT/BOOTX64.EFI

mdir -i build/ludo_dual.img@@1048576 ::/EFI/BOOT
```

Expected output should show:

```text
BOOTX64 EFI
```

---

## Writing the Image to USB

First check your USB device:

```bash
lsblk
```

Example output:

```text
sda      14.4G disk
└─sda1   14.4G part /media/user/USB
```

In this example, the USB disk is:

```text
/dev/sda
```

Do not write to your internal drive, for example:

```text
/dev/nvme0n1
```

---

### Write to USB

Unmount the USB partition:

```bash
sudo umount /dev/sda1
```

Write the dual image:

```bash
sudo dd if=build/ludo_dual.img of=/dev/sda bs=4M status=progress conv=fsync
```

Flush data:

```bash
sync
```

Eject USB:

```bash
sudo eject /dev/sda
```

---

## Booting on Dell Laptop

### Open Boot Menu

Restart the laptop and press:

```text
F12
```

Choose the USB boot option.

---

### BIOS / Legacy Boot

Choose:

```text
Legacy USB
```

Expected result:

```text
Graphical Assembly Ludo game starts.
```

---

### UEFI Boot

Choose:

```text
UEFI USB
```

Expected result:

```text
UEFI Ludo version starts.
```

---

## BIOS Settings

If the USB does not appear, open BIOS setup using:

```text
F2
```

Recommended settings:

```text
USB Boot Support: Enabled
Secure Boot: Disabled
Legacy Boot / CSM: Enabled for BIOS mode
Boot Mode: UEFI for UEFI mode
```

---

## Secure Boot Note

Custom `BOOTX64.EFI` files are usually unsigned.

Because of this, Secure Boot may block the UEFI version.

Recommended setting:

```text
Secure Boot: Disabled
```

---

## Expected Final Result

| Boot Mode | Result |
|---|---|
| Legacy BIOS USB | Graphical Assembly Ludo |
| UEFI USB | UEFI Ludo version |

---

## Important Technical Notes

### BIOS Version

The BIOS version uses:

```asm
int 0x10
int 0x16
int 0x1A
```

These are BIOS interrupts.

They are used for:

- Graphics
- Keyboard input
- Timer-based dice values

---

### UEFI Version

The UEFI version does not use BIOS interrupts.

It is loaded by firmware from:

```text
/EFI/BOOT/BOOTX64.EFI
```

This is the default removable-media boot path for x86_64 UEFI systems.

---

## Limitations

This project is designed for educational purposes.

Current limitations:

- BIOS and UEFI versions are separate implementations.
- The BIOS version is the main graphical version.
- The UEFI version is created for compatibility with UEFI boot.
- Secure Boot may need to be disabled.
- Advanced Ludo rules such as online multiplayer are not included.
- The game is designed for COAL demonstration, not commercial release.

---

## Learning Outcomes

This project helped demonstrate:

- Low-level boot process
- How BIOS loads a boot sector
- How a program can run without an operating system
- 16-bit real mode Assembly programming
- VGA graphics programming
- BIOS interrupt usage
- Keyboard input handling at low level
- Game state management in Assembly
- Disk image creation
- USB booting
- Difference between BIOS and UEFI
- Creation of a dual-mode bootable USB

---

## Common Problems and Fixes

### QEMU Snap Library Error

If QEMU shows an error related to Snap libraries, use system QEMU directly:

```bash
env -i \
PATH=/usr/bin:/bin \
HOME="$HOME" \
DISPLAY="$DISPLAY" \
XAUTHORITY="$XAUTHORITY" \
XDG_RUNTIME_DIR="$XDG_RUNTIME_DIR" \
/usr/bin/qemu-system-i386 \
-drive file=build/ludo_dual.img,format=raw,if=ide
```

---

### USB Does Not Boot in BIOS Mode

Check:

```text
Legacy Boot / CSM is enabled
Secure Boot is disabled
USB boot is enabled
```

---

### USB Does Not Boot in UEFI Mode

Check:

```text
Secure Boot is disabled
USB boot is enabled
BOOTX64.EFI exists at /EFI/BOOT/BOOTX64.EFI
```

---

### Wrong USB Device Warning

Always verify with:

```bash
lsblk
```

Never write the image to your internal drive.

Correct example:

```bash
sudo dd if=build/ludo_dual.img of=/dev/sda bs=4M status=progress conv=fsync
```

Wrong example:

```bash
sudo dd if=build/ludo_dual.img of=/dev/nvme0n1 bs=4M status=progress conv=fsync
```

---

## Git Commands

Add files:

```bash
git add .
```

Commit:

```bash
git commit -m "Complete bootable Ludo game project"
```

Push:

```bash
git push origin main
```

---

## Conclusion

This project successfully implements a bootable Ludo game that can run directly from a USB drive. The BIOS version demonstrates low-level Assembly programming, boot sector concepts, VGA graphics, and BIOS interrupt usage. The UEFI version adds compatibility with modern systems by using a separate `BOOTX64.EFI` application.

The final result is a dual-mode bootable USB that supports both Legacy BIOS and UEFI boot environments, making the project suitable for demonstrating core concepts of Computer Organization and Assembly Language.