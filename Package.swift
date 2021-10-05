// swift-tools-version:5.2
import PackageDescription

let package = Package(
    name: "DogPatchServer",
    platforms: [
       .macOS(.v10_15)
    ],
    dependencies: [
      .package(url: "https://github.com/vapor/vapor.git", .exact("4.48.3")),
      .package(url: "https://github.com/vapor/fluent.git", .exact("4.3.1")),        
      .package(url: "https://github.com/vapor/fluent-postgres-driver.git", .exact("2.1.3")),
    ],
    targets: [
        .target(
            name: "App",
            dependencies: [
                .product(name: "Fluent", package: "fluent"),
                .product(name: "FluentPostgresDriver", package: "fluent-postgres-driver"),
                .product(name: "Vapor", package: "vapor")
            ],
            swiftSettings: [
                .unsafeFlags(["-cross-module-optimization"], .when(configuration: .release))
            ]
        ),
        .target(name: "Run", dependencies: [.target(name: "App")]),
        .testTarget(name: "AppTests", dependencies: [
            .target(name: "App"),
            .product(name: "XCTVapor", package: "vapor"),
        ])
    ]
)
