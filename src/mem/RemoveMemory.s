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

;*****i* AgaOS/RemoveMemory ******************************************
*
*   NAME
*	RemoveMemory - Uninitialize the memory-subsystem.
*
*   SYNOPSIS
*
*   FUNCTION
*
*   INPUT
*
*   RESULTS
*
*   NOTES
*
*   BUGS
*
*   SEE ALSO
*
**********************************************************************
*
* Uninitialize the memory-subsystem.
*
* IN:	void
*
* OUT:	void
*

_RemoveMemory
	movem.l	d0-a6,-(sp)

	*** delete memory-pools

	tst.l	_PublicPool
	beq	.no_publicpool

	move.l	_SysBase,a6
	move.l	_PublicPool,a0
	jsr	_LVODeletePool(a6)

.no_publicpool

	tst.l	_ChipPool
	beq	.no_chippool

	move.l	_SysBase,a6
	move.l	_ChipPool,a0
	jsr	_LVODeletePool(a6)

.no_chippool

	movem.l	(sp)+,d0-a6
	rts

	public	_ChipPool
	public	_PublicPool
