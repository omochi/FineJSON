// swift-tools-version:4.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FineJSON",
    products: [
        .library(name: "FineJSON", targets: ["FineJSON"]),
    ],
    dependencies: [
        .package(url: "https://github.com/omochi/RichJSONParser.git", .upToNextMajor(from: "2.0.0")),
    ],
    targets: [
        .target(name: "FineJSON", dependencies: ["RichJSONParser"]),
        .testTarget(name: "FineJSONTests", dependencies: ["FineJSON"]),
    ]
)
