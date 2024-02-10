import Foundation
import CascableCore
import CascableCoreSimulatedCamera

// This class is here because:
//
// - Xcode gets very upset about using this overarching project's Swift package since it contains
//   both unsafe flags and explicit .dynamic flags, so we need to use the production CascableCore
//   and Simulated Camera, and:
//
// - The production CascableCore is a commercial SDK with a licensing requirement. Since we don't want
//   to require a commercial license just to use this demo project, we're bypassing CascableCore
//   and implementing the CascableCore plugin API directly. This lets us load the simulated camera
//   (which doesn't require a commercial license) without having to license the main SDK.

@Observable
class BasicCameraDiscovery: NSObject, PluginRegistration, CameraDiscoveryProviderDelegate {

    static let shared: BasicCameraDiscovery = .init()

    override private init() {
        super.init()
        SimulatedCameraEntryPoint().register(with: self)
    }

    // MARK: - API

    /// Returns `true` if camera discovery is running, otherwise `false`.
    public private(set) var discoveryRunning: Bool = false

    /// Returns an array of visible cameras.
    public private(set) var visibleCameras: [Camera] = []

    /// Start camera discovery.
    ///
    /// - Parameter clientName: The client (i.e., app) name. Will be displayed on some cameras during pairing.
    public func startDiscovery(clientName: String) {
        guard !discoveryRunning else { return }
        discoveryRunning = true

        // Let's simulate a real camera model name.
        var config = SimulatedCameraConfiguration.default
        config.manufacturer = "Canon"
        config.model = "EOS R5"
        config.connectionAuthentication = .none
        config.apply()

        for provider in discoveryProviders {
            provider.startDiscovery(in: .networkAndUSB, clientName: clientName)
        }
    }

    /// Stop camera discovery. This is recommended once you have a camera to connect to in order to save system
    /// resources/battery life.
    public func stopDiscovery() {
        guard discoveryRunning else { return }
        discoveryRunning = false
        for provider in discoveryProviders { provider.stopDiscovery() }
    }

    // MARK: - Plugin Interop

    private var discoveryProviders: [CameraDiscoveryProvider] = []

    func register(discoveryProvider: CameraDiscoveryProvider) {
        discoveryProvider.delegate = self
        discoveryProviders.append(discoveryProvider)
    }

    func register(manualDiscoveryProvider: CameraManualDiscoveryProvider) {
        // We don't need this here.
    }

    func cameraDiscoveryProvider(_ provider: CameraDiscoveryProvider, didDiscover camera: Camera) {
        visibleCameras.append(camera)
    }

    func cameraDiscoveryProvider(_ provider: CameraDiscoveryProvider, didLoseSightOf camera: Camera) {
        visibleCameras.removeAll(where: { $0.isEqual(camera) })
    }
}
