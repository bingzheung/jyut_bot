// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "JyutBot",
    products: [
                .executable(name: "jyutbot", targets: ["JyutBot"])
    ],
    dependencies: [
                .package(url: "https://github.com/rapierorg/telegram-bot-swift.git", from: "2.1.2"),
                .package(url: "https://github.com/apple/swift-log.git", from: "1.4.4")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .executableTarget(
            name: "JyutBot",
            dependencies: [
                    .product(name: "TelegramBotSDK", package: "telegram-bot-swift"),
                    .product(name: "Logging", package: "swift-log")
            ]
        ),
        .testTarget(
            name: "JyutBotTests",
            dependencies: ["JyutBot"]
        ),
    ]
)
