#!/bin/bash
avrdude -c dragon_isp -p m2560 -Ulock:w:0x3F:m -Uefuse:w:0xFD:m -Uhfuse:w:0xD8:m -Ulfuse:w:0xFF:m -e -v
avrdude -c dragon_isp -p m2560 -Uflash:w:bootloader/stk500boot_v2_mega2560.hex:i -Ulock:w:0x0f:m -v
