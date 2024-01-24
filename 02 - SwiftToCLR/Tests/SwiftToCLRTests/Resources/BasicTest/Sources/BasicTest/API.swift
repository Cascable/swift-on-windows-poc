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

public enum WorkType: Int {
    case returnValue
    case returnNil
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

    public func doOptionalWork(of type: WorkType, optionalString: String?) -> String? {
        switch type {
            case .returnNil: return nil
            case .returnValue: return "I did some work"
        }
    }
}
