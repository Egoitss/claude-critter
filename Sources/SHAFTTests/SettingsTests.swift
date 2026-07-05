import Foundation
import SHAFTCore
import SHAFTTestKit

func runSettingsTests() {
    // Substring mapping tolerates ids and variants.
    XCTAssertEqual(SettingsModel.model(from: "opus[1m]"), .opus,
        "maps an opus variant")
    XCTAssertEqual(SettingsModel.model(from: "claude-sonnet-5"), .sonnet,
        "maps a full sonnet id")
    XCTAssertEqual(SettingsModel.model(from: "Haiku"), .haiku,
        "case-insensitive")
    XCTAssertNil(SettingsModel.model(from: "gpt-4"), "unknown -> nil")

    // Reads the model out of a settings.json file.
    let tmp = NSTemporaryDirectory() + "shaft-settings-test.json"
    try? "{\"model\":\"fable\"}".write(toFile: tmp, atomically: true,
                                       encoding: .utf8)
    XCTAssertEqual(SettingsModel.current(path: tmp), .fable,
        "reads model from a settings file")
    XCTAssertNil(SettingsModel.current(path: "/no/such/file.json"),
        "missing file -> nil")
}
