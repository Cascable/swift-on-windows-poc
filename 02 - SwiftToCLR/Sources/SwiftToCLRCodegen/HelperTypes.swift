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
        return lhs.unmanagedTypeName == rhs.unmanagedTypeName && lhs.managedTypeName == rhs.unmanagedTypeName
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(unmanagedTypeName)
        hasher.combine(managedTypeName)
    }

    /// Returns a "direct" mapping (i.e., no work needs to be done) for a given type.
    static func direct(for typeName: String) -> TypeMapping {
        return TypeMapping(unmanagedTypeName: typeName, managedTypeName: typeName, convertManagedToUnmanaged: {
            return $0
        }, convertUnmanagedToManaged: {
            return $0
        })
    }

    let unmanagedTypeName: String
    let managedTypeName: String

    let convertManagedToUnmanaged: (_ variableName: String) -> String
    let convertUnmanagedToManaged: (_ variableName: String) -> String
}

public struct GeneratedFile {
    public let name: String
    public let contents: Data
}
