Function1700b0: ; 1700b0
; special
	call InitBattleTowerChallengeRAM
	callba Function118121
	ret
; 1700ba

Function1700ba: ; 1700ba
	call InitBattleTowerChallengeRAM
	callba Function11811a
	ret
; 1700c4

Function1700c4: ; 1700c4
	ld a, [rSVBK]
	push af
	ld a, $3
	ld [rSVBK], a

	call Function17042c

	ld a, $5
	call GetSRAMBank
	ld a, $1
	ld [$be45], a
	xor a
	ld [$be46], a
	ld hl, w3_dffc
	ld de, $aa41
	ld bc, 4
	call CopyBytes
	ld hl, w3_d202Name
	ld de, $aa8e
	ld bc, 7 * $cc ; length of battle tower struct from japanese games?
	call CopyBytes
	ld hl, $aa5d ; some sort of count
	ld a, [hl]
	inc [hl]
	inc hl
	sla a
	sla a
	ld e, a
	ld d, $0
	add hl, de
	ld e, l
	ld d, h
	ld hl, w3_dffc
	ld bc, 4
	call CopyBytes
	call CloseSRAM
	pop af
	ld [rSVBK], a
	ret
; 170114

Function170114: ; 170114
	call InitBattleTowerChallengeRAM
	call .Function170121
	callba Function11805f
	ret
; 170121

.Function170121: ; 170121
	ld a, $5
	call GetSRAMBank
	ld hl, $a948
	ld de, wMisc
	ld bc, $f6 ; 246
	call CopyBytes
	call CloseSRAM
	call Function170c8b
	ret
; 170139

Function170139: ; 170139
; Convert the 4-digit decimal number at 5:aa41 into binary
	ld a, $5
	call GetSRAMBank
	ld de, $aa41
	ld h, $0
	ld l, h
	ld bc, 1000
	call .DecToBin
	ld bc, 100
	call .DecToBin
	ld bc, 10
	call .DecToBin
	ld a, [de]
	ld c, a
	ld b, $0
	add hl, bc
	call CloseSRAM
; Store that number in wMisc
	ld a, h
	ld [wMisc], a
	ld a, l
	ld [wMisc + 1], a
	ld hl, wBT_OTTempPkmn1DVs
	ld a, [PlayerID]
	ld [hli], a
	ld a, [PlayerID + 1]
	ld [hli], a
	ld a, [wSecretID]
	ld [hli], a
	ld a, [wSecretID + 1]
	ld [hli], a
	ld e, l
	ld d, h
	ld hl, PlayerName
	ld bc, 5 ; Japanese name length
	call CopyBytes
	ld bc, PlayerID
	ld de, PlayerGender
	callba Function4e929
	ld de, wBT_OTTempPkmn1CaughtGender
	ld a, c
	ld [de], a
	inc de
	ld a, PartyMons % $100
	ld [wcd49], a
	ld a, PartyMons / $100
	ld [wcd4a], a
	ld a, PartyMonNicknames % $100
	ld [wcd4b], a
	ld a, PartyMonNicknames / $100
	ld [wcd4c], a
	ld a, 3
.CopyLoop:
	push af
	ld a, [wcd49]
	ld l, a
	ld a, [wcd4a]
	ld h, a
	ld bc, PARTYMON_STRUCT_LENGTH
	call CopyBytes
	ld a, l
	ld [wcd49], a
	ld a, h
	ld [wcd4a], a
	ld a, [wcd4b]
	ld l, a
	ld a, [wcd4c]
	ld h, a
	ld bc, $0006
	call CopyBytes
	ld a, l
	ld [wcd4b], a
	ld a, h
	ld [wcd4c], a
	pop af
	dec a
	jr nz, .CopyLoop
	ld a, $4
	call GetSRAMBank
	ld hl, $a013
	ld bc, $24
	call CopyBytes
	call CloseSRAM
	ld a, $5
	call GetSRAMBank
	ld hl, $a894
	ld bc, 6
	call CopyBytes
	ld hl, wMisc
	ld de, $a948
	ld bc, $f6
	call CopyBytes
	call CloseSRAM
	ret
; 17020c

.DecToBin: ; 17020c
	ld a, [de]
	inc de
	and a
	ret z

.digit_loop
	add hl, bc
	dec a
	jr nz, .digit_loop
	ret
; 170215

BattleTowerBattle: ; 170215
	xor a
	ld [wBattleTowerBattleEnded], a
	call _BattleTowerBattle
	ret
; 17021d

EmptySpecial_17021d: ; 17021d
	ret
; 17021e

InitBattleTowerChallengeRAM: ; 17021e
	xor a
	ld [wBattleTowerBattleEnded], a
	ld [wNrOfBeatenBattleTowerTrainers], a
	ld [wcf65], a
	ld [wcf66], a
	ret
; 17022c

_BattleTowerBattle: ; 17022c
.loop
	call .do_dw
	call DelayFrame
	ld a, [wBattleTowerBattleEnded]
	cp $1
	jr nz, .loop
	ret
; 17023a

.do_dw ; 17023a
	ld a, [wBattleTowerBattleEnded]
	ld e, a
	ld d, 0
	ld hl, .dw
rept 2
	add hl, de
endr
	ld a, [hli]
	ld h, [hl]
	ld l, a
	jp [hl]
; 170249

.dw ; 170249
	dw RunBattleTowerTrainer
	dw SkipBattleTowerTrainer
; 17024d

RunBattleTowerTrainer: ; 17024d
	ld a, [Options]
	push af
	ld hl, Options
	res BATTLE_SHIFT, [hl] ; SET MODE

	ld a, [InBattleTowerBattle]
	push af
	or $1
	ld [InBattleTowerBattle], a

	xor a
	ld [wLinkMode], a
	;callba Mobile_HealParty
	callba HealParty
	call ReadBTTrainerParty
	call Clears5_a89a

	predef StartBattle

	callba LoadPokemonData
	callba HealParty
	ld a, [wBattleResult]
	ld [ScriptVar], a
	and a
	jr nz, .lost
	ld a, BANK(sNrOfBeatenBattleTowerTrainers)
	call GetSRAMBank
	ld a, [sNrOfBeatenBattleTowerTrainers]
	ld [wNrOfBeatenBattleTowerTrainers], a
	call CloseSRAM
	ld hl, StringBuffer3
	ld a, [wNrOfBeatenBattleTowerTrainers]
	add "1"
	ld [hli], a
	ld a, "@"
	ld [hl], a

.lost
	pop af
	ld [InBattleTowerBattle], a
	pop af
	ld [Options], a
	ld a, $1
	ld [wBattleTowerBattleEnded], a
	ret


ReadBTTrainerParty: ; 1702b7
; Initialise the BattleTower-Trainer and his Pkmn
	call CopyBTTrainer_FromBT_OT_TowBT_OTTemp

	ld hl, wBT_OTTempName ; 0xc608
	ld de, OTPlayerName
	ld bc, NAME_LENGTH - 1
	call CopyBytes
	ld a, "@"
	ld [de], a

	ld hl, wBT_OTTempTrainerClass
	ld a, [hli]
	ld [OtherTrainerClass], a
	ld a, OTPartyMonNicknames % $100
	ld [BGMapBuffer], a
	ld a, OTPartyMonNicknames / $100
	ld [BGMapBuffer + 1], a

	; Copy Pkmn into Memory from the address in hl
	ld de, OTPartyMon1Species
	ld bc, OTPartyCount
	ld a, BATTLETOWER_NROFPKMNS ; Number of Pkmn the BattleTower-Trainer has
	ld [bc], a
	inc bc
.otpartymon_loop
	push af
	ld a, [hl]
	ld [bc], a
	inc bc
	push bc
	ld bc, PARTYMON_STRUCT_LENGTH
	call CopyBytes
	push de
	ld a, [BGMapBuffer]
	ld e, a
	ld a, [BGMapBuffer + 1]
	ld d, a
	ld bc, PKMN_NAME_LENGTH
	call CopyBytes
	ld a, e
	ld [BGMapBuffer], a
	ld a, d
	ld [BGMapBuffer + 1], a
	pop de
	pop bc
	pop af
	dec a
	and a
	jr nz, .otpartymon_loop
	ld a, -1
	ld [bc], a
	ret
; 170394

Function17042c: ; 17042c
	ld hl, w3_d202TrainerData
	ld a, BATTLETOWER_NROFTRAINERS
.loop
	push af
	push hl
	ld c, BATTLETOWER_TRAINERDATALENGTH / 2
.loop2
	; First byte is a comparison value.
	ld a, [hli]
	ld b, a
	; Second byte is a lookup index.
	ld a, [hli]
	and a
	jr z, .empty
	cp 15
	jr nc, .copy_data

	push hl
	ld hl, Unknown_170470
	dec a
	ld e, a
	ld d, 0
	add hl, de
	ld a, [hl]
	pop hl

	; If Unknown_170470[a-1] <= b, overwrite the current trainer's data
	; with Unknown17047e, and exit the inner loop.
	cp b
	jr c, .copy_data
	jr z, .copy_data
	jr .next_iteration

.empty
	; If a == 0 and b >= $fc, overwrite the current trainer's data with
	; Unknown17047e, and exit the inner loop.
	ld a, b
	cp $fc
	jr nc, .copy_data

.next_iteration
	dec c
	jr nz, .loop2
	jr .next_trainer

.copy_data
	pop de
	push de
	ld hl, Unknown_17047e
	ld bc, BATTLETOWER_TRAINERDATALENGTH
	call CopyBytes

.next_trainer
	pop hl
	ld de, BATTLE_TOWER_STRUCT_LENGTH
	add hl, de
	pop af
	dec a
	jr nz, .loop
	ret
; 170470

Unknown_170470:
	db $12
	db $24
	db $45
	db $45
	db $42
	db $42
	db $45
	db $42
	db $27
	db $27
	db $45
	db $27
	db $42
	db $24

Unknown_17047e:
; see data/battle_tower_2.asm
	db $03,  4
	db $05,  8
	db $03,  5
	db $0e,  6
	db $03,  2
	db $00,  0
	db $39,  7
	db $07,  4
	db $00,  5
	db $04,  7
	db $01,  5
	db $00,  0
	db $0f,  5
	db $14,  7
	db $05,  5
	db $11, 12
	db $0c,  6
	db $06,  4


CopyBTTrainer_FromBT_OT_TowBT_OTTemp: ; 1704a2
; copy the BattleTower-Trainer data that lies at 'BT_OTTrainer' to 'wBT_OTTemp'
	ld a, [rSVBK]
	push af
	ld a, $3 ; BANK(BT_OTTrainer)
	ld [rSVBK], a

	ld hl, BT_OTTrainer ; $d100
	ld de, wBT_OTTemp ; wMisc
	ld bc, BATTLE_TOWER_STRUCT_LENGTH
	call CopyBytes

	pop af
	ld [rSVBK], a

	ld a, BANK(sBattleTowerChallengeState)
	call GetSRAMBank
	ld a, BATTLETOWER_CHALLENGE_IN_PROGESS
	ld [sBattleTowerChallengeState], a
	ld hl, sNrOfBeatenBattleTowerTrainers
	inc [hl]
	call CloseSRAM
SkipBattleTowerTrainer: ; 1704c9
	ret
; 1704ca

BattleTowerAction: ; 170687
	ld a, [ScriptVar]
	ld e, a
	ld d, 0
	ld hl, .dw
rept 2
	add hl, de
endr
	ld a, [hli]
	ld h, [hl]
	ld l, a
	jp [hl]
; 170696


.dw ; 170696 (5c:4696)
	dw Function17075f ; 0x00
	dw Function170788 ; 0x01
	dw Function170778 ; 0x02
	dw BattleTowerAction_SetByteToQuickSaveChallenge ; 0x03
	dw BattleTowerAction_SetByteToCancelChallenge ; 0x04
	dw Function1707ac ; 0x05
	dw Function1707f4 ; 0x06
	dw SaveBattleTowerLevelGroup ; 0x07
	dw LoadBattleTowerLevelGroup ; 0x08
	dw BattleTower_CheckSaveFileExistsAndIsYours ; 0x09
	dw Function1708b1 ; 0x0a
	dw CheckMobileEventIndex ; 0x0b
	dw Function1708c8 ; 0x0c
	dw Function1708f0 ; 0x0d
	dw Function17093c ; 0x0e
	dw Function1709aa ; 0x0f
	dw Function1709bb ; 0x10
	dw Function170a9c ; 0x11
	dw Function170aa0 ; 0x12
	dw Function170aaf ; 0x13
	dw Function170abe ; 0x14
	dw Function170ad7 ; 0x15
	dw Function170807 ; 0x16
	dw Function17081d ; 0x17
	dw Function170ae8 ; 0x18
	dw Function170b16 ; 0x19
	dw ResetBattleTowerTrainersSRAM ; 0x1a
	dw BattleTower_GiveReward ; 0x1b
	dw Function17071b ; 0x1c
	dw Function170729 ; 0x1d
	dw BattleTower_RandomlyChooseReward ; 0x1e
	dw BattleTower_SaveOptions ; 0x1f


; Reset the save memory for BattleTower-Trainers (Counter and all 7 TrainerBytes)
ResetBattleTowerTrainersSRAM: ; 1706d6 (5c:46d6) BattleTowerAction $1a
	ld a, BANK(sBTTrainers)
	call GetSRAMBank

	ld a, $ff
	ld hl, sBTTrainers
	ld bc, BATTLETOWER_NROFTRAINERS
	call ByteFill

	xor a
	ld [sNrOfBeatenBattleTowerTrainers], a

	call CloseSRAM

	ret

BattleTower_GiveReward: ; 1706ee (5c:46ee) BattleTowerAction $1b
	ld a, BANK(sBattleTowerReward)
	call GetSRAMBank

	ld a, [sBattleTowerReward]
	call CloseSRAM
	ld [ScriptVar], a
	ld hl, NumItems
	ld a, [hli]
	cp MAX_ITEMS
	ret c
	ld b, MAX_ITEMS
	ld a, [ScriptVar]
	ld c, a
.loop
	ld a, [hli]
	cp c
	jr nz, .next
	ld a, [hl]
	cp 95
	ret c
.next
	inc hl
	dec b
	jr nz, .loop
	ld a, POTION
	ld [ScriptVar], a
	ret

Function17071b: ; 17071b (5c:471b) BattleTowerAction $1c
	ld a, BANK(sBattleTowerChallengeState)
	call GetSRAMBank
	ld a, BATTLETOWER_WON_CHALLENGE
	ld [sBattleTowerChallengeState], a
	call CloseSRAM
	ret

Function170729: ; 170729 (5c:4729) BattleTowerAction $1d
	ld a, BANK(sBattleTowerChallengeState)
	call GetSRAMBank
	ld a, BATTLETOWER_RECEIVED_REWARD
	ld [sBattleTowerChallengeState], a
	call CloseSRAM
	ret

BattleTower_SaveOptions: ; 170737 (5c:4737) BattleTowerAction $1f
	callba SaveOptions
	ret

BattleTower_RandomlyChooseReward: ; 17073e (5c:473e) BattleTowerAction $1e
; Generate a random stat boosting item.
.loop
	call Random
	ld a, [hRandomAdd]
	and $7
	cp 6
	jr c, .okay
	sub 6
.okay
	add HP_UP
	cp LUCKY_PUNCH
	jr z, .loop
	push af
	ld a, BANK(sBattleTowerReward)
	call GetSRAMBank
	pop af
	ld [sBattleTowerReward], a
	call CloseSRAM
	ret

Function17075f: ; 17075f (5c:475f) BattleTowerAction $00
	call BattleTower_CheckSaveFileExistsAndIsYours
	ld a, [ScriptVar]
	and a
	ret z

	ld a, BANK(s1_be4f)
	call GetSRAMBank
	ld a, [s1_be4f]
	and $2
	ld [ScriptVar], a
	call CloseSRAM
	ret

Function170778: ; 170778 (5c:4778) BattleTowerAction $02
	ld hl, sBattleTowerChallengeState
	ld a, BANK(sBattleTowerChallengeState)
	call GetSRAMBank
	ld a, [hl]
	ld [ScriptVar], a
	call CloseSRAM
	ret

Function170788: ; 170788 (5c:4788) BattleTowerAction $01
	ld a, BANK(s1_be4f)
	call GetSRAMBank
	ld a, [s1_be4f]
	or $2
	ld [s1_be4f], a
	call CloseSRAM
	ret

BattleTowerAction_SetByteToQuickSaveChallenge: ; 170799 (5c:4799) BattleTowerAction $03
	ld c, BATTLETOWER_SAVED_AND_LEFT
	jr asm_17079f

BattleTowerAction_SetByteToCancelChallenge: ; 17079d (5c:479d) BattleTowerAction $04
	ld c, BATTLETOWER_NO_CHALLENGE
asm_17079f: ; 17079f (5c:479f)
	ld a, BANK(sBattleTowerChallengeState)
	call GetSRAMBank
	ld a, c
	ld [sBattleTowerChallengeState], a
	call CloseSRAM
	ret

Function1707ac: ; 1707ac (5c:47ac) BattleTowerAction $05
	ld a, $5
	call GetSRAMBank
	ld a, [$aa8c]
	ld b, a
	ld a, [$be46]
	ld [ScriptVar], a
	call CloseSRAM
	and a
	ret z
	ld a, b
	cp $2
	jr nc, .asm_1707ef
	push bc
	call UpdateTime
	pop bc
	ld a, $5
	call GetSRAMBank
	ld a, [$aa8b]
	call CloseSRAM
	ld c, a
	ld a, [CurDay]
	sub c
	jr c, .asm_1707e5
	cp $8
	jr nc, .asm_1707ef
	ld a, b
	and a
	jr nz, .asm_1707ef
	ret
.asm_1707e5
	ld hl, CurDay
	ld a, $8c
	sub c
	add [hl]
	cp $8
	ret c
.asm_1707ef
	ld a, $8
	ld [ScriptVar], a

Function1707f4: ; 1707f4 (5c:47f4) BattleTowerAction $06
	ld a, $5
	call GetSRAMBank
	xor a
	ld [$be46], a
	ld [$aa8b], a
	ld [$aa8c], a
	call CloseSRAM
	ret

Function170807: ; 170807 (5c:4807) BattleTowerAction $16
	call UpdateTime
	ld a, $5
	call GetSRAMBank
	ld a, [CurDay]
	ld [$b2f9], a
	xor a
	ld [$b2fa], a
	call CloseSRAM
	ret

Function17081d: ; 17081d (5c:481d) BattleTowerAction $17
	xor a
	ld [ScriptVar], a
	ld a, $5
	call GetSRAMBank
	ld a, [$b2f9]
	ld c, a
	ld a, [$b2fa]
	ld b, a
	call CloseSRAM
	cp $2
	jr nc, .asm_170853
	push bc
	call UpdateTime
	pop bc
	ld a, [CurDay]
	sub c
	jr c, .asm_170849
	cp $b
	jr nc, .asm_170853
	ld a, b
	and a
	jr nz, .asm_170853
	ret

.asm_170849
	ld hl, CurDay
	ld a, 140
	sub c
	add [hl]
	cp $b
	ret c
.asm_170853
	ld a, $1
	ld [ScriptVar], a
	ld a, $5
	call GetSRAMBank
	xor a
	ld [$b2f9], a
	ld [$b2fa], a
	call CloseSRAM
	ret

SaveBattleTowerLevelGroup: ; 170868 (5c:4868) BattleTowerAction $07
	ld a, BANK(sBTChoiceOfLevelGroup)
	call GetSRAMBank
	ld a, [rSVBK]
	push af
	ld a, $3
	ld [rSVBK], a
	ld a, [wBTChoiceOfLvlGroup]
	ld [sBTChoiceOfLevelGroup], a
	pop af
	ld [rSVBK], a
	call CloseSRAM
	ret

LoadBattleTowerLevelGroup: ; 170881 (5c:4881) BattleTowerAction $08 ; Load level group choice
	ld a, BANK(sBTChoiceOfLevelGroup)
	call GetSRAMBank
	ld a, [rSVBK]
	push af
	ld a, $3
	ld [rSVBK], a
	ld a, [sBTChoiceOfLevelGroup]
	ld [wBTChoiceOfLvlGroup], a
	pop af
	ld [rSVBK], a
	call CloseSRAM
	ret

BattleTower_CheckSaveFileExistsAndIsYours: ; 17089a BattleTowerAction $09
	ld a, [wSaveFileExists]
	and a
	jr z, .nope
	callba CompareLoadedAndSavedPlayerID
	jr z, .yes
	xor a
	jr .nope

.yes
	ld a, $1

.nope
	ld [ScriptVar], a
	ret
; 1708b1


Function1708b1: ; 1708b1 (5c:48b1) BattleTowerAction $0a
	xor a
	ld [MusicFade], a
	call MaxVolume
	ret

CheckMobileEventIndex: ; 1708b9 (5c:48b9) BattleTowerAction $0b something to do with GS Ball
	ld a, BANK(sMobileEventIndex)
	call GetSRAMBank
	ld a, [sMobileEventIndex]
	ld [ScriptVar], a
	call CloseSRAM
	ret

Function1708c8: ; 1708c8 (5c:48c8) BattleTowerAction $0c
	call UpdateTime
	ld a, $5
	call GetSRAMBank
	ld a, [CurDay]
	ld [$aa8b], a
	xor a
	ld [$aa8c], a
	ld a, [$aa5d]
	cp $2
	jr nc, .asm_1708ec
	ld a, [CurDay]
	ld [$aa48], a
	ld a, $1
	ld [$aa47], a
.asm_1708ec
	call CloseSRAM
	ret

Function1708f0: ; 1708f0 (5c:48f0) BattleTowerAction $0d
	xor a
	ld [ScriptVar], a
	call UpdateTime
	ld a, $5
	call GetSRAMBank
	ld a, [$aa48]
	ld c, a
	ld a, [$aa47]
	call CloseSRAM
	and a
	ret z
	ld hl, CurDay
	ld a, c
	cp [hl]
	jr nz, Function170923
	ld a, $5
	call GetSRAMBank
	ld a, [$aa5d]
	call CloseSRAM
	cp $5
	ret c
	ld a, $1
	ld [ScriptVar], a
	ret


Function170923: ; 170923
	ld a, $5
	call GetSRAMBank
	xor a
	ld [$aa48], a
	ld [$aa47], a
	ld hl, $aa5d
	ld bc, $0011
	call ByteFill
	call CloseSRAM
	ret
; 17093c


Function17093c: ; 17093c (5c:493c) BattleTowerAction $0e
	xor a
	ld [ScriptVar], a
	ld a, [PartyCount]
	ld b, 0
	ld c, a
	ld hl, PartySpecies
.loop
	ld a, [hli]
	cp EGG
	jr nz, .not_egg
	push hl
	ld hl, PartyMonOT ; wddff (aliases: PartyMonOT)
	ld de, $6 ; NAME_LENGTH
	ld a, b
	and a
	jr z, .skip
.loop2
	add hl, de
	dec a
	jr nz, .loop2
.skip
	ld de, String_1709a4
	ld a, $6 ; NAME_LENGTH
.compare_loop
	push af
	ld a, [de]
	inc de
	cp [hl]
	inc hl
	jr nz, .different
	pop af
	dec a
	jr nz, .compare_loop
rept 4
	dec hl
endr
	ld a, "@"
rept 2
	ld [hli], a
endr
	pop hl
	ld a, $1
	ld [ScriptVar], a
	ret

.different
	pop af
	pop hl
.not_egg
	inc b
	dec c
	jr nz, .loop
	ret
; 1709a4 (5c:49a4)

String_1709a4: ; 1709a4
	db "なぞナゾ@@"

Function1709aa: ; 1709aa (5c:49aa) BattleTowerAction $0f
	ld a, [rSVBK]
	push af
	ld a, BANK(w3_d090)
	ld [rSVBK], a
	ld a, [w3_d090]
	ld [ScriptVar], a
	pop af
	ld [rSVBK], a
	ret

Function1709bb: ; 1709bb (5c:49bb) BattleTowerAction $10
	xor a
	ld [ScriptVar], a
	ld a, $5
	call GetSRAMBank
	ld a, [$a800]
	call CloseSRAM
	cp 6
	jr nc, .invalid
	ld e, a
	ld d, 0
	ld hl, Jumptable_1709e7
rept 2
	add hl, de
endr
	ld a, [hli]
	ld h, [hl]
	ld l, a
	jp [hl]

.invalid
	ld a, $5
	call GetSRAMBank
	xor a
	ld [$a800], a
	call CloseSRAM
	ret
; 1709e7 (5c:49e7)

Jumptable_1709e7: ; 1709e7
	dw .NoAction
	dw .NoAction
	dw .DoAction1
	dw .DoAction1
	dw .Action4
	dw .Action5
; 1709f3

.DoAction1: ; 1709f3
	ld a, $5
	call GetSRAMBank
	ld a, $1
	ld [$a800], a
	call CloseSRAM

.NoAction: ; 170a00
	ret
; 170a01

.Action4: ; 170a01
	ld a, $5
	call GetSRAMBank
	ld hl, $b023
	ld de, wMisc
	ld bc, $0069
	call CopyBytes
	ld a, [$a825]
	ld [wcd30], a
	ld a, [$a826]
	ld [wcd31], a
	call CloseSRAM
	callba Function11b6b4
	callba Function17d0f3
	ld a, $1
	ld [ScriptVar], a
	ret
; 170a33

.Action5: ; 170a33
	ld a, $0
	call GetSRAMBank
	ld hl, wRTC
	ld de, wMisc
	ld bc, $0004
	call CopyBytes
	call CloseSRAM
	ld a, $5
	call GetSRAMBank
	ld hl, $b08c
	ld de, wMisc
	ld c, $4
.compare_loop
	ld a, [de]
	inc de
	cp [hl]
	jr nz, .different
	inc hl
	dec c
	jr nz, .compare_loop
	call CloseSRAM
	ld a, [MapGroup]
	ld b, a
	ld a, [MapNumber]
	ld c, a
	call GetMapTrigger
	ld a, d
	or e
	jr z, .no_trigger
	ld a, [de]
	and a
	ret nz

.no_trigger
	ld a, $1
	ld [ScriptVar], a
	ret

.different
	call CloseSRAM
	ld a, $5
	call GetSRAMBank
	xor a
	ld [$a800], a
	call CloseSRAM
	ld [ScriptVar], a
	ld a, [MapGroup]
	ld b, a
	ld a, [MapNumber]
	ld c, a
	call GetMapTrigger
	ld a, d
	or e
	jr z, .no_trigger_2
	xor a
	ld [de], a

.no_trigger_2
	ret
; 170a9c

Function170a9c: ; 170a9c (5c:4a9c) BattleTowerAction $11
	ld c, $0
	jr asm_170aa2

Function170aa0: ; 170aa0 (5c:4aa0) BattleTowerAction $12
	ld c, $1
asm_170aa2: ; 170aa2 (5c:4aa2)
	ld a, $5
	call GetSRAMBank
	ld a, c
	ld [$aa8d], a
	call CloseSRAM
	ret

Function170aaf: ; 170aaf (5c:4aaf) BattleTowerAction $13
	ld a, $5
	call GetSRAMBank
	ld a, [$aa8d]
	ld [ScriptVar], a
	call CloseSRAM
	ret

Function170abe: ; 170abe (5c:4abe) BattleTowerAction $14
	call BattleTower_CheckSaveFileExistsAndIsYours
	ld a, [ScriptVar]
	and a
	ret z

	ld a, BANK(s1_be4f)
	call GetSRAMBank
	ld a, [s1_be4f]
	and $1
	ld [ScriptVar], a
	call CloseSRAM
	ret

Function170ad7: ; 170ad7 (5c:4ad7) BattleTowerAction $15
	ld a, BANK(s1_be4f)
	call GetSRAMBank
	ld a, [s1_be4f]
	or $1
	ld [s1_be4f], a
	call CloseSRAM
	ret

Function170ae8: ; 170ae8 (5c:4ae8) BattleTowerAction $18
	ld a, $5
	call GetSRAMBank
	ld a, [$b2fb]
	call CloseSRAM
	ld c, 10
	call SimpleDivide
	ld a, b
	ld [wcd4f], a
	xor a
	ld [ScriptVar], a
	callba Function119d93 ; level check
	ret nc
	ld a, $5
	call GetSRAMBank
	ld a, [$b2fb]
	call CloseSRAM
	ld [ScriptVar], a
	ret

Function170b16: ; 170b16 (5c:4b16) BattleTowerAction $19
	ld a, $5
	call GetSRAMBank
	ld a, [$b2fb]
	call CloseSRAM
	ld c, 10
	call SimpleDivide
	ld a, b
	ld [wcd4f], a
	xor a
	ld [ScriptVar], a
	callba Function119dd1 ; ubers check
	ret nc
	ld a, $5
	call GetSRAMBank
	ld a, [$b2fb]
	call CloseSRAM
	ld [ScriptVar], a
	ret

Function_LoadOpponentTrainerAndPokemonsWithOTSprite: ; 0x170b44
	callba Function_LoadOpponentTrainerAndPokemons
	ld a, [rSVBK]
	push af
	ld a, $3
	ld [rSVBK], a
	ld hl, BT_OTTrainerClass
	ld a, [hl]
	dec a
	ld c, a
	ld b, $0
	pop af
	ld [rSVBK], a
	ld hl, .Sprites
	add hl, bc
	ld a, [hl]
	ld [wBTTempOTSprite], a

; Load sprite of the opponent trainer
; because s/he is chosen randomly and appears out of nowhere
	ld a, [ScriptVar]
	dec a
	sla a
	ld e, a
	sla a
	sla a
	sla a
	ld c, a
	ld b, 0
	ld d, 0
	ld hl, MapObjects
	add hl, bc
	inc hl
	ld a, [wBTTempOTSprite]
	ld [hl], a
	ld hl, UsedSprites
	add hl, de
	ld [hli], a
	ld [hUsedSpriteIndex], a
	ld a, [hl]
	ld [hUsedSpriteTile], a
	callba GetUsedSprite
	ret
; 170b90

.Sprites:
	db SPRITE_KRIS
	db SPRITE_CHRIS
	db SPRITE_FALKNER
	db SPRITE_BUGSY
	db SPRITE_WHITNEY
	db SPRITE_MORTY
	db SPRITE_CHUCK
	db SPRITE_JASMINE
	db SPRITE_PRYCE
	db SPRITE_CLAIR
	db SPRITE_WILL
	db SPRITE_KOGA
	db SPRITE_BRUNO
	db SPRITE_KAREN
	db SPRITE_LANCE
	db SPRITE_BROCK
	db SPRITE_MISTY
	db SPRITE_SURGE
	db SPRITE_ERIKA
	db SPRITE_JANINE
	db SPRITE_SABRINA
	db SPRITE_BLAINE
	db SPRITE_BLUE
	db SPRITE_RED
	db SPRITE_LEAF
	db SPRITE_SILVER
	db SPRITE_SILVER
	db SPRITE_YOUNGSTER
	db SPRITE_BUG_CATCHER
	db SPRITE_YOUNGSTER
	db SPRITE_LASS
	db SPRITE_TWIN
	db SPRITE_FISHER
	db SPRITE_YOUNGSTER
	db SPRITE_POKEFAN_M
	db SPRITE_ROCKET
	db SPRITE_ROCKET_GIRL
	db SPRITE_JAMES
	db SPRITE_POKEFAN_M
	db SPRITE_POKEFAN_F
	db SPRITE_OFFICER
	db SPRITE_OFFICER_F
	db SPRITE_SUPER_NERD
	db SPRITE_SUPER_NERD
	db SPRITE_LASS
	db SPRITE_BUENA
	db SPRITE_FISHER
	db SPRITE_SUPER_NERD
	db SPRITE_YOUNGSTER
	db SPRITE_TWIN
	db SPRITE_YOUNGSTER
	db SPRITE_HEX_MANIAC
	db SPRITE_SAGE
	db SPRITE_GRANNY
	db SPRITE_KIMONO_GIRL
	db SPRITE_SAGE
	db SPRITE_LASS
	db SPRITE_YOUNGSTER
	db SPRITE_GENTLEMAN
	db SPRITE_RICH_BOY
	db SPRITE_BREEDER
	db SPRITE_COWGIRL
	db SPRITE_SAILOR
	db SPRITE_SWIMMER_GUY
	db SPRITE_SWIMMER_GIRL
	db SPRITE_PHARMACIST
	db SPRITE_PI
	db SPRITE_SCIENTIST
	db SPRITE_ROCKER
	db SPRITE_BUENA
	db SPRITE_BLACK_BELT
	db SPRITE_COOLTRAINER_F
	db SPRITE_DRAGON_TAMER
	db SPRITE_TEACHER
	db SPRITE_ROCKER
	db SPRITE_COOLTRAINER_F
	db SPRITE_BIKER
	db SPRITE_BIKER
	db SPRITE_COOLTRAINER_M
	db SPRITE_COOLTRAINER_F
	db SPRITE_COOLTRAINER_M
	db SPRITE_VETERAN_M
	db SPRITE_VETERAN_F
	db SPRITE_ROCKET
	db SPRITE_ROCKET
	db SPRITE_ROCKET
	db SPRITE_ROCKET_GIRL
	db SPRITE_OAK
	db SPRITE_COOLTRAINER_M
	db SPRITE_SUPER_NERD
	db SPRITE_LYRA
	db SPRITE_LORELEI
	db SPRITE_AGATHA
	db SPRITE_YELLOW
	db SPRITE_WALKER
	db SPRITE_BILL
	db SPRITE_LAWRENCE
	db SPRITE_GIOVANNI
	db SPRITE_STEVEN
	db SPRITE_CYNTHIA
	db SPRITE_PALMER
	db SPRITE_VALERIE
	db SPRITE_SABRINA

ret_170bd2: ; 170bd2
	ret
; 170bd3

SpecialCheckForBattleTowerRules: ; 170bd3
	callba CheckForBattleTowerRules
	jr c, .asm_170bde
	xor a
	jr .asm_170be0

.asm_170bde
	ld a, $1

.asm_170be0
	ld [ScriptVar], a
	ret
; 170be4
