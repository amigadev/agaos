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

;****** AgaOS/MemFree ************************************************
*
*   NAME
*	MemFree - Free memory block
*
*   SYNOPSIS
*	MemFree(block)
*		a0
*
*	void MemFree(void* block);
*
*   FUNCTION
*
*   INPUT
*	block - Pointer to block that should be freed.
*
*   RESULTS
*
*   NOTES
*	If the memory-tag in the header has been touched,
*	memory will not be freed and a warning will be
*	displayed when the application exits.
*
*   BUGS
*
*   SEE ALSO
*	MemAlloc()
*
**********************************************************************
*
* Free memory-block.
*
* IN:   a0 - Memory block to free.
*
* OUT:	void
*

_MemFree
	movem.l	d0-a6,-(sp)

	cmp.l	#MEMTAG,-(a0)
	bne	.not_valid_allocation

	move.l	-(a0),a1			; pool used
	move.l	-(a0),d0			; size
	move.l	-(a0),a0			; real pointer
	exg.l	a0,a1				; pool & pointer switch places (for syscall)

	move.l	_SysBase,a6
	jsr	_LVOFreePooled(a6)

	movem.l	(sp)+,d0-a6
	rts

.not_valid_allocation

	ERRMSG	ERR_MemNotFreed
	movem.l	(sp)+,d0-a6
	rts

	section	data,data

	IFEQ	NOERRORMSGS

ERR_MemNotFreed		dc.b	"WARNING: Memory-header mismatch, block not freed!\n",0

	ENDC

	public	_ChipPool
	public	_PublicPool
