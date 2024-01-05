// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CascableCore Simulated Camera",
    defaultLocalization: "en",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "CascableCore Simulated Camera",
            targets: ["CascableCore Simulated Camera"]),
        .library(name: "StopKit", targets: ["StopKit"])
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(name: "CascableCore Simulated Camera",
                dependencies: ["StopKit"],
                resources: [.copy("Resources/Live View Images")],
                swiftSettings: [.unsafeFlags(["-Xfrontend", "-validate-tbd-against-ir=none"])]),
        .testTarget(name: "CascableCore Simulated Camera Tests", dependencies: ["CascableCore Simulated Camera"]),
        .target(name: "StopKit"),
        .testTarget(name: "StopKit Tests", dependencies: ["StopKit"])
    ]
)
