# Makefile

.SUFFIXES:
.SUFFIXES:	.c .o .asm .s

# project specific configurations
include	project.mk

# include build engine
include make/core.mk

# first target is defined prior the engine
.PHONY: all
all:	target

# process root dir - run build engine
include $(step_in)
include $(subdir_make)	# root dir makefile
include $(step_out)

# project target should be defined after the engine
.PHONY:	target
target:	$(g_targets)

# include generated dependencies
ifneq "$(MAKECMDGOALS)" "clean"
-include $(g_dyndeps)
endif

# clean files
g_cleans	+= build.log


# build system testing
.PHONY: test
test:
	@echo "Build engine results:"
	@echo "sources:\n$(g_sources)\n"
	@echo "objects:\n$(g_objects)\n"
	@echo "dyndeps:\n$(g_dyndeps)\n"
	@echo "cleans:\n$(g_cleans)\n"
	@echo "targets:\n$(g_targets)\n"
	@echo "srcdirs:\n$(g_srcdirs)\n"


# cleaning
.PHONY: clean
clean:
#	@echo "cleaning..."
	@rm -rf $(g_cleans) $(g_dyndeps)
#	@rm -r  $(if $(OUTDIR), $(addprefix $(OUTDIR)/,$(g_srcdirs),)


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
$(obj)/%.obj: %.asm
	$(cmd_asm) -MD $@.p.d $< -o $@
	@cp $@.p.d $@.d
	@sed -e 's/#.*//' -e 's/^[^:]*: *//' -e 's/ *\\$$//' \
			-e '/^$$/ d' -e 's/$$/:/' < $@.p.d >> $@.d
	@rm $@.p.d

# GNU c cources
$(obj)/%.o: %.c
	$(cmd_cc) -Wp,-MD,$@.p.d -c $< -o $@
	@sed -e 's,^.*$(@F)*:,$@:,' < $@.p.d > $@.d
	@sed -e 's/#.*//' -e 's/^[^:]*: *//' -e 's/ *\\$$//' \
			-e '/^$$/ d' -e 's/$$/:/' < $@.p.d >> $@.d
	@rm	$@.p.d
