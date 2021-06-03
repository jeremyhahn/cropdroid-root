#!/bin/bash

avrdude -p m2560 -c wiring -P /dev/ttyACM0 -b 115200 -D -U flash:w:cropdroid-reservoir.hex
