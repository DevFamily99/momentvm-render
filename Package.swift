// swift-tools-version:5.5
import PackageDescription


let package = Package(
  name: "CoreMomentvmRenderer",
  platforms: [
    .macOS(.v12),
  ],
  dependencies: [
    // 💧 A server-side Swift web framework.
    .package(url: "https://github.com/vapor/vapor.git", from: "4.5.0"),
    .package(url: "https://github.com/vapor/fluent.git", from: "4.0.0"),
    .package(url: "https://github.com/vapor/fluent-postgres-driver.git", from: "2.0.0"),
    .package(url: "https://github.com/vapor/leaf.git", from: "4.0.0"),
    // custom requirements
    .package(url: "https://github.com/vapor/jwt.git", from: "4.0.0"),
    .package(url: "https://github.com/vapor/redis.git", from: "4.0.0"),
    .package(url: "https://github.com/skelpo/JSON", from: "1.0.0"),
  ],
  targets: [
    .target(name: "App", dependencies: [
      .product(name: "Fluent", package: "fluent"),
      .product(name: "FluentPostgresDriver", package: "fluent-postgres-driver"),
      // .product(name: "FluentSQLiteDriver", package: "fluent-sqlite-driver"),
      .product(name: "Vapor", package: "vapor"),
      .product(name: "Leaf", package: "leaf"),
      .product(name: "Redis", package: "redis"),
      .product(name: "JWT", package: "jwt"),
      .product(name: "JSON", package: "JSON"),
      // .product(name: "CurlyClient", package: "curlyclient"),
      
    ]),
    .executableTarget(name: "Run", dependencies: [.target(name: "App")]),
    .testTarget(name: "AppTests", dependencies: [
      .target(name: "App"),
    ])
  ]
)
