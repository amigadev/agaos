	IFND	__AGAOS_I
__AGAOS_I	EQU	1

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

	incdir	include:
	include	exec/types.i

	*****************************************
	*** Compile Time Switches
	*****************************************

	*** Enable any of these to shrink the
	*** executable-size or prohibit execution
	*** on non-amiga systems. When enabled,
	*** these switches might affect the
	*** performance and stability of the
	*** produced application

UAEFAIL = 0		; 1 = Executable fails on UAE-systems
MINIEXEC = 1		; 1 = Execbase-caching is disabled
NOERRORMSGS = 0		; 1 = Error-messages are supressed (and not included)

ERRMSG		MACRO

	IFEQ	NOERRORMSGS
	move.l	#\1,_LastError
	ENDC

		ENDM

CLEARERR	MACRO

	IFEQ	NOERRORMSGS
	clr.l	_LastError
	ENDC

		ENDM

	*****************************************
	*** COPPER
	*****************************************

	*** exported functions

	public	_BuildDisplay
	public	_WriteCopperPtrs

	*** exported data

	public	_DummySprite

	*** tags used for BuildDisplay()

	* bitplane

CB_Flags	EQU	$0001

CB_BplScrollX	EQU	$1001			; Bitplane X-scroll (shires)
CB_BplScrollY	EQU	$1002			; Bitplane Y-scroll (shires)
CB_BplWidth	EQU	$1003			; Bitplane Width
CB_BplHeight	EQU	$1004			; Bitplane Height
CB_BplDepth	EQU	$1005			; Bitplane Depth (0-8 bitplanes)
CB_BplFlags	EQU	$1006			; Bitplane Flags
CB_BplPointer	EQU	$1007			; Bitplane Pointer
CB_BplIndirect	EQU	$1008			; Bitplane Pointer (Indirect)

	BITDEF	CBB,DUALPF,0			; Dual-playfield mode
	BITDEF	CBB,PF2PRIO,1			; Playfield 2 Prio over Playfield 1

	* display

CB_DispPosX	EQU	$2001			; Display X-position (shires)
CB_DispPosY	EQU	$2002			; Display Y-position (lowres)
CB_DispWidth	EQU	$2003			; Display width (shires)
CB_DispHeight	EQU	$2004			; Display height (lowres)
CB_DispFlags	EQU	$2005			; Display flags

	BITDEF	CBD,HIRES,0			; Display is hires
	BITDEF	CBD,SHIRES,1			; Display is super-hires
	BITDEF	CBD,LACE,2			; Display is laced
	BITDEF	CBD,HAM,3			; Display is HAM
	BITDEF	CBD,EHB,4			; Display is EHB
	BITDEF	CBD,DBLSCAN,5			; Double-scan

	* sprite

CB_SpriteFlags	EQU	$3001			; Sprite Flags

CB_SprPtr0	EQU	$3002			; Pointer to sprite 0
CB_SprPtr1	EQU	$3003			; Pointer to sprite 1
CB_SprPtr2	EQU	$3004			; Pointer to sprite 2
CB_SprPtr3	EQU	$3005			; Pointer to sprite 3
CB_SprPtr4	EQU	$3006			; Pointer to sprite 4
CB_SprPtr5	EQU	$3007			; Pointer to sprite 5
CB_SprPtr6	EQU	$3008			; Pointer to sprite 6

* sprite 7 disabled (invisible due to display-setting)

	*****************************************
	*** STARTUP
	*****************************************

	*** exported functions

	public	_Startup
	public	_Shutdown

	*** exported data

	public	_PtrTask

	*** startup flags

	BITDEF	AASTR,FPU,0			; Program requires FPU

	*****************************************
	*** INPUT
	*****************************************

	*** exported functions

	public	_InstallInputHandler
	public	_RemoveInputHandler

	*****************************************
	*** LIBRARIES
	*****************************************

	*** exported functions

	public	_OpenLibraries
	public	_CloseLibraries

	*** exported data

	public	_DOSName
	public	_GfxName
	public	_IntuitionName

	IFEQ	MINIEXEC
	public	_SysBase
	ELSE
_SysBase	EQU	($4).w
	ENDC
	public	_DOSBase
	public	_GfxBase
	public	_IntuitionBase

	*****************************************
	*** SCREEN
	*****************************************

	*** exported functions

	public	_InstallScreen
	public	_RemoveScreen

	*****************************************
	*** VBL
	*****************************************

	*** exported functions

	public	_SetupVBL
	public	_RemoveVBL

	public	_WaitVBL

	public	_AttachVBLHook
	public	_DetachVBLHook

	public	_InstallCopper

	*** exported data

	public	_VBLTimer

	*****************************************
	*** FADE
	*****************************************

	*** structures

 STRUCTURE	FDS_FadeStructure,0
	LONG	FDS_Iterator		; internal counter
	LONG	FDS_FirstColor		; first color to fade
	LONG	FDS_LastColor		; last color to fade
	LONG	FDS_BPLCON3		; BPLCON3 mask for bank-selection

	STRUCT	FDS_ValueColor,256*3*2	; all color values (current iteration RGB, 16 bits per gun)
	STRUCT	FDS_DeltaColor,256*3*2	; all delta-colors (RGB, 16 bits per gun)
	STRUCT	FDS_FadeBuffer,256*4	; internal fade-buffer (for _LoadColors)

	LABEL	FDS_SIZEOF

	*** exported functions

	public	_GeneratePalettes

	public	_BeginFade
	public	_DoFade

	public	_LoadColors

	*** exported variables

	public	_BlackPalette		; 256 longwords, $000000
	public	_WhitePalette		; 256 longwords, $ffffff
	public	_GreyscalePalette	; 256 longwords, ranging from $000000 to $ffffff

	*****************************************
	*** MATH
	*****************************************

	*** exported functions

	public	_SetupMath
	public	_RemoveMath

	*** exported data

	public	_Cos1024		; cosinus, 1024 values, longwords, amplitude: -32768 to 32767
	public	_Sin1024		; sinus, 1024 values, longwords, amplitude: -32768 to 32767

	*****************************************
	*** MEM
	*****************************************

	*** exported functions

	public	_SetupMemory
	public	_RemoveMemory

	public	_MemAlloc
	public	_MemFree
	public	_MemClear
	public	_MemCopy

	*** memory flags

	BITDEF	AAMEM,CHIP,0			; allocate chip-memory
	BITDEF	AAMEM,ALIGN,1			; align allocation to 64-bit boundaries
	BITDEF	AAMEM,MMU,2			; align allocation for mmu-usage

	*****************************************
	*** FILE
	*****************************************

	*** exported functions

	public	_FileLoad

	*** data-file interface

	;public	_DataOpen
	;public	_DataClose

	;public	_DataObtain
	;public	_DataRelease

	*****************************************
	*** SYSTEM
	*****************************************

	*** exported functions

	public	_CheckSystem

	*****************************************
	*** VECTOR
	*****************************************

	;NOTE! These routines REQUIRE an FPU to
	;run! If you use them, make sure to call
	;Startup() with AASTRF_FPU!!! If not,
	;non-FPU machines will crash!!!

	*** constants

PI	EQU.X	3.14159265358979323846

	*** structures

 STRUCTURE MTX_Matrix,0
	FLOAT	MTX_R0C0
	FLOAT	MTX_R0C1
	FLOAT	MTX_R0C2
	FLOAT	MTX_R0C3

	FLOAT	MTX_R1C0
	FLOAT	MTX_R1C1
	FLOAT	MTX_R1C2
	FLOAT	MTX_R1C3

	FLOAT	MTX_R2C0
	FLOAT	MTX_R2C1
	FLOAT	MTX_R2C2
	FLOAT	MTX_R2C3

	LABEL	MTX_X
	FLOAT	MTX_R3C0
	LABEL	MTX_Y
	FLOAT	MTX_R3C1
	LABEL	MTX_Z
	FLOAT	MTX_R3C2
	FLOAT	MTX_R3C3

	LABEL	MTX_SIZEOF

 STRUCTURE VTX_Vertex,0
	FLOAT	VTX_X
	FLOAT	VTX_Y
	FLOAT	VTX_Z
	LABEL	VTX_SIZEOF

	*** exported functions

	public	_Matrix_Identity
	public	_Matrix_Rotate
	public	_Matrix_Translate
	public	_Matrix_Scale
	public	_Matrix_Multiply
	public	_Matrix_Apply
	public	_Matrix_Invert

	*****************************************
	*** AUDIO / STREAMING
	*****************************************

	*** structures

 STRUCTURE	SB_StreamBuffer,0
	ULONG	SB_Status		; status, private
	ULONG	SB_BufferSize		; size in bytes of each channel
	APTR	SB_Channel0		; channel 0 buffer
	APTR	SB_Channel1		; channel 1 buffer
	APTR	SB_Channel2		; channel 2 buffer
	APTR	SB_Channel3		; channel 3 buffer
	LABEL	SB_SIZEOF

	*** exported functions

	public	_InstallAudioStream
	public	_RemoveAudioStream

	public	_StartAudioStream
	public	_StopAudioStream

	public	_LockStreamBuffer
	public	_UnlockStreamBuffer

	*****************************************
	*** ERROR
	*****************************************

	; points to an error-string which will be printed by
	; _Shutdown

	IFEQ	NOERRORMSGS

	public	_LastError

	ENDC

	ENDC
