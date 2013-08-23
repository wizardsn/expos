# We need to go deeper
subdirs := boot kernel
$(eval $(build_subdirs))

# project target
targets	:= $(TARGET_NAME)

# project target rule
$(obj)/$(TARGET_NAME): $(g_targets)
	@echo "Building image: $@ ($^)"
	@cat $^ > $@
	@echo "Image $@ is ready!"
