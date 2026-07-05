import SHAFTCore
import SHAFTTestKit

final class FakeRunner: CommandRunner {
    var calls: [[String]] = []
    var result = CommandResult(stdout: "", stderr: "", code: 0)
    var responder: (([String]) -> CommandResult)?
    func run(_ path: String, _ args: [String]) -> CommandResult {
        calls.append([path] + args)
        return responder?(args) ?? result
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

func runTmuxTargetTests() {
    let r = FakeRunner()
    r.result = .init(stdout: "claude\nwork\nfable-run\n",
        stderr: "", code: 0)
    XCTAssertEqual(TmuxController(runner: r).listSessions(),
        ["claude", "work", "fable-run"],
        "listSessions parses newline-separated session names")

    let r2 = FakeRunner()
    r2.result = .init(stdout: "", stderr: "no server", code: 1)
    XCTAssertEqual(TmuxController(runner: r2).listSessions(), [],
        "listSessions returns [] when tmux exits nonzero")

    let r3 = FakeRunner()
    let t = TmuxController(runner: r3, session: "claude")
    t.session = "work"
    t.send(model: .opus)
    XCTAssertEqual(r3.calls.last, ["/usr/bin/env", "tmux", "send-keys",
        "-t", "work", "/model opus", "Enter"],
        "retargeting session redirects send(model:)")
}

func runSelfTargetTests() {
    let r = FakeRunner()
    r.responder = { args in
        if args.contains("display-message") {
            return .init(stdout: "claude\n", stderr: "", code: 0)
        }
        if args.contains("list-sessions") {
            return .init(stdout: "claude\nwork\n", stderr: "", code: 0)
        }
        return .init(stdout: "", stderr: "", code: 0)
    }
    let t = TmuxController(runner: r)
    XCTAssertNil(t.ownSession(env: [:]),
        "ownSession is nil when not inside tmux")
    XCTAssertEqual(t.ownSession(env: ["TMUX": "x"]), "claude",
        "ownSession reads the current tmux session")
    XCTAssertEqual(t.controllableSessions(env: [:]), ["claude", "work"],
        "no filtering when SHAFT isn't inside tmux")
    XCTAssertEqual(t.controllableSessions(env: ["TMUX": "x"]), ["work"],
        "own session excluded from switch targets")
}
