.label IO_REG = $01
.label NMI_LO = $FFFA
.label NMI_HI = $FFFB
.label IRQ_LO = $FFFE
.label IRQ_HI = $FFFF
.label CIA1_ICR = $DC0D
.label CIA2_ICR = $DD0D
.label SCREEN = $0400
.label COLOR_RAM = $D800
.label CONTROL_1 = $D011  // vic control #1 register
.label CONTROL_2 = $D016  // vic control #2 register
.label RASTER = $D012     // raster counter
.label IRR = $d019        // interrupt request register
.label IMR = $d01a        // interrupt mask register



*=$0801 "Basic Upstart"
BasicUpstart(start)
*=$080d "Program"
start:

  jsr init
  jsr initScreen
  jsr installIrq

loop:
  lda #$00
  sta $D020
  lda #$01
  sta $D020
  jmp loop
  
  
irqHandler: {
  pha
  txa
  pha
  tya
  pha
  
  lda RASTER
  busyWait:
    cmp RASTER
  beq busyWait
  
  lda CONTROL_2
  and #%11111000
  ora #6
  sta CONTROL_2
  
  lda CONTROL_2
  and #%11111000

  ldx #20
  loop:
    ldy RASTER
    busyWait2:  
      cpy RASTER
    beq busyWait2
    dex
  bne loop
  
  sta CONTROL_2
  
  pla
  tay
  pla
  tax
  pla
  dec IRR
  rti
}  

installIrq: {
  sei             // disable interrupts
  lda #$3c
  sta RASTER      // set up requested raster line
  lda CONTROL_1
  and #%01111111
  sta CONTROL_1   // 9th bit of raster line is 0
  lda #$01
  sta IMR         // vic will trigger interrupt on given raster line
  cli             // enable interrupts
  rts
}

initScreen: {
  ldx #$00
  loop:
    lda screenData, x    
    sta SCREEN, x
    lda colorData, x
    sta COLOR_RAM, x
    
    lda screenData + 256, x
    sta SCREEN + 256, x
    lda colorData + 256, x
    sta COLOR_RAM + 256, x

    lda screenData + 512, x
    sta SCREEN + 512, x
    lda colorData + 512, x
    sta COLOR_RAM + 512, x

    lda screenData + 768, x
    sta SCREEN + 768, x
    lda colorData + 768, x
    sta COLOR_RAM + 768, x
    
    inx
  bne loop
  
  rts
} 
  
init: {
  sei
  lda IO_REG        
  and #%11111000
  ora #%00000101
  sta IO_REG
        
  lda #<irqHandler
  sta NMI_LO
  sta IRQ_LO
  lda #>irqHandler
  sta NMI_HI
  sta IRQ_HI
        
  lda #$7F
  sta CIA1_ICR
  sta CIA2_ICR
  lda CIA1_ICR
  lda CIA2_ICR
       
  cli        
  rts
}

screenData:
.byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
.byte $20,$20,$55,$40,$49,$20,$6E,$20,$70,$20,$55,$43,$49,$20,$70,$49,$55,$6E,$20,$70,$43,$49,$20,$70,$43,$6E,$20,$70,$43,$49,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
.byte $20,$20,$42,$20,$20,$20,$42,$20,$42,$20,$42,$20,$42,$20,$42,$42,$42,$42,$20,$42,$20,$42,$20,$42,$20,$20,$20,$42,$20,$42,$20,$03,$0F,$0E,$06,$20,$20,$20,$20,$20
.byte $20,$20,$42,$20,$20,$20,$6B,$43,$73,$20,$6B,$43,$73,$20,$42,$4A,$4B,$42,$20,$6B,$43,$49,$20,$6B,$43,$20,$20,$6B,$43,$49,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
.byte $20,$20,$42,$20,$20,$20,$42,$20,$42,$20,$42,$20,$42,$20,$42,$20,$20,$42,$20,$42,$20,$42,$20,$42,$20,$20,$20,$42,$20,$42,$20,$20,$20,$20,$20,$32,$30,$31,$39,$20
.byte $20,$20,$4A,$40,$4B,$20,$7D,$20,$6D,$20,$7D,$20,$6D,$20,$7D,$20,$20,$6D,$20,$6D,$43,$4B,$20,$6D,$43,$7D,$20,$7D,$20,$4A,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
.byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
.byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
.byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$42,$62,$79,$6F,$64,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
.byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$42,$77,$E2,$F9,$E2,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
.byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$42,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
.byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$42,$E9,$DF,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
.byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$E9,$A0,$A0,$DF,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
.byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$E9,$A0,$69,$5F,$A0,$DF,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
.byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$A0,$A0,$20,$20,$DC,$A0,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
.byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$A0,$A0,$20,$20,$DC,$A0,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
.byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$A0,$A0,$A0,$A0,$A0,$A0,$DC,$61,$20,$DC,$61,$20,$DC,$61,$20,$DC,$61,$20,$DC,$61,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
.byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$A0,$A0,$A0,$A0,$A0,$A0,$DC,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$61,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
.byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$DC,$A0,$A0,$A0,$A0,$A0,$DC,$A0,$A0,$A0,$A0,$E2,$A0,$A0,$A0,$A0,$A0,$A0,$A0,$61,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
.byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$DC,$A0,$A0,$A0,$A0,$A0,$DC,$A0,$A0,$A0,$61,$20,$E1,$A0,$A0,$A0,$A0,$A0,$A0,$61,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
.byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$E6,$A0,$A0,$A0,$A0,$A0,$DC,$A0,$A0,$A0,$61,$20,$E1,$A0,$A0,$A0,$A0,$A0,$A0,$61,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
.byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$E6,$E6,$E8,$A0,$A0,$A0,$DC,$A0,$A0,$A0,$FC,$62,$FE,$A0,$A0,$A0,$A0,$A0,$A0,$61,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
.byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
.byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
.byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
.fill 24, $00

colorData:
.byte $0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E
.byte $0E,$0E,$01,$0F,$0C,$0E,$01,$0E,$0F,$0E,$01,$0F,$0C,$0E,$01,$0F,$01,$0F,$0E,$01,$0F,$0C,$0E,$01,$0F,$0C,$0E,$01,$0F,$0C,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E
.byte $0E,$0E,$0F,$0E,$0E,$0E,$0F,$0E,$0F,$0E,$0F,$0E,$0C,$0E,$0F,$0C,$0F,$0C,$0E,$0F,$0E,$0B,$0E,$0F,$0E,$0E,$0E,$0F,$0E,$0B,$0E,$0F,$0F,$0F,$0F,$0E,$0E,$0E,$0E,$0E
.byte $0E,$0E,$0C,$0E,$0E,$0E,$0C,$0C,$0C,$0E,$0C,$0C,$0B,$0E,$0C,$0C,$0B,$0B,$0E,$0C,$0C,$0B,$0E,$0C,$0C,$0E,$0E,$0C,$0C,$0B,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E
.byte $0E,$0E,$0C,$0E,$0E,$0E,$0C,$0E,$0B,$0E,$0C,$0E,$0B,$0E,$0C,$0E,$0E,$0B,$0E,$0C,$0E,$0B,$0E,$0C,$0E,$0E,$0E,$0C,$0E,$0B,$0E,$0E,$0E,$0E,$0E,$0D,$07,$0A,$02,$0E
.byte $0E,$0E,$0B,$0B,$0B,$0E,$0B,$0E,$0B,$0E,$0B,$0E,$0B,$0E,$0B,$0E,$0E,$0B,$0E,$0B,$0B,$0B,$0E,$0B,$0B,$0B,$0E,$0B,$0E,$0B,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E
.byte $0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E
.byte $0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E
.byte $0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0C,$02,$02,$02,$02,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E
.byte $0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0C,$02,$02,$02,$02,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E
.byte $0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0C,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E
.byte $0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0C,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E
.byte $0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E
.byte $0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E
.byte $0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E
.byte $0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E
.byte $0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E
.byte $0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E
.byte $0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E
.byte $0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E
.byte $0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E
.byte $0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E
.byte $0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E
.byte $0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E
.byte $0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E
.fill 24, $00
