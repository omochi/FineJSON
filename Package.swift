// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "FineJSON",
    products: [
        .library(name: "FineJSON", targets: ["FineJSON"]),
    ],
    dependencies: [
        .package(url: "https://github.com/omochi/RichJSONParser.git", from: "3.0.0"),
    ],
    targets: [
        .target(name: "FineJSON", dependencies: ["RichJSONParser"]),
        .testTarget(name: "FineJSONTests", dependencies: ["FineJSON"]),
    ]
)
