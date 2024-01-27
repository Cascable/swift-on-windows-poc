import Foundation
import XCTest
@testable import SwiftToCLRCodegen

class CodeGenerationTests: XCTestCase {

    func testModuleToUnmanaged() throws {

        let inputFile = try XCTUnwrap(testFile(named: "CascableCoreBasicAPI-Swift", extension: "h"))
        let cxxParent = try XCTUnwrap(testFile(named: "swiftToCxx", extension: nil)).deletingLastPathComponent()

        let resultFiles = try ModuleToUnmanagedOperation.execute(inputHeaderPath: inputFile.path,
                                                                 inputModuleName: "CascableCoreBasicAPI",
                                                                 wrappedObjectVariableName: "swiftObj",
                                                                 outputNamespace: "UnmanagedCascableCoreBasicAPI",
                                                                 platformRoot: nil,
                                                                 cxxInteropContainerPath: cxxParent.path,
                                                                 verbose: true)
        for file in resultFiles {
            print("-----", file.name, "-----")
            print(String(decoding: file.contents, as: UTF8.self))
        }
    }

    func testUnmanagedToManaged() throws {

        let inputFile = try XCTUnwrap(testFile(named: "UnmanagedCascableCoreBasicAPI", extension: "hpp"))

        let resultFiles = try UnmanagedToManagedOperation.execute(
            inputHeaderPath: inputFile.path,
            inputNamespace: "UnmanagedCascableCoreBasicAPI",
            wrappedObjectVariableName: "wrappedObj",
            outputNamespace: "ManagedCascableCoreBasicAPI",
            platformRoot: nil,
            verbose: true)

        XCTAssert(resultFiles.count == 2)

        for file in resultFiles {
            print("-----", file.name, "-----")
            print(String(decoding: file.contents, as: UTF8.self))
        }
    }
}

