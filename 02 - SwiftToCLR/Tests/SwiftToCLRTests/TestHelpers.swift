import Foundation
import XCTest

func testFile(named fileName: String, extension fileExtension: String?) -> URL? {
    guard let fileUrl = Bundle.module.url(forResource: fileName, withExtension: fileExtension, subdirectory: "Resources") else {
        XCTFail("Couldn't get file named \(fileName)")
        return nil
    }
    return fileUrl
}
