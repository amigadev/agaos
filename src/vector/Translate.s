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

;****** AgaOS/Matrix_Translate ****************************************
*
*   NAME
*	Matrix_Translate - Translate matrix into a new coordinate
*	system.
*
*   SYNOPSIS
*	Matrix_Translate(input,output,xcoord,ycoord,zcoord)
*	                 a0    a1     fp0    fp1    fp2
*
*	void Matrix_Translate(Matrix4*,Matrix4*,double,double,double);
*
*   FUNCTION
*	Translate the matrixed passed from 'input' into a new
*	coordinate system, and store result in 'output'.
*
*   INPUT
*	input - Input matrix.
*	output - Output matrix.
*	xcoord - X coordinate.
*	ycoord - Y coordinate.
*	zcoord - Z coordinate.
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

_Matrix_Translate
*************************************************
*						*
* Translate a matrix to a new position.		*
*						*
* IN:	a0  - Ptr to 4x4 Matrix (input)		*
*	a1  - Ptr to 4x4 Matrix (output)	*
*	fp0 - X					*
*	fp1 - Y					*
*	fp2 - Z					*
*						*
* USES: fp0,fp1,fp2,fp3,fp4			*
*						*
*************************************************

	movem.l	d0-a6,-(sp)

	link	a5,#-STACKSIZE1

	move.l	a1,a2

	lea.l	temp_matrix1,a1

	fmove.s	#0.0,fp3
	fmove.s	#1.0,fp4

	;x 0 0 0
	fmove.s	fp4,(a1)+
	fmove.s	fp3,(a1)+
	fmove.s	fp3,(a1)+
	fmove.s	fp3,(a1)+

	;0 y 0 0
	fmove.s	fp3,(a1)+
	fmove.s	fp4,(a1)+
	fmove.s	fp3,(a1)+
	fmove.s	fp3,(a1)+

	;0 0 z 0
	fmove.s	fp3,(a1)+
	fmove.s	fp3,(a1)+
	fmove.s	fp4,(a1)+
	fmove.s	fp3,(a1)+

	;0 0 0 1
	fmove.s	fp0,(a1)+
	fmove.s	fp1,(a1)+
	fmove.s	fp2,(a1)+
	fmove.s	fp4,(a1)+

	lea.l	temp_matrix1,a1
	jsr	_Matrix_Multiply

	unlk	a5

	movem.l	(sp)+,d0-a6
	rts
