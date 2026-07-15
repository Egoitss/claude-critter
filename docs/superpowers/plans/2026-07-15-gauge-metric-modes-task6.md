# Task 6: StatusController wiring + menu lines

**Files:**
- Modify: `Sources/SHAFT/StatusController.swift`

**Interfaces:**
- Consumes: `GaugeMetric.next(creditsAvailable:)` (Task 1),
  `GaugeReading.resolve(_:snapshot:)` (Task 2),
  `GaugeRenderer.image(reading:width:u:)` (Task 4),
  `PetWindow.onGaugeRightClick` (Task 5), existing `BalanceLine`.
- Produces: end-user behavior; nothing downstream.

AppKit UI: compile-verified + manual check (repo convention).

- [ ] **Step 1: Store the snapshot and metric**

In `Sources/SHAFT/StatusController.swift`, replace the line
`private var usage: Double?          // used fraction; nil until
fetched` with:

```swift
    private var snapshot: UsageSnapshot?   // nil until first fetch
    private var metric: GaugeMetric = .session
```

At the end of `init()`, before `render(); refresh()`, add:

```swift
        pet.onGaugeRightClick = { [weak self] in
            self?.cycleMetric()
        }
```

- [ ] **Step 2: Render the selected metric**

In `render()`, replace the `let gauge = ...` line with:

```swift
        let reading = GaugeReading.resolve(metric, snapshot: snapshot)
        let gauge = gaugeRenderer.image(reading: reading,
                                        width: 128, u: 4)
```

- [ ] **Step 3: Split the menu Budget line**

In `buildMenu()`, replace these two lines:

```swift
        let left = usage.map { "\(Int(((1 - $0) * 100).rounded()))% left" }
        m.addItem(info("Budget: \(left ?? "unavailable")"))
```

with:

```swift
        m.addItem(info("Session: \(remainingLine(.session))"))
        m.addItem(info("Weekly: \(remainingLine(.weekly))"))
```

Add these helpers after `info(_:)`:

```swift
    /// "NN% left" for a percent metric, or "unavailable" before the
    /// first successful fetch / when the window is missing.
    private func remainingLine(_ m: GaugeMetric) -> String {
        let r = GaugeReading.resolve(m, snapshot: snapshot)
        return r.known ? "\(r.text) left" : "unavailable"
    }

    /// Advances the gauge metric on gauge right-click, skipping
    /// credits while extra usage is off.
    private func cycleMetric() {
        let creditsOK = snapshot
            .map { BalanceLine.resolve($0) != .hidden } ?? false
        metric = metric.next(creditsAvailable: creditsOK)
        render()
    }
```

- [ ] **Step 4: Keep the snapshot on refresh**

In `refresh()`, replace `usage = snap.worstFraction` with:

```swift
            snapshot = snap
```

and directly after the `balance = ...` line add (spec: if credits is
selected and extra usage turns off, fall back to session):

```swift
            if metric == .credits && balance == nil {
                metric = .session
            }
```

`schedule(pollInterval(worstFraction: snap.worstFraction))` stays —
polling still keys off the worst window.

- [ ] **Step 5: Verify compile, tests, line widths**

Run: `swift build && swift run SHAFTTests`
Expected: build succeeds; final line `checks: N, failures: 0`.

Run: `grep -n '.\{81,\}' Sources/SHAFT/StatusController.swift`
Expected: no output.

- [ ] **Step 6: Manual check**

Run `swift run SHAFT` (blocking; use a separate terminal), then:

1. Pet gauge shows the heart + session remaining % (100% on a fresh
   session, even if weekly is partly used).
2. Right-click the gauge strip: `W` + weekly remaining %.
3. Right-click again: `$` + remaining dollars if extra usage is on,
   otherwise back to the heart.
4. Right-click the critter: context menu opens, now with separate
   "Session: … left" and "Weekly: … left" lines.
5. Drag still works from both the critter and the gauge.

Quit with the menu's "Quit SHAFT".

- [ ] **Step 7: Commit**

```bash
git add Sources/SHAFT/StatusController.swift
git commit -m "feat: gauge defaults to session; right-click cycles"
```
