// swift-tools-version: 5.9

import PackageDescription

// On the Mac, clang's binary is in the Xcode toolchain. We'll need to have platform-specific values for this.
let clangSwiftSettings: [SwiftSetting] = [
    .unsafeFlags(["-I/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/libclang.dylib"])
]

let clangLinkerSettings : [LinkerSetting]  = [
    .unsafeFlags(["-rpath", "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib",
                  "-L/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib",
                  "-lclang"])
]

let package = Package(
    name: "SwiftToCLR",
    platforms: [.macOS("13.0")],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.2.0"),
    ],
    targets: [
        .executableTarget(
            name: "SwiftToCLR",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .target(name: "clang")
            ],
            swiftSettings: clangSwiftSettings,
            linkerSettings: clangLinkerSettings
        ),
        .target(name: "clang", publicHeadersPath: "include", cSettings: [.headerSearchPath("include")])
    ]
)
