
/// Options for discovering cameras.
public enum CameraDiscoveryMode: Int {
    /// Only search for cameras on the network.
    case networkOnly = 0
    /// Only search for cameras via USB.
    case usbOnly = 1
    /// Search for cameras both on the network and via USB.
    case networkAndUSB = 2
}
