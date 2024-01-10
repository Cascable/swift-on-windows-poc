// The Swift Programming Language
// https://docs.swift.org/swift-book
// 
// Swift Argument Parser
// https://swiftpackageindex.com/apple/swift-argument-parser/documentation

import Foundation
import ArgumentParser

@main
struct SwiftToCLR: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "Code generation for calling Swift code from the .NET CLR",
        subcommands: [UnmanagedToManaged.self]
    )
}

struct CommonOptions: ParsableArguments {
    @Argument(help: "The to-be-wrapped input header file.")
    var inputHeader: String

    @Option(name: .long, help: "The input namespace to target.")
    var inputNamespace: String

    @Option(name: .long, help: "The output namespace to contain the generated wrapper classes.")
    var outputNamespace: String

    @Option(name: .long, help: "The platform SDK root, for finding system headers. If omitted, a basic auto-detection will be used.")
    var platformRoot: String?

    @Flag(name: .shortAndLong, help: "Output more stuff.")
    var verbose: Bool = false
}

