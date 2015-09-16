# We need to go deeper
subdirs := kernel
$(call add_subdirs)

# project target
targets	:= $(TARGET_NAME)

# project target rule
$(obj)/$(TARGET_NAME): $(g_targets) $(g_objects)
	@echo "Building image: $@ ($^)"
	@cat $^ > $@
	@echo "Image $@ is ready!"

tmp/hdd.img: $(obj)/$(TARGET_NAME)
	@dd if=$< of=tmp/hdd.img conv=notrunc

bochs: tmp/hdd.img tools/bochsrc.txt
	@echo "running bochs emulator"
	@bochs -qf tools/bochsrc.txt

qemu: tmp/hdd.img
	@echo "running qemu"
	@qemu -hda tmp/hdd.img

