import SHAFTCore
import SHAFTTestKit

final class FakeRunner: CommandRunner {
    var calls: [[String]] = []
    var result = CommandResult(stdout: "", stderr: "", code: 0)
    func run(_ path: String, _ args: [String]) -> CommandResult {
        calls.append([path] + args); return result
    }
}

func runTmuxTests() throws {
    let r1 = FakeRunner(); r1.result = .init(stdout: "", stderr: "", code: 0)
    XCTAssertTrue(TmuxController(runner: r1, session: "claude")
        .hasSession(), "exit code 0 means session exists")
    r1.result = .init(stdout: "", stderr: "no", code: 1)
    XCTAssertFalse(TmuxController(runner: r1).hasSession(),
        "nonzero exit code means no session")

    let r2 = FakeRunner()
    TmuxController(runner: r2, session: "claude").startSession()
    XCTAssertEqual(r2.calls.last, ["/usr/bin/env", "tmux",
        "new-session", "-d", "-s", "claude", "claude"],
        "startSession builds correct tmux args")

    let r3 = FakeRunner()
    r3.result = .init(stdout:
        "{\"claudeAiOauth\":{\"accessToken\":\"sk-z\"}}",
        stderr: "", code: 0)
    XCTAssertEqual(try SecurityCLITokenSource(runner: r3).accessToken(),
        "sk-z", "reads token from security CLI output")
}

func runTmuxSwitchTests() {
    let r = FakeRunner()
    TmuxController(runner: r, session: "claude").send(model: .sonnet)
    XCTAssertEqual(r.calls.last, ["/usr/bin/env", "tmux", "send-keys",
        "-t", "claude", "/model sonnet", "Enter"],
        "send(model:) builds correct tmux args")

    let r2 = FakeRunner()
    let t = TmuxController(runner: r2)
    r2.result = .init(stdout: "> ready", stderr: "", code: 0)
    XCTAssertTrue(t.isIdle(), "no busy marker means idle")
    r2.result = .init(stdout: "…thinking (esc to interrupt)",
        stderr: "", code: 0)
    XCTAssertFalse(t.isIdle(), "busy marker means not idle")

    let r3 = FakeRunner()
    r3.result = .init(stdout: "esc to interrupt", stderr: "", code: 0)
    XCTAssertFalse(TmuxController(runner: r3).switchModel(.opus),
        "switchModel does not send while busy")

    let r4 = FakeRunner()
    r4.result = .init(stdout: "model: Sonnet 5", stderr: "", code: 0)
    XCTAssertEqual(TmuxController(runner: r4).currentModel(), .sonnet,
        "currentModel reads pane text")

    let r5 = FakeRunner()
    r5.result = .init(stdout: "> ready", stderr: "", code: 0)
    XCTAssertTrue(TmuxController(runner: r5).switchModel(.opus),
        "switchModel sends while idle")
    XCTAssertEqual(r5.calls.last, ["/usr/bin/env", "tmux", "send-keys",
        "-t", "claude", "/model opus", "Enter"],
        "switchModel builds correct tmux args when idle")

    let r6 = FakeRunner()
    r6.result = .init(stdout: "was on opus earlier\nnow model: sonnet",
        stderr: "", code: 0)
    XCTAssertEqual(TmuxController(runner: r6).currentModel(), .sonnet,
        "currentModel prefers the most recent mention")
}
