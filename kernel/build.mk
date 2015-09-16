subdirs := arch/x86_64
$(call add_subdirs)

objs-y := kernel.o

kernel-y := f2.o $(src)/file1.bin

f2-y := f1.o $(src)/Makefile

f1-y := main.o

