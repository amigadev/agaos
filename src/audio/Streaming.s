
	machine	68020

	*** includes

	include	src/agaos.i

	incdir	include:

	include	exec/types.i

	include	hardware/custom.i
	include	hardware/dmabits.i
	include	hardware/intbits.i

	include	graphics/gfxbase.i

	include	devices/audio.i

	include	lvo/exec_lib.i
	include	lvo/dos_lib.i

	*** TODO

	* Break this file up into smaller pieces to follow the
	* general design of AgaOS

	*** status for streaming

SB_EMPTY	EQU	0		; stream-buffer is empty
SB_LOCKED	EQU	1		; stream-buffer is locked
SB_PENDING	EQU	2		; stream-buffer is pending playback
SB_SETUP	EQU	3		; stream-buffer is setup to be played
SB_PLAYING	EQU	4		; stream-buffer is currently playin

NUM_BUFFERS	EQU	4		; number of stream-buffers to use

	*** functions

	section	code,code

_InstallAudioStream
*************************************************
*						*
* Install streaming interfaces.			*
*						*
* IN:	d0 - Hz to play buffer in		*
*	d1 - Volume for channel 0		*
*	d2 - Volume for channel 1 		*
*	d3 - Volume for channel 2		*
*	d4 - Volume for channel 3		*
*						*
* Volume is in amiga-specific style. Refer to	*
* the hardware manual.				*
*						*
* OUT:	d0 - success				*
*						*
*************************************************

	movem.l	d0-a6,-(sp)

	; store input

	lea.l	_StreamVolume,a0
	move.l	d0,_StreamHz
	move.w	d1,(a0)+
	move.w	d2,(a0)+
	move.w	d3,(a0)+
	move.w	d4,(a0)+

	*** Create MsgPort

	move.l	_SysBase,a6
	jsr	_LVOCreateMsgPort(a6)
	move.l	d0,_AudioPort
	beq	.Fail

	*** Create IOAudio

	move.l	_SysBase,a6
	move.l	_AudioPort,a0
	move.l	#ioa_SIZEOF,d0
	jsr	_LVOCreateIORequest(a6)
	move.l	d0,_AudioIO
	beq	.Fail

	*** Open audio.device (and allocate channels)

	move.l	_SysBase,a6
	lea.l	_AudioName,a0
	move.l	#0,d0
	move.l	_AudioIO,a1
	move.l	#1,ioa_Length(a1)
	move.l	#.channel_map,ioa_Data(a1)
	move.l	#0,d1
	jsr	_LVOOpenDevice(a6)
	tst.l	d0
	bne	.Fail

	st.l	_AudioOpen

	*** Setup interrupts

	lea.l	$dff000,a5
	move.w	#DMAF_AUDIO,dmacon(a5)	; make sure it's all stopped

	; setup streaming interrupt

	move.l	_SysBase,a6
	lea.l	_AudioInterruptStruct,a1
	move.l	#INTB_AUD0,d0
	jsr	_LVOSetIntVector(a6)
	move.l	d0,_AudioVector

	nop
	move.w	#INTF_AUD0|INTF_AUD1|INTF_AUD2|INTF_AUD3,intena(a5)
	nop
	move.w	#INTF_AUD0|INTF_AUD1|INTF_AUD2|INTF_AUD3,intreq(a5)
	nop
	move.w	#INTF_SETCLR|INTF_AUD0,intena(a5)
	nop

	*** setup stream-buffers ***

	lea.l	_StreamBuffers,a4
	move.l	_StreamHz,d6		; d6 - bytes per channel
	move.l	d6,d5
	lsl.l	#2,d5			; d5 - total number of bytes
	move.l	#NUM_BUFFERS-1,d7
.streambuffer_alloc

	; allocate buffers

	move.l	d5,d0
	move.l	#AAMEMF_CHIP|AAMEMF_ALIGN,d1
	jsr	_MemAlloc
	tst.l	d0
	beq	.Fail

	; store buffers

	move.l	d0,a0

	move.l	#SB_EMPTY,SB_Status(a4)		; buffer is empty
	move.l	d6,SB_BufferSize(a4)		; buffer size set

	move.l	a0,SB_Channel0(a4)
	lea.l	(a0,d6),a0
	move.l	a0,SB_Channel1(a4)
	lea.l	(a0,d6),a0
	move.l	a0,SB_Channel2(a4)
	lea.l	(a0,d6),a0
	move.l	a0,SB_Channel3(a4)

	lea.l	SB_SIZEOF(a4),a4

	dbra	d7,.streambuffer_alloc

	*** setup stream period and volumes ***

	; compute period

	move.l	#3579545,d1
	move.l	d1,d0
	divu.l	_StreamHz,d0

	; store in hardware

	move.w	d0,aud0+ac_per(a5)
	move.w	d0,aud1+ac_per(a5)
	move.w	d0,aud2+ac_per(a5)
	move.w	d0,aud3+ac_per(a5)

	; store volume in hardware

	lea.l	_StreamVolume,a0
	move.w	(a0)+,aud0+ac_vol(a5)
	move.w	(a0)+,aud1+ac_vol(a5)
	move.w	(a0)+,aud2+ac_vol(a5)
	move.w	(a0)+,aud3+ac_vol(a5)

	; store length

	move.l	_StreamHz,d0
	lsr.l	#1,d0
	move.w	d0,aud0+ac_len(a5)
	move.w	d0,aud1+ac_len(a5)
	move.w	d0,aud2+ac_len(a5)
	move.w	d0,aud3+ac_len(a5)

	movem.l	(sp)+,d0-a6
	st.l	d0
	rts
.Fail
	movem.l	(sp)+,d0-a6
	clr.l	d0
	rts

.channel_map	dc.b	$f	; %1111 - allocate all channels

	cnop	0,4

_RemoveAudioStream
*************************************************
*						*
* Remove streaming interfaces.			*
*						*
*************************************************

	movem.l	d0-a6,-(sp)

	*** Close audio.device (and restore interrupts)

	tst.l	_AudioOpen
	beq	.no_device

	move.l	_SysBase,a6

	; restore interrupt

	move.l	_AudioVector,a1
	move.l	#INTB_AUD0,d0
	jsr	_LVOSetIntVector(a6)

	; close device

	move.l	_AudioIO,a1
	jsr	_LVOCloseDevice(a6)
	clr.l	_AudioOpen

.no_device

	*** free buffers

	lea.l	_StreamBuffers,a4
	move.l	#NUM_BUFFERS-1,d7
.streambuffers_free

	; free all buffers if allocated

	move.l	SB_Channel0(a4),a0
	tst.l	a0
	beq	.no_channel0
	jsr	_MemFree
.no_channel0

	lea.l	SB_SIZEOF(a4),a4

	dbra	d7,.streambuffers_free

	*** Delete IOAudio

	tst.l	_AudioIO
	beq	.no_request

	move.l	_SysBase,a6
	move.l	_AudioIO,a0
	jsr	_LVODeleteIORequest(a6)
	clr.l	_AudioIO

.no_request

	*** Delete MsgPort

	tst.l	_AudioPort
	beq	.no_msgport

	move.l	_SysBase,a6
	move.l	_AudioPort,a0
	jsr	_LVODeleteMsgPort(a6)
	clr.l	_AudioPort

.no_msgport

	movem.l	(sp)+,d0-a6
	rts

_StartAudioStream
*************************************************
*						*
* Start streaming of audio-data.		*
*						*
* This requires that atleast ONE (1) buffer has	*
* been filled with data, or this function will	*
* silently fail.				*
*						*
*************************************************

	movem.l	d0-a6,-(sp)

	*** Start playing of stream

	; check if first buffer is available

	lea.l	_StreamBuffers,a4
	cmp.l	#SB_PENDING,SB_Status(a4)
	bne	.Fail	

	; ok, setup buffer-pointers

	lea.l	$dff000,a5

	move.l	#SB_SETUP,SB_Status(a4)

	move.l	SB_Channel0(a4),aud0+ac_ptr(a5)
	move.l	SB_Channel1(a4),aud1+ac_ptr(a5)
	move.l	SB_Channel2(a4),aud2+ac_ptr(a5)
	move.l	SB_Channel3(a4),aud3+ac_ptr(a5)

	move.l	a4,_CurrentSetup

	move.l	#1,_BufferPlaying

	; press play on tape!

	move.w	#DMAF_SETCLR|DMAF_AUDIO,dmacon(a5)

.Fail

	movem.l	(sp)+,d0-a6
	rts

_StopAudioStream
*************************************************
*						*
* Stop streaming of audio-data.			*
*						*
* This call will stop all audio-DMA, and kill	*
* the status on all remaining audio-buffers, so	*
* it is not possible to just resume where it	*
* left off.					*
*						*
*************************************************

	movem.l	d0-a6,-(sp)

	*** Stop playing of stream

	lea.l	$dff000,a5

	; stop stream

	move.w	#INTF_AUD0,intena(a5)
	move.w	#INTF_AUD0,intena(a5)
	move.w	#INTF_AUD0,intena(a5)

	move.w	#INTF_AUD0,intreq(a5)

	lea.l	$dff000,a5
	move.w	#DMAF_AUDIO,dmacon(a5)

	; reset buffer-flags

	lea.l	_StreamBuffers,a4
	move.l	#NUM_BUFFERS-1,d7
.kill_buffers

	move.l	#SB_EMPTY,SB_Status(a4)

	lea.l	SB_SIZEOF(a4),a4

	dbra	d7,.kill_buffers

	; make sure we don't overwrite any data

	clr.l	_CurrentSetup
	clr.l	_CurrentPlaying

	movem.l	(sp)+,d0-a6
	rts

_LockStreamBuffer
*************************************************
*						*
* Get an exclusive lock on the next stream	*
* buffer. This will mark the buffer as locked.	*
*						*
* OUT:	d0 - ptr to streambuffer-structure.	*
*						*
* If NULL is returned, all buffers are already	*
* in pending mode.				*
*						*
*************************************************

	movem.l	d1-a6,-(sp)

	; reset output

	clr.l	d7

	; compute address of currently buffer needed filling

	lea.l	_StreamBuffers,a0
	move.l	_BufferEmpty,d0
	mulu.l	#SB_SIZEOF,d0
	lea.l	(a0,d0),a0

	; check if the current buffer is available

	;TODO: we should make this thread-safe. How about
	; first xoring a value to the status-value, then
	; read and xor again to check if it's really
	; empty?

	cmp.l	#SB_EMPTY,SB_Status(a0)
	bne.s	.not_empty

	; set output to current buffer, and lock

	move.l	a0,d7
	move.l	#SB_LOCKED,SB_Status(a0)

.not_empty

	move.l	d7,d0
	movem.l	(sp)+,d1-a6
	rts

_UnlockStreamBuffer
*************************************************
*						*
* Release exclusive lock on buffer. This will	*
* mark the buffer as pending.			*
*						*
*************************************************

	movem.l	d0-a6,-(sp)

	; make sure it's locked (the buffer might have been killed while
	; locked)

	lea.l	_StreamBuffers,a0
	move.l	_BufferEmpty,d0
	mulu.l	#SB_SIZEOF,d0
	lea.l	(a0,d0),a0

	cmp.l	#SB_LOCKED,SB_Status(a0)
	bne.s	.not_locked

	; set buffer to pending

	move.l	#SB_PENDING,SB_Status(a0)

	; update buffer-empty rotation value

	move.l	_BufferEmpty,d0
	addq.l	#1,d0
	and.l	#NUM_BUFFERS-1,d0
	move.l	d0,_BufferEmpty

.not_locked

	movem.l	(sp)+,d0-a6
	rts

_AudioInterrupt
*************************************************
*						*
* This routine is called every time a stream	*
* needs to update its buffers. It checks if a	*
* new buffer is ready for playing, and if so,	*
* updates the audio-pointers to point towards	*
* that buffer.					*
*						*
*************************************************

	movem.l	d0-a6,-(sp)

	lea.l	$dff000,a5
	lea.l	_StreamBuffers,a4

	; disable interrupts

	move.w	#INTF_INTEN,intena(a5)

	; check if next buffer is available for replaying

	move.l	_BufferPlaying,d0
	mulu.l	#SB_SIZEOF,d0
	lea.l	(a4,d0),a3
	cmp.l	#SB_PENDING,SB_Status(a3)
	bne	.skip_update

	; set playing buffer as empty

	move.l	_CurrentPlaying,a2
	tst.l	a2
	beq	.no_playing_buffer
	move.l	#SB_EMPTY,SB_Status(a2)
.no_playing_buffer

	; set setup buffer as playing

	move.l	_CurrentSetup,a2
	tst.l	a2
	beq	.no_current_buffer
	move.l	#SB_PLAYING,SB_Status(a2)
	move.l	a2,_CurrentPlaying
.no_current_buffer

	; update location registers

	move.l	SB_Channel0(a3),aud0+ac_ptr(a5)
	move.l	SB_Channel1(a3),aud1+ac_ptr(a5)
	move.l	SB_Channel2(a3),aud2+ac_ptr(a5)
	move.l	SB_Channel3(a3),aud3+ac_ptr(a5)

	; set new buffer as setup

	move.l	#SB_SETUP,SB_Status(a3)
	move.l	a3,_CurrentSetup

	; update counter to next buffer

	move.l	_BufferPlaying,d0
	addq.l	#1,d0
	and.l	#NUM_BUFFERS-1,d0
	move.l	d0,_BufferPlaying

.skip_update

	; temp, count buffer-updates

	add.l	#1,_BufferUpdates

	; restore interrupts

	nop
	move.w	#INTF_SETCLR|INTF_INTEN,intena(a5)
	nop

	; clear interrupt request

	nop
	move.w	#INTF_AUD0,intreq(a5)
	move.w	#INTF_AUD0,intreq(a5)
	move.w	#INTF_AUD0,intreq(a5)
	nop

	movem.l	(sp)+,d0-a6
	rts

	section	data,data

_AudioInterruptStruct
	dc.l	0,0
	dc.b	NT_INTERRUPT
	dc.b	0
	dc.l	_AudioInterruptName
	dc.l	0
	dc.l	_AudioInterrupt

_AudioName		dc.b	"audio.device",0
_AudioInterruptName	dc.b	"AgaOS AudioStream Interrupt",0

	section	bss,bss

_AudioPort	ds.l	1
_AudioIO	ds.l	1
_AudioOpen	ds.l	1
_AudioVector	ds.l	1+3
_StreamBuffers	ds.b	SB_SIZEOF*4

_BufferUpdates	ds.l	1	; temp counter, to see if it really works

_BufferEmpty	ds.l	1			; buffer-cycle for empty
_BufferPlaying	ds.l	1			; buffer-cycle for playing
_CurrentSetup	ds.l	1			; direct pointer to buffer currently setup
_CurrentPlaying	ds.l	1			; direct pointer to buffer currently playing

_StreamBuffer	ds.b	SB_SIZEOF*NUM_BUFFERS

_StreamHz	ds.l	1
_StreamVolume	ds.w	4
