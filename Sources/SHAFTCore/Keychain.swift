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
