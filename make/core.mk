#  
# this file contains functions to recursivly include make files for subdirectories
# the code is based on the article:
# http://locklessinc.com/articles/makefile_tricks/
#

# Global lists of files
# these lists are populated by build engine
# they should be used in main Makefile to finish the build
g_sources   :=
g_objects   :=
g_libraries :=
g_dyndeps   :=
g_targets   :=
g_srcdirs   :=
g_cleans    := build.log

# name of makefile in subdirectories
subdir_make     := build.mk
# default target name
default_target  := built-in.o

# these files save and restore current build context
step_in     := make/step_in.mk
step_out    := make/step_out.mk

# direcotry specific variables
# the set of below variables are defined for each directory to be unique
# and initialized with empty values
# the are saved and restored during directory traversal
#
# objs-y    - list of objects in the directory to be linked in default build object
# cleans    - file list to be cleaned (objs and custom targes are automaticaly add 
#             here)
# libs-y    - list of libraries to be added to final target
# targets   - list of directory specific targets, custom targets
#
step_vars   := objs-y libs-y targets cleans

# these vars are like step_vars, but inherit the initial values from parent dir
# can be used to override global configuration for the current directory
dirsafe_vars := DEBUG CC CPP AS ASM LD

# directory specific build tools flags
# these flags take affect for the whole directory
#
# cflags-y   - GNU C compiler flags
# cppflags-y - GNU C++ compiler flags
# ldflags-y  - GNU linker flags
# asflags-y  - GNU as assembeler flags
# asmflags   - NASM/YASM assembler flags
#
dir_flags   := asflags-y asmflags-y cflags-y cppflags-y ldflags-y 
step_vars   += $(dir_flags)

# ****************************************

# debug trace
debug_print = $(if $(BUILD_DEBUG), $(shell echo "Process: Dir=$~ curdir=$~$(firstword $(1)) subdirs='$(subdirs)' dirlist='$(dirlist)'" >> build.log), )

# ****************************************
# init function - to be called from main Makefile

define __init_make
include $(step_in)
include $(subdir_make)
include $(step_out)
endef

define init_make
$(eval $(__init_make))
endef

# ****************************************
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

scan_subdirs = $(if $(subdirs), \
		 $(eval dirlist:=$(subdirs) $(dirlist))\
		 $(call get_dirlist,$(subdirs)),)

define __add_subdirs
include $(scan_subdirs)
endef

# function is to be called in subdirs makefiles
define add_subdirs
$(eval $(__add_subdirs))
endef

# ****************************************
# set_src:
# prepare path for sources
set_src = $(strip $(patsubst %/, %, $(1)))

# set_obj:
# prepare path for objects - under $(OUTDIR)
# for root dir it would be . or $(OUTDIR)
set_obj = $(strip $(if $(OUTDIR),\
	$(patsubst %/, %, $(patsubst %/, %, $(OUTDIR))/$(1)),\
	$(if $(1),$(1),.)))

# init src and obj variables (usefull for main makefile)
~ :=
src := $(call set_src,$~)
obj := $(call set_obj,$(src))

# Functions used for directory processing (see step_out)

# ****************************************
# check if an object has submodules
# obj_parse (<obj> <list>)
# add finded objects to the list
# obj-y := sobj1.o sobj2.o
define obj_parse

dummy := \
	$(if $(BUILD_DEBUG), \
	$(shell echo "\nobj_parse: ($(1),$(2))" >> build.log ), )

# add object module to the objs list and cleans
$(2) += $(1)

# check if object has submodules, otherwise add it to single_objects
$(if $(filter %.o,$(1)), \
	$(if $($(basename $(1))-y), \
		$(eval $(call comp_obj_parse,$(1),$($(basename $(1))-y))), \
		$(eval single_objects += $(1)) \
		$(eval cleans += $(1)) \
	) \
,)
endef

# ****************************************
# comp_obj_parse (<obj>, <objs + deps> )
# obj-y := sobj1.o sobj2.o dep3
define comp_obj_parse

dummy := \
	$(if $(BUILD_DEBUG), \
	$(shell echo "\ncomp_obj_parse: ($(1), $(2))" >> build.log ), )

# parse dep objects recursively, obj_deps is tricky saved, returned from obj_parse
obj_deps :=
$(foreach object, $(2), \
	$(eval $(call obj_parse,$(object),obj_deps)) )

$(if $(filter %.o,$(obj_deps)), \
	$(eval $(call comp_obj_rule,$(1),$(filter %.o,$(obj_deps)))) )

$(if $(filter-out %.o,$(obj_deps)), \
	$(eval $(call comp_obj_deps_rule,$(1),$(filter-out %.o,$(obj_deps)))) )
endef

# ****************************************
# Define rule for composite object:
# comp_obj_rule ( <obj> <sub_objs> )
define comp_obj_rule

dummy := \
	$(if $(BUILD_DEBUG), \
	$(shell echo "\ncom_obj_rule: $(obj)/$(strip $(1)): $(addprefix $(obj)/,$(strip $(2)))" >> build.log ), )

cleans += $(1)

# obj.o:    sobj1.o sobj2.o
$(obj)/$(strip $(1)):   $(addprefix $(obj)/,$(strip $(2)))
	$$(cmd_ld) -o $$@ -r $$(filter %.o, $$^)
endef

# ****************************************
# Define rule for composite object:
# comp_obj_deps_rule ( <obj> <obj-deps> )
define comp_obj_deps_rule

dummy := \
	$(if $(BUILD_DEBUG), \
	$(shell echo "\ncom_obj_deps_rule: ($(1): $(src)/$(2))" >> build.log ), )

# obj.o: dep1 dep2
$(obj)/$(strip $(1)):   $(strip $(2))
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
$(obj)/$(strip $(1)):   $(addprefix $(obj)/,$(strip $(2)))
endef

# ****************************************
# add dependencies for custom target
# target_deps_rule ( target <varname_of_deps> )
# target-deps := <dep1> <dep2>
define target_deps_rule

dummy := \
	$(if $(BUILD_DEBUG), \
	$(shell echo "\ntarget_deps_rule: $(1): $(2)" >> build.log ), \
	)

# rule: custom_target: <custom_deps>
$(obj)/$(srip $(1))):   $(strip $(2))
endef

# ****************************************
# check if target objects are defined and parse them
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

g_targets += $(addprefix $(obj)/,$(strip $(1)))
cleans += $(strip $(1))

tgt_objs:=
$(if $(objs-y-$(1)),\
	$(foreach object, $(objs-y-$(1)), \
		$(eval $(call obj_parse,$(object),tgt_objs)) \
	) \
)

# handle object deps from obj dir
$(if $(filter %.o,$(tgt_objs)), \
	$(eval $(call target_rule,$(1),$(filter %.o,$(tgt_objs)))) )

# other file deps as src dir
$(if $(filter-out %.o,$(tgt_objs)), \
	$(eval $(call target_deps_rule,$(1),$(filter-out %.o,$(tgt_objs)))) )
endef


# ****************************************
# Flags handling
# convert file name to var_name
clear_name      = $(subst /,_,$(strip $(dir $(1))))

# directory specific flags
ASFLAGS_DIR     = $(asflags-y_$(call clear_name,$@))
ASMFLAGS_DIR    = $(asmflags-y_$(call clear_name,$@))
CFLAGS_DIR      = $(cflags-y_$(call clear_name,$@))
CPPFLAGS_DIR    = $(cflags-y_$(call clear_name,$@))
LDFLAGS_DIR     = $(ldflags-y_$(call clear_name,$@))

# file specific flags
ASFLAGS_FILE    = $(ASFLAGS_$(notdir $@))
ASMFLAGS_FILE   = $(ASMFLAGS_$(notdir $@))
CFLAGS_FILE     = $(CFLAGS_$(notdir $@))
CPPFLAGS_FILE   = $(CFLAGS_$(notdir $@))
# it used only for auto rules as target specific variable
LDFLAGS_FILE    = $(LDFLAGS_$(notdir $@))

# full flags
ASFLAGS     = $(BUILD_ASFLAGS)  $(ASFLAGS_DIR)  $(ASFLAGS_FILE)
ASMFLAGS    = $(BUILD_ASMFLAGS) $(ASMFLAGS_DIR) $(ASMFLAGS_FILE)
CFLAGS      = $(BUILD_CFLAGS)   $(CFLAGS_DIR)   $(CFLAGS_FILE)
CPPFLAGS    = $(BUILD_CPPFLAGS) $(CPPFLAGS_DIR) $(CPPFLAGS_FILE)
LDFLAGS     = $(BUILD_LDFLAGS)  $(LDFLAGS_DIR)  $(LDFLAGS_FILE)

# build commands
__cmd_as    = $(AS)  $(ASFLAGS)
__cmd_asm   = $(ASM) $(ASMFLAGS)
__cmd_cc    = $(CC)  $(CFLAGS)
__cmd_cpp   = $(CPP) $(CPPFLAGS)
__cmd_ld    = $(LD)  $(LDFLAGS)

cmd_as      = $(if $(BUILD_DEBUG),,@echo "\tAS\t$@";)  $(__cmd_as)
cmd_asm     = $(if $(BUILD_DEBUG),,@echo "\tASM\t$@";) $(__cmd_asm)
cmd_cc      = $(if $(BUILD_DEBUG),,@echo "\tCC\t$@";)  $(__cmd_cc)
cmd_cpp     = $(if $(BUILD_DEBUG),,@echo "\tCPP\t$@";) $(__cmd_cpp)
cmd_ld      = $(if $(BUILD_DEBUG),,@echo "\tLD\t$@";)  $(__cmd_ld)

