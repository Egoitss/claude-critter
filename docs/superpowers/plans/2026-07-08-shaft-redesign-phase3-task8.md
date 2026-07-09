# Task 8: Wire the gauge into the pet window

[← Phase 3](2026-07-08-shaft-redesign-phase3.md) · Global Constraints apply.
This is UI: compile-verified + visually checked (no unit test).

**Files:** Modify `Sources/SHAFT/PetWindow.swift`,
`Sources/SHAFT/StatusController.swift`, `Sources/SpritePreview/main.swift`.

**Interfaces:** Consumes `GaugeRenderer`, `CritterRenderer.color(for:)`.
`PetWindow.update` gains a `gauge:` parameter.

- [ ] **Step 1: Grow the pet panel + stack the gauge.** In
  `PetWindow.swift`, add `gaugeH` + a `gaugeView`, and replace `init`,
  `update`:

```swift
    private static let side: CGFloat = 96
    private static let gaugeH: CGFloat = 24
    private let panel: NSPanel
    private let imageView = PetView()
    private let gaugeView = PetView()

    init() {
        let side = Self.side
        let h = side + Self.gaugeH
        panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: side, height: h),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered, defer: false)
        panel.level = .floating
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = false
        panel.isMovableByWindowBackground = true
        panel.collectionBehavior = [
            .canJoinAllSpaces, .fullScreenAuxiliary,
        ]
        let content = NSView(
            frame: NSRect(x: 0, y: 0, width: side, height: h))
        imageView.frame = NSRect(
            x: 0, y: Self.gaugeH, width: side, height: side)
        imageView.imageScaling = .scaleProportionallyUpOrDown
        gaugeView.frame = NSRect(
            x: 0, y: 0, width: side, height: Self.gaugeH)
        gaugeView.imageScaling = .scaleProportionallyUpOrDown
        content.addSubview(imageView)
        content.addSubview(gaugeView)
        panel.contentView = content
        positionBottomRight(side: side)
        panel.orderFrontRegardless()
    }

    func update(image: NSImage, gauge: NSImage, menu: NSMenu) {
        imageView.image = image
        imageView.menu = menu
        gaugeView.image = gauge
        gaugeView.menu = menu
    }
```

- [ ] **Step 2: Render the gauge in `StatusController`.** Add a renderer
  property and rewrite `render()`; add `gaugeFill`:

```swift
    private let gaugeRenderer = GaugeRenderer()
```

```swift
    private func render() {
        let spending = balance != nil
        item.button?.image = renderer.image(
            outfit: model.outfit, spending: spending)
        let critter = renderer.image(
            outfit: model.outfit, spending: spending, size: 96)
        let gauge = gaugeRenderer.image(
            usage: usage, fill: gaugeFill(model), width: 96, u: 3)
        pet.update(image: critter, gauge: gauge, menu: buildMenu())
    }

    private func gaugeFill(_ m: ClaudeModel) -> NSColor {
        m == .fable ? renderer.color(for: .yellow)
                    : renderer.color(for: .body)
    }
```

- [ ] **Step 3: Add a usage line to the menu.** In `buildMenu()`, after the
  `Model:` info item:

```swift
        m.addItem(info("Usage: \(Int((usage * 100).rounded()))%"))
```

- [ ] **Step 4: Preview the gauge.** In `SpritePreview/main.swift`, add a
  gauge strip under each tile. Replace the sizing + draw loop:

```swift
let tile: CGFloat = 144
let gaugeH = 40
let cols = tiles.count
let w = Int(tile) * cols
let h = Int(tile) + gaugeH
```

```swift
let gaugeR = GaugeRenderer()
for (i, t) in tiles.enumerated() {
    renderer.image(outfit: t.2, spending: t.3, size: tile)
        .draw(at: NSPoint(x: CGFloat(i) * tile, y: CGFloat(gaugeH)),
              from: .zero, operation: .sourceOver, fraction: 1)
    let fill = (t.2 == .wizardHat)
        ? renderer.color(for: .yellow) : renderer.color(for: .body)
    gaugeR.image(usage: t.1, fill: fill, width: tile - 16, u: 4)
        .draw(at: NSPoint(x: CGFloat(i) * tile + 8, y: 6),
              from: .zero, operation: .sourceOver, fraction: 1)
}
```

- [ ] **Step 5: Build + tests:** `swift build` (clean) and
  `swift run SHAFTTests` → `failures: 0`.
- [ ] **Step 6: Visual check:** `swift run SpritePreview`; Read
  `~/Downloads/shaft-preview.png` — each critter has a heart + orange bar
  filled to its usage + `NN%`; Fable's bar fill is yellow.
- [ ] **Step 7: Launch check (manual):** `swift run SHAFT` — the floating
  pet shows the critter with the gauge beneath it; the menu shows
  `Usage: N%`. Quit from the menu.
- [ ] **Step 8: Commit:** `git commit -am "feat: heart+bar usage gauge in
  the pet window"`

---

**Redesign complete:** square orange critter, four outfits, money-bag, and a
live heart + bar + `NN%` gauge.
