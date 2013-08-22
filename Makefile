# Makefile

.SUFFIXES:
.SUFFIXES:	.c .o .asm .s

# include build engine
include make/core.mk

# configuration options
OUTDIR := out
BUILD_DEBUG := y

TARGET_NAME := wzoskrnl.img

# project specific variables
KERNEL_LMA	:= 0x200000

# build tools
AS	:= gcc
ASM := nasm
CC	:= gcc
LD	:= ld

# Project include directories
INCLUDE		:= include/
INCLUDE		:= $(addprefix -I ,$(INCLUDE))

# build flags
BUILD_ASFLAGS	:= -mmnemonic=intel -msyntax=intel -mnaked-reg $(INCLUDE)
BUILD_ASMFLAGS	:= -felf32 -w+orphan-labels $(INCLUDE)
BUILD_CFLAGS	:= -ffreestanding -std=gnu99 -m32 -march=i686 -fno-builtin -g \
				-nostdinc $(INCLUDE)
BUILD_LDFLAGS	:= -nostdlib -melf_i386

# Global lists
g_sources	:=
g_objects	:=
g_targets	:=
cleanfiles	:= build.log

# Project target should be defined before subdirs
.PHONY: all
all:	target

# We need to go deeper
SUBDIRS := boot kernel
$(eval $(build_subdirs))

# build project
.PHONY:	target
target:	$(obj)/$(TARGET_NAME)

# Project target rule
$(obj)/$(TARGET_NAME): $(g_targets)
	@echo "Building image: $@ ($^)"
	@cat $^ > $@
	@echo "Image $@ is ready!"

.PHONY: clean
clean:
	@echo "cleaning ...\n"
	@echo "cleanfiles:\n $(cleanfiles)\nobjects:\n $(g_objects)\ntargets: $(g_targets)\n"
	@rm -rf -v $(cleanfiles)
	@rm -rv $(addprefix $(OUTDIR)/, $(srcdirs))

# Pattern compilation rules
# GNU as sources
$(obj)/%.o: %.s
	$(call cmd_as, $@, $^)

# NASM/YASM sources
$(obj)/%.obj: %.asm
	$(call cmd_asm, $@, $^)

# GNU c cources
$(obj)/%.o: %.c
	$(call cmd_cc, $@, $^)
