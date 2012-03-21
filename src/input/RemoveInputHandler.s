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

*** input.s

	; handles user-input (swallowing, processing)

	include	src/agaos.i

	incdir	include:

	include	exec/types.i
	include	exec/funcdef.i
	include	exec/memory.i
	include	exec/interrupts.i
	include	exec/io.i

	include	devices/input.i
	include	devices/inputevent.i

	include	exec/exec_lib.i

;*****i* AgaOS/RemoveInputHandler ************************************
*
*   NAME
*
*   SYNOPSIS
*
*   FUNCTION
*
*   INPUT
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

_RemoveInputHandler
	movem.l	d0-a6,-(sp)

	*** Remove input-handler

	tst.l	_IHandlerAdded
	beq	.no_ihandler

	move.l	_SysBase,a6
	move.l	_InputIO,a1
	move.l	#_IHandler_Structure,IO_DATA(a1)
	move.w	#IND_REMHANDLER,IO_COMMAND(a1)	
	jsr	_LVODoIO(a6)

	clr.l	_IHandlerAdded

.no_ihandler

	*** Close input.device

	tst.l	_InputOpen
	beq	.no_device

	move.l	_SysBase,a6
	move.l	_InputIO,a1
	jsr	_LVOCloseDevice(a6)
	clr.l	_InputOpen

.no_device

	*** Delete IOStdReq

	tst.l	_InputIO
	beq	.no_request

	move.l	_SysBase,a6
	move.l	_InputIO,a0
	jsr	_LVODeleteIORequest(a6)
	clr.l	_InputIO

.no_request

	*** Delete MsgPort

	tst.l	_InputPort
	beq	.no_msgport

	move.l	_SysBase,a6
	move.l	_InputPort,a0
	jsr	_LVODeleteMsgPort(a6)
	clr.l	_InputPort

.no_msgport

	movem.l	(sp)+,d0-a6
	rts

	public	_IHandler_Structure
	public	_IHandlerAdded
	public	_InputOpen
	public	_InputPort
	public	_InputIO
