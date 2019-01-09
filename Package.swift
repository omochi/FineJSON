// swift-tools-version:4.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FineJSON",
    products: [
        .library(name: "FineJSON", targets: ["FineJSON"]),
    ],
    dependencies: [
        .package(url: "https://github.com/omochi/yajl-swift-build.git", .upToNextMajor(from: "1.0.0")),
        .package(url: "https://github.com/omochi/OrderedDictionary.git", .upToNextMajor(from: "1.0.0")),
    ],
    targets: [
        .target(name: "FineJSON", dependencies: ["yajl", "OrderedDictionary"]),
        .testTarget(name: "FineJSONTests", dependencies: ["FineJSON"]),
    ]
)
