/// Implement the CBLCoreCameraDiscoveryProvider protocol in order to provide custom cameras and camera discovery
/// to CascableCore. You can then register your camera provider with CascableCore in the plugin entrypoint.
protocol CameraDiscoveryProvider: AnyObject {

/// Start the discovery process in the given mode. If the mode given doesn't apply to your situation (i.e., the mode
/// is `CBLCameraDiscoveryModeUSBOnly` and you only support network comms), you shouldn't do anything.
///
/// When searching, the `visibleCameras` property should be updated as cameras appear or disappear, after which
/// discovery messages should be delivered to the delegate, if present. Clients are encouraged to perform searches
/// in the background, but messages to the delegate must be performed on the main queue/thread.
///
/// @param discoveryMode The mode in which to perform the search.
/// @param clientName The client name to use when connecting/pairing to cameras.
func startDiscovery(in discoveryMode: CameraDiscoveryMode, clientName: String)

/// Stop discovery and clean up any resources used by the discovery process. May be called without a preceding
/// call to `-startDiscoveryInMode:clientName:`.
func stopDiscovery()

/// Returns an array of the currently visible cameras.
var visibleCameras: [Camera] { get }

/// CascableCore will set the delegate as appropriate. Messages delivered to this delegate should
/// be done so on the main thread/queue.
var delegate: CameraDiscoveryProviderDelegate? { get set }

/// Returns a unique identifier for the provider. Can be the plugin's bundle ID if it only has one provider.
var providerIdentifier: String { get }

}

/// Methods to deliver camera discovery changes to CascableCore.
protocol CameraDiscoveryProviderDelegate: AnyObject {

/// Inform CascableCore that a new camera has been discovered.
///
/// This method must be called on the main queue/thread.
///
/// @param provider The provider that has discovered the new camera.
/// @param camera The camera that has been discovered.
func cameraDiscoveryProvider(_ provider: CameraDiscoveryProvider, didDiscover camera: Camera)

/// Inform CascableCore that a previously-visible camera is no longer available.
///
/// This method must be called on the main queue/thread.
///
/// @param provider The provider that has lost sight of the camera.
/// @param camera The camera that is no longer available.
func cameraDiscoveryProvider(_ provider: CameraDiscoveryProvider, didLoseSightOf camera: Camera)

}