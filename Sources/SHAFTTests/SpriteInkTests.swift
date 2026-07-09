import AppKit
import SHAFTCore
import SHAFTTestKit

func runSpriteInkTests() {
    let r = CritterRenderer()
    XCTAssertNotEqual(r.color(for: .body), r.color(for: .eye),
        "body vs eye differ")
    XCTAssertEqual(r.color(for: .eye), NSColor.black, "eye is black")
    let all: [SpriteInk] = [.body, .yellow, .red, .blue, .green, .hatBlue,
        .brown]
    for a in all where a != .body {
        XCTAssertNotEqual(r.color(for: a), r.color(for: .body),
            "\(a) differs from body")
    }
}
