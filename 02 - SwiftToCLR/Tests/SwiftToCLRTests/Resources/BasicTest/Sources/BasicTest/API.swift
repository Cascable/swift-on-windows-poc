import Foundation

public enum APIEnum: Int {
    case caseOne
    case caseTwo
}

public struct APIStruct {
    public let enumValue: APIEnum

    public init(enumValue: APIEnum) {
        self.enumValue = enumValue
    }
}

public protocol APIProtocol {
    func sayHello(to name: String) -> String
}

public class APIClass: APIProtocol {

    public init() {}

    public var text: String {
        return "API!"
    }

    public func sayHello(to name: String) -> String {
        return "Hello from Swift, \(name)!"
    }

    public func doWork(with structValue: APIStruct) -> APIStruct {
        print("structValue is", structValue)
        return APIStruct(enumValue: structValue.enumValue)
    }
}
