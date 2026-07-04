### Task 4: Balance line resolution

**Files:**
- Create: `Sources/SHAFTCore/Balance.swift`
- Test: `Tests/SHAFTCoreTests/BalanceTests.swift`

**Interfaces:**
- Consumes: `UsageSnapshot`, `ExtraUsage` (Task 3).
- Produces:
  - `enum BalanceLine: Equatable { case overage(remaining: Double, limit:
    Double, currency: String); case hidden }`.
  - `static func resolve(_ s: UsageSnapshot) -> BalanceLine`.
  - `var display: String?` → e.g. `"€46.80 left of €50.00"`, or nil when
    hidden.

Units: `monthly_limit` and `used_credits` are treated as major currency units;
`remaining = limit − used`. Verify against a real response in Task 10 and
adjust the arithmetic here if the API reports cents.

- [ ] **Step 1: Write the failing tests**

```swift
import XCTest
@testable import SHAFTCore

final class BalanceTests: XCTestCase {
    private func snap(_ e: ExtraUsage?) -> UsageSnapshot {
        UsageSnapshot(fiveHour: nil, sevenDay: nil, extraUsage: e)
    }

    func testOverageShownWhenEnabled() {
        let e = ExtraUsage(isEnabled: true, monthlyLimit: 50,
            usedCredits: 3.2, utilization: 0.064, currency: "EUR")
        let line = BalanceLine.resolve(snap(e))
        XCTAssertEqual(line, .overage(remaining: 46.8, limit: 50,
            currency: "EUR"))
        XCTAssertEqual(line.display, "€46.80 left of €50.00")
    }

    func testHiddenWhenDisabledOrMissing() {
        XCTAssertEqual(BalanceLine.resolve(snap(nil)), .hidden)
        let off = ExtraUsage(isEnabled: false, monthlyLimit: 50,
            usedCredits: 0, utilization: 0, currency: "EUR")
        XCTAssertEqual(BalanceLine.resolve(snap(off)), .hidden)
        XCTAssertNil(BalanceLine.hidden.display)
    }
}
```

- [ ] **Step 2: Run to verify it fails**

Run: `swift test --filter BalanceTests`
Expected: FAIL — `BalanceLine` undefined (also add a memberwise
`ExtraUsage`/`UsageSnapshot` init below so tests can construct them).

- [ ] **Step 3: Implement**

`Sources/SHAFTCore/Balance.swift`:

```swift
import Foundation

public enum BalanceLine: Equatable {
    case overage(remaining: Double, limit: Double, currency: String)
    case hidden

    public static func resolve(_ s: UsageSnapshot) -> BalanceLine {
        guard let e = s.extraUsage, e.isEnabled,
              let limit = e.monthlyLimit, let used = e.usedCredits
        else { return .hidden }
        return .overage(remaining: max(0, limit - used), limit: limit,
                        currency: e.currency ?? "USD")
    }

    public var display: String? {
        guard case let .overage(rem, limit, cur) = self else { return nil }
        let s = Self.symbol(cur)
        return String(format: "%@%.2f left of %@%.2f", s, rem, s, limit)
    }

    static func symbol(_ code: String) -> String {
        switch code {
        case "USD": return "$"
        case "EUR": return "€"
        case "GBP": return "£"
        default: return code + " "
        }
    }
}
```

Add public memberwise inits so tests can build values. In `Usage.swift`,
add to `ExtraUsage` and `UsageSnapshot`:

```swift
// ExtraUsage
public init(isEnabled: Bool, monthlyLimit: Double?, usedCredits: Double?,
            utilization: Double?, currency: String?) {
    self.isEnabled = isEnabled; self.monthlyLimit = monthlyLimit
    self.usedCredits = usedCredits; self.utilization = utilization
    self.currency = currency
}
// UsageSnapshot
public init(fiveHour: Window?, sevenDay: Window?, extraUsage: ExtraUsage?) {
    self.fiveHour = fiveHour; self.sevenDay = sevenDay
    self.extraUsage = extraUsage
}
```

- [ ] **Step 4: Run to verify it passes**

Run: `swift test --filter BalanceTests`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add Sources/SHAFTCore/Balance.swift Sources/SHAFTCore/Usage.swift \
  Tests/SHAFTCoreTests/BalanceTests.swift
git commit -m "feat: graceful balance line resolution"
```
