import Foundation

extension Bundle {
    static var forLocalizations: Bundle {
        // On Mac/iOS, this should be the main CascableCore bundle, since the simulated camera pinches
        // string values from there.
        return Bundle.module
    }
}

public typealias PlatformImageType = ImagePlaceholder
