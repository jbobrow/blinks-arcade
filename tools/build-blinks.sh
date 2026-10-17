#!/bin/bash
# Build a Blinks sketch folder with the Blinks-SDK core, following platform.txt recipes.
# usage: BLINKS_SDK=~/Blinks-SDK tools/build-blinks.sh blinks/OrbitLock
# Needs avr-gcc (e.g. apt install gcc-avr avr-libc). Prints flash/RAM use and fails if over the Blink limit.
set -e
SDK="${BLINKS_SDK:?set BLINKS_SDK to your Blinks-SDK checkout (github.com/Move38/Blinks-SDK)}"
SK="$1"; NAME=$(basename "$SK"); B=/tmp/blinkbuild/$NAME; rm -rf "$B"; mkdir -p "$B/core"
MCU=atmega168pb; DEF="-mmcu=$MCU -DF_CPU=8000000L -DARDUINO=10813 -DARDUINO_AVR_BLINK -DARDUINO_ARCH_AVR"
INC="-I$SDK/cores/blinklib -I$SDK/variants/standard"
CF="-c -g -Os -w -std=gnu11 -ffunction-sections -fdata-sections -MMD -flto -fno-fat-lto-objects"
CPPF="-c -g -Os -Wall -std=gnu++11 -fpermissive -fno-exceptions -ffunction-sections -fdata-sections -fno-threadsafe-statics -Wno-error=narrowing -MMD -flto"
SF="-c -x assembler-with-cpp -flto -MMD"
for f in $SDK/cores/blinklib/*.c; do [ -e "$f" ] && avr-gcc $CF $DEF $INC "$f" -o "$B/core/$(basename $f).o"; done
for f in $SDK/cores/blinklib/*.cpp; do avr-g++ ${CPPF/-Wall/-w} $DEF $INC "$f" -o "$B/core/$(basename $f).o"; done
for f in $SDK/cores/blinklib/*.S; do avr-gcc $SF $DEF $INC "$f" -o "$B/core/$(basename $f).o"; done
avr-gcc-ar rcs "$B/core.a" $B/core/*.o
# sketch: concatenate .ino files (main first) and prepend Arduino.h like the IDE does
{ echo '#include <Arduino.h>'; echo "#line 1 \"$NAME.ino\""; cat "$SK/$NAME.ino"; for f in "$SK"/*.ino; do [ "$f" != "$SK/$NAME.ino" ] && cat "$f"; done; } > "$B/$NAME.ino.cpp"
avr-g++ $CPPF $DEF $INC -I"$SK" "$B/$NAME.ino.cpp" -o "$B/$NAME.ino.cpp.o" 2>&1 | grep -v '^$' || true
[ -f "$B/$NAME.ino.cpp.o" ] || { echo "COMPILE FAILED: $NAME"; exit 1; }
avr-gcc -w -Os -g -flto -mrelax -fuse-linker-plugin -Wl,--gc-sections -mmcu=$MCU -T "$SDK/linkscripts/avr5.xn" -nostartfiles -o "$B/$NAME.elf" "$B/$NAME.ino.cpp.o" "$B/core.a" -L"$B" -lm
avr-objcopy --change-addresses 0x1700 -O ihex -R .eepromm "$B/$NAME.elf" "$B/$NAME.hex"
FL=$(avr-size -A "$B/$NAME.elf" | awk '/^\.text|^\.data/{s+=$2} END{print s}')
RAM=$(avr-size -A "$B/$NAME.elf" | awk '/^\.data|^\.bss|^\.noinit/{s+=$2} END{print s}')
printf "%-14s flash %5d / 5888 (%3d%%)   RAM %4d / 1024\n" "$NAME" $FL $((FL*100/5888)) $RAM
[ $FL -le 5888 ] || { echo "  !! TOO BIG for a Blink"; exit 2; }
