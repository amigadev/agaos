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

	public	_IHandler_Code

;*****i* AgaOS/InstallInputHandler ***********************************
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

_InstallInputHandler
	movem.l	d0-a6,-(sp)

	*** Create MsgPort

	ERRMSG	ERR_MessagePort
	move.l	_SysBase,a6
	jsr	_LVOCreateMsgPort(a6)
	move.l	d0,_InputPort
	beq	.Fail

	*** Create IOStdReq

	ERRMSG	ERR_IORequest
	move.l	_SysBase,a6
	move.l	_InputPort,a0
	move.l	#IOSTD_SIZE,d0
	jsr	_LVOCreateIORequest(a6)
	move.l	d0,_InputIO
	beq	.Fail

	*** Open input.device

	ERRMSG	ERR_OpenDevice
	move.l	_SysBase,a6
	lea.l	_InputName,a0
	move.l	#0,d0
	move.l	_InputIO,a1
	move.l	#0,d1
	jsr	_LVOOpenDevice(a6)
	tst.l	d0
	bne	.Fail

	st.l	_InputOpen

	*** Initalize handler

	lea.l	_IHandler_Structure,a2
        move.l  #_IHandler_Code,IS_CODE(a2)
	clr.l	IS_DATA(a2)
	move.b	#100,LN_PRI(a2)
	move.l	#_IHandler_Name,LN_NAME(a2)

	*** Insert input-handler

	ERRMSG	ERR_InputInstall
	move.l	_SysBase,a6
	move.l	_InputIO,a1
	move.l	#_IHandler_Structure,IO_DATA(a1)
	move.w	#IND_ADDHANDLER,IO_COMMAND(a1)	
	jsr	_LVODoIO(a6)
	tst.l	d0
	bne	.Fail

	st.l	_IHandlerAdded

	CLEARERR

	movem.l	(sp)+,d0-a6
	st.l	d0
	rts
.Fail
	movem.l	(sp)+,d0-a6
	clr.l	d0
	rts

	section	data,data

	*** Strings

_IHandler_Name	dc.b	"AgaOS Input Handler",0
_InputName	dc.b	"input.device",0


	IFEQ	NOERRORMSGS

ERR_MessagePort		dc.b	"ERROR: Failed creating message-port\n",0
ERR_IORequest		dc.b	"ERROR: Failed creating IO-request\n",0
ERR_OpenDevice		dc.b	"ERROR: Failed opening input.device\n",0
ERR_InputInstall	dc.b	"ERROR: Failed installing input-handler\n",0

	ENDC

	section	bss,bss

	*** Misc. variables

	public	_IHandler_Structure
	public	_IHandlerAdded
	public	_InputOpen
	public	_InputPort
	public	_InputIO

_IHandler_Structure	ds.b	IS_SIZE

_IHandlerAdded		ds.l	1
_InputOpen		ds.l	1
_InputPort		ds.l	1
_InputIO		ds.l	1
