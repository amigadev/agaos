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

*** fade.s

	; manages automatic fading of
	; colour-palettes

	include	src/agaos.i

	incdir	include:

	include	lvo/dos_lib.i

	include	hardware/custom.i

;****** AgaOS/DoFade *************************************************
*
*   NAME
*	DoFade - Perform a fade-iteration
*
*   SYNOPSIS
*	complete = DoFade(fadestruct)
*	D0		  a0
*
*	BOOL DoFade(FadeStructure*);
*
*   FUNCTION
*
*   INPUT
*	fadestruct - Pointer to fade-structure
*
*   RESULTS
*	complete - FALSE if fade is still running, otherwise the
*		fade has completed and anymore calls to this routine
*		will perform nothing.
*
*   NOTES
*	This routine currently uses LoadColors() when writing to the
*	hardware.
*
*   BUGS
*
*   SEE ALSO
*	BeginFade(), LoadColors()
*
**********************************************************************
*
* Perform a fade-iteration.
*
* IN:	a0 - pointer to fade-structure
*
* OUT:	d0 - FALSE if fade is running
*

_DoFade
	movem.l	d0-d2/d7/a0/a2-a4,-(sp)

	tst.l	FDS_Iterator(a0)
	beq	.iterations_finished
	sub.l	#1,FDS_Iterator(a0)

	lea.l	FDS_ValueColor(a0),a2
	lea.l	FDS_DeltaColor(a0),a3
	lea.l	FDS_FadeBuffer(a0),a4
	move.l	FDS_FirstColor(a0),d7

.colorfade_loop

	cmp.l	FDS_LastColor(a0),d7
	bgt	.colorfade_complete
	addq.l	#1,d7

	move.w	(a2),d0			; fetch R0
	move.w	2(a2),d1		; fetch G0
	move.w	4(a2),d2		; fetch B0

	add.w	(a3)+,d0		; R1 = R0 + dR
	add.w	(a3)+,d1		; G1 = G0 + dG
	add.w	(a3)+,d2		; B1 = B0 + dB

	move.w	d0,(a2)+		; store R1
	move.w	d1,(a2)+		; store G1
	move.w	d2,(a2)+		; store B1

	; d0	= $xxxxRRrr
	; d1	= $xxxxGGgg
	; d2	= $xxxxBBbb

	swap	d0			; d0 = $RRrrxxxx
	lsr.l	#8,d0			; d0 = $00RRrrxx
	lsr.w	#8,d2			; d2 = $xxxx00BB
	move.w	d1,d0			; d0 = $00RRGGgg
	move.b	d2,d0			; d0 = $00RRGGBB
	move.l	d0,(a4)+

	bra	.colorfade_loop
.colorfade_complete

	; Write colors to the hardware

	lea.l	FDS_FadeBuffer(a0),a2
	move.l	FDS_FirstColor(a0),d0
	move.l	FDS_LastColor(a0),d1
	move.l	FDS_BPLCON3(a0),d2
	move.l	a2,a0
	jsr	_LoadColors

	movem.l	(sp)+,d0-d2/d7/a0/a2-a4
	clr.l	d0
	rts

.iterations_finished

	movem.l	(sp)+,d0-d2/d7/a0/a2-a4
	st.l	d0
	rts
