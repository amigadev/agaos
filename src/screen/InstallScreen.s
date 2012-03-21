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

*** screen.s

	; handle screen setup and
	; closedown (private)

	include	src/agaos.i

	incdir	include:

	include	graphics/gfxbase.i

	include	lvo/graphics_lib.i

;*****i* AgaOS/InstallScreen *****************************************
*
**********************************************************************
*

_InstallScreen
	movem.l	d0-a6,-(sp)

	*** remove and store OS-view

	move.l	_GfxBase,a6
	move.l	gb_ActiView(a6),_OSView
	sub.l	a1,a1
	jsr	_LVOLoadView(a6)
	jsr	_LVOWaitTOF(a6)
	jsr	_LVOWaitTOF(a6)

	move.w	$dff002,d0
	or.w	#$8000,d0
	move.w	d0,_DMAStore			; store DMA

	*** allocate dummy-sprite

	move.l	#8*4,d0
	move.l	#AAMEMF_CHIP|AAMEMF_ALIGN,d1
	jsr	_MemAlloc
	move.l	d0,_DummySprite
	beq	.Fail

	movem.l	(sp)+,d0-a6
	st.l	d0
	rts

.Fail
	movem.l	d0-a6,-(sp)
	clr.l	d0
	rts

	section	bss,bss

	public	_OSView
	public	_DMAStore

_OSView			ds.l	1
_DMAStore		ds.w	1
