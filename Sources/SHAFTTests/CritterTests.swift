import AppKit
import SHAFTCore
import SHAFTTestKit

func runCritterTests() {
    let r = CritterRenderer()
    let img = r.image(outfit: .crown, size: 40)
    XCTAssertEqual(img.size, NSSize(width: 40, height: 40), "size honored")
    XCTAssertEqual(r.dimension, 20, "square grid is 20")
    XCTAssertTrue(r.gridsAreSquare(), "every grid is 20x20")
    XCTAssertEqual(CritterRenderer().color(for: .body),
        CritterRenderer().color(for: .body), "body color stable")
    XCTAssertTrue(r.hasOutfit(.headphones), "headphones present")
    XCTAssertTrue(r.hasOutfit(.headband), "headband present")
}
