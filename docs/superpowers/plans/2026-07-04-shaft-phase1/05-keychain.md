### Task 5: Keychain token source

**Files:**
- Create: `Sources/SHAFTCore/Keychain.swift`
- Test: `Tests/SHAFTCoreTests/KeychainTests.swift`

**Interfaces:**
- Consumes: nothing.
- Produces:
  - `protocol TokenSource { func accessToken() throws -> String }`.
  - `enum CredentialsParser { static func token(from data: Data) throws ->
    String }` — decodes `{"claudeAiOauth":{"accessToken":"..."}}`.
  - (The `security` CLI source that uses these lives in Task 6, after
    `CommandRunner` exists, so every task keeps a green build.)

- [ ] **Step 1: Write the failing test**

```swift
import XCTest
@testable import SHAFTCore

final class KeychainTests: XCTestCase {
    func testParseToken() throws {
        let json = """
        {"claudeAiOauth":{"accessToken":"sk-abc","expiresAt":1}}
        """.data(using: .utf8)!
        XCTAssertEqual(try CredentialsParser.token(from: json), "sk-abc")
    }

    func testMissingTokenThrows() {
        let json = "{\"claudeAiOauth\":{}}".data(using: .utf8)!
        XCTAssertThrowsError(try CredentialsParser.token(from: json))
    }
}
```

- [ ] **Step 2: Run to verify it fails**

Run: `swift test --filter KeychainTests`
Expected: FAIL — `CredentialsParser` undefined.

- [ ] **Step 3: Implement**

`Sources/SHAFTCore/Keychain.swift`:

```swift
import Foundation

public protocol TokenSource {
    func accessToken() throws -> String
}

public enum TokenError: Error { case notFound }

public enum CredentialsParser {
    private struct Root: Decodable {
        struct OAuth: Decodable { let accessToken: String? }
        let claudeAiOauth: OAuth?
    }

    public static func token(from data: Data) throws -> String {
        let root = try JSONDecoder().decode(Root.self, from: data)
        guard let t = root.claudeAiOauth?.accessToken, !t.isEmpty
        else { throw TokenError.notFound }
        return t
    }
}
```

The `security`-CLI `TokenSource` that consumes `CommandRunner` is added in
Task 6.

- [ ] **Step 4: Run to verify it passes**

Run: `swift test --filter KeychainTests`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add Sources/SHAFTCore/Keychain.swift \
  Tests/SHAFTCoreTests/KeychainTests.swift
git commit -m "feat: keychain credential parsing"
```
