# SHAFT

A macOS menu-bar app and floating desktop pet — a pixel critter that lets you
**switch the model of a running Claude Code session** and shows your usage at
a glance.

Your little guy encodes three things at once:

- **Outfit** → the active model — crown (Opus), headphones (Sonnet), headband
  (Haiku), wizard hat (Fable).
- **Grey level** → how much of your plan budget is used; grey fills up from
  his feet as usage climbs (fully grey = maxed out).
- **Money bag** → he holds a gold `$` bag when paid credits are being spent
  (extra-usage / API).

He lives in the menu bar and as a draggable, always-on-top desktop pet.

## Requirements

- macOS 13+
- Swift 5.9+ (Xcode or Command Line Tools)
- [`tmux`](https://github.com/tmux/tmux) — `brew install tmux`
- Logged in to Claude Code (`claude`) so the usage data is available

## Run

SHAFT switches models by injecting `/model` into a Claude session running in
tmux, so the two run in **separate** terminals:

```bash
# Terminal 1 — the app (a normal terminal, NOT tmux):
cd ~/claude-critter
swift run SHAFT          # first run compiles (~30-60s)

# Terminal 2 — Claude inside tmux:
tmux new -s claude       # then, inside it:
claude
```

A critter icon appears in your menu bar (top-right) and a larger pet appears
bottom-right. It's a menu-bar app — there's no window; quit from the critter's
menu or with `Ctrl-C` in Terminal 1.

## Use it

Click the menu-bar critter, or **right-click the desktop pet**:

- **Target** — pick which tmux session a switch applies to (handy when you run
  several Claude sessions, each on a different model).
- **Switch model** — sends `/model …` to the target session. If Claude is
  mid-reply it beeps and you retry once it's idle.
- **Hide / Show pet**, **Start session** (when none exist), **Quit**.

The critter greys up from the feet as your usage climbs, and shows a money bag
if you're on paid credits. Usage and the balance line come from your Claude
plan; nothing is sent anywhere but Anthropic's own API.

## Develop

```bash
swift build                 # compile
swift run SHAFTTests        # tests — green = "checks: N, failures: 0"
swift run SpritePreview     # sprites -> ~/Downloads/shaft-preview.png
```

Zero third-party dependencies — pure Swift + AppKit and the system `tmux` /
`security` CLIs. Tests run as a plain executable (this project targets
machines without Xcode/XCTest); see [`CLAUDE.md`](CLAUDE.md) for details.

The critter is hand-authored pixel art defined as a grid in
`Sources/SHAFTCore/Sprite.swift` — edit cells there and re-run `SpritePreview`
to iterate. Design notes live in `docs/superpowers/`.

## Status

Working end-to-end: menu bar + desktop pet, live model switching across tmux
sessions, usage gauge, balance line, and the money-bag spend indicator.

Not yet built: a local proxy for a live per-token `$` counter (designed in the
spec under `docs/superpowers/`).
