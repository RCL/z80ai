	DEVICE ZXSPECTRUM128

AI_ENTRY_POINT equ $6100
CPM_CMDLINE_ADDR equ $6080
CPM_CMDLINE_LEN equ 80
OPEN_CHAN equ $1601

	org $6000
	jp MainStart
	jp PrintReply

MainStart
	ld hl, CPM_CMDLINE_ADDR
	ld de, CPM_CMDLINE_ADDR+1
	ld bc, CPM_CMDLINE_LEN-1
	ld (hl), 0
	ldir
	call CopyFirstStringVariableToCmdLine
	jp CallAI

Debug
	ld hl, CPM_CMDLINE_ADDR
	ld de, CPM_CMDLINE_ADDR+1
	ld bc, CPM_CMDLINE_LEN-1
	ld (hl), 0
	ldir

	ld hl, CPM_CMDLINE_ADDR
	ld (hl), 2
	inc hl
	ld (hl), 'H'
	inc hl
	ld (hl), 'I'
	; intentional fall-through

CallAI:
	ld (RestoreIY), iy
	di
	call AI_ENTRY_POINT
	ld iy, (RestoreIY)
	ei
	ld a, 7		; AI will mess up the border for fun
	out ($fe), a
	ret

; prints one character of the reply
PrintReply:
	ld iy, (RestoreIY)
	ei
	push af
	ld a, 2
	call OPEN_CHAN
	pop af
	rst 16
	di
	ld (RestoreIY), iy
	ret

; --------------------------------
; copies first string variable to AI input
CopyFirstStringVariableToCmdLine:
	; get the strings area
	ld hl, (23627)	; VARS
.find_A_var:
	ld a, (hl)
	; skip name and flags
	inc hl
	; load string data
	ld c, (hl)
	inc hl
	ld b, (hl)
	inc hl

	if (0)
	cp 0x40		; '010
	jr z, .found

	; not A, continue
	add hl, bc
	jr .find_A_var
	endif

.found
	; BC holds the count, HL holds the ptr to beginning
	ld de, CPM_CMDLINE
	; handle empty strings
	ld a, b
	or c
	jr z, .empty_string
	ld a, c
	ld (de), a
	inc de
	; we don't handle too long strings
	ld b, 0	
	ldir
	ret

.empty_string
	xor a
	ld (de), a
	ret

RestoreIY
	dw 0

	org CPM_CMDLINE_ADDR
CPM_CMDLINE
	ds CPM_CMDLINE_LEN

	DISPLAY "First address ready to use is ", /A, $

	org AI_ENTRY_POINT
	incbin "../../block.bin"

	SAVETAP "main_code.tap", CODE, "TinyChat", $6000, $-$6000
	;SAVESNA "main_code_debug.sna", Debug
