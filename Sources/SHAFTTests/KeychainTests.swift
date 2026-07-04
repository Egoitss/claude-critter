import SHAFTCore
import SHAFTTestKit

func runKeychainTests() throws {
    let json = """
    {"claudeAiOauth":{"accessToken":"sk-abc","expiresAt":1}}
    """.data(using: .utf8)!
    XCTAssertEqual(try CredentialsParser.token(from: json), "sk-abc",
        "parses access token from credentials JSON")

    let missing = "{\"claudeAiOauth\":{}}".data(using: .utf8)!
    XCTAssertThrowsError(try CredentialsParser.token(from: missing),
        "missing accessToken throws")
}
