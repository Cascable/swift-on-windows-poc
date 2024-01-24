import Foundation
import clang
import OrderedCollections

public struct ModuleToUnmanagedOperation {

    public static func execute(inputHeaderPath: String, inputModuleName: String, wrappedObjectVariableName: String,
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
            "-D_ALLOW_KEYWORD_MACROS",
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

        let options = (CXTranslationUnit_SkipFunctionBodies.rawValue |
                       CXTranslationUnit_KeepGoing.rawValue |
                       CXTranslationUnit_IncludeAttributedTypes.rawValue |
                       CXTranslationUnit_VisitImplicitAttributes.rawValue |
                       CXTranslationUnit_RetainExcludedConditionalBlocks.rawValue)

        argumentPointers.withUnsafeBufferPointer { ptr in
            let argumentsBasePtr = ptr.baseAddress!
            unit = clang_parseTranslationUnit(index, inputFilePath.path,
                                              argumentsBasePtr, Int32(argumentPointers.count),
                                              nil, 0, UInt32(options))
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

        var wrapperClasses: OrderedDictionary<String, UnmanagedManagedCPPWrapperClass> = [:]
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
            //let kindSpelling = clang_getCursorKindSpelling(cursorKind).consumeToString
            //let typeSpelling = clang_getTypeSpelling(type).consumeToString
            //let typeKindSpelling = clang_getTypeKindSpelling(type.kind).consumeToString
            //print("Display name: \(displayName), Kind: \(kindSpelling), Type: \(typeSpelling), Type Kind: \(typeKindSpelling), Parent: \(parent.briefName)")

            if cursorKind == CXCursor_EnumConstantDecl && parentKind == CXCursor_EnumDecl &&
                clang_getCursorKind(clang_getCursorLexicalParent(parent)) == CXCursor_ClassDecl {

                // We found what appears to be a Swift enum case declaration (an enum case with a parent enum with a
                // parent class). I feel like this could be fragile, since we're relying on the fact that the C++ interop
                // embeds the C++ enum declaration inside a class.
                let parentParent: CXCursor = clang_getCursorLexicalParent(parent)
                let parentParentName = clang_getCursorDisplayName(parentParent).consumeToString

                let className = parentParentName
                let caseName = displayName
                let caseType = clang_getTypeSpelling(type).consumeToString

                if var wrapperClass = wrapperClasses[className], clang_getCXXAccessSpecifier(cursor) == CX_CXXPublic {
                    if verbose { print("Got enum case \(caseName) of type \(caseType) in \(className) - adding to wrapper list") }
                    wrapperClass.generateEnumCaseForSwiftEnumCase(at: cursor)
                    wrapperClasses[className] = wrapperClass // CoW and all that
                }
            }

            if cursorKind == CXCursor_ClassDecl && parentKind == CXCursor_Namespace {
                let className = displayName
                let namespaceName = clang_getCursorDisplayName(parent).consumeToString
                if namespaceName == inputModuleName {
                    if verbose { print("Got class \(className) in target namespace \(namespaceName) - adding to wrapper list.") }

                    // Swift current declares protocols as unavailable, so try to find that attribute on the class
                    // definition. This feels a little bit clunky to me.
                    let classIsUnavailable: Bool = {
                        let hasAttributes = clang_Cursor_hasAttrs(cursor)
                        guard hasAttributes > 0 else { return false }
                        var didEncounterUnavailableAttribute: Bool = false

                        clang_visitChildrenWithBlock(cursor) { classChildCursor, _ in
                            let kind: CXCursorKind = clang_getCursorKind(classChildCursor)
                            guard className == "APIProtocol" else { return CXChildVisit_Continue }
                            guard kind == CXCursor_FirstAttr else { return CXChildVisit_Continue }

                            let range: CXSourceRange = clang_getCursorExtent(classChildCursor)

                            var tokenCount: UInt32 = 0
                            var tokens: UnsafeMutablePointer<CXToken>? = nil

                            clang_tokenize(unit, range, &tokens, &tokenCount)
                            guard let tokens else { return CXChildVisit_Continue }
                            defer { clang_disposeTokens(unit, tokens, tokenCount) }
                            guard tokenCount > 0 else { return CXChildVisit_Continue }

                            // Maybe due to macros or defines, sometimes the declared types get a pile of "attributes"
                            // tacked on to them. One type had tens of thousands? I've observed that the unavailable
                            // attribute is the first one, so we're just checking that.
                            let tokenValue = clang_getTokenSpelling(unit, tokens[0]).consumeToString
                            if tokenValue == "unavailable" {
                                if verbose { print("Class \(className) is marked as unavailable, removing from wrapper list.") }
                                didEncounterUnavailableAttribute = true
                                return CXChildVisit_Break
                            } else {
                                return CXChildVisit_Continue
                            }
                        }

                        return didEncounterUnavailableAttribute
                    }()

                    let wrapperClass: UnmanagedManagedCPPWrapperClass = {
                        if var existing = wrapperClasses[className] {
                            if !existing.isUnavailable && classIsUnavailable {
                                existing.isUnavailable = classIsUnavailable
                                wrapperClasses[className] = existing
                            }
                            return existing
                        }

                        let newClass = UnmanagedManagedCPPWrapperClass(swiftClassName: className,
                                                                       swiftModuleName: namespaceName,
                                                                       swiftObjectName: wrappedObjectVariableName,
                                                                       wrapperClassName: className,
                                                                       wrapperNamespace: outputNamespace,
                                                                       isUnavailable: classIsUnavailable)
                        wrapperClasses[className] = newClass
                        return newClass
                    }()

                    // We also need to be able to adapt to/from it.
                    // As long the header we're wrapping forward-declares everything within the namespace, this works
                    // alright. Without, we'd need to do two passes - one to collect all the types, then another to
                    // adapt the method calls.
                    let constMapping = TypeMapping(wrappedTypeName: "const " + wrapperClass.swiftModuleName + "::" + wrapperClass.swiftClassName + " &",
                                                   wrapperTypeName: "const " + wrapperClass.wrapperNamespace + "::" + wrapperClass.wrapperClassName + " &",
                                                   convertWrapperToWrapped: {
                        return "*\($0).\(wrapperClass.swiftObjectName).get()"
                    }, convertWrappedToWrapper: {
                        return "\(wrapperClass.wrapperNamespace)::\(wrapperClass.wrapperClassName)(std::make_shared<\(wrapperClass.swiftModuleName)::\(wrapperClass.swiftClassName)>(\($0)))"
                    })

                    let flatMapping = TypeMapping(wrappedTypeName: wrapperClass.swiftModuleName + "::" + wrapperClass.swiftClassName,
                                                   wrapperTypeName: wrapperClass.wrapperNamespace + "::" + wrapperClass.wrapperClassName,
                                                   convertWrapperToWrapped: {
                        return "\($0)->\(wrapperClass.swiftObjectName).get()"
                    }, convertWrappedToWrapper: {
                        return "\(wrapperClass.wrapperNamespace)::\(wrapperClass.wrapperClassName)(std::make_shared<\(wrapperClass.swiftModuleName)::\(wrapperClass.swiftClassName)>(\($0)))"
                    })

                    internalTypeMappings["const " + className + " &"] = constMapping // This seems fragile.
                    internalTypeMappings[className] = flatMapping // This seems fragile.
                }
            }

            if type.kind == CXType_FunctionProto && cursorKind == CXCursor_CXXMethod && parentKind == CXCursor_ClassDecl {
                let className = clang_getCursorDisplayName(parent).consumeToString
                if var wrapperClass = wrapperClasses[className], clang_getCXXAccessSpecifier(cursor) == CX_CXXPublic {
                    let wasAdded = wrapperClass.generateWrappedMethodForSwiftMethod(at: cursor, in: unit, internalTypeMappings: internalTypeMappings)
                    if verbose, wasAdded { print("Got public method \(displayName) in class \(className) - adding to wrapper list.") }
                    wrapperClasses[className] = wrapperClass // CoW and all that
                }
            }

            return CXChildVisit_Recurse
        }

        // Generate content.

        var hppContent: [String] = [
            "// This is an auto-generated file. Do not modify.",
            "",
            "#ifndef " + outputNamespace + "_hpp",
            "#define " + outputNamespace + "_hpp",
            "#include <memory>",
            "#include <string>",
            "#include <optional>",
            ""
        ]

        let availableWrapperClasses = wrapperClasses.values.filter({ !$0.isUnavailable })

        // We need to forward-declare the Swift module types we're wrapping.
        hppContent.append("namespace " + inputModuleName + " {")
        for wrapperClass in availableWrapperClasses {
            hppContent.append("    class " + wrapperClass.swiftClassName + ";")
        }
        hppContent.append("}")
        hppContent.append("")

        hppContent.append("namespace " + outputNamespace + " {")
        hppContent.append("")

        // We also need to forward-declare all of our wrapper classes in case they reference each other.
        for wrapperClass in availableWrapperClasses {
            hppContent.append("    " + "class " + wrapperClass.wrapperClassName + ";")
        }

        for wrapperClass in availableWrapperClasses {
            hppContent.append("")
            hppContent.append(contentsOf: wrapperClass.generateClassDefinition().map({ "    " + $0 }))
        }

        hppContent.append("}")
        hppContent.append("")
        hppContent.append("#endif /* " + outputNamespace + "_hpp */")
        hppContent.append("")

        var cppContent: [String] = [
            "// This is an auto-generated file. Do not modify.",
            "",
            "#include \"" + outputNamespace + ".hpp\"",
            "#include <" + inputFileName + ">",
            ""
        ]

        for wrapperClass in availableWrapperClasses {
            cppContent.append("// Implementation of " + wrapperClass.wrapperNamespace + "::" + wrapperClass.wrapperClassName)
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

struct SwiftToUnmanagedTypeMappings {

    static let swiftStringMapping: TypeMapping =
        TypeMapping(wrappedTypeName: "swift::String",
                    wrapperTypeName: "std::string",
                    convertWrapperToWrapped: {
            return "(swift::String)\($0)"
        }, convertWrappedToWrapper: {
            return "(std::string)\($0)"
        })

    static let swiftStringConstStdStringMapping: TypeMapping =
        TypeMapping(wrappedTypeName: "const swift::String &",
                    wrapperTypeName: "const std::string &",
                    convertWrapperToWrapped: {
            return "(swift::String)\($0)"
        }, convertWrappedToWrapper: {
            return "(std::string)\($0)"
        })

    static let swiftIntMapping: TypeMapping =
        TypeMapping(wrappedTypeName: "swift::Int",
                    wrapperTypeName: "int",
                    convertWrapperToWrapped: {
            return "(swift::Int)\($0)"
        }, convertWrappedToWrapper: {
            return "(int)\($0)"
        })

    static let mappingsBySwiftType: [String: TypeMapping] = [
        swiftStringMapping.wrappedTypeName: swiftStringMapping,
        swiftStringConstStdStringMapping.wrappedTypeName: swiftStringConstStdStringMapping,
        swiftIntMapping.wrappedTypeName: swiftIntMapping
    ]

    static let mappingsByUnmanagedType: [String: TypeMapping] = [
        swiftStringMapping.wrapperTypeName: swiftStringMapping,
        swiftIntMapping.wrapperTypeName: swiftIntMapping
    ]

    static func unmanagedMapping(from swiftTypeName: String) -> TypeMapping? {
        return mappingsBySwiftType[swiftTypeName]
    }
}

/// Represents an unmanaged C++ class wrapping a Swift object's C++ interface.
struct UnmanagedManagedCPPWrapperClass {
    let swiftClassName: String
    let swiftModuleName: String
    let swiftObjectName: String

    let wrapperClassName: String
    let wrapperNamespace: String

    // True if the type is marked as unavailable in the source header.
    var isUnavailable: Bool

    var generatedMethodDefinitions: [String] // For the header file
    var generatedConstructorDefinitions: [String] // For the header file
    var generatedEnumCaseDefinitions: [String] // For the header file
    var generatedStaticMethodDefinitions: [String] // For the header file
    var generatedMethodImplementations: [[String]]  // For the implementation file.
    var generatedConstructorImplementations: [[String]] // For the implementation file.
    var generatedEnumCaseImplementations: [[String]] // For the implementation file.

    init(swiftClassName: String, swiftModuleName: String, swiftObjectName: String, wrapperClassName: String,
         wrapperNamespace: String, isUnavailable: Bool) {
        self.swiftClassName = swiftClassName
        self.swiftModuleName = swiftModuleName
        self.swiftObjectName = swiftObjectName
        self.wrapperClassName = wrapperClassName
        self.wrapperNamespace = wrapperNamespace
        self.isUnavailable = isUnavailable
        self.generatedMethodDefinitions = []
        self.generatedConstructorDefinitions = []
        self.generatedEnumCaseDefinitions = []
        self.generatedStaticMethodDefinitions = []
        self.generatedMethodImplementations = []
        self.generatedConstructorImplementations = []
        self.generatedEnumCaseImplementations = []
    }

    mutating func generateEnumCaseForSwiftEnumCase(at cursor: CXCursor) {
        let cursorType: CXType = clang_getCursorType(cursor)
        let cursorKind: CXCursorKind = clang_getCursorKind(cursor)
        assert(cursorType.kind == CXType_Enum, "Passed wrong cursor type")
        assert(cursorKind == CXCursor_EnumConstantDecl, "Passed wrong cursor kind")

        let enumCaseName = clang_getCursorDisplayName(cursor).consumeToString
        let scopedWrapperClassName = wrapperNamespace + "::" + wrapperClassName
        let scopedSwiftClassName = swiftModuleName + "::" + swiftClassName

        //static APIEnum caseOne();
        generatedEnumCaseDefinitions.append("static " + scopedWrapperClassName + " " + enumCaseName + "();")

        //UnmanagedSwiftWrapper::APIEnum UnmanagedSwiftWrapper::APIEnum::caseOne() {
        //    BasicTest::APIEnum val = BasicTest::APIEnum::caseOne();
        //    return APIEnum(std::make_shared<BasicTest::APIEnum>(val));
        //}
        var implementationLines: [String] = []
        implementationLines.append(scopedWrapperClassName + " " + scopedWrapperClassName + "::" + enumCaseName + "() {")
        implementationLines.append("    " + scopedSwiftClassName + " value = " + scopedSwiftClassName + "::" + enumCaseName + "();")
        implementationLines.append("    return " + scopedWrapperClassName + "(std::make_shared<" + scopedSwiftClassName + ">(value));")
        implementationLines.append("}")
        generatedEnumCaseImplementations.append(implementationLines)
    }

    mutating func generateWrappedMethodForSwiftMethod(at cursor: CXCursor, in unit: CXTranslationUnit, internalTypeMappings: [String: TypeMapping]) -> Bool {
        let cursorType: CXType = clang_getCursorType(cursor)
        let cursorKind: CXCursorKind = clang_getCursorKind(cursor)
        assert(cursorType.kind == CXType_FunctionProto, "Passed wrong cursor type")
        assert(cursorKind == CXCursor_CXXMethod, "Passed wrong cursor kind")

        // We need to get the return type.
        let swiftReturnArgument: MethodArgument = {
            if let tokenization = cursor.condensedTokenization(in: unit),
                let optionalArgument = MethodArgument(extractingFirstOptionalTypeFromCondensedTokenization: tokenization, argumentName: "") {
                    return optionalArgument
            } else {
                let swiftReturnType: CXType = clang_getResultType(cursorType)
                let swiftReturnTypeName = clang_getTypeSpelling(swiftReturnType).consumeToString
                let returnIsVoid = (swiftReturnType.kind == CXType_Void)
                return MethodArgument(typeName: swiftReturnTypeName, argumentName: "", isOptionalType: false, isVoidType: returnIsVoid)
            }
        }()

        // And the method name.
        let swiftMethodName = clang_getCursorSpelling(cursor).consumeToString
        let isConstructor = (swiftMethodName == "init")

        let excludedMethods: [String] = ["operator="]
        guard !excludedMethods.contains(swiftMethodName) else { return false }

        // …and the arguments.
        let argumentCount = UInt32(clang_Cursor_getNumArguments(cursor)) // Can return -1 if the wrong cursor type. We checked that above.
        let swiftArguments: [MethodArgument] = (0..<argumentCount).map({ argumentIndex in
            let argumentCursor: CXCursor = clang_Cursor_getArgument(cursor, argumentIndex)
            let argumentName = clang_getCursorSpelling(argumentCursor).consumeToString
            let argumentType: CXType = clang_getArgType(cursorType, argumentIndex)
            let argumentTypeName = clang_getTypeSpelling(argumentType).consumeToString

            if let argumentSpelling = argumentCursor.condensedTokenization(in: unit),
                let argument = MethodArgument(extractingFirstOptionalTypeFromCondensedTokenization: argumentSpelling, argumentName: argumentName) {
                return argument
            } else {
                return MethodArgument(typeName: argumentTypeName, argumentName: argumentName, isOptionalType: false, isVoidType: false)
            }
        })

        // We have everything we need to wrap the method now!

        func wrapping(for swiftTypeName: String) -> TypeMapping {
            if let stdMapping = SwiftToUnmanagedTypeMappings.unmanagedMapping(from: swiftTypeName) { return stdMapping }
            if let internalMapping = internalTypeMappings[swiftTypeName] { return internalMapping }
            return .direct(for: swiftTypeName)
        }

        let returnTypeMapping = wrapping(for: swiftReturnArgument.typeName)
        let unmanagedReturnTypeName = returnTypeMapping.wrapperTypeName

        let unmanagedMethodArguments: [String] = swiftArguments.map({ argument in
            if argument.isOptionalType {
                return "const std::optional<\(wrapping(for: argument.typeName).wrapperTypeName)> & \(argument.argumentName)"
            } else {
                return "\(wrapping(for: argument.typeName).wrapperTypeName) \(argument.argumentName)"
            }
        })

        // Header definition.
        if isConstructor {
            if swiftReturnArgument.isOptionalType {
                // C++ doesn't have optional constructors, so make this a static method instead.
                let mashedArgumentNames: String = swiftArguments.map({
                    $0.argumentName.prefix(1).uppercased() + $0.argumentName.dropFirst()
                }).joined(separator: "And")
                let methodDefinition = "static std::optional<" + unmanagedReturnTypeName + "> initWith" + mashedArgumentNames + "(" +
                    unmanagedMethodArguments.joined(separator: ", ") + ");"
                generatedStaticMethodDefinitions.append(methodDefinition);
            } else {
                let methodDefinition = swiftClassName + "(" + unmanagedMethodArguments.joined(separator: ", ") + ");"
                generatedConstructorDefinitions.append(methodDefinition)
            }
        } else {
            let methodDefinition: String = {
                if swiftReturnArgument.isOptionalType {
                    return "std::optional<" + unmanagedReturnTypeName + "> " + swiftMethodName + "(" +
                        unmanagedMethodArguments.joined(separator: ", ") + ");"
                } else {
                    return unmanagedReturnTypeName + " " + swiftMethodName + "(" +
                        unmanagedMethodArguments.joined(separator: ", ") + ");"
                }
            }()
            generatedMethodDefinitions.append(methodDefinition)
        }

        let scopedSwiftClassName = swiftModuleName + "::" + swiftClassName
        let scopedWrapperClassName = wrapperNamespace + "::" + wrapperClassName

        // Implementation
        if isConstructor && !swiftReturnArgument.isOptionalType {
            let openingLine: String = scopedWrapperClassName + "::" + wrapperClassName + "("
                + unmanagedMethodArguments.joined(separator: ", ") + ") {"
            var constructorLines: [String] = [openingLine]

            let parameterName: String = "arg"

            // Adapt the parameters
            for (index, argument) in swiftArguments.enumerated() {
                // We need to bridge each argument to the Swift type.
                let swiftType = argument.typeName
                let mapping = wrapping(for: swiftType)
                let adaptedArgument: String = mapping.wrappedTypeName + " " + parameterName + "\(index) = " + mapping.convertWrapperToWrapped(argument.argumentName) + ";"
                constructorLines.append("    " + adaptedArgument)
            }

            let args: String = (0..<swiftArguments.count).map({ "arg\($0)" }).joined(separator: ", ")

            constructorLines.append("    " + scopedSwiftClassName + " instance = " + scopedSwiftClassName + "::init(" + args + ");")
            constructorLines.append("    " + swiftObjectName + " = std::make_shared<" + scopedSwiftClassName + ">(instance);")
            constructorLines.append("}")
            generatedConstructorImplementations.append(constructorLines)
        } else {

            let openingLine: String = {
                if swiftReturnArgument.isOptionalType && isConstructor {
                    // We transform failable inits into static methods.
                    /// C++ doesn't have optional constructors, so make this a static method instead.
                    let mashedArgumentNames: String = swiftArguments.map({
                        $0.argumentName.prefix(1).uppercased() + $0.argumentName.dropFirst()
                    }).joined(separator: "And")
                    return "std::optional<" + unmanagedReturnTypeName + "> " + scopedWrapperClassName + "::" +
                        "initWith" + mashedArgumentNames + "(" + unmanagedMethodArguments.joined(separator: ", ") + ") {"
                } else if swiftReturnArgument.isOptionalType {
                    return "std::optional<" + unmanagedReturnTypeName + "> " + scopedWrapperClassName + "::" +
                        swiftMethodName + "(" + unmanagedMethodArguments.joined(separator: ", ") + ") {"
                } else {
                    return unmanagedReturnTypeName + " " + scopedWrapperClassName + "::" +
                        swiftMethodName + "(" + unmanagedMethodArguments.joined(separator: ", ") + ") {"
                }
            }()

            var methodLines: [String] = [openingLine]

            let parameterName: String = "arg"

            // Adapt the parameters
            for (index, argument) in swiftArguments.enumerated() {
                // We need to bridge each argument to the Swift type.
                let swiftType = argument.typeName
                let mapping = wrapping(for: swiftType)
                if argument.isOptionalType {
                    // This is a bit clunky. Maybe we should rebuild the wrapping class to do this.
                    let swiftOptionalType: String = "swift::Optional<" + mapping.wrappedTypeName + ">"
                    // swift::Optional<swift::String> arg1 = (optionalString.has_value() ? swift::Optional<swift::String>::init((swift::String)optionalString.value()) : swift::Optional<swift::String>::none());
                    let adaptedArgument: String = swiftOptionalType + parameterName + "\(index) = (" + argument.argumentName + ".has_value() ? " +
                        swiftOptionalType + "::init(" + mapping.convertWrapperToWrapped(argument.argumentName) + ".value()) : " +
                        swiftOptionalType + "::none());"
                    methodLines.append("    " + adaptedArgument)
                } else {
                    let adaptedArgument: String = mapping.wrappedTypeName + " " + parameterName + "\(index) = " + mapping.convertWrapperToWrapped(argument.argumentName) + ";"
                    methodLines.append("    " + adaptedArgument)
                }
            }

            let args: String = (0..<swiftArguments.count).map({ "arg\($0)" }).joined(separator: ", ")

            if swiftReturnArgument.isVoidType {
                let methodCall: String = swiftObjectName + "->" + swiftMethodName + "(" + args + ");"
                methodLines.append("    " + methodCall)
            } else {
                // Call the method!
                if isConstructor {
                    let methodCall: String = "swift::Optional<" + returnTypeMapping.wrappedTypeName + "> swiftResult = "
                        + scopedSwiftClassName + "::" + swiftMethodName + "(" + args + ");"
                    methodLines.append("    " + methodCall)
                } else if swiftReturnArgument.isOptionalType {
                    let methodCall: String = "swift::Optional<" + returnTypeMapping.wrappedTypeName + "> swiftResult = " + swiftObjectName
                        + "->" + swiftMethodName + "(" + args + ");"
                    methodLines.append("    " + methodCall)
                } else {
                    let methodCall: String = returnTypeMapping.wrappedTypeName + " swiftResult = " + swiftObjectName
                        + "->" + swiftMethodName + "(" + args + ");"
                    methodLines.append("    " + methodCall)
                }

                // Finally, translate back to the unmanaged type and return it.
                if swiftReturnArgument.isOptionalType {
                    // This needs to be multiline so we can make that explicit reference to the new value.
                    // Passing an optional's get() result straight to the wrapper constructor can trigger
                    // the Swift C++ interop's current non-support of C++ move semantics.
                    var optionalConversionLines: [String] = ["if (swiftResult) {"]
                    optionalConversionLines.append("    " + returnTypeMapping.wrappedTypeName + " unwrapped = swiftResult.get();")
                    optionalConversionLines.append("    return std::optional<" + returnTypeMapping.wrapperTypeName + ">(" +
                            returnTypeMapping.convertWrappedToWrapper("unwrapped") + ");")
                    optionalConversionLines.append("} else {")
                    optionalConversionLines.append("    return std::nullopt;")
                    optionalConversionLines.append("}")
                    methodLines.append(contentsOf: optionalConversionLines.map({ "    " + $0 }))
                } else {
                    let returnLine = "return " + returnTypeMapping.convertWrappedToWrapper("swiftResult") + ";"
                    methodLines.append("    " + returnLine)
                }
            }

            methodLines.append("}")
            generatedMethodImplementations.append(methodLines)
        }

        return true
    }

    func generateClassDefinition() -> [String] {
        var lines: [String] = []

        let scopedSwiftClassName: String = swiftModuleName + "::" + swiftClassName
        let scopedWrapperClassName: String = wrapperNamespace + "::" + wrapperClassName

        lines.append("class " + wrapperClassName + " {")
        lines.append("private:")
        lines.append("public:")
        lines.append("    std::shared_ptr<" + scopedSwiftClassName + "> " + swiftObjectName + ";")
        lines.append("    " + wrapperClassName + "(std::shared_ptr<" + scopedSwiftClassName + "> " + swiftObjectName + ");")
        lines.append(contentsOf: generatedConstructorDefinitions.map({ "    " + $0 }))
        lines.append("    ~" + wrapperClassName + "();")
        lines.append("")

        if !generatedStaticMethodDefinitions.isEmpty {
            lines.append(contentsOf: generatedStaticMethodDefinitions.map({ "    " + $0 }))
            lines.append("")
        }

        if !generatedEnumCaseDefinitions.isEmpty {
            lines.append(contentsOf: generatedEnumCaseDefinitions.map({ "    " + $0 }))
            lines.append("")
            lines.append("    bool operator==(const " + scopedWrapperClassName + " &other) const;")
            lines.append("")
        }

        for methodDefinition in generatedMethodDefinitions {
            lines.append("    "  + methodDefinition)
        }

        lines.append("};")
        return lines
    }

    func generateClassImplementation() -> [String] {
        var lines: [String] = []

        let scopedSwiftClassName: String = swiftModuleName + "::" + swiftClassName
        let scopedWrapperClassName: String = wrapperNamespace + "::" + wrapperClassName

        lines.append(scopedWrapperClassName + "::" + wrapperClassName + "(std::shared_ptr<" + scopedSwiftClassName + "> " + swiftObjectName + ") {")
        lines.append("    this->" + swiftObjectName + " = " + swiftObjectName + ";")
        lines.append("}")
        lines.append("")

        for constructor in generatedConstructorImplementations {
            lines.append(contentsOf: constructor)
            lines.append("")
        }

        lines.append(scopedWrapperClassName + "::~" + wrapperClassName + "() {}")
        lines.append("")

        if !generatedEnumCaseImplementations.isEmpty {
            for generatedEnumCaseImplementation in generatedEnumCaseImplementations {
                lines.append(contentsOf: generatedEnumCaseImplementation)
                lines.append("")
            }

            // bool UnmanagedSwiftWrapper::APIEnum::operator==(const UnmanagedSwiftWrapper::APIEnum &other) const {
            //      return (*internal.get() == *other.internal.get());
            // }
            var comparator: [String] = []
            comparator.append("bool " + scopedWrapperClassName + "::operator==(const " + scopedWrapperClassName + " &other) const {")
            comparator.append("    return (*\(swiftObjectName).get() == *other.\(swiftObjectName).get());")
            comparator.append("}")

            lines.append(contentsOf: comparator)
            lines.append("")
        }

        for implementation in generatedMethodImplementations {
            lines.append(contentsOf: implementation)
            lines.append("")
        }
        return lines
    }
}
