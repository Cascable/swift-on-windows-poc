import Foundation

/// A representation of a method argument.
struct MethodArgument: Hashable {
    let typeName: String
    let argumentName: String
    let isOptionalType: Bool
    let isVoidType: Bool

    init(typeName: String, argumentName: String, isOptionalType: Bool, isVoidType: Bool) {
        self.typeName = typeName
        self.argumentName = argumentName
        self.isOptionalType = isOptionalType
        self.isVoidType = isVoidType
    }

    init?(extractingOptionalTypeFromCondensedArgumentTokenization argumentSpelling: String, argumentName: String) {
        // RED FLAG: This is definitely not the best way to do this. However, clang seems to trip up and report
        // swift::Optional<T> types as just "int", which is what it seems to do if it can't find the definition
        // of a type. I can't immediately figure out why this is, so here's a stopgap solution in the meantime.
        let optionalContainerStart: String = "swift::Optional<"
        let optionalContainerEnd: String = ">"
        guard let containerStartRange = argumentSpelling.range(of: optionalContainerStart),
            let containerEndRange = argumentSpelling.range(of: optionalContainerEnd, range: containerStartRange.upperBound..<argumentSpelling.endIndex) else { return nil }
        let containedType: String = String(argumentSpelling[containerStartRange.upperBound..<containerEndRange.lowerBound])
        self.typeName = containedType
        self.argumentName = argumentName
        self.isOptionalType = true
        self.isVoidType = false
    }

    init?(extractingOptionalReturnTypeFromCondensedMethodTokenization methodSpelling: String, of methodName: String) {
        // RED FLAG: This is definitely not the best way to do this. However, clang seems to trip up and report
        // swift::Optional<T> types as just "int", which is what it seems to do if it can't find the definition
        // of a type. I can't immediately figure out why this is, so here's a stopgap solution in the meantime.
        guard let rangeOfMethodName = methodSpelling.range(of: methodName) else { return nil }
        let returnTypeHaystack = methodSpelling[methodSpelling.startIndex..<rangeOfMethodName.lowerBound];

        let optionalContainerStart: String = "swift::Optional<"
        let optionalContainerEnd: String = ">"
        guard let containerStartRange = returnTypeHaystack.range(of: optionalContainerStart),
            let containerEndRange = returnTypeHaystack.range(of: optionalContainerEnd, range: containerStartRange.upperBound..<returnTypeHaystack.endIndex) else { return nil }
        let containedType: String = String(returnTypeHaystack[containerStartRange.upperBound..<containerEndRange.lowerBound])
        self.typeName = containedType
        self.argumentName = ""
        self.isOptionalType = true
        self.isVoidType = false
    }

    init(extractingOptionalOfType optionalType: String, from typeName: String, argumentName: String, isVoidType: Bool) {
        // We'll be given a string like std::optional<std::string> etc. `optionalType` should be given without the <>.
        let optionalContainerStart: String = optionalType + "<"
        let optionalContainerEnd: String = ">"

        if let containerStartRange = typeName.range(of: optionalContainerStart),
            let containerEndRange = typeName.range(of: optionalContainerEnd, range: containerStartRange.upperBound..<typeName.endIndex) {
            let containedType: String = String(typeName[containerStartRange.upperBound..<containerEndRange.lowerBound])
            self.typeName = containedType
            self.argumentName = argumentName
            self.isOptionalType = true
            self.isVoidType = isVoidType
        } else {
            self.typeName = typeName
            self.argumentName = argumentName
            self.isOptionalType = false
            self.isVoidType = isVoidType
        }
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
        return TypeMapping(wrappedTypeName: typeName, wrapperTypeName: typeName, convertWrapperToWrapped: {
            return $0
        }, convertWrappedToWrapper: {
            return $0
        })
    }

    /// The "inside" type, such as `std::string`.
    let wrappedTypeName: String
    /// The "outside" type, such as `system::string`.
    let wrapperTypeName: String

    let convertWrapperToWrapped:(_ variableName: String) -> String
    let convertWrappedToWrapper: (_ variableName: String) -> String
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
