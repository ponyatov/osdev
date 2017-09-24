// FORTH Virtual Machine

#ifndef _H_HPP
#define _H_HPP

							// FVM configuration
#define Msz 0x10000
#define Rsz 0x1000
#define Dsz 0x100

#include <stdint.h>

extern uint8_t  M[Msz];		// main memory (bytecode and data storage)
extern uint32_t Ip;			// instruction pointer
extern  int32_t D[Dsz],Dp;	// data stack
extern uint32_t R[Rsz],Rp;	// return stack

#endif // _H_HPP
