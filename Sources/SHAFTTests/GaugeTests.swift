import AppKit
import SHAFTCore
import SHAFTTestKit

func runGaugeTests() {
    let g = GaugeRenderer()
    XCTAssertEqual(g.percentText(0), "0%", "zero")
    XCTAssertEqual(g.percentText(0.5), "50%", "half")
    XCTAssertEqual(g.percentText(1), "100%", "full")
    XCTAssertEqual(g.percentText(1.5), "100%", "clamped high")
    let img = g.image(usage: 0.5, width: 80, u: 4)
    XCTAssertEqual(img.size, NSSize(width: 80, height: 28), "7u tall")
    let unknown = g.image(usage: nil, width: 80, u: 4)
    XCTAssertEqual(unknown.size, NSSize(width: 80, height: 28),
        "unknown gauge still 7u tall")
    let weekly = g.image(reading: GaugeReading(
        icon: .weekly, text: "89%", known: true), width: 80, u: 4)
    XCTAssertEqual(weekly.size, NSSize(width: 80, height: 28),
        "reading-based gauge is 7u tall")
    let dollar = g.image(reading: GaugeReading(
        icon: .dollar, text: "16.50", known: true), width: 128, u: 4)
    XCTAssertEqual(dollar.size, NSSize(width: 128, height: 28),
        "credits gauge renders at pet width")
}
