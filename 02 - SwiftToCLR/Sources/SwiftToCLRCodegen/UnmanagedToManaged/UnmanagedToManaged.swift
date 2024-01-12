import Foundation
import clang
import OrderedCollections

public struct UnmanagedToManagedOperation {

    public static func execute(inputHeaderPath: String, inputNamespace: String, wrappedObjectVariableName: String,
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

        var argumentPointers = clangArguments.map({ UnsafePointer<Int8>(_strdup($0)) })
        var unit: CXTranslationUnit? = nil

        let inputFilePath: URL = URL(fileURLWithPath: inputHeaderPath)
        let inputFileName: String = inputFilePath.lastPathComponent

        guard let index: CXIndex = clang_createIndex(0, 0) else { throw ClangError.initialization("Failed to initialise clang") }
        defer { clang_disposeIndex(index) }

        argumentPointers.withUnsafeBufferPointer { ptr in
            let argumentsBasePtr = ptr.baseAddress!
            unit = clang_parseTranslationUnit(index, inputFilePath.path,
                                              argumentsBasePtr, Int32(argumentPointers.count),
                                              nil, 0, UInt32(CXTranslationUnit_None.rawValue))
        }

        argumentPointers.forEach({ free(UnsafeMutablePointer(mutating: $0)) })
        argumentPointers = []

        guard let unit else {
            throw ClangError.initialization("Failed to initialise clang with the given input. Make sure it's a valid C++ header file.")
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

        var wrapperClasses: OrderedDictionary<String, ManagedCPPWrapperClass> = [:]
        var internalTypeMappings: [String: TypeMapping] = [:]

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
                                                              managedClassName: className,
                                                              managedNamespace: outputNamespace)

                    // We also need to be able to adapt to/from it.
                    // As long the header we're wrapping forward-declares everything within the namespace, this works
                    // alright. Without, we'd need to do two passes - one to collect all the types, then another to
                    // adapt the method calls.
                    let mapping = TypeMapping(wrappedTypeName: wrapperClass.unmanagedNamespace + "::" + wrapperClass.unmanagedClassName + " *",
                                              wrapperTypeName: wrapperClass.managedNamespace + "::" + wrapperClass.managedClassName + "^",
                                              convertWrapperToWrapped: {
                                                  return "\($0)->\(wrapperClass.unmanagedObjectName)"
                                              }, convertWrappedToWrapper: {
                                                  return "gcnew \(wrapperClass.managedNamespace)::\(wrapperClass.managedClassName)(\($0))"
                                              })

                    wrapperClasses[className] = wrapperClass
                    internalTypeMappings[className + " *"] = mapping // This seems fragile.
                }
            }

            if type.kind == CXType_FunctionProto && cursorKind == CXCursor_CXXMethod && parentKind == CXCursor_ClassDecl {
                let className = clang_getCursorDisplayName(parent).consumeToString
                if var wrapperClass = wrapperClasses[className], clang_getCXXAccessSpecifier(cursor) == CX_CXXPublic {
                    if verbose { print("Got public method \(displayName) in class \(className) - adding to wrapper list.") }
                    wrapperClass.generateWrappedMethodForUnmanagedMethod(at: cursor, internalTypeMappings: internalTypeMappings)
                    wrapperClasses[className] = wrapperClass // CoW and all that
                }
            }

            // TODO: Constructor?

            return CXChildVisit_Recurse
        }

        // Generate content.

        // TODO: Have these deal with multiple platforms properly.
        var hppContent: [String] = [
            "// This is an auto-generated file. Do not modify.",
            "#pragma once",
            "#define WIN32_LEAN_AND_MEAN",
            "#include <windows.h>",
            "#include <" + inputFileName + ">",
            ""
        ]

        hppContent.append("namespace " + outputNamespace + " {")
        hppContent.append("")

        // We need to forward-declare all of our classes in case they reference each other.
        for wrapperClass in wrapperClasses.values {
            hppContent.append("    " + "ref class " + wrapperClass.managedClassName + ";")
        }

        for wrapperClass in wrapperClasses.values {
            hppContent.append("")
            hppContent.append(contentsOf: wrapperClass.generateClassDefinition().map({ "    " + $0 }))
        }

        hppContent.append("}")
        hppContent.append("")

        var cppContent: [String] = [
            "// This is an auto-generated file. Do not modify.",
            "",
            "#include \"" + outputNamespace + ".h\"",
            "#include <msclr/marshal_cppstd.h>",
            "",
            "using namespace msclr::interop;",
            ""
        ]

        for wrapperClass in wrapperClasses.values {
            cppContent.append("// Implementation of " + wrapperClass.managedNamespace + "::" + wrapperClass.managedClassName)
            cppContent.append("")
            cppContent.append(contentsOf: wrapperClass.generateClassImplementation())
        }

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
        TypeMapping(wrappedTypeName: "std::string",
                    wrapperTypeName: "System::String^",
                    convertWrapperToWrapped: {
            return "marshal_as<std::string>(\($0))"
        }, convertWrappedToWrapper: {
            return "marshal_as<System::String^>(\($0))"
        })

    static let constStdStringMapping: TypeMapping =
        TypeMapping(wrappedTypeName: "const std::string &",
                    wrapperTypeName: "System::String^",
                    convertWrapperToWrapped: {
            return "marshal_as<std::string>(\($0))"
        }, convertWrappedToWrapper: {
            return "marshal_as<System::String^>(\($0))"
        })

    static let mappingsByUnManagedType: [String: TypeMapping] = [
        stdStringMapping.wrappedTypeName: stdStringMapping,
        constStdStringMapping.wrappedTypeName: constStdStringMapping
    ]

    static let mappingsByManagedType: [String: TypeMapping] = [
        stdStringMapping.wrapperTypeName: stdStringMapping
    ]

    static func managedMapping(from unmanagedTypeName: String) -> TypeMapping? {
        return mappingsByUnManagedType[unmanagedTypeName]
    }
}

/// Represents a managed C++ class wrapping an unmanaged one.
struct ManagedCPPWrapperClass {
    let unmanagedClassName: String
    let unmanagedNamespace: String
    let unmanagedObjectName: String

    let managedClassName: String
    let managedNamespace: String

    var generatedMethodDefinitions: [String] // For the header file
    var generatedMethodImplementations: [[String]]  // For the implementation file.

    init(unmanagedClassName: String, unmanagedNamespace: String, unmanagedObjectName: String, managedClassName: String, managedNamespace: String) {
        self.unmanagedClassName = unmanagedClassName
        self.unmanagedNamespace = unmanagedNamespace
        self.unmanagedObjectName = unmanagedObjectName
        self.managedClassName = managedClassName
        self.managedNamespace = managedNamespace
        self.generatedMethodDefinitions = []
        self.generatedMethodImplementations = []
    }

    mutating func generateWrappedMethodForUnmanagedMethod(at cursor: CXCursor, internalTypeMappings: [String: TypeMapping]) {
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

        func wrapping(for unmanagedTypeName: String) -> TypeMapping {
            if let stdMapping = UnmanagedToManagedTypeMappings.managedMapping(from: unmanagedTypeName) { return stdMapping }
            if let internalMapping = internalTypeMappings[unmanagedTypeName] { return internalMapping }
            return .direct(for: unmanagedTypeName)
        }

        let returnTypeMapping = wrapping(for: unmanagedReturnTypeName)
        let managedReturnTypeName = returnTypeMapping.wrapperTypeName

        let managedMethodArguments: [String] = unmanagedArguments.map({ argument in
            return "\(wrapping(for: argument.typeName).wrapperTypeName) \(argument.argumentName)"
        })

        // Header definition.
        let methodDefinition = managedReturnTypeName + " " + unmanagedMethodName + "(" +
            managedMethodArguments.joined(separator: ", ") + ");"
        generatedMethodDefinitions.append(methodDefinition)

        // Implementation

        let openingLine: String = managedReturnTypeName + " " + managedNamespace + "::" + managedClassName + "::" +
            unmanagedMethodName + "(" + managedMethodArguments.joined(separator: ", ") + ") {"

        var methodLines: [String] = [openingLine]

        let parameterName: String = "arg"

        // Adapt the parameters
        for (index, argument) in unmanagedArguments.enumerated() {
            // We need to bridge each argument to the unmanaged type.
            let unmanagedType = argument.typeName
            let mapping = wrapping(for: unmanagedType)
            let adaptedArgument: String = mapping.wrappedTypeName + " " + parameterName + "\(index) = " + mapping.convertWrapperToWrapped(argument.argumentName) + ";"
            methodLines.append("    " + adaptedArgument)
        }

        let args: String = (0..<unmanagedArguments.count).map({ "arg\($0)" }).joined(separator: ", ")

        if returnIsVoid {
            let methodCall: String = unmanagedObjectName + "->" + unmanagedMethodName + "(" + args + ");"
            methodLines.append("    " + methodCall)
        } else {
            // Call the method!
            let methodCall: String = returnTypeMapping.wrappedTypeName + " unmanagedResult = " + unmanagedObjectName
                                        + "->" + unmanagedMethodName + "(" + args + ");"
            methodLines.append("    " + methodCall)

            // Finally, translate back to the managed type and return it.
            let returnLine = "return " + returnTypeMapping.convertWrappedToWrapper("unmanagedResult") + ";"
            methodLines.append("    " + returnLine)
        }

        methodLines.append("}")
        generatedMethodImplementations.append(methodLines)
    }

    func generateClassDefinition() -> [String] {
        var lines: [String] = []

        let scopedUnmanagedTypeName: String = unmanagedNamespace + "::" + unmanagedClassName

        lines.append("public ref class " + managedClassName + " {")
        lines.append("private:")
        lines.append("public:")
        lines.append("    " + scopedUnmanagedTypeName + " *" + unmanagedObjectName + ";")
        lines.append("    " + managedClassName + "() : " + unmanagedObjectName + "(new " + scopedUnmanagedTypeName + "()) {}")
        lines.append("    " + managedClassName + "(" + scopedUnmanagedTypeName + " * wrapped) : " + unmanagedObjectName + "(wrapped) {}")
        // TODO: This might be bad when wrapping. We might want to use shared_ptr.
        lines.append("    ~" + managedClassName + "() { delete " + unmanagedObjectName + "; }")
        lines.append("")

        for methodDefinition in generatedMethodDefinitions {
            lines.append("    "  + methodDefinition)
        }

        lines.append("};")
        return lines
    }

    func generateClassImplementation() -> [String] {
        var lines: [String] = []
        for implementation in generatedMethodImplementations {
            lines.append(contentsOf: implementation)
            lines.append("")
        }
        return lines
    }
}
