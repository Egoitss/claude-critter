import SHAFTCore
import SHAFTTestKit

func runPixelFontTests() {
    XCTAssertEqual(PixelFont.glyph("5").count, 5, "glyph has 5 rows")
    for row in PixelFont.glyph("5") {
        XCTAssertEqual(row.count, 3, "glyph rows are 3 wide")
    }
    XCTAssertEqual(PixelFont.heart.count, 5, "heart has 5 rows")
    XCTAssertEqual(PixelFont.text("50%").count, 5, "text has 5 rows")
    XCTAssertEqual(PixelFont.text("50%")[0], "###.###.#.#",
        "50% top row: 5 | 0 | %")
    XCTAssertEqual(PixelFont.weekly.count, 5, "W icon has 5 rows")
    for row in PixelFont.weekly {
        XCTAssertEqual(row.count, 5, "W icon rows are 5 wide")
    }
    XCTAssertEqual(PixelFont.dollar.count, 5, "$ icon has 5 rows")
    for row in PixelFont.dollar {
        XCTAssertEqual(row.count, 5, "$ icon rows are 5 wide")
    }
    XCTAssertEqual(PixelFont.glyph(".")[4], "#",
        "dot is 1 wide and sits on the baseline")
    XCTAssertEqual(PixelFont.text("6.50")[4], "###.#.###.###",
        "digits join around the 1-wide dot with 1-column gaps")
}
