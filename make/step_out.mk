#
# step_out.mk
#
# Called after including a sub directory makefile

# the goal of this file is to populate global objects list with
# directory objects and files, 
# separete rules are created for composite objects and custom targets
#
# all prodused files should be added to $(clean) variable for auto cleaning
# 

# debug print
dummy := \
    $(if $(BUILD_DEBUG), \
    $(shell echo "<<< make_after: stack[$(dstackp)]=$(dstack$(dstackp)) src='$(src)' obj='$(obj)'" >> build.log ), \
    )

# add current dir to $(srcdirs)
g_srcdirs += $~

# create output directory structure
$(if $(OUTDIR), \
    $(shell if [ ! -d $(obj) ]; then mkdir -p $(obj); fi),)

# collect all simple objects (used internally)
single_objects :=

# objs-y handling:
# Parse $(objs-y) as complex object
# add build rule for composite objects and their childs recursively
# objs-y := sobj1.o sobj2.o
#
# note: $(dir_objects) does not include sub-objects (ex. sobj1.o sobj2.o)
$(eval $(call comp_obj_parse,$(default_target),$(objs-y)))

# default_target handling:
# create default target from $(dir_objects) if any
# and then added to global objects and cleans
dir_objects := $(filter %.o, $(objs-y))
$(if $(dir_objects), \
    $(eval g_objects += $(obj)/$(default_target) ) )

# custom target handling:
# it is similar to $(objs-y) handling
# for each custom target walk through objs-y-<target> including composite objects
$(foreach tgt, $(targets), \
    $(eval $(call target_obj_parse,$(tgt))))


# tool flags for directory handling:
# Xflags-y options are applied to all %.X sources in the directory
$(foreach flags, $(dir_flags), \
    $(if $($(flags)), \
        $(eval $(flags)_$(call clear_name,$(obj)/) := $($(flags))), ) )

# Add dyndeps files to global list
g_dyndeps += $(addprefix $(obj)/,$(addsuffix .d,$(single_objects)))

# additional libraries handling:
g_libraries += $(libs-y)

# Add dir clean files to global clean files
g_cleans += $(addprefix $(obj)/,$(cleans) $(g_dyndeps))

# Add single objects to source list
g_sources += $(addprefix $(src)/, $(single_objects))

# restore old context of the directory
$(foreach var, $(step_vars), \
    $(eval $(var) := $($(var)_stack$(dstackp))) )

$(foreach var, $(dirsafe_vars), \
    $(eval $(var) := $($(var)_stack$(dstackp))) )

# Restore directory name - step out
~       := $(dstack$(dstackp))
src     := $(call set_src,$~)
obj     := $(call set_obj,$(src))
dstackp := $(basename $(dstackp))

