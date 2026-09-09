#ifndef _MM_H
#define _MM_H

#define KERNEL_STACK (1 << 22)    // 0x400'000 = 4 MB
#define USER_STACK_TOP (1 << 23)  // 0x800'000

#ifndef __ASSEMBLER__

void memzero(void* ptr, unsigned long len);

#endif

#endif  // _MM_H
