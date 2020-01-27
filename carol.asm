*=$0801 "Basic Upstart"
BasicUpstart(start)
*=$080d "Program"
start:

loop:
  lda #$00
  sta $D020
  lda #$01
  sta $D020
  jmp loop
  
  