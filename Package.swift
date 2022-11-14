// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let packageDependencies: [Package.Dependency] = {
        #if os(Linux)
        return [.package(url: "https://github.com/ososoio/SQLite3.git", from: "1.0.0"),
                .package(url: "https://github.com/rapierorg/telegram-bot-swift.git", from: "2.1.2")]
        #else
        return [.package(url: "https://github.com/rapierorg/telegram-bot-swift.git", from: "2.1.2")]
        #endif
}()

let targetDependencies: [Target.Dependency] = {
        #if os(Linux)
        return [.product(name: "SQLite3", package: "SQLite3"),
                .product(name: "TelegramBotSDK", package: "telegram-bot-swift")]
        #else
        return [.product(name: "TelegramBotSDK", package: "telegram-bot-swift")]
        #endif
}()

let package = Package(
        name: "JyutBot",
        products: [
                .executable(name: "jyutbot", targets: ["JyutBot"])
        ],
        dependencies: packageDependencies,
        targets: [
                // Targets are the basic building blocks of a package. A target can define a module or a test suite.
                // Targets can depend on other targets in this package, and on products in packages this package depends on.
                .executableTarget(
                        name: "JyutBot",
                        dependencies: targetDependencies
                ),
                .testTarget(
                        name: "JyutBotTests",
                        dependencies: ["JyutBot"]
                ),
        ]
)
