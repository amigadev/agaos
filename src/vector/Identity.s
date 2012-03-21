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

;****** AgaOS/Matrix_Identity ****************************************
*
*   NAME
*	Matrix_Identity - Setting matrix to identity
*
*   SYNOPSIS
*	Matrix_Identity(input)
*			a0
*
*	void Matrix_Identity(Matrix4*);
*
*   FUNCTION
*	Loads the input-matrix with the values representing a
*	identity matrix:
*
*	[1.0 0.0 0.0 0.0]
*	[0.0 1.0 0.0 0.0]
*	[0.0 0.0 1.0 0.0]
*	[0.0 0.0 0.0 1.0]
*
*   INPUT
*	input - Input matrix that will be loaded with identity.
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

_Matrix_Identity
*************************************************
*						*
* Set the matrix to reflect an identity-matrix.	*
*						*
* [1.0 0.0 0.0 0.0]				*
* [0.0 1.0 0.0 0.0]				*
* [0.0 0.0 1.0 0.0]				*
* [0.0 0.0 0.0 1.0]				*
*						*
* IN:	a0 - Ptr to matrix.			*
*						*
* USES: fp0,fp1					*
*						*
*************************************************

	movem.l	d0-a6,-(sp)

	fmove.s	#0.0,fp0
	fmove.s	#1.0,fp1
	fmove.s	fp0,d0
	fmove.s	fp1,d1

	;1 0 0 0
	move.l	d1,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+

	;0 1 0 0
	move.l	d0,(a0)+
	move.l	d1,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+

	;0 0 1 0
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d1,(a0)+
	move.l	d0,(a0)+

	;0 0 0 1
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d1,(a0)+

	movem.l	(sp)+,d0-a6
	rts
