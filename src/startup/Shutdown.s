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

*** startup.s

	; shuts down the system and sets up crucial
	; services required by AgaOS

	include	src/agaos.i

	incdir	include:

	include	exec/types.i
	include	dos/dos.i
	include	dos/dosextens.i

	include	workbench/startup.i

	include	lvo/exec_lib.i
	include	lvo/dos_lib.i

;****** AgaOS/Shutdown ***********************************************
*
*   NAME
*	Shutdown - Restore system and release all resources.
*
*   SYNOPSIS
*	Shutdown()
*
*	void Shutdown(void);
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
*	Startup()
*
**********************************************************************
*
* Restore system and release all
* resources.
*
* IN:	void
*
* OUT:	void
*

_Shutdown
	movem.l	d0-a6,-(sp)				; push all registers

	*** remove vbl

	jsr	_RemoveVBL

	*** bring back intuition

	jsr	_RemoveScreen

	*** remove input handler

	jsr	_RemoveInputHandler

	*** Remove memory-handling

	jsr	_RemoveMemory

	*** print eventual error

	tst.l	_LastError				; did any error occur?
	beq	.no_error				; skip if not

	tst.l	_DOSBase				; can we actually print the error?
	beq	.no_error				; skip if not

	move.l	_DOSBase,a6				; get dos-pointer
	move.l	_LastError,d1				; get error-string
	jsr	_LVOPutStr(a6)				; print to stdout
	clr.l	_LastError				; clear error-string

.no_error

	*** remove math

	jsr	_RemoveMath

	*** restore task priority

	move.l	_SysBase,a6
	move.l	_PtrTask,a1
	move.l	_OldTaskPri,d0
	jsr	_LVOSetTaskPri(a6)

	*** Workbench shutdown (part 1)

	tst.l	_PtrMessage
	beq	.no_wbclosedown_1

	; restore old directory

	move.l	_DOSBase,a6
	move.l	_PtrOldLock,d1
	jsr	_LVOCurrentDir(a6)

.no_wbclosedown_1

	*** close libraries

	jsr	_CloseLibraries

	*** Workbench shutdown (part 2)

	move.l	_PtrMessage,d5
	beq	.no_wbclosedown_2

	; stop wb from freeing seglist before we exit

	move.l	_SysBase,a6
	jsr	_LVOForbid(a6)

	; reply message (trigger seglist-freeing when mt is back on)

	move.l	d5,a1
	jsr	_LVOReplyMsg(a6)

	clr.l	_PtrMessage
.no_wbclosedown_2

	movem.l	(sp)+,d0-a6				; pop all registers
	rts						; return

	section	bss,bss

_LastError		ds.l	1

	public	_OldTaskPri
	public	_PtrTask
	public	_PtrMessage
	public	_PtrOldLock

_OldTaskPri		ds.l	1	; Old task-priority (restored on exit)
_PtrTask		ds.l	1	; Pointer to this task
_PtrMessage		ds.l	1	; Pointer to WBStartup-message, if any
_PtrOldLock		ds.l	1	; Old current directory
