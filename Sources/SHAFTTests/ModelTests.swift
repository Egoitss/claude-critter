import SHAFTCore
import SHAFTTestKit

func runModelTests() {
    XCTAssertEqual(ClaudeModel.opus.modelArg, "opus", "opus modelArg")
    XCTAssertEqual(
        ClaudeModel.fable.modelArg, "claude-fable-5", "fable modelArg")
    XCTAssertEqual(ClaudeModel.sonnet.outfit, .headphones, "sonnet outfit")

    XCTAssertEqual(Mood(usageFraction: 0.10), .fresh, "0.10 -> fresh")
    XCTAssertEqual(Mood(usageFraction: 0.65), .focused, "0.65 -> focused")
    XCTAssertEqual(Mood(usageFraction: 0.90), .tired, "0.90 -> tired")
    XCTAssertEqual(Mood(usageFraction: 1.20), .asleep, "1.20 -> asleep")
}
