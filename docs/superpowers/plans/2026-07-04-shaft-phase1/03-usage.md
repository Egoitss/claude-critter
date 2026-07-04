### Task 3: Usage parsing

**Files:**
- Create: `Sources/SHAFTCore/Usage.swift`
- Test: `Tests/SHAFTCoreTests/UsageTests.swift`

**Interfaces:**
- Consumes: nothing.
- Produces:
  - `struct Window: Decodable { let utilization: Double; let resetsAt: Date? }`
  - `struct ExtraUsage: Decodable { let isEnabled: Bool; let monthlyLimit:
    Double?; let usedCredits: Double?; let utilization: Double?; let currency:
    String? }`
  - `struct UsageSnapshot: Decodable { let fiveHour: Window?; let sevenDay:
    Window?; let extraUsage: ExtraUsage? }` with `var worstFraction: Double`
    and `static func decode(_ data: Data) throws -> UsageSnapshot`.

Field names use snake_case in JSON (`five_hour`, `resets_at`, `extra_usage`,
`is_enabled`, `monthly_limit`, `used_credits`) — decoded via
`.convertFromSnakeCase`.

- [ ] **Step 1: Write the failing test**

```swift
import XCTest
@testable import SHAFTCore

final class UsageTests: XCTestCase {
    let json = """
    {"five_hour":{"utilization":0.58,"resets_at":"2026-07-04T20:00:00Z"},
     "seven_day":{"utilization":0.41,"resets_at":null},
     "extra_usage":{"is_enabled":true,"monthly_limit":50.0,
       "used_credits":3.2,"utilization":0.064,"currency":"EUR"}}
    """.data(using: .utf8)!

    func testDecodeAndWorstFraction() throws {
        let s = try UsageSnapshot.decode(json)
        XCTAssertEqual(s.fiveHour?.utilization, 0.58, accuracy: 0.001)
        XCTAssertEqual(s.extraUsage?.currency, "EUR")
        XCTAssertEqual(s.worstFraction, 0.58, accuracy: 0.001)
    }

    func testMissingWindowsGiveZeroWorst() throws {
        let s = try UsageSnapshot.decode("{}".data(using: .utf8)!)
        XCTAssertEqual(s.worstFraction, 0.0, accuracy: 0.001)
    }
}
```

- [ ] **Step 2: Run to verify it fails**

Run: `swift test --filter UsageTests`
Expected: FAIL — `UsageSnapshot` undefined.

- [ ] **Step 3: Implement**

`Sources/SHAFTCore/Usage.swift`:

```swift
import Foundation

public struct Window: Decodable {
    public let utilization: Double
    public let resetsAt: Date?
}

public struct ExtraUsage: Decodable {
    public let isEnabled: Bool
    public let monthlyLimit: Double?
    public let usedCredits: Double?
    public let utilization: Double?
    public let currency: String?
}

public struct UsageSnapshot: Decodable {
    public let fiveHour: Window?
    public let sevenDay: Window?
    public let extraUsage: ExtraUsage?

    public var worstFraction: Double {
        max(fiveHour?.utilization ?? 0, sevenDay?.utilization ?? 0)
    }

    public static func decode(_ data: Data) throws -> UsageSnapshot {
        let d = JSONDecoder()
        d.keyDecodingStrategy = .convertFromSnakeCase
        d.dateDecodingStrategy = .iso8601
        return try d.decode(UsageSnapshot.self, from: data)
    }
}
```

- [ ] **Step 4: Run to verify it passes**

Run: `swift test --filter UsageTests`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add Sources/SHAFTCore/Usage.swift Tests/SHAFTCoreTests/UsageTests.swift
git commit -m "feat: usage response parsing"
```
