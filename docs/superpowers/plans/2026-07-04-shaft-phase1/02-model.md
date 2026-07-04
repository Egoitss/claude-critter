### Task 2: Model / Outfit / Mood mappings

**Files:**
- Modify: `Sources/SHAFTCore/Model.swift`
- Test: `Tests/SHAFTCoreTests/ModelTests.swift`

**Interfaces:**
- Consumes: nothing.
- Produces:
  - `enum ClaudeModel: String, CaseIterable { case opus, sonnet, haiku,
    fable }` with `var displayName: String`, `var modelArg: String`,
    `var outfit: Outfit`.
  - `enum Outfit { case crown, headphones, headband, wizardHat }`.
  - `enum Mood { case fresh, focused, tired, asleep }` with
    `init(usageFraction: Double)`.

- [ ] **Step 1: Write the failing tests**

```swift
import XCTest
@testable import SHAFTCore

final class ModelTests: XCTestCase {
    func testModelArgAndOutfit() {
        XCTAssertEqual(ClaudeModel.opus.modelArg, "opus")
        XCTAssertEqual(ClaudeModel.fable.modelArg, "claude-fable-5")
        XCTAssertEqual(ClaudeModel.sonnet.outfit, .headphones)
    }

    func testMoodThresholds() {
        XCTAssertEqual(Mood(usageFraction: 0.10), .fresh)
        XCTAssertEqual(Mood(usageFraction: 0.65), .focused)
        XCTAssertEqual(Mood(usageFraction: 0.90), .tired)
        XCTAssertEqual(Mood(usageFraction: 1.20), .asleep)
    }
}
```

- [ ] **Step 2: Run to verify it fails**

Run: `swift test --filter ModelTests`
Expected: FAIL — `ClaudeModel` undefined.

- [ ] **Step 3: Implement the enums**

Append to `Sources/SHAFTCore/Model.swift`:

```swift
public enum Outfit { case crown, headphones, headband, wizardHat }

public enum ClaudeModel: String, CaseIterable {
    case opus, sonnet, haiku, fable

    public var displayName: String {
        switch self {
        case .opus: return "Opus 4.8"
        case .sonnet: return "Sonnet 5"
        case .haiku: return "Haiku 4.5"
        case .fable: return "Fable 5"
        }
    }

    // Argument passed to `/model`. Verify aliases against the installed
    // Claude Code during Task 10; adjust here if they differ.
    public var modelArg: String {
        switch self {
        case .opus: return "opus"
        case .sonnet: return "sonnet"
        case .haiku: return "haiku"
        case .fable: return "claude-fable-5"
        }
    }

    public var outfit: Outfit {
        switch self {
        case .opus: return .crown
        case .sonnet: return .headphones
        case .haiku: return .headband
        case .fable: return .wizardHat
        }
    }
}

public enum Mood { case fresh, focused, tired, asleep }

extension Mood {
    public init(usageFraction f: Double) {
        switch f {
        case ..<0.5: self = .fresh
        case ..<0.8: self = .focused
        case ..<1.0: self = .tired
        default: self = .asleep
        }
    }
}
```

- [ ] **Step 4: Run to verify it passes**

Run: `swift test --filter ModelTests`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add Sources/SHAFTCore/Model.swift Tests/SHAFTCoreTests/ModelTests.swift
git commit -m "feat: model/outfit/mood mappings"
```
