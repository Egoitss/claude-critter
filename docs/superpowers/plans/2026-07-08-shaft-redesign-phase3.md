# Phase 3 — Usage gauge (Tasks 6–8)

[← Plan index](2026-07-08-shaft-redesign.md) · Global Constraints apply.

---

## Task 6: Pixel font (digits + heart)

**Files:** Create `Sources/SHAFTCore/PixelFont.swift`; test
`Sources/SHAFTTests/PixelFontTests.swift` (register in `main.swift`).

**Interfaces:** Produces `PixelFont.heart: [String]`,
`PixelFont.glyph(_:) -> [String]`, `PixelFont.text(_:) -> [String]`.

- [ ] **Step 1: Write failing test** `PixelFontTests.swift`:

```swift
import SHAFTCore
import SHAFTTestKit

func runPixelFontTests() {
    XCTAssertEqual(PixelFont.glyph("5").count, 5, "glyph has 5 rows")
    for row in PixelFont.glyph("5") {
        XCTAssertEqual(row.count, 3, "glyph rows are 3 wide")
    }
    XCTAssertEqual(PixelFont.heart.count, 5, "heart has 5 rows")
    XCTAssertEqual(PixelFont.text("50%").count, 5, "text has 5 rows")
    XCTAssertEqual(PixelFont.text("50%")[0], "###.###.#.#",
        "50% top row: 5 | 0 | %")
}
```

Register `runPixelFontTests()` above `xctReport()` in `main.swift`.

- [ ] **Step 2: Run — expect FAIL:** `swift run SHAFTTests`.
- [ ] **Step 3: Create `PixelFont.swift`:**

```swift
import Foundation

// 3x5 bitmap font + heart for the usage gauge. '#' = an ink pixel.
public enum PixelFont {
    public static let heart: [String] = [
        ".#.#.", "#####", "#####", ".###.", "..#..",
    ]
    static let glyphs: [Character: [String]] = [
        "0": ["###", "#.#", "#.#", "#.#", "###"],
        "1": [".#.", "##.", ".#.", ".#.", "###"],
        "2": ["###", "..#", "###", "#..", "###"],
        "3": ["###", "..#", "###", "..#", "###"],
        "4": ["#.#", "#.#", "###", "..#", "..#"],
        "5": ["###", "#..", "###", "..#", "###"],
        "6": ["###", "#..", "###", "#.#", "###"],
        "7": ["###", "..#", "..#", "..#", "..#"],
        "8": ["###", "#.#", "###", "#.#", "###"],
        "9": ["###", "#.#", "###", "..#", "###"],
        "%": ["#.#", "..#", ".#.", "#..", "#.#"],
    ]
    public static func glyph(_ ch: Character) -> [String] {
        glyphs[ch] ?? ["...", "...", "...", "...", "..."]
    }
    // Glyphs joined left-to-right with a 1-column gap; 5 rows out.
    public static func text(_ s: String) -> [String] {
        var rows = Array(repeating: "", count: 5)
        for (i, ch) in s.enumerated() {
            let g = glyph(ch)
            for r in 0..<5 { rows[r] += (i == 0 ? "" : ".") + g[r] }
        }
        return rows
    }
}
```

- [ ] **Step 4: Run — expect PASS:** `swift run SHAFTTests`; `failures: 0`.
- [ ] **Step 5: Commit:** `git commit -am "feat: 3x5 pixel font + heart"`

---

## Task 7: Gauge renderer

**Files:** Create `Sources/SHAFTCore/Gauge.swift`; test
`Sources/SHAFTTests/GaugeTests.swift` (register in `main.swift`).

**Interfaces:** Produces `GaugeRenderer.percentText(_:) -> String` and
`.image(usage:fill:width:u:) -> NSImage` (height `7*u`).

- [ ] **Step 1: Write failing test** `GaugeTests.swift`:

```swift
import AppKit
import SHAFTCore
import SHAFTTestKit

func runGaugeTests() {
    let g = GaugeRenderer()
    XCTAssertEqual(g.percentText(0), "0%", "zero")
    XCTAssertEqual(g.percentText(0.5), "50%", "half")
    XCTAssertEqual(g.percentText(1), "100%", "full")
    XCTAssertEqual(g.percentText(1.5), "100%", "clamped high")
    let img = g.image(usage: 0.5, fill: .orange, width: 80, u: 4)
    XCTAssertEqual(img.size, NSSize(width: 80, height: 28), "7u tall")
}
```

Register `runGaugeTests()` above `xctReport()` in `main.swift`.

- [ ] **Step 2: Run — expect FAIL:** `swift run SHAFTTests`.
- [ ] **Step 3: Create `Gauge.swift`** — see
  [Gauge.swift source](2026-07-08-shaft-redesign-phase3-gauge.md).
- [ ] **Step 4: Run — expect PASS:** `swift run SHAFTTests`; `failures: 0`.
- [ ] **Step 5: Commit:** `git commit -am "feat: heart + bar + NN% gauge"`

---

## Task 8: Wire the gauge into the pet window

Grows the pet panel, stacks the gauge under the critter, colors the fill by
model, adds a menu usage line, and previews it. See
[Task 8 detail](2026-07-08-shaft-redesign-phase3-task8.md).
