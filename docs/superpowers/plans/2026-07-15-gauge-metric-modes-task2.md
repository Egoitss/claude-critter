# Task 2: GaugeReading resolution (SHAFTCore)

**Files:**
- Modify: `Sources/SHAFTCore/GaugeMetric.swift` (append types)
- Modify: `Sources/SHAFTTests/GaugeMetricTests.swift`

**Interfaces:**
- Consumes: `GaugeMetric` and public `Window` init (Task 1);
  existing `UsageSnapshot`, `BalanceLine`, `Spend`, `Money`.
- Produces: `GaugeIcon` (`.heart`, `.weekly`, `.dollar`) and
  `GaugeReading` (`icon`, `text`, `known`, `init(icon:text:known:)`,
  `static func resolve(_ metric: GaugeMetric, snapshot:
  UsageSnapshot?) -> GaugeReading`). Tasks 4 and 6 rely on these.

- [ ] **Step 1: Write the failing test**

Append to `Sources/SHAFTTests/GaugeMetricTests.swift` (fixture above
`runGaugeMetricTests`, assertions inside it, at the end):

```swift
/// Snapshot fixture; utilization is 0-100 like the live API.
/// spendEnabled adds $3.50 used of a limit (default $20.00).
private func snap(five: Double?, seven: Double?,
                  spendEnabled: Bool = false,
                  limitMinor: Int = 2000) -> UsageSnapshot {
    let spend = spendEnabled ? Spend(
        used: Money(amountMinor: 350, currency: "USD", exponent: 2),
        limit: Money(amountMinor: limitMinor, currency: "USD",
                     exponent: 2),
        enabled: true) : nil
    return UsageSnapshot(
        fiveHour: five.map { Window(utilization: $0, resetsAt: nil) },
        sevenDay: seven.map { Window(utilization: $0, resetsAt: nil) },
        extraUsage: nil, spend: spend)
}
```

```swift
    let s = snap(five: 0, seven: 11)
    XCTAssertEqual(GaugeReading.resolve(.session, snapshot: s),
        GaugeReading(icon: .heart, text: "100%", known: true),
        "fresh session reads 100% even when weekly is used")
    XCTAssertEqual(GaugeReading.resolve(.weekly, snapshot: s),
        GaugeReading(icon: .weekly, text: "89%", known: true),
        "weekly reads its own remaining %")
    XCTAssertEqual(GaugeReading.resolve(.weekly,
        snapshot: snap(five: 34, seven: nil)),
        GaugeReading(icon: .weekly, text: "--", known: false),
        "missing window is unknown")
    XCTAssertEqual(GaugeReading.resolve(.session, snapshot: nil),
        GaugeReading(icon: .heart, text: "--", known: false),
        "no snapshot is unknown")
    XCTAssertEqual(GaugeReading.resolve(.credits,
        snapshot: snap(five: 0, seven: 0, spendEnabled: true)),
        GaugeReading(icon: .dollar, text: "16.50", known: true),
        "credits shows remaining dollars")
    XCTAssertEqual(GaugeReading.resolve(.credits,
        snapshot: snap(five: 0, seven: 0, spendEnabled: true,
                       limitMinor: 15350)),
        GaugeReading(icon: .dollar, text: "150", known: true),
        "credits >= $100 drops cents to fit the strip")
    XCTAssertEqual(GaugeReading.resolve(.credits,
        snapshot: snap(five: 0, seven: 0)),
        GaugeReading(icon: .dollar, text: "--", known: false),
        "credits unknown when spend hidden")
```

- [ ] **Step 2: Run test to verify it fails**

Run: `swift run SHAFTTests`
Expected: compile error — `GaugeReading` not found.

- [ ] **Step 3: Write minimal implementation**

Append to `Sources/SHAFTCore/GaugeMetric.swift`:

```swift
/// The icon slot drawn left of the gauge label.
public enum GaugeIcon: Equatable { case heart, weekly, dollar }

/// One resolved gauge display: icon, label text, and whether the
/// underlying figure is known (unknown renders dim, as "--").
public struct GaugeReading: Equatable {
    public let icon: GaugeIcon
    public let text: String
    public let known: Bool

    /// Memberwise init, public for the renderer and tests.
    public init(icon: GaugeIcon, text: String, known: Bool) {
        self.icon = icon; self.text = text; self.known = known
    }

    /// Maps a metric + latest snapshot to what the gauge draws.
    /// Percent modes show remaining budget (100 - used); credits
    /// shows remaining dollars, dropping cents from $100 up so the
    /// label fits the 128px strip.
    public static func resolve(_ metric: GaugeMetric,
                               snapshot: UsageSnapshot?)
        -> GaugeReading {
        switch metric {
        case .session:
            return percent(.heart, snapshot?.fiveHour)
        case .weekly:
            return percent(.weekly, snapshot?.sevenDay)
        case .credits:
            return credits(snapshot)
        }
    }

    /// Remaining-% reading for one usage window, or unknown.
    private static func percent(_ icon: GaugeIcon,
                                _ window: Window?) -> GaugeReading {
        guard let w = window else {
            return GaugeReading(icon: icon, text: "--", known: false)
        }
        let left = max(0, min(1, 1 - w.utilization / 100))
        let p = Int((left * 100).rounded())
        return GaugeReading(icon: icon, text: "\(p)%", known: true)
    }

    /// Remaining extra-usage dollars, or unknown when spend is off.
    private static func credits(_ snapshot: UsageSnapshot?)
        -> GaugeReading {
        guard let s = snapshot,
              case let .overage(rem, _, _) = BalanceLine.resolve(s)
        else {
            return GaugeReading(icon: .dollar, text: "--",
                                known: false)
        }
        let text = rem < 100 ? String(format: "%.2f", rem)
                             : String(format: "%.0f", rem)
        return GaugeReading(icon: .dollar, text: text, known: true)
    }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `swift run SHAFTTests`
Expected: final line `checks: N, failures: 0`.

- [ ] **Step 5: Commit**

```bash
git add Sources/SHAFTCore/GaugeMetric.swift \
  Sources/SHAFTTests/GaugeMetricTests.swift
git commit -m "feat: GaugeReading resolves metric + snapshot"
```
