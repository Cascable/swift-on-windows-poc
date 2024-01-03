import Foundation

/// Possible camera transport values.
public enum CameraTransport: Int {
    /// The camera is communicating via a TCP/IP network, either using WiFi or Ethernet.
    case network = 0
    /// The camera is communicating via USB.
    case USB = 1
}

/// The discovery service's delegate protocol. Typically, this should not be interfered with.
public protocol CameraDiscoveryServiceDelegate: AnyObject {

    /// Called when the service thinks it should be removed from any list of available devices.
    ///
    /// @param service The service the sent the message.
    func serviceShouldBeForciblyRemoved(_ service: CameraDiscoveryService)
}

/// The block callback signature when a service has completed or failed resolving.
///
/// @param service The service that completed or failed resolving.
/// @param error If the operation failed, an error object describing the operation.
public typealias CameraDiscoveryServiceResolveCallback = (_ service: CameraDiscoveryService, _ error: Error?) -> Void

/// The block callback signature when a service has completed or failed resolving metadata.
///
/// @param service The service that completed or failed resolving.
/// @param error If the operation failed, an error object describing the operation.
public typealias CameraDiscoveryMetadataResolveCallback = (_ service: CameraDiscoveryService, _ error: Error?) -> Void

/// A camera discovery service represents a camera that has been found on the network, but has not been connected to. A meta-camera, if you will.
public protocol CameraDiscoveryService {

    /// ------- Service Resolving

    /// Attempt to resolve the service enough to be able to connect to the camera.
    ///
    /// @param block The block to be called when resolution fails or succeeds.
    /// @param blockQueue The queue on which to trigger the callback block.
    func resolveService(_ completionHandler: CameraDiscoveryServiceResolveCallback, queue: DispatchQueue)

    /// Attempt to resolve the service enough to be able to query camera metadata.
    ///
    /// @param block The block to be called when resolution fails or succeeds.
    /// @param blockQueue The queue on which to trigger the callback block.
    func resolveMetadata(_ completionHandler: CameraDiscoveryMetadataResolveCallback, queue: DispatchQueue)

    /// Inform the service that it should be forcibly removed from available device lists.
    func forceRemoval()

    /// Returns `true` if the service has been resolved enough to attempt a connection to the camera, otherwise `false`.
    var serviceHasBeenResolved: Bool { get }

    /// Returns `true` if the service has been resolved enough for metadata such as model name to be available, otherwise `false`.
    var metadataHasBeenResolved: Bool { get }

    /// Returns the service's transport.
    var transport: CameraTransport { get }

    /// ------- Properties

    /// The service's delegate.
    var delegate: CameraDiscoveryServiceDelegate? { get set }

    /// Returns the client name used when connecting to the camera.
    var clientName: String { get }

    /// Returns the service's camera model name, if available.
    var model: String? { get }

    ///  Returns the service's camera manufacturer, if available.
    var manufacturer: String? { get }

    ///  Returns a unique identifier for the service's camera, if available.
    var cameraId: String? { get }

    ///  Returns the service's camera serial number, if available.
    var serialNumber: String? { get }

    /// Returns the IPv4 address of the service, if available.
    var ipv4Address: String? { get }

    /// Returns the service's dynamic host name, if available.
    var hostName: String? { get }

    /// Returns the port on which the service can be connected to, or `0` if not available.
    var port: Int { get }
}
