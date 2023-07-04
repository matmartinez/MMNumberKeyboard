// swift-tools-version:5.3
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
            publicHeadersPath: "."),
    ]
)

