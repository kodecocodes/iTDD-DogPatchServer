// swift-tools-version:4.0
import PackageDescription

let package = Package(
  name: "DogPatchServer",
  dependencies: [
    .package(url: "https://github.com/vapor/auth.git", from: "2.0.4"),
    .package(url: "https://github.com/vapor/multipart.git", from: "3.0.4"),
    .package(url: "https://github.com/vapor/fluent-postgresql.git", from: "1.0.0"),
    .package(url: "https://github.com/vapor/validation.git", from: "2.1.1"),
    .package(url: "https://github.com/vapor/vapor.git", from: "3.3.0"),
    ],
  targets: [
    .target(name: "App", dependencies: [
      "Authentication",
      "FluentPostgreSQL",
      "Validation",
      "Vapor",
      ]),
    .target(name: "Run", dependencies: ["App"]),
    .testTarget(name: "AppTests", dependencies: ["App"])
  ]
)
