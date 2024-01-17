// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "BasicTest",
    products: [.library(name: "BasicTest", targets: ["BasicTest"])],
    targets: [
        .target(
            name: "BasicTest",
            swiftSettings: [
                .interoperabilityMode(.Cxx),
                .unsafeFlags(["-emit-clang-header-path", ".build/BasicTest-Swift.h"])
            ]
        )
    ]
)
