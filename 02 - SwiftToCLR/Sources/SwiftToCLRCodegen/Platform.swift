import Foundation

#if os(Windows)

typealias Platform = WindowsPlatform

struct WindowsPlatform {

    static var defaultSDKRoot: String = {
        let developerPath = findDeveloperPath()
        let platformsPath = findPlatforms(in: developerPath)
        return platformsPath.appendingPathComponent("Windows.platform")
            .appendingPathComponent("Developer")
            .appendingPathComponent("SDKs")
            .appendingPathComponent("Windows.sdk")
            .path
    }()

    static let pathSeparator: String = "\\"

    static func findDeveloperPath() -> URL {
        // Dev snapshots seem to install into AppData.
        let userLocalDirectory = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("AppData")
            .appendingPathComponent("Local")
            .appendingPathComponent("Programs")
            .appendingPathComponent("Swift")

        if (try? userLocalDirectory.checkResourceIsReachable()) == true {
            return userLocalDirectory
        }

        // Earlier/release builds install into <boot>/Library/Developer.
        // The assumption here is that the first drive not reserved for floppies is the boot drive.
        let volumes = FileManager.default.mountedVolumeURLs(includingResourceValuesForKeys: [], options: .skipHiddenVolumes)
        let bootVolume = volumes?.compactMap({ $0.pathComponents.first }).first(where: { !$0.hasPrefix("A:") && !$0.hasPrefix("B:") })
        let path: String = [(bootVolume ?? "C:"), "Library", "Developer"].joined(separator: pathSeparator)
        return URL(filePath: path)
    }

    static func findPlatforms(in developerPath: URL) -> URL {
        let platformsPath = developerPath.appendingPathComponent("Platforms")
        let children: [URL]
        do {
            children = try FileManager.default.contentsOfDirectory(
                at: platformsPath,
                includingPropertiesForKeys: [.isDirectoryKey],
                options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants, .skipsPackageDescendants]
            )
        } catch {
            fatalError("Developer path doesn't exist or contain any platforms: \(developerPath), error: \(error)")
        }

        let platformContainer = children.first(where: { (try? $0.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) == true })
        let toolchainName = platformContainer?.lastPathComponent ?? "???"
        return developerPath.appendingPathComponent("Platforms").appendingPathComponent(toolchainName)
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
