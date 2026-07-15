import SHAFTCore
import SHAFTTestKit

/// Snapshot fixture; utilization is 0-100 like the live API.
/// spendEnabled adds $3.50 used of a limit (default $20.00).
private func snap(five: Double?, seven: Double?,
                  spendEnabled: Bool = false,
                  limitMinor: Int = 2000) -> UsageSnapshot {
    let spend = spendEnabled ? Spend(
        used: Money(amountMinor: 350, currency: "USD", exponent: 2),
        limit: Money(amountMinor: limitMinor, currency: "USD",
                     exponent: 2),
        enabled: true) : nil
    return UsageSnapshot(
        fiveHour: five.map { Window(utilization: $0, resetsAt: nil) },
        sevenDay: seven.map { Window(utilization: $0, resetsAt: nil) },
        extraUsage: nil, spend: spend)
}

/// Covers metric cycling and GaugeReading resolution for all modes.
func runGaugeMetricTests() {
    XCTAssertEqual(GaugeMetric.session.next(creditsAvailable: false),
        .weekly, "session -> weekly")
    XCTAssertEqual(GaugeMetric.weekly.next(creditsAvailable: false),
        .session, "weekly skips credits when off")
    XCTAssertEqual(GaugeMetric.weekly.next(creditsAvailable: true),
        .credits, "weekly -> credits when on")
    XCTAssertEqual(GaugeMetric.credits.next(creditsAvailable: true),
        .session, "credits wraps to session")
    XCTAssertEqual(GaugeMetric.credits.next(creditsAvailable: false),
        .session, "credits still wraps when spend vanished")

    let s = snap(five: 0, seven: 11)
    XCTAssertEqual(GaugeReading.resolve(.session, snapshot: s),
        GaugeReading(icon: .heart, text: "100%", known: true),
        "fresh session reads 100% even when weekly is used")
    XCTAssertEqual(GaugeReading.resolve(.weekly, snapshot: s),
        GaugeReading(icon: .weekly, text: "89%", known: true),
        "weekly reads its own remaining %")
    XCTAssertEqual(GaugeReading.resolve(.weekly,
        snapshot: snap(five: 34, seven: nil)),
        GaugeReading(icon: .weekly, text: "--", known: false),
        "missing window is unknown")
    XCTAssertEqual(GaugeReading.resolve(.session, snapshot: nil),
        GaugeReading(icon: .heart, text: "--", known: false),
        "no snapshot is unknown")
    XCTAssertEqual(GaugeReading.resolve(.credits,
        snapshot: snap(five: 0, seven: 0, spendEnabled: true)),
        GaugeReading(icon: .dollar, text: "16.50", known: true),
        "credits shows remaining dollars")
    XCTAssertEqual(GaugeReading.resolve(.credits,
        snapshot: snap(five: 0, seven: 0, spendEnabled: true,
                       limitMinor: 15350)),
        GaugeReading(icon: .dollar, text: "150", known: true),
        "credits >= $100 drops cents to fit the strip")
    XCTAssertEqual(GaugeReading.resolve(.credits,
        snapshot: snap(five: 0, seven: 0)),
        GaugeReading(icon: .dollar, text: "--", known: false),
        "credits unknown when spend hidden")
}
