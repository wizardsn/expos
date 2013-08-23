#
# example of build.mk for each directory
#
# subdirs := dir1 dir2 dir3
# $(eval $(build_subdirs)
#
# $(src) - path to the current source directory
# $(obj) - path to the output for this source directory
#
# objs-y	:= someobj.o
# cleans	:= somefile.log
# targets	:= custom_tgt.bin
# 
# someobj-y	:= depa.o depb.o
#
# objs-y-custom_tgt.bin := dep1.o dep2.o
# dep1-y	:= dep1_main.o dep1_lib.o
#
# cflags-y	:= GNU C compiler flags applied for all dir sources
# ldflags-y	:= <ldflags applied to the directory files linkning>
#
# CFLAGS_depa.o	:= <GNU C compiler flags for the depa.c file only>
# ASMFLAGS_custom_tgt.bin	:= <NASM/YASM flags for the file only, ex. -fbin>
#
# $(obj)/custom_tgt.bin:	$(src)/file.bin
#     <build commands for custom_tgt.bin>
#
