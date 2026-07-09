# Phase 2 — Outfits (Tasks 3–5)

[← Plan index](2026-07-08-shaft-redesign.md) · Global Constraints apply.
Each task adds one `OutfitSprite` to `CritterSprite.outfits` in
`Sources/SHAFTCore/Sprite.swift`, asserts it exists, and visually verifies.

---

## Task 3: Headphones (Sonnet)

**Files:** Modify `Sprite.swift`, `Critter.swift`, `CritterTests.swift`.

**Interfaces:** Produces `CritterRenderer.hasOutfit(_:)` and
`outfits[.headphones]`.

- [ ] **Step 1:** Add to `runCritterTests()` (CritterTests.swift):
  `XCTAssertTrue(r.hasOutfit(.headphones), "headphones present")`
- [ ] **Step 2:** Add to `CritterRenderer` (Critter.swift):

```swift
    public func hasOutfit(_ o: Outfit) -> Bool {
        CritterSprite.outfits[o] != nil
    }
```

- [ ] **Step 3: Run — expect FAIL** (`hasOutfit` false):
  `swift run SHAFTTests`.
- [ ] **Step 4:** Add to the `outfits` dictionary in `Sprite.swift`:

```swift
        .headphones: OutfitSprite(rows: [
            e,
            "..HHHHHHHHHHHHHHHH..",
            ".HH..............HH.",
            ".H................H.",
            ".H................H.",
            ".H................H.",
            "HHH..............HHH",
            "HHH..............HHH",
            "HHH..............HHH",
            ".HH..............HH.",
            e,
            ".................H..",
            "...............HP...",
            "..............PPP...",
            "..............PPP...",
            e, e, e, e, e,
        ], ink: ["H": .blue, "P": .white]),
```

- [ ] **Step 5: Run — expect PASS:** `swift run SHAFTTests`; `failures: 0`.
- [ ] **Step 6: Visual:** `swift run SpritePreview`; Read the PNG — Sonnet
  shows a blue band, side ear-cups, wire to a white player.
- [ ] **Step 7: Commit:** `git commit -am "feat: headphones outfit (Sonnet)"`

---

## Task 4: Headband (Haiku)

**Files:** Modify `Sprite.swift`, `CritterTests.swift`.

- [ ] **Step 1:** Add: `XCTAssertTrue(r.hasOutfit(.headband),
  "headband present")` to `runCritterTests()`.
- [ ] **Step 2: Run — expect FAIL:** `swift run SHAFTTests`.
- [ ] **Step 3:** Add to `outfits` in `Sprite.swift`:

```swift
        .headband: OutfitSprite(rows: [
            e, e, e,
            "..NNNNNNNNNNNNNNNN..",
            ".................NN.",
            "..................NN",
            e, e, e, e, e, e, e, e, e, e, e, e, e, e,
        ], ink: ["N": .green]),
```

- [ ] **Step 4: Run — expect PASS:** `swift run SHAFTTests`.
- [ ] **Step 5: Visual:** `swift run SpritePreview`; Read the PNG — Haiku
  shows a green forehead band with a knot-tail on the right.
- [ ] **Step 6: Commit:** `git commit -am "feat: headband outfit (Haiku)"`

---

## Task 5: Wizard hat + leg-bands + wisp (Fable)

**Files:** Modify `Sprite.swift`, `CritterTests.swift`.

- [ ] **Step 1:** Add: `XCTAssertTrue(r.hasOutfit(.wizardHat),
  "wizard present")` to `runCritterTests()`.
- [ ] **Step 2: Run — expect FAIL:** `swift run SHAFTTests`.
- [ ] **Step 3:** Add to `outfits` in `Sprite.swift` (`Z` hat, `S` yellow
  stars + leg-bands + face-wisp):

```swift
        .wizardHat: OutfitSprite(rows: [
            "....SZZZZZZZZZZS....",
            "..ZZZSZZZSZZZZZZSZ..",
            ".ZZZZZZSZZZZSZZZZZZ.",
            ".ZZZZZZZZZSZZZZSZZZ.",
            e, e, e, e, e, e, e,
            "..................S.",
            e, e, e, e, e,
            "..SS..SS....SS..SS..",
            e, e,
        ], ink: ["Z": .hatBlue, "S": .yellow]),
```

- [ ] **Step 4: Run — expect PASS:** `swift run SHAFTTests`.
- [ ] **Step 5: Visual:** `swift run SpritePreview`; Read the PNG — Fable
  shows a starry blue hat, a face-wisp, and yellow leg-bands.
- [ ] **Step 6: Commit:** `git commit -am "feat: wizard hat outfit (Fable)"`

---

**Phase 2 done:** all four models render their outfits. Fable's yellow
gauge-bar fill is handled in Phase 3.
