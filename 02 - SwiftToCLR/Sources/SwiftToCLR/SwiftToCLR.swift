// The Swift Programming Language
// https://docs.swift.org/swift-book
//
// Swift Argument Parser
// https://swiftpackageindex.com/apple/swift-argument-parser/documentation

import Foundation
import ArgumentParser
import SwiftToCLRCodegen

@main
struct SwiftToCLR: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "Code generation for the wrappers needed to call Swift code from the .NET CLR.",
        discussion: "This is a code generation tool to assist with calling Swift code from .NET CLR languages such as C# via Swift's C++ interop. Since the Microsoft compiler can't handle the clang-generated <Module-Swift.h> header, we actually need *two* wrappers - an 'unmanaged' C++ wrapper to expose the Swift API via a C++ dialect understandable by the Microsoft compiler, then a 'managed' C++ wrapper around *that* to get into the .NET CLR. From there, the code can be called from C#. This tool generates both wrappers.\n\nThe default command takes the <Module-Swift.h> file and outputs C++ code in files and namespaces named Unmanaged<Module> and Managed<Module>. To customise this behaviour, you can invoke the module-to-unmanaged and unmanaged-to-managed commands separately with additional options.",
        subcommands: [ModuleToUnmanagedCommand.self, UnmanagedToManagedCommand.self]
    )

    @Argument(help: "The to-be-wrapped input C++ header file as output by the Swift compiler.")
    var inputHeader: String

    @Option(name: .long, help: "The input module name to target.")
    var inputModule: String

    @Option(name: .long, help: "The platform SDK root, for finding system headers. If omitted, a basic auto-detection will be used.")
    var platformRoot: String?

    @Option(name: .customLong("cxx-interop"), help: "The directory containing the Swift C++ interop headers. It should be named 'swiftToCxx'.")
    var cxxInteropHeaderDirectory: String

    @Option(name: .shortAndLong, help: "The output directory. C++ implementation and header files will be emitted here, named after the input module.")
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

        let interopParent = URL(filePath: cxxInteropHeaderDirectory).deletingLastPathComponent().path
        let unmanagedWrapperNamespace: String = "Unmanaged" + inputModule
        let managedWrapperNamespace: String = "Managed" + inputModule

        // First, we generate the "unmanaged" C++ API. This is for the Microsoft C++ compiler.
        let generatedUnmanagedFiles: [GeneratedFile] = try ModuleToUnmanagedOperation.execute(
            inputHeaderPath: inputHeader,
            inputModuleName: inputModule,
            wrappedObjectVariableName: "swiftObj",
            outputNamespace: unmanagedWrapperNamespace,
            platformRoot: platformRoot,
            cxxInteropContainerPath: interopParent,
            verbose: verbose)

        for file in generatedUnmanagedFiles {
            let outputPath = URL(fileURLWithPath: outputDirectory)
                .appendingPathComponent(file.name)
            try file.contents.write(to: outputPath)
        }

        guard let unmanagedHeader = generatedUnmanagedFiles.first(where: { $0.kind == .header }) else {
            throw ValidationError("Filed to find unmanaged C++ API header! This is most likely a bug.")
        }

        let generatedManagedFiles: [GeneratedFile] = try UnmanagedToManagedOperation.execute(
            inputHeaderPath: URL(fileURLWithPath: outputDirectory).appendingPathComponent(unmanagedHeader.name).path,
            inputNamespace: unmanagedWrapperNamespace,
            wrappedObjectVariableName: "wrappedObj",
            outputNamespace: managedWrapperNamespace,
            platformRoot: platformRoot,
            verbose: verbose)

        for file in generatedManagedFiles {
            let outputPath = URL(fileURLWithPath: outputDirectory)
                .appendingPathComponent(file.name)
            try file.contents.write(to: outputPath)
        }
    }
}
