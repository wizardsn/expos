# This file contains project configurations
# and build system settings

# put all produced files into this dir
OUTDIR := out

# build tools
AS	:= gcc
ASM := nasm
CC	:= gcc
LD	:= ld

# include directories
INCLUDE		:= include/
INCLUDE		:= $(addprefix -I ,$(INCLUDE))

# build flags
BUILD_ASFLAGS	:= -mmnemonic=intel -msyntax=intel -mnaked-reg $(INCLUDE)
BUILD_ASMFLAGS	:= -felf32 -w+orphan-labels $(INCLUDE)
BUILD_CFLAGS	:= -ffreestanding -std=gnu99 -m32 -march=i686 -fno-builtin -g \
				-nostdinc $(INCLUDE)
BUILD_LDFLAGS	:= -nostdlib -melf_i386

# project specific configurations
TARGET_NAME := image.bin
KERNEL_LMA	:= 0x200000
