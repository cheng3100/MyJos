/* See COPYRIGHT for copyright information. */

#include <inc/mmu.h>
#include <inc/memlayout.h>
#include <inc/trap.h>



###################################################################
# exceptions/interrupts
###################################################################

/* TRAPHANDLER defines a globally-visible function for handling a trap.
 * It pushes a trap number onto the stack, then jumps to _alltraps.
 * Use TRAPHANDLER for traps where the CPU automatically pushes an error code.
 *
 * You shouldn't call a TRAPHANDLER function from C, but you may
 * need to _declare_ one in C (for instance, to get a function pointer
 * during IDT setup).  You can declare the function with
 *   void NAME();
 * where NAME is the argument passed to TRAPHANDLER.
 */
#define TRAPHANDLER(name, num)						\
	.globl name;		/* define global symbol for 'name' */	\
	.type name, @function;	/* symbol type is function */		\
	.align 2;		/* align function definition */		\
	name:			/* function starts here */		\
	pushl $(num);							\
	jmp _alltraps

/* Use TRAPHANDLER_NOEC for traps where the CPU doesn't push an error code.
 * It pushes a 0 in place of the error code, so the trap frame has the same
 * format in either case.
 */
#define TRAPHANDLER_NOEC(name, num)					\
	.globl name;							\
	.type name, @function;						\
	.align 2;							\
	name:								\
	pushl $0;							\
	pushl $(num);							\
	jmp _alltraps

#define TN_2(trap, num) trap ## _ ## num
#define TN(num) TN_2(trap, num)
#define TN_DEC(num) .long TN_2(trap, num)

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */
.text
	TRAPHANDLER_NOEC(TN(T_DIVIDE), T_DIVIDE)
	TRAPHANDLER_NOEC(TN(T_DEBUG), T_DEBUG)
	TRAPHANDLER_NOEC(TN(T_NMI), T_NMI)
	TRAPHANDLER_NOEC(TN(T_BRKPT), T_BRKPT)
	TRAPHANDLER_NOEC(TN(T_OFLOW), T_OFLOW)
	TRAPHANDLER_NOEC(TN(T_BOUND), T_BOUND)
	TRAPHANDLER_NOEC(TN(T_ILLOP), T_ILLOP)
	TRAPHANDLER_NOEC(TN(T_DEVICE), T_DEVICE)
	TRAPHANDLER_NOEC(TN(T_DBLFLT), T_DBLFLT)
	TRAPHANDLER_NOEC(TN(T_TSS), T_TSS)
	TRAPHANDLER_NOEC(TN(T_SEGNP), T_SEGNP)
	TRAPHANDLER_NOEC(TN(T_STACK), T_STACK)
	TRAPHANDLER_NOEC(TN(T_GPFLT), T_GPFLT)
	TRAPHANDLER(TN(T_PGFLT), T_PGFLT)
	TRAPHANDLER_NOEC(TN(T_FPERR), T_FPERR)
	TRAPHANDLER_NOEC(TN(T_ALIGN), T_ALIGN)
	TRAPHANDLER_NOEC(TN(T_MCHK), T_MCHK)
	TRAPHANDLER_NOEC(TN(T_SIMDERR), T_SIMDERR)
	TRAPHANDLER_NOEC(TN(T_SYSCALL), T_SYSCALL)

	TRAPHANDLER_NOEC(TN(T_DEFAULT), T_DEFAULT)

.data
.global traps
traps:
	TN_DEC(T_DIVIDE)
	TN_DEC(T_DEBUG)
	TN_DEC(T_NMI)
	TN_DEC(T_BRKPT)
	TN_DEC(T_OFLOW)
	TN_DEC(T_BOUND)
	TN_DEC(T_ILLOP)
	TN_DEC(T_DEVICE)
	TN_DEC(T_DBLFLT)
	TN_DEC(T_DEFAULT)
	TN_DEC(T_TSS)
	TN_DEC(T_SEGNP)
	TN_DEC(T_STACK)
	TN_DEC(T_GPFLT)
	TN_DEC(T_PGFLT)
	TN_DEC(T_DEFAULT)
	TN_DEC(T_FPERR)
	TN_DEC(T_ALIGN)
	TN_DEC(T_MCHK)
	TN_DEC(T_SIMDERR)
		

	TN_DEC(T_DEFAULT)
	TN_DEC(T_DEFAULT)
	TN_DEC(T_DEFAULT)
	TN_DEC(T_DEFAULT)
	TN_DEC(T_DEFAULT)
	TN_DEC(T_DEFAULT)
	TN_DEC(T_DEFAULT)
	TN_DEC(T_DEFAULT)
	TN_DEC(T_DEFAULT)
	TN_DEC(T_DEFAULT)
	TN_DEC(T_DEFAULT)
	TN_DEC(T_DEFAULT)
	TN_DEC(T_DEFAULT)
	TN_DEC(T_DEFAULT)
	TN_DEC(T_DEFAULT)
	TN_DEC(T_DEFAULT)
	TN_DEC(T_DEFAULT)
	TN_DEC(T_DEFAULT)
	TN_DEC(T_DEFAULT)
	TN_DEC(T_DEFAULT)
	TN_DEC(T_DEFAULT)
	TN_DEC(T_DEFAULT)
	TN_DEC(T_DEFAULT)
	TN_DEC(T_DEFAULT)
	TN_DEC(T_DEFAULT)
	TN_DEC(T_DEFAULT)
	TN_DEC(T_DEFAULT)
	TN_DEC(T_DEFAULT)

	TN_DEC(T_SYSCALL)

/*
 * Lab 3: Your code here for _alltraps
 */
.text
_alltraps:
	pushl %ds
	pushl %es
	pushal

	movw $(GD_KD), %ax
	movw %ax, %ds
	movw %ax, %es

	pushl %esp
	call trap
	leal 4(%esp), %esp

	trap_ret:
	popal
	popl %es
	popl %ds
	leal 8(%esp), %esp	// trapno and err
	iret

