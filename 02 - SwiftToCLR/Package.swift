// swift-tools-version: 5.9

import Foundation
import PackageDescription

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
            swiftSettings: [clangSwiftSettings],
            linkerSettings: [clangLinkerSettings]
        ),
        .target(name: "clang", publicHeadersPath: "include", cSettings: [.headerSearchPath("include")])
    ]
)

// On the Mac, clang's binary is in the Xcode toolchain. We'll need to have platform-specific values for this.
var clangSwiftSettings: SwiftSetting {
    let developerPath = findDeveloperPath()
    return .unsafeFlags([
        "-I\(developerPath)/Toolchains/XcodeDefault.xctoolchain/usr/lib/libclang.dylib"
    ])
}

var clangLinkerSettings: LinkerSetting {
    let developerPath = findDeveloperPath()
    return .unsafeFlags([
        "-rpath", "\(developerPath)/Toolchains/XcodeDefault.xctoolchain/usr/lib",
        "-L\(developerPath)/Toolchains/XcodeDefault.xctoolchain/usr/lib",
        "-lclang"
    ])
}

func findDeveloperPath() -> String {

    let task = Process()
    let stdOut = Pipe()

    task.standardOutput = stdOut
    task.arguments = ["--print-path"]
    task.executableURL = URL(fileURLWithPath: "/usr/bin/xcode-select")

    let defaultDeveloperPath: String = "/Applications/Xcode.app/Contents/Developer"

    do {
        try task.run()
    } catch {
        print("warning: Running xcode-select failed - falling back to default path: \(error)")
        return defaultDeveloperPath
    }

    let data = stdOut.fileHandleForReading.readDataToEndOfFile()
    let output = String(decoding: data, as: UTF8.self).trimmingCharacters(in: .whitespacesAndNewlines)

    if output.isEmpty {
        print("warning: Running xcode-select returned no path - falling back to default path")
        return defaultDeveloperPath
    }

    if !FileManager.default.fileExists(atPath: output) {
        print("warning: Running xcode-select returned a path, but it doesn't exist - falling back to default path")
        return defaultDeveloperPath
    }

    return output
}
