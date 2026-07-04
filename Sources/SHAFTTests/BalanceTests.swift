import SHAFTCore
import SHAFTTestKit

func balanceSnap(_ e: ExtraUsage?) -> UsageSnapshot {
    UsageSnapshot(fiveHour: nil, sevenDay: nil, extraUsage: e)
}

func runBalanceTests() {
    let e = ExtraUsage(isEnabled: true, monthlyLimit: 50,
        usedCredits: 3.2, utilization: 0.064, currency: "EUR")
    let line = BalanceLine.resolve(balanceSnap(e))
    XCTAssertEqual(line, .overage(remaining: 46.8, limit: 50,
        currency: "EUR"), "overage resolves when enabled")
    XCTAssertEqual(line.display, "€46.80 left of €50.00",
        "overage display formats currency")

    XCTAssertEqual(BalanceLine.resolve(balanceSnap(nil)), .hidden,
        "hidden when extraUsage missing")
    let off = ExtraUsage(isEnabled: false, monthlyLimit: 50,
        usedCredits: 0, utilization: 0, currency: "EUR")
    XCTAssertEqual(BalanceLine.resolve(balanceSnap(off)), .hidden,
        "hidden when disabled")
    XCTAssertNil(BalanceLine.hidden.display, "hidden has no display text")
}
