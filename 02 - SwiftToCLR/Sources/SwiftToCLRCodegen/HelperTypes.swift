import Foundation

/// A representation of a method argument.
struct MethodArgument: Hashable {
    let typeName: String
    let argumentName: String
    let isOptionalType: Bool
    let isArrayType: Bool
    let isVoidType: Bool

    init(typeName: String, argumentName: String, isOptionalType: Bool, isArrayType: Bool, isVoidType: Bool) {
        self.typeName = typeName
        self.argumentName = argumentName
        self.isOptionalType = isOptionalType
        self.isArrayType = isArrayType
        self.isVoidType = isVoidType
    }

    init(extractingOptionalTypeFromCondensedArgumentTokenization argumentSpelling: String, argumentName: String) {
        // RED FLAG: This is definitely not the best way to do this. However, clang seems to trip up and report
        // swift::Optional<T> types as just "int", which is what it seems to do if it can't find the definition
        // of a type. I can't immediately figure out why this is, so here's a stopgap solution in the meantime.
        var extractedType: String = {
            if let argumentNameInSpellingRange = argumentSpelling.range(of: argumentName) {
                return String(argumentSpelling[argumentSpelling.startIndex..<argumentNameInSpellingRange.lowerBound])
            } else {
                return argumentSpelling
            }
        }()

        // RED FLAG 2: clang's property parsing deals with this.
        if extractedType.hasSuffix("_Nonnull") {
            extractedType = String(extractedType.dropLast("_Nonnull".count))
        }

        let demangledType: String = {
            // "Condensed" tokens have spaces stripped.
            if extractedType.hasPrefix("const") && extractedType.hasSuffix("&") {
                return "const " + String(extractedType.dropFirst("const".count).dropLast("&".count)) + " &"
            } else {
                return extractedType
            }
        }()

        self.init(extractingOptionalOfType: "swift::Optional", arrayOfType: "swift::Array", from: demangledType,
                  argumentName: argumentName, isVoidType: false)
    }

    init?(extractingOptionalReturnTypeFromCondensedMethodTokenization methodSpelling: String, of methodName: String) {
        // RED FLAG: This is definitely not the best way to do this. However, clang seems to trip up and report
        // swift::Optional<T> types as just "int", which is what it seems to do if it can't find the definition
        // of a type. I can't immediately figure out why this is, so here's a stopgap solution in the meantime.
        // DOUBLE RED FLAG: Static functions end up in here with a 'staticSWIFT_INLINE_THUNK' prefix. We should
        // only try to use this method for swift::Optional and swift::Array types.
        let manuallyFixedStaticDecl = methodSpelling.replacingOccurrences(of: "staticSWIFT_INLINE_THUNK", with: "")
        guard let rangeOfMethodName = manuallyFixedStaticDecl.range(of: methodName) else { return nil }
        let returnTypeHaystack = String(manuallyFixedStaticDecl[manuallyFixedStaticDecl.startIndex..<rangeOfMethodName.lowerBound]);
        self.init(extractingOptionalOfType: "swift::Optional", arrayOfType: "swift::Array", from: returnTypeHaystack,
                  argumentName: "", isVoidType: false)
    }

    init(extractingOptionalOfType optionalType: String, arrayOfType arrayType: String, from typeName: String, argumentName: String, isVoidType: Bool) {
        // We'll be given a string like std::optional<std::string> etc. `optionalType` should be given without the <>.
        let optionalContainerStart: String = optionalType + "<"
        let optionalContainerEnd: String = ">"

        let arrayContainerStart: String = arrayType + "<"
        let arrayContainerEnd: String = ">"

        let (unwrappedTypeName, isOptionalType): (String, Bool) = {
            guard let containerStartRange = typeName.range(of: optionalContainerStart),
                let containerEndRange = typeName.range(of: optionalContainerEnd, options: [.backwards],
                                                       range: containerStartRange.upperBound..<typeName.endIndex)
                else {
                    return (unwrappedTypeName: typeName, isOptionalType: false)
                }
            return (unwrappedTypeName: String(typeName[containerStartRange.upperBound..<containerEndRange.lowerBound]), isOptionalType: true)
        }()

        let (unarrayedTypeName, isArrayType): (String, Bool) = {
            guard let containerStartRange = unwrappedTypeName.range(of: arrayContainerStart),
                let containerEndRange = unwrappedTypeName.range(of: arrayContainerEnd, options: [.backwards],
                                                       range: containerStartRange.upperBound..<unwrappedTypeName.endIndex)
                else {
                    return (unarrayedTypeName: unwrappedTypeName, isArrayType: false)
                }
            return (unarrayedTypeName: String(unwrappedTypeName[containerStartRange.upperBound..<containerEndRange.lowerBound]), isArrayType: true)
        }()

        self.typeName = unarrayedTypeName
        self.argumentName = argumentName
        self.isOptionalType = isOptionalType
        self.isArrayType = isArrayType
        self.isVoidType = isVoidType
    }
}

/// A representation of a mapping between two related types (such as `swift::string` and `std::string`).
struct TypeMapping: Hashable {
    static func == (lhs: TypeMapping, rhs: TypeMapping) -> Bool {
        return lhs.wrappedTypeName == rhs.wrappedTypeName && lhs.wrapperTypeName == rhs.wrapperTypeName
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(wrappedTypeName)
        hasher.combine(wrapperTypeName)
    }

    /// Returns a "direct" mapping (i.e., no work needs to be done) for a given type.
    static func direct(for typeName: String) -> TypeMapping {
        return TypeMapping(wrappedTypeName: typeName, wrapperTypeName: typeName, convertWrapperToWrapped: { name, _ in
            return name
        }, convertWrappedToWrapper: { name, _ in
            return name
        })
    }

    /// The "inside" type, such as `std::string`.
    let wrappedTypeName: String
    /// The "outside" type, such as `system::string`.
    let wrapperTypeName: String

    let convertWrapperToWrapped:(_ variableName: String, _ isInConstEnvironment: Bool) -> String
    let convertWrappedToWrapper: (_ variableName: String, _ isInConstEnvironment: Bool) -> String
}

public struct GeneratedFile {
    public enum Kind {
        case header
        case implementation
    }

    public let kind: Kind
    public let name: String
    public let contents: Data
}
