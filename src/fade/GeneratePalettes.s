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

_GeneratePalettes
*************************************************
*						*
* Generate general-purpose palettes for later	*
* use.						*
*						*
*************************************************

	movem.l	d0-d1/a0,-(sP)

	lea.l	_WhitePalette,a0
	move.l	#256-1,d0
.white_palette_loop
	move.l	#$ffffff,(a0)+
	dbra	d0,.white_palette_loop

	lea.l	_GreyscalePalette,a0
	move.l	#256-1,d0
.greyscale_palette_loop
	move.l	d0,d1
	eor.b	#$ff,d1
	move.b	d1,1(a0)
	move.b	d1,2(a0)
	move.b	d1,3(a0)
	lea.l	4(a0),a0
	dbra	d0,.greyscale_palette_loop

	movem.l	(sp)+,d0-d1/a0
	rts

	section	data,data

	section	bss,bss

_GreyscalePalette
	ds.l	256
_WhitePalette
	ds.l	256
_BlackPalette
	ds.l	256
