import AppKit
import SHAFTCore
import SHAFTTestKit

func runCritterTests() {
    let r = CritterRenderer()

    let img = r.image(mood: .fresh, outfit: .crown, size: 18)
    XCTAssertEqual(img.size, NSSize(width: 18, height: 18),
        "image has requested size")

    XCTAssertNotEqual(r.moodTint(.fresh), r.moodTint(.asleep),
        "mood tints differ")

    XCTAssertNotEqual(r.outfitAccent(.crown), r.outfitAccent(.wizardHat),
        "outfit accents differ")
}
