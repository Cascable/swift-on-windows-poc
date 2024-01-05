import Foundation
import XCTest
import CascableCoreAPI
@testable import CascableCoreSimulatedCamera

class CameraTests: XCTestCase, CameraDiscoveryProviderDelegate {

    var gotCameraExpectation: XCTestExpectation? = nil
    var discoveredCamera: Camera? = nil

    func testCameraDiscovery() throws {
        let modelName = "Windows Camera"

        var config = SimulatedCameraConfiguration.default
        config.model = modelName
        config.connectionAuthentication = .none
        config.connectionSpeed = .instant
        config.apply()

        let discovery = SimulatedCameraDiscovery.shared
        discovery.delegate = self
        gotCameraExpectation = XCTestExpectation(description: "Discovered camera")
        discovery.startDiscovery(in: .networkAndUSB, clientName: "Windows Test Runner")
        wait(for: [gotCameraExpectation!], timeout: 1.0)
        let camera = try XCTUnwrap(discoveredCamera)
        XCTAssertEqual(camera.service.model, modelName)
    }

    /// Inform CascableCore that a new camera has been discovered.
    ///
    /// This method must be called on the main queue/thread.
    ///
    /// @param provider The provider that has discovered the new camera.
    /// @param camera The camera that has been discovered.
    func cameraDiscoveryProvider(_ provider: CameraDiscoveryProvider, didDiscover camera: Camera) {
        print(camera)
        discoveredCamera = camera
        gotCameraExpectation?.fulfill()
    }

    /// Inform CascableCore that a previously-visible camera is no longer available.
    ///
    /// This method must be called on the main queue/thread.
    ///
    /// @param provider The provider that has lost sight of the camera.
    /// @param camera The camera that is no longer available.
    func cameraDiscoveryProvider(_ provider: CameraDiscoveryProvider, didLoseSightOf camera: Camera) {

    }
}
