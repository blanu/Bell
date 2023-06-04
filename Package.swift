// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Bell",
    platforms: [.macOS(.v13)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Bell",
            targets: ["Bell"]),
    ],
    dependencies: [
        .package(url: "https://github.com/OperatorFoundation/Abacus", branch: "main"),
        .package(url: "https://github.com/OperatorFoundation/Datable", branch: "main"),
        .package(url: "https://github.com/OperatorFoundation/Text", branch: "main"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Bell",
            dependencies: [
                "Abacus",
                "Datable",
                "Text",
            ]
        ),
        .testTarget(
            name: "BellTests",
            dependencies: ["Bell"]),
    ],
    swiftLanguageVersions: [.v5]
)
