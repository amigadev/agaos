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

;****** AgaOS/Matrix_Multiply ****************************************
*
*   NAME
*	Matrix_Multiply - Merge two matrices.
*
*   SYNOPSIS
*	Matrix_Multiply(inputA,inputB,output)
*	                a0     a1     a2
*
*	void Matrix_Multiply(Matrix4*,Matrix4*,Matrix4*);
*
*   FUNCTION
*	Merge actions taken with 'inputA' with the actions in 'inputB'
*	and store result in 'output'.
*
*   INPUT
*	inputA - Input matrix A.
*	inputB - Input matrix B.
*	output - Output matrix.
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

_Matrix_Multiply
*************************************************
*						*
* Multiply two matrices.			*
*						*
* IN:	a0 - Ptr to 4x4 Matrix (Input A)	*
*	a1 - Ptr to 4x4 Matrix (Input B)	*
*	a2 - Ptr to 4x4 Matrix (Output)		*
*						*
* USES: fp0,fp1,fp2				*
*						*
*************************************************

	movem.l	d0-a6,-(sp)

	clr.l	d7
.row_loop
	cmp.l	#4,d7
	beq	.row_loop_end

	clr.l	d6
.col_loop
	cmp.l	#4,d6
	beq	.col_loop_end

	fmove.s	#0.0,fp0		; clear temporary register

	clr.l	d5
.mul_loop
	cmp.l	#4,d5
	beq	.mul_loop_end

	; compute input 1 offset & fetch

	move.l	d7,d0
	lsl.l	#2,d0
	add.l	d5,d0
	fmove.s	(a0,d0.l*4),fp1

	; compute input 2 offset & fetch

	move.l	d5,d0
	lsl.l	#2,d0
	add.l	d6,d0
	fmove.s	(a1,d0.l*4),fp2

	; multiply and add to result

	fmul	fp1,fp2
	fadd	fp2,fp0

	addq.l	#1,d5
	bra	.mul_loop
.mul_loop_end

	fmove.s	fp0,(a2)+		; write to output matrix

	addq.l	#1,d6
	bra	.col_loop
.col_loop_end

	addq.l	#1,d7
	bra	.row_loop
.row_loop_end

	movem.l	(sp)+,d0-a6
	rts
