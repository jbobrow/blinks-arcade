# Blinks Arcade

**Play it at [blinksarcade.jonbobrow.com](https://blinksarcade.jonbobrow.com)**

Ten one-button games for [Blinks](https://move38.com), playable in the browser. Every game works on a single Blink. Drag Blinks together and the same game switches to connected play.

## Play on real Blinks

The [`blinks/`](blinks/) folder has an Arduino sketch for each game, ready to load onto Blinks with the [Blinks SDK](https://github.com/Move38/Blinks-SDK). See [`blinks/README.md`](blinks/README.md) for loading steps, controls and how the hardware versions differ.

## How to play

- **Press the center** of a Blink to use its button. Click, double-click, triple-click, long press (700 ms) and hold-and-release all work.
- **Drag a Blink by its rim** to move it. Blinks that touch play together as a group.
- **Drop a Blink on the bin** (bottom-right, shown while dragging) to remove it. **+ Tile** adds a new one.
- **Space** presses the last Blink you touched.
- Pick a game from the cartridge shelf. The layout buttons set up Solo, Pair, Trio, 2 + 1 or Flower (7).

## The games

| Game | Solo | Connected |
| --- | --- | --- |
| Orbit Lock | Press when the comet lands on the gold segment | The orbit hops across edges and the target moves from Blink to Blink |
| Parrot | Repeat a growing sequence of gestures | Calls are spread across Blinks; each player answers their own |
| Hex Brew | Mix red, green and blue to match the potion | Each Blink holds one ingredient |
| High Noon | Reaction test: press on green | Duel: the fastest draw takes a segment from each opponent |
| Ricochet | Return the ball the moment it lands | Returns cross edges into a neighbor's Blink |
| Spill | Flood all six segments with one color | Race to claim the most segments |
| Safecracker | Hold to sweep a color, release on the hidden one | Same combination on every Blink; first to open wins |
| Fireflies | Lights Out on a ring of six | Toggles flip the touching segment on the next Blink |
| Honeypot | Pour and seal six cells without bursting | Bursts spill across edges and chain |
| Hexling | Hatch and care for a tiny pet | Pets keep each other company; eggs inherit neighbors' colors |

## Run locally

It's a static page. Serve the folder with any web server (the cartridge window mask needs `http://`, not `file://`):

```sh
python3 -m http.server 8000
# then open http://localhost:8000
```

## Publishing

GitHub Pages serves `main` from the repo root, with the custom domain set in `CNAME`. The `.nojekyll` file makes Pages serve the files as-is.

## Project layout

```
index.html                       page, simulator and all ten games
assets/cartridge-frame.png       cartridge frame (window is transparent)
assets/cartridge-window-mask.png alpha mask for the cartridge window
blinks/<Game>/<Game>.ino         Arduino sketch for each game, for real Blinks
tools/build-blinks.sh            command-line build + size check for the sketches
```

## Adding a game

Each game is an object in the `GAMES` array in `index.html`. The simulator groups touching Blinks into clusters and calls:

| Hook | Called |
| --- | --- |
| `initTile(t)` | once per Blink when the game loads; per-Blink state goes in `t.s` |
| `initCluster(C, now)` | whenever a group forms or changes shape; group state goes in `C.s` |
| `update(C, dt, now)` | every frame, per group |
| `event(C, t, ev, now)` | on a button event. `ev.type` is `down`, `up` (with `cancel` if it turned into a drag), `click` (with `n` clicks) or `long` |
| `draw(C, t, now)` | every frame per Blink; returns six `[r, g, b]` colors, face 0 at the top, clockwise |

Inside a group, `C.tiles` lists the Blinks (`t.p` is each one's player index) and `C.nb(t, f)` returns the Blink touching face `f`, if any. Face `f` on one Blink touches face `(f + 3) % 6` on its neighbor. `say(t, text)` shows a small readout above a Blink. That readout only exists in the simulator.

Cover art is drawn in code: add a function to `ART` and point the game's `art` at it.
