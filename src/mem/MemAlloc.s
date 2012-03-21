**************************************************************************
* Copyright (c) 2001 Jesper Svennevid. All rights reserved.              *
*                                                                        *
* Redistribution and use in source and binary forms, with or without     *
* modification, are permitted provided that the following conditions     *
* are met:                                                               *
*                                                                        *
*	Redistributions of source code must retain the above copyright   *
* notice, this list of conditions and the following disclaimer.          *
*                                                                        *
*	Redistributions in binary form must reproduce the above copyright*
* notice, this list of conditions and the following disclaimer in the    *
* documentation and/or other materials provided with the distribution.   *
*                                                                        *
* THIS SOFTWARE IS PROVIDED BY THE AUTHOR "AS IS" AND ANY EXPRESS OR     *
* IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED         *
* WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE     *
* ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY        *
* DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL     *
* DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE      *
* GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS          *
* INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER   *
* IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR        *
* OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN    *
* IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.                          *
**************************************************************************

	machine	68020

	section	code,code

*** mem.s

	; handles memory-allocations

	include	src/agaos.i

MEMTAG	equ	$C0CAC01A			; this must present to allow de-allocation

	incdir	include:

	include	exec/memory.i

	include	lvo/exec_lib.i

;****** AgaOS/MemAlloc ***********************************************
*
*   NAME
*	MemAlloc - Allocate a block of memory for use by the application
*
*   SYNOPSIS
*	block = MemAlloc(size,flags)
*	d0		 d0   d1
*
*	void* MemAlloc(ULONG size, ULONG flags);
*
*   FUNCTION
*
*   INPUT
*	size - Size of wanted memory-block
*	flags - Requirements of the wanted memory-blockFlags, specifying attributes of returned memory,
*		possible flags are: (mask together when using)
*
*		AAMEMF_CHIP:	Memory returned should reside in in the
*				chip memory.
*
*		AAMEMF_ALIGN:	Memory returned should be aligned to a
*				64-bit boundary.
*
*		AAMEMF_MMU:	Memory returned should be allocated so
*				the MMU can be used to modify attributes.
*				*** NOT IMPLEMENTED ***
*
*   RESULTS
*	block - Pointer to allocated block, or NULL if failed
*
*   NOTES
*
*   BUGS
*
*   SEE ALSO
*	MemFree()
*
**********************************************************************
*
* Allocate a block of memory for
* use by the application.
*
* IN:	d0 - Block size
*	d1 - Block flags
*
* OUT:	d0 - Memory block or NULL if
*	     failure.
*

_MemAlloc
	movem.l	d1-a6,-(sp)

	move.l	d0,d5
	move.l	d1,d6

	*** select memory-pool

	move.l	_PublicPool,a0

	btst	#AAMEMB_CHIP,d6
	beq	.not_chip_pool
	move.l	_ChipPool,a0
.not_chip_pool

	*** correct memory-size to make room for extra data

	btst	#AAMEMB_ALIGN,d6
	beq	.no_align_setup
	add.l	#8,d5				; 64-bit align
.no_align_setup

	add.l	#16,d5				; real pointer, size, pool, tagword

	*** make allocation

	move.l	_SysBase,a6
	move.l	a0,a5				; store memory-pool
	move.l	d5,d0
	jsr	_LVOAllocPooled(a6)

	move.l	d0,d3
	move.l	d0,d4
	beq	.Fail

	*** align memory to 64-bit boundaries

	btst	#AAMEMB_ALIGN,d6
	beq	.no_align
	add.l	#7,d4
	and.l	#$fffffff8,d4
.no_align

	*** clear memory

	move.l	d3,a1
	move.l	d5,d0

	*** store real pointer and size

	move.l	d4,a0
	move.l	d3,(a0)+			; unaligned pointer
	move.l	d5,(a0)+			; size
	move.l	a5,(a0)+			; memory-pool used
	move.l	#MEMTAG,(a0)+			; tag-word
	move.l	a0,d0

	movem.l	(sp)+,d1-a6
	rts

.Fail
	ERRMSG	ERR_MemAllocFail
	movem.l	(sp)+,d1-a6
	clr.l	d0
	rts

	section	data,data

	IFEQ	NOERRORMSGS

ERR_MemAllocFail	dc.b	"ERROR: Failed in MemAlloc()\n",0

	ENDC

	public	_ChipPool
	public	_PublicPool
