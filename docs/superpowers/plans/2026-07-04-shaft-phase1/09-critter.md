### Task 9: Critter renderer

**Files:**
- Create: `Sources/SHAFTCore/Critter.swift`
- Test: `Tests/SHAFTCoreTests/CritterTests.swift`

**Interfaces:**
- Consumes: `Mood`, `Outfit` (Task 2).
- Produces:
  - `struct CritterRenderer` with `init()`,
    `func moodTint(_ m: Mood) -> NSColor`,
    `func outfitAccent(_ o: Outfit) -> NSColor`,
    `func image(mood: Mood, outfit: Outfit, size: CGFloat = 18) -> NSImage`.

Phase-1 sprites are drawn programmatically (a tinted body + an accent
accessory bar). Real SHAFT pixel art later replaces the drawing block inside
`image(...)` without changing the signature.

- [ ] **Step 1: Write the failing tests**

```swift
import XCTest
import AppKit
@testable import SHAFTCore

final class CritterTests: XCTestCase {
    let r = CritterRenderer()

    func testImageHasRequestedSize() {
        let img = r.image(mood: .fresh, outfit: .crown, size: 18)
        XCTAssertEqual(img.size, NSSize(width: 18, height: 18))
    }

    func testMoodTintsDiffer() {
        XCTAssertNotEqual(r.moodTint(.fresh), r.moodTint(.asleep))
    }

    func testOutfitAccentsDiffer() {
        XCTAssertNotEqual(r.outfitAccent(.crown),
                          r.outfitAccent(.wizardHat))
    }
}
```

- [ ] **Step 2: Run to verify it fails**

Run: `swift test --filter CritterTests`
Expected: FAIL — `CritterRenderer` undefined.

- [ ] **Step 3: Implement**

`Sources/SHAFTCore/Critter.swift`:

```swift
import AppKit

public struct CritterRenderer {
    public init() {}

    public func moodTint(_ m: Mood) -> NSColor {
        switch m {
        case .fresh: return NSColor(srgbRed: 0.79, green: 0.42,
            blue: 0.30, alpha: 1)                 // terracotta
        case .focused: return NSColor(srgbRed: 0.85, green: 0.55,
            blue: 0.20, alpha: 1)
        case .tired: return NSColor(srgbRed: 0.70, green: 0.26,
            blue: 0.09, alpha: 1)
        case .asleep: return NSColor(srgbRed: 0.45, green: 0.40,
            blue: 0.38, alpha: 1)                 // grey, napping
        }
    }

    public func outfitAccent(_ o: Outfit) -> NSColor {
        switch o {
        case .crown: return .systemYellow
        case .headphones: return .systemBlue
        case .headband: return .systemGreen
        case .wizardHat: return .systemTeal
        }
    }

    public func image(mood: Mood, outfit: Outfit,
                      size: CGFloat = 18) -> NSImage {
        let body = moodTint(mood); let accent = outfitAccent(outfit)
        return NSImage(size: NSSize(width: size, height: size),
                       flipped: false) { rect in
            body.setFill()
            let b = NSBezierPath(roundedRect: rect.insetBy(dx: 2, dy: 3),
                xRadius: 2, yRadius: 2)
            b.fill()
            NSColor.black.setFill()          // two eyes
            let e = size * 0.12
            NSBezierPath(ovalIn: NSRect(x: size*0.34, y: size*0.5,
                width: e, height: e)).fill()
            NSBezierPath(ovalIn: NSRect(x: size*0.56, y: size*0.5,
                width: e, height: e)).fill()
            accent.setFill()                 // accessory bar = outfit
            NSBezierPath(rect: NSRect(x: size*0.25, y: size*0.78,
                width: size*0.5, height: size*0.12)).fill()
            return true
        }
    }
}
```

- [ ] **Step 4: Run to verify it passes**

Run: `swift test --filter CritterTests`
Expected: PASS. (Size is set without needing a graphics session.)

- [ ] **Step 5: Commit**

```bash
git add Sources/SHAFTCore/Critter.swift \
  Tests/SHAFTCoreTests/CritterTests.swift
git commit -m "feat: programmatic critter renderer (placeholder sprites)"
```
