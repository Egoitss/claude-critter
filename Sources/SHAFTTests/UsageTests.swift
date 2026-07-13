import SHAFTCore
import SHAFTTestKit

func runUsageTests() {
    let json = """
    {"five_hour":{"utilization":34.0,"resets_at":"2026-07-04T20:00:00Z"},
     "seven_day":{"utilization":11.0,"resets_at":null},
     "extra_usage":{"is_enabled":true,"monthly_limit":50.0,
       "used_credits":3.2,"utilization":0.064,"currency":"EUR"},
     "spend":{"used":{"amount_minor":0,"currency":"EUR","exponent":2},
       "limit":{"amount_minor":10000,"currency":"EUR","exponent":2},
       "enabled":false}}
    """.data(using: .utf8)!

    let s = try! UsageSnapshot.decode(json)
    XCTAssertEqual(
        s.fiveHour?.utilization, 34.0, accuracy: 0.001,
        "fiveHour utilization decodes")
    XCTAssertEqual(
        s.extraUsage?.currency, "EUR", "extraUsage currency decodes")
    XCTAssertEqual(
        s.worstFraction, 0.34, accuracy: 0.001,
        "worstFraction converts percent utilization to a fraction")
    XCTAssertEqual(
        s.spend?.limit?.amountMinor, 10000, "spend.limit.amountMinor decodes")
    XCTAssertEqual(
        s.spend?.limit?.currency, "EUR", "spend.limit.currency decodes")

    // The API answers some errors (e.g. rate limiting) with HTTP 200 and an
    // error body. Decoding such a payload as "0% used" once showed a false
    // 100%-remaining gauge, so a snapshot without any usage window must be
    // rejected rather than silently decoded as empty.
    XCTAssertThrowsError(
        try UsageSnapshot.decode("{}".data(using: .utf8)!),
        "decode rejects a payload with no usage windows")
    let rateLimited = """
    {"error":{"type":"rate_limit_error","message":"Rate limited."}}
    """.data(using: .utf8)!
    XCTAssertThrowsError(
        try UsageSnapshot.decode(rateLimited),
        "decode rejects an HTTP-200 rate-limit error body")

    let weeklyOnly = """
    {"seven_day":{"utilization":94.0,"resets_at":null}}
    """.data(using: .utf8)!
    let w = try? UsageSnapshot.decode(weeklyOnly)
    XCTAssertEqual(
        w?.worstFraction ?? -1, 0.94, accuracy: 0.001,
        "a single present window is enough for a valid snapshot")
}
