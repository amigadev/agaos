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

*** copper.s

	; manages copper-lists, to simplify
	; on the higher level

	include	src/agaos.i

	incdir	include:

	include	utility/tagitem.i

	include	hardware/custom.i
	include	hardware/bplbits.i

	include	lvo/exec_lib.i

;****** AgaOS/WriteCopperPtrs ****************************************
*
*   NAME
*	WriteCopperPtrs - Write pointer-loads copper-style
*   SYNOPSIS
*	endcop = WriteCopperPtrs(coplist,ptr,modulo,count,copptr)
*	d0			 a0      d0  d1     d2    d3
*
*	UWORD* WriteCopperptrs(UWORD*,APTR,ULONG,ULONG,UWORD);
*
*   FUNCTION
*
*   INPUT
*	coplist - Pointer to output copperlist
*	ptr - Base pointer
*	modulo - Distance between each pointer-block
*	count - How many pointers to set
*	copptr - Copper pointer-word to use when loading
*
*   RESULTS
*	endcop - Pointing just past the last copper-instruction written
*
*   NOTES
*
*   BUGS
*
*   SEE ALSO
*
**********************************************************************

_WriteCopperPtrs
	movem.l	d2-d3/a0,-(sp)

	subq.l	#1,d2
	bmi	.no_loads
.load_loop
	move.w	d3,(a0)+
	add.w	#2,d3
	swap	d0
	move.w	d0,(a0)+

	move.w	d3,(a0)+
	add.w	#2,d3
	swap	d0
	move.w	d0,(a0)+

	add.l	d1,d0

	dbra	d2,.load_loop
.no_loads

	move.l	a0,d0
	movem.l	(sp)+,d2-d3/a0
	rts
