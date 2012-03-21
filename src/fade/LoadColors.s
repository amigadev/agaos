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

;****** AgaOS/LoadColors *********************************************
*
*   NAME
*	LoadColors - Load colors into the graphics-hardware
*
*   SYNOPSIS
*	LoadColors(table,first,last,bplcon3)
*		   a0    d0    d1   d2
*
*	void LoadColors(ULONG*, ULONG, ULONG, UWORD);
*
*   FUNCTION
*
*   INPUT
*	table - Pointer to an array with longwords ($00RrGgBb)
*	first - First color to write (0-255)
*	last - Last color to write (0-255, >= first)
*	bplcon3 - Mask for BPLCON3 writes
*
*   RESULTS
*
*   NOTES
*	Colors are reduced to two passes (ECS, AGA) for most
*	efficient memory-footprint.
*
*   BUGS
*
*   SEE ALSO
*
**********************************************************************
*
* A 256-color load results in 528 word-writes, or 1056 bytes written
* to the graphics-hardware. This is just a 32-byte overhead, and the
* smallest you can get because of the colour-banks.
*

_LoadColors
	movem.l	d0-a6,-(sp)

	lea.l	$dff000,a4

	move.l	d0,d6
	move.l	d1,d7

	movem.l	d6-d7/a0,-(sp)

	; ECS loop

	; d5 - color bank
	moveq.w	#-1,d5

	sub.l	d6,d7
	bmi	.ecs_color_complete

.ecs_color_loop

	; compute current group and update 

	move.w	d6,d0
	and.w	#$e0,d0
	lsl.w	#8,d0

	cmp.w	d0,d5
	beq	.ecs_same_colorbank

	move.w	d0,d5
	or.w	d2,d0

	move.w	d0,bplcon3(a4)

.ecs_same_colorbank

	; write color

	move.l	(a0)+,d0
	move.l	d6,d1
	and.l	#31,d1

	lsr.l	#4,d0				; 0000 0000 0000 RRRR rrrr GGGG gggg BBBB
	lsl.b	#4,d0				; 0000 0000 0000 RRRR rrrr GGGG BBBB 0000
	lsl.w	#4,d0				; 0000 0000 0000 RRRR GGGG BBBB 0000 0000
	lsr.l	#8,d0				; 0000 0000 0000 0000 0000 RRRR GGGG BBBB
	move.w	d0,color(a4,d1*2)		; write MSB of color

	addq.l	#1,d6
	dbra	d7,.ecs_color_loop
.ecs_color_complete	

	movem.l	(sp)+,d6-d7/a0

	; AGA loop

	or.w	#$0200,d2			; set LOCT

	; d5 - color bank
	moveq.w	#-1,d5

	sub.l	d6,d7
	bmi	.aga_color_complete

.aga_color_loop

	; compute current group and update 

	move.w	d6,d0
	and.w	#$e0,d0
	lsl.w	#8,d0

	cmp.w	d0,d5
	beq	.aga_same_colorbank

	move.w	d0,d5
	or.w	d2,d0

	move.w	d0,bplcon3(a4)

.aga_same_colorbank

	; write color

	move.l	(a0)+,d0
	move.l	d6,d1
	and.l	#31,d1

	lsl.b	#4,d0				; 0000 0000 RRRR rrrr GGGG gggg bbbb 0000
	lsl.w	#4,d0				; 0000 0000 RRRR rrrr gggg bbbb 0000 0000
	lsr.l	#8,d0				; 0000 0000 0000 0000 RRRR rrrr gggg bbbb
	move.w	d0,color(a4,d1*2)		; write LSB of color (no genlock bit, so
						; the 4 MSB of the register can be in any
						; state)

	addq.l	#1,d6
	dbra	d7,.aga_color_loop
.aga_color_complete	

	movem.l	(sp)+,d0-a6
	rts
