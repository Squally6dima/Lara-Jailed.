// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "LaraJailed",
    platforms: [.iOS(.v16), .macOS(.v13)],
    products: [.library(name: "LaraJailedCore", targets: ["LaraJailedCore"])],
    targets: [
        .target(name: "LaraJailedCore"),
        .testTarget(name: "LaraJailedCoreTests", dependencies: ["LaraJailedCore"])
    ]
)
