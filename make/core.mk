#  
# this file contains functions to recursivly include make files for subdirectories
# the code is based on the article:
# http://locklessinc.com/articles/makefile_tricks/
#

# name of makefile in subdirectories
subdir_make		:= build.mk
# default target name
default_target	:= built-in.o

# these files save and restore current build context
step_in		:= make/step_in.mk
step_out	:= make/step_out.mk

# the per direcotry variables
# the set of below variables are defined for each directory, they are saved
# during step_in and step_out operations
#
# objs	- list of objects in the directory to be linked in default build object
# clean - file list to be cleaned (objs and custom targes are automaticaly add 
#		  here)
# targets - list of directory specific targets, custom targets
#
step_vars	:= objs-y targets clean $(dir_flags)

# directory specific build tools flags
dir_flags	:= cflags-y ldflags-y asflags-y asmflags-y
step_vars	+= $(dir_flags)

# example of build.mk
#
# SUBDIRS := dir1 dir2 dir3
# $(eval $(build_subdirs)
#
# objs := someobj.o
# clean := somefile.log
# targets := custom_tgt.bin
#
# objs-custom_tgt.bin := dep1.o dep2.o
#

# ****************************************

# debug trace
debug_print = $(if $(BUILD_DEBUG), $(shell echo "Process: Dir=$~ curdir=$~$(firstword $(1)) subdirs='$(SUBDIRS)' dirlist='$(dirlist)'" >> build.log), )

# Process all subdirs step by step
# This is the core of the build system

# cut the list: rest = rest [2 ... n]
rest = $(wordlist 2,$(words $(1)),$(1))

# recursive walk on subdirs
get_dirlist = $(debug_print) \
		$(step_in) \
		$~$(firstword $(1))/$(subdir_make) $(wildcard $~$(firstword $(1))/*.d) \
		$(step_out) \
		$(if $(rest), \
			$(call get_dirlist,$(rest)),)
scan_subdirs = $(if $(SUBDIRS), \
		 $(eval dirlist:=$(SUBDIRS) $(dirlist)) $(call get_dirlist,$(SUBDIRS)),)

# processing function called in makefiles
define build_subdirs
include $(scan_subdirs)
endef


# set_src:
# prepare path for sources
set_src = $(strip $(patsubst %/, %, $(1)))

# set_obj:
# prepare path for objects - under $(OUTDIR)
set_obj = $(strip $(if $(OUTDIR),\
	$(patsubst %/, %, $(patsubst %/, %, $(OUTDIR))/$(1)),\
	$(1)))

# init src and obj variables (usefull for main makefile)
~ :=
src	:= $(call set_src,$~)
obj := $(call set_obj,$(src))

# srcdirs will contain visited directory list after processing
srcdirs :=


# Functions used for directory processing (see step_out)

# ****************************************
# check if an object has submodules
# obj_parse ( <obj> <list> )
# add finded objects to the list
# obj-y := sobj1.o sobj2.o
define obj_parse

dummy := \
	$(if $(BUILD_DEBUG), \
	$(shell echo "\nobj_parse: $(1)" >> build.log ), \
	)

# add module to the list
$(2) += $(1)
clean += $(1)

# check if object has submodules
$(if $($(basename $(1))-y), \
	$(eval $(call comp_obj_rule,$(1), $($(basename $(1))-y))), \
	$(eval single_objects += $(1)))
endef

# ****************************************
# Define rule for composite object:
# comp_obj_rule ( <obj> <obj-deps> )
define comp_obj_rule

dummy := \
	$(if $(BUILD_DEBUG), \
	$(shell echo "\ncom_obj_rule: $(1): $(2)" >> build.log ), \
	)

clean += $(2)
single_objects += $(2)

# obj.o:	sobj1.o sobj2.o
#$(obj)/$(strip $(1)):	ldflags-y := -r
$(obj)/$(strip $(1)): 	$(addprefix $(obj)/,$(2))
	$$(call cmd_ld, $$@, -r $$^)
endef

# ****************************************
# link dir objects into single file
# dir_default_rule ( <dir_objects> )
define dir_default_rule

# add direcotry default target to global objects and cleans
g_objects += $(obj)/$(default_target)
clean += $(default_target)

# dir_path/built-in.o: <dir_objects.o> ...
#$(obj)/$(default_target): 	ldflags-y := -r
$(obj)/$(default_target):	$(addprefix $(obj)/, $(1)) 
	$$(call cmd_ld, $$@, -r $$^)
endef

# ****************************************
# add dependencies for custom target
# target_rule ( target <varname_of_deps> )
# target-deps := <dep1> <dep2>
define target_rule

dummy := \
	$(if $(BUILD_DEBUG), \
	$(shell echo "\ntarget_rule: $(1): $(2)" >> build.log ), \
	)

# rule: custom_target: <custom_deps>
$(obj)/$(strip $(1)):	$(addprefix $(obj)/,$(strip $(2)))
endef

# ****************************************
# check if target objects is defined and parse them
# target_obj_parse( <target> )
# obj-y-<target> := obj1.o obj2.o ...
# for composite objects separate rules are created
#
# create dependency rule: target: objects-<target>
define target_obj_parse

dummy := \
	$(if $(BUILD_DEBUG), \
	$(shell echo "\ntarget_obj_parse: $(1): $(objs-y-$(1))" >> build.log ), \
	)

g_targets += $(addprefix $(obj)/, $(strip $(1)))
clean += $(strip $(1))

tgt-objs:=
$(if $(objs-y-$(1)),\
	$(foreach object, $(objs-y-$(1)), \
		$(eval $(call obj_parse,$(object),tgt-objs)) \
	) \
	$(eval $(call target_rule,$(1), $(tgt-objs))),\
)
endef


# ****************************************
# Flags handling
# convert file name to var_name
clear_name	= $(subst /,_,$(strip $(dir $(1))))

# directory specific flags
ASFLAGS_DIR		= $(asflags-y_$(call clear_name,$(1)))
ASMFLAGS_DIR	= $(asmflags-y_$(call clear_name,$(1)))
CFLAGS_DIR		= $(cflags-y_$(call clear_name,$(1)))
LDFLAGS_DIR		= $(ldflags-y_$(call clear_name,$(1)))

# file specific flags
ASFLAGS_FILE	= $(ASFLAGS_$(notdir $(1)))
ASMFLAGS_FILE	= $(ASMFLAGS_$(notdir $(1)))
CFLAGS_FILE		= $(CFLAGS_$(notdir $(1)))
# it used only for auto rules as target specific variable
LDFLAGS_FILE	= $(ldflags-y)

# full flags
ASFLAGS		= $(BUILD_ASFLAGS) $(ASFLAGS_DIR) $(ASFLAGS_FILE)
ASMFLAGS	= $(BUILD_ASMFLAGS) $(ASMFLAGS_DIR) $(ASMFLAGS_FILE)
CFLAGS		= $(BUILD_CFLAGS) $(CFLAGS_DIR) $(CFLAGS_FILE)
LDFLAGS		= $(BUILD_LDFLAGS) $(LDFLAGS_DIR) $(LDFLAGS_FILE)

Q := $(if $(BUILD_DEBUG),@echo,)

# build commands
_as_cmd		= $(AS)	$(ASFLAGS) $(2) -c -o $(1)
_asm_cmd	= $(ASM) $(ASMFLAGS) $(2) -o $(1)
_cc_cmd		= $(CC) $(CFLAGS) $(2) -c -o $(1)
_ld_cmd		= $(LD) $(LDFLAGS) $(2) -o $(1)

cmd_as		= @echo "\tAS\t$(1)"; echo $(_as_cmd) >> build.log;	$(_as_cmd)
cmd_asm		= @echo "\tASM\t$(1)"; echo $(_asm_cmd) >> build.log;	$(_asm_cmd)
cmd_cc		= @echo "\tCC\t$(1)"; echo $(_cc_cmd) >> build.log;	$(_cc_cmd)
cmd_ld		= @echo "\tLD\t$(1)"; echo $(_ld_cmd) >> build.log;	$(_ld_cmd)



