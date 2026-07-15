# Gauge metric modes — design

Date: 2026-07-15
Status: approved

## Problem

The pet gauge renders `UsageSnapshot.worstFraction`, the worse of the
5-hour session and 7-day weekly windows. A fresh session therefore
still shows the weekly number (e.g. `♥ 89%` when the session is
untouched). The user cannot see the session, weekly, and credits
figures separately from the pet.

## Goal

The gauge defaults to the current 5-hour session. Right-clicking the
gauge strip cycles through the available metrics. The critter's
right-click context menu is unchanged.

## Metric modes

Cycle order: session → weekly → credits → session.

1. **Session** (default on launch): red heart + remaining % of the
   5-hour window, e.g. `♥ 100%`.
2. **Weekly**: white `W` glyph + remaining % of the 7-day window,
   e.g. `W 11%`.
3. **Credits**: green `$` glyph + remaining extra-usage dollars with
   two decimals, e.g. `$ 16.50` (limit − used from the `spend`
   block). Skipped in the cycle when `BalanceLine.resolve` is
   `.hidden`, so the cycle never lands on an empty mode.

A metric whose window is missing shows the existing dim `--`
treatment. A fetch that has never succeeded shows `--` as today.

## Components

All logic lives in SHAFTCore and is unit-tested; the AppKit shell
stays thin.

- `GaugeMetric` (new, SHAFTCore): enum `session | weekly | credits`
  with `next(in:)` cycling that skips unavailable modes.
- `GaugeReading` (new, SHAFTCore): pure value type resolving
  metric + `UsageSnapshot` to `(icon, text, color, known)`.
  Percent modes render remaining budget (100 − used); credits mode
  renders remaining dollars.
- `PixelFont`: gains `W`, `$`, and `.` glyphs (5-row bitmaps,
  matching existing digit style).
- `GaugeRenderer`: draws an arbitrary icon glyph + label + colors
  from a `GaugeReading` instead of hard-coding heart + percent.
- `StatusController`: stores the last full `UsageSnapshot` (not one
  collapsed fraction) plus the current `GaugeMetric`; re-renders on
  cycle. Poll interval still keys off `worstFraction`. The menu's
  single "Budget" line splits into "Session: NN% left" and
  "Weekly: NN% left"; the balance line stays.
- `PetView`: optional `onRightClick` handler; when set it replaces
  the default menu behavior. Only the gauge view sets it.

## Error handling

- No snapshot yet / fetch never succeeded: dim heart + `--`.
- Snapshot present but selected window missing: dim icon + `--`.
- Credits mode disappears mid-run (extra usage turned off): the next
  cycle skips it; if currently selected, render falls back to
  session.

## Testing

- SHAFTCore unit tests: `GaugeMetric.next` cycling with and without
  credits; `GaugeReading` resolution for all modes, missing windows,
  and dollar formatting; new `PixelFont` glyph shapes.
- AppKit shell (`StatusController`, `PetWindow`): compile-verified
  and manually checked, per repo convention.

## Out of scope

Persisting the selected metric across launches, menu-bar icon
changes, new settings, and the Phase 3 streaming proxy.
