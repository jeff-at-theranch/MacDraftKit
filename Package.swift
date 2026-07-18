// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "MacDraftKit",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .library(name: "MacDraftKit", targets: ["MacDraftKit"]),
        .executable(name: "macdraftinfo", targets: ["macdraftinfo"]),
        .executable(name: "macdraftextract", targets: ["macdraftextract"]),
        .executable(name: "macdraftdiff", targets: ["macdraftdiff"])
    ],
    targets: [
        .target(name: "MacDraftKit"),
        .executableTarget(name: "macdraftinfo", dependencies: ["MacDraftKit"]),
        .executableTarget(name: "macdraftextract", dependencies: ["MacDraftKit"]),
        .executableTarget(name: "macdraftdiff", dependencies: ["MacDraftKit"]),
        .testTarget(name: "MacDraftKitTests", dependencies: ["MacDraftKit"])
    ]
)
