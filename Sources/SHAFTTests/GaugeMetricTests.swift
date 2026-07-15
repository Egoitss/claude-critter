import SHAFTCore
import SHAFTTestKit

/// Covers metric cycling; Task 2 extends this with reading checks.
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
}
