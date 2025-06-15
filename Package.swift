// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "mastermindSwift",
    platforms: [
        .macOS(.v11)
    ],

    dependencies: [
        .package(url: "https://github.com/rensbreur/SwiftTUI.git", branch: "main"),
        .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.10.0")),
        .package(
            url: "https://github.com/SwiftyBeaver/SwiftyBeaver.git", .upToNextMajor(from: "2.0.0")),
    ],
    targets: [
        .executableTarget(
            name: "mastermindSwift",
            dependencies: [
                "SwiftTUI",
                "Alamofire",
                "SwiftyBeaver",
            ])
    ]
)
