#!/bin/bash
avrdude -v -patmega328p -cusbasp -Pusb -e -Ulock:w:0x3F:m -Uefuse:w:0xFD:m -Uhfuse:w:0xDA:m -Ulfuse:w:0xFF:m
avrdude -v -patmega328p -cusbasp -Pusb -Uflash:w:optiboot_atmega328.hex:i -Ulock:w:0x0F:m
