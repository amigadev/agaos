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

_MainVBLInterrupt
* * * * * * * * * * * * * * * * * * * *
*
* Main internal VBL interrupt
*
* * * * * * * * * * * * * * * * * * * *

	movem.l	d0-a6,-(sp)

	*** Install copper, if any

	move.l	_CopperPointer(pc),a0
	tst.l	a0
	beq	.no_copper

	lea.l	$dff000,a5			; get pointer to hardware
	move.l	a0,cop1lc(a5)			; write new address
	move.w	#0,copjmp1(a5)			; touch strobe

.no_copper

	*** Increase frame-based timer

	add.l	#1,_VBLTimer

	*** traverse vbl-hooks

	move.l	_VBLHookList,a1
.hook_loop
	tst.l	a1
	beq	.hooks_finished

	move.l	VBH_Code(a1),a2
	move.l	VBH_Data(a1),a0

	movem.l	a1,-(sp)
	jsr	(a2)
	movem.l	(sp)+,a1
	
	move.l	VBH_Next(a1),a1
	bra	.hook_loop
.hooks_finished

	*** notify task if sleeping (will be processed when we return)

	move.l	_SysBase,a6
	move.l	_PtrTask,a1
	move.l	_VBLSigMask,d0
	jsr	_LVOSignal(a6)

	movem.l	(sp)+,d0-a6
	sub.l	d0,d0			; set Z condition
	rts

_CopperPointer	ds.l	1

	section	bss,bss

_VBLHookList	ds.l	1

_VBLSigMask	ds.l	1
_VBLTimer	ds.l	1
