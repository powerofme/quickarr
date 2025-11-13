// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Quickarr",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "Quickarr",
            targets: ["Quickarr"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Quickarr",
            dependencies: [],
            path: "Quickarr",
            exclude: []
        ),
        .testTarget(
            name: "QuickarrTests",
            dependencies: ["Quickarr"],
            path: "QuickarrTests"
        ),
    ]
)
