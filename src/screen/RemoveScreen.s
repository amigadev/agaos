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

;*****i* AgaOS/RemoveScreen ******************************************
*
**********************************************************************
*

_RemoveScreen
	movem.l	d0-a6,-(sp)

	*** free dummy-sprite

	move.l	_DummySprite,d0
	beq	.no_sprite

	move.l	d0,a0
	jsr	_MemFree
	clr.l	_DummySprite

.no_sprite

	*** restore OS-view

	tst.l	_OSView
	beq	.no_view

	move.l	_GfxBase,a6
	move.l	_OSView,a1
	jsr	_LVOLoadView(a6)
	jsr	_LVOWaitTOF(a6)
	jsr	_LVOWaitTOF(a6)

	move.w	_DMAStore,$dff096

	move.l	gb_copinit(a6),$dff080
	move.l	gb_LOFlist(a6),$dff084
	move.w	#0,$dff08a
	move.w	#0,$dff088

.no_view

	movem.l	(sp)+,d0-a6
	rts

	public	_OSView
	public	_DMAStore
