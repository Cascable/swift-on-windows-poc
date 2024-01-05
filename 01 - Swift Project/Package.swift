// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CascableCore Simulated Camera",
    defaultLocalization: "en",
    products: [
        .library(name: "CascableCoreAPI", targets: ["CascableCoreAPI"]),
        .library(name: "StopKit", targets: ["StopKit"]),
        .library(name: "CascableCore Simulated Camera", targets: ["CascableCoreSimulatedCamera"])
    ],
    targets: [
        .target(name: "CascableCoreAPI", dependencies: ["StopKit"]), // The public CascableCore API.
        .target(name: "StopKit"), // StopKit, a library for working with units of light.
        .testTarget(name: "StopKit Tests", dependencies: ["StopKit"]), // StopKit tests.
        .target(name: "CascableCoreSimulatedCamera", // The simulated camera - an example implementation of the CascableCore API.
                dependencies: ["StopKit", "CascableCoreAPI"],
                resources: [.copy("Resources/Live View Images")],
                swiftSettings: [.unsafeFlags(["-Xfrontend", "-validate-tbd-against-ir=none"])]),
        .testTarget(name: "CascableCore Simulated Camera Tests", dependencies: ["CascableCoreSimulatedCamera"]) // Simulated camera tests.
    ]
)
