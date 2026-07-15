# Task 3: PixelFont glyphs W, $, . (SHAFTCore)

**Files:**
- Modify: `Sources/SHAFTCore/PixelFont.swift`
- Modify: `Sources/SHAFTTests/PixelFontTests.swift`

**Interfaces:**
- Consumes: existing `PixelFont` (`heart`, `glyphs`, `glyph(_:)`,
  `text(_:)`).
- Produces: `PixelFont.weekly` and `PixelFont.dollar` (5×5 icon
  bitmaps, same `[String]` shape as `PixelFont.heart`) and a 1-wide
  `"."` glyph so `text("16.50")` renders. Task 4 relies on `weekly`
  and `dollar`.

- [ ] **Step 1: Write the failing test**

Append inside `runPixelFontTests()` in
`Sources/SHAFTTests/PixelFontTests.swift`:

```swift
    XCTAssertEqual(PixelFont.weekly.count, 5, "W icon has 5 rows")
    for row in PixelFont.weekly {
        XCTAssertEqual(row.count, 5, "W icon rows are 5 wide")
    }
    XCTAssertEqual(PixelFont.dollar.count, 5, "$ icon has 5 rows")
    for row in PixelFont.dollar {
        XCTAssertEqual(row.count, 5, "$ icon rows are 5 wide")
    }
    XCTAssertEqual(PixelFont.glyph(".")[4], "#",
        "dot is 1 wide and sits on the baseline")
    XCTAssertEqual(PixelFont.text("6.50")[4], "###.#.###.###",
        "digits join around the 1-wide dot with 1-column gaps")
```

- [ ] **Step 2: Run test to verify it fails**

Run: `swift run SHAFTTests`
Expected: compile error — `PixelFont` has no member `weekly`.

- [ ] **Step 3: Write minimal implementation**

In `Sources/SHAFTCore/PixelFont.swift`, add below `heart`:

```swift
    // 5x5 letter W: the weekly-metric icon.
    public static let weekly: [String] = [
        "#...#", "#...#", "#.#.#", "#.#.#", ".#.#.",
    ]
    // 5x5 dollar sign: the credits-metric icon. Column 2 carries
    // the vertical stroke through the S curve.
    public static let dollar: [String] = [
        ".####", "#.#..", ".###.", "..#.#", "####.",
    ]
```

Add to the `glyphs` dictionary (after the `"-"` entry):

```swift
        ".": [".", ".", ".", ".", "#"],
```

- [ ] **Step 4: Run test to verify it passes**

Run: `swift run SHAFTTests`
Expected: final line `checks: N, failures: 0`.

- [ ] **Step 5: Commit**

```bash
git add Sources/SHAFTCore/PixelFont.swift \
  Sources/SHAFTTests/PixelFontTests.swift
git commit -m "feat: PixelFont W and dollar icons, 1-wide dot glyph"
```
