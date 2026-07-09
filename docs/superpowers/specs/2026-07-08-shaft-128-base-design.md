# SHAFT — 128×128 square redesign (base + all outfits + gauge)

## Goal

Adopt the reshaped SHAFT critter and its full outfit set (drawn at 128×128
in five `*.pixil` files) into the app. One shared square base body; four
model outfits; a money-bag "spending" overlay; and a new heart + progress-bar
usage gauge. Keep the hand-authored char-grid renderer, extended to
multi-color overlays.

## Source art (all share one identical base body)

| Pixil | Model / state | Outfit |
|-------|---------------|--------|
| `SHAFT.pixil` | Opus | crown: yellow + red gem-tips |
| `shaft_sonet.pixil` | Sonnet | headphones: blue band, cups, wire, player |
| `shaft_haiku.pixil` | Haiku | headband: green band + knot-tails |
| `shaft_fable.pixil` | Fable | wizard hat: blue, scattered yellow stars |
| `money_bag_shaft.pixil` | spending | brown sack + yellow `$` (no headwear) |

## Decisions (locked)

- Grid: **20×20 square** (`dim = 20`). Char-grid kept.
- Outfits: **char-grid with an expanded, per-outfit color palette** — fine
  details (wire, stars, player) are faithful approximations, not pixel-exact.
- Usage: **heart + horizontal progress bar** replaces the grey body-fill.
  The body renders solid; the bar shows live usage % below the critter.
- Body color: **terracotta kept** (the vivid orange is only the pixil
  palette). See Open Points — worth a second look now all art is orange.

## Renderer constraint

`Critter.swift` assumes a square `dim × dim` grid (`paint()` flips y with
`n - 1 - r`, `cell = size / dim`). Every critter grid — `base` + all
overlays — MUST be exactly 20 rows.

## A. Base grid (20×20)

Rows 0–2 empty (crown/hat zone); head 3–5; eyes 6–7; ear bulge row 8; torso
9–13; four legs 14–19. Legend: `.` empty · `B` body · `K` eye.

```
....................
....................
....................
..BBBBBBBBBBBBBBBB..
..BBBBBBBBBBBBBBBB..
..BBBBBBBBBBBBBBBB..
..BBKKBBBBBBBBKKBB..
..BBKKBBBBBBBBKKBB..
BBBBBBBBBBBBBBBBBBBB
..BBBBBBBBBBBBBBBB..
..BBBBBBBBBBBBBBBB..
..BBBBBBBBBBBBBBBB..
..BBBBBBBBBBBBBBBB..
..BBBBBBBBBBBBBBBB..
..BB..BB....BB..BB..
..BB..BB....BB..BB..
..BB..BB....BB..BB..
..BB..BB....BB..BB..
..BB..BB....BB..BB..
..BB..BB....BB..BB..
```

The body is a single solid color (no depleted/grey rows).

## B. Outfit model (generalized)

Replace the single-accent model with per-outfit palettes.

```swift
// SHAFTCore — color keys (no AppKit dependency here)
public enum SpriteInk {
    case body, eye, yellow, red, blue, green, hatBlue, star, brown, white
}
public struct OutfitSprite {          // one overlay
    public let rows: [String]         // 20 rows
    public let ink: [Character: SpriteInk]
}
```

`CritterSprite.outfits: [Outfit: OutfitSprite]` and
`CritterSprite.moneyBag: OutfitSprite`. `Critter.swift` maps `SpriteInk` →
`NSColor` in one switch and drops `outfitAccent`/`outfitAccent2`.

Per-outfit symbols (exact grids quantized from the pixils, then hand-tuned
in `SpritePreview` during implementation):

- **crown** `A`→yellow, `G`→red — worked example:
  ```
  .....G...G...G......
  ....AAA.AAA.AAA.....
  ....AAAAAAAAAAAA....
  ```
  (rows 3–19 empty)
- **headphones** `H`→blue (band + side cups), `P`→white (player), short
  `H` wire — approximated.
- **headband** `N`→green (forehead band + knot-tails on the right).
- **wizard** `Z`→hatBlue (draped hat), `S`→yellow (a handful of stars).
- **moneyBag** `M`→brown (sack), `D`→yellow (`$`), lower-right of the body.

## C. Usage gauge (heart + bar) — new, code-drawn

Dynamic, so drawn programmatically (not a static grid):

- red heart bitmap (~5×5) at the left,
- a bar: outlined rect, filled left-to-right to `usage` (orange fill, white
  remainder),
- `NN%` via a tiny 3×5 pixel-digit font (`0–9` + `%`) at the right.

Rendered **below the critter in the floating pet window**, which grows to fit
(≈96 wide × ≈116 tall). The **menu-bar icon stays critter-only** (too small
for a bar); usage there remains a menu text line. `depletedColor` /
`greyFromRow` / body-fill logic is removed.

## Decomposition (one plan, three phases)

1. Base + `dim=20` + solid body (remove grey-fill).
2. Outfit model generalization + four outfit grids + money bag.
3. Usage gauge + pet-window layout + menu-bar/menu wiring.

## Testing / verification

- `swift build`; `swift run SpritePreview` → Read the PNG, compare to each
  pixil, iterate grids.
- `swift run SHAFTTests` → GREEN `checks: N, failures: 0`. Update
  `CritterTests` (drop accent/gauge-row assertions; add `SpriteInk`
  mapping + gauge % checks). Bump default `image()` size to `dim` so the
  menu-bar icon (20 cells) isn't clipped.

## Open points for review

- **Body color**: every pixil is orange `#ff7e00`; keeping terracotta means
  the app matches none of the new art. Reconsider?
- **Fable extras**: the wizard pixil also has yellow leg-bands + a yellow
  bar fill + a face-wisp. Include, or hat-only for now?
- **Live digits** in the gauge: include the 3×5 font, or bar + heart only?

## Conventions

Files ≤300 lines, lines ≤80 cols, Markdown ≤150. Zero new dependencies.
