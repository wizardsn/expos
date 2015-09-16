# This file contains project configurations
# and build system settings

# put all produced files into this dir
PREFIX ?= ./
OUTDIR := out

# build tools
AS    := gcc
ASM   := nasm
CC    := gcc
CPP   := g++
LD    := ld

# include directories
INCLUDE_DIRS    := include/
INCLUDE_DIRS    := $(addprefix -I ,$(INCLUDE_DIRS))

# global build flags
BUILD_ASFLAGS	:= -mmnemonic=intel -msyntax=intel -O2 -g $(INCLUDE_DIRS)
BUILD_ASMFLAGS	:= -felf32 -w+orphan-labels -g $(INCLUDE_DIRS)
BUILD_CFLAGS	:= -ffreestanding -std=gnu11 -O2 -g -Wall -Wextra $(INCLUDE_DIRS)
BUILD_CPPFLAGS  := -ffreestanding -std=gnu++11 -O2 -g -Wall -Wextra $(INCLUDE_DIRS)
BUILD_LDFLAGS	:= -nostdlib

# project specific configurations
TARGET_NAME := osdev.bin

