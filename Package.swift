// swift-tools-version:5.6
import PackageDescription

let package = Package(
    name: "Session",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(name: "Session", type: .static, targets: ["Session"]),
        .library(name: "SessionDynamic", type: .dynamic, targets: ["Session"])
    ],
    dependencies: [
        .package(url: "git@github.com:apple/swift-docc-plugin.git", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "Session",
            dependencies: [],
            path: "sources/main"
        ),
        .testTarget(
            name: "SessionTests",
            dependencies: ["Session"],
            path: "sources/tests"
        )
    ]
)
