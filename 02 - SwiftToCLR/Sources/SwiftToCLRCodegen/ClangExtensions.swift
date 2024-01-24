import Foundation
import clang

enum ClangError: Error {
    case initialization(String)
}

public func clangVersionString() -> String {
    return clang_getClangVersion().consumeToString
}

extension CXTranslationUnit {
    func printDiagnostics() {
        let numberOfDiagnosticMessages = clang_getNumDiagnostics(self)
        if numberOfDiagnosticMessages > 0 {
            print("Warning: Got \(numberOfDiagnosticMessages) diagnostic messages from clang:")
            for index in 0..<numberOfDiagnosticMessages {
                let diagnostic = clang_getDiagnostic(self, index)
                print(clang_formatDiagnostic(diagnostic, clang_defaultDiagnosticDisplayOptions()).consumeToString)
            }
        }
    }
}

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

    func condensedTokenization(in unit: CXTranslationUnit) -> String? {
        let range: CXSourceRange = clang_getCursorExtent(self)

        var tokenCount: UInt32 = 0
        var tokens: UnsafeMutablePointer<CXToken>? = nil
        clang_tokenize(unit, range, &tokens, &tokenCount)

        guard let tokens else { return nil }
        defer { clang_disposeTokens(unit, tokens, tokenCount) }
        guard tokenCount > 0 else { return "" }
        return (0..<tokenCount).map({ clang_getTokenSpelling(unit, tokens[Int($0)]).consumeToString }).joined()
    }
}

