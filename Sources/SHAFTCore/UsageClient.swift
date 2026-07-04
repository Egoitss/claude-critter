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
