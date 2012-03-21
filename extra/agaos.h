#ifndef	__AGAOS_H
#define __AGAOS_H

/*************************************************************************
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
*************************************************************************/

#include <exec/types.h>
#include <exec/tasks.h>
#include <exec/libraries.h>

#include <dos/dosextens.h>

/*
	Compiler specific-switches
*/

#ifdef __GNUC__
#	define PREG(x) register
#	define REG(x) __asm(#x)
#	define ASM
#else
#	ifdef VBCC
#		define REG(x) __reg(#x)
#		define ASM
#	else
#		define PREG(x) register __##x
#		define REG(x)
#		define ASM __asm
#	endif
#endif


	/****************************************
	*** COPPER
	****************************************/

	/*** exported functions */

extern ASM UWORD* BuildDisplay(PREG(a0) LONG* REG(a0), PREG(a1) UWORD* REG(a1));
extern ASM UWORD* WriteCopperPtrs(PREG(a0) UWORD* REG(a0), PREG(d0) APTR REG(d0), PREG(d1) ULONG REG(d1), PREG(d2) ULONG REG(d2), PREG(d3) UWORD REG(d3)); 

	/*** exported data */

extern void* _DummySprite;

	/*** tags used for BuildDisplay() */

#define	CB_Flags	0x0001

	/* bitplane */

#define CB_BplScrollX	0x1001			/* Bitplane X-scroll (shires) */
#define CB_BplScrollY	0x1002			/* Bitplane Y-scroll (shires) */
#define CB_BplWidth	0x1003			/* Bitplane Width */
#define CB_BplHeight	0x1004			/* Bitplane Height */
#define CB_BplDepth	0x1005			/* Bitplane Depth (0-8 bitplanes) */
#define	CB_BplFlags	0x1006			/* Bitplane Flags */
#define CB_BplPointer	0x1007			/* Bitplane Pointer */
#define CB_BplIndirect	0x1008			/* Bitplane Pointer (Indirect) */

#define CBBB_DUALPF	0			/* Dual-playfield mode */
#define CBBF_DUALPF	(1<<CBBB_DUALPF)
#define CBBB_PF2PRIO	1			/* Playfield 2 Prio over Playfield 1 */
#define CBBF_PF2PRIO	(1<<CBBB_PF2PRIO)


	/* display */

#define	CB_DispPosX	0x2001			/* Display X-position (shires) */
#define	CB_DispPosY	0x2002			/* Display Y-position (lowres) */
#define CB_DispWidth	0x2003			/* Display width (shires) */
#define CB_DispHeight	0x2004			/* Display height (lowres) */
#define CB_DispFlags	0x2005			/* Display flags */

#define	CBDB_HIRES	0			/* Display is hires */
#define CBDF_HIRES	(1<<CBDB_HIRES)
#define	CBDB_SHIRES	1			/* Display is super-hires */
#define CBDF_SHIRES	(1<<CBDB_SHIRES)
#define	CBDB_LACE	2			/* Display is laced */
#define CBDF_LACE	(1<<CBDB_LACE)
#define	CBDB_HAM	3			/* Display is HAM */
#define CBDF_HAM	(1<<CBDB_HAM)
#define	CBDB_EHB	4			/* Display is EHB */
#define CBDF_EHB	(1<<CBDB_EHB)
#define	CBDB_DBLSCAN	5			/* Double-scan */
#define CBDF_DBLSCAN	(1<<CBDB_DBLSCAN)

	/* sprite */

#define CB_SpriteFlags	0x3001			/* Sprite Flags */

#define	CB_SprPtr0	0x3002			/* Pointer to sprite 0 */
#define	CB_SprPtr1	0x3003			/* Pointer to sprite 1 */
#define	CB_SprPtr2	0x3004			/* Pointer to sprite 2 */
#define	CB_SprPtr3	0x3005			/* Pointer to sprite 3 */
#define	CB_SprPtr4	0x3006			/* Pointer to sprite 4 */
#define	CB_SprPtr5	0x3007			/* Pointer to sprite 5 */
#define	CB_SprPtr6	0x3008			/* Pointer to sprite 6 */

/* sprite 7 disabled (invisible due to display-setting)

	/****************************************
	*** STARTUP
	****************************************/

	/*** exported functions */

extern ASM BOOL Startup(PREG(d0) ULONG REG(d0));
extern ASM void Shutdown(void);

	/*** exported data */

extern struct Task* PtrTask;

	/*** startup flags */

#define	ASSTRB_FPU	0			/* Program requires FPU */
#define ASSTRF_FPU	(1<<ASSTRB_FPU)


	/****************************************
	*** INPUT
	****************************************/

	/*** exported functions */

extern ASM BOOL InstallInputHandler(void);
extern ASM void RemoveInputHandler(void);

	/****************************************
	*** 
	****************************************/

	/*** exported functions */

extern ASM BOOL OpenLibraries(void);
extern ASM void CloseLibraries(void);

	/*** exported data */

extern char* DOSName;
extern char* GfxName;
extern char* IntuitionName;

extern struct Library* SysBase;
extern struct DosLibrary* DOSBase;
extern struct Library* GfxBase;
extern struct Library* IntuitionBase; 

	/****************************************
	*** SCREEN
	****************************************/

	/*** exported functions */

extern ASM BOOL InstallScreen(void);
extern ASM void RemoveScreen(void);

	/****************************************
	*** VBL
	****************************************/

	/*** exported functions */

extern ASM BOOL SetupVBL(void);
extern ASM void RemoveVBL(void);

extern ASM void WaitVBL(void);

extern ASM BOOL AttachVBLHook(PREG(a0) void* REG(a0), PREG(d0) ULONG REG(d0));
extern ASM void RemoveVBLHook(PREG(a0) void* REG(a0));

extern ASM void InstallCopper(PREG(a0) UWORD* REG(a0));

	/*** exported data */

extern unsigned long VBLTimer;

	/****************************************
	*** FADE
	****************************************/

	/*** structures */

typedef struct
{
	LONG	Iterator;		/* internal counter */
	LONG	FirstColor;		/* first color to fade */
	LONG	LastColor;		/* last color to fade */
	LONG	BPLCON3;		/* BPLCON3 mask for bank-selection */

	WORD	ValueColor[256*3];	/* all color-values (current iteration RGB, 16 bits per gun */
	WORD	DeltaColor[256*3];	/* all delta-colors (RGB, 16 bits per gun)
	ULONG	FadeBuffer[256];	/* internal fade-buffer (for _LoadColors) */
} FadeStructure;

	/*** exported functions */

extern ASM void BeginFade(PREG(a0) FadeStructure* REG(a0), PREG(a1) ULONG* REG(a1), PREG(a2) ULONG* REG(a2), PREG(d0) ULONG REG(d0), PREG(d1) ULONG REG(d1), PREG(d2) ULONG REG(d2), PREG(d3) UWORD REG(d3));
extern ASM BOOL DoFade(PREG(a0) FadeStructure* REG(a0));

extern ASM void LoadColors(PREG(a0) ULONG* REG(a0), PREG(d0) ULONG REG(d0), PREG(d1) ULONG REG(d1), PREG(d2) UWORD REG(d2));

	/*** exported data */

extern ULONG BlackPalette[256];		/* 256 longwords, $000000 */
extern ULONG WhitePalette[256];		/* 256 longwords, $ffffff */
extern ULONG GreyscalePalette[256];	/* 256 longwords, ranging from $000000 to $ffffff */

	/****************************************
	*** MATH
	****************************************/

	/*** exported functions */

extern ASM BOOL SetupMath(void);
extern ASM void RemoveMath(void);

	/*** exported data */

extern LONG	Cos1024[1024];
extern LONG	Sin1024[1024];

	/****************************************
	*** MEM
	****************************************/

	/*** exported functions */

extern ASM BOOL SetupMemory(void);
extern ASM void RemoveMemory(void);

extern ASM void* MemAlloc(PREG(d0) ULONG REG(d0), PREG(d1) ULONG REG(d1));
extern ASM void MemFree(PREG(a0) void* REG(a0));
/*
	these are off-limits for now

extern ASM void MemClear(void);
extern ASM void MemCopy(void);
*/

#define	AAMEMB_CHIP	0			/* allocate chip-memory */
#define AAMEMF_CHIP	(1<<AAMEMB_CHIP)
#define AAMEMB_ALIGN	1			/* align allocation to 64-bit */
#define AAMEMF_ALIGN	(1<<AAMEMB_ALIGN)
#define AAMEMB_MMU	2			/* align allocation for mmu-usage */
#define AAMEMF_MMU	(1<<AAMEMB_MMU)

	/****************************************
	*** FILE
	****************************************/

	/*** exported functions */

extern ASM BOOL FileLoad(PREG(a0) char* REG(a0), PREG(a1) void* REG(a1), PREG(d0) LONG REG(d0));

	/****************************************
	*** SYSTEM
	****************************************/

	/*** exported functions */

extern ASM BOOL CheckSystem(void);

	/****************************************
	*** ERROR
	****************************************/

	/* points to an error-string which will be printed
	by Shutdown() */

extern char* LastError;

#endif
