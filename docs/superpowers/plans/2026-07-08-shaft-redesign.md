# SHAFT 128×128 Redesign Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use
> superpowers:subagent-driven-development (recommended) or
> superpowers:executing-plans to implement this plan task-by-task. Steps use
> checkbox (`- [ ]`) syntax for tracking.

**Goal:** Adopt the reshaped square critter, all four model outfits, the
money-bag overlay, and a heart + progress-bar usage gauge.

**Architecture:** Keep the hand-authored char-grid renderer. Generalize
outfits from a single accent color to per-outfit color palettes
(`OutfitSprite`). Replace the grey body-fill usage cue with a code-drawn
heart + bar + `NN%` gauge below the critter.

**Tech Stack:** Swift 5.9, AppKit, macOS 13. Zero third-party deps.

**Spec:** `docs/superpowers/specs/2026-07-08-shaft-128-base-design.md`

## Global Constraints

- Swift 5.9 / macOS 13; **zero third-party dependencies** (Apple frameworks
  + system `tmux`/`security` only).
- Source file ≤300 lines; function ≤50 lines; line ≤80 columns; Markdown
  ≤150 lines. Check widths: `grep -n '.\{81,\}' <file>`.
- **No XCTest.** Tests are a plain executable via `SHAFTTestKit`. Run:
  `swift run SHAFTTests`. GREEN = final line `checks: N, failures: 0` (read
  the line; `$?` reports the pipe, not the program). Add a suite by writing
  `run<Suite>()` in `Sources/SHAFTTests/` and registering it in
  `Sources/SHAFTTests/main.swift` above `xctReport()`.
- **Square-grid invariant:** every critter grid (`base`, all `outfits`,
  `moneyBag`) MUST be exactly `CritterSprite.dim` (=20) rows of 20 chars.
- Visual check: `swift run SpritePreview` writes
  `~/Downloads/shaft-preview.png`; Read it (you can view PNGs).

## Phases

1. **[Phase 1 — Foundation](2026-07-08-shaft-redesign-phase1.md)** —
   `SpriteInk`/`OutfitSprite` types; new 20×20 base; solid orange body;
   render swap; crown + money-bag. (Tasks 1–2)
2. **[Phase 2 — Outfits](2026-07-08-shaft-redesign-phase2.md)** —
   headphones, headband, wizard (+ leg-bands/wisp). (Tasks 3–5)
3. **[Phase 3 — Gauge](2026-07-08-shaft-redesign-phase3.md)** — pixel font +
   heart; gauge renderer; pet-window + status wiring. (Tasks 6–8)

## File map

- `Sources/SHAFTCore/SpriteInk.swift` — **new**: `SpriteInk`, `OutfitSprite`.
- `Sources/SHAFTCore/Sprite.swift` — new base + all overlay grids.
- `Sources/SHAFTCore/Critter.swift` — ink→NSColor, solid body, overlay paint.
- `Sources/SHAFTCore/PixelFont.swift` — **new**: 3×5 digits + heart bitmap.
- `Sources/SHAFTCore/Gauge.swift` — **new**: heart + bar + `NN%` renderer.
- `Sources/SHAFT/PetWindow.swift` — stack critter + gauge; grow window.
- `Sources/SHAFT/StatusController.swift` — model→fill color; icon size.
- `Sources/SpritePreview/main.swift` — preview new set + gauge.
- `Sources/SHAFTTests/*` — new/updated suites.
