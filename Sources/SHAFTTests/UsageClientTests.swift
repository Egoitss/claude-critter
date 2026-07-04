import Foundation
import SHAFTCore
import SHAFTTestKit

final class FakeHTTP: HTTPFetching {
    var lastURL: URL?
    var lastHeaders: [String: String] = [:]
    var data = Data()
    func get(_ url: URL, headers: [String: String]) async throws -> Data {
        lastURL = url; lastHeaders = headers; return data
    }
}

struct FakeToken: TokenSource {
    func accessToken() throws -> String { "sk" }
}

func runUsageClientTests() async throws {
    let http = FakeHTTP()
    http.data = """
    {"five_hour":{"utilization":0.9,"resets_at":null}}
    """.data(using: .utf8)!
    let client = UsageClient(http: http, tokens: FakeToken())
    let snap = try await client.fetch()
    XCTAssertEqual(snap.worstFraction, 0.9, accuracy: 0.001,
        "fetch decodes worstFraction")
    XCTAssertEqual(http.lastHeaders["Authorization"], "Bearer sk",
        "fetch sends bearer token")
    XCTAssertEqual(http.lastHeaders["anthropic-version"], "2023-06-01",
        "fetch sends anthropic-version header")
    XCTAssertEqual(http.lastURL?.absoluteString,
        "https://api.anthropic.com/api/oauth/usage",
        "fetch hits usage URL")

    XCTAssertEqual(pollInterval(worstFraction: 0.2), 60,
        "pollInterval low tier")
    XCTAssertEqual(pollInterval(worstFraction: 0.6), 30,
        "pollInterval mid tier")
    XCTAssertEqual(pollInterval(worstFraction: 0.85), 15,
        "pollInterval high tier")
}
