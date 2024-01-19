import Foundation
import ArgumentParser
import SwiftToCLRCodegen

struct UnmanagedToManagedCommand: ParsableCommand {

    static var configuration = CommandConfiguration(commandName: "unmanaged-to-managed",
                                                    abstract: "Wrap an 'unmanaged' C++ API into a 'managed' one, accessible by the .NET CLR.")

    @Argument(help: "The to-be-wrapped input header file.")
    var inputHeader: String

    @Option(name: .long, help: "The input namespace to target.")
    var inputNamespace: String

    @Option(name: .long, help: "The output namespace to contain the generated wrapper classes.")
    var outputNamespace: String

    @Option(name: .long, help: "The platform SDK root, for finding system headers. If omitted, a basic auto-detection will be used.")
    var platformRoot: String?

    @Option(name: .customLong("wrapped-object-name"), help: "The variable name of the wrapped object.")
    var wrappedObjectVariableName: String = "wrappedObj"

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

        let generatedFiles: [GeneratedFile] = try UnmanagedToManagedOperation.execute(
            inputHeaderPath: inputHeader,
            inputNamespace: inputNamespace,
            wrappedObjectVariableName: wrappedObjectVariableName,
            outputNamespace: outputNamespace,
            platformRoot: platformRoot,
            verbose: verbose
        )

        for file in generatedFiles {
            let outputPath = URL(fileURLWithPath: outputDirectory)
                .appendingPathComponent(file.name)
            try file.contents.write(to: outputPath)
            print("Successfully wrote", file.name)
        }
    }
}
