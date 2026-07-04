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
        var best: (model: ClaudeModel, index: String.Index)?
        for model in ClaudeModel.allCases {
            guard let range = pane.range(
                of: model.rawValue, options: .backwards
            ) else { continue }
            if best == nil || range.lowerBound > best!.index {
                best = (model, range.lowerBound)
            }
        }
        return best?.model
    }

    @discardableResult
    public func switchModel(_ m: ClaudeModel) -> Bool {
        guard isIdle() else { return false }
        send(model: m)
        return true
    }
}
