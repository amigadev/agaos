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

	fpu

	include	src/agaos.i

STACKSIZE1	EQU	(MTX_SIZEOF*1)
STACKSIZE	EQU	(MTX_SIZEOF*3)
temp_matrix1	EQU	-((MTX_SIZEOF*1))(a5)
temp_matrix2	EQU	-((MTX_SIZEOF*2))(a5)
temp_matrix3	EQU	-((MTX_SIZEOF*3))(a5)

	section	code,code

;****** AgaOS/Matrix_Apply ****************************************
*
*   NAME
*	Matrix_Apply - Apply matrix to a list of vector-points.
*
*   SYNOPSIS
*	Matrix_Apply(matrix,input,output,count)
*	             a0     a1    a2     d0
*
*	void Matrix_Apply(Matrix4*,float*,float*,int);
*
*   FUNCTION
*	Completes a full matrix-processing on the vector-points,
*	with transformation and translation.
*
*   INPUT
*	matrix - Full 4x4 matrix.
*	input - Input vector-points. (groups of 3(X,Y,Z) floats)
*	output - Output vector-points. ( -""- )
*	count - number of points to apply matrix to. (count*3*4
*	        for byte-size)
*
*   RESULTS
*
*   NOTES
*	This routine requires a FPU. If you intend to allow the
*	program to run on all systems that atleast provide a
*	MC68020, you should not run this.
*
*   BUGS
*
*   SEE ALSO
*
**********************************************************************
*
*
*

_Matrix_Apply
*************************************************
*						*
* IN:	a0 - Ptr to 4x4 matrix			*
*	a1 - Ptr to input-points		*
*	a2 - Ptr to output-points		*
*	d0 - Number of points			*
*						*
* All points are FLOATS (3 values per point, in	*
* (X,Y,Z) order)				*
*						*
* USES: fp0,fp1,fp2,fp3,fp4,fp5,fp6,fp7		*
*						*
*************************************************

	movem.l	d0-a6,-(sp)

	; store matrix in as many registers as possible

	;d7 - loop counter

	move.l	d0,d7

	;fp0 - temp (X)
	;fp1 - temp (Y)
	;fp2 - temp (Z)

	;[ fp3  fp4  fp5 R0C4]
	;[ fp6  fp7   d0 R1C4]
	;[  d1   d2   d3 R2C4]
	;[  d4   d5   d6 R3C4]

	fmove.s	(a0)+,fp3
	fmove.s	(a0)+,fp4
	fmove.s	(a0)+,fp5
	lea.l	4(a0),a0

	fmove.s	(a0)+,fp6
	fmove.s	(a0)+,fp7
	move.l	(a0)+,d0
	lea.l	4(a0),a0

	move.l	(a0)+,d1
	move.l	(a0)+,d2
	move.l	(a0)+,d3
	lea.l	4(a0),a0

	move.l	(a0)+,d4
	move.l	(a0)+,d5
	move.l	(a0)+,d6

	subq.l	#1,d7
.point_loop

	; X = x * mtx00 + y * mtx10 + z * mtx20 + mtx30

	fmove.s	0(a1),fp0
	fmove.s	4(a1),fp1
	fmove.s	8(a1),fp2

	fmul		fp3,fp0
	fmul		fp6,fp1
	fmul.s		d1,fp2
	fadd		fp0,fp1
	fadd.s		d4,fp2
	fadd		fp1,fp2
	fmove.s		fp2,(a2)+

	; Y = x * mtx01 + y * mtx11 + z * mtx21 + mtx31

	fmove.s	0(a1),fp0
	fmove.s	4(a1),fp1
	fmove.s	8(a1),fp2

	fmul		fp4,fp0
	fmul		fp7,fp1
	fmul.s		d2,fp2
	fadd		fp0,fp1
	fadd.s		d5,fp2
	fadd		fp1,fp2
	fmove.s		fp2,(a2)+

	; Z = x * mtx02 + y * mtx12 + z * mtx22 + mtx32

	fmove.s	0(a1),fp0
	fmove.s	4(a1),fp1
	fmove.s	8(a1),fp2

	fmul		fp5,fp0
	fmul.s		d0,fp1
	fmul.s		d3,fp2
	fadd		fp0,fp1
	fadd.s		d6,fp2
	fadd		fp1,fp2
	fmove.s		fp2,(a2)+

	lea.l	12(a1),a1

	dbra	d7,.point_loop

	movem.l	(sp)+,d0-a6
	rts
