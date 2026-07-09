import AppKit
import SHAFTCore
import SHAFTTestKit

func runCritterTests() {
    let r = CritterRenderer()

    // Every bundled asset (base + all outfits + money bag) must load.
    XCTAssertTrue(r.assetsLoad(), "all critter art assets load")

    // Rendered image honors the requested size.
    let img = r.image(outfit: .crown, size: 128)
    XCTAssertEqual(img.size, NSSize(width: 128, height: 128),
        "image has requested size")

    // Spending overlay does not change the image dimensions.
    let spend = r.image(outfit: .wizardHat, spending: true, size: 96)
    XCTAssertEqual(spend.size, NSSize(width: 96, height: 96),
        "spending image has requested size")
}
