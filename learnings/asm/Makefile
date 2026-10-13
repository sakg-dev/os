NUMBER = $(filter-out run ,$(MAKECMDGOALS))

build:
	nasm -f bin $(NUMBER)_boot.asm -o $(NUMBER)_boot.bin

run:build
	qemu-system-x86_64 $(NUMBER)_boot.bin
