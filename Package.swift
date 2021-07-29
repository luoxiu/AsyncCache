// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AsyncCache",
    platforms: [.macOS(.v12), .iOS(.v15), .watchOS(.v8), .tvOS(.v15)],
    products: [
        .library(name: "AsyncCache", targets: ["AsyncCache"]),
    ],
    targets: [
        .target(name: "AsyncCache", dependencies: []),
        .testTarget(name: "AsyncCacheTests", dependencies: ["AsyncCache"]),
    ]
)
