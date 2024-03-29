import Foundation
import clang
import OrderedCollections

public struct UnmanagedToManagedOperation {

    public static func execute(inputHeaderPath: String, inputNamespace: String, wrappedObjectVariableName: String,
                 outputNamespace: String, platformRoot: String?, verbose: Bool) throws -> [GeneratedFile] {

        // The initial implementation of this codegen used std::shared_ptr to store unmanaged objects inside the
        // garbage-collected objects. Since we're currently being very aggressive with copying, this doesn't appear
        // to be needed for now. However, my C++ memory management skills are rather rusty, so I'm keeping the option around.
        let useSharedPtrs: Bool = false

        // Config & Setup

        let sdkRootPath: String = platformRoot ?? Platform.defaultSDKRoot

        let clangArguments: [String] = [
            "-x", "c++",
            "--language=c++",
            "-std=c++17",
            "-isysroot", sdkRootPath
        ]

        var argumentPointers = clangArguments.map({
            #if os(Windows)
            return UnsafePointer<Int8>(_strdup($0))
            #else
            return UnsafePointer<Int8>(strdup($0))
            #endif
        })

        let inputFilePath: URL = URL(fileURLWithPath: inputHeaderPath)
        let inputFileName: String = inputFilePath.lastPathComponent

        guard let index: CXIndex = clang_createIndex(0, 0) else { throw ClangError.initialization("Failed to initialise clang") }
        defer { clang_disposeIndex(index) }

        var unit: CXTranslationUnit? = nil
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

        if verbose {
            unit.printDiagnostics()
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
                                                              managedNamespace: outputNamespace,
                                                              useSharedPtrs: useSharedPtrs)

                    let scopedManagedTypeName = wrapperClass.managedNamespace + "::" + wrapperClass.managedClassName
                    let scopedUnmanagedTypeName = wrapperClass.unmanagedNamespace + "::" + wrapperClass.unmanagedClassName

                    // We also need to be able to adapt to/from it.
                    // As long the header we're wrapping forward-declares everything within the namespace, this works
                    // alright. Without, we'd need to do two passes - one to collect all the types, then another to
                    // adapt the method calls.
                    let mapping = TypeMapping(wrappedTypeName: scopedUnmanagedTypeName,
                                              wrapperTypeName: scopedManagedTypeName + "^",
                                              convertWrapperToWrapped: { name, _ in
                                                  if useSharedPtrs {
                                                      return "*\(name)->\(wrapperClass.unmanagedObjectName)->get()"
                                                  } else {
                                                      return "*\(name)->\(wrapperClass.unmanagedObjectName)"
                                                  }
                                              }, convertWrappedToWrapper: { name, _ in
                                                  let copyOperation = "new " + scopedUnmanagedTypeName + "(" + name + ")"
                                                  let ptrOperation: String
                                                  if useSharedPtrs {
                                                      ptrOperation = "new std::shared_ptr<" + scopedUnmanagedTypeName + ">(" + copyOperation + ")"
                                                  } else {
                                                      ptrOperation = copyOperation
                                                  }
                                                  return "gcnew \(scopedManagedTypeName)(\(ptrOperation))"
                                              })

                    wrapperClasses[className] = wrapperClass
                    internalTypeMappings[className + " *"] = mapping // This seems fragile.
                    internalTypeMappings["const " + scopedUnmanagedTypeName + " &"] = mapping // This seems fragile.
                    internalTypeMappings[scopedUnmanagedTypeName] = mapping // This seems fragile
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

            if cursorKind == CXCursor_Constructor && parentKind == CXCursor_ClassDecl {
                let className = clang_getCursorDisplayName(parent).consumeToString
                if var wrapperClass = wrapperClasses[className], clang_getCXXAccessSpecifier(cursor) == CX_CXXPublic {
                    let wasIngested = wrapperClass.generateWrappedConstructorForUnmanagedConstructor(at: cursor, internalTypeMappings: internalTypeMappings)
                    if wasIngested {
                        if verbose { print("Got public constructor \(displayName) in class \(className) - adding to wrapper list.") }
                        wrapperClasses[className] = wrapperClass // CoW and all that
                    }
                }
            }

            return CXChildVisit_Recurse
        }

        // Generate content.

        var hppContent: [String] = [
            "// This is an auto-generated file. Do not modify.",
            "",
            "#pragma once",
            "#define WIN32_LEAN_AND_MEAN",
            "#include <windows.h>",
            "#include <" + inputFileName + ">",
            "",
            "using namespace System::Collections::Generic;",
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
            "#include \"" + outputNamespace + ".hpp\"",
            "#include <msclr/marshal_cppstd.h>",
            "",
            "using namespace msclr::interop;",
            "using namespace System::Collections::Generic;",
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

        let headerFile = GeneratedFile(kind: .header, name: "\(outputNamespace).hpp", contents: headerData)
        let implementationFile = GeneratedFile(kind: .implementation, name: "\(outputNamespace).cpp", contents: implementationData)

        return [headerFile, implementationFile]
    }
}

// MARK: - Types

struct UnmanagedToManagedTypeMappings {

    static let stdStringMapping: TypeMapping =
        TypeMapping(wrappedTypeName: "std::string",
                    wrapperTypeName: "System::String^",
                    convertWrapperToWrapped: { name, _ in
            return "marshal_as<std::string>(\(name))"
        }, convertWrappedToWrapper: { name, _ in
            return "marshal_as<System::String^>(\(name))"
        })

    static let constStdStringMapping: TypeMapping =
        TypeMapping(wrappedTypeName: "const std::string &",
                    wrapperTypeName: "System::String^",
                    convertWrapperToWrapped: { name, _ in
            return "marshal_as<std::string>(\(name))"
        }, convertWrappedToWrapper: { name, _ in
            return "marshal_as<System::String^>(\(name))"
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

    let useSharedPtrs: Bool

    var generatedMethodDefinitions: [String] // For the header file
    var generatedConstructorDefinitions: [String] // For the header file
    var generatedStaticMethodDefinitions: [String] // For the header file
    var generatedMethodImplementations: [[String]]  // For the implementation file
    var generatedConstructorImplementations: [[String]] // For the implementation file

    init(unmanagedClassName: String, unmanagedNamespace: String, unmanagedObjectName: String, managedClassName: String, managedNamespace: String, useSharedPtrs: Bool) {
        self.unmanagedClassName = unmanagedClassName
        self.unmanagedNamespace = unmanagedNamespace
        self.unmanagedObjectName = unmanagedObjectName
        self.managedClassName = managedClassName
        self.managedNamespace = managedNamespace
        self.useSharedPtrs = useSharedPtrs
        self.generatedMethodDefinitions = []
        self.generatedConstructorDefinitions = []
        self.generatedStaticMethodDefinitions = []
        self.generatedMethodImplementations = []
        self.generatedConstructorImplementations = []
    }

    mutating func generateWrappedConstructorForUnmanagedConstructor(at cursor: CXCursor, internalTypeMappings: [String: TypeMapping]) -> Bool {
        let cursorType: CXType = clang_getCursorType(cursor)
        let cursorKind: CXCursorKind = clang_getCursorKind(cursor)
        assert(cursorType.kind == CXType_FunctionProto, "Passed wrong cursor type")
        assert(cursorKind == CXCursor_Constructor, "Passed wrong cursor kind")

        // We need to reject "wrapping" constructors and only take custom ones, since we generate our own wrapping
        // constructor. These constructors take a std::shared_ptr<SwiftType>.

        let argumentCount = UInt32(clang_Cursor_getNumArguments(cursor)) // Can return -1 if the wrong cursor type. We checked that above.
        let unmanagedArguments: [MethodArgument] = (0..<argumentCount).map({ argumentIndex in
            let argumentCursor: CXCursor = clang_Cursor_getArgument(cursor, argumentIndex)
            let argumentName = clang_getCursorSpelling(argumentCursor).consumeToString
            let argumentType = clang_getTypeSpelling(clang_getArgType(cursorType, argumentIndex)).consumeToString
            return MethodArgument(typeName: argumentType, argumentName: argumentName, isOptionalType: false, isArrayType: false, isVoidType: false)
        })

        guard !unmanagedArguments.contains(where: { $0.typeName.contains("std::shared_ptr") }) else { return false }

        // We have everything we need to wrap the constructor now!

        func wrapping(for unmanagedTypeName: String) -> TypeMapping {
            if let stdMapping = UnmanagedToManagedTypeMappings.managedMapping(from: unmanagedTypeName) { return stdMapping }
            if let internalMapping = internalTypeMappings[unmanagedTypeName] { return internalMapping }
            return .direct(for: unmanagedTypeName)
        }

        let managedMethodArguments: [String] = unmanagedArguments.map({ argument in
            return "\(wrapping(for: argument.typeName).wrapperTypeName) \(argument.argumentName)"
        })

        // Header definition.
        let constructorDefinition = managedClassName + "(" + managedMethodArguments.joined(separator: ", ") + ");"
        generatedConstructorDefinitions.append(constructorDefinition)

        // Implementation
        let scopedUnmanagedTypeName = unmanagedNamespace + "::" + unmanagedClassName
        let scopedManagedTypeName = managedNamespace + "::" + managedClassName

        let openingLine: String = scopedManagedTypeName + "::" + managedClassName
            + "(" + managedMethodArguments.joined(separator: ", ") + ") {"

        var methodLines: [String] = [openingLine]

        let parameterName: String = "arg"

        // Adapt the parameters
        for (index, argument) in unmanagedArguments.enumerated() {
            // We need to bridge each argument to the unmanaged type.
            let unmanagedType = argument.typeName
            let mapping = wrapping(for: unmanagedType)
            let adaptedArgument: String = mapping.wrappedTypeName + " " + parameterName + "\(index) = " + mapping.convertWrapperToWrapped(argument.argumentName, false) + ";"
            methodLines.append("    " + adaptedArgument)
        }


        let args: String = (0..<unmanagedArguments.count).map({ "arg\($0)" }).joined(separator: ", ")
        methodLines.append("    " + scopedUnmanagedTypeName + " *newObject = new " + scopedUnmanagedTypeName + "(" + args + ");")
        if useSharedPtrs {
            methodLines.append("    " + unmanagedObjectName + " = new std::shared_ptr<" + scopedUnmanagedTypeName + ">(newObject);")
        } else {
            methodLines.append("    " + unmanagedObjectName + " = newObject;")
        }
        methodLines.append("}")
        generatedConstructorImplementations.append(methodLines)

        return true
    }

    mutating func generateWrappedMethodForUnmanagedMethod(at cursor: CXCursor, internalTypeMappings: [String: TypeMapping]) {
        let cursorType: CXType = clang_getCursorType(cursor)
        let cursorKind: CXCursorKind = clang_getCursorKind(cursor)
        assert(cursorType.kind == CXType_FunctionProto, "Passed wrong cursor type")
        assert(cursorKind == CXCursor_CXXMethod, "Passed wrong cursor kind")

        // We need to get the return type.
        let unmanagedReturnType: CXType = clang_getResultType(cursorType)
        let unmanagedReturnArgument = MethodArgument(extractingOptionalOfType: "std::optional",
                                                     arrayOfType: "std::vector",
                                                     from: clang_getTypeSpelling(unmanagedReturnType).consumeToString,
                                                     argumentName: "", isVoidType: (unmanagedReturnType.kind == CXType_Void))

        // And the method name.
        let unmanagedMethodName = clang_getCursorSpelling(cursor).consumeToString
        let methodIsEqualityOperator: Bool = (unmanagedMethodName == "operator==") // I'm sure there's a better way than this.
        let methodIsStatic: Bool = (clang_CXXMethod_isStatic(cursor) > 0)

        // …and the arguments.
        let argumentCount = UInt32(clang_Cursor_getNumArguments(cursor)) // Can return -1 if the wrong cursor type. We checked that above.
        let unmanagedArguments: [MethodArgument] = (0..<argumentCount).map({ argumentIndex in
            let argumentCursor: CXCursor = clang_Cursor_getArgument(cursor, argumentIndex)
            let argumentName = clang_getCursorSpelling(argumentCursor).consumeToString
            let argumentType = clang_getTypeSpelling(clang_getArgType(cursorType, argumentIndex)).consumeToString
            return MethodArgument(extractingOptionalOfType: "std::optional", arrayOfType: "std::vector", from: argumentType, argumentName: argumentName, isVoidType: false)
        })

        // We have everything we need to wrap the method now!

        func wrapping(for unmanagedTypeName: String) -> TypeMapping {
            if let stdMapping = UnmanagedToManagedTypeMappings.managedMapping(from: unmanagedTypeName) { return stdMapping }
            if let internalMapping = internalTypeMappings[unmanagedTypeName] { return internalMapping }
            return .direct(for: unmanagedTypeName)
        }

        let returnTypeMapping = wrapping(for: unmanagedReturnArgument.typeName)
        let managedReturnTypeName: String = {
            if unmanagedReturnArgument.isArrayType {
                return "List<" + returnTypeMapping.wrapperTypeName + ">^"
            } else {
                return returnTypeMapping.wrapperTypeName
            }
        }();

        let managedMethodArguments: [String] = unmanagedArguments.map({ argument in
            if argument.isArrayType {
                return "List<\(wrapping(for: argument.typeName).wrapperTypeName)>^ \(argument.argumentName)"
            } else {
                return "\(wrapping(for: argument.typeName).wrapperTypeName) \(argument.argumentName)"
            }
        })

        let scopedManagedClassName: String = managedNamespace + "::" + managedClassName
        let scopedUnmanagedClassName: String = unmanagedNamespace + "::" + unmanagedClassName

        // Header definition.
        let methodDefinition = managedReturnTypeName + " " + unmanagedMethodName + "(" +
            managedMethodArguments.joined(separator: ", ") + ");"

        if methodIsStatic {
            generatedStaticMethodDefinitions.append("static " + methodDefinition)
        } else if methodIsEqualityOperator {
            generatedStaticMethodDefinitions.append("static bool operator==(" + scopedManagedClassName + "^ lhs, " + scopedManagedClassName + "^ rhs);")
        } else {
            generatedMethodDefinitions.append(methodDefinition)
        }

        guard !methodIsEqualityOperator else {
            // This is special-cased a bit.
            var methodLines: [String] = []

            methodLines.append("bool " + scopedManagedClassName + "::operator==(" + scopedManagedClassName + "^ lhs, " + scopedManagedClassName + "^ rhs) {")
            methodLines.append("    if (Object::ReferenceEquals(lhs, nullptr) && Object::ReferenceEquals(rhs, nullptr)) { return true; }");
            methodLines.append("    if (Object::ReferenceEquals(lhs, nullptr) || Object::ReferenceEquals(rhs, nullptr)) { return false; }");
            if useSharedPtrs {
                methodLines.append("    return (*lhs->" + unmanagedObjectName + "->get() == *rhs->" + unmanagedObjectName + "->get());")
            } else {
                methodLines.append("    return (*lhs->" + unmanagedObjectName + " == *rhs->" + unmanagedObjectName + ");")
            }
            methodLines.append("}")

            generatedMethodImplementations.append(methodLines)
            return
        }

        // Implementation

        let openingLine: String = managedReturnTypeName + " " + scopedManagedClassName + "::" +
            unmanagedMethodName + "(" + managedMethodArguments.joined(separator: ", ") + ") {"

        var methodLines: [String] = [openingLine]

        let parameterName: String = "arg"

        func adaptArray(fromListNamed sourceName: String, toStdVectorNamed destName: String, using mapping: TypeMapping) -> [String] {
            var lines: [String] = []
            lines.append("std::vector<" + mapping.wrappedTypeName + "> \(destName);")
            lines.append(destName + ".reserve(" + sourceName + "->Count);")
            lines.append("for each(auto element in " + sourceName + ") {")
            lines.append("    " + destName + ".push_back(" + mapping.convertWrapperToWrapped("element", false) + ");")
            lines.append("}")
            return lines
        }

        // Adapt the parameters
        for (index, argument) in unmanagedArguments.enumerated() {
            // We need to bridge each argument to the unmanaged type.
            let unmanagedType = argument.typeName
            let mapping = wrapping(for: unmanagedType)
            let arrayName: String = "\(parameterName)\(index)Array"
            if argument.isOptionalType {
                if argument.isArrayType {
                    var lines: [String] = []
                    lines.append("std::optional<std::vector<" + mapping.wrappedTypeName + ">> " + arrayName + ";");
                    lines.append("if (" + argument.argumentName + " == nullptr) {")
                    lines.append("    " + arrayName + " = std::nullopt;")
                    lines.append("} else {")
                    lines.append(contentsOf: adaptArray(fromListNamed: argument.argumentName, toStdVectorNamed: arrayName + "Unwrapped",
                                                using: mapping).map({ "    " + $0 }))
                    lines.append("    " + arrayName + " = std::optional<std::vector<" + mapping.wrappedTypeName + ">>(" + arrayName + "Unwrapped);")
                    lines.append("}")
                    methodLines.append(contentsOf: lines.map({ "    " + $0 }))
                } else {
                    let adaptedArgument: String = "std::optional<" + mapping.wrappedTypeName + "> " + parameterName + "\(index) = (" +
                        argument.argumentName + " == nullptr ? std::nullopt : std::optional<" + mapping.wrappedTypeName +
                            ">(" + mapping.convertWrapperToWrapped(argument.argumentName, false) + "));"
                    methodLines.append("    " + adaptedArgument)
                }
            } else if argument.isArrayType {
                methodLines.append(contentsOf: adaptArray(fromListNamed: argument.argumentName, toStdVectorNamed: arrayName,
                    using: mapping).map({ "    " + $0 }))
            } else {
                let adaptedArgument: String = mapping.wrappedTypeName + " " + parameterName + "\(index) = " +
                    mapping.convertWrapperToWrapped(argument.argumentName, false) + ";"
                methodLines.append("    " + adaptedArgument)
            }
        }

        let args: String = unmanagedArguments.enumerated().map({ index, argument in
            if argument.isArrayType {
                return parameterName + "\(index)Array"
            } else {
                return parameterName + "\(index)"
            }
        }).joined(separator: ", ")

        if unmanagedReturnArgument.isVoidType {
            let methodCall: String = {
                if methodIsStatic {
                    return scopedUnmanagedClassName + "::" + unmanagedMethodName + "(" + args + ");"
                } else {
                    if useSharedPtrs {
                        return unmanagedObjectName + "->get()->" + unmanagedMethodName + "(" + args + ");"
                    } else {
                        return unmanagedObjectName + "->" + unmanagedMethodName + "(" + args + ");"
                    }
                }
            }()
            methodLines.append("    " + methodCall)
        } else {
            let methodCall: String = {
                var resultTypeName: String = returnTypeMapping.wrappedTypeName
                if unmanagedReturnArgument.isArrayType { resultTypeName = "std::vector<" + resultTypeName + ">" }
                if unmanagedReturnArgument.isOptionalType { resultTypeName = "std::optional<" + resultTypeName + ">" }

                if methodIsStatic {
                    return resultTypeName + " unmanagedResult = " + scopedUnmanagedClassName + "::"
                                        + unmanagedMethodName + "(" + args + ");"
                } else {
                    if useSharedPtrs {
                        return resultTypeName + " unmanagedResult = " + unmanagedObjectName
                                            + "->get()->" + unmanagedMethodName + "(" + args + ");"
                    } else {
                        return resultTypeName + " unmanagedResult = " + unmanagedObjectName
                                            + "->" + unmanagedMethodName + "(" + args + ");"
                    }
                }
            }()
            methodLines.append("    " + methodCall)

            func adaptArray(fromStdVectorNamed sourceName: String, toListNamed destName: String, using mapping: TypeMapping) -> [String] {
                var lines: [String] = []
                lines.append("List<" + mapping.wrapperTypeName + ">^ " + destName + " = gcnew List<" + mapping.wrapperTypeName + ">();")
                lines.append("for (auto element : " + sourceName + ") {")
                lines.append("    auto managedElement = " + mapping.convertWrappedToWrapper("element", false) + ";")
                lines.append("    " + destName + "->Add(managedElement);")
                lines.append("}")
                return lines
            }

            // Finally, translate back to the managed type and return it.
            if unmanagedReturnArgument.isOptionalType {
                if unmanagedReturnArgument.isArrayType {
                    methodLines.append("    if (unmanagedResult.has_value()) {")
                    methodLines.append("        std::vector<" + returnTypeMapping.wrappedTypeName + "> unwrappedResult = unmanagedResult.value();")
                    let conversion = adaptArray(fromStdVectorNamed: "unwrappedResult", toListNamed: "managedResult", using: returnTypeMapping)
                    methodLines.append(contentsOf: conversion.map({ "        " + $0 }))
                    methodLines.append("        return managedResult;")
                    methodLines.append("    } else {")
                    methodLines.append("        return nullptr;")
                    methodLines.append("    }")

                } else {
                    let returnLine = "return (unmanagedResult.has_value() ? " +
                        returnTypeMapping.convertWrappedToWrapper("unmanagedResult.value()", false) + " : nullptr);"
                    methodLines.append("    " + returnLine)
                }
            } else if unmanagedReturnArgument.isArrayType {
                methodLines.append(contentsOf: adaptArray(fromStdVectorNamed: "unmanagedResult", toListNamed: "managedResult",
                    using: returnTypeMapping).map{( "    " + $0 )})
                methodLines.append("    return managedResult;")
            } else {
                let returnLine = "return " + returnTypeMapping.convertWrappedToWrapper("unmanagedResult", false) + ";"
                methodLines.append("    " + returnLine)
            }
        }

        methodLines.append("}")
        generatedMethodImplementations.append(methodLines)
    }

    func generateClassDefinition() -> [String] {
        var lines: [String] = []

        let scopedUnmanagedTypeName: String = unmanagedNamespace + "::" + unmanagedClassName

        lines.append("public ref class " + managedClassName + " {")
        lines.append("private:")
        lines.append("internal:")
        if useSharedPtrs {
            lines.append("    std::shared_ptr<" + scopedUnmanagedTypeName + "> *" + unmanagedObjectName + ";")
            lines.append("    " + managedClassName + "(std::shared_ptr<" + scopedUnmanagedTypeName + "> *objectToTakeOwnershipOf);")
        } else {
            lines.append("    " + scopedUnmanagedTypeName + " *" + unmanagedObjectName + ";")
            lines.append("    " + managedClassName + "(" + scopedUnmanagedTypeName + " *objectToTakeOwnershipOf);")
        }
        lines.append("public:")
        lines.append(contentsOf: generatedConstructorDefinitions.map({ "    " + $0 }))
        lines.append("    ~" + managedClassName + "();")
        lines.append("")

        lines.append(contentsOf: generatedStaticMethodDefinitions.map({ "    " + $0 }))
        if !generatedStaticMethodDefinitions.isEmpty { lines.append("") }
        lines.append(contentsOf: generatedMethodDefinitions.map({ "    " + $0 }))

        lines.append("};")
        return lines
    }

    func generateClassImplementation() -> [String] {

        let scopedUnmanagedTypeName: String = unmanagedNamespace + "::" + unmanagedClassName
        let scopedManagedTypeName: String = managedNamespace + "::" + managedClassName

        var lines: [String] = []

        // Wrapper constructor
        if useSharedPtrs {
            lines.append(scopedManagedTypeName + "::" + managedClassName + "(std::shared_ptr<" + scopedUnmanagedTypeName + "> *objectToTakeOwnershipOf) {")
        } else {
            lines.append(scopedManagedTypeName + "::" + managedClassName + "(" + scopedUnmanagedTypeName + " *objectToTakeOwnershipOf) {")
        }
        lines.append("    " + unmanagedObjectName + " = objectToTakeOwnershipOf;")
        lines.append("}")
        lines.append("")

        // Wrapped constructor(s)
        for implementation in generatedConstructorImplementations {
            lines.append(contentsOf: implementation)
            lines.append("")
        }

        // Destructor
        lines.append(scopedManagedTypeName + "::~" + managedClassName + "() {")
        lines.append("    delete " + unmanagedObjectName + ";")
        lines.append("}")
        lines.append("")

        for implementation in generatedMethodImplementations {
            lines.append(contentsOf: implementation)
            lines.append("")
        }
        return lines
    }
}
