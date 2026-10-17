# Blinks Arcade sketches

Arduino sketches for real Blinks, one folder per game. Each plays on a single Blink and switches to connected play when Blinks touch, like the [browser version](https://blinksarcade.jonbobrow.com).

> **Status:** every sketch compiles against the [Blinks SDK](https://github.com/Move38/Blinks-SDK) and fits on a Blink. They have **not been tested on hardware yet**, so expect to tune timings and colors once they're running.

## Loading a game

1. Install the Blinks SDK in the Arduino IDE, following the [Blinks-SDK](https://github.com/Move38/Blinks-SDK) instructions.
2. Open a sketch, for example `blinks/OrbitLock/OrbitLock.ino`. The folder name has to match the file name, which Arduino requires.
3. Select the **Blink** board and upload through your dev kit.
4. To spread the game to other Blinks, hold the button on the programmed Blink **by itself** for 6 seconds until it spins blue, release, then put other Blinks next to it. This is the standard Blinks game-sharing ("seed") mode.

## The games

| Sketch | Flash (of 5,888) | RAM (of 1,024) | Controls on a Blink |
| --- | ---: | ---: | --- |
| [OrbitLock](OrbitLock/OrbitLock.ino) | 3,725 | 720 | press = hit gold · long press = new comet |
| [Parrot](Parrot/Parrot.ino) | 4,267 | 736 | click / double / triple / long press = copy the call · click an idle Blink to start a chain |
| [HexBrew](HexBrew/HexBrew.ino) | 4,515 | 836 | solo: click R, double G, triple B · connected: click = your ingredient, double = switch · long press = dump |
| [HighNoon](HighNoon/HighNoon.ino) | 5,257 | 842 | press = start / draw · long press = reset table |
| [Ricochet](Ricochet/Ricochet.ino) | 3,856 | 718 | press = serve / return · long press = new ball |
| [Spill](Spill/Spill.ino) | 4,203 | 826 | click = next paint · double-click = pour · long press = new board |
| [Safecracker](Safecracker/Safecracker.ino) | 4,761 | 814 | hold = turn dial, release on white · click = new safe |
| [Fireflies](Fireflies/Fireflies.ino) | 4,088 | 728 | click = move cursor · double-click = toggle · long press = new puzzle |
| [Honeypot](Honeypot/Honeypot.ino) | 4,638 | 800 | hold = pour, release to seal · click = new hive |
| [Hexling](Hexling/Hexling.ino) | 4,547 | 730 | triple = hatch · click = feed · double = play · long press = nap |

RAM figures include about 694 bytes that blinklib uses on its own. The deepest stack frame in any game is 27 bytes, so stack headroom is comfortable.

## How they differ from the browser version

Real Blinks work differently from the simulator in a few ways, so some rules changed:

- **Blinks don't know their orientation.** A Blink can tell which of its own faces has a neighbor, but not which face of the neighbor is touching it. Anything that crosses an edge (a comet, a ball, a spill, a firefly flip) is sent as a message and lands on whichever face receives it.
- **No Blink can see the whole group.** Shared state (Hex Brew's potion, Safecracker's combination, Spill's pours, High Noon's rounds) spreads by flooding messages from Blink to Blink. Each update carries a version number and a tie-break ID, so every Blink settles on the same answer. Important state is re-sent every 2 seconds, so a lost message heals itself.
- **Long presses are slower on hardware**, so frequent actions moved to double-click: pouring in Spill and toggling in Fireflies.
- **Holding the button for 6 seconds or more is reserved by the Blinks BIOS:** 6 seconds on a lone Blink starts game sharing, and 7 seconds puts the table to sleep. Safecracker jams the pin at 4.5 seconds so nobody gets there by accident.
- **Connected rules adapted for local messaging:**
  - **Parrot** becomes "telephone": you repeat the sequence, your Blink adds a call, then hands it to a touching Blink.
  - **Hex Brew:** each Blink holds one ingredient, and double-click switches it.
  - **High Noon:** whoever wins deals the next round. "Green" is a GO message from the dealer, so differences between Blink clocks don't matter.
  - **Fireflies** deals a fresh puzzle whenever the arrangement changes, because a puzzle only stays solvable for the arrangement it was dealt for.
  - **Orbit Lock:** every Blink keeps its own gold mark.

## Building from the command line

`tools/build-blinks.sh` builds a sketch with the same compiler settings as the SDK's `platform.txt`, without the IDE. It reports flash and RAM use and fails if a sketch is too big for a Blink.

```sh
sudo apt install gcc-avr avr-libc            # or any avr-gcc 7.x
git clone https://github.com/Move38/Blinks-SDK ~/Blinks-SDK
for g in blinks/*/; do BLINKS_SDK=~/Blinks-SDK tools/build-blinks.sh "$g"; done
```
