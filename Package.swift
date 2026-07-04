// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "SHAFT",
    platforms: [.macOS(.v13)],
    targets: [
        .target(name: "SHAFTCore"),
        .executableTarget(
            name: "SHAFT", dependencies: ["SHAFTCore"]),
        .testTarget(
            name: "SHAFTCoreTests", dependencies: ["SHAFTCore"]),
    ]
)
