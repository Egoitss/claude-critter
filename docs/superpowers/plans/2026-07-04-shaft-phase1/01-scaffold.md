### Task 1: Package scaffold + smoke test

**Files:**
- Create: `Package.swift`
- Create: `Sources/SHAFTCore/Model.swift` (stub)
- Create: `Sources/SHAFT/main.swift` (stub)
- Test: `Tests/SHAFTCoreTests/ModelTests.swift`

**Interfaces:**
- Consumes: nothing.
- Produces: a buildable package with a `SHAFTCore` library target, a `SHAFT`
  executable target, and a `SHAFTCoreTests` test target.

- [ ] **Step 1: Write the failing test**

```swift
import XCTest
@testable import SHAFTCore

final class SmokeTests: XCTestCase {
    func testCoreVersion() {
        XCTAssertEqual(SHAFTCore.version, "0.1.0")
    }
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `swift test --filter SmokeTests`
Expected: FAIL — no such module / `version` undefined.

- [ ] **Step 3: Write the package manifest and stubs**

`Package.swift`:

```swift
// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "SHAFT",
    platforms: [.macOS(.v13)],
    targets: [
        .target(name: "SHAFTCore"),
        .executableTarget(
            name: "SHAFT", dependencies: ["SHAFTCore"]),
        .testTarget(
            name: "SHAFTCoreTests", dependencies: ["SHAFTCore"]),
    ]
)
```

`Sources/SHAFTCore/Model.swift`:

```swift
import Foundation

public enum SHAFTCore {
    public static let version = "0.1.0"
}
```

`Sources/SHAFT/main.swift`:

```swift
import SHAFTCore

// Real bootstrap arrives in Task 10.
print("SHAFT \(SHAFTCore.version)")
```

- [ ] **Step 4: Run test to verify it passes**

Run: `swift test --filter SmokeTests`
Expected: PASS. Also `swift build` succeeds.

- [ ] **Step 5: Commit**

```bash
git add Package.swift Sources Tests
git commit -m "chore: scaffold SHAFT swift package"
```
