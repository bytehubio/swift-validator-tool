// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

var packageDependencies: [Package.Dependency] = [
    .package(name: "SwiftRegularExpression", url: "https://github.com/nerzh/swift-regular-expression.git", .upToNextMajor(from: "0.2.3")),
    .package(name: "swift-argument-parser", url: "https://github.com/apple/swift-argument-parser", .upToNextMinor(from: "0.4.4")),
    .package(name: "FileUtils", url: "https://github.com/nerzh/SwiftFileUtils", .upToNextMinor(from: "1.3.0")),
]

#if os(Linux)
    packageDependencies.append(.package(name: "EverscaleClientSwift", url: "https://github.com/nerzh/everscale-client-swift", .upToNextMajor(from: "1.6.0")))
#else
    packageDependencies.append(.package(name: "EverscaleClientSwift", path: "/Users/nerzh/mydata/swift_projects/everscale-client-swift"))
#endif

let package = Package(
    name: "validator-tool",
    platforms: [.macOS(.v12)],
    dependencies: packageDependencies,
    targets: [
        .executableTarget(
            name: "validator-tool",
            dependencies: [
                .product(name: "EverscaleClientSwift", package: "EverscaleClientSwift"),
                .product(name: "SwiftRegularExpression", package: "SwiftRegularExpression"),
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "FileUtils", package: "FileUtils"),
            ]
        ),
        .testTarget(
            name: "validator-toolTests",
            dependencies: [
                .product(name: "SwiftRegularExpression", package: "SwiftRegularExpression"),
                .byName(name: "validator-tool"),
                .product(name: "FileUtils", package: "FileUtils")
            ]
        ),
    ],
    swiftLanguageVersions: [SwiftVersion.v5]
)
