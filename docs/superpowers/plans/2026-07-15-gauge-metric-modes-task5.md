# Task 5: Gauge right-click handler (PetWindow)

**Files:**
- Modify: `Sources/SHAFT/PetWindow.swift`

**Interfaces:**
- Consumes: nothing new.
- Produces: `PetWindow.onGaugeRightClick: (() -> Void)?`. Task 6
  sets this to cycle the metric. `PetView.onRightClick` stays nil on
  the critter view, so its right-click menu is untouched.

This is AppKit UI: compile-verified, no unit test (repo convention).

- [ ] **Step 1: Add the right-click hook to PetView**

In `Sources/SHAFT/PetWindow.swift`, replace the `PetView` class:

```swift
/// An `NSImageView` that initiates a real window drag on mouse-down,
/// since `isMovableByWindowBackground` is unreliable for a
/// `.nonactivatingPanel`. Right-click runs `onRightClick` when set
/// (the gauge strip cycles metrics); otherwise it opens `.menu`
/// normally via the superclass.
final class PetView: NSImageView {
    var onRightClick: (() -> Void)?

    override func mouseDown(with event: NSEvent) {
        window?.performDrag(with: event)
    }

    override func rightMouseDown(with event: NSEvent) {
        guard let handler = onRightClick else {
            super.rightMouseDown(with: event)
            return
        }
        handler()
    }
}
```

- [ ] **Step 2: Expose the hook on PetWindow**

In the `PetWindow` class, add below `var isVisible`:

```swift
    /// Fired when the gauge strip is right-clicked; the critter view
    /// keeps the default context-menu behavior.
    var onGaugeRightClick: (() -> Void)? {
        get { gaugeView.onRightClick }
        set { gaugeView.onRightClick = newValue }
    }
```

- [ ] **Step 3: Verify it compiles and tests still pass**

Run: `swift build && swift run SHAFTTests`
Expected: build succeeds; final line `checks: N, failures: 0`.

- [ ] **Step 4: Commit**

```bash
git add Sources/SHAFT/PetWindow.swift
git commit -m "feat: gauge-only right-click hook on the pet window"
```
