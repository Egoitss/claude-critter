# Claude Critter — macOS usage widget with live model switching

- **Date:** 2026-07-04
- **Status:** Approved design, pre-implementation
- **Working name:** claude-critter (mascot name TBD)

## Concept

A macOS menu-bar app whose icon is a pixel critter. The critter fuses the
two signals the widget must convey:

- **Outfit = active model** (which model Claude Code is on)
- **Mood = usage** (how much of the rate-limit budget is left)

A later phase adds an optional always-on-top desktop-pet version of the same
character.

## Goals

- Show live Claude plan usage (5-hour window, weekly quota, overage) like
  claude-meter.
- Switch the model of the *running* Claude Code session from the widget.
- Make model + usage readable at a glance through the character.

## Non-goals

- No WidgetKit desktop widget (sandboxed; can't poll or run shell commands).
- No per-model usage breakdown (the API reports aggregate usage).
- No control of non-tmux sessions in the MVP.

## Architecture (three modules)

1. **Meter** — reads the Claude Code OAuth token from macOS Keychain
   (service `Claude Code-credentials`) via `/usr/bin/security`, then polls
   `https://api.anthropic.com/api/oauth/usage` (and `/profile`). Adaptive
   polling: faster as usage nears a limit. This is claude-meter's proven
   mechanism, re-implemented (not forked).
2. **Model control** — the switcher. Sends
   `tmux send-keys -t <target> '/model <id>' Enter` to the session. Reads
   `tmux capture-pane -p` to confirm the switch and detect manual drift.
3. **Character** — renders the critter from (model, mood) in the menu bar
   and, in phase 2, the floating pet window.

## Tech stack

Native **Swift / AppKit**. `NSStatusItem` for the menu bar; a borderless,
always-on-top `NSWindow` for the phase-2 pet; frame-swap sprite animation.
Chosen because the animated pet + sprite rendering is the bulk of the new
work and is far simpler in AppKit than in claude-meter's Rust. The meter
port is small (one Keychain read + one HTTPS call).

## The tmux bridge (live switching)

There is no official way to retarget a running Claude Code session's model.
tmux is the bridge that works identically across Terminal.app and VS Code's
integrated terminal (both target platforms), because it sits under whichever
front-end attaches.

- User runs Claude inside a tmux session (MVP: named `claude`, configurable
  as `session:window.pane`).
- Switch: `tmux send-keys -t claude '/model sonnet' Enter`.
- Confirm / detect drift: parse `tmux capture-pane -p -t claude`.
- Idle gating: before sending, check the pane shows the input prompt (not a
  streaming response) so the command lands as a command, not queued text.

## Character system

Layered assets — composite at runtime instead of drawing every combination:

- **4 mood base sprites:** fresh (0–50%), focused (50–80%), tired (80–100%),
  asleep (rate-limited).
- **4 outfit overlays:** crown (Opus), headphones (Sonnet), headband (Haiku),
  wizard hat (Fable).
- Menu bar shows silhouette + accent color at ~18px; the dropdown panel and
  the desktop pet show the full detailed outfit.
- Colored (non-template) `NSImage`; draw light and dark variants since it
  won't auto-tint.

## Model mapping

| Outfit | Model | `/model` argument (confirm in impl) |
|---|---|---|
| Crown | Opus 4.8 | `opus` / `claude-opus-4-8` |
| Headphones | Sonnet 5 | `sonnet` / `claude-sonnet-5` |
| Headband | Haiku 4.5 | `haiku` / `claude-haiku-4-5-20251001` |
| Wizard hat | Fable 5 | `claude-fable-5` |

## Phasing

- **Phase 1 (MVP):** menu-bar critter, usage bars, tmux switcher, mood +
  outfit swapping. Target: ~a long weekend.
- **Phase 2:** toggleable floating desktop pet — same character, idle
  animations (blink, wander, nap when rate-limited), right-click to switch.

## Risks / open questions

- **Session discovery:** MVP assumes tmux session `claude`; later, auto-detect
  the pane running a `claude` process.
- **Switch while streaming:** confirm whether Claude queues or drops an
  injected `/model` mid-response; gate on idle if it drops.
- **Manual drift:** if the user types `/model` directly, re-read
  `capture-pane` so the outfit stays honest.
- **Exact `/model` strings:** verify aliases against the installed Claude
  Code version during implementation.
- **Distribution:** signing/notarization for a shippable `.app` (later).

## Success criteria

- Menu bar shows correct 5h/weekly usage within one poll of claude.ai.
- Clicking a model in the widget changes the live tmux session's model, and
  the outfit updates to match.
- Mood reflects usage tier without manual refresh.
