import Foundation
import ArgumentParser
import SwiftToCLRCodegen

struct UnmanagedToManagedCommand: ParsableCommand {

    static var configuration = CommandConfiguration(commandName: "unmanaged-to-managed",
                                                    abstract: "Wrap an 'unmanaged' C++ API into a 'managed' one, accessible by the .NET CLR.")

    @OptionGroup var commonOptions: CommonOptions

    @Option(name: .shortAndLong, help: "The output directory. C++ implementation and header files will be emitted here, named after the output namespace.")
    var outputDirectory: String

    @Option(name: .customLong("wrapped-object-name"), help: "The variable name of the wrapped object. Defaults to 'wrappedObj'.")
    var wrappedObjectVariableName: String = "wrappedObj"

    mutating func run() throws {

        guard FileManager.default.fileExists(atPath: commonOptions.inputHeader) else {
            throw ValidationError("Input file doesn't exist!")
        }

        guard FileManager.default.fileExists(atPath: outputDirectory) else {
            throw ValidationError("Output directory doesn't exist!")
        }

        print("Using clang version:", clangVersionString())

        let generatedFiles: [GeneratedFile] = try UnmanagedToManagedOperation.execute(
            inputHeaderPath: commonOptions.inputHeader,
            inputNamespace: commonOptions.inputNamespace,
            wrappedObjectVariableName: wrappedObjectVariableName,
            outputNamespace: commonOptions.outputNamespace,
            platformRoot: commonOptions.platformRoot,
            verbose: commonOptions.verbose
        )

        for file in generatedFiles {
            let outputPath = URL(fileURLWithPath: outputDirectory)
                .appendingPathComponent(file.name)
            try file.contents.write(to: outputPath)
        }
    }
}
