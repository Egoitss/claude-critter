import AppKit
import SHAFTCore
import SHAFTTestKit

func runCritterTests() {
    let r = CritterRenderer()

    let img = r.image(usage: 0.3, outfit: .crown, size: 18)
    XCTAssertEqual(img.size, NSSize(width: 18, height: 18),
        "image has requested size")

    XCTAssertNotEqual(r.bodyColor, r.depletedColor,
        "fresh body vs depleted colors differ")

    XCTAssertNotEqual(r.outfitAccent(.crown), r.outfitAccent(.wizardHat),
        "outfit accents differ")

    // Usage gauge: 0% => no depleted rows (grey line below the body);
    // 100% => grey reaches the top body row.
    let (top, bot) = r.bodyRowRange
    XCTAssertTrue(r.greyFromRow(usage: 0) > bot, "0% leaves body un-greyed")
    XCTAssertTrue(r.greyFromRow(usage: 1) <= top, "100% greys whole body")
}
