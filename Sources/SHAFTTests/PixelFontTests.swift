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
}
