//
//  SimulatedCameraDiscovery.swift
//  CascableCore Simulated Camera Plugin
//
//  Created by Daniel Kennett on 2023-11-24.
//  Copyright © 2023 Cascable AB. All rights reserved.
//

import Foundation

internal class SimulatedCameraDiscovery: CameraDiscoveryProvider, SimulatedCameraDelegate {

    static let shared = SimulatedCameraDiscovery()

    // MARK: - Public API

    weak var delegate: CameraDiscoveryProviderDelegate? = nil

    var providerIdentifier: String {
        return SimulatedCameraPluginIdentifier
    }

    var visibleCameras: [Camera] {
        if let camera = currentSimulatedCamera { return [camera] }
        return []
    }

    func startDiscovery(in discoveryMode: CameraDiscoveryMode, clientName: String) {
        isDiscovering = true
        let configuration = self.configuration
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            guard self.isDiscovering else { return }

            let canBeDiscovered: Bool = {
                let transports = configuration.connectionTransports
                switch discoveryMode {
                case .networkOnly: return transports.contains(.network)
                case .usbOnly: return transports.contains(.USB)
                case .networkAndUSB: return true
                }
            }()

            guard canBeDiscovered else { return }

            let simulatedTransport: CameraTransport = {
                switch discoveryMode {
                case .networkOnly: return .network
                case .usbOnly: return .USB
                case .networkAndUSB: return .network
                }
            }()

            let camera = SimulatedCamera(configuration: configuration, clientName: clientName, transport: simulatedTransport)
            camera.simulatedCameraDelegate = self
            self.currentSimulatedCamera = camera
        }
    }

    func stopDiscovery() {
        isDiscovering = false
        currentSimulatedCamera = nil
    }

    // MARK: - Internal API

    private var configuration: SimulatedCameraConfiguration = .default

    internal func applyConfiguration(_ config: SimulatedCameraConfiguration) {
        configuration = config
    }

    private var isDiscovering: Bool = false

    func simulatedCameraDidDisconnect(_ camera: SimulatedCamera) {
        currentSimulatedCamera = nil
    }

    private var currentSimulatedCamera: SimulatedCamera? {
        didSet {
            if let camera = currentSimulatedCamera {
                delegate?.cameraDiscoveryProvider(self, didDiscover: camera)
            } else if let oldCamera = oldValue {
                delegate?.cameraDiscoveryProvider(self, didLoseSightOf: oldCamera)
            }
        }
    }
}
