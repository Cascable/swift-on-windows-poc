import Foundation
import clang

extension CXString: CustomStringConvertible, CustomDebugStringConvertible {

    public var description: String {
        return asString
    }

    public var debugDescription: String {
        return asString
    }

    var asString: String {
        return String(cString: UnsafePointer(clang_getCString(self)))
    }

    /// Convert the receiver to a Swift String. SELF WILL BE DISPOSED - DON'T USE IT AGAIN.
    var consumeToString: String {
        let string = String(cString: UnsafePointer(clang_getCString(self)))
        clang_disposeString(self)
        return string
    }
}

extension CXCursor {
    var briefName: String {
        let cursorKind: CXCursorKind = clang_getCursorKind(self)
        let kindSpelling = clang_getCursorKindSpelling(cursorKind)
        defer { clang_disposeString(kindSpelling) }
        return kindSpelling.asString
    }
}

