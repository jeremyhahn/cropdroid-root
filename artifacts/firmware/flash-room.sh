#!/bin/bash

avrdude -v -patmega328p -carduino -P/dev/ttyUSB1 -b115200 -D -U flash:w:cropdroid-room.hex
