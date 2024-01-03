import Foundation

extension PropertyValue {

    // TODO: Implement this
    func isEqual(_ other: Any?) -> Bool {
        return false
    }

}

extension Bundle {
    static var forLocalizations: Bundle {
        // On Mac/iOS, this should be the main CascableCore bundle, since the simulated camera pinches
        // string values from there.
        return Bundle.module
    }
}

public struct UniversalExposurePropertyValuePlaceholder {
    func isEqual(_ other: Any?) -> Bool {
        return true
    }
}

// We don't have StopKit in Swift yet.
public typealias UniversalExposurePropertyValue = UniversalExposurePropertyValuePlaceholder

public typealias PlatformImageType = ImagePlaceholder


