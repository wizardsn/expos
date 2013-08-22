#
# step_out.mk
#
# Called after including a sub directory makefile

# the goal of this file is to populate global objects list with
# directory objects and files, 
# separete rules are created for composite objects and custom targets
#
# all prodused files  should be added to $(clean) variable for auto cleaning
# 

# debug prints
dummy := \
	$(if $(BUILD_DEBUG), \
	$(shell echo "<<< make_after: stack[$(dstackp)]=$(dstack$(dstackp)) src='$(src)' obj='$(obj)'" >> build.log ), \
	)

# add current dir to $(srcdirs)
srcdirs += $~

# create output directory structure
$(if $(OUTDIR), \
	$(shell if [ ! -d $(obj) ]; then mkdir -p $(obj); fi),)

# collect all simple objects into the variable
single_objects :=


# objs handling:
# walk through $(objs-y) defined in the directory and populate $(dir_objects)
# add build rule for composite objects:
# obj-y := sobj1.o sobj2.o
#
# note: $(dir_objects) does not include sub-objects (ex. sobj1.o sobj2.o)
dir_objects := 
$(foreach object, $(objs-y), \
	$(eval $(call obj_parse,$(object), dir_objects)))


# default_target handling:
# create default target from $(dir_objects) if any
# and then added to global objects and cleans
$(if $(dir_objects), \
		$(eval $(call dir_default_rule,$(dir_objects))), )


# custom target handling:
# it is similar to $(objs-y) handling
# for each custom target walks through objs-y-<target> including composite objects
$(foreach tgt, $(targets), \
	$(eval $(call target_obj_parse,$(tgt))))


# tool flags for directory handling:
# Xflags-y options are applied to all %.X sources in the directory
$(foreach flags, $(dir_flags), \
	$(if $($(flags)), \
		$(eval $(flags)_$(call clear_name,$(obj)/) := $($(flags))), ) )


# Add dir clean files to global clean files
cleanfiles += $(addprefix $(obj)/,$(clean))

# restore old context of the directory
$(foreach var, $(step_vars), \
	$(eval $(var) := $($(var)_stack$(dstackp))) )

# Restore directory name - step out
~ := $(dstack$(dstackp))
src := $(call set_src,$~)
obj := $(call set_obj,$(src))
dstackp := $(basename $(dstackp))
