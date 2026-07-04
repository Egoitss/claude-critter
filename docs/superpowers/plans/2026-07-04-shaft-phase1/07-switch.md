### Task 7: Model switch + idle gate

**Files:**
- Modify: `Sources/SHAFTCore/Tmux.swift`
- Test: `Tests/SHAFTCoreTests/TmuxTests.swift` (add cases)

**Interfaces:**
- Consumes: `ClaudeModel` (Task 2), `TmuxController` (Task 6).
- Produces on `TmuxController`:
  - `func send(model: ClaudeModel)` — injects `/model <arg>` + Enter.
  - `func isIdle() -> Bool` — true when the pane is not mid-response.
  - `func currentModel() -> ClaudeModel?` — best-effort from pane text.
  - `@discardableResult func switchModel(_ m: ClaudeModel) -> Bool` — sends
    only when idle; returns whether it sent.

Idle heuristic: Claude Code shows `esc to interrupt` while streaming, so
idle = pane does not contain that marker. Verify the exact marker in Task 10.

- [ ] **Step 1: Add failing tests**

```swift
extension TmuxTests {
    func testSendModelArgs() {
        let r = FakeRunner()
        TmuxController(runner: r, session: "claude").send(model: .sonnet)
        XCTAssertEqual(r.calls.last, ["/usr/bin/env", "tmux", "send-keys",
            "-t", "claude", "/model sonnet", "Enter"])
    }

    func testIdleFromPaneMarker() {
        let r = FakeRunner()
        let t = TmuxController(runner: r)
        r.result = .init(stdout: "> ready", stderr: "", code: 0)
        XCTAssertTrue(t.isIdle())
        r.result = .init(stdout: "…thinking (esc to interrupt)",
            stderr: "", code: 0)
        XCTAssertFalse(t.isIdle())
    }

    func testSwitchModelGatedOnIdle() {
        let r = FakeRunner()
        r.result = .init(stdout: "esc to interrupt", stderr: "", code: 0)
        XCTAssertFalse(TmuxController(runner: r).switchModel(.opus))
    }

    func testCurrentModelFromPane() {
        let r = FakeRunner()
        r.result = .init(stdout: "model: Sonnet 5", stderr: "", code: 0)
        XCTAssertEqual(TmuxController(runner: r).currentModel(), .sonnet)
    }
}
```

- [ ] **Step 2: Run to verify it fails**

Run: `swift test --filter TmuxTests`
Expected: FAIL — `send(model:)` undefined.

- [ ] **Step 3: Implement**

Append to `TmuxController` in `Sources/SHAFTCore/Tmux.swift`:

```swift
private static let busyMarker = "esc to interrupt"

public func send(model: ClaudeModel) {
    tmux(["send-keys", "-t", session,
          "/model \(model.modelArg)", "Enter"])
}

public func isIdle() -> Bool {
    !capturePane().contains(Self.busyMarker)
}

public func currentModel() -> ClaudeModel? {
    let pane = capturePane().lowercased()
    return ClaudeModel.allCases.first { pane.contains($0.rawValue) }
}

@discardableResult
public func switchModel(_ m: ClaudeModel) -> Bool {
    guard isIdle() else { return false }
    send(model: m)
    return true
}
```

- [ ] **Step 4: Run to verify it passes**

Run: `swift test --filter TmuxTests`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add Sources/SHAFTCore/Tmux.swift Tests/SHAFTCoreTests/TmuxTests.swift
git commit -m "feat: tmux model switch with idle gate + drift read"
```
