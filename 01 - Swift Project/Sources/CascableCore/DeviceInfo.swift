import Foundation

/// Information about a connected camera.
public protocol DeviceInfo {

    /// Returns the device's manufacturer (for instance, 'Canon').
    var manufacturer: String? { get }

    /// Returns the device's model (for instance, 'EOS M3').
    var model: String? { get }

    /// Returns the device's software version (for instance, 'V1.01').
    ///
    /// @note This will sometimes differ from the user-visible software version the camera displays in its own UI.
    var version: String? { get }

    /// Returns the device's serial number.
    var serialNumber: String? { get }
}