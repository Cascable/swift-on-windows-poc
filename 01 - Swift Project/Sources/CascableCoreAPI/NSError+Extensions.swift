import Foundation

/// The block callback signature for an async operation that can fail with an error.
/// @param error The error that occurred, if any. If `nil`, the operation succeeded.
public typealias ErrorableOperationCallback = (Error?) -> Void

/// CascableCore error domains.
public enum CascableCoreErrorCameraDomain: UInt {
    /// The error occurred with a generic PTP camera.
    case genericPTP
    /// The error occurred with a generic HTTP camera.
    case genericHTTP
    /// The error occurred with a Canon camera.
    case canon
    /// The error occurred with a Nikon camera.
    case nikon
    /// The error occurred with a Sony camera.
    case sony
    /// The error occurred with a Olympus camera.
    case olympus
    /// The error occurred with a Panasonic camera.
    case panasonic
    /// The error occurred with a Fujifilm.
    case fuji
}

/// CascableCore error codes.
public enum CascableCoreErrorCode: UInt {
    /// A generic, unknown error occurred.
    case generic = 1000
    /// No error.
    case noError
    /// The operation failed because the camera isn't connected. Can also be used as an error code if another operation
    /// fails due to the camera disconnecting (such as file streaming, live view, etc).
    case notConnected
    /// The operation failed because the device is busy. Typically, you can wait a moment and try again.
    case deviceBusy
    /// The operation was cancelled by the user. For instance, a pairing request can fail with this code if the user
    /// cancels pairing from the camera body.
    case cancelledByUser
    /// The operation failed because the given value is not valid for the property in its current state. If you're
    /// caching valid values, the camera may have changed state since the cache was made (for instance, you're trying
    /// to set a shutter speed but the camera is now in an automatic exposure mode).
    case invalidPropertyValue
    /// The operation failed because the camera's storage is write-protected.
    case writeProtected
    /// The operation failed because no thumbnail is available for the requested resource.
    case noThumbnail
    /// The operation failed because the camera does not support the requested operation.
    case notAvailable
    /// The operation failed because the camera isn't in a command category that supports the requested operation.
    /// For example, you're trying to take a photo while the camera doesn't currently allow stills shooting commands.
    case incorrectCommandCategory
    /// The focus operation failed, perhaps because the camera's autofocus is unable to being anything into focus.
    case autoFocusFailed
    /// The operation failed because of an underlying failure in the camera's protocol. This is often an indication of
    /// a larger problem (for example, the network dropped or the USB cable was disconnected halfway through an operation).
    case genericProtocolFailure
    /// The operation failed because of an invalid input parameter.
    case invalidInput
    /// The connection failed because the camera needs a firmware update to be controlled by CascableCore.
    case cameraNeedsSoftwareUpdate
    /// The operation failed because the camera did not respond within a sensible time period. Check network conditions.
    case timeout
    /// The focus drive operation failed because the lens was unable to move, either due to being at the end of its travel
    /// in the particular direction given, or due to a physical blockage.
    case focusDidNotMove
    /// The operation failed because the file isn't of a supported format.
    case unsupportedFileFormat
    /// The operation failed because metadata could not be retrieved for the requested file.
    case noMetadata
    /// The camera connection failed because it is paired with something else. A new pairing is required.
    case needsNewPairing
    /// The operation failed because the camera is currently recording video.
    case videoRecordingInProgress
    /// The operation failed because the camera can only perform the given action by having the user flip a switch
    /// or push a button on the camera directly.
    case requiresPhysicalInteraction
    /// The operation failed because the camera doesn't allow the operation over the current transport. For example
    /// older Canon cameras don't allow video recording over WiFi.
    case disallowedOnCurrentTransport
    /// The operation failed because it requires live view to be running. Start live view and try again.
    case requiresLiveView
    /// The operation failed because of a card error. Either the storage card is missing, damaged, or unformatted.
    case cardError
    /// The operation failed because the camera's storage is full.
    case storageFull
    /// The operation failed because the camera is in an incompatible communication mode. This error is usually
    /// encountered when a camera has multiple options on how to communicate over USB or the network, and the chosen
    /// mode is incompatible with CascableCore.
    case incorrectCommunicationMode
    /// The operation failed because the result would be too large for the given context. For example, trying to
    /// read an extremely large file into memory in its entirety.
    case objectTooLarge
    /// Couldn't connect to the camera because it requires an encrypted connection which isn't currently supported by CascableCore.
    case encryptedConnectionsNotSupported
    /// Couldn't connect to the camera because authentication failed (i.e., an incorrect password was given, etc).
    case connectionAuthenticationFailed
}

public extension CascableCoreErrorCode {

    var stringValue: String {
        switch (self) {
        case .generic: return "Generic"
        case .noError: return "No Error"
        case .notConnected: return "Not Connected"
        case .deviceBusy: return "Device Busy"
        case .cancelledByUser: return "Cancelled By User"
        case .invalidPropertyValue: return "Invalid Property Value"
        case .writeProtected: return "Write Protected"
        case .noThumbnail: return "No Thumbnail"
        case .notAvailable: return "Not Available"
        case .incorrectCommandCategory: return "Incorrect Command Category"
        case .autoFocusFailed: return "AutoFocus Failed"
        case .genericProtocolFailure: return "Generic Protocol Failure"
        case .invalidInput: return "Invalid Input"
        case .cameraNeedsSoftwareUpdate: return "Camera Needs Software Update"
        case .timeout: return "Timeout"
        case .focusDidNotMove: return "Focus did not move"
        case .noMetadata: return "No metadata available in image"
        case .unsupportedFileFormat: return "Unsupported file format for this operation"
        case .needsNewPairing: return "The connection failed because the camera is paired with another device or app"
        case .videoRecordingInProgress: return "Video recording in progress"
        case .requiresPhysicalInteraction: return "This operation requires a physical user interaction with the camera"
        case .disallowedOnCurrentTransport: return "This operation is not allowed via the current transport/connection method"
        case .requiresLiveView: return "This operation requires live view to be running"
        case .cardError: return "An error occurred accessing the camera's storage"
        case .storageFull: return "The camera's storage is full"
        case .incorrectCommunicationMode: return "The camera is in an incompatible communication mode"
        case .objectTooLarge: return "The object is too large for the current context."
        case .encryptedConnectionsNotSupported: return "Encrypted connections to this camera are not supported."
        case .connectionAuthenticationFailed: return "Authentication failed - check that the username/password or passcode is correct."
        }
    }
}

public let CascableCoreErrorDomain: String = "se.cascable"

public extension NSError {
    convenience init(cblErrorCode: CascableCoreErrorCode) {
        self.init(domain: CascableCoreErrorDomain, code: Int(cblErrorCode.rawValue), userInfo: [NSLocalizedDescriptionKey: cblErrorCode.stringValue])
    }
}