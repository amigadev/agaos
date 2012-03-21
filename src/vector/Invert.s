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

;****** AgaOS/Matrix_Invert ****************************************
*
*   NAME
*	Matrix_Apply - Invert matrix.
*
*   SYNOPSIS
*	Matrix_Invert(input,output)
*	              a0    a1
*
*	void Matrix_Invert(Matrix4*,Matrix4*);
*
*   FUNCTION
*	Computes the inverse of the matrix passed in 'input' and
*	writes the result to 'output'.
*
*   INPUT
*	input - Full 4x4 matrix to invert.
*	ouput - Full 4x4 matrix to write the result to.
*
*   RESULTS
*
*   NOTES
*	Input- and output-pointer can be one and the same. The
*	algorithm uses internal buffers.
*
*	Do not use heavily! This is a _MASSIVE_ routine, and it
*	will eat a lot of time.
*
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

_Matrix_Invert
*************************************************
*						*
* Compute the inverse of the input-matrix.	*
* This routine is _MASSIVE_!!!			*
*						*
* IN:	a0 - Ptr to 4x4 Matrix (Input)		*
*	a1 - Ptr to 4x4 Matrix (Output)		*
*						*
* NOTE: Input & Output can be the same pointer,	*
*	it's written in this way to be flexible.*
*						*
* USES: blah :D I'll write it after I've	*
*	optimized a bit				*
*						*
*************************************************

	movem.l	d0-a6,-(sp)

	link	a5,#-STACKSIZE1

	lea.l	temp_matrix1,a2

	;d00

	fmove.s	MTX_R1C1(a0),fp0
	fmul.s	MTX_R2C2(a0),fp0
	fmul.s	MTX_R3C3(a0),fp0

	;+

	fmove.s	MTX_R1C2(a0),fp1
	fmul.s	MTX_R2C3(a0),fp1
	fmul.s	MTX_R3C1(a0),fp1
	fadd	fp1,fp0

	;+

	fmove.s	MTX_R1C3(a0),fp1
	fmul.s	MTX_R2C1(a0),fp1
	fmul.s	MTX_R3C2(a0),fp1
	fadd	fp1,fp0

	;-

	fmove.s	MTX_R3C1(a0),fp1
	fmul.s	MTX_R2C2(a0),fp1
	fmul.s	MTX_R1C3(a0),fp1
	fsub	fp1,fp0

	;-

	fmove.s	MTX_R3C2(a0),fp1
	fmul.s	MTX_R2C3(a0),fp1
	fmul.s	MTX_R1C1(a0),fp1
	fsub	fp1,fp0

	;-

	fmove.s	MTX_R3C3(a0),fp1
	fmul.s	MTX_R2C1(a0),fp1
	fmul.s	MTX_R1C2(a0),fp1
	fsub	fp1,fp0

	fmove.s	fp0,(a2)+

	;d01

	fmove.s	MTX_R1C0(a0),fp0
	fmul.s	MTX_R2C2(a0),fp0
	fmul.s	MTX_R3C3(a0),fp0

	;+

	fmove.s	MTX_R1C2(a0),fp1
	fmul.s	MTX_R2C3(a0),fp1
	fmul.s	MTX_R3C0(a0),fp1
	fadd	fp1,fp0

	;+

	fmove.s	MTX_R1C3(a0),fp1
	fmul.s	MTX_R2C0(a0),fp1
	fmul.s	MTX_R3C2(a0),fp1
	fadd	fp1,fp0

	;-

	fmove.s	MTX_R3C0(a0),fp1
	fmul.s	MTX_R2C2(a0),fp1
	fmul.s	MTX_R1C3(a0),fp1
	fsub	fp1,fp0

	;-

	fmove.s	MTX_R3C2(a0),fp1
	fmul.s	MTX_R2C3(a0),fp1
	fmul.s	MTX_R1C0(a0),fp1
	fsub	fp1,fp0

	;-

	fmove.s	MTX_R3C3(a0),fp1
	fmul.s	MTX_R2C0(a0),fp1
	fmul.s	MTX_R1C2(a0),fp1
	fsub	fp1,fp0

	fmove.s	fp0,(a2)+

	;d02

	fmove.s	MTX_R1C0(a0),fp0
	fmul.s	MTX_R2C1(a0),fp0
	fmul.s	MTX_R3C3(a0),fp0

	;+

	fmove.s	MTX_R1C1(a0),fp1
	fmul.s	MTX_R2C3(a0),fp1
	fmul.s	MTX_R3C0(a0),fp1
	fadd	fp1,fp0

	;+

	fmove.s	MTX_R1C3(a0),fp1
	fmul.s	MTX_R2C0(a0),fp1
	fmul.s	MTX_R3C1(a0),fp1
	fadd	fp1,fp0

	;-

	fmove.s	MTX_R3C0(a0),fp1
	fmul.s	MTX_R2C1(a0),fp1
	fmul.s	MTX_R1C3(a0),fp1
	fsub	fp1,fp0

	;-

	fmove.s	MTX_R3C1(a0),fp1
	fmul.s	MTX_R2C3(a0),fp1
	fmul.s	MTX_R1C0(a0),fp1
	fsub	fp1,fp0

	;-

	fmove.s	MTX_R3C3(a0),fp1
	fmul.s	MTX_R2C0(a0),fp1
	fmul.s	MTX_R1C1(a0),fp1
	fsub	fp1,fp0

	fmove.s	fp0,(a2)+

	;d03

	fmove.s	MTX_R1C0(a0),fp0
	fmul.s	MTX_R2C1(a0),fp0
	fmul.s	MTX_R3C2(a0),fp0

	;+

	fmove.s	MTX_R1C1(a0),fp1
	fmul.s	MTX_R2C2(a0),fp1
	fmul.s	MTX_R3C0(a0),fp1
	fadd	fp1,fp0

	;+

	fmove.s	MTX_R1C2(a0),fp1
	fmul.s	MTX_R2C0(a0),fp1
	fmul.s	MTX_R3C1(a0),fp1
	fadd	fp1,fp0

	;-

	fmove.s	MTX_R3C0(a0),fp1
	fmul.s	MTX_R2C1(a0),fp1
	fmul.s	MTX_R1C2(a0),fp1
	fsub	fp1,fp0

	;-

	fmove.s	MTX_R3C1(a0),fp1
	fmul.s	MTX_R2C2(a0),fp1
	fmul.s	MTX_R1C0(a0),fp1
	fsub	fp1,fp0

	;-

	fmove.s	MTX_R3C2(a0),fp1
	fmul.s	MTX_R2C0(a0),fp1
	fmul.s	MTX_R1C1(a0),fp1
	fsub	fp1,fp0

	fmove.s	fp0,(a2)+

	;d10

	fmove.s	MTX_R0C1(a0),fp0
	fmul.s	MTX_R2C2(a0),fp0
	fmul.s	MTX_R3C3(a0),fp0

	;+

	fmove.s	MTX_R0C2(a0),fp1
	fmul.s	MTX_R2C3(a0),fp1
	fmul.s	MTX_R3C1(a0),fp1
	fadd	fp1,fp0

	;+

	fmove.s	MTX_R0C3(a0),fp1
	fmul.s	MTX_R2C1(a0),fp1
	fmul.s	MTX_R3C2(a0),fp1
	fadd	fp1,fp0

	;-

	fmove.s	MTX_R3C1(a0),fp1
	fmul.s	MTX_R2C2(a0),fp1
	fmul.s	MTX_R0C3(a0),fp1
	fsub	fp1,fp0

	;-

	fmove.s	MTX_R3C2(a0),fp1
	fmul.s	MTX_R2C3(a0),fp1
	fmul.s	MTX_R0C1(a0),fp1
	fsub	fp1,fp0

	;-

	fmove.s	MTX_R3C3(a0),fp1
	fmul.s	MTX_R2C1(a0),fp1
	fmul.s	MTX_R0C2(a0),fp1
	fsub	fp1,fp0

	fmove.s	fp0,(a2)+

	;d11

	fmove.s	MTX_R0C0(a0),fp0
	fmul.s	MTX_R2C2(a0),fp0
	fmul.s	MTX_R3C3(a0),fp0

	;+

	fmove.s	MTX_R0C2(a0),fp1
	fmul.s	MTX_R2C3(a0),fp1
	fmul.s	MTX_R3C0(a0),fp1
	fadd	fp1,fp0

	;+

	fmove.s	MTX_R0C3(a0),fp1
	fmul.s	MTX_R2C0(a0),fp1
	fmul.s	MTX_R3C2(a0),fp1
	fadd	fp1,fp0

	;-

	fmove.s	MTX_R3C0(a0),fp1
	fmul.s	MTX_R2C2(a0),fp1
	fmul.s	MTX_R0C3(a0),fp1
	fsub	fp1,fp0

	;-

	fmove.s	MTX_R3C2(a0),fp1
	fmul.s	MTX_R2C3(a0),fp1
	fmul.s	MTX_R0C0(a0),fp1
	fsub	fp1,fp0

	;-

	fmove.s	MTX_R3C3(a0),fp1
	fmul.s	MTX_R2C0(a0),fp1
	fmul.s	MTX_R0C2(a0),fp1
	fsub	fp1,fp0

	fmove.s	fp0,(a2)+

	;d12

	fmove.s	MTX_R0C0(a0),fp0
	fmul.s	MTX_R2C1(a0),fp0
	fmul.s	MTX_R3C3(a0),fp0

	;+

	fmove.s	MTX_R0C1(a0),fp1
	fmul.s	MTX_R2C3(a0),fp1
	fmul.s	MTX_R3C0(a0),fp1
	fadd	fp1,fp0

	;+

	fmove.s	MTX_R0C3(a0),fp1
	fmul.s	MTX_R2C0(a0),fp1
	fmul.s	MTX_R3C1(a0),fp1
	fadd	fp1,fp0

	;-

	fmove.s	MTX_R3C0(a0),fp1
	fmul.s	MTX_R2C1(a0),fp1
	fmul.s	MTX_R0C3(a0),fp1
	fsub	fp1,fp0

	;-

	fmove.s	MTX_R3C1(a0),fp1
	fmul.s	MTX_R2C3(a0),fp1
	fmul.s	MTX_R0C0(a0),fp1
	fsub	fp1,fp0

	;-

	fmove.s	MTX_R3C3(a0),fp1
	fmul.s	MTX_R2C0(a0),fp1
	fmul.s	MTX_R0C1(a0),fp1
	fsub	fp1,fp0

	fmove.s	fp0,(a2)+

	;d13

	fmove.s	MTX_R0C0(a0),fp0
	fmul.s	MTX_R2C1(a0),fp0
	fmul.s	MTX_R3C2(a0),fp0

	;+

	fmove.s	MTX_R0C1(a0),fp1
	fmul.s	MTX_R2C2(a0),fp1
	fmul.s	MTX_R3C0(a0),fp1
	fadd	fp1,fp0

	;+

	fmove.s	MTX_R0C2(a0),fp1
	fmul.s	MTX_R2C0(a0),fp1
	fmul.s	MTX_R3C1(a0),fp1
	fadd	fp1,fp0

	;-

	fmove.s	MTX_R3C0(a0),fp1
	fmul.s	MTX_R2C1(a0),fp1
	fmul.s	MTX_R0C2(a0),fp1
	fsub	fp1,fp0

	;-

	fmove.s	MTX_R3C1(a0),fp1
	fmul.s	MTX_R2C2(a0),fp1
	fmul.s	MTX_R0C0(a0),fp1
	fsub	fp1,fp0

	;-

	fmove.s	MTX_R3C2(a0),fp1
	fmul.s	MTX_R2C0(a0),fp1
	fmul.s	MTX_R0C1(a0),fp1
	fsub	fp1,fp0

	fmove.s	fp0,(a2)+

	;d20

	fmove.s	MTX_R0C1(a0),fp0
	fmul.s	MTX_R1C2(a0),fp0
	fmul.s	MTX_R3C3(a0),fp0

	;+

	fmove.s	MTX_R0C2(a0),fp1
	fmul.s	MTX_R1C3(a0),fp1
	fmul.s	MTX_R3C1(a0),fp1
	fadd	fp1,fp0

	;+

	fmove.s	MTX_R0C3(a0),fp1
	fmul.s	MTX_R1C1(a0),fp1
	fmul.s	MTX_R3C2(a0),fp1
	fadd	fp1,fp0

	;-

	fmove.s	MTX_R3C1(a0),fp1
	fmul.s	MTX_R1C2(a0),fp1
	fmul.s	MTX_R0C3(a0),fp1
	fsub	fp1,fp0

	;-

	fmove.s	MTX_R3C2(a0),fp1
	fmul.s	MTX_R1C3(a0),fp1
	fmul.s	MTX_R0C1(a0),fp1
	fsub	fp1,fp0

	;-

	fmove.s	MTX_R3C3(a0),fp1
	fmul.s	MTX_R1C1(a0),fp1
	fmul.s	MTX_R0C2(a0),fp1
	fsub	fp1,fp0

	fmove.s	fp0,(a2)+

	;d21

	fmove.s	MTX_R0C0(a0),fp0
	fmul.s	MTX_R1C2(a0),fp0
	fmul.s	MTX_R3C3(a0),fp0

	;+

	fmove.s	MTX_R0C2(a0),fp1
	fmul.s	MTX_R1C3(a0),fp1
	fmul.s	MTX_R3C0(a0),fp1
	fadd	fp1,fp0

	;+

	fmove.s	MTX_R0C3(a0),fp1
	fmul.s	MTX_R1C0(a0),fp1
	fmul.s	MTX_R3C2(a0),fp1
	fadd	fp1,fp0

	;-

	fmove.s	MTX_R3C0(a0),fp1
	fmul.s	MTX_R1C2(a0),fp1
	fmul.s	MTX_R0C3(a0),fp1
	fsub	fp1,fp0

	;-

	fmove.s	MTX_R3C2(a0),fp1
	fmul.s	MTX_R1C3(a0),fp1
	fmul.s	MTX_R0C0(a0),fp1
	fsub	fp1,fp0

	;-

	fmove.s	MTX_R3C3(a0),fp1
	fmul.s	MTX_R1C0(a0),fp1
	fmul.s	MTX_R0C2(a0),fp1
	fsub	fp1,fp0

	fmove.s	fp0,(a2)+

	;d22

	fmove.s	MTX_R0C0(a0),fp0
	fmul.s	MTX_R1C1(a0),fp0
	fmul.s	MTX_R3C3(a0),fp0

	;+

	fmove.s	MTX_R0C1(a0),fp1
	fmul.s	MTX_R1C3(a0),fp1
	fmul.s	MTX_R3C0(a0),fp1
	fadd	fp1,fp0

	;+

	fmove.s	MTX_R0C3(a0),fp1
	fmul.s	MTX_R1C0(a0),fp1
	fmul.s	MTX_R3C1(a0),fp1
	fadd	fp1,fp0

	;-

	fmove.s	MTX_R3C0(a0),fp1
	fmul.s	MTX_R1C1(a0),fp1
	fmul.s	MTX_R0C3(a0),fp1
	fsub	fp1,fp0

	;-

	fmove.s	MTX_R3C1(a0),fp1
	fmul.s	MTX_R1C3(a0),fp1
	fmul.s	MTX_R0C0(a0),fp1
	fsub	fp1,fp0

	;-

	fmove.s	MTX_R3C3(a0),fp1
	fmul.s	MTX_R1C0(a0),fp1
	fmul.s	MTX_R0C1(a0),fp1
	fsub	fp1,fp0

	fmove.s	fp0,(a2)+

	;d23

	fmove.s	MTX_R0C0(a0),fp0
	fmul.s	MTX_R1C1(a0),fp0
	fmul.s	MTX_R3C2(a0),fp0

	;+

	fmove.s	MTX_R0C1(a0),fp1
	fmul.s	MTX_R1C2(a0),fp1
	fmul.s	MTX_R3C0(a0),fp1
	fadd	fp1,fp0

	;+

	fmove.s	MTX_R0C2(a0),fp1
	fmul.s	MTX_R1C0(a0),fp1
	fmul.s	MTX_R3C1(a0),fp1
	fadd	fp1,fp0

	;-

	fmove.s	MTX_R3C0(a0),fp1
	fmul.s	MTX_R1C1(a0),fp1
	fmul.s	MTX_R0C2(a0),fp1
	fsub	fp1,fp0

	;-

	fmove.s	MTX_R3C1(a0),fp1
	fmul.s	MTX_R1C2(a0),fp1
	fmul.s	MTX_R0C0(a0),fp1
	fsub	fp1,fp0

	;-

	fmove.s	MTX_R3C2(a0),fp1
	fmul.s	MTX_R1C0(a0),fp1
	fmul.s	MTX_R0C1(a0),fp1
	fsub	fp1,fp0

	fmove.s	fp0,(a2)+

	;d30

	fmove.s	MTX_R0C1(a0),fp0
	fmul.s	MTX_R1C2(a0),fp0
	fmul.s	MTX_R2C3(a0),fp0

	;+

	fmove.s	MTX_R0C2(a0),fp1
	fmul.s	MTX_R1C3(a0),fp1
	fmul.s	MTX_R2C1(a0),fp1
	fadd	fp1,fp0

	;+

	fmove.s	MTX_R0C3(a0),fp1
	fmul.s	MTX_R1C1(a0),fp1
	fmul.s	MTX_R2C2(a0),fp1
	fadd	fp1,fp0

	;-

	fmove.s	MTX_R2C1(a0),fp1
	fmul.s	MTX_R1C2(a0),fp1
	fmul.s	MTX_R0C3(a0),fp1
	fsub	fp1,fp0

	;-

	fmove.s	MTX_R2C2(a0),fp1
	fmul.s	MTX_R1C3(a0),fp1
	fmul.s	MTX_R0C1(a0),fp1
	fsub	fp1,fp0

	;-

	fmove.s	MTX_R2C3(a0),fp1
	fmul.s	MTX_R1C1(a0),fp1
	fmul.s	MTX_R0C2(a0),fp1
	fsub	fp1,fp0

	fmove.s	fp0,(a2)+

	;d31

	fmove.s	MTX_R0C0(a0),fp0
	fmul.s	MTX_R1C2(a0),fp0
	fmul.s	MTX_R2C3(a0),fp0

	;+

	fmove.s	MTX_R0C2(a0),fp1
	fmul.s	MTX_R1C3(a0),fp1
	fmul.s	MTX_R2C0(a0),fp1
	fadd	fp1,fp0

	;+

	fmove.s	MTX_R0C3(a0),fp1
	fmul.s	MTX_R1C0(a0),fp1
	fmul.s	MTX_R2C2(a0),fp1
	fadd	fp1,fp0

	;-

	fmove.s	MTX_R2C0(a0),fp1
	fmul.s	MTX_R1C2(a0),fp1
	fmul.s	MTX_R0C3(a0),fp1
	fsub	fp1,fp0

	;-

	fmove.s	MTX_R2C2(a0),fp1
	fmul.s	MTX_R1C3(a0),fp1
	fmul.s	MTX_R0C0(a0),fp1
	fsub	fp1,fp0

	;-

	fmove.s	MTX_R2C3(a0),fp1
	fmul.s	MTX_R1C0(a0),fp1
	fmul.s	MTX_R0C2(a0),fp1
	fsub	fp1,fp0

	fmove.s	fp0,(a2)+

	;d32

	fmove.s	MTX_R0C0(a0),fp0
	fmul.s	MTX_R1C1(a0),fp0
	fmul.s	MTX_R2C3(a0),fp0

	;+

	fmove.s	MTX_R0C1(a0),fp1
	fmul.s	MTX_R1C3(a0),fp1
	fmul.s	MTX_R2C0(a0),fp1
	fadd	fp1,fp0

	;+

	fmove.s	MTX_R0C3(a0),fp1
	fmul.s	MTX_R1C0(a0),fp1
	fmul.s	MTX_R2C1(a0),fp1
	fadd	fp1,fp0

	;-

	fmove.s	MTX_R2C0(a0),fp1
	fmul.s	MTX_R1C1(a0),fp1
	fmul.s	MTX_R0C3(a0),fp1
	fsub	fp1,fp0

	;-

	fmove.s	MTX_R2C1(a0),fp1
	fmul.s	MTX_R1C3(a0),fp1
	fmul.s	MTX_R0C0(a0),fp1
	fsub	fp1,fp0

	;-

	fmove.s	MTX_R2C3(a0),fp1
	fmul.s	MTX_R1C0(a0),fp1
	fmul.s	MTX_R0C1(a0),fp1
	fsub	fp1,fp0

	fmove.s	fp0,(a2)+

	;d33

	fmove.s	MTX_R0C0(a0),fp0
	fmul.s	MTX_R1C1(a0),fp0
	fmul.s	MTX_R2C2(a0),fp0

	;+

	fmove.s	MTX_R0C1(a0),fp1
	fmul.s	MTX_R1C2(a0),fp1
	fmul.s	MTX_R2C0(a0),fp1
	fadd	fp1,fp0

	;+

	fmove.s	MTX_R0C2(a0),fp1
	fmul.s	MTX_R1C0(a0),fp1
	fmul.s	MTX_R2C1(a0),fp1
	fadd	fp1,fp0

	;-

	fmove.s	MTX_R2C0(a0),fp1
	fmul.s	MTX_R1C1(a0),fp1
	fmul.s	MTX_R0C2(a0),fp1
	fsub	fp1,fp0

	;-

	fmove.s	MTX_R2C1(a0),fp1
	fmul.s	MTX_R1C2(a0),fp1
	fmul.s	MTX_R0C0(a0),fp1
	fsub	fp1,fp0

	;-

	fmove.s	MTX_R2C2(a0),fp1
	fmul.s	MTX_R1C0(a0),fp1
	fmul.s	MTX_R0C1(a0),fp1
	fsub	fp1,fp0

	fmove.s	fp0,(a2)+

	*** d ***

	lea.l	temp_matrix1,a2

	fmove.s	MTX_R0C0(a0),fp0
	fmul.s	MTX_R0C0(a2),fp0

	fmove.s	MTX_R0C1(a0),fp1
	fmul.s	MTX_R0C1(a2),fp1
	fsub	fp1,fp0

	fmove.s	MTX_R0C2(a0),fp1
	fmul.s	MTX_R0C2(a2),fp1
	fadd	fp1,fp0

	fmove.s	MTX_R0C3(a0),fp1
	fmul.s	MTX_R0C3(a2),fp1
	fsub	fp1,fp0

	ftst	fp0
	fbeq	.Fail

	fmove.s	#1,fp7
	fdiv.s	fp0,fp7

	; row 0

	fmove.s	MTX_R0C0(a2),fp0
	fmove.s	MTX_R1C0(a2),fp1
	fmove.s	MTX_R2C0(a2),fp2
	fmove.s	MTX_R3C0(a2),fp3

	fneg	fp1
	fneg	fp3
	fmul.s	fp7,fp0
	fmul.s	fp7,fp1
	fmul.s	fp7,fp2
	fmul.s	fp7,fp3

	fmove.s	fp0,(a1)+
	fmove.s	fp1,(a1)+
	fmove.s	fp2,(a1)+
	fmove.s	fp3,(a1)+

	; row 1

	fmove.s	MTX_R0C1(a2),fp0
	fmove.s	MTX_R1C1(a2),fp1
	fmove.s	MTX_R2C1(a2),fp2
	fmove.s	MTX_R3C1(a2),fp3

	fneg	fp0
	fneg	fp2
	fmul.s	fp7,fp0
	fmul.s	fp7,fp1
	fmul.s	fp7,fp2
	fmul.s	fp7,fp3

	fmove.s	fp0,(a1)+
	fmove.s	fp1,(a1)+
	fmove.s	fp2,(a1)+
	fmove.s	fp3,(a1)+

	; row 2

	fmove.s	MTX_R0C2(a2),fp0
	fmove.s	MTX_R1C2(a2),fp1
	fmove.s	MTX_R2C2(a2),fp2
	fmove.s	MTX_R3C2(a2),fp3

	fneg	fp1
	fneg	fp3
	fmul.s	fp7,fp0
	fmul.s	fp7,fp1
	fmul.s	fp7,fp2
	fmul.s	fp7,fp3

	fmove.s	fp0,(a1)+
	fmove.s	fp1,(a1)+
	fmove.s	fp2,(a1)+
	fmove.s	fp3,(a1)+

	; row 3

	fmove.s	MTX_R0C3(a2),fp0
	fmove.s	MTX_R1C3(a2),fp1
	fmove.s	MTX_R2C3(a2),fp2
	fmove.s	MTX_R3C3(a2),fp3

	fneg	fp0
	fneg	fp2
	fmul.s	fp7,fp0
	fmul.s	fp7,fp1
	fmul.s	fp7,fp2
	fmul.s	fp7,fp3

	fmove.s	fp0,(a1)+
	fmove.s	fp1,(a1)+
	fmove.s	fp2,(a1)+
	fmove.s	fp3,(a1)+

.Fail

	unlk	a5

	movem.l	(sp)+,d0-a6
	rts
