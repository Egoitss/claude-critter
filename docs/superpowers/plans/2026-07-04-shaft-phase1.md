# SHAFT Phase 1 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use
> superpowers:subagent-driven-development (recommended) or
> superpowers:executing-plans to implement this plan task-by-task. Steps use
> checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ship the SHAFT menu-bar MVP: a pixel critter whose outfit shows the
active Claude model and whose mood shows plan usage, with live model switching
via tmux and an optional plan-overage EUR line.

**Architecture:** Swift Package with a headless, unit-tested `SHAFTCore`
library (Keychain, usage API, tmux bridge, mappings, renderer) and a thin
AppKit `SHAFT` executable (NSStatusItem shell wired to Core). All I/O sits
behind protocols (`CommandRunner`, `HTTPFetching`, `TokenSource`) so logic is
tested with fakes.

**Tech Stack:** Swift 5.9, AppKit, Foundation, XCTest. No third-party
dependencies. Data from macOS Keychain + `api.anthropic.com/api/oauth/usage`.
Model switching via the `tmux` CLI.

## Global Constraints

- Swift tools 5.9+, deployment target macOS 13.
- **No third-party dependencies** — Apple frameworks + the system `tmux`/
  `security` CLIs only.
- Source file ≤300 lines; function ≤50 lines; line ≤80 columns.
- Markdown file ≤150 lines.
- TDD: failing test first; commit after each green task.
- Keychain service string is exactly `Claude Code-credentials`; token lives at
  JSON path `claudeAiOauth.accessToken`.
- Usage request headers: `Authorization: Bearer <token>`,
  `Accept: application/json`, `anthropic-version: 2023-06-01`.
- Sprites are programmatic placeholders in Phase 1; real SHAFT pixel art
  replaces the draw functions later (same signatures).

---

## File structure

```
Package.swift
Sources/SHAFTCore/
  Model.swift        ClaudeModel, Outfit, Mood enums + mappings
  Usage.swift        UsageSnapshot/Window/ExtraUsage + JSON decode
  Balance.swift      BalanceLine.resolve + display string
  Keychain.swift     TokenSource, credentials JSON parse, security CLI
  Command.swift      CommandRunner protocol + ProcessCommandRunner
  Tmux.swift         TmuxController (has/start/capture/send/idle/current)
  UsageClient.swift  HTTPFetching, UsageClient.fetch, pollInterval
  Critter.swift      CritterRenderer (NSImage compositing, placeholders)
Sources/SHAFT/
  main.swift         NSApplication .accessory bootstrap
  AppDelegate.swift  builds StatusController
  StatusController.swift  NSStatusItem + menu + refresh loop
Tests/SHAFTCoreTests/
  ModelTests.swift UsageTests.swift BalanceTests.swift
  KeychainTests.swift TmuxTests.swift UsageClientTests.swift
  CritterTests.swift
```

## Tasks

Each task is a separate file (kept ≤150 lines):

1. [Package scaffold + smoke test](2026-07-04-shaft-phase1/01-scaffold.md)
2. [Model / Outfit / Mood mappings](2026-07-04-shaft-phase1/02-model.md)
3. [Usage parsing](2026-07-04-shaft-phase1/03-usage.md)
4. [Balance line resolution](2026-07-04-shaft-phase1/04-balance.md)
5. [Keychain token source](2026-07-04-shaft-phase1/05-keychain.md)
6. [CommandRunner + tmux basics](2026-07-04-shaft-phase1/06-tmux.md)
7. [Model switch + idle gate](2026-07-04-shaft-phase1/07-switch.md)
8. [UsageClient + adaptive poll](2026-07-04-shaft-phase1/08-client.md)
9. [Critter renderer](2026-07-04-shaft-phase1/09-critter.md)
10. [AppKit shell + manual verification](2026-07-04-shaft-phase1/10-shell.md)

## Self-Review

- **Spec coverage:** Meter → Tasks 3,5,8,10. Model control → Tasks 2,6,7,10.
  Character → Tasks 2,9,10. Balance line → Task 4 (+8,10). Hybrid tmux
  session → Tasks 6,10. Every spec module maps to a task.
- **Placeholders:** sprites are intentional programmatic placeholders with
  final signatures; no code placeholders remain.
- **Type consistency:** `ClaudeModel.modelArg`, `UsageSnapshot.worstFraction`,
  `BalanceLine.resolve`, `TmuxController.send(model:)`, `UsageClient.fetch()`
  are defined once and reused verbatim downstream.

## Execution handoff

After review, choose subagent-driven (fresh agent per task) or inline
execution. Phase 2 (desktop pet) and Phase 3 (proxy) are separate plans.
