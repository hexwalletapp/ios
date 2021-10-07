// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CryptoCompareAPI",
    platforms: [
        .iOS(.v13),
    ],
    products: [
        .library(name: "CryptoCompareAPI", targets: ["CryptoCompareAPI"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "CryptoCompareAPI",
            dependencies: []
        ),
        .testTarget(
            name: "CryptoCompareAPITests",
            dependencies: ["CryptoCompareAPI"]
        ),
    ]
)
