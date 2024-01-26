// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CascableCore Simulated Camera",
    defaultLocalization: "en",
    products: [
        .library(name: "CascableCore", targets: ["CascableCore"]),
        .library(name: "StopKit", targets: ["StopKit"]),
        .library(name: "CascableCore Simulated Camera", targets: ["CascableCoreSimulatedCamera"])
    ],
    targets: [
        .target(name: "CascableCore", // The public CascableCore API.
                dependencies: ["StopKit"],
                swiftSettings: [
                    .interoperabilityMode(.Cxx),
                    .unsafeFlags(["-emit-clang-header-path", ".build/CascableCore-Swift.h"])
                ]),
        .target(name: "StopKit", // StopKit, a library for working with units of light.
                swiftSettings: [
                    .interoperabilityMode(.Cxx),
                    .unsafeFlags(["-emit-clang-header-path", ".build/StopKit-Swift.h"])
                ]),
        .testTarget(name: "StopKit Tests", dependencies: ["StopKit"], swiftSettings: [.interoperabilityMode(.Cxx)]), // StopKit tests.
        .target(name: "CascableCoreSimulatedCamera", // The simulated camera - an example implementation of the CascableCore API.
                dependencies: ["StopKit", "CascableCore"],
                resources: [.copy("Resources/Live View Images")],
                swiftSettings: [
                    .interoperabilityMode(.Cxx),
                    .unsafeFlags(["-emit-clang-header-path", ".build/CascableCoreSimulatedCamera-Swift.h"]),
                    .unsafeFlags(["-Xfrontend", "-validate-tbd-against-ir=none"])
                ]),
        .testTarget(name: "CascableCore Simulated Camera Tests", // Simulated camera tests.
                    dependencies: ["CascableCoreSimulatedCamera"],
                    swiftSettings: [.interoperabilityMode(.Cxx)])
    ]
)
