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
        ),
        .library(
            name: "SenzuRouteKitResolver",
            targets: ["SenzuRouteKitResolver"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/hmlongco/Resolver.git", from: "1.5.1")
    ],
    targets: [
        .target(
            name: "SenzuRouteKit"
        ),
        .target(
            name: "SenzuRouteKitResolver",
            dependencies: [
                "SenzuRouteKit",
                .product(name: "Resolver", package: "Resolver")
            ]
        ),
        .testTarget(
            name: "SenzuRouteKitTests",
            dependencies: ["SenzuRouteKit"]
        )
    ]
)
