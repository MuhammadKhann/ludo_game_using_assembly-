#!/bin/bash
set -e

echo "Building Ludo COAL Project..."

mkdir -p build

# Detect boot.asm location
if [ -f "src/boot.asm" ]; then
    BOOT_FILE="src/boot.asm"
elif [ -f "boot.asm" ]; then
    BOOT_FILE="boot.asm"
else
    echo "Error: boot.asm not found."
    exit 1
fi

# Detect game.asm location
if [ -f "src/game.asm" ]; then
    GAME_FILE="src/game.asm"
elif [ -f "game.asm" ]; then
    GAME_FILE="game.asm"
else
    echo "Error: game.asm not found."
    exit 1
fi

nasm -f bin "$BOOT_FILE" -o build/boot.bin
nasm -f bin "$GAME_FILE" -o build/game.bin

# Create floppy image
dd if=/dev/zero of=build/ludo.img bs=512 count=2880 status=none
dd if=build/boot.bin of=build/ludo.img bs=512 count=1 conv=notrunc status=none
dd if=build/game.bin of=build/ludo.img bs=512 seek=1 conv=notrunc status=none

# Create USB/HDD-style image
dd if=/dev/zero of=build/ludo_usb.img bs=1M count=16 status=none
dd if=build/boot.bin of=build/ludo_usb.img bs=512 count=1 conv=notrunc status=none
dd if=build/game.bin of=build/ludo_usb.img bs=512 seek=1 conv=notrunc status=none

echo "Build successful."
echo "Floppy image: build/ludo.img"
echo "USB image: build/ludo_usb.img"
echo "Starting QEMU..."

env -i \
PATH=/usr/bin:/bin \
HOME="$HOME" \
DISPLAY="$DISPLAY" \
XAUTHORITY="$XAUTHORITY" \
XDG_RUNTIME_DIR="$XDG_RUNTIME_DIR" \
/usr/bin/qemu-system-i386 \
-drive file=build/ludo_usb.img,format=raw,if=ide \
-display gtk,zoom-to-fit=on