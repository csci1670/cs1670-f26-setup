.PHONY: clean format

HOST_OS = $(shell uname -s)

ifndef IN_CONTAINER
ifneq ("$(wildcard /etc/image-version)","")
    IN_CONTAINER = 1
else
    IN_CONTAINER = 0
endif
endif

# Try to infer the correct TOOLPREFIX if not set
ifndef TOOLPREFIX
ifeq ($(HOST_OS), Darwin)
# MacOS
TOOLPREFIX = aarch64-elf-
else
# Linux/Windows
ifneq ($(shell uname -m), aarch64)
TOOLPREFIX = aarch64-linux-gnu-
endif
endif
endif


GCC = $(TOOLPREFIX)gcc
LD = $(TOOLPREFIX)ld
OBJCOPY = $(TOOLPREFIX)objcopy
PYTHON ?= python3

QEMU ?= qemu-system-aarch64

CFLAGS = -Wall -Wextra -Werror -g -std=gnu2x
# Tell compiler to avoid automatically linking the C standard library and Linux/MacOS startup files
CFLAGS += -nostdlib -nostartfiles -ffreestanding
# Prevent compiler from using floating point and SIMD registers in kernel code
CFLAGS += -mgeneral-regs-only

# Modify the number of debug prints
DEBUG_LVL ?= 0
ifeq ($(DEBUG_LVL),0)
    CFLAGS += -DDEBUG_LEVEL=0
else ifeq ($(DEBUG_LVL),1)
    CFLAGS += -DDEBUG_LEVEL=1
else ifeq ($(DEBUG_LVL),2)
    CFLAGS += -DDEBUG_LEVEL=2
else
    $(error Invalid DEBUG_LEVEL value: $(DEBUG_LEVEL). Must be 0, 1 or 2)
endif


ASMFLAGS = -g


K = kernel
U = user

# Find all the source files for kernel code
KSRCS  := $(wildcard $(K)/*.c $(K)/drivers/*.c)
KASM   := $(wildcard $(K)/*.S)
KOBJS  := $(KASM:%.S=%.o) $(KSRCS:%.c=%.o)

DEPSDIR = .deps
DEPS := $(shell find $(DEPSDIR) -name '*.d' 2>/dev/null)

all: kernel8.img

clean:
	rm -rf kernel8.img
	find $(K) -name *.o -delete
	rm -f bgcolor.bin
	rm -rf $(DEPSDIR)

format:
	find . -name *.[c,h] | xargs clang-format -i

ifneq ($(DEPS),)
include $(DEPS)
endif

###################
# kernel files
###################

$(K)/bgcolor.o: $(K)/bgcolor.c
	mkdir -p $(@D)
	$(GCC) $(CFLAGS) -MMD -Ikernel -c $< -o $@

# Re-create the kernel image, replacing the contents of the .bgcolor
# section with our new version
OBJCOPY_ARGS = --update-section .bgcolor=bgcolor.bin
bgcolor.bin: $(K)/bgcolor.o
	$(OBJCOPY) $(K)/bgcolor.o --dump-section .bgcolor=bgcolor.bin
	@touch bgcolor.bin # Create a blank file if does not exist

kernel8.img: $(K)/kernel8.elf bgcolor.bin
	$(OBJCOPY) $(K)/kernel8.elf -O binary $(OBJCOPY_ARGS) kernel8.img

###################
# QEMU
###################

include qemu.mk


