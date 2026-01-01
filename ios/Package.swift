// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "PageFlow",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "PageFlow",
            targets: ["PageFlow"]
        ),
    ],
    dependencies: [
        // ZIP file handling for EPUB parsing
        .package(url: "https://github.com/weichsel/ZIPFoundation.git", from: "0.9.0"),
    ],
    targets: [
        .target(
            name: "PageFlow",
            dependencies: ["ZIPFoundation"],
            path: "PageFlow"
        ),
    ]
)

