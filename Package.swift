// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "ZoronShaderOptimizer",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "ZoronShaderOptimizer",
            type: .dynamic,
            targets: ["ZoronShaderOptimizer"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "ZoronShaderOptimizer",
            dependencies: [],
            path: "Sources/ZoronShaderOptimizer",
            resources: []
        )
    ]
)
