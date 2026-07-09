import AppKit
import SHAFTCore
import SHAFTTestKit

func runGaugeTests() {
    let g = GaugeRenderer()
    XCTAssertEqual(g.percentText(0), "0%", "zero")
    XCTAssertEqual(g.percentText(0.5), "50%", "half")
    XCTAssertEqual(g.percentText(1), "100%", "full")
    XCTAssertEqual(g.percentText(1.5), "100%", "clamped high")
    let img = g.image(usage: 0.5, fill: .orange, width: 80, u: 4)
    XCTAssertEqual(img.size, NSSize(width: 80, height: 28), "7u tall")
}
