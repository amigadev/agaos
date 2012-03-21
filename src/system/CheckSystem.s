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

*** system.s

	; contains system-validation code

	include	src/agaos.i

	incdir	include:

	include	exec/execbase.i
	include	graphics/gfxbase.i

	include	lvo/exec_lib.i

_CheckSystem
;*****i* AgaOS/CheckSystem *******************************************
*
*   NAME
*
*   SYNOPSIS
*
*   FUNCTION
*	success = CheckSystem(flags)
*	d0                    d0
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
* Check system so necessary components
* are available.
*
* IN:	d0 - flags
*
* OUT:	d0 - FALSE is system is not OK.
*

	movem.l	d0-a6,-(sp)

	move.l	d0,d7

	*** check for setpatch semaphore

	ERRMSG	ERR_SetPatch
	move.l	_SysBase,a6				; get sysbase
	lea.l	_SetPatchName,a1			; get name for setpatch semaphore
	jsr	_LVOFindSemaphore(a6)			; see if it is available
	tst.l	d0					; did we get it?
	beq	.Fail					; if not, fail

	*** Check for Amiga Hardware

	IFNE	UAEFAIL
	ERRMSG	ERR_NoAmiga
	cmp.w	#$4e75,($f0ff62).l
	beq	.Fail
	ENDC

	*** Check for AGA hardware

	ERRMSG	ERR_NoAGA
	move.l	_GfxBase,a1
	move.b	gb_ChipRevBits0(a1),d0
	and.b	#GFXF_AA_ALICE|GFXF_AA_LISA,d0
	cmp.b	#GFXF_AA_ALICE|GFXF_AA_LISA,d0
	bne	.Fail

	*** Check CPU

	move.l	_SysBase,a6
	move.w	AttnFlags(a6),d0

	ERRMSG	ERR_NoMC68020
	move.w	d0,d1
	and.w	#AFF_68020|AFF_68030|AFF_68040,d1
	beq	.Fail

	btst	#AASTRB_FPU,d7
	beq	.no_fpu_test

	ERRMSG	ERR_NoFPU
	and.w	#AFF_68881|AFF_68882|AFF_FPU40,d0
	beq	.Fail

.no_fpu_test

	CLEARERR

	movem.l	(sp)+,d0-a6
	st.l	d0
	rts
.Fail
	movem.l	(sp)+,d0-a6
	clr.l	d0
	rts

	section	data,data

_SetPatchName	dc.b	"« SetPatch »",0
	IFEQ	NOERRORMSGS
ERR_SetPatch	dc.b	"ERROR: SetPatch is not installed.\n",0
ERR_NoAGA	dc.b	"ERROR: AGA Alice/Lisa hardware not available\n",0
ERR_NoMC68020	dc.b	"ERROR: This program requires atleast an MC68020\n",0
ERR_NoFPU	dc.b	"ERROR: No usable FPU available\n",0
	IFNE	UAEFAIL
ERR_NoAmiga	dc.b	"ERROR: Only Amiga makes it possible!\n",0
	ENDC
	ENDC
