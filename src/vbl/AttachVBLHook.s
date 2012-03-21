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

;****** AgaOS/AttachVBLHook ******************************************
*
*   NAME
*	AttachVBLHook - Attach a new routine that will be executed
*		in the vertical blanking period.
*
*   SYNOPSIS
*	success = AttachVBLHook(routine,userdata)
*	d0			a0	d0
*
*	BOOL AttachVBLHook(void*,ULONG);
*
*   FUNCTION
*
*   INPUT
*	routine - The routine that you want to execute at vertical
*		retrace. It must point to a valid code-segment that
*		ends with a RTS instruction.
*	userdata - This data will be passed into the routine when
*		it executes, and is placed in the register a0.
*   RESULTS
*	success - FALSE if we failed to add to internal VBL hook. This
*		should only happen if there was no memory to allocate.
*   NOTES
*
*   BUGS
*
*   SEE ALSO
*	RemoveVBLHook()
*
**********************************************************************
*
*
* Attach a hook to the VBL-interrupt
* processing chain. The processing scheme
* is first-to-last.
*
* The hook will be executed with userdata
* in a0.
*
* IN:	a0 - pointer to hook-routine
*    	d0 - hook userdata
*
* OUT:	d0 - FALSE if failed to add
*

_AttachVBLHook

	movem.l	d0-a6,-(sp)

	move.l	a0,a4
	move.l	d0,d4

	move.l	#VBH_SIZEOF,d0
	clr.l	d1
	jsr	_MemAlloc
	tst.l	d0
	beq	.Fail

	move.l	d0,a0

	*** fill in structure

	clr.l	VBH_Next(a0)
	move.l	a4,VBH_Code(a0)
	move.l	d4,VBH_Data(a0)

	*** attach to chain

	move.l	_VBLHookList,a1
	tst.l	a1
	beq	.first_entry

.not_last
	move.l	a1,a2

	move.l	VBH_Next(a1),a1
	tst.l	a1
	bne	.not_last

	move.l	a0,VBH_Next(a2)		; this should be atomic enough

	; scan to end of chain

	beq	.finished
.first_entry

	; first entry in list

	move.l	a0,_VBLHookList		; atomic enough for ya? :)

.finished

	movem.l	(sp)+,d0-a6
	st.l	d0
	rts

.Fail
	movem.l	(sp)+,d0-a6
	clr.l	d0
	rts
