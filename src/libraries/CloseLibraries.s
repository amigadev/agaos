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

;*****i* AgaOS/CloseLibraries ****************************************
*
*   NAME
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

_CloseLibraries
	movem.l	d0-a6,-(sp)

	tst.l	_IntuitionBase				; check intui-pointer
	beq	.no_intui				; skip if NULL

	move.l	_SysBase,a6				; get exec-pointer
	move.l	_IntuitionBase,a1			; get intui-pointer
	jsr	_LVOCloseLibrary(a6)			; close intui
	clr.l	_IntuitionBase				; clear base

.no_intui

	tst.l	_GfxBase				; check gfx-pointer
	beq	.no_gfx					; skip if NULL

	move.l	_SysBase,a6				; get exec-pointer
	move.l	_GfxBase,a1				; get gfx-pointer
	jsr	_LVOCloseLibrary(a6)			; close gfx
	clr.l	_GfxBase				; clear base

.no_gfx

	tst.l	_DOSBase				; check dos-pointer
	beq	.no_dos					; skip if NULL

	move.l	_SysBase,a6				; get exec-pointer
	move.l	_DOSBase,a1				; get dos-pointer
	jsr	_LVOCloseLibrary(a6)			; close dos
	clr.l	_DOSBase				; clear base

.no_dos

	movem.l	(sp)+,d0-a6
	rts
