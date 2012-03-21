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

;****** AgaOS/Matrix_Rotate ****************************************
*
*   NAME
*	Matrix_Rotate - Rotate matrix.
*
*   SYNOPSIS
*	Matrix_Rotate(input,output,heading,pitch,bank)
*	              a0    a1     fp0     fp1   fp2
*
*	void Matrix_Identity(Matrix4*,Matrix4*,double,double,double);
*
*   FUNCTION
*	Rotate the matrix passed from 'input' around heading, pitch
*	and bank, and stores it in 'output'.
*
*   INPUT
*	input - Input matrix.
*	output - Output matrix.
*	heading - Heading axis value.
*	pitch - Pitch axis value.
*	bank - Bank axis value.
*
*   RESULTS
*
*   NOTES
*	This routine requires a FPU. If you intend to allow the
*	program to run on all systems that atleast provide a
*	MC68020 but no FPU, you should not run this.
*
*   BUGS
*	FSIN and FCOS are used, even though they are emulated on
*	MC68040+ systems. This behaviour will change.
*
*   SEE ALSO
*
**********************************************************************
*
*
*

_Matrix_Rotate
*************************************************
*						*
* Rotate a matrix using heading, pitch and bank.*
*						*
* IN:	a0  - Ptr to 4x4 matrix	(input)		*
*	a1  - Ptr to 4x4 matrix (output)	*
*	fp0 - Heading				*
*	fp1 - Pitch				*
*	fp2 - Bank				*
*						*
* USES:	fp0,fp1,fp2,fp3,fp4,fp5,fp6		*
*						*
*************************************************

	movem.l	d0-a6,-(sp)

	link	a5,#-STACKSIZE

	; store input & output

	move.l	a0,a3
	move.l	a1,a4

	; store constants

	fmove.s	#0.0,fp3
	fmove.s	fp3,d0
	fmove.s	#1.0,fp3
	fmove.s	fp3,d1

	; build pitch (temp1)

	lea.l	temp_matrix1,a2

	fsin	fp1,fp3		;sin
	fcos	fp1,fp4		;cos
	fmove	fp3,fp5
	fneg	fp5		;-sin

	;row0  1  0  0  0
	;row1  0  c  s  0
	;row2  0 -s  c  0
	;row3  0  0  0  1

	move.l	d1,(a2)+	;r0c0
	move.l	d0,(a2)+	;r0c1
	move.l	d0,(a2)+	;r0c2
	move.l	d0,(a2)+	;r0c3

	move.l	d0,(a2)+	;r1c0
	fmove.s	fp4,(a2)+	;r1c1
	fmove.s	fp3,(a2)+	;r1c2
	move.l	d0,(a2)+	;r1c3

	move.l	d0,(a2)+	;r2c0
	fmove.s	fp5,(a2)+	;r2c1
	fmove.s	fp4,(a2)+	;r2c2
	move.l	d0,(a2)+	;r2c3

	move.l	d0,(a2)+	;r3c0
	move.l	d0,(a2)+	;r3c1
	move.l	d0,(a2)+	;r3c2
	move.l	d1,(a2)+	;r3c3

	; build bank (temp2)

	lea.l	temp_matrix2,a2

	fsin	fp2,fp3		;sin
	fcos	fp2,fp4		;cos
	fmove	fp3,fp5
	fneg	fp5		;-sin

	;row0  c  s  0  0
	;row1 -s  c  0  0
	;row2  0  0  1  0
	;row3  0  0  0  1

	fmove.s	fp4,(a2)+	;r0c0
	fmove.s	fp3,(a2)+	;r0c1
	move.l	d0,(a2)+	;r0c2
	move.l	d0,(a2)+	;r0c3

	fmove.s	fp5,(a2)+	;r1c0
	fmove.s	fp4,(a2)+	;r1c1
	move.l	d0,(a2)+	;r1c2
	move.l	d0,(a2)+	;r1c3

	move.l	d0,(a2)+	;r2c0
	move.l	d0,(a2)+	;r2c1
	move.l	d1,(a2)+	;r2c2
	move.l	d0,(a2)+	;r2c3

	move.l	d0,(a2)+	;r3c0
	move.l	d0,(a2)+	;r3c1
	move.l	d0,(a2)+	;r3c2
	move.l	d1,(a2)+	;r3c3

	; temp3 = temp1 * temp2 (pitch * bank)

	fmove	fp0,fp6
	lea.l	temp_matrix1,a0
	lea.l	temp_matrix2,a1
	lea.l	temp_matrix3,a2
	jsr	_Matrix_Multiply
	fmove	fp6,fp0

	; build heading (temp1)

	lea.l	temp_matrix1,a2

	fsin	fp0,fp3		;sin
	fcos	fp0,fp4		;cos
	fmove	fp3,fp5
	fneg	fp5		;-sin

	;row0  c  0 -s  0
	;row1  0  1  0  0
	;row2  s  0  c  0
	;row3  0  0  0  1

	fmove.s	fp4,(a2)+	;r0c0
	move.l	d0,(a2)+	;r0c1
	fmove.s	fp5,(a2)+	;r0c2
	move.l	d0,(a2)+	;r0c3

	move.l	d0,(a2)+	;r1c0
	move.l	d1,(a2)+	;r1c1
	move.l	d0,(a2)+	;r1c2
	move.l	d0,(a2)+	;r1c3

	fmove.s	fp3,(a2)+	;r2c0
	move.l	d0,(a2)+	;r2c1
	fmove.s	fp4,(a2)+	;r2c2
	move.l	d0,(a2)+	;r2c3

	move.l	d0,(a2)+	;r3c0
	move.l	d0,(a2)+	;r3c1
	move.l	d0,(a2)+	;r3c2
	move.l	d1,(a2)+	;r3c3

	;temp2 = temp1 * temp3 (heading * (pitch * bank))

	lea.l	temp_matrix1,a0
	lea.l	temp_matrix3,a1
	lea.l	temp_matrix2,a2
	jsr	_Matrix_Multiply

	; output = input * temp2 (mtx * (heading * (pitch * bank)))

	move.l	a3,a0
	lea.l	temp_matrix2,a1
	move.l	a4,a2
	jsr	_Matrix_Multiply

	unlk	a5

	movem.l	(sp)+,d0-a6
	rts
