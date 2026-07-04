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
