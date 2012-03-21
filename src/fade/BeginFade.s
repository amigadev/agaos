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

;****** AgaOS/BeginFade **********************************************
*
*   NAME
*	BeginFade - Setup a new color fade
*
*   SYNOPSIS
*	BeginFade(fadestruct,source,dest,first,last,iterations,bplcon3)
*                 a0         a1     a2   d0    d1   d2         d3
*
*	void BeginFade(FadeStructure*, ULONG*, ULONG*, ULONG, ULONG, ULONG,
*			UWORD);
*
*   FUNCTION
*	This function prepares a FadeStructure for use, filling it with
*	all the needed information to perform a fade from one colour-
*	table to another.
*
*   INPUT
*	fadestruct - Pointer to FadeStructure
*	source - Source palette (up to 256 longwords, $00RrGgBb)
*	dest - Dest Palette (up to 256 longwords, $00RrGgBb)
*	first - First color to start fade(0-255)
*	last - Last color to fade (0-255, >= first)
*	iterations - Number of iterations until fade completes
*	bplcon3 - Mask for BPLCON3 writes
*
*   RESULTS
*
*   NOTES
*
*   BUGS
*
*   SEE ALSO
*	DoFade()
*
**********************************************************************
*
* Setup a new fade.
*
* IN:	a0 - pointer to FadeStructure
*	a1 - source palette (256 longwords, $00RrGgBb)
*	a2 - dest palette (256 longwords, $00RrGgBb)
*	d0 - first color to fade (0-255)
*	d1 - last color to fade (0-255, >= first)
*	d2 - number of iterations (the higher the slower)
*	d3 - BPLCON3 mask
*
* OUT:	void
*

_BeginFade

	movem.l	d0-a6,-(sp)

	*** setup fade-structure

	move.l	d0,FDS_FirstColor(a0)
	move.l	d1,FDS_LastColor(a0)
	move.l	d2,FDS_Iterator(a0)
	move.l	d3,FDS_BPLCON3(a0)

	clr.l	d5

	lea.l	FDS_ValueColor(a0),a3
	lea.l	FDS_DeltaColor(a0),a4
	sub.l	d0,d1
.color_loop
	lea.l	1(a1),a1
	lea.l	1(a2),a2

	move.l	#3-1,d4
.gun_loop

	clr.l	d6

	move.b	(a1)+,d5
	lsl.l	#8,d5
	move.b	(a2)+,d6
	lsl.l	#8,d6

	move.w	d5,(a3)+

	sub.l	d5,d6
	divs.l	d2,d6

	move.w	d6,(a4)+

	dbra	d4,.gun_loop

	dbra	d1,.color_loop

	movem.l	(sp)+,d0-a6
	rts
