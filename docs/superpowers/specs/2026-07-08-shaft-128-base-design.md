# SHAFT — 128×128 square base redesign

## Goal

Adopt the reshaped SHAFT critter (drawn at 128×128 in `SHAFT.pixil`) as the
new **base** sprite: a square body with wide-set eyes, side ears, four legs,
and a gem-tipped crown. Keep the existing hand-authored char-grid renderer.
Other outfit designs ("the rest") follow later as their own pixil files.

## Scope

In scope now:

- Redraw `CritterSprite.base` to the new square silhouette.
- Grow the grid to a **20×20 square** (`dim = 20`).
- Reposition the `.crown` overlay onto the new head; give it **red
  gem-tips** via a new secondary outfit accent color.
- Repad the other three outfits + the money bag to 20 rows and nudge them
  onto the new body as **functional placeholders** (refined later).

Out of scope (deferred — "rest will follow"):

- Final art for `.headphones`, `.headband`, `.wizardHat`.
- The heart + literal "50%" progress bar shown at the bottom of the pixil.
  Usage stays represented as the grey body-fill gauge.
- Changing the body color. It stays terracotta; the vivid orange is only
  the pixil palette, not the rendered color.

## Renderer constraints (must hold)

From `Critter.swift`: the grid is assumed **square `dim × dim`**. `paint()`
flips y with `n - 1 - r` where `n = dim`, and `cell = size / dim`. Therefore
**every** grid — `base`, all four `outfits`, and `moneyBag` — MUST have
exactly `dim` (=20) rows, or overlays misalign. `bodyRowRange` is computed
dynamically (rows containing `B`/`K`), so the grey usage gauge adapts to the
new shape with no extra work.

## Grid legend

`.` empty · `B` body (usage-colored) · `K` eye (black) · `A` outfit accent
(primary) · `G` outfit gem (secondary accent) · `M`/`D` money bag.

`G` is new. Only the crown uses it today.

## New base grid (20×20)

Rows 0–2 empty (crown/hat zone); head 3–5; eyes 6–7; ear bulge row 8;
torso 9–13; four legs rows 14–19.

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

## Crown overlay (rows 0–2, rest empty)

```
.....G...G...G......
....AAA.AAA.AAA.....
....AAAAAAAAAAAA....
```

`A` → yellow (`outfitAccent(.crown)`), `G` → red gem tips (new secondary).

## Secondary accent color (model change)

Add to `CritterRenderer`:

```swift
// Secondary outfit accent (e.g. crown gems). nil = outfit has none.
public func outfitAccent2(_ o: Outfit) -> NSColor? {
    switch o {
    case .crown: return .systemRed
    default: return nil
    }
}
```

In `drawCritter`, the outfit paint closure maps `A` → `outfitAccent(o)` and
`G` → `outfitAccent2(o)` (skip `G` when nil). No change to `paint()` itself.

## Other overlays (placeholders, 20 rows each)

`.headphones`, `.headband`, `.wizardHat`, and `moneyBag` are repadded to 20
rows and repositioned onto the new head/body so the build renders correctly.
Their art is intentionally rough — refined when the matching pixils arrive.

## Render size (menu-bar icon)

The menu-bar icon renders at the default `size` (currently `18`).
`cell = floor(size / dim)`, so `18 / 20 = 0` → clamps to 1px cells and the
20-cell sprite is clipped by 2px. Fix: bump `image()`'s default `size` to
`CGFloat(CritterSprite.dim)` (=20) so the menu-bar icon fits. The pet
window (96) and `SpritePreview` tile are unaffected.

## Testing / verification

- `swift build` — compiles (grid row-count invariant holds).
- `swift run SpritePreview` → Read `~/Downloads/shaft-preview.png`; confirm
  base + crown match `SHAFT.pixil`. Iterate grids until faithful.
- `swift run SHAFTTests` — GREEN line `checks: N, failures: 0`. No test
  hard-codes `dim`; `CritterTests` asks for an explicit `size: 18` image
  and checks only `img.size`, and the gauge test uses dynamic
  `bodyRowRange` — both stay valid. Add a `G`/`outfitAccent2` assertion.

## Conventions

Files ≤300 lines, lines ≤80 cols. `Sprite.swift` grows but stays under 300.
Zero new dependencies.
