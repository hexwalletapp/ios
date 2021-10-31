// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BitqueryAPI",
    platforms: [
        .iOS(.v13),
    ],
    products: [
        .library(name: "BitqueryAPI", targets: ["BitqueryAPI"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "BitqueryAPI",
            dependencies: []
        ),
        .testTarget(
            name: "BitqueryAPITests",
            dependencies: ["BitqueryAPI"]
        ),
    ]
)
