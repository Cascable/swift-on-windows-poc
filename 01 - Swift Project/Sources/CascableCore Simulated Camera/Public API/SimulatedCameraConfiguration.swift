//
//  SimulatedCameraConfiguration.swift
//  CascableCore Simulated Camera Plugin
//
//  Created by Daniel Kennett on 2023-11-24.
//  Copyright © 2023 Cascable AB. All rights reserved.
//

import Foundation

/// Configuration values for simulated cameras.
public struct SimulatedCameraConfiguration {
    
    /// The simulated camera's manufacturer name. The default value is `Cascable`.
    public var manufacturer: String
    
    /// The simulated camera's model name. The default value is `Simulated Camera`.
    public var model: String
    
    /// The simulated camera's identifier, which will be used for serial numbers, authentication identifiers, etc.
    /// The default value is the plugin's identifier (`se.cascable.CascableCore.plugin.simulated-camera`).
    public var identifier: String

    /// Which authentication type to perform when connecting to the simulated camera.
    /// The default value is `.pairOnCamera`.
    public var connectionAuthentication: SimulatedAuthentication

    /// The simulated connection speed. The default value is `.fast`.
    public var connectionSpeed: SimulatedConnectionSpeed
    
    /// Which transport(s) the simulated camera will be discovered on. The default value is `[.network, .USB]`.
    public var connectionTransports: Set<CameraTransport>
    
    /// How simulated exposure properties (aperture, shutter speed, ISO, etc) are set. Defaults to `.enumerated`.
    public var exposurePropertyType: SimulatedPropertySetType

    /// An array of local file URLs to JPEG images to be used as the live view stream. These images will be loaded
    /// upon live view start and delivered in a loop at approximately 30fps. The images must all be the same size and
    /// around 720p (or the 3:2 or 4:3 equivalent) or so to be accurate. Setting an array of one item is valid for a
    /// static image. Setting an empty array or including non-JPEG images will cause the simulated live view stream to
    /// fail.
    public var liveViewImageFrames: [URL]

    /// The local filesystem URL to expose as a storage device on the simulated camera. When set to an accessible
    /// directory, the simulated camera will use that directory's contents to populate the camera's storage device.
    /// For best results, it should simulate a real layout (`/DCIM/100CAMERA/etc`). The default value is `nil`.
    public var storageFileSystemRoot: URL?

    /// How the simulated camera grants filesystem access. Defaults to `.alongsideRemoteShooting`.
    public var fileSystemAccess: SimulatedFileSystemAccess

    /// Apply the settings for newly-discovered simulated cameras. Changes won't be applied to simulated cameras
    /// that have already been discovered or connected to (i.e., you should apply your configuration before starting
    /// camera discovery).
    public func apply() {
        SimulatedCameraDiscovery.shared.applyConfiguration(self)
    }
}

public extension SimulatedCameraConfiguration {

    /// Returns the default simulated camera configuration. Use this as the base for customisation.
    static var `default`: SimulatedCameraConfiguration {
        let bundle = Bundle(for: SimulatedCamera.self)
        let imageUrls: [URL] = (bundle.urls(forResourcesWithExtension: "jpg", subdirectory: "Live View Images") ?? [])
            .map({ $0 as URL })
            .sorted(by: { $0.lastPathComponent < $1.lastPathComponent })

        return SimulatedCameraConfiguration(manufacturer: "Cascable",
                                            model: "Simulated Camera",
                                            identifier: SimulatedCameraPluginIdentifier,
                                            connectionAuthentication: .pairOnCamera,
                                            connectionSpeed: .fast,
                                            connectionTransports: [.network, .USB],
                                            exposurePropertyType: .enumerated,
                                            liveViewImageFrames: imageUrls,
                                            storageFileSystemRoot: nil,
                                            fileSystemAccess: .alongsideRemoteShooting)
    }
}

// MARK: - Simulated Connection Speed

/// A simulated camera connection speed.
public struct SimulatedConnectionSpeed {

    /// Simulates a camera connected via a slow WiFi network.
    public static let slow = SimulatedConnectionSpeed(small: 1.0 / 10.0, medium: 1.0 / 5.0, large: 1.0 / 2.0)

    /// Simulates a camera connected via USB or a fast network connection.
    public static let fast = SimulatedConnectionSpeed(small: 1.0 / 25.0, medium: 1.0 / 15.0, large: 1.0 / 10.0)
    
    /// Simulates a camera that performs all operations instantly. Not realistic, but can be useful for UI tests and etc.
    public static let instant = SimulatedConnectionSpeed(small: 0.0, medium: 0.0, large: 0.0)

    /// The time it takes to execute a small operation (payloads measured in bytes).
    internal let smallOperationDuration: TimeInterval

    /// The time it takes to execute a medium operation (payloads measured in kilobytes).
    internal let mediumOperationDuration: TimeInterval

    /// The time it takes to execute a large operation (payloads measured in megabytes).
    internal let largeOperationDuration: TimeInterval
}

internal extension SimulatedConnectionSpeed {
    init(small: TimeInterval, medium: TimeInterval, large: TimeInterval) {
        self.smallOperationDuration = small
        self.mediumOperationDuration = medium
        self.largeOperationDuration = large
    }
}

// MARK: - Simulated Camera Authentication

/// Defines how a simulated camera authenticates its connection.
public enum SimulatedAuthentication {
    /// No authentication is required.
    case none
    /// Authentication is performed via pushing a "confirm" button on the camera. The camera will simulate
    /// this happening a few seconds after an authentication request callback if the request isn't cancelled.
    case pairOnCamera
    /// Authentication is performed via a username and password.
    case userNameAndPassword(String, String)
    /// Authentication is performed via a four-digit numeric code.
    case fourDigitCode(String)
}

// MARK: - Simulated Camera Property Types

/// Defines how simulated properties are set. See the documentation for `PropertyValueSetType` in the CascableCore
/// documentation for more details.
public enum SimulatedPropertySetType {
    /// Values are set directly by setting a new value from a list of valid values.
    case enumerated
    /// Values are set by stepping up or down through a list.
    case stepped
}

// MARK: - Simulated Camera Filesystem Access Types

/// Defines how the simulated camera grants access to the file system. See the documentation for
/// `AvailableCommandCategory` in the CascableCore documentation for more details.
public enum SimulatedFileSystemAccess {
    /// The simulated camera allows access to its file system alongside stills/video shooting. This matches how
    /// Canon EOS and Nikon cameras operate.
    case alongsideRemoteShooting
    /// The simulated camera doesn't allow access to its file system alongside stills/video shooting - it must be
    /// switched over to "filesystem mode". This matches how Fuji, Olympus, Panasonic, Sony, etc cameras operate.
    case exclusivelyOfRemoteShooting
}
