// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MarkPad",
    platforms: [.macOS(.v14)],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-markdown.git", from: "0.8.0"),
    ],
    targets: [
        .executableTarget(
            name: "MarkPad",
            dependencies: [.product(name: "Markdown", package: "swift-markdown")],
            path: "Sources/MarkPad"
        ),
    ]
)
