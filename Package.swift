// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MarkPad",
    platforms: [.macOS(.v14)],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-markdown.git", from: "0.8.0"),
        .package(url: "https://github.com/nodes-app/swift-markdown-engine.git", from: "0.13.0"),
        .package(url: "https://github.com/sparkle-project/Sparkle", from: "2.6.4"),
    ],
    targets: [
        .executableTarget(
            name: "MarkPad",
            dependencies: [
                .product(name: "Markdown", package: "swift-markdown"),
                .product(name: "MarkdownEngine", package: "swift-markdown-engine"),
                .product(name: "Sparkle", package: "Sparkle"),
            ],
            path: "Sources/MarkPad"
        ),
        .testTarget(
            name: "MarkPadTests",
            dependencies: ["MarkPad"],
            path: "Tests/MarkPadTests"
        ),
    ]
)
