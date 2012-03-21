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

;****** AgaOS/Matrix_Scale ****************************************
*
*   NAME
*	Matrix_Scale - Scale input matrix.
*
*   SYNOPSIS
*	Matrix_Scale(input,output,xscale,yscale,zscale)
*	             a0    a1     fp0    fp1    fp2
*
*	void Matrix_Scale(Matrix4*,Matrix4*,double,double,double);
*
*   FUNCTION
*	Scale the input-matrix into a new size. To perform a uniform
*	scale, pass the same input-value in all three scaling factors.
*
*   INPUT
*	input - Input matrix.
*	output - Output matrix.
*	xcoord - X scaling factor.
*	ycoord - Y scaling factor.
*	zcoord - Z scaling factor.
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

_Matrix_Scale
*************************************************
*						*
* Scale matrix to a new size			*
*						*
* IN:	a0  - Ptr to 4x4 Matrix (input)		*
*	a1  - Ptr to 4x4 Matrix (output)	*
*	fp0 - X scale				*
*	fp1 - Y scale				*
*	fp2 - Z scale				*
*						*
* USES:	fp0,fp1,fp2,fp3,fp4			*
*						*
*************************************************

	movem.l	d0-a6,-(sp)

	link	a5,#-STACKSIZE1

	move.l	a1,a2

	lea.l	temp_matrix1,a1

	fmove.s	#0.0,fp3
	fmove.s	#1.0,fp4

	;x 0 0 0
	fmove.s	fp0,(a1)+
	fmove.s	fp3,(a1)+
	fmove.s	fp3,(a1)+
	fmove.s	fp3,(a1)+

	;0 y 0 0
	fmove.s	fp3,(a1)+
	fmove.s	fp1,(a1)+
	fmove.s	fp3,(a1)+
	fmove.s	fp3,(a1)+

	;0 0 z 0
	fmove.s	fp3,(a1)+
	fmove.s	fp3,(a1)+
	fmove.s	fp2,(a1)+
	fmove.s	fp3,(a1)+

	;0 0 0 1
	fmove.s	fp3,(a1)+
	fmove.s	fp3,(a1)+
	fmove.s	fp3,(a1)+
	fmove.s	fp4,(a1)+

	lea.l	temp_matrix1,a1
	jsr	_Matrix_Multiply

	unlk	a5

	movem.l	(sp)+,d0-a6
	rts
