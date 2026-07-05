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

    let empty = try! UsageSnapshot.decode("{}".data(using: .utf8)!)
    XCTAssertEqual(
        empty.worstFraction, 0.0, accuracy: 0.001,
        "worstFraction defaults to 0 when windows missing")
}
