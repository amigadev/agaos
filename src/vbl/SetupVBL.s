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

;*****i* AgaOS/SetupVBL **********************************************
*
*   NAME
*	SetupVBL - Setup the VBL-subsystem
*   SYNOPSIS
*	success = SetupVBL()
*
*	BOOL SetupVBL(void);
*
*   FUNCTION
*
*   INPUT
*
*   RESULTS
*	success - FALSE if we failed to complete setup of this sub-
*		system.
*   NOTES
*
*   BUGS
*
*   SEE ALSO
*	RemoveVBL()
*
**********************************************************************
*
*
* Setup the VBL-subsystem
*
* IN:	void
*
* OUT:	d0 - FALSE if failure
*

_SetupVBL

	movem.l	d0-a6,-(sp)

	*** allocate copper-signal

	ERRMSG	ERR_VBLSignal
	move.l	_SysBase,a6
	move.l	#-1,d0
	jsr	_LVOAllocSignal(a6)
	move.l	d0,_VBLSignal
	bmi	.Fail

	; compute a bitmask for easy use of the signal

	move.l	#1,d1
.bitmask_loop
	tst.l	d0
	beq	.bitmask_finished

	lsl.l	#1,d1
	subq.l	#1,d0
	bra	.bitmask_loop
.bitmask_finished
	move.l	d1,_VBLSigMask

	*** add vbl-interrupt to system

	move.l	#INTB_VERTB,d0
	lea.l	_VBLInterruptStruct,a1
	jsr	_LVOAddIntServer(a6)

	CLEARERR

	movem.l	(sp)+,d0-a6
	st.l	d0
	rts

.Fail
	movem.l	(sp)+,d0-a6
	clr.l	d0
	rts

	section	data,data

_VBLInterruptStruct
	dc.l	0			; LN_SUCC
	dc.l	0			; LN_PRED
	dc.b	NT_INTERRUPT		; LN_TYPE
	dc.b	127			; LN_PRI
	dc.l	_VBLInterruptName	; LN_NAME
	dc.l	0			; IS_DATA
	dc.l	_MainVBLInterrupt	; IS_CODE

	IFEQ	NOERRORMSGS

ERR_VBLSignal		dc.b	"ERROR: Could not allocate vbl-signal\n",0
ERR_FailedToAdd		dc.b	"ERROR: Failed to add VBL-hook\n",0

	ENDC

_VBLInterruptName	dc.b	"AgaOS VBL Interrupt",0
			even
