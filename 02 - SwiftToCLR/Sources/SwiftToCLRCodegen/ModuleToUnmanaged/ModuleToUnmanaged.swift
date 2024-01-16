import Foundation
import clang
import OrderedCollections

public struct ModuleToUnmanagedOperation {

    public static func execute(inputHeaderPath: String, inputNamespace: String, wrappedObjectVariableName: String,
                               outputNamespace: String, platformRoot: String?, cxxInteropContainerPath: String,
                               verbose: Bool) throws -> [GeneratedFile] {

        // Config & Setup

        let sdkRootPath: String = platformRoot ?? Platform.defaultSDKRoot

        // libclang seems to ignore inlined functions, which the generated module header adds to our methods via the
        // SWIFT_INLINE_THUNK macro. We pass in `-Dinline=` to "null out" the `inline` attribute.
        // It's horrid, but it works - SWIFT_INLINE_THUNK is declared in the swiftToCxx headers, so nulling *that*
        // out at this point doesn't work (since it's defined later on).
        let clangArguments: [String] = [
            "-x", "c++",
            "--language=c++",
            "-std=c++17",
            "-isysroot", sdkRootPath,
            "-I\(cxxInteropContainerPath)",
            "-Dinline=",
        ]

        var argumentPointers = clangArguments.map({
            #if os(Windows)
            return UnsafePointer<Int8>(_strdup($0))
            #else
            return UnsafePointer<Int8>(strdup($0))
            #endif
        })
        var unit: CXTranslationUnit? = nil

        let inputFilePath: URL = URL(fileURLWithPath: inputHeaderPath)
        let inputFileName: String = inputFilePath.lastPathComponent

        guard let index: CXIndex = clang_createIndex(0, 0) else { throw ClangError.initialization("Failed to initialise clang") }
        defer { clang_disposeIndex(index) }

        let options: UInt32 = (CXTranslationUnit_SkipFunctionBodies.rawValue | 
                               CXTranslationUnit_KeepGoing.rawValue |
                               CXTranslationUnit_IncludeAttributedTypes.rawValue |
                               CXTranslationUnit_VisitImplicitAttributes.rawValue |
                               CXTranslationUnit_RetainExcludedConditionalBlocks.rawValue)

        argumentPointers.withUnsafeBufferPointer { ptr in
            let argumentsBasePtr = ptr.baseAddress!
            unit = clang_parseTranslationUnit(index, inputFilePath.path,
                                              argumentsBasePtr, Int32(argumentPointers.count),
                                              nil, 0, options)
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
            let kindSpelling = clang_getCursorKindSpelling(cursorKind).consumeToString
            let typeSpelling = clang_getTypeSpelling(type).consumeToString
            let typeKindSpelling = clang_getTypeKindSpelling(type.kind).consumeToString
            print("Display name: \(displayName), Kind: \(kindSpelling), Type: \(typeSpelling), Type Kind: \(typeKindSpelling), Parent: \(parent.briefName)")
            
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
