/*
 * linker.ld: Example linker script for the lab 0 kernel This file is
 * not used: a similar file was used to create the .elf files we've
 * provided for this lab, which contain a complete kernel for testing.
 */

SECTIONS
{
    . = 0x80000;
    .text.boot : { *(.text.boot) }
    .text : { *(.text) }
    .rodata : { *(.rodata) }
    .data : { *(.data) }
    . = ALIGN(0x8);
    bss_begin = .;
    .bss : { *(.bss) }
    bss_end = .;
    kernel_end = .;
    . = ALIGN(4096);
    elf_executables_begin = .;
    .elf_executables : { *(.elf_executables) }
    elf_executables_end = .;


    /* Ensure that the kernel image does not grow inside processes kernel stacks
     * [0x90000, PROC_START=0xA0000]
    */
    ASSERT(elf_executables_end <= 0x90000,
           "kernel image overlaps the per-process kernel stacks at 0x90000")

     . = 0xE0000;
     .bgcolor : { *(.bgcolor) }

     . = 0xF0000;
     kernel_fb_begin = .;
     .kernel_fb (NOLOAD) : { *(.kernel_fb) }
     kernel_fb_end = .;


}
