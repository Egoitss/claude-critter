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
