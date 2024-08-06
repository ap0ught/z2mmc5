.include "build.inc"
.include "mmc5regs.inc"

.feature c_comments
.feature org_per_seg

BANK_SIZE = $2000
NUM_PRG_BANKS = $10

PpuControl_2000 := $2000
PpuMask_2001 := $2001
PpuStatus_2002 := $2002
OamAddr_2003 := $2003
PpuScroll_2005 := $2005
PpuAddr_2006 := $2006
SpriteDma_4014 := $4014

.define SRC_OFFS(bank, offs) ((BANK_SIZE * (bank)) + (offs) + $10)
.define SRC_BOFFS(bank) SRC_OFFS (bank), 0

.macro patch_segment name, size, start_addr, end_addr
	.segment .string(name)

	.import .ident(.sprintf("__%s_SIZE__", .string(name)))
	.assert .ident(.sprintf("__%s_SIZE__", .string(name))) <= (size), lderror, .sprintf("Segment '%s' exceeds size limit of $%x bytes", .string(name), (size))

	.ifnblank start_addr
	.import .ident(.sprintf("__%s_LOAD__", .string(name)))
	.assert .ident(.sprintf("__%s_LOAD__", .string(name))) = (start_addr), lderror, .sprintf("Segment '%s' was not loaded at the correct address %x", .string(name), (start_addr))
	.endif

	.ifnblank end_addr
	.assert (size) = (end_addr) + 1 - (start_addr), error, .sprintf("$%x + 1 - $%x != $%x", (end_addr), (start_addr), (size))
	.endif
.endmacro

.macro patch_set_mirror seg_name, mode
	patch_segment seg_name, 5
		lda #mode
		sta NameTableModeReg
.endmacro
	
.macro patch_call seg_name, target
	patch_segment seg_name, 3
		jsr target
.endmacro

Z2Main := $c000
NmiHdlr = $c07b

Saved16kBank := $769

PpuCtrlForIrq := $6c7
ScrollPosForIrq := $6c8

.segment "VARS"
	; These are at the same location as in Z2R
	.org $7b2
CurBank8: .byte 0
CurBankA: .byte 0

.segment "HIVARS"

.segment "HDR"
.incbin SRC_ROM, 0, $10

.repeat NUM_PRG_BANKS, bank_idx
	.segment .sprintf("BANK%X", bank_idx)
	.incbin SRC_ROM, SRC_BOFFS bank_idx, BANK_SIZE

	.segment .sprintf("CHRBANK%X", bank_idx)
	.incbin SRC_ROM, SRC_BOFFS bank_idx + NUM_PRG_BANKS, BANK_SIZE
.endrepeat

patch_segment PATCH_HDR, 3
	.byte $10 ; Num 16 KB PRG-ROM banks
	.byte $10 ; Num 8 KB CHR-ROM banks
	.byte $52 ; Mapper 5, battery-backed PRG-RAM
	
patch_segment PATCH_HDR_20_PRG_RAM_SIZE, 1
	.byte 7
	
.segment "BANK1F"
	.res $1fa8, 0

.proc ResetHdlrPart2
	cld
	
	lda #PRG_BANK_MODE_8KB_BANKS
	sta PrgBankModeReg
	
	ldx #$0
	stx PpuControl_2000
	inx
	
:
	lda PpuStatus_2002
	bpl :-
	
	dex
	beq :-
	
	txs
	
	inx
	stx PrgRamBankReg
	
	stx LineIrqStatusReg
	lda LineIrqStatusReg
	
	lda #CHR_BANK_MODE_8KB_BANKS
	sta ChrBankModeReg
	
	lda #HORIZ_MIRROR_MODE
	sta NameTableModeReg
	
	ldx #((NUM_PRG_BANKS - 2) | PRG_BANK_ROM)
	stx PrgBankCReg
	
	; Unprotect RAM last
	ldx #PRG_RAM_UNPROTECT1_VALUE
	stx PrgRamProtReg1
	dex
	stx PrgRamProtReg2
	
	jmp ResetHdlrPart3
.endproc ; ResetHdlr

patch_segment PATCH_RESET_HDLR_1F, $1d, $ffe3, $ffff
.proc ResetHdlrPart3
	; $c bytes
	lda #((NUM_PRG_BANKS - 1) | PRG_BANK_ROM)
	sta PrgBankEReg
	
	lda #$f
	
	.res 6, 0 ; BRKs as this should never be executed
.endproc ; ResetHdlrPart3

.proc ResetHdlr
	; $a bytes
	sei
	cld
	lda #$ff
	sta PrgBankEReg
	
	jmp ResetHdlrPart2
.endproc

	.assert * = $fffa, lderror

	.word NmiHdlr, ResetHdlr, ResetHdlr
	
patch_segment PATCH_RESET_HDLR_F, $90, $ff70, $ffff
	.res $41

	; ffb1
	.assert * = $ffb1, lderror
	
.proc SwitchChrBank
	; 9 bytes
	lsr a
	sta BgChrBank3Reg
	sta SpChrBank7Reg
	
	bpl SwitchChrBankCont
.endproc

	.res $b

	; ffc5
	.assert * = $ffc5, lderror
	
SwitchTo16kBank0:
	lda #$0
	beq Switch16kBank
	
	; ffc9
Restore16kBank:
	lda Saved16kBank
	
	; ffcc
Switch16kBank:
	; $11 bytes
	asl a
	ora #PRG_BANK_ROM
	sta CurBank8
	sta PrgBank8Reg
	
	ora #$1
	sta CurBankA
	sta PrgBankAReg
	
SwitchChrBankCont:
SetMirroringCont:
	; 4 bytes
	lda #$0
	clc
	
	rts

	.res 2
	
.proc ResetHdlrPart3F
	; $d bytes
	lda #((NUM_PRG_BANKS - 1) | PRG_BANK_ROM)
	sta PrgBankEReg
	
	lda #$f
	jsr SwitchChrBank
	
	jmp Z2Main
.endproc ; ResetHdlrPart3F

	.assert ResetHdlrPart3 = ResetHdlrPart3F, lderror
	
	; fff0
	.assert * = $fff0, lderror
	
	; Must EXACTLY match start of ResetHdlr
.proc ResetHdlrF
	; $a bytes
	sei
	cld
	lda #$ff
	sta PrgBankEReg
	
	jmp ResetHdlrPart2
.endproc

	.assert ResetHdlr = ResetHdlrF, lderror
	
	.assert * = $fffa, lderror

	.word NmiHdlr, ResetHdlr, IrqHdlr

patch_set_mirror PATCH_CALL_SET_VMIRROR, VERT_MIRROR_MODE
patch_set_mirror PATCH_CALL_SET_HMIRROR1, HORIZ_MIRROR_MODE
patch_set_mirror PATCH_CALL_SET_HMIRROR2, HORIZ_MIRROR_MODE
patch_call PATCH_CALL_SWITCH_CHR_BANK1, SwitchChrBank
patch_call PATCH_CALL_SWITCH_CHR_BANK2, SwitchChrBank
patch_call PATCH_CALL_SWITCH_CHR_BANK3, SwitchChrBank

patch_segment PATCH_WAIT_FOR_SPRITE_0, $1c, $d4b2, $d4cd
	; Can clobber all registers
	lda $ff
	ora $746 ; Have concerns about this
	;sta $ff
	sta PpuCtrlForIrq
	lda $fd
	sta ScrollPosForIrq
	
	lda $200
	clc
	adc #$11
	sta LineIrqTgtReg
	
	lda #ENABLE_SCANLINE_IRQ
	sta LineIrqStatusReg
	
	cli
	
patch_segment BANK_E_FREE_SPACE, $30, $d39a, $d3c9
	.res $30

patch_segment BANK_F_FREE_SPACE_2, $24, $ff4c, $ff6f
.proc IrqHdlr
	; $22 bytes
	pha
	txa
	pha
	
	lda LineIrqStatusReg
	
	ldx PpuCtrlForIrq
	lda ScrollPosForIrq
	sta PpuScroll_2005
	lda #$0
	sta PpuScroll_2005
	stx PpuControl_2000
	
	stx $ff ; Not sure about this
	
	pla
	tax
	pla
	
	rti
.endproc ; IrqHdlr

patch_segment BANK_C_FREE_SPACE_1, $874, $878c, $8fff

patch_segment BANK_C_FREE_SPACE_2, $258, $9da8, $9fff

patch_segment BANK_D_FREE_SPACE, $13f7, $ac09, $bfff
