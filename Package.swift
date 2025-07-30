// swift-tools-version:6.1
import PackageDescription

let package = Package(
    name: "Session",
    platforms: [
        .iOS(.v18)
    ],
    products: [
        .library(name: "Session", type: .static, targets: ["Session"]),
        .library(name: "SessionDynamic", type: .dynamic, targets: ["Session"])
    ],
    dependencies: [
        .package(url: "git@github.com:apple/swift-docc-plugin.git", from: "1.4.3")
    ],
    targets: [
        .target(
            name: "Session",
            dependencies: [],
            path: "Sources/Main"
        ),
        .testTarget(
            name: "SessionTests",
            dependencies: ["Session"],
            path: "Sources/Tests"
        )
    ]
)
