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
    dependencies: [
        .package(url: "https://github.com/hmlongco/Resolver.git", from: "1.5.1")
    ],
    targets: [
        .target(
            name: "SenzuRouteKit",
            dependencies: [
                .product(name: "Resolver", package: "Resolver")
            ]
        ),
        .testTarget(
            name: "SenzuRouteKitTests",
            dependencies: ["SenzuRouteKit"]
        )
    ]
)
