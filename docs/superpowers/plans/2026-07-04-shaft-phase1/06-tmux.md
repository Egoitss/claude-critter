### Task 6: CommandRunner + tmux basics

**Files:**
- Create: `Sources/SHAFTCore/Command.swift`
- Create: `Sources/SHAFTCore/Tmux.swift`
- Modify: `Sources/SHAFTCore/Keychain.swift` (add `SecurityCLITokenSource`)
- Test: `Tests/SHAFTCoreTests/TmuxTests.swift`

**Interfaces:**
- Consumes: `TokenSource`, `CredentialsParser` (Task 5); `ClaudeModel`
  (Task 2).
- Produces: `CommandResult`, `protocol CommandRunner` +
  `ProcessCommandRunner`, `SecurityCLITokenSource: TokenSource`, and
  `TmuxController(runner:session:)` with `hasSession()`, `startSession()`,
  `capturePane()`. Exact signatures shown in the code below.

- [ ] **Step 1: Write the failing tests (with a fake runner)**

```swift
import XCTest
@testable import SHAFTCore
final class FakeRunner: CommandRunner {
    var calls: [[String]] = []
    var result = CommandResult(stdout: "", stderr: "", code: 0)
    func run(_ path: String, _ args: [String]) -> CommandResult {
        calls.append([path] + args); return result
    }
}
final class TmuxTests: XCTestCase {
    func testHasSessionUsesExitCode() {
        let r = FakeRunner(); r.result = .init(stdout: "", stderr: "", code: 0)
        XCTAssertTrue(TmuxController(runner: r, session: "claude")
            .hasSession())
        r.result = .init(stdout: "", stderr: "no", code: 1)
        XCTAssertFalse(TmuxController(runner: r).hasSession())
    }
    func testStartSessionArgs() {
        let r = FakeRunner()
        TmuxController(runner: r, session: "claude").startSession()
        XCTAssertEqual(r.calls.last, ["/usr/bin/env", "tmux",
            "new-session", "-d", "-s", "claude", "claude"])
    }
    func testTokenSourceReadsSecurity() throws {
        let r = FakeRunner()
        r.result = .init(stdout:
            "{\"claudeAiOauth\":{\"accessToken\":\"sk-z\"}}",
            stderr: "", code: 0)
        XCTAssertEqual(try SecurityCLITokenSource(runner: r).accessToken(),
            "sk-z")
    }
}
```

- [ ] **Step 2: Run to verify it fails**

Run: `swift test --filter TmuxTests`
Expected: FAIL — `CommandRunner` undefined.

- [ ] **Step 3: Implement**

`Sources/SHAFTCore/Command.swift`:

```swift
import Foundation
public struct CommandResult {
    public let stdout: String; public let stderr: String; public let code: Int32
    public init(stdout: String, stderr: String, code: Int32) {
        self.stdout = stdout; self.stderr = stderr; self.code = code
    }
}
public protocol CommandRunner {
    func run(_ path: String, _ args: [String]) -> CommandResult
}
public struct ProcessCommandRunner: CommandRunner {
    public init() {}
    public func run(_ path: String, _ args: [String]) -> CommandResult {
        let p = Process(); p.executableURL = URL(fileURLWithPath: path)
        p.arguments = args
        let out = Pipe(); let err = Pipe()
        p.standardOutput = out; p.standardError = err
        do { try p.run() } catch {
            return CommandResult(stdout: "", stderr: "\(error)", code: -1)
        }
        p.waitUntilExit()
        func s(_ pipe: Pipe) -> String {
            String(decoding: pipe.fileHandleForReading.readDataToEndOfFile(),
                   as: UTF8.self)
        }
        return CommandResult(stdout: s(out), stderr: s(err),
                             code: p.terminationStatus)
    }
}
```

`Sources/SHAFTCore/Tmux.swift`:

```swift
import Foundation
public final class TmuxController {
    private let runner: CommandRunner
    public let session: String
    public init(runner: CommandRunner, session: String = "claude") {
        self.runner = runner; self.session = session
    }
    @discardableResult
    func tmux(_ args: [String]) -> CommandResult {
        runner.run("/usr/bin/env", ["tmux"] + args)
    }
    public func hasSession() -> Bool {
        tmux(["has-session", "-t", session]).code == 0
    }
    public func startSession() {
        tmux(["new-session", "-d", "-s", session, "claude"])
    }
    public func capturePane() -> String {
        tmux(["capture-pane", "-p", "-t", session]).stdout
    }
}
```

Append `SecurityCLITokenSource` to `Sources/SHAFTCore/Keychain.swift`:

```swift
public struct SecurityCLITokenSource: TokenSource {
    private let runner: CommandRunner
    public init(runner: CommandRunner) { self.runner = runner }
    public func accessToken() throws -> String {
        let r = runner.run("/usr/bin/security", [
            "find-generic-password",
            "-s", "Claude Code-credentials", "-w"])
        guard r.code == 0 else { throw TokenError.notFound }
        return try CredentialsParser.token(from: Data(r.stdout.utf8))
    }
}
```

- [ ] **Step 4: Run to verify it passes**

Run: `swift test --filter TmuxTests`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add Sources/SHAFTCore/Command.swift Sources/SHAFTCore/Tmux.swift \
  Sources/SHAFTCore/Keychain.swift Tests/SHAFTCoreTests/TmuxTests.swift
git commit -m "feat: command runner + tmux session basics"
```
