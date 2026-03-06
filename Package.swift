// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SenzuRouteKit",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "SenzuRouteKit",
            targets: ["SenzuRouteKit"]
        )
    ],
    targets: [
        .target(
            name: "SenzuRouteKit"
        ),
        .testTarget(
            name: "SenzuRouteKitTests",
            dependencies: ["SenzuRouteKit"]
        )
    ]
)
