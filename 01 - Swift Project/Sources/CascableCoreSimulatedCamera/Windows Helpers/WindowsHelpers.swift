import Foundation

extension Bundle {
    static var forLocalizations: Bundle {
        // On Mac/iOS, this should be the main CascableCore bundle, since the simulated camera pinches
        // string values from there.
        return Bundle.module
    }
}

#if !os(Windows)
// Stub for this project - in reality, this is provided by CascableCore.
internal class NetworkConfigurationHelper {
    static func suggestedInterfaceForCameraCommunication() -> String? { return "en0 "}
    static func ipAddress(ofInterface: String) -> String { return "127.0.0.1" }
}
#endif
