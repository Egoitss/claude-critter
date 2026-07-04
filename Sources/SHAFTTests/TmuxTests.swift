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
