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

	include	src/agaos.i

	incdir	include:

	include	dos/dos.i

	include	lvo/dos_lib.i

;****** AgaOS/FileLoad *******************************************
*
*   NAME
*	FileLoad - Load file into memory
*
*   SYNOPSIS
*	success = FileLoad(filename,destination,amount)
*	d0		   a0	    a1		d0
*
*
*	BOOL FileLoad(char* filename, void* destination, LONG amount);
*
*   FUNCTION
*
*   INPUT
*	filename - pointer to filename, null-terminated
*	destination - pointer to destination data-area
*	amount - How much data we should read (-1 to read entire file)
*
*   RESULTS
*	success - FALSE if file-loading failed
*
*   NOTES
*
*   BUGS
*
*   SEE ALSO
*
**********************************************************************
*
* Load file into memory
*
* IN:	a0 - file name
*	a1 - destination
*	d0 - amount of data to load (-1 for entire file)
*
* OUT:	d0 - FALSE if failed
*

_FileLoad
	movem.l	d0-a6,-(sp)

	move.l	a0,.file_Name
	move.l	a1,.file_Dest
	move.l	d0,.file_Size
	clr.l	.file_Handle

	*** open file

	ERRMSG	ERR_FailedOpening
	move.l	_DOSBase,a6
	move.l	.file_Name,d1
	move.l	#MODE_OLDFILE,d2
	jsr	_LVOOpen(a6)
	move.l	d0,.file_Handle
	beq	.Fail	

	*** See if we should query for filename

	tst.l	.file_Size
	bpl	.no_size_query

	move.l	#DOS_FIB,d1
	move.l	#0,d2
	jsr	_LVOAllocDosObject(a6)

	ERRMSG	ERR_SizeQuery
	bra	.Fail

.no_size_query

	*** load data

	move.l	.file_Handle,d1
	move.l	.file_Dest,d2
	move.l	.file_Size,d3
	jsr	_LVORead(a6)

	st.l	.file_RC
	CLEARERR

.Cleanup

	tst.l	.file_FIB
	beq	.no_fib

	move.l	_DOSBase,a6
	move.l	#DOS_FIB,d1
	move.l	.file_FIB,d2
	jsr	_LVOFreeDosObject(a6)
	clr.l	.file_FIB

.no_fib

	tst.l	.file_Handle
	beq	.no_file

	move.l	_DOSBase,a6
	move.l	.file_Handle,d1
	jsr	_LVOClose(a6)
	clr.l	.file_Handle

.no_file

	movem.l	(sp)+,d0-a6
	move.l	.file_RC,d0
	rts

.Fail
	clr.l	.file_RC
	bra	.Cleanup


.file_RC	ds.l	1
.file_Handle	ds.l	1
.file_Size	ds.l	1
.file_Name	ds.l	1
.file_Dest	ds.l	1
.file_Lock	ds.l	1
.file_FIB	ds.l	1

_GetFileSize
	movem.l	d1-a6,-(sp)
	movem.l	(sp)+,d1-a6
	rts

	section	data,data

	IFEQ	NOERRORMSGS

ERR_FailedOpening	dc.b	"ERROR: Failed opening file\n",0
ERR_SizeQuery		dc.b	"ERROR: Size-query not implemented\n",0

	ENDC
