#ifndef _UTILS_H
#define _UTILS_H

#include "types.h"

#define Register(reg) ((volatile uint32*)(reg))
#define ReadRegister(reg) (*(Register(reg)))
#define WriteRegister(reg, v) (*(Register(reg)) = (v))

unsigned int delay_cycles(uint64);

// Prints str to the console and loop forever
__attribute__((noreturn)) void panic(const char* fmt, ...);

// Copy n bytes of src into dest
// (works with overlapping memory)
void* memmove(void* dest, const void* src, uint64 n);

// Wrapper around memmove
void* memcpy(void* dest, const void* src, uint64 n);

void memset(void* s, uint8 c, size_t n);

#endif  // _UTILS_H
