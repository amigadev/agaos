;****** AgaOS/--LICENSE-- *******************************************
* Copyright (c) 2001 Jesper Svennevid. All rights reserved.
*
* Redistribution and use in source and binary forms, with or without
* modification, are permitted provided that the following conditions
* are met:
*
*	Redistributions of source code must retain the above copyright
* notice, this list of conditions and the following disclaimer.
*
*	Redistributions in binary form must reproduce the above copyright
* notice, this list of conditions and the following disclaimer in the
* documentation and/or other materials provided with the distribution.
*
* THIS SOFTWARE IS PROVIDED BY THE AUTHOR "AS IS" AND ANY EXPRESS OR
* IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
* WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
* ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
* DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
* DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
* GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
* INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER
* IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
* OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN
* IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*********************************************************************

	machine	68020

	section	code,code

*** startup.s

	; shuts down the system and sets up crucial
	; services required by AgaOS

	include	src/agaos.i

	incdir	include:

	include	exec/types.i
	include	dos/dos.i
	include	dos/dosextens.i

	include	workbench/startup.i

	include	lvo/exec_lib.i
	include	lvo/dos_lib.i

;****** AgaOS/--Overview-- *******************************************
*
* The intention with AgaOS is that it will supply a very simple
* interface to the Amiga AGA hardware and leave a relatively small
* disk-footprint. It might not work out of the box for 4kB-intros,
* but 40kB-intros should be able to use it with ease. (The smallest
* executable among the examples deliveres 1896 bytes.)
*
* AgaOS provides the following:
*
* * Built as a link-library with each function separated into
*   a separate unit, resulting in that only the functions that are
*   really needed get included in the resulting executable.
*
* * Completely system-friendly in every aspect except the display-
*   hardware. Only performance-gaining action is raising the priority
*   a small step.
*
* * A simple, yet powerful copper-list generator.
*
* * A fast and easy-to-use AGA color-fader.
*
* * VBL handling which allows user-extendability and a "frame ready"-
*   waiting that does not include busy-waiting.
*
* * Memory allocation with alignment handling, allocation tracking
*   and overwrite detection.
*
* * Extensive documentation over every function, providing the user
*   answers to many of the questions they may have without forcing
*   them to read the actual code.
*
* * Complete library of matrix routines, written in FPU assembler,
*   compatible with all available co-processors.
*
**********************************************************************
*

;****** AgaOS/Startup ************************************************
*
*   NAME
*	Startup - Setup AgaOS for use
*
*   SYNOPSIS
*	success = Startup(flags)
*	d0		  d0
*
*	BOOL Startup(ULONG flags);
*
*   FUNCTION
*	This functions sets up all the sub-systems that are contained
*	within AgaOS and readies them for use.
*
*	The following actions are taken:
*
*		- Workbench messages are handled (and current path modified)
*		- The priority is raised to 1 to avoid all pri 0-tasks
*		- System is validated (SetPatch, AGA, etc)
*		- Default-palettes are generated (White, Greyscale)
*		- Math tables are generated
*		- Needed libraries are opened
*		- Memory-pools are created (chip & public)
*		- Input-handler is installed
*		- The system viewport is reset
*		- VBL interrupt chain is started
*   INPUT
*	flags - Requirements for startup. Possible flags are:
*		(mask together when using)
*
*		AASTRF_FPU:	This program requires that an FPU is
*				present, and will fail if there is none.
*
*   RESULTS
*	success - FALSE if any error occured. If it did, you can NOT
*		rely on that ANY AgaOS sub-system is set up. Skip
*		directly to end of the program and call Shutdown().
*
*   NOTES
*
*   BUGS
*
*   SEE ALSO
*	Shutdown()
*
**********************************************************************
*

_Startup

	movem.l	d0-a6,-(sp)				; push all registers

	*** store flags

	move.l	d0,d7

	*** store sysbase for faster access

	IFEQ	MINIEXEC
	move.l	(4).w,_SysBase				; store exec-pointer
	ENDC

	*** find and store task

	move.l	_SysBase,a6				; get exec-pointer
	sub.l	a1,a1					; no task-name
	jsr	_LVOFindTask(a6)			; get pointer to this task
	move.l	d0,_PtrTask				; store pointer (never fails)

	*** open libraries

	jsr	_OpenLibraries
	tst.l	d0
	beq	.Fail

	*** workbench startup

	move.l	_PtrTask,a0
	tst.l	pr_CLI(a0)
	bne	.no_wbstartup

	; get message from workbench

	move.l	_SysBase,a6
	lea.l	pr_MsgPort(a0),a0
	jsr	_LVOGetMsg(a6)
	move.l	d0,_PtrMessage

	; change current directory

	move.l	_DOSBase,a6
	move.l	d0,a0
	move.l	sm_ArgList(a0),a0
	move.l	wa_Lock(a0),d1		; first message is WBArg
	jsr	_LVOCurrentDir(a6)
	move.l	d0,_PtrOldLock	

.no_wbstartup

	*** raise priority

	; this will stop all the tasks running at pri 0
	; to steal CPU

	move.l	d0,a1	; d0 = task
	move.l	#1,d0
	jsr	_LVOSetTaskPri(a6)
	move.l	d0,_OldTaskPri

	*** See if system can handle AgaOS

	move.l	d7,d0
	jsr	_CheckSystem
	tst.l	d0
	beq	.Fail

	*** Generate palettes

	jsr	_GeneratePalettes

	*** setup math

	jsr	_SetupMath

	*** initialize memory

	jsr	_SetupMemory
	tst.l	d0
	beq	.Fail

	*** install input-handler

	jsr	_InstallInputHandler
	tst.l	d0
	beq	.Fail

	; ok, now the intuition input won´t
	; trouble the hardware-screen

	*** kill intuition

	jsr	_InstallScreen
	tst.l	d0
	beq	.Fail

	*** setup vbl

	jsr	_SetupVBL
	tst.l	d0
	beq	.Fail

	movem.l	(sp)+,d0-a6				; pop all registers
	st.l	d0					; set success
	rts						; return
.Fail
	movem.l	(sp)+,d0-a6				; pop all registers
	clr.l	d0					; set failure
	rts						; return

	public	_OldTaskPri
	public	_PtrTask
	public	_PtrMessage
	public	_PtrOldLock
