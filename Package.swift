// swift-tools-version: 5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NymStatusWidget",
    platforms: [.macOS(.v11)],
    products: [
        .executable(name: "NymStatusWidget", targets: ["NymStatusWidget"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .executableTarget(
            name: "NymStatusWidget",
            resources: [.process("Resources")]),
    ]
)
