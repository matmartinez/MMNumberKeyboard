// swift-tools-version:5.4
import PackageDescription

let package = Package(
    name: "MMNumberKeyboard",
    platforms: [
        .iOS(.v10)
    ],
    products: [
        .library(
            name: "MMNumberKeyboard",
            targets: ["MMNumberKeyboard"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "MMNumberKeyboard",
            path: "Classes",
            resources: [.process("Images")],
            publicHeadersPath: "."
            ),
    ]
)

