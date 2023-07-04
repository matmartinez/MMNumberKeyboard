// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "MMNumberKeyboard",
    platforms: [
        .iOS(.v8)
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
            path: "MMNumberKeyboard",
            publicHeadersPath: "."),
    ]
)

