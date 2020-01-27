.label IO_REG = $01
.label NMI_LO = $FFFA
.label NMI_HI = $FFFB
.label IRQ_LO = $FFFE
.label IRQ_HI = $FFFF
.label CIA1_ICR = $DC0D
.label CIA2_ICR = $DD0D


*=$0801 "Basic Upstart"
BasicUpstart(start)
*=$080d "Program"
start:

  jsr init

loop:
  lda #$00
  sta $D020
  lda #$01
  sta $D020
  jmp loop
  
irqHandler: {
  rti
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
