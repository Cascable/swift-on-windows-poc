import Foundation

#if os(Windows)

typealias Platform = WindowsPlatform

struct WindowsPlatform {

    static var defaultSDKRoot: String = {
        let developerPath = findDeveloperPath()
        let platformsPath = findPlatforms(in: developerPath)
        return [platformsPath, "Windows.platform", "Developer", "SDKs", "Windows.sdk"].joined(separator: pathSeparator)
    }()

    static let pathSeparator: String = "\\"

    static func findDeveloperPath() -> String {
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

    static func findPlatforms(in developerPath: String) -> String {
        let platformsPath = URL(fileURLWithPath: developerPath + pathSeparator + "Platforms")
        guard let children = try? FileManager.default.contentsOfDirectory(
            at: platformsPath,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants, .skipsPackageDescendants]
        ) else {
            fatalError("Developer path doesn't exist or contain any toolchains: " + developerPath)
        }
        let platformContainer = children.first(where: { (try? $0.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) == true })
        let toolchainName = platformContainer?.lastPathComponent ?? "???"
        return [developerPath, "Platforms", toolchainName].joined(separator: pathSeparator)
    }
}

#else

typealias Platform = MacOSPlatform

struct MacOSPlatform {

    static var defaultSDKRoot: String {
        let developerPath = findDeveloperPath()
        return "\(developerPath)/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk"
    }

    private static func findDeveloperPath() -> String {

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
}

#endif
