/// Possible camera transport values.
public enum CameraTransport: Int {
    /// The camera is communicating via a TCP/IP network, either using WiFi or Ethernet.
    case network = 0
    /// The camera is communicating via USB.
    case USB = 1
}

/// The block callback signature for an async operation that can fail with an error.
/// @param error The error that occurred, if any. If `nil`, the operation succeeded.
public typealias ErrorableOperationCallback = (Error?) -> Void

public typealias UniversalExposurePropertyValue = Any

public typealias PlatformImageType = Any

public typealias CameraFamily = Int

public protocol Camera: AnyObject {

}
