# Gauge Metric Modes Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use
> superpowers:subagent-driven-development (recommended) or
> superpowers:executing-plans to implement this plan task-by-task.
> Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** The pet gauge defaults to the 5-hour session metric;
right-clicking the gauge strip cycles session → weekly → credits.

**Architecture:** A pure `GaugeMetric`/`GaugeReading` layer in
SHAFTCore resolves metric + `UsageSnapshot` into icon/text/known.
`GaugeRenderer` draws any reading. The AppKit shell stores the last
snapshot plus the current metric and wires a gauge-only right-click
handler; the critter's right-click menu is untouched.

**Tech Stack:** Swift 5.9, AppKit, zero third-party dependencies.

**Spec:** `docs/superpowers/specs/2026-07-15-gauge-metric-modes-design.md`

## Global Constraints

- Swift 5.9 / macOS 13; Apple frameworks only, no third-party deps.
- Source lines ≤ 80 columns; check with `grep -n '.\{81,\}' <file>`
  (must print nothing).
- Source file ≤ 300 lines; function ≤ 50 lines; Markdown ≤ 150 lines.
- Every function opens with a doc comment (what/why, not syntax).
- **No XCTest on this machine.** Tests are plain functions run via
  `swift run SHAFTTests`. GREEN = the final output line reads
  `checks: N, failures: 0`. Read that line; a piped `$?` reports the
  pipe's status, not the program's.
- New test suites: add a `run<Suite>()` function in
  `Sources/SHAFTTests/` and call it in
  `Sources/SHAFTTests/main.swift` above `xctReport()`.

## File Map

| File | Change |
|------|--------|
| `Sources/SHAFTCore/Usage.swift` | Add public `Window` init |
| `Sources/SHAFTCore/GaugeMetric.swift` | Create: metric + reading |
| `Sources/SHAFTCore/PixelFont.swift` | Add `W`, `$` icons; `.` glyph |
| `Sources/SHAFTCore/Gauge.swift` | Draw readings; legacy wrapper |
| `Sources/SHAFT/PetWindow.swift` | Gauge right-click handler |
| `Sources/SHAFT/StatusController.swift` | Snapshot + metric wiring |
| `Sources/SHAFTTests/GaugeMetricTests.swift` | Create: new suite |
| `Sources/SHAFTTests/PixelFontTests.swift` | New glyph checks |
| `Sources/SHAFTTests/GaugeTests.swift` | Reading-image checks |
| `Sources/SHAFTTests/main.swift` | Register new suite |

## Tasks

One file per task (150-line Markdown limit):

1. `...-task1.md` — `GaugeMetric` cycling (SHAFTCore, TDD).
2. `...-task2.md` — `GaugeReading` resolution + `Window` init
   (SHAFTCore, TDD).
3. `...-task3.md` — `PixelFont` glyphs `W`, `$`, `.` (TDD).
4. `...-task4.md` — `GaugeRenderer` draws a `GaugeReading`; old API
   becomes a wrapper (TDD).
5. `...-task5.md` — `PetView`/`PetWindow` right-click handler
   (compile-verified UI).
6. `...-task6.md` — `StatusController` snapshot/metric/menu wiring +
   manual check (UI).

Tasks 1–4 are pure SHAFTCore; task 4 needs 2 and 3, task 6 needs all
earlier tasks. Execute in order.
