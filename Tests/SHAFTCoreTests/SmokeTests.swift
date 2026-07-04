import XCTest
@testable import SHAFTCore

final class SmokeTests: XCTestCase {
    func testCoreVersion() {
        XCTAssertEqual(SHAFTCore.version, "0.1.0")
    }
}
