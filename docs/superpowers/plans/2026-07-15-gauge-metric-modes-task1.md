# Task 1: GaugeMetric cycling (SHAFTCore)

**Files:**
- Create: `Sources/SHAFTCore/GaugeMetric.swift`
- Modify: `Sources/SHAFTCore/Usage.swift` (public `Window` init)
- Create: `Sources/SHAFTTests/GaugeMetricTests.swift`
- Modify: `Sources/SHAFTTests/main.swift`

**Interfaces:**
- Consumes: nothing new.
- Produces: `GaugeMetric` enum (`.session`, `.weekly`, `.credits`)
  with `next(creditsAvailable: Bool) -> GaugeMetric`, and
  `Window.init(utilization:resetsAt:)` made public so Task 2's
  fixtures can build snapshots. Tasks 2 and 6 rely on these names.

- [ ] **Step 1: Write the failing test**

Create `Sources/SHAFTTests/GaugeMetricTests.swift`:

```swift
import SHAFTCore
import SHAFTTestKit

/// Covers metric cycling; Task 2 extends this with reading checks.
func runGaugeMetricTests() {
    XCTAssertEqual(GaugeMetric.session.next(creditsAvailable: false),
        .weekly, "session -> weekly")
    XCTAssertEqual(GaugeMetric.weekly.next(creditsAvailable: false),
        .session, "weekly skips credits when off")
    XCTAssertEqual(GaugeMetric.weekly.next(creditsAvailable: true),
        .credits, "weekly -> credits when on")
    XCTAssertEqual(GaugeMetric.credits.next(creditsAvailable: true),
        .session, "credits wraps to session")
    XCTAssertEqual(GaugeMetric.credits.next(creditsAvailable: false),
        .session, "credits still wraps when spend vanished")
}
```

In `Sources/SHAFTTests/main.swift`, add `runGaugeMetricTests()` on
its own line directly after `runGaugeTests()` (above `xctReport()`).

- [ ] **Step 2: Run test to verify it fails**

Run: `swift run SHAFTTests`
Expected: compile error — `GaugeMetric` not found (a compile failure
is this repo's RED for brand-new types).

- [ ] **Step 3: Write minimal implementation**

In `Sources/SHAFTCore/Usage.swift`, give `Window` a public init
(tests live in another module; its memberwise init is internal):

```swift
public struct Window: Decodable {
    public let utilization: Double
    public let resetsAt: Date?
    /// Memberwise init, public so tests can build fixtures.
    public init(utilization: Double, resetsAt: Date?) {
        self.utilization = utilization
        self.resetsAt = resetsAt
    }
}
```

Create `Sources/SHAFTCore/GaugeMetric.swift`:

```swift
import Foundation

/// Which usage figure the pet gauge shows. Right-clicking the gauge
/// strip cycles session -> weekly -> credits -> session; `session`
/// is the launch default. `credits` is skipped while extra usage is
/// off, so the cycle never lands on an empty mode.
public enum GaugeMetric: Equatable {
    case session   // 5-hour window, remaining %
    case weekly    // 7-day window, remaining %
    case credits   // extra-usage dollars remaining

    /// Next metric in the cycle. Pass `creditsAvailable: false`
    /// when the snapshot has no enabled spend block.
    public func next(creditsAvailable: Bool) -> GaugeMetric {
        switch self {
        case .session: return .weekly
        case .weekly: return creditsAvailable ? .credits : .session
        case .credits: return .session
        }
    }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `swift run SHAFTTests`
Expected: final line `checks: N, failures: 0`.

- [ ] **Step 5: Commit**

```bash
git add Sources/SHAFTCore/GaugeMetric.swift \
  Sources/SHAFTCore/Usage.swift \
  Sources/SHAFTTests/GaugeMetricTests.swift \
  Sources/SHAFTTests/main.swift
git commit -m "feat: GaugeMetric with credits-aware cycling"
```
