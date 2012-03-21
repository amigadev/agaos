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

*** copper.s

	; manages copper-lists, to simplify
	; on the higher level

	include	src/agaos.i

	incdir	include:

	include	utility/tagitem.i

	include	hardware/custom.i
	include	hardware/bplbits.i

	include	lvo/exec_lib.i

;****** AgaOS/BuildDisplay ***************************************
*
*   NAME
*	BuildDisplay - Generate a copper-list from tagitems passed in.
*
*   SYNOPSIS
*	endcop = BuildDisplay(tagItems, copperlist)
*	D0			a0	a1
*
*	WORD* BuildDisplay(LONG*, UWORD*);
*
*   FUNCTION
*
*   INPUT
*	tagItems - tag-items describing the new display
*
*	--- Tagitems ---
*
*	CB_Flags	- Global flags
*
*	CB_BplScrollX	- Bitplane horizontal scroll (shires)
*	CB_BplScrollY	- Bitplane vertical scroll (lowres)
*	CB_BplWidth	- Bitplane width (pixels)
*	CB_BplHeight	- Bitplane height (pixels)
*	CB_BplDepth	- Bitplane depth (0-8 (0-256 colors))
*	CB_BplPointer	- Pointer to contiguous bitplanes,
*			  offset (width/8)*height
*	CB_BplIndirect	- Indirect pointer to bitplanes
*	CB_BplFlags	- Bitplane flags
*			CBBF_DUALPF:	Enable dual playfields
*			CBBF_PF2PRIO:	Playfield 2 Prio over Playfield 1
*
*	CB_DispPosX	- Display window horizontal position (shires)
*	CB_DispPosY	- Display window vertical position (lowres)
*	CB_DispWidth	- Display window width (shires) 
*	CB_DispHeight	- Display window height (lowres)
*	CB_DispFlags	- Display flags
*		CBDF_HIRES:	*** Display will be in hires
*		CBDF_SHIRES:	*** Display will be in super-hires
*		CBDF_LACE:	*** Display will be laced
*		CBDF_HAM:	*** Enable HAM6 or HAM8 
*		CBDF_EHB:	*** Enable Extra Half-Brite
*		CBDF_DBLSCAN:	*** Display will be double-scanned
*
*	CB_SpriteFlags	- Sprite flags
*	CB_SprPtr0	- Pointer to sprite 0
*	CB_SprPtr1	- Pointer to sprite 1
*	CB_SprPtr2	- Pointer to sprite 2
*	CB_SprPtr3	- Pointer to sprite 3
*	CB_SprPtr4	- Pointer to sprite 4
*	CB_SprPtr5	- Pointer to sprite 5
*	CB_SprPtr6	- Pointer to sprite 6
*
*	copperlist - Pointer to memory-area that will contain the copper-
*		     list, prefferably in chip-memory if you intend to use it
*
*   RESULTS
*	endcop - Pointer that is just past the final copper-instruction,
*		which happens to be a $ffff,$fffe (wait for End Of Display)
*
*   NOTES
*
*   BUGS
*
*   SEE ALSO
*
**********************************************************************
*

_BuildDisplay

	movem.l	d1-a6,-(sp)

	*** display

	move.w	#fmode,(a1)+
	move.w	#$000f,(a1)+

	jsr	_BuildDisplayWindow
	move.l	d0,a1

	*** bitplanes

	jsr	_BuildBitplaneInfo
	move.l	d0,a1

	*** sprites

	jsr	_BuildSprites
	move.l	d0,a1

	*** terminate list

	move.l	#$fffffffe,(a1)+

	move.l	a1,d0
	movem.l	(sp)+,d1-a6
	rts

_BuildBitplaneInfo
;*****i* AgaOS/BuildBitplaneInfo *********************************
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
* *** INTERNAL ***
*
* Copper-registers written here:
* 
* BPLCON0
* BPLCON2
* (BPLCON3) not anymore
* BPLCON4
* BPLPT0-BPLPT7
*
* IN:	a0 - array of tagitems describing
*	     the display
*	a1 - output copperlist
*
* OUT:	d0 - pointer to end of copperlist
* 

	movem.l	d1-a6,-(sp)

	clr.l	d5				; disp flags
	clr.l	d6				; bpl depth
	clr.l	d7				; bpl flags

	move.l	#CB_DispFlags,d0
	jsr	_GetTagItem
	bne	.have_dispflags
	move.l	#0,d1
.have_dispflags
	move.l	d1,d5

	move.l	#CB_BplFlags,d0
	jsr	_GetTagItem
	bne	.have_bplflags
	move.l	#0,d1
.have_bplflags
	move.l	d1,d7

	move.l	#CB_BplDepth,d0
	jsr	_GetTagItem
	bne	.have_bpldepth
	move.l	#0,d1
.have_bpldepth
	move.l	d1,d6

	*** BPLCON0

	move.w	#bplcon0,(a1)+
	clr.l	d0

	move.l	d6,d1

	lsl.w	#5,d1
	lsr.b	#5,d1
	ror.w	#4,d1
	or.w	d1,d0

	btst	#CBBB_DUALPF,d7
	beq	.no_dualpf
	or.w	#BPLF_DUAL,d0
.no_dualpf

	btst	#CBDB_HAM,d5
	beq	.no_ham
	or.w	#BPLF_HAM,d0
.no_ham

	btst	#CBDB_SHIRES,d5
	beq	.no_shires
	or.w	#BPLF_SHRES,d0
	bra	.no_hires
.no_shires

	btst	#CBDB_HIRES,d5
	beq	.no_hires
	or.w	#BPLF_HIRES,d0
.no_hires

	or.w	#BPLF_COLOR|BPLF_ECSEN,d0
	move.w	d0,(a1)+

	*** BPLCON2

	move.w	#bplcon2,(a1)+
	move.w	#$0200,d0

	btst	#CBBB_PF2PRIO,d7
	beq	.no_pf2prio
	or.w	#$0040,d0
.no_pf2prio

	move.w	d0,(a1)+

	*** BPLCON3

	;move.w	#bplcon3,(a1)+
	;clr.l	d0

	;btst	#CBDB_BLANK,d5
	;beq	.no_borderblank
	;bset	#5,d0
.no_borderblank

	;move.w	d0,(a1)+

	*** BPLCON4

	move.w	#bplcon4,(a1)+
	move.w	#0,(a1)+

	*** BPLPT0-BPLPT7

	move.l	#CB_BplPointer,d0
	jsr	_GetTagItem
	bne	.got_bitplanes

	move.l	#CB_BplIndirect,d0
	jsr	_GetTagItem
	beq	.no_bitplanes

	move.l	(d1.l),d1

.got_bitplanes

	move.l	d1,d2

	; y bitplane scrolling

	move.l	#CB_BplScrollY,d0
	jsr	_GetTagItem
	bne	.got_scrolly_bplscrolly
	move.l	#0,d1
.got_scrolly_bplscrolly

	move.l	d1,d3

	move.l	#CB_BplWidth,d0
	jsr	_GetTagItem
	bne	.got_scrolly_bplwidth
	move.l	#320,d1
.got_scrolly_bplwidth

	lsr.l	#3,d1
	muls.l	d3,d1
	add.l	d1,d2

	; left edge clipping

	move.l	#CB_DispPosX,d0
	jsr	_GetTagItem
	bne	.got_edgeclip_posx
	move.l	#($81*4),d1
.got_edgeclip_posx
	sub.l	#($81*4),d1
	bpl	.edgeclip_ok

	neg.l	d1
	lsr.l	#5,d1
	lsl.l	#1,d1
	;sub.l	#2,d1

	add.l	d1,d2

.edgeclip_ok

	; computer bitplane size

	move.l	#CB_BplHeight,d0
	jsr	_GetTagItem
	beq	.no_bitplanes
	move.l	d1,d3

	move.l	#CB_BplWidth,d0
	jsr	_GetTagItem
	beq	.no_bitplanes
	move.l	d1,d4

	lsr.l	#3,d4
	mulu.l	d4,d3

	; apply clipping

	move.l	#CB_DispPosY,d0
	jsr	_GetTagItem			; try to get y-position
	beq	.no_clip_posy			; not present, should be safe (default $2c)

	tst.l	d1
	bpl	.no_clip_posy

	neg.l	d1
	mulu.l	d4,d1

	add.l	d1,d2

.no_clip_posy

	; get depth

	move.l	#CB_BplDepth,d0
	jsr	_GetTagItem
	beq	.no_bitplanes
	move.l	d1,d4
	beq	.no_bitplanes			; BplDepth == 0

	move.l	#bplpt,d1

	;sub.l	#2,d2

	movem.l	d0-d7/a0/a2-a6,-(sp)
	move.l	a1,a0
	move.l	d2,d0
	move.l	d3,d1
	move.l	d4,d2
	move.l	#bplpt,d3
	jsr	_WriteCopperPtrs
	move.l	d0,a1
	movem.l	(sp)+,d0-d7/a0/a2-a6

.no_bitplanes

	move.l	a1,d0
	movem.l	(sp)+,d1-a6
	rts


_BuildDisplayWindow
;*****i* AgaOS/BuildDisplayWindow ********************************
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
* *** INTERNAL ***
*
* Copper-registers written here:
*
* FMODE
* DIWSTRT
* DIWSTOP
* DIWHIGH
* DDFSTRT
* DDFSTOP
* BPL1MOD
* BPL2MOD
* BPLCON1
* 
* IN:	a0 - array of tagitems describing
*	     the display
*	a1 - output copperlist
*
* OUT:	d0 - pointer to end of copperlist
* 

	movem.l	d1-a6,-(sp)

	clr.l	d4	; disp posx
	clr.l	d5	; disp posy
	clr.l	d6	; disp width
	clr.l	d7	; disp height

	clr.w	.temp_modulo		; add to this for modulo displacement

	*** get data for display-window

	move.l	#CB_DispPosX,d0
	jsr	_GetTagItem
	bne	.have_dispposx
	move.l	#$81*4,d1
.have_dispposx
	move.l	d1,d4

	move.l	#CB_DispPosY,d0
	jsr	_GetTagItem
	bne	.have_dispposy
	move.l	#$2c,d1
.have_dispposy
	move.l	d1,d5

	move.l	#CB_DispWidth,d0
	jsr	_GetTagItem
	bne	.have_dispwidth
	move.l	#320*4,d1
.have_dispwidth
	;sub.l	#4,d1	; CHECK THIS ONE
	move.l	d1,d6

	move.l	#CB_DispHeight,d0
	jsr	_GetTagItem
	bne	.have_dispheight
	move.l	#256,d1
.have_dispheight
	move.l	d1,d7

	add.l	d4,d6			; convert width to horizontal stop
	add.l	d5,d7			; convert height to vertical stop

	cmp.l	#(($81*4)),d4
	bge	.valid_disp_start
	move.l	#(($81*4)),d4
.valid_disp_start

	cmp.l	#(($81*4)+320*4),d6
	ble	.valid_disp_stop
	move.l	#(($81*4)+320*4),d6
.valid_disp_stop

	tst.l	d5
	bpl	.no_clip_posy
	clr.l	d5
.no_clip_posy

	*** DIWSTRT

	move.w	#diwstrt,(a1)+
	move.l	d4,d0
	add.l	#4,d0
	lsr.l	#2,d0
	move.l	d5,d1
	lsl.w	#8,d1
	move.b	d0,d1
	move.w	d1,(a1)+
	;move.w	#$2c81,(a1)+

	*** DIWSTOP

	move.w	#diwstop,(a1)+
	move.l	d6,d0
	add.l	#4,d0
	lsr.l	#2,d0
	move.l	d7,d1
	lsl.w	#8,d1
	move.b	d0,d1
	;move.w	#$2cc0,(a1)+
	move.w	d1,(a1)+

	*** DIWHIGH

	move.w	#diwhigh,(a1)+
	clr.l	d0

					;FEDC BA98 7654 3210

	; stop

	move.w	d6,d1			;xxxx xAxx xxxx xx10
	and.w	#$0403,d1		;---- -A-- ---- --10
	lsl.b	#6,d1			;---- -A-- 10-- ----
	lsr.w	#2,d1			;---- ---A --10 ----
	lsl.b	#2,d1			;---- ---A 10-- ----
	lsr.w	#3,d1			;---- ---- --A1 0---

	move.w	d7,d2			;xxxx xA98 xxxx xxxx
	and.w	#$0700,d2		;---- -A98 ---- ----
	lsr.w	#8,d2			;---- ---- ---- -A98
	move.b	d1,d0
	or.b	d2,d0

	lsl.w	#8,d0

	; start

	move.w	d4,d1			;xxxx xAxx xxxx xx10
	and.w	#$0403,d1		;---- -A-- ---- --10
	lsl.b	#6,d1			;---- -A-- 10-- ----
	lsr.w	#2,d1			;---- ---A --10 ----
	lsl.b	#2,d1			;---- ---A 10-- ----
	lsr.w	#3,d1			;---- ---- --A1 0---

	move.w	d5,d2			;xxxx xA98 xxxx xxxx
	and.w	#$0700,d2		;---- -A98 ---- ----
	lsr.w	#8,d2			;---- ---- ---- -A98
	move.b	d1,d0
	or.b	d2,d0

		;  (stop)  |  (start)
		; xxHHHVVV | xxHHHVVV
		;   A10A98 |   A10A98

	move.w	d0,(a1)+

	*** DDFSTRT

	move.w	#ddfstrt,(a1)+

	move.l	d4,d0
	lsr.l	#3,d0
	sub.l	#8,d0
	;sub.l	#8*4,d0

	add.w	#-8,.temp_modulo

	;move.w	d0,(a1)+
	move.w	#$0038,(a1)+

	*** DDFSTOP

	move.w	#ddfstop,(a1)+
	move.w	#($00d0-$0038),d1
	;add.w	#40*8,d0
	add.w	d1,d0

	cmp.w	#$00d0,d0
	blt	.ok_val
	sub.w	#$00d0,d0
	lsr.w	#2,d0
	add.w	d0,.temp_modulo
	move.w	#$00d0,d0
.ok_val

	;move.w	d0,(a1)+
	move.w	#$00d0,(a1)+

	*** BPLCON1

	move.w	#bplcon1,(a1)+
	clr.l	d0

	move.l	#CB_DispPosX,d0
	jsr	_GetTagItem
	bne	.got_bplcon1_dispposx
	move.l	#$81*4,d1
.got_bplcon1_dispposx

	and.w	#$3f,d1				; xxxx xxxx xx54 3210
	lsl.w	#6,d1				; xxxx 5432 10xx xxxx
	lsr.b	#6,d1				; xxxx 5432 xxxx xx10
	ror.w	#8,d1				; xxxx xx10 xxxx 5432

	move.w	d1,d0
	lsl.w	#4,d0
	or.w	d0,d1

	move.w	#0,(a1)+

	*** BPL1MOD / BPL2MOD

	move.l	#CB_BplWidth,d0
	jsr	_GetTagItem
	bne	.got_modulo_bpl_width
	move.l	#320,d1
.got_modulo_bpl_width
	move.l	d1,d2

	move.l	#CB_DispWidth,d0
	jsr	_GetTagItem
	bne	.got_modulo_disp_width
	move.l	#320*4,d1
.got_modulo_disp_width
	move.l	d1,d3

	lsr.l	#2,d3

	sub.l	d3,d2
	lsr.l	#3,d2

	add.w	.temp_modulo,d2

	;move.l	#((2048-320)/8)-2,d2

	move.w	#bpl1mod,(a1)+
	move.w	d2,(a1)+
	move.w	#bpl2mod,(a1)+
	move.w	d2,(a1)+

	move.l	a1,d0
	movem.l	(sp)+,d1-a6
	rts

.temp_modulo	ds.w	1

_BuildSprites
;*****i* AgaOS/BuildSprites ******************************************
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
* *** INTERNAL ***
*
* IN:	a0 - array of tagitems describing
*	     the display
*	a1 - output copperlist
*
* OUT:	d0 - pointer to end of copperlist
*

	movem.l	d1-a6,-(sp)

	move.l	a1,a0
	move.l	_DummySprite,d0
	move.l	#0,d1
	move.l	#8,d2
	move.l	#sprpt,d3
	jsr	_WriteCopperPtrs

	movem.l	(sp)+,d1-a6
	rts

_GetTagItem
;*****i* AgaOS/GetTagItem ********************************************
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
*	This function would not be accessible from C, due to the double
*	return-type
*   BUGS
*
*   SEE ALSO
*
**********************************************************************
*
* *** INTERNAL ***
*
* IN:	a0 - array of tagitems
*	d0 - requested tag-item
*
* OUT:	d0 - TRUE if tag found
*	d1 - tag-data
*

	movem.l	d2-a6,-(sp)

	move.l	d0,d5

	clr.l	d6
	clr.l	d7

.tagitem_loop
	move.l	(a0)+,d0
	cmp.l	#TAG_DONE,d0
	beq	.tagitem_finished

	st.l	d6
	move.l	(a0)+,d7

	cmp.l	d5,d0
	beq	.tagitem_finished

	clr.l	d6
	bra	.tagitem_loop

.tagitem_finished

	move.l	d6,d0
	move.l	d7,d1

	movem.l	(sp)+,d2-a6
	tst.l	d0
	rts

	section	bss,bss

_DummySprite	ds.l	1
