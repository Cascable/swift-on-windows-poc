import Foundation

/// A representation of a method argument.
struct MethodArgument: Hashable {
    let typeName: String
    let argumentName: String
}

/// Platform helpers.
struct Platform {
    static var defaultSDKRoot: String {
        // TODO: Try and make this smarter. Also Windows.
        return "/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk"
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
    public let name: String
    public let contents: Data
}
