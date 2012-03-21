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

*** vbl.s

	; handles the vertical blanking
	; interrupt

	*** local unit exports

	public	_VBLHookList
	public	_VBLSigMask
	public	_CopperPointer
	public	_MainVBLInterrupt
	public	_VBLSignal
	public	_VBLInterruptStruct

	include	src/agaos.i

	incdir	include:

	include	exec/nodes.i
	include	exec/interrupts.i

	include	hardware/custom.i
	include	hardware/intbits.i

	include	lvo/exec_lib.i

 STRUCTURE	VBH_VBHook,0
	APTR	VBH_Next
	APTR	VBH_Code
	APTR	VBH_Data
	LABEL	VBH_SIZEOF

;****** AgaOS/RemoveVBLHook ******************************************
*
*   NAME
*	RemoveVBLHook
*   SYNOPSIS
*	RemoveVBLHook(routine)
*			a0
*
*	void RemoveVBLHook(void*);
*
*   FUNCTION
*	Removes a already added routine from the VBL-hook chain. If
*	the routine is not added, it will do nothing.
*
*   INPUT
*	routine - Routine that should be removed.
*
*   RESULTS
*
*   NOTES
*	If you add the same routine more than once(but with different
*	user-data), they will be removed in reverse order.
*
*   BUGS
*
*   SEE ALSO
*
**********************************************************************
*
*
* Remove a hook from the VBL-interrupt
* processing chain.
*
* IN: a0 - pointer to hook-routine.
*

_RemoveVBLHook

	movem.l	d0-a6,-(sp)

	tst.l	a0
	beq	.no_hook

	sub.l	a2,a2
	sub.l	a3,a3
	sub.l	a4,a4
	move.l	_VBLHookList,a1
.hook_loop
	tst.l	a1
	beq	.hook_end

	move.l	VBH_Code(a1),d0
	cmp.l	a0,d0
	beq	.not_this_hook

	move.l	a1,a3
	move.l	a2,a4

.not_this_hook

	move.l	a1,a2
	move.l	VBH_Next(a1),a1
	bra	.hook_loop

.hook_end

	tst.l	a3
	beq	.no_hook

	tst.l	a4
	beq	.first_entry

	move.l	VBH_Next(a3),VBH_Next(a4)	; atomic?

	bra	.free_hook
.first_entry
	move.l	VBH_Next(a3),_VBLHookList	; atomic?

.free_hook

	move.l	a3,a0
	jsr	_MemFree

.no_hook

	movem.l	(sp)+,d0-a6
	rts
