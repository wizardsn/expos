# Makefile

.SUFFIXES:
.SUFFIXES: .o .asm .s .c .cpp

# project specific configurations
include	project.mk

# include build engine
include make/core.mk

# first target is defined prior the engine
.PHONY: all
all:	target

# process root dir - run build engine
$(call init_make)

# project target should be defined after the engine
.PHONY:	target
target:	$(g_targets)

# include generated dynamic dependencies
ifneq "$(MAKECMDGOALS)" "clean"
-include $(g_dyndeps)
endif

# clean files
g_cleans	+=

# build system testing
.PHONY: test
test:
	@echo "Build params:"
	@echo "CC  - $(__cmd_cc)"
	@echo "CPP - $(__cmd_cpp)"
	@echo
	@echo "Build engine results:"
	@echo "sources:\n$(g_sources)\n"
	@echo "objects:\n$(g_objects)\n"
	@echo "libraries:\n$(g_libraries)\n"
	@echo "dyndeps:\n$(g_dyndeps)\n"
	@echo "cleans:\n$(g_cleans)\n"
	@echo "targets:\n$(g_targets)\n"
	@echo "srcdirs:\n$(g_srcdirs)\n"


# cleaning
.PHONY: clean
clean:
#	@echo "cleaning..."
	@rm -rf $(g_cleans) $(g_dyndeps)

# pattern compilation rules
# GNU as sources
$(obj)/%.o: %.s
	@echo "\nTODO: check dynamic dependecies generated for GNU as file"
	$(cmd_as) -Wp,-MD,$@.p.d -c $< -o $@
	@sed -e 's,^.*$(@F)*:,$@:,' < $@.p.d > $@.d
	@sed -e 's/#.*//' -e 's/^[^:]*: *//' -e 's/ *\\$$//' \
			-e '/^$$/ d' -e 's/$$/:/' < $@.p.d >> $@.d
	@rm	$@.p.d

# NASM/YASM sources
$(obj)/%.o: %.asm
	$(cmd_asm) -MD $@.p.d $< -o $@
	@cp $@.p.d $@.d
	@sed -e 's/#.*//' -e 's/^[^:]*: *//' -e 's/ *\\$$//' \
			-e '/^$$/ d' -e 's/$$/:/' < $@.p.d >> $@.d
	@rm $@.p.d

# GNU c sources
$(obj)/%.o: %.c
	$(cmd_cc) -Wp,-MD,$@.p.d -c $< -o $@
	@sed -e 's,^.*$(@F)*:,$@:,' < $@.p.d > $@.d
	@sed -e 's/#.*//' -e 's/^[^:]*: *//' -e 's/ *\\$$//' \
			-e '/^$$/ d' -e 's/$$/:/' < $@.p.d >> $@.d
	@rm	$@.p.d

# GNU cpp sources
$(obj)/%.o: %.cpp
	$(cmd_cpp) -Wp,-MD,$@.p.d -c $< -o $@
	@sed -e 's,^.*$(@F)*:,$@:,' < $@.p.d > $@.d
	@sed -e 's/#.*//' -e 's/^[^:]*: *//' -e 's/ *\\$$//' \
			-e '/^$$/ d' -e 's/$$/:/' < $@.p.d >> $@.d
	@rm	$@.p.d

