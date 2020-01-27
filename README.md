# carol-shaw-story
## Build status
* master: [![CircleCI](https://circleci.com/gh/maciejmalecki/carol-shaw-story/tree/master.svg?style=svg)](https://circleci.com/gh/maciejmalecki/carol-shaw-story/tree/master)

## Useful links
* Slides: https://maciejmalecki.github.io/it-archeology/index-cg.html

## How to use it
Live demo is written Kick Assembler, a dialect of 6502 assembly. Output files can be
generated using gradle build, as there is a gradle wrapper provided, nothing more than
Java 8+ (JDK) is needed to run it.

Just type: ```gradlew build``` and in result a runnable ```carol.prg``` file is
created. 

Easiest way to run it is to use an emulator, for example: ```x64 carol.prg```
launches it using [Vice](http://vice-emu.sourceforge.net/).

All steps are included on ```live``` branch. Just checkout it.

## Hardware setup
* I use real Commodore 64C (for first part of live coding and as target machine of cross 
development) and a laptop (for slides, and second live coding: cross development
using KickAssembler and Relaunch64).
* I use 1541 Ultimate II+ cartridge for disk drive emulation (first live demo).
* I use EasyFlash 3 + USB cable to run KickAssembler out file on real C64 (second live demo).
* Additionally I use USB Screen Grabber and splitting cable (C64 Video port to both S-Video
and Composite at once) for real C64 preview in first live demo.
