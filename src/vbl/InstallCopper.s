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

*** vbl.s

	; handles the vertical blanking
	; interrupt

	*** local unit exports

	public	_VBLHookList
	public	_VBLSigMask
	public	_CopperPointer
	public	_MainVBLInterrupt
	public	_VBLSignal
	public	_VBLInterruptStruct

	include	src/agaos.i

	incdir	include:

	include	exec/nodes.i
	include	exec/interrupts.i

	include	hardware/custom.i
	include	hardware/intbits.i

	include	lvo/exec_lib.i

 STRUCTURE	VBH_VBHook,0
	APTR	VBH_Next
	APTR	VBH_Code
	APTR	VBH_Data
	LABEL	VBH_SIZEOF

;****** AgaOS/InstallCopper ******************************************
*
*   NAME
*	InstallCopper - Instruct AgaOS to use a new copper-list
*
*   SYNOPSIS
*	InstallCopper(coplist)
*		      a0
*
*	void InstallCopper(UWORD*);
*
*   FUNCTION
*	This functions will modify the internal copper-list pointer
*	to point to a new location. This copper-list will be installed
*	on the next vertical retrace.
*
*   INPUT
*	coplist - Pointer to the new copper-list. This list MUST reside
*		in chip-memory, otherwise the effects are undefined.
*
*   RESULTS
*
*   NOTES
*
*   BUGS
*
*   SEE ALSO
*
**********************************************************************
*
* Install a new copper-list (the copper-
* list will actually be installed on the
* next vertical retrace)
*
* IN:	a0 - pointer to copper-list
*
* OUT:	void
*

_InstallCopper

	movem.l	d0-a6,-(sp)

	move.l	a0,_CopperPointer

	movem.l	(sp)+,d0-a6
	rts
