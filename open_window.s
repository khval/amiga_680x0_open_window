
	include "lvo/exec_lib.i"
	include "lvo/dos_lib.i"
	include "lvo/intuition_lib.i"
	include "lvo/graphics_lib.i"

	include "HARDWARE/CUSTOM.I"
	include "GRAPHICS/GFX.I"
	include "INTUITION/INTUITION.I"

	include "help.i"

NULL		EQU 0
FALSE	EQU 0
TRUE	EQU 1

__use_real_chipset__ set 1

	SECTION main,CODE

DELAY	macro
	move.l #\1,d1
	jsr delay
	endm

writeText	macro
		lea 1\(pc),a1
		jsr _writeText
		endm

main:
	OPENLIB	dos
	OPENLIB	intuition
	OPENLIB	graphics

	IFND	__use_real_chipset__
	OPENLIB	chipset
	ENDC

	INFOTXT LibsOpen

	jsr	openWin

	move #rp_SIZEOF,D1
	INFOVALUE D1

	INFOTXT	allocBitmap	
	jsr	allocBitmap		; create bitmap

	INFOTXT	initTmpRastPort
	jsr	initTmpRastPort	; init rastport with bitmap, and setup JAM1, and PEN colors.

	INFOTXT	clearBitmap
	jsr	clearBitmap		; Try to dump some stuff into bitmap, not so system frendly way.

	INFOTXT	drawSomeGfx	; try to draw something into tmp RastPort
	jsr	drawSomeGfx

	INFOTXT	blitBitmapIntoWindow	; Copy the tmp rastport into the window.
	jsr	blitBitmapIntoWindow

	INFOTXT	freeBitmap
	jsr	freeBitmap

	DELAY 60

	jsr	closeWin

closeLibs:
	IFND	__use_real_chipset__
	CLOSELIB	chipset
	ENDC

	CLOSELIB	graphics
	CLOSELIB	intuition
	CLOSELIB	dos
	rts

closeLib
	move.l a1,d0
	tst.l d0
	beq.s	.notOpen
	move.l 4,a6
	jsr	_LVOCloseLibrary(a6)
	moveq #0,d0
.notOpen
	rts

delay
	move.l dosBase(pc),a6
	jsr _LVODelay(a6)
	rts

_writeText:
	move.l (a1),d2
	add.l #4,a1
	move.l a1,d1
	move.l	dosBase(pc),A6
	jsr		_LVOWriteChars(a6)
	rts

clearBitmap
	move.l	windowBitmap,a0
	clr.l		d2
	move.w	bm_BytesPerRow(a0),d2
	move.l	bm_Planes(a0),a1
	move.l	a1,a2
	move.l	#50,d1
.row
	move.l	#80,d0
	move.l	a2,a1
	add.l		d2,a2
.col
	move.b	#$AA,(a1)
	add.l		#1,a1
	sub.w	#1,d0
	tst.w		d0
	bne	.col
	sub.w	#1,d1
	tst.w		d1
	bne	.row
	rts

drawSomeGfx
	move.l	graphicsBase,a6

;	move.l	window,A1
;	move.l	wd_RPort(a1),a1	; get RastPort

	lea.l	tmpRastPort,a1
	move.l	#0,d0
	move.l	#0,d1
	jsr		_LVOMove(a6)

;	move.l	window,A1
;	move.l	wd_RPort(a1),a1	; get RastPort

	lea.l	tmpRastPort,a1
	move.l	#100,d0
	move.l	#100,d1
	jsr		_LVODraw(a6)

	rts

openWin
	move.l	intuitionBase,a6
	move.l	#0,A0
	move.l	#windowTags,A1
	jsr		_LVOOpenWindowTagList(a6)
	move.l	d0,window
	rts

closeWin
	move.l	intuitionBase,a6
	move.l	window,A0
	jsr		_LVOCloseWindow(a6)
	rts

allocBitmap
	move.l	#640,D0	; Width
	move.l	#256,D1	; height
	move.l	#8,D2	; bits
	move.l	#BMF_CLEAR+BMF_DISPLAYABLE,D3
	move.l	#0,a0
	move.l	graphicsBase,a6
	jsr		_LVOAllocBitMap(A6)
	move.l	d0,windowBitmap
	rts

initTmpRastPort
	move.l	graphicsBase,a6
	lea.l		tmpRastPort,a1
	jsr		_LVOInitRastPort(a6)

	move.l	windowBitmap,d0
	move.l	d0,rp_BitMap(a1)

	lea.l		tmpRastPort,a1
	move.l	#RP_JAM1,D0
	jsr		_LVOSetDrMd(a6)

	lea.l		tmpRastPort,a1
	move.l	#1,D0
	jsr		_LVOSetAPen(a6)

	lea.l		tmpRastPort,a1
	move.l	#1,D0
	jsr		_LVOSetBPen(a6)

	rts

freeBitmap
	move.l	graphicsBase,a6
	jsr		_LVOWaitBlit(A6)

	move.l	windowBitmap,A0
	jsr		_LVOFreeBitMap(A6)
	rts

blitBitmapIntoWindow
	move.l	windowBitmap,A0
	move.l	#0,D0	; src X,y
	move.l	#0,D1
	move.l	window,a1
	move.l	wd_RPort(a1),a1	; get RastPort
	move.l	#0,D2	; des x,y
	move.l	#0,D3
	move.l	#640,D4	; width,height
	move.l	#256,D5
	move.l	#0,D6	; minterm
	move.l	graphicsBase,a6
	jsr		_LVOBltBitMapRastPort(A6)
	rts


windowTags	dc.l	WA_PubScreen,NULL
			dc.l	WA_Left,100
			dc.l	WA_Top,0
			dc.l	WA_Width,320
			dc.l	WA_Height,200
			dc.l	WA_DragBar,FALSE
			dc.l	WA_DepthGadget,FALSE
			dc.l	WA_SizeGadget,FALSE
			dc.l	WA_Gadgets, NULL
			dc.l	WA_IDCMP, NULL
			dc.l	WA_Title,windowName
			dc.l	TAG_DONE, NULL

windowBitmap
	dc.l	0

screenBitmap
	dc.l	0

window
	dc.l	0

windowName
	dc.b	0,0

dosBase:
	dc.l	0

chipsetBase
	dc.l	0

graphicsBase
	dc.l	0

intuitionBase
	dc.l	0

printf_args:
	ds.l	20

txtLibsOpen:
	dc.b "Libs are open",$A,0

dosName:
	dc.b	"dos.library",0

chipsetName:
	dc.b	"chipset.library",0

graphicsName:
	dc.b	"graphics.library",0

intuitionName:
	dc.b	"intuition.library",0

PRINT_TXT_FMT
		dc.b	"%s",10,0

PRINT_VALUE_FMT
		dc.b	"VALUE: %ld",10,0

PRINT_HEX_FMT
		dc.b	"HEX: %lx",10,0

txtallocBitmap
		dc.b	"AllocBitmap",0

txtinitTmpRastPort
		dc.b	"initTmpRastport",0

txtclearBitmap
		dc.b	"ClearBitmap",0

txtblitBitmapIntoWindow
		dc.b	"BlitBitmapIntoWindow",0

txtfreeBitmap
		dc.b	"FreeBitmap",0

txtdrawSomeGfx
		dc.b "drawSomeGfx",0

tmpRastPort
	dcb.b rp_SIZEOF,0

