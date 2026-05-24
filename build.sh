#!/bin/bash

clear

echo "Building Ludo COAL Project..."

mkdir -p build

nasm -f bin boot.asm -o build/boot.bin
if [ $? -ne 0 ]; then
    echo "Bootloader build failed."
    exit 1
fi

nasm -f bin src/game.asm -o build/game.bin
if [ $? -ne 0 ]; then
    echo "Game build failed."
    exit 1
fi

dd if=/dev/zero of=build/ludo.img bs=512 count=2880 status=none
dd if=build/boot.bin of=build/ludo.img conv=notrunc status=none
dd if=build/game.bin of=build/ludo.img bs=512 seek=1 conv=notrunc status=none

echo "Build successful."
echo "Starting QEMU..."

env -i PATH=/usr/bin:/bin HOME="$HOME" DISPLAY="$DISPLAY" XAUTHORITY="$XAUTHORITY" XDG_RUNTIME_DIR="$XDG_RUNTIME_DIR" /usr/bin/qemu-system-i386 -fda build/ludo.img