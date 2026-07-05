// swift-tools-version:5.9
import PackageDescription

// NOTE: This environment has Command Line Tools only (no Xcode), so XCTest
// and swift-testing are unavailable and `swift test` cannot run. Tests run
// as a plain executable (`swift run SHAFTTests`) using SHAFTTestKit, which
// provides XCTest-named assert functions. Reversible: to move to XCTest,
// drop SHAFTTestKit + SHAFTTests and add a `.testTarget`.
let package = Package(
    name: "SHAFT",
    platforms: [.macOS(.v13)],
    targets: [
        .target(name: "SHAFTCore"),
        .target(name: "SHAFTTestKit"),
        .executableTarget(
            name: "SHAFT", dependencies: ["SHAFTCore"]),
        .executableTarget(
            name: "SHAFTTests",
            dependencies: ["SHAFTCore", "SHAFTTestKit"]),
        .executableTarget(
            name: "SpritePreview", dependencies: ["SHAFTCore"]),
    ]
)
