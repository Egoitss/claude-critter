# CLAUDE.md — SHAFT

Guidance for Claude Code working in this repo.

SHAFT is a macOS menu-bar app + floating desktop pet: a pixel critter whose
outfit shows the active Claude model, with a heart + progress-bar gauge below
it showing plan usage, and who holds a money bag when paid credits are being
spent. It switches the model of a **running** Claude Code session via a tmux
bridge.

## Build / run / test

```bash
swift build                 # compile everything
swift run SHAFTTests        # run the test suite (see note below)
swift run SHAFT             # launch the menu-bar app + pet (blocking)
swift run SpritePreview     # render sprites -> ~/Downloads/shaft-preview.png
```

**IMPORTANT — no XCTest here.** This machine has Command Line Tools only (no
Xcode), so `swift test`, XCTest, and swift-testing are unavailable. Tests run
as a plain executable via `SHAFTTestKit` (XCTest-named assert functions) and
`swift run SHAFTTests`. GREEN = the final line reads `checks: N, failures: 0`.
Read that line — a piped `$?` reports the pipe's status, not the program's.
To add a test: put a `run<Suite>()` function in `Sources/SHAFTTests/` and
register it in `Sources/SHAFTTests/main.swift` above `xctReport()`.

## Layout

- `Sources/SHAFTCore/` — headless, unit-tested library. All I/O sits behind
  protocols (`CommandRunner`, `HTTPFetching`, `TokenSource`) so logic is
  tested with fakes. Key files: `Model` (model/outfit enums), `Usage` +
  `Balance` (API parsing + money line), `Keychain` + `Command` + `Tmux`
  (the tmux bridge + token read), `UsageClient` (HTTP), `Critter` + `Sprite`
  (pixel rendering).
- `Sources/SHAFT/` — thin AppKit shell: `main`, `AppDelegate`,
  `StatusController` (NSStatusItem + menu + refresh loop), `PetWindow`
  (floating pet).
- `Sources/SHAFTTestKit/` — the XCTest-compatible assert shim.
- `Sources/SpritePreview/` — dev tool: renders the critter to a PNG so you
  can inspect it (you can Read PNGs — use this instead of guessing).
- `docs/superpowers/` — the design spec and implementation plan.

## The pixel critter

The sprite is a hand-authored **20×20 square** grid of strings in
`Sprite.swift`. The `base` uses `.` empty, `B` body, `K` eye. Each outfit is
an `OutfitSprite` (a 20-row grid + a `Character -> SpriteInk` ink map), so an
overlay picks its own colors (e.g. crown `A`→yellow, `G`→red gem). The money
bag is another `OutfitSprite`. `Critter.swift` maps `SpriteInk` → `NSColor`
and renders with **integer cell size and anti-aliasing off** (crisp pixels;
never scale a fractional cell factor). The body renders a single solid color.
Every grid MUST be exactly `dim` (=20) rows of 20 chars (`gridsAreSquare()`),
since `paint()` flips y by `dim`. To reshape the critter, edit cells in
`Sprite.swift` and re-run SpritePreview.

Plan usage is shown by a separate heart + progress-bar gauge (`Gauge.swift`,
digits via `PixelFont.swift`) drawn below the critter in the pet window — not
by shading the body.

## Conventions (enforced)

- Swift 5.9 / macOS 13; **zero third-party dependencies** — Apple frameworks
  and the system `tmux` / `security` CLIs only.
- Source file ≤300 lines; function ≤50 lines; line ≤80 columns; Markdown
  ≤150 lines. Check widths with `grep -n '.\{81,\}'`.
- TDD where practical (logic in SHAFTCore); the AppKit shell is
  compile-verified + manually checked (it's UI).

## Runtime model (how switching works)

Claude Code must run **inside a tmux session** (default name `claude`). SHAFT
sends `tmux send-keys -t <session> '/model <arg>' Enter`, gated on the pane
not showing `esc to interrupt` (busy). Run SHAFT itself in a **normal**
terminal, not inside that tmux session — it auto-excludes its own session
from targets, but keep them separate. See `README.md` for the exact setup.

## Data source

Usage/balance come from `https://api.anthropic.com/api/oauth/usage`, authed
with the Claude Code OAuth token read from the Keychain service
`Claude Code-credentials` (JSON path `claudeAiOauth.accessToken`).
`utilization` is a **percentage (0–100)**; money lives in the `spend` block
as minor units (`amount_minor` / 10^`exponent`). Verify shapes with a live
call before assuming.

## Not built yet

Phase 3 (a local streaming proxy for a live per-token `$` counter) is
designed in the spec but not implemented. Minor cleanup: `ExtraUsage` in
`Usage.swift` and the `Mood` enum in `Model.swift` are now vestigial.
