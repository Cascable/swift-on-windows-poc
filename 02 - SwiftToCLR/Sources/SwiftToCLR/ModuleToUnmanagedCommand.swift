import Foundation
import ArgumentParser
import SwiftToCLRCodegen

struct ModuleToUnmanagedCommand: ParsableCommand {

    static var configuration = CommandConfiguration(commandName: "module-to-unmanaged",
                                                    abstract: "Wrap a Swift module defined in C++ into an 'unmanaged' C++ API, accessible by compilers other than clang.")

    @Argument(help: "The to-be-wrapped input header file.")
    var inputHeader: String

    @Option(name: .long, help: "The input module name to target.")
    var inputModule: String

    @Option(name: .long, help: "The output namespace to contain the generated wrapper classes.")
    var outputNamespace: String

    @Option(name: .long, help: "The platform SDK root, for finding system headers. If omitted, a basic auto-detection will be used.")
    var platformRoot: String?

    @Option(name: .customLong("cxx-interop"), help: "The directory containing the Swift C++ interop headers. It should be named 'swiftToCxx'.")
    var cxxInteropHeaderDirectory: String

    @Option(name: .customLong("wrapped-object-name"), help: "The variable name of the wrapped object.")
    var wrappedObjectVariableName: String = "swiftObj"

    @Option(name: .shortAndLong, help: "The output directory. C++ implementation and header files will be emitted here, named after the output namespace.")
    var outputDirectory: String

    @Flag(name: .shortAndLong, help: "Output more stuff.")
    var verbose: Bool = false

    mutating func run() throws {

        guard FileManager.default.fileExists(atPath: inputHeader) else {
            throw ValidationError("Input file doesn't exist!")
        }

        guard FileManager.default.fileExists(atPath: outputDirectory) else {
            throw ValidationError("Output directory doesn't exist!")
        }

        print("Using clang version:", clangVersionString())

        let interopParent = URL(fileURLWithPath: cxxInteropHeaderDirectory).deletingLastPathComponent().path

        let generatedFiles: [GeneratedFile] = try ModuleToUnmanagedOperation.execute(
            inputHeaderPath: inputHeader,
            inputModuleName: inputModule,
            wrappedObjectVariableName: wrappedObjectVariableName,
            outputNamespace: outputNamespace,
            platformRoot: platformRoot,
            cxxInteropContainerPath: interopParent,
            verbose: verbose)

        for file in generatedFiles {
            let outputPath = URL(fileURLWithPath: outputDirectory)
                .appendingPathComponent(file.name)
            try file.contents.write(to: outputPath)
        }
    }
}
