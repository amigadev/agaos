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

;****** AgaOS/WaitVBL ************************************************
*
*   NAME
*	WaitVBL - Wait for vertical retrace
*
*   SYNOPSIS
*	WaitVBL()
*
*	void WaitVBL(void);
*
*   FUNCTION
*	This function sets the task into a waiting state that will
*	be triggered when the vertical blanking interrupt has finished
*	executing.
*
*   INPUT
*
*   RESULTS
*
*   NOTES
*	As AmigaOS is still executing in the background, it will be
*	allowed to execute while we are inside this function. This
*	is only a side-effect of exec/Wait(), but it´s what we want.
*
*   BUGS
*
*   SEE ALSO
*
**********************************************************************
*
*
* Wait for screen retrace (VBL interrupt)
* NOTE: This routine does multi-task,
*       so the system will operate until
*       the VBL triggers the task again.
*
* IN:	void
*
* OUT:	void
*

_WaitVBL

	movem.l	d0-a6,-(sp)

	; clear signals

	move.l	_SysBase,a6
	clr.l	d0
	move.l	_VBLSigMask,d1
	jsr	_LVOSetSignal(a6)

	; wait for vbl-signal

	move.l	_VBLSigMask,d0
	jsr	_LVOWait(a6)

	movem.l	(sp)+,d0-a6
	rts
