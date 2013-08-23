
targets	:= bootsect.img

ASMFLAGS_bootsect.img	:= -fbin -DSTAGE2_LMA=$(STAGE2_LMA)

$(obj)/bootsect.img:	$(src)/bootsect.asm
	$(cmd_asm) -fbin $^ -o $@
