# Called before including a sub directory makefile

# Save directory name
dstackp := $(dstackp).x
dstack$(dstackp) := $~

# save current context of directory
# these variables are saved for each directory
# step_vars is defined in core.mk
$(foreach var, $(step_vars), \
	$(eval $(var)_stack$(dstackp) := $($(var))) \
	$(eval $(var) := )  )

# init subdirs
subdirs :=

# Build directory name - step in
~ := $(if $(dirlist),$(strip $~$(firstword $(dirlist)))/,)
src := $(call set_src,$~)
obj := $(call set_obj,$(src))

# Remove current directory from list
dirlist := $(call rest,$(dirlist))

# debug print
dummy := \
	$(if $(BUILD_DEBUG), \
	$(shell echo ">>> make_before: stack[$(dstackp)]=$(dstack$(dstackp)) src='$(src)' obj='$(obj)' dirlist='$(dirlist)'" >> build.log ), \
	)

