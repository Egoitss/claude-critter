# Task 2: Square base, solid orange body, render swap

[← Phase 1](2026-07-08-shaft-redesign-phase1.md) · Global Constraints apply.

**Files:**
- Modify: `Sources/SHAFTCore/Model.swift` (`Outfit: CaseIterable`)
- Modify: `Sources/SHAFTCore/Sprite.swift` (full rewrite)
- Modify: `Sources/SHAFTCore/Critter.swift` (render internals)
- Test: `Sources/SHAFTTests/CritterTests.swift` (rewrite)

**Interfaces:**
- Consumes: `SpriteInk`, `OutfitSprite`, `color(for:)` (Task 1).
- Produces: `CritterSprite.dim == 20`, `.base`, `.outfits[.crown]`,
  `.moneyBag`; `CritterRenderer.dimension`, `.gridsAreSquare()`;
  `image(outfit:spending:size:)` (solid body, no `usage` fill).

- [ ] **Step 1: Rewrite `CritterTests.swift`** (drops removed APIs):

```swift
import AppKit
import SHAFTCore
import SHAFTTestKit

func runCritterTests() {
    let r = CritterRenderer()
    let img = r.image(outfit: .crown, size: 40)
    XCTAssertEqual(img.size, NSSize(width: 40, height: 40), "size honored")
    XCTAssertEqual(r.dimension, 20, "square grid is 20")
    XCTAssertTrue(r.gridsAreSquare(), "every grid is 20x20")
    XCTAssertEqual(CritterRenderer().color(for: .body),
        CritterRenderer().color(for: .body), "body color stable")
}
```

- [ ] **Step 2: Run — expect FAIL/compile error** (`dimension`,
  `gridsAreSquare`, new `image` signature missing): `swift run SHAFTTests`.

- [ ] **Step 3: `Model.swift`** — make `Outfit` iterable:

```swift
public enum Outfit: CaseIterable {
    case crown, headphones, headband, wizardHat
}
```

- [ ] **Step 4: Replace `Sprite.swift` entirely:**

```swift
import Foundation

// Hand-authored 20x20 square critter. Rows top->bottom. Legend: '.' empty,
// 'B' body, 'K' eye. Overlays (OutfitSprite) carry their own inks.
private let e = "...................."   // one empty 20-wide row

enum CritterSprite {
    static let dim = 20

    static let base: [String] = [
        e, e, e,
        "..BBBBBBBBBBBBBBBB..",
        "..BBBBBBBBBBBBBBBB..",
        "..BBBBBBBBBBBBBBBB..",
        "..BBKKBBBBBBBBKKBB..",
        "..BBKKBBBBBBBBKKBB..",
        "BBBBBBBBBBBBBBBBBBBB",
        "..BBBBBBBBBBBBBBBB..",
        "..BBBBBBBBBBBBBBBB..",
        "..BBBBBBBBBBBBBBBB..",
        "..BBBBBBBBBBBBBBBB..",
        "..BBBBBBBBBBBBBBBB..",
        "..BB..BB....BB..BB..",
        "..BB..BB....BB..BB..",
        "..BB..BB....BB..BB..",
        "..BB..BB....BB..BB..",
        "..BB..BB....BB..BB..",
        "..BB..BB....BB..BB..",
    ]

    static let outfits: [Outfit: OutfitSprite] = [
        .crown: OutfitSprite(
            rows: [".....G...G...G......",
                   "....AAA.AAA.AAA.....",
                   "....AAAAAAAAAAAA...."]
                + Array(repeating: e, count: 17),
            ink: ["A": .yellow, "G": .red]),
    ]

    static let moneyBag = OutfitSprite(
        rows: Array(repeating: e, count: 10)
            + ["................MM..",
               "...............MMMM.",
               "...............MDDM.",
               "...............MDDM.",
               "...............MMMM."]
            + Array(repeating: e, count: 5),
        ink: ["M": .brown, "D": .yellow])
}
```

- [ ] **Step 5: Update `Critter.swift`.** Keep `color(for:)` (Task 1).
  DELETE `bodyColor`, `depletedColor`, `moneyGold`, `moneyDark`,
  `outfitAccent`, `greyFromRow`, `bodyRowRange`. Replace `image` +
  `drawCritter` + `paint` and ADD `dimension` + `gridsAreSquare` — full
  source in [Critter render changes](
  2026-07-08-shaft-redesign-phase1-task2-critter.md).

- [ ] **Step 6:** Fix any callers of the old `image(usage:…)` in
  `StatusController.swift`/`SpritePreview/main.swift` — drop the `usage:`
  argument. `grep -rn "image(usage" Sources`.
- [ ] **Step 7: Run — expect PASS:** `swift run SHAFTTests` → `failures: 0`.
- [ ] **Step 8: Visual check:** `swift run SpritePreview`; Read
  `~/Downloads/shaft-preview.png` — orange square body, wide-set eyes, ear
  bulge, 4 legs; Opus shows the gem-tipped crown; spending shows the `$`
  sack lower-right.
- [ ] **Step 9: Commit:** `git add -A && git commit -m "feat: 20x20 square
  base, solid orange body, OutfitSprite render"`
