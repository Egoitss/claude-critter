# Task 4: GaugeRenderer draws a GaugeReading (SHAFTCore)

**Files:**
- Modify: `Sources/SHAFTCore/Gauge.swift`
- Modify: `Sources/SHAFTTests/GaugeTests.swift`

**Interfaces:**
- Consumes: `GaugeReading`/`GaugeIcon` (Task 2), `PixelFont.weekly`/
  `PixelFont.dollar` (Task 3).
- Produces: `GaugeRenderer.image(reading: GaugeReading, width:
  CGFloat, u: CGFloat) -> NSImage`. The legacy
  `image(usage:width:u:)` keeps working (SpritePreview and Task 6
  both compile against the renderer). Task 6 relies on the
  `image(reading:width:u:)` signature.

- [ ] **Step 1: Write the failing test**

Append inside `runGaugeTests()` in
`Sources/SHAFTTests/GaugeTests.swift`:

```swift
    let weekly = g.image(reading: GaugeReading(
        icon: .weekly, text: "89%", known: true), width: 80, u: 4)
    XCTAssertEqual(weekly.size, NSSize(width: 80, height: 28),
        "reading-based gauge is 7u tall")
    let dollar = g.image(reading: GaugeReading(
        icon: .dollar, text: "16.50", known: true), width: 128, u: 4)
    XCTAssertEqual(dollar.size, NSSize(width: 128, height: 28),
        "credits gauge renders at pet width")
```

- [ ] **Step 2: Run test to verify it fails**

Run: `swift run SHAFTTests`
Expected: compile error — no member `image(reading:width:u:)`.

- [ ] **Step 3: Write minimal implementation**

Replace the body of `Sources/SHAFTCore/Gauge.swift` below
`percentText` (keep the header comment, struct declaration, `init`,
`percentText`, and `blit` exactly as they are):

```swift
    // Gauge ink. Red heart matches the original design; green marks
    // money; dim marks unknown readings.
    private static let red = NSColor(srgbRed: 0.929, green: 0.11,
                                     blue: 0.141, alpha: 1)
    private static let green = NSColor(srgbRed: 0.216, green: 0.78,
                                       blue: 0.31, alpha: 1)
    private static let dim = NSColor(white: 0.45, alpha: 1)

    /// Legacy session-style entry: used fraction -> remaining %.
    /// Kept so SpritePreview and older callers stay source-stable.
    public func image(usage: Double?, width: CGFloat,
                      u: CGFloat) -> NSImage {
        let reading = GaugeReading(
            icon: .heart,
            text: usage.map { percentText(1 - $0) } ?? "--",
            known: usage != nil)
        return image(reading: reading, width: width, u: u)
    }

    /// Renders one resolved reading as the 7u-tall gauge strip.
    public func image(reading: GaugeReading, width: CGFloat,
                      u: CGFloat) -> NSImage {
        let size = NSSize(width: width, height: 7 * u)
        return NSImage(size: size, flipped: false) { _ in
            self.draw(reading, width: width, u: u)
            return true
        }
    }

    /// Centers icon + 1-cell gap + label in the strip and blits both.
    private func draw(_ r: GaugeReading, width: CGFloat, u: CGFloat) {
        NSGraphicsContext.current?.shouldAntialias = false
        let icon = Self.iconBitmap(r.icon)
        let text = PixelFont.text(r.text)
        let iconW = CGFloat(icon.first?.count ?? 0)
        let textW = CGFloat(text.first?.count ?? 0)
        let groupW = (iconW + 1 + textW) * u
        let x0 = ((width - groupW) / 2).rounded(.down)
        blit(icon, x: x0, y: u, u: u, color: Self.iconColor(r))
        blit(text, x: x0 + (iconW + 1) * u, y: u, u: u,
             color: r.known ? .white : Self.dim)
    }

    /// Bitmap for the reading's icon slot.
    private static func iconBitmap(_ icon: GaugeIcon) -> [String] {
        switch icon {
        case .heart: return PixelFont.heart
        case .weekly: return PixelFont.weekly
        case .dollar: return PixelFont.dollar
        }
    }

    /// Icon ink: red heart, white W, green $; dim when unknown.
    private static func iconColor(_ r: GaugeReading) -> NSColor {
        guard r.known else { return dim }
        switch r.icon {
        case .heart: return red
        case .weekly: return .white
        case .dollar: return green
        }
    }
```

Delete the old `image(usage:width:u:)` body, the old
`draw(usage:width:u:)`, and the local `red`/`dim` constants they
contained — the code above replaces them. `blit` stays unchanged.

- [ ] **Step 4: Run test to verify it passes**

Run: `swift run SHAFTTests`
Expected: final line `checks: N, failures: 0` (existing legacy-API
assertions in this suite must still pass).

- [ ] **Step 5: Commit**

```bash
git add Sources/SHAFTCore/Gauge.swift \
  Sources/SHAFTTests/GaugeTests.swift
git commit -m "feat: GaugeRenderer draws any GaugeReading"
```
