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

*** math.s

	; handles mathematic algorithms

	include	src/agaos.i

;*****i* AgaOS/SetupMath *********************************************
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

_SetupMath
	movem.l	d0-a6,-(sp)

	*** generate sinus-table (amplitude -32768 to 32767, 15 bit fraction in calculation)

	lea.l	_Cos1024,a0
	move.l	#$0fff8000,d4
	move.l	#0,d5

	move.l	#(1024+256)-1,d0
.render_sinus

	move.l	d4,d1
	asr.l	#5,d1
	asr.l	#8,d1

	;sub.l	#1,d1
	neg.l	d1
	move.l	d1,(a0)+

	move.l	d4,d6
	divs.l	#26550,d6
	sub.l	d6,d5

	add.l	d5,d4

	dbra	d0,.render_sinus

	movem.l	(sp)+,d0-a6
	rts

	section	bss,bss

_Cos1024	ds.l	256
_Sin1024	ds.l	1024
