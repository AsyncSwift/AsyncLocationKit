// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AsyncLocationKit",
    platforms: [
        .iOS("13.0"),
        .macOS(.v12),
        .watchOS(.v6)
    ],
    
    products: [
        .library(
            name: "AsyncLocationKit",
            targets: ["AsyncLocationKit"]),
    ],
    
    dependencies: [],
    targets: [
        .target(
            name: "AsyncLocationKit",
            dependencies: []),
        .testTarget(
            name: "AsyncLocationKitTests",
            dependencies: ["AsyncLocationKit"]),
    ],
    
    swiftLanguageVersions: [.version("5.5")]
)
