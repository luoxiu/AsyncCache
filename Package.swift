// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AsyncCache",
    platforms: [.macOS(.v12), .iOS(.v15), .watchOS(.v8), .tvOS(.v15)],
    products: [
        .library(name: "LRUCache", targets: ["LRUCache"]),
    ],
    targets: [
        .target(name: "LRUCache", dependencies: []),
        .testTarget(name: "LRUCacheTests", dependencies: ["LRUCache"]),
        .target(name: "DiskLRUCache", dependencies: ["LRUCache"]),
    ]
)
