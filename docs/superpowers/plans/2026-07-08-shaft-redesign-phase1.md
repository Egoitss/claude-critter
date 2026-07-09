# Phase 1 — Foundation (Tasks 1–2)

[← Plan index](2026-07-08-shaft-redesign.md). Global Constraints there apply
to every task.

---

## Task 1: Sprite ink + outfit types

**Files:**
- Create: `Sources/SHAFTCore/SpriteInk.swift`
- Modify: `Sources/SHAFTCore/Critter.swift` (add `color(for:)`)
- Test: `Sources/SHAFTTests/SpriteInkTests.swift`, register in `main.swift`

**Interfaces:**
- Produces: `enum SpriteInk { body,eye,yellow,red,blue,white,green,hatBlue,
  brown }`; `struct OutfitSprite { let rows:[String]; let ink:[Character:
  SpriteInk] }`; `CritterRenderer.color(for: SpriteInk) -> NSColor`.

- [ ] **Step 1: Write the failing test** — `SpriteInkTests.swift`:

```swift
import AppKit
import SHAFTCore
import SHAFTTestKit

func runSpriteInkTests() {
    let r = CritterRenderer()
    XCTAssertNotEqual(r.color(for: .body), r.color(for: .eye),
        "body vs eye differ")
    XCTAssertEqual(r.color(for: .eye), NSColor.black, "eye is black")
    let all: [SpriteInk] = [.body,.yellow,.red,.blue,.green,.hatBlue,.brown]
    for a in all where a != .body {
        XCTAssertNotEqual(r.color(for: a), r.color(for: .body),
            "\(a) differs from body")
    }
}
```

Register it in `Sources/SHAFTTests/main.swift` (add `runSpriteInkTests()`
above `xctReport()`).

- [ ] **Step 2: Run — expect FAIL** (`color(for:)` undefined):
`swift run SHAFTTests` → build error / fail.

- [ ] **Step 3: Create `SpriteInk.swift`:**

```swift
import Foundation

// Color keys for sprite cells; Critter maps them to NSColor. Keeping keys
// AppKit-free lets the grids stay pure data.
public enum SpriteInk {
    case body, eye, yellow, red, blue, white, green, hatBlue, brown
}

// One overlay: a 20-row grid plus the ink each symbol paints.
public struct OutfitSprite {
    public let rows: [String]
    public let ink: [Character: SpriteInk]
    public init(rows: [String], ink: [Character: SpriteInk]) {
        self.rows = rows
        self.ink = ink
    }
}
```

- [ ] **Step 4: Add `color(for:)` to `CritterRenderer`** (in `Critter.swift`):

```swift
    public func color(for ink: SpriteInk) -> NSColor {
        func c(_ r: Double, _ g: Double, _ b: Double) -> NSColor {
            NSColor(srgbRed: r, green: g, blue: b, alpha: 1)
        }
        switch ink {
        case .body:    return c(1.0, 0.494, 0.0)
        case .eye:     return .black
        case .yellow:  return c(1.0, 0.949, 0.0)
        case .red:     return c(0.929, 0.110, 0.141)
        case .blue:    return c(0.184, 0.212, 0.600)
        case .white:   return .white
        case .green:   return c(0.133, 0.694, 0.298)
        case .hatBlue: return c(0.302, 0.427, 0.953)
        case .brown:   return c(0.612, 0.353, 0.235)
        }
    }
```

- [ ] **Step 5: Run — expect PASS:** `swift run SHAFTTests` → `failures: 0`.
- [ ] **Step 6: Commit:** `git add -A && git commit -m "feat: SpriteInk +
  OutfitSprite types with color mapping"`

---

## Task 2: Square base, solid orange body, render swap

Rewrites the sprite data + render path. Delivers the new orange square
critter with the **crown** and **money-bag**; other outfits appear in
Phase 2. See [Task 2 detail](2026-07-08-shaft-redesign-phase1-task2.md).
