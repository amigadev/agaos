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

*** libraries.s

	; Handles opening and closing of system-libraries

	include	src/agaos.i

	incdir	include:

	include	exec/types.i
	include	graphics/gfx.i
	include	intuition/intuition.i

	include	lvo/exec_lib.i
	include	lvo/graphics_lib.i
	include	lvo/intuition_lib.i

;*****i* AgaOS/OpenLibraries *****************************************
*
*   NAME
*	OpenLibraries
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

_OpenLibraries
	movem.l	d0-a6,-(sp)				; push all registers

	ERRMSG	ERR_DOS
	move.l	_SysBase,a6				; get exec-pointer
	lea.l	_DOSName,a1				; get dos name
	move.l	#39,d0					; OS 3.x
	jsr	_LVOOpenLibrary(a6)			; open dos
	move.l	d0,_DOSBase				; store pointer
	beq	.Fail					; fail if NULL

	ERRMSG	ERR_Gfx
	lea.l	_GfxName,a1				; get gfx name
	move.l	#39,d0					; OS 3.x
	jsr	_LVOOpenLibrary(a6)			; open gfx
	move.l	d0,_GfxBase				; store pointer
	beq	.Fail					; fail if NULL

	ERRMSG	ERR_Intuition
	lea.l	_GfxName,a1				; get intui name
	move.l	#39,d0					; OS 3.x
	jsr	_LVOOpenLibrary(a6)			; open intui
	move.l	d0,_IntuitionBase			; store pointer
	beq	.Fail					; fail if NULL

	CLEARERR

	movem.l	(sp)+,d0-a6
	st.l	d0
	rts

.Fail
	movem.l	(sp)+,d0-a6
	clr.l	d0
	rts

	section	data,data

_DOSName		dc.b	"dos.library",0
_GfxName		dc.b	"graphics.library",0
_IntuitionName		dc.b	"intuition.library",0

	IFEQ	NOERRORMSGS

ERR_DOS			dc.b	"ERROR: Could not open dos.library V39\n",0
ERR_Gfx			dc.b	"ERROR: Could not open graphics.library V39\n",0
ERR_Intuition		dc.b	"ERROR: Could not open intuition.library V39\n",0

	ENDC

	section	bss,bss

	IFEQ	MINIEXEC
_SysBase		ds.l	1
	ENDC
_DOSBase		ds.l	1
_GfxBase		ds.l	1
_IntuitionBase		ds.l	1
