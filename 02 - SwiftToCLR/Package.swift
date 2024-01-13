// swift-tools-version: 5.9

import Foundation
import PackageDescription

let package = Package(
    name: "SwiftToCLR",
    platforms: [.macOS("13.0")],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.2.0"),
        .package(url: "https://github.com/apple/swift-collections.git", from: "1.0.6")
    ],
    targets: [
        .executableTarget(
            name: "SwiftToCLR",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .target(name: "SwiftToCLRCodegen")
            ]
        ),
        .target(
            name: "SwiftToCLRCodegen",
            dependencies: [
                .product(name: "OrderedCollections", package: "swift-collections"),
                .target(name: "clang")
            ],
            swiftSettings: [clangSwiftSettings],
            linkerSettings: [clangLinkerSettings]
        ),
        .target(
            name: "clang",
            publicHeadersPath: "include",
            cSettings: [.headerSearchPath("include")]
        ),
        .testTarget(
            name: "SwiftToCLRTests",
            dependencies: [.target(name: "SwiftToCLRCodegen"), .target(name: "clang")],
            resources: [.copy("Resources")]
        )
    ]
)

#if os(Windows)

var pathSeparator: String { return "\\" }

// On the Windows, clang's binary is in the Swift toolchain.
var clangSwiftSettings: SwiftSetting {
    let libPath = findLibPath()
    return .unsafeFlags([
        "-I\(libPath)" + pathSeparator + "libclang.lib"
    ])
}

var clangLinkerSettings: LinkerSetting {
    let libPath = findLibPath()
    return .unsafeFlags([
        "-L\(libPath)",
        "-llibclang"
    ])
}

func findLibPath() -> String {
    let developerPath = findDeveloperPath()
    let toolchain = findToolchain(in: developerPath)
    return [toolchain, "usr", "lib"].joined(separator: pathSeparator)
}

func findDeveloperPath() -> String {
    // Dev snapshots seem to install into AppData.
    let userLocalDirectory = FileManager.default.homeDirectoryForCurrentUser
        .appendingPathComponent("AppData")
        .appendingPathComponent("Local")
        .appendingPathComponent("Programs")
        .appendingPathComponent("Swift")

    if (try? userLocalDirectory.checkResourceIsReachable()) == true {
        return userLocalDirectory.pathComponents.joined(separator: pathSeparator)
    }

    // Earlier/release builds install into <boot>/Library/Developer.
    // The assumption here is that the first drive not reserved for floppies is the boot drive.
    let volumes = FileManager.default.mountedVolumeURLs(includingResourceValuesForKeys: [], options: .skipHiddenVolumes)
    let bootVolume = volumes?.compactMap({ $0.pathComponents.first }).first(where: { !$0.hasPrefix("A:") && !$0.hasPrefix("B:") })
    return [(bootVolume ?? "C:"), "Library", "Developer"].joined(separator: pathSeparator)
}

func findToolchain(in developerPath: String) -> String {
    let toolchainsPath = URL(fileURLWithPath: developerPath + pathSeparator + "Toolchains")
    guard let children = try? FileManager.default.contentsOfDirectory(
        at: toolchainsPath,
        includingPropertiesForKeys: [.isDirectoryKey],
        options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants, .skipsPackageDescendants]
    ) else {
        fatalError("Developer path doesn't exist or contain any toolchains: " + developerPath)
    }
    let toolchain = children.first(where: { (try? $0.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) == true })
    let toolchainName = toolchain?.lastPathComponent ?? "???"
    return [developerPath, "Toolchains", toolchainName].joined(separator: pathSeparator)
}

#else

// On the Mac, clang's binary is in the Xcode toolchain.
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

#endif
