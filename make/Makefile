# Makefile

.SUFFIXES:
.SUFFIXES:	.c .o .asm .s

# include build engine
include make/core.mk

# configuration options
OUTDIR := out
BUILD_DEBUG := y

TARGET_NAME := image.bin

# build tools
CC	:= @echo "\tCC ="; echo gcc
LD	:= @echo "\tLD ="; echo gcc
AS	:= @echo "\tAS ="; echo gcc
ASM := @echo "\tASM ="; echo yasm

# build flags
CFLAGS		:= -m32 -std=gnu99 -masm=intel -Wall
LDFLAGS		:= --warn-unresolved-symbols
ASFLAGS		:= -mmnemonic=intel -msyntax=intel -mnaked-reg
ASMFLAGS	:= -f elf32 -w+orphan-labels

# comamnds
cc_cmd		= $(CC) $(CFLAGS) $(CFLAGS_DIR) -c -o $(1) $(2) | tee -a build.log; touch $(1)
ld_cmd		= $(LD) $(LDFLAGS) -o $(1) $(2) | tee -a build.log; touch $(1)
ld_r_cmd	= $(LD) $(LDFLAGS) -r -o $(1) $(2) | tee -a build.log; touch $(1) 
as_cmd		= $(AS) $(ASFLAGS) -c -o $(1) $(2) | tee -a build.log; touch $(1)
asm_cmd		= $(ASM) $(ASMFLAGS) -o $(1) $(2) | tee -a build.log; touch $(1)


# Global lists
g_sources :=
g_objects :=
g_targets :=
cleanfiles := build.log

# Project target should be defined before subdirs
.PHONY: all
all:	target

# We need to go deeper
SUBDIRS := kernel boot
$(eval $(build_subdirs))


# build project
.PHONY:	target
target: $(obj)/$(TARGET_NAME) $(g_targets)

$(obj)/$(TARGET_NAME): $(g_objects)
	$(call ld_cmd,$@,$^)

# debug print
dummy := \
	$(if $(BUILD_DEBUG), \
	$(shell echo "Makefile: stack[$(dstackp)]=$(dstack$(dstackp)) src='$(src)' obj='$(obj)' dirlist='$(dirlist)' dirs='$(srcdirs)' g_objects" >> build.log ), \
	)

# Automtic rules
$(obj)/%.o: %.c Makefile
	$(call cc_cmd,$@,$<)

.PHONY: clean
clean:
	@echo "cleaning ...\n"
	@echo "cleanfiles:\n $(cleanfiles)\nobjects:\n $(g_objects)\n"
	@rm -rf -v $(cleanfiles)
	@rm -r $(OUTDIR)/$(srcdirs)