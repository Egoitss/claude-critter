import SHAFTCore
import SHAFTTestKit

func balanceSnap(_ sp: Spend?) -> UsageSnapshot {
    UsageSnapshot(fiveHour: nil, sevenDay: nil, extraUsage: nil, spend: sp)
}

func runBalanceTests() {
    let sp = Spend(used: Money(amountMinor: 0, currency: "EUR", exponent: 2),
        limit: Money(amountMinor: 10000, currency: "EUR", exponent: 2),
        enabled: true)
    let line = BalanceLine.resolve(balanceSnap(sp))
    XCTAssertEqual(line, .overage(remaining: 100.0, limit: 100.0,
        currency: "EUR"), "overage resolves when enabled")
    XCTAssertEqual(line.display, "€100.00 left of €100.00",
        "overage display formats currency")

    XCTAssertEqual(BalanceLine.resolve(balanceSnap(nil)), .hidden,
        "hidden when spend missing")
    let off = Spend(used: Money(amountMinor: 0, currency: "EUR", exponent: 2),
        limit: Money(amountMinor: 10000, currency: "EUR", exponent: 2),
        enabled: false)
    XCTAssertEqual(BalanceLine.resolve(balanceSnap(off)), .hidden,
        "hidden when disabled")
    XCTAssertNil(BalanceLine.hidden.display, "hidden has no display text")
}
