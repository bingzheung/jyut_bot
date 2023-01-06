// swift-tools-version: 5.7

import PackageDescription

let packageDependencies: [Package.Dependency] = {
        #if os(Linux)
        return [.package(url: "https://github.com/apple/swift-log.git", from: "1.4.4"),
                .package(url: "https://github.com/ososoio/SQLite3.git", from: "1.0.0"),
                .package(url: "https://github.com/rapierorg/telegram-bot-swift.git", from: "2.1.2")]
        #else
        return [.package(url: "https://github.com/apple/swift-log.git", from: "1.4.4"),
                .package(url: "https://github.com/rapierorg/telegram-bot-swift.git", from: "2.1.2")]
        #endif
}()

let targetDependencies: [Target.Dependency] = {
        #if os(Linux)
        return [.product(name: "Logging", package: "swift-log"),
                .product(name: "SQLite3", package: "SQLite3"),
                .product(name: "TelegramBotSDK", package: "telegram-bot-swift")]
        #else
        return [.product(name: "Logging", package: "swift-log"),
                .product(name: "TelegramBotSDK", package: "telegram-bot-swift")]
        #endif
}()

let package = Package(
        name: "JyutBot",
        platforms: [.macOS(.v13)],
        products: [
                .executable(name: "jyutbot", targets: ["JyutBot"])
        ],
        dependencies: packageDependencies,
        targets: [
                .executableTarget(
                        name: "JyutBot",
                        dependencies: targetDependencies
                ),
                .testTarget(
                        name: "JyutBotTests",
                        dependencies: ["JyutBot"]
                )
        ]
)
