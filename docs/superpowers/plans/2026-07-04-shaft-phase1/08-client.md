### Task 8: UsageClient + adaptive poll

**Files:**
- Create: `Sources/SHAFTCore/UsageClient.swift`
- Test: `Tests/SHAFTCoreTests/UsageClientTests.swift`

**Interfaces:**
- Consumes: `TokenSource` (Task 5), `UsageSnapshot` (Task 3).
- Produces:
  - `protocol HTTPFetching { func get(_ url: URL, headers: [String: String])
    async throws -> Data }` + `struct URLSessionHTTP: HTTPFetching`.
  - `struct UsageClient` with `init(http: HTTPFetching, tokens: TokenSource)`
    and `func fetch() async throws -> UsageSnapshot`.
  - `func pollInterval(worstFraction: Double) -> TimeInterval`.

- [ ] **Step 1: Write the failing tests**

```swift
import XCTest
@testable import SHAFTCore

final class FakeHTTP: HTTPFetching {
    var lastURL: URL?; var lastHeaders: [String: String] = [:]
    var data = Data()
    func get(_ url: URL, headers: [String: String]) async throws -> Data {
        lastURL = url; lastHeaders = headers; return data
    }
}
struct FakeToken: TokenSource { func accessToken() throws -> String { "sk" } }

final class UsageClientTests: XCTestCase {
    func testFetchSendsAuthAndDecodes() async throws {
        let http = FakeHTTP()
        http.data = """
        {"five_hour":{"utilization":0.9,"resets_at":null}}
        """.data(using: .utf8)!
        let client = UsageClient(http: http, tokens: FakeToken())
        let snap = try await client.fetch()
        XCTAssertEqual(snap.worstFraction, 0.9, accuracy: 0.001)
        XCTAssertEqual(http.lastHeaders["Authorization"], "Bearer sk")
        XCTAssertEqual(http.lastHeaders["anthropic-version"], "2023-06-01")
        XCTAssertEqual(http.lastURL?.absoluteString,
            "https://api.anthropic.com/api/oauth/usage")
    }

    func testPollIntervalTiers() {
        XCTAssertEqual(pollInterval(worstFraction: 0.2), 60)
        XCTAssertEqual(pollInterval(worstFraction: 0.6), 30)
        XCTAssertEqual(pollInterval(worstFraction: 0.85), 15)
    }
}
```

- [ ] **Step 2: Run to verify it fails**

Run: `swift test --filter UsageClientTests`
Expected: FAIL — `UsageClient` undefined.

- [ ] **Step 3: Implement**

`Sources/SHAFTCore/UsageClient.swift`:

```swift
import Foundation

public protocol HTTPFetching {
    func get(_ url: URL, headers: [String: String]) async throws -> Data
}

public struct URLSessionHTTP: HTTPFetching {
    public init() {}
    public func get(_ url: URL,
                    headers: [String: String]) async throws -> Data {
        var req = URLRequest(url: url)
        for (k, v) in headers { req.setValue(v, forHTTPHeaderField: k) }
        let (data, _) = try await URLSession.shared.data(for: req)
        return data
    }
}

public struct UsageClient {
    static let usageURL =
        URL(string: "https://api.anthropic.com/api/oauth/usage")!
    private let http: HTTPFetching
    private let tokens: TokenSource

    public init(http: HTTPFetching, tokens: TokenSource) {
        self.http = http; self.tokens = tokens
    }

    public func fetch() async throws -> UsageSnapshot {
        let token = try tokens.accessToken()
        let data = try await http.get(Self.usageURL, headers: [
            "Authorization": "Bearer \(token)",
            "Accept": "application/json",
            "anthropic-version": "2023-06-01",
        ])
        return try UsageSnapshot.decode(data)
    }
}

public func pollInterval(worstFraction f: Double) -> TimeInterval {
    if f >= 0.8 { return 15 }
    if f >= 0.5 { return 30 }
    return 60
}
```

- [ ] **Step 4: Run to verify it passes**

Run: `swift test --filter UsageClientTests`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add Sources/SHAFTCore/UsageClient.swift \
  Tests/SHAFTCoreTests/UsageClientTests.swift
git commit -m "feat: usage API client + adaptive poll interval"
```
