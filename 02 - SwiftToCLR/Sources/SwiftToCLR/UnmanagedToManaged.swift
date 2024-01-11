import Foundation
import ArgumentParser
import clang

struct UnmanagedToManaged: ParsableCommand {

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

        print("Using clang version:", clang_getClangVersion().consumeToString)

        let generatedFiles: [GeneratedFile] = try UnmanagedToManagedOperation.execute(
            inputHeaderPath: commonOptions.inputHeader,
            inputNamespace: commonOptions.inputNamespace,
            wrappedObjectVariableName: wrappedObjectVariableName,
            outputNamespace: commonOptions.outputNamespace,
            platformRoot: commonOptions.platformRoot,
            verbose: commonOptions.verbose
        )

        for file in generatedFiles {
            let outputPath = URL(filePath: outputDirectory, directoryHint: .isDirectory)
                .appending(component: file.name, directoryHint: .notDirectory)
            try file.contents.write(to: outputPath)
        }
    }
}

// MARK: - Work

struct UnmanagedToManagedOperation {

    static func execute(inputHeaderPath: String, inputNamespace: String, wrappedObjectVariableName: String,
                 outputNamespace: String, platformRoot: String?, verbose: Bool) throws -> [GeneratedFile] {

        // Config & Setup

        let sdkRootPath: String = platformRoot ?? Platform.defaultSDKRoot

        let clangArguments: [String] = [
            "-x", "c++",
            "--language=c++",
            "-std=c++17",
            "-isysroot", sdkRootPath
            //"-I/path/to/swift/cxx-interop-headers" // Parent folder of swiftToCxx - not needed here.
        ]

        var argumentPointers = clangArguments.map({ UnsafePointer<Int8>(strdup($0)) })
        var unit: CXTranslationUnit? = nil

        let inputFilePath: URL = URL(filePath: inputHeaderPath)
        let inputFileName: String = inputFilePath.lastPathComponent

        guard let index: CXIndex = clang_createIndex(0, 0) else { throw ValidationError("Failed to initialise clang") }
        defer { clang_disposeIndex(index) }

        argumentPointers.withUnsafeBufferPointer { ptr in
            let argumentsBasePtr = ptr.baseAddress!
            unit = clang_parseTranslationUnit(index, inputFilePath.path(percentEncoded: false),
                                              argumentsBasePtr, Int32(argumentPointers.count),
                                              nil, 0, CXTranslationUnit_None.rawValue)
        }

        argumentPointers.forEach({ free(UnsafeMutablePointer(mutating: $0)) })
        argumentPointers = []

        guard let unit else {
            throw ValidationError("Failed to initialise clang with the given input. Make sure it's a valid C++ header file.")
        }

        let numberOfDiagnosticMessages = clang_getNumDiagnostics(unit)
        if numberOfDiagnosticMessages > 0 {
            print("Warning: Got \(numberOfDiagnosticMessages) diagnostic messages from clang:")
            for index in 0..<numberOfDiagnosticMessages {
                let diagnostic = clang_getDiagnostic(unit, index)
                print(clang_formatDiagnostic(diagnostic, clang_defaultDiagnosticDisplayOptions()).consumeToString)
            }
        }

        // Logic

        var wrapperClasses: [String: ManagedCPPWrapperClass] = [:]
        let translationCursor: CXCursor = clang_getTranslationUnitCursor(unit)

        // We have to do this to avoid captuing self

        clang_visitChildrenWithBlock(translationCursor) { (cursor, parent) -> CXChildVisitResult in
            let range: CXSourceRange = clang_getCursorExtent(cursor)
            let location: CXSourceLocation = clang_getRangeStart(range)

            // If the symbol isn't in our input file, skip it entirely - otherwise we'll be parsing a *ton* of stuff
            // brought in by includes.
            guard clang_Location_isFromMainFile(location) != 0 else {
                return CXChildVisit_Continue
            }

            let type: CXType = clang_getCursorType(cursor)
            let cursorKind: CXCursorKind = clang_getCursorKind(cursor)
            let parentKind: CXCursorKind = clang_getCursorKind(parent)

            let displayName = clang_getCursorDisplayName(cursor).consumeToString
            //let kindSpelling = clang_getCursorKindSpelling(cursorKind).consumeToString
            //let typeSpelling = clang_getTypeSpelling(type).consumeToString
            //let typeKindSpelling = clang_getTypeKindSpelling(type.kind).consumeToString
            //print("Display name: \(displayName), Kind: \(kindSpelling), Type: \(typeSpelling), Type Kind: \(typeKindSpelling), Parent: \(parent.briefName)")

            if cursorKind == CXCursor_ClassDecl && parentKind == CXCursor_Namespace {
                let className = displayName
                let namespaceName = clang_getCursorDisplayName(parent).consumeToString
                if namespaceName == inputNamespace {
                    if verbose { print("Got class \(className) in target namespace \(namespaceName) - adding to wrapper list.") }
                    let wrapperClass = ManagedCPPWrapperClass(unmanagedClassName: className,
                                                              unmanagedNamespace: namespaceName,
                                                              unmanagedObjectName: wrappedObjectVariableName,
                                                              managedClassName: className, generatedMethods: [])
                    wrapperClasses[className] = wrapperClass
                }
            }

            if type.kind == CXType_FunctionProto && cursorKind == CXCursor_CXXMethod && parentKind == CXCursor_ClassDecl {
                let className = clang_getCursorDisplayName(parent).consumeToString
                if var wrapperClass = wrapperClasses[className], clang_getCXXAccessSpecifier(cursor) == CX_CXXPublic {
                    if verbose { print("Got public method \(displayName) in class \(className) - adding to wrapper list.") }
                    wrapperClass.generateWrappedMethodForUnmanagedMethod(at: cursor)
                    wrapperClasses[className] = wrapperClass // CoW and all that
                }
            }

            // TODO: Constructor?

            return CXChildVisit_Recurse
        }

        // Generate content.

        // TODO: Have these deal with multiple platforms properly.
        let hppContent: [String] = [
            "#pragma once",
            "#define WIN32_LEAN_AND_MEAN",
            "#include <windows.h>",
            ""
        ]

        var cppContent: [String] = [
            "// This is an auto-generated file. Do not modify.",
            "",
            "#include \"" + outputNamespace + ".h\"",
            "#include <" + inputFileName + ">",
            "#include <msclr/marshal_cppstd.h>",
            "",
            "using namespace " + inputNamespace + ";",
            "using namespace msclr::interop;",
            ""
        ]

        cppContent.append("namespace " + outputNamespace + " {")

        for wrapperDefinition in wrapperClasses.values {
            cppContent.append(contentsOf: wrapperDefinition.generateClassDefinition().map({ "    " + $0 }))
        }

        cppContent.append("}")
        cppContent.append("")

        #if os(Windows)
        let newLineCharacters: String = "\r\n"
        #else
        let newLineCharacters: String = "\n"
        #endif

        let headerData = Data(hppContent.joined(separator: newLineCharacters).utf8)
        let implementationData = Data(cppContent.joined(separator: newLineCharacters).utf8)

        let headerFile = GeneratedFile(name: "\(outputNamespace).h", contents: headerData)
        let implementationFile = GeneratedFile(name: "\(outputNamespace).cpp", contents: implementationData)

        return [headerFile, implementationFile]
    }
}

// MARK: - Types

struct UnmanagedToManagedTypeMappings {
    
    static let stdStringMapping: TypeMapping =
        TypeMapping(unmanagedTypeName: "std::string",
                    managedTypeName: "System::String^",
                    convertManagedToUnmanaged: {
            return "marshal_as<std::string>(\($0))"
        }, convertUnmanagedToManaged: {
            return "marshal_as<System::String^>(\($0))"
        })

    static let constStdStringMapping: TypeMapping =
        TypeMapping(unmanagedTypeName: "const std::string &",
                    managedTypeName: "System::String^",
                    convertManagedToUnmanaged: {
            return "marshal_as<std::string>(\($0))"
        }, convertUnmanagedToManaged: {
            return "marshal_as<System::String^>(\($0))"
        })

    static let mappingsByUnManagedType: [String: TypeMapping] = [
        stdStringMapping.unmanagedTypeName: stdStringMapping,
        constStdStringMapping.unmanagedTypeName: constStdStringMapping
    ]

    static let mappingsByManagedType: [String: TypeMapping] = [
        stdStringMapping.managedTypeName: stdStringMapping
    ]

    static func managedMapping(from unmanagedTypeName: String) -> TypeMapping {
        return mappingsByUnManagedType[unmanagedTypeName] ?? .direct(for: unmanagedTypeName)
    }
}

/// Represents a managed C++ class wrapping an unmanaged one.
struct ManagedCPPWrapperClass {
    let unmanagedClassName: String
    let unmanagedNamespace: String
    let unmanagedObjectName: String

    let managedClassName: String

    var generatedMethods: [[String]]

    mutating func generateWrappedMethodForUnmanagedMethod(at cursor: CXCursor) {
        let cursorType: CXType = clang_getCursorType(cursor)
        let cursorKind: CXCursorKind = clang_getCursorKind(cursor)
        assert(cursorType.kind == CXType_FunctionProto, "Passed wrong cursor type")
        assert(cursorKind == CXCursor_CXXMethod, "Passed wrong cursor kind")

        // We need to get the return type.
        let unmanagedReturnType: CXType = clang_getResultType(cursorType)
        let unmanagedReturnTypeName = clang_getTypeSpelling(unmanagedReturnType).consumeToString
        let returnIsVoid = (unmanagedReturnType.kind == CXType_Void)

        // And the method name.
        let unmanagedMethodName = clang_getCursorSpelling(cursor).consumeToString

        // …and the arguments.
        let argumentCount = UInt32(clang_Cursor_getNumArguments(cursor)) // Can return -1 if the wrong cursor type. We checked that above.
        let unmanagedArguments: [MethodArgument] = (0..<argumentCount).map({ argumentIndex in
            let argumentCursor: CXCursor = clang_Cursor_getArgument(cursor, argumentIndex)
            let argumentName = clang_getCursorSpelling(argumentCursor).consumeToString
            let argumentType = clang_getTypeSpelling(clang_getArgType(cursorType, argumentIndex)).consumeToString
            return MethodArgument(typeName: argumentType, argumentName: argumentName)
        })

        // We have everything we need to wrap the method now!

        let returnTypeMapping = UnmanagedToManagedTypeMappings.managedMapping(from: unmanagedReturnTypeName)
        let managedReturnTypeName = returnTypeMapping.managedTypeName

        let managedMethodArguments: [String] = unmanagedArguments.map({ argument in
            return "\(UnmanagedToManagedTypeMappings.managedMapping(from: argument.typeName).managedTypeName) \(argument.argumentName)"
        })

        let openingLine = managedReturnTypeName + " " + unmanagedMethodName + "(" +
        managedMethodArguments.joined(separator: ", ") + ") {"
        var methodLines: [String] = [openingLine]

        let parameterName: String = "arg"

        // Adapt the parameters
        for (index, argument) in unmanagedArguments.enumerated() {
            // We need to bridge each argument to the unmanaged type.
            let unmanagedType = argument.typeName
            let mapping = UnmanagedToManagedTypeMappings.managedMapping(from: unmanagedType)
            let adaptedArgument: String = unmanagedType + " " + parameterName + "\(index) = " + mapping.convertManagedToUnmanaged(argument.argumentName) + ";"
            methodLines.append("    " + adaptedArgument)
        }

        let args: String = (0..<unmanagedArguments.count).map({ "arg\($0)" }).joined(separator: ", ")

        if returnIsVoid {
            let methodCall: String = unmanagedObjectName + "->" + unmanagedMethodName + "(" + args + ");"
            methodLines.append("    " + methodCall)
        } else {
            // Call the method!
            let methodCall: String = unmanagedReturnTypeName + " unmanagedResult = " + unmanagedObjectName + "->" + unmanagedMethodName + "(" + args + ");"
            methodLines.append("    " + methodCall)

            // Finally, translate back to the managed type and return it.
            let returnLine = "return " + returnTypeMapping.convertUnmanagedToManaged("unmanagedResult") + ";"
            methodLines.append("    " + returnLine)
        }

        methodLines.append("}")
        generatedMethods.append(methodLines)
    }

    func generateClassDefinition() -> [String] {
        var lines: [String] = []

        let scopedUnmanagedTypeName: String = unmanagedNamespace + "::" + unmanagedClassName

        lines.append("public ref class " + managedClassName + " {")
        lines.append("private:")
        lines.append("    " + scopedUnmanagedTypeName + " *" + unmanagedObjectName + ";")
        lines.append("public:")
        lines.append("    " + managedClassName + "() : " + unmanagedObjectName + "(new " + scopedUnmanagedTypeName + "()) {}")
        lines.append("    ~" + managedClassName + "() { delete " + unmanagedObjectName + "; }")
        lines.append("")

        for methodLines in generatedMethods {
            lines.append(contentsOf: methodLines.map({ "    " + $0 }))
            lines.append("")
        }

        lines.append("};")
        return lines
    }
}
