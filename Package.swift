// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PokedexData",
    platforms: [.iOS(.v13), .macOS(.v10_15)],
    products: [
        .library(
            name: "PokedexData",
            targets: ["PokedexData"]),
    ],
    dependencies: [
        .package(path: "../PokedexDomain"),
        .package(path: "../SwiftNetworking")
    ],
    targets: [
        .target(
            name: "PokedexData",
            dependencies: ["PokedexDomain", "SwiftNetworking"]),
        .testTarget(
            name: "PokedexDataTests",
            dependencies: ["PokedexData"]),
    ]
)
