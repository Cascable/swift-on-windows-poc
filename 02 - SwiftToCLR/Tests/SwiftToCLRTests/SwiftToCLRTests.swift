import Foundation
import XCTest
@testable import SwiftToCLRCodegen

class UnmanagedToManagedTests: XCTestCase {

    func testWrapping() throws {

        let inputFile = try XCTUnwrap(testFile(named: "UnmanagedSwiftWrapper", extension: "h"))

        let resultFiles = try UnmanagedToManagedOperation.execute(
            inputHeaderPath: inputFile.path,
            inputNamespace: "UnmanagedSwiftWrapper",
            wrappedObjectVariableName: "wrappedObj",
            outputNamespace: "ManagedWrapper",
            platformRoot: nil,
            verbose: true)

        XCTAssert(resultFiles.count == 2)

        for file in resultFiles {
            print("-----", file.name, "-----")
            print(String(decoding: file.contents, as: UTF8.self))
        }
    }
}

