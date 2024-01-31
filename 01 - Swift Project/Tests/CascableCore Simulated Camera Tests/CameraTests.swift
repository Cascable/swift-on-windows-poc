import Foundation
import XCTest
import CascableCore
@testable import CascableCoreSimulatedCamera
@testable import CascableCoreBasicAPI

class CameraTests: XCTestCase, CameraDiscoveryProviderDelegate {

    var gotCameraExpectation: XCTestExpectation? = nil
    var discoveredCamera: Camera? = nil

    func testBasicCameraDiscovery() throws {
        BasicSimulatedCameraConfiguration.defaultConfiguration().apply()

        let basicDiscovery = BasicCameraDiscovery.sharedInstance()
        basicDiscovery.startDiscovery(clientName: "Windows Test Runner")

        let waitedABitExpectation = XCTestExpectation(description: "Waited for discovery")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            waitedABitExpectation.fulfill();
        }

        wait(for: [waitedABitExpectation], timeout: 5.0)

        let camera: BasicCamera = try XCTUnwrap(basicDiscovery.visibleCameras.first)
        print(camera.friendlyDisplayName)

        camera.connect();

        let waitedABitMoreExpectation = XCTestExpectation(description: "Waited for connection")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            waitedABitMoreExpectation.fulfill();
        }

        wait(for: [waitedABitMoreExpectation], timeout: 5.0)
        camera.beginLiveViewStream();

        let waitedForLiveView = XCTestExpectation(description: "Waited for connection")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            waitedForLiveView.fulfill();
        }

        wait(for: [waitedForLiveView], timeout: 5.0)
        XCTAssertNotNil(camera.lastLiveViewFrame)
    }

    func testCameraDiscoveryAndConnection() throws {
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

        let connectedToCameraExpectation = XCTestExpectation(description: "Connected to camera")
        camera.connect(authenticationRequestCallback: { context in
            XCTFail("Camera was configured for no auth, but we got an auth request!")
        }, authenticationResolvedCallback: {
            XCTFail("Camera was configured for no auth, but we got an auth resolution!")
        }, completionCallback: { error, warnings in
            XCTAssertNil(error)
            connectedToCameraExpectation.fulfill()
        })

        wait(for: [connectedToCameraExpectation], timeout: 1.0)
        XCTAssert(camera.connectionState == .connected)

        let exposureModeProperty = camera.property(with: .autoExposureMode)

        // Check we're in P and have the properties we'd expect.
        let exposureModeValue = try XCTUnwrap(exposureModeProperty.currentValue)
        XCTAssertEqual(exposureModeValue.commonValue, PropertyCommonValueAutoExposureMode.programAuto.rawValue)

        let populatedInPProperties = camera.populatedProperties(in: .exposureSetting)
        XCTAssertEqual(populatedInPProperties.count, 2)
        XCTAssert(populatedInPProperties.contains(where: { $0.identifier == .exposureCompensation }))
        XCTAssert(populatedInPProperties.contains(where: { $0.identifier == .isoSpeed }))

        // Switch to M and make sure we get the properties we'd expect.
        let manualValue = try XCTUnwrap(exposureModeProperty.validValue(matchingCommonValue: PropertyCommonValueAutoExposureMode.fullyManual.rawValue))
        let setManualExpectation = XCTestExpectation(description: "Setting M")

        exposureModeProperty.setValue(manualValue, completionHandler: { error in
            XCTAssertNil(error)
            setManualExpectation.fulfill()
        })

        wait(for: [setManualExpectation], timeout: 1.0)

        let populatedInMProperties = camera.populatedProperties(in: .exposureSetting)
        XCTAssertEqual(populatedInMProperties.count, 3)
        XCTAssert(populatedInMProperties.contains(where: { $0.identifier == .aperture }))
        XCTAssert(populatedInMProperties.contains(where: { $0.identifier == .shutterSpeed }))
        XCTAssert(populatedInMProperties.contains(where: { $0.identifier == .isoSpeed }))

        for identifier in camera.knownPropertyIdentifiers {
            let property = camera.property(with: identifier)
            let currentValue = property.currentValue
            print("Current value of \(property.localizedDisplayName ?? "??") is \(currentValue?.localizedDisplayValue ?? "nil")")
            if property.localizedDisplayName == "Unknown" {
                print(property.identifier)
            }
        }
    }

    /// Inform CascableCore that a new camera has been discovered.
    ///
    /// This method must be called on the main queue/thread.
    ///
    /// @param provider The provider that has discovered the new camera.
    /// @param camera The camera that has been discovered.
    func cameraDiscoveryProvider(_ provider: CameraDiscoveryProvider, didDiscover camera: Camera) {
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
