import Foundation

/// The block callback signature for an async operation that can fail with an error.
/// @param error The error that occurred, if any. If `nil`, the operation succeeded.
public typealias ErrorableOperationCallback = (Error?) -> Void

public typealias UniversalExposurePropertyValue = Any

public typealias PlatformImageType = Any

public typealias CameraFamily = Int


// ---

/// Methods of authenticating with a camera.
public enum CameraAuthenticationType: Int {
    /// The user must authenticate by interacting with the camera itself.
    case interactWithCamera
    /// The user must authenticate by entering a username and password.
    case usernameAndPassword
    /// The user must authenticate by entering a four-digit numeric code.
    case fourDigitNumericCode
}

/// A camera authentication context represents a request for authentication from the camera. Responses are
/// submitted via this context object.
public protocol CameraAuthenticationContext {

    /// The type of authentication the camera is requesting.
    var type: CameraAuthenticationType { get }

    /// Returns `YES` if this authentication context is being delivered immediately after a previous authentication
    /// submission was rejected. This allows (for example) to re-ask for a username/password, particularly if the previous
    /// submission was from saved credentials.
    var previousSubmissionRejected: Bool { get }


    /// A unique, stable identifier for the camera, appropriate for using as a key for storing credentials in
    /// (for e.g.) the Keychain.
    ///
    /// CascableCore will do its best to make this identifier unique on a per-camera basis when the `type` property is
    /// set to a value other than `CBLCameraAuthenticationTypeInteractWithCamera`. Since no credentials need to be stored
    /// for such a context, this identifier isn't needed.
    var authenticationIdentifier: String { get }

    /// Submit a cancellation for camera authentication. This will disconnect from the camera and deliver a
    /// `CBLErrorCodeCancelledByUser` error to the connection completion handler. Valid for all authentication types.
    func submitCancellation()

    /// Submit a username and password for camera authentication. Only valid if `type` is `CBLCameraAuthenticationTypeUsernameAndPassword`.
    ///
    /// @param userName The supplied username.
    /// @param password The supplied password.
    func submitUserName(_ userName: String, password: String)

    /// Submit a numeric passcode for camera authentication. Only valid if `type` is `CBLCameraAuthenticationTypeFourDigitNumericCode`.
    ///
    /// @param code The supplied code.
    func submitNumericCode(_ code: String)
}

/// The block callback signature when the camera requests authentication.
///
/// @param context The authentication context object for inspecting the request and delivering a response.
public typealias CameraAuthenticationRequestBlock = (_ context: CameraAuthenticationContext) -> Void

/// The block callback signature when a camera's authentication request has been resolved and authentication UI can be hidden.
public typealias CameraAuthenticationResolvedBlock = () -> Void

/// The block callback signature when camera connection completes or fails.
///
/// @param error The error that occurred, if any.
/// @param warnings Any non-fatal connection warnings.
public typealias ConnectionCompleteCallback = (_ error: Error?, _ warnings: [ConnectionWarning]?) -> Void

/// The block callback signature when a camera has a new camera-initiated transfer request. See `CBLCameraInitiatedTransferRequest`
/// for details.
public typealias CameraInitiatedTransferRequestHandler = (_ request: CameraInitiatedTransferRequest) -> Void

/// Which advanced features are supported.
public struct SupportedFunctionality: OptionSet {
    public let rawValue: UInt

    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }

    /// The camera supports rendering individual AF points.
    public static let afPoints = SupportedFunctionality(rawValue: 1 << 0)
    /// The camera supports expressing its current orientation through live view.
    public static let liveViewOrientation = SupportedFunctionality(rawValue: 1 << 4)
    /// The camera supports remote control when live view is not active.
    public static let remoteControlWithoutLiveView = SupportedFunctionality(rawValue: 1 << 5)
    /// The camera supports deleting files from its storage.
    public static let fileDeletion = SupportedFunctionality(rawValue: 1 << 6)
    /// The camera supports engaging Depth of Field (DoF) preview.
    public static let depthOfFieldPreview = SupportedFunctionality(rawValue: 1 << 7)
    /// The camera supports "half pressing" the shutter to engage autofocus independently of taking a shot.
    public static let shutterHalfPress = SupportedFunctionality(rawValue: 1 << 8)
    /// The camera supports updating its date/time.
    public static let updateClock = SupportedFunctionality(rawValue: 1 << 9)
    /// The camera supports zooming in to its live view image.
    @available(*, deprecated, message: "Use the CBLPropertyIdentifierLiveViewZoomLevel property instead.")
    public static let zoomableLiveView = SupportedFunctionality(rawValue: 1 << 10)
    /// The camera supports basic remote control when live view is not active.
    public static let limitedRemoteControlWithoutLiveView = SupportedFunctionality(rawValue: 1 << 11)
    /// The camera supports directly controlling the focus motor to move the focus distance.
    public static let directFocusManipulation = SupportedFunctionality(rawValue: 1 << 12)
    /// The camera supports powering off when disconnecting.
    public static let powerOffOnDisconnect = SupportedFunctionality(rawValue: 1 << 13)
    /// The camera supports exposure control through aperture, shutter speed, ISO, and exposure compensation.
    public static let exposureControl = SupportedFunctionality(rawValue: 1 << 14)
    /// The camera supports camera-initiated transfer callbacks.
    public static let cameraInitiatedTransfer = SupportedFunctionality(rawValue: 1 << 15)
    /// The camera supports zooming live view via crop rectangles.
    public static let croppableLiveView = SupportedFunctionality(rawValue: 1 << 16)
    /// The camera supports video recording.
    public static let videoRecording = SupportedFunctionality(rawValue: 1 << 17)
    /// The camera supports panning live view around while zoomed in.
    public static let pannableLiveView = SupportedFunctionality(rawValue: 1 << 18)
}

/// Camera connection states.
public enum ConnectionState: UInt {
    /// The camera is not connected.
    case notConnected = 0
    /// The camera is in the process of connecting.
    case connectionInProgress
    /// The camera is connected, and commands can be issued to it.
    case connected
    /// The camera is in the process of disconnecting.
    case disconnectionInProgress
}

/// Bitfield values for camera command categories. Cameras can have zero, one, or multiple available command categories at the same time.
public struct AvailableCommandCategory: OptionSet {
    public let rawValue: UInt

    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }

    /// If this value is present in the options, the camera can perform stills shooting operations.
    public static let stillsShooting = AvailableCommandCategory(rawValue: 1 << 0)
    /// If this value is present in the options, the camera can perform filesystem actions.
    public static let filesystemAccess = AvailableCommandCategory(rawValue: 1 << 1)
    /// If this value is present in the options, the camera can perform video recording operations.
    public static let videoRecording = AvailableCommandCategory(rawValue: 1 << 2)
}

/// Non-fatal warning types that can occur during connection.
public enum ConnectionWarningType: UInt {
    /// The camera has lower than expected functionality. Use the `supportedFunctionality` methods to check.
    case lowerThanExpectedFunctionality
    /// The camera supports clock sync, but attempting to do so during connection failed.
    case clockSyncFailed
    /// The camera doesn't support clock sync.
    case clockSyncNotSupported
    /// The connection succeeded, but more features will be available if the camera's firmware is updated.
    case firmwareUpdateRecommended
}

/// Non-fatal warning categories that can occur during connection.
public enum ConnectionWarningCategory: UInt {
    /// The warning is in the 'remote control' category, affecting shooting functionality.
    case remoteControl
    /// The warning is in the 'filesystem' category, affecting access to the camera's internal storage.
    case filesystemAccess
    /// The warning is in the 'misc' category, affecting minor features.
    case misc
}

/// An observer token. Required to unregister an oberver.
public typealias ObserverToken = String

/// A non-fatal connection warning.
public protocol ConnectionWarning {

    /// The type of the warning.
    var type: ConnectionWarningType { get }

    /// The category of the warning.
    var category: ConnectionWarningCategory { get }
}

/// Sync the camera's clock to the current system clock, if supported by the camera.
public let CBLConnectionFlagSyncCameraClockToSystemClock: String = "CBLConnectionFlagSyncCameraClockToSystemClock"

/// Powers off the camera during disconnect, if supported by the camera. Requires `CBLCameraSupportedFunctionalityPowerOffOnDisconnect`.
public let CBLDisconnectionFlagPowerOffCamera: String = "CBLDisconnectionFlagPowerOffCamera"

/// The catch-all protocol for a camera object in CascableCore. Functionality is broken down into sub-protocols:
///
/// - `CameraCore` for core functionality, such as connection/disconnection, supported functionality, etc.
/// - `CameraLiveView` for operations involving live view streaming.
/// - `CameraFocusAndShutter` for operations involving shooting images.
/// - `CameraProperties` for operations involving getting and setting camera settings/properties.
/// - `CameraFileSystem` for operations involving accessing the camera's file system.
/// - `CameraVideoRecording` for operations involving video recording.
public protocol Camera: AnyObject {

}

/// Camera connection, disconnection and status methods.
public protocol CameraCore {

    /// Returns the camera's "friendly" identifier, typically the serial number.
    var friendlyIdentifier: String? { get }

    /// Returns `YES` if the instance is connected to a physical camera, otherwise `NO`.
    ///
    /// The `connectionState` property returns more fine-grained detail about the camera's state.
    /// The value of this property is equivalent to `(connectionState == CBLCameraConnectionStateConnected)`.
    var connected: Bool { get }

    /// Returns an object representing information about the device. Will be `nil` if not connected.
    var deviceInfo: DeviceInfo? { get }

    /// Returns the `CBLCameraDiscoveryService` used to connect this camera.
    // @property (nonatomic, readonly, strong, nonnull) id <CBLCameraDiscoveryService> service;
    var service: CameraDiscoveryService { get }

    /// Returns the `CBLCameraFamily` for this camera.
    var cameraFamily: CameraFamily { get }

    /// Returns the `CBLCameraTransport` for this camera.
    var cameraTransport: CameraTransport { get }

    /// Returns the friendly, user-set name of the camera, if available. May be `nil` until the camera is connected.
    var friendlyDisplayName: String? { get }

    /// Returns the connection state of the camera.
    var connectionState: ConnectionState { get }

    /// Returns `YES` if the disconnection that just happens was expected or not.
    ///
    /// This property is only valid inside a triggered observation of the `connectionState` property
    /// or within the callback block of `disconnectFromDevice:callbackQueue:`.
    var disconnectionWasExpected: Bool { get }

    /// Returns any warnings that occurred during connection to the camera.
    var connectionWarnings: [ConnectionWarning]? { get }

    /// Attempt to connect to the device with the given flags.
    ///
    /// The passed block is called when a session is established or if the connection or session
    /// setup failed. If the `error` parameter of the callback is `nil`, connection and session setup was
    /// successful.
    ///
    /// In some cases, the connection will complete successfully enough to be useable, but with
    /// some warnings. A notable example is when connecting to a very new model of camera,
    /// some advanced functionality may not be available yet. If there are warnings, these will
    /// contained in the `warnings` parameter of the callback block. These warnings should be
    /// presented to the user *if* they fall in a category your application uses.
    ///
    /// In some circumstances, the connection process is stalled by the camera requiring authentication. If this happens,
    /// the `authenticationRequestCallback` will be called with information on the request. You should display UI to the
    /// user on how to satisy the request, which will vary depending on the type of authentication request (see the
    /// documentation for `id <CBLCameraAuthenticationContext>` for more details.
    ///
    /// Once the authentication request has been satisfied, the `authenticationResolvedCallback` will be called, signalling
    /// that the request has been satisifed and you can close your UI.
    ///
    /// @note If you get a `authenticationRequestCallback`, you will always get a `authenticationResolvedCallback` before
    ///       camera connection completes. **Importantly**, you may get more than one sequence of authentication
    ///       requests/resolves during a connection - for example, if the camera rejects the given username and password, it
    ///       may grant another try before failing.
    ///
    /// @note The callback blocks will be called on the main queue.
    ///
    /// @param flags The connection flags for this session. Can be `nil`.
    /// @param authenticationRequestCallback The callback to be invoked when a camera needs user authentication.
    /// @param authenticationResolvedCallback The callback to be invoked when a camera's authentication request has been resolved.
    /// @param callback The callback to be called when the connection succeeds or fails.
    func connect(flags: [String: Any]?,
                authenticationRequestCallback: CameraAuthenticationRequestBlock,
                authenticationResolvedCallback: CameraAuthenticationResolvedBlock,
                completionCallback: ConnectionCompleteCallback)

    /// Attempt to connect to the device with the given client name.
    ///
    /// Equivalent to calling `-connectWithFlags:authenticationRequestCallback:authenticationResolvedCallback:completionCallback:`
    /// with a `nil` `flags` parameter.
    ///
    /// See the documentation for `-connectWithFlags:authenticationRequestCallback:authenticationResolvedCallback:completionCallback:`
    /// for details.
    ///
    /// @param authenticationRequestCallback The callback to be invoked when a camera needs user authentication.
    /// @param authenticationResolvedCallback The callback to be invoked when a camera's authentication request has been resolved.
    /// @param callback The callback to be called when the connection succeeds or fails.
    func connect(authenticationRequestCallback: CameraAuthenticationRequestBlock,
                authenticationResolvedCallback: CameraAuthenticationResolvedBlock,
                completionCallback: ConnectionCompleteCallback)

    /// Attempt to disconnect from the device.
    ///
    /// The passed block is called when the session is ended and connections have been
    /// terminated. If the `error` parameter of the callback is `nil`, disconnection was successful.
    ///
    /// @param flags The disconnection flags.
    /// @param callback The callback to be called when disconnection succeeds or fails.
    /// @param queue The queue on which to trigger the callback.
    func disconnect(flags: [String: Any]?, completionCallback: ErrorableOperationCallback?, callbackQueue: DispatchQueue?)

    /// Attempt to disconnect from the device.
    ///
    /// The passed block is called when the session is ended and connections have been
    /// terminated. If the `error` parameter of the callback is `nil`, disconnection was successful.
    ///
    /// Equivalent to calling disconnectWithFlags:completionCallback:callbackQueue: with a `nil` `flags` parameter.
    ///
    /// @param callback The callback to be called when disconnection succeeds or fails.
    /// @param queue The queue on which to trigger the callback.
    func disconnect(completionCallback: ErrorableOperationCallback?, callbackQueue: DispatchQueue?)

    // -------------
    // @name Querying Available Functionality
    // -------------

    /// Returns a bitmask of the supported advanced functionality of this camera.
    var supportedFunctionality: SupportedFunctionality { get }

    /// Returns `YES` if the camera supports the given functionality, otherwise `NO`.
    ///
    /// @param functionality The functionality to test for.
    func supportsFunctionality(_ functionality: SupportedFunctionality) -> Bool

    /// Returns a bitmask of the current available command categories.
    var currentCommandCategories: AvailableCommandCategory { get }

    /// Returns `YES` if the camera currently supports the given category, otherwise `NO`.
    ///
    /// @param category The category to test for.
    func currentCommandCategoriesContainsCategory(_ category: AvailableCommandCategory) -> Bool

    /// Returns `YES` if the camera is able to switch to the given category combination, otherwise `NO`.
    ///
    /// @param categories The command category combination to check if the camera supports.
    func supportsCommandCategories(_ categories: AvailableCommandCategory) -> Bool

    /// Attempt to switch the camera into a mode that supports the given category combination.
    ///
    /// It is not guaranteed that the camera's current command categories will end up exactly the same as what's passed
    /// in, but if the method succeeds you can expect that they will contain the requested category/categories.
    ///
    /// For example, some cameras support both stills shooting and filesystem access at the same time. Requesting the
    /// command category `.stillsShooting` will succeed, but the camera will end up with current command categories of
    /// `[.stillsShooting, .filesystemAccess]`.
    ///
    /// In general, it's safe to call this method with a single category (for example, if you want to shoot video,
    /// `.videoRecording`) — CascableCore will put the camera into the closest sensible mode that supports that category.
    ///
    /// To check if the camera supports your desired command category/categories, use `-supportsCommandCategories:`.
    ///
    /// @param categories The command categories the camera should accept.
    /// @param block The block to be called when the camera has switched modes and is able to accept commands in the given categories, or an error occurs.
    func setCurrentCommandCategories(_ categories: AvailableCommandCategory, completionCallback: ErrorableOperationCallback)
}

// MARK: - Live View

/// Reasons the live view stream can stop.
public enum LiveViewTerminationReason: Int {
    /// The stream ended normally, due to mode switching or an explicit call to `endLiveViewStream`.
    case endedNormally
    /// The stream could not start because there is already a stream running from this camera.
    case alreadyStreaming
    /// The stream failed, due to disconnection or another failure.
    case failed
}

/// The live view frame delivery callback.
///
/// @param frame A live view frame from the camera.
/// @param completionHandler A completion handler to inform the camera that you're ready for the next frame. This MUST be called, and can be called from any thread.
public typealias LiveViewFrameDelivery = (_ frame: LiveViewFrame, _ completionHandler: () -> Void) -> Void

/// The handler for the live view stream ending.
///
/// @param reason The reason the live view stream ended.
/// @param error The error that caused the failure, if `reason` is `CBLCameraLiveViewTerminationReasonFailed`.
public typealias LiveViewTerminationHandler = (_ reason: LiveViewTerminationReason, _ error: Error?) -> Void

/// If set to `@YES`, image data will not be decoded in delivered live view frames, so the `image` property of delivered
/// frames will be `nil`. All other properties will be populated as normal, including `rawImageData`. This can be useful if
/// you have a frame rendering pipeline that doesn't need `NSImage`/`UIImage` objects, as turning off image decoding can
/// save a significant amount of CPU resources.
///
/// When omitted from the options dictionary, the assumed value for this option is `@NO`.
public let CBLLiveViewOptionSkipImageDecoding: String = "CBLLiveViewOptionSkipImageDecoding"

/// If set to `@YES` and if supported by the particular camera model you're connected to, live view will be configured
/// to favour lower-quality image data in an attempt to achieve a higher live view frame rate. If set to `@NO` (or omitted),
/// live view will be configured to favour the highest quality image.
///
/// Setting this option after live view has started (with `-applyLiveViewStreamOptions:`) has no effect.
///
/// When omitted from the options dictionary, the assumed value for this option is `@NO`.
public let CBLLiveViewOptionFavorHighFrameRate: String = "CBLLiveViewOptionFavorHighFrameRate"

/// Camera live view methods.
public protocol CameraLiveView {

    /// Start streaming the live view image from the camera.
    ///
    /// @note The frame delivery block has a completion handler, which MUST be called in order to receive the next frame. The completion handler
    /// can be called from any thread, and should be called when you're ready for the next frame. This allows frame delivery to correctly throttle
    /// without backing up frames if your image processing/display is slower than the delivery rate from the camera.
    ///
    /// @param delivery The frame delivery block.
    /// @param deliveryQueue The queue on which to deliver frames. If you pass `nil`, the main queue will be used.
    /// @param terminationHandler The callback to call when the live view stream ends. Will be called on the main queue.
    func beginLiveViewStreamWithDelivery(_ delivery: LiveViewFrameDelivery,
                                        deliveryQueue: DispatchQueue?,
                                        terminationHandler: LiveViewTerminationHandler)

    /// Start streaming the live view image from the camera with the given options.
    ///
    /// @note The frame delivery block has a completion handler, which MUST be called in order to receive the next frame. The completion handler
    /// can be called from any thread, and should be called when you're ready for the next frame. This allows frame delivery to correctly throttle
    /// without backing up frames if your image processing/display is slower than the delivery rate from the camera.
    ///
    /// @param delivery The frame delivery block.
    /// @param deliveryQueue The queue on which to deliver frames. If you pass `nil`, the main queue will be used.
    /// @param options Custom options for the live view session. See `CBLLiveViewOption…` constants for details.
    /// @param terminationHandler The callback to call when the live view stream ends. Will be called on the main queue.
    func beginLiveViewStreamWithDelivery(_ delivery: LiveViewFrameDelivery,
                                        deliveryQueue: DispatchQueue?,
                                        options: [String: Any]?,
                                        terminationHandler: LiveViewTerminationHandler)

    /// Apply new options to the running stream live view stream. Options not included in the passed dictionary will not be changed.
    ///
    /// Due to the threaded nature of live view streaming, a number of frames may be delivered between calling this method and
    /// the new options taking effect.
    ///
    /// @note If no live view stream is running, this method has no effect.
    ///
    /// @param options The options to apply to the running live view stream.
    func applyLiveViewStreamOptions(_ options: [String: Any])

    /// Ends the current live view stream, if one is running. Will cause the stream's termination handler to be called with `CBLCameraLiveViewTerminationReasonEndedNormally`.
    func endLiveViewStream()

    /// Returns `YES` if the camera is currently streaming a live view image.
    var liveViewStreamActive: Bool { get }

    /// Attempt to zoom in to live view by cropping in on the camera's side.
    ///
    /// The given crop rectangle must match the aspect ratio of the live view frame's `aspect`, must be completely contained
    /// within it, and must be larger or equal in size to the live view frame's `minimumCropSize`. The rect may be adjusted
    /// by CascableCore to match the camera's requirements. To check the final cropped frame, see live view frame's
    /// `imageFrameInAspect` property once the operation completes.
    ///
    /// Note that it may take a few frames for crop geometry to update after this operation finishes, due to frame buffers and etc.
    ///
    /// If the camera doesn't support the functionality `CBLCameraSupportedFunctionalityCroppableLiveView`, this operation will fail.
    ///
    /// @param cropRect The rectangle at which to crop live view, relative to a live view frame's `aspect`.
    /// @param block The callback to call when the operation is complete.
    func setLiveViewCrop(_ cropRect: CGRect, completionCallback: ErrorableOperationCallback?)

    /// Attempt to reset the live view crop to the uncropped state.
    ///
    /// If the camera doesn't support the functionality `CBLCameraSupportedFunctionalityCroppableLiveView`, this operation will fail.
    ///
    /// @param block The callback to call when the operation is complete.
    func resetLiveViewCrop(_ completionCallback: ErrorableOperationCallback?)

    /// Attempt to set the live view zoom's center point to the given point without changing the zoom level.
    ///
    /// The given point must be within the live view frame's `aspect`. The point may be adjusted by CascableCore to match
    /// the camera's requirements. To check the final position, see live view frame's `imageFrameInAspect` property once
    /// the operation completes.
    ///
    /// Note that it may take a few frames for zoom geometry to update after this operation finishes, due to frame buffers and etc.
    ///
    /// If the camera doesn't support the `CBLCameraSupportedFunctionalityCroppableLiveView` or
    /// `CBLCameraSupportedFunctionalityPannableLiveView` functionalities, this operation will fail.
    func setLiveViewZoomCenterPoint(_ centerPoint: CGPoint, completionCallback: ErrorableOperationCallback?)
}

// MARK: - Properties

/// Camera property methods.
public protocol CameraProperties {

    /// Attempt to update the camera's internal clock to the given date/time.
    ///
    /// @note Olympus cameras can only update their time when the current command categories contains `CBLCameraAvailableCommandCategoryFilesystemAccess`.
    ///
    /// Only cameras that contain `CBLCameraSupportedFunctionalityUpdateClock` in their functionality flags support this operation.
    ///
    /// For cameras that support changing timezones, the camera's timezone will be set to the current system timezone and the time will be
    /// set correctly — e.g., passing `date` as `[NSDate new]` will set the camera to the system's timezone and the time will match the system's time.
    /// If the camera's time zone is CET before calling this method and the system's time zone is PST, setting 2017-01-01 12:00:00 will set the camera
    /// to 2017-01-01 12:00:00 PST (equivalent to 2017-01-01 20:00:00 CET).
    ///
    /// For cameras that don't support changing timezones, the camera's time will be set to the given time and the camera's time zone (if any) will
    /// remain unchanged  — e.g., passing `date` as `[NSDate new]` will set the time to the system's time, but the timezone will not change.
    /// If the camera's time zone is CET before calling this method and the system's time zone is PST, setting 2017-01-01 12:00:00 will set the camera
    /// to 2017-01-01 12:00:00 CET.
    ///
    /// In all cases, the user-visible date and time on the camera will match the value of `date` passed to this method. However,
    /// depending on the camera, the time zone may be incorrect, meaning that the camera's system time may not technically be the intended time.
    ///
    /// - Canon: Timezone and DST will be set correctly.
    /// - Nikon: Timezone cannot be changed.
    /// - Olympus: Timezone will be set correctly.
    /// - Sony: System clock cannot be changed at all (this method will always return an error).
    /// - Panasonic: System clock cannot be changed at all (this method will always return an error).
    /// - Fujifilm: System clock cannot be changed at all (this method will always return an error).
    ///
    /// @param date The date/time to set.
    /// @param block The block to trigger when the value has been set or an error occurs.
    func updateClock(to date: Date, completionCallback: ErrorableOperationCallback?)

    // -------------
    // @name Autoexposure
    // -------------

    /// Returns the latest auto exposure measurement from the camera, or `nil` if AE is not currently running.
    var autoexposureResult: AEResult { get }

    // -------------
    // @name Camera Properties
    // -------------

    /// The known property identifiers, encoded as `CBLPropertyIdentifier` values in `NSNumber` objects. Observable with key-value observing.
    var knownPropertyIdentifiers: [PropertyIdentifier] { get }

    /// Returns a property object for the given identifier. If the property is currently unknown, returns an object
    /// with `currentValue`, `validSettableValues`, etc set to `nil`.
    ///
    /// The returned object is owned by the receiver, and the same object will be returned on subsequent calls to this
    /// method with the same identifier.
    ///
    /// @param identifier The property identifier to get a property object for.
    func propertyWithIdentifier(_ identifier: PropertyIdentifier) -> CameraProperty

    /// Returns an array of property objects for the given category that have a non-nil `currentValue`.
    ///
    /// @param category The category for which to get properties.
    func populatedProperties(in category: PropertyCategory) -> [CameraProperty]
}

// MARK: - Filesystem

/// Camera filesystem methods.
public protocol CameraFileSystem {

    /// Returns an array of `CBLFileStorage` instances representing the storage within the device.
    var storageDevices: [FileStorage]? { get }
}

/// MARK: - Focus and Shutter

/// A focus drive direction.
public enum FocusDriveDirection {
    /// Drive the focus towards the camera.
    case towardsCamera
    /// Drive the focus towards infinity.
    case towardsInfinity
}

/// A focus drive amount.
public enum FocusDriveAmount {
    /// A very small amount of movement.
    case small
    /// A medium amount of movement.
    case medium
    /// A large amount of movement.
    case large
}

/// Camera focus and shutter methods.
public protocol CameraFocusAndShutter {

    // -------------
    // @name Autofocus Setup
    // -------------

    /// Returns the current autofocus info from the camera.
    var focusInfo: FocusInfo? { get }

    /// Sets the given AF point as the active point.
    ///
    /// @param point The AF point to set as active.
    /// @param block The block to trigger when the active AF point has been set or an error occurs.
    func setActiveAutoFocusPoint(_ point: FocusPoint, completionCallback: ErrorableOperationCallback?)

    /// Returns `YES` if the camera currently supports freeform "touch" AF, otherwise `NO`.
    var supportsTouchAF: Bool { get }

    /// Sets the camera's touch AF position, if available.
    ///
    /// @param center The centre of the touch AF point, expressed in the current live view frame's aspect.
    /// @param block The callback to call when the operation is complete.
    func touchAFAtPoint(_ center: CGPoint, completionCallback: ErrorableOperationCallback?)

    // -------------
    // @name Engaging Autofocus and Shutter
    // -------------

    /// Returns `YES` if autofocus is currently engaged, otherwise `NO`.
    var autoFocusEngaged: Bool { get }

    /// Engages autofocus.
    ///
    /// @note Autofocus will remain engaged until `disengageAutoFocus:` is called. While autofocus is engaged,
    /// functionality not directly to taking a shot will be unavailable. Live view (if on before this method is called)
    /// will continue to stream, and you can use the `engageShutter:`, `disengageShutter:`, and `disengageAutoFocus:`
    /// methods.
    ///
    /// The typical ordering for taking a photograph using these methods is as follows:
    ///
    /// - `engageAutoFocus:`
    /// - `engageShutter:`
    /// - `disengageShutter:`
    /// - `disengageAutoFocus:`
    ///
    /// @param block The block to trigger when autofocus has been engaged or an error occurs.
    func engageAutoFocus(_ completionHandler: ErrorableOperationCallback?)

    /// Disengages autofocus.
    ///
    /// @param block The block to trigger when autofocus has been disengaged or an error occurs.
    func disengageAutoFocus(_ completionHandler: ErrorableOperationCallback?)

    /// Returns `YES` if the shutter is currently engaged, otherwise `NO`.
    var shutterEngaged: Bool { get }

    /// Engages the shutter.
    ///
    /// The shutter will remain "engaged" until `disengageShutter:` is called. However,
    /// if the camera is set to take an exposure of a specific length (i.e., anything other than "bulb"
    /// mode) the timing of these calls will have no effect on the exposure.
    ///
    /// @note This may not engage autofocus if the camera is configured to use back-button autofocus.
    ///
    /// @note Even if you don't call `engageAutoFocus:` prior to this method, calling this method may cause `autoFocusEngaged`
    ///       to become `YES`. It is the client's responsibility to detect this and called `disengageAutoFocus:` if needed.
    ///
    /// @param block The block to trigger when the shutter has been engaged or an error occurs.
    func engageShutter(_ completionHandler: ErrorableOperationCallback?)

    /// Disengages the shutter.
    ///
    /// @param block The block to trigger when the shutter has been disengaged or an error occurs.
    func disengageShutter(_ completionHandler: ErrorableOperationCallback?)

    /// Takes a single photo.
    ///
    /// This method will (optionally) engage autofocus, engage the shutter, disengage the shutter and
    /// disengage autofocus. Think of it as a "Take a photo!" button.
    ///
    /// @param triggerAutoFocus Pass `YES` to explicitly engage autofocus during the process, otherwise `NO`.
    /// @param block The block to trigger when the operation completes or an error occurs.
    func invokeOneShotShutterExplicitlyEngagingAutoFocus(_ triggerAutoFocus: Bool,
                                                        completionCallback: ErrorableOperationCallback?)

    // -------------
    // @name Camera-Initiated Transfer
    // -------------

    /// Adds an observer to be notified when a camera-initiated transfer request is received.
    ///
    /// @note Only cameras that support the `CBLCameraSupportedFunctionalityCameraInitiatedTransfer` functionality flag
    ///       will trigger these callbacks.
    ///
    /// @param handler The handler to be called when a camera-initiated transfer request is received.
    ///                Will be called on the main thread.
    func addCameraInitiatedTransferHandler(_ handler: CameraInitiatedTransferRequestHandler) -> ObserverToken

    /// Removes a previously registered camera-initiated transfer handler.
    ///
    /// @param token The token for the hander to be removed.
    func removeCameraInitiatedTransferHandler(with token: ObserverToken)

    // -------------
    // @name Direct Focus Manipulation
    // -------------

    /// Drive the camera's focus a certain amount in the given direction. Requires that the camera has the `CBLCameraSupportedFunctionalityDirectFocusManipulation`
    /// functionality available.
    ///
    /// Direct focus manipulation with this method requires that the camera has live view enabled, and that autofocus is engaged. If the camera isn't in
    /// the correct state, an error of `CBLErrorCodeNotAvailable` will be returned. In some situations, you may receive an error of
    /// `CBLErrorCodeFocusDidNotMove` — this indicates that either the focus is already at the end of its travel in the specified direction, or that the focus
    /// didn't move for some other reason.
    ///
    /// @param amount The amount to move the focus. The actual change in focus will depend on the camera and lens being used.
    /// @param direction The direction in which the focus should move.
    /// @param callback The block to trigger when the operation completes or an error occurs.
    func driveFocus(amount: FocusDriveAmount, direction: FocusDriveDirection,
                    completionCallback: ErrorableOperationCallback?)
}

// MARK: - Video Recording

/// Video recording timer types.
public enum VideoTimerType: Int {
    /// No video timer is currently available.
    case none
    /// The video timer is counting down to zero (i.e., is counting the recording time remaining).
    case countingDown
    /// The video timer is counting up from zero (i.e., is counting the length of the current clip).
    case countingUp
}

/// A video timer value. Only valid during video recording.
public protocol VideoTimerValue {

    /// The timer type.
    var type: VideoTimerType { get }

    /// The current value of the timer. Will be zero if the video timer is invalid.
    var value: TimeInterval { get }
}

/// Video recording methods.
public protocol CameraVideoRecording {

    /// Returns `YES` if the camera is currently recording video, otherwise `NO`. Will update if video recording is started
    /// or stopped using the camera's on-body controls, or if video recording stopped due to the card being full etc.
    ///
    /// Can be observed with Key-Value Observing.
    var isRecordingVideo: Bool { get }

    /// If available, returns the current value of the camera's video recording timer. Can be observed with Key-Value Observing.
    ///
    /// The returned value is immutable — a new value will be created when the timer updates.
    ///
    /// Will be `nil` when the camera isn't recording video.
    var currentVideoTimerValue: VideoTimerValue? { get }

    /// Start video recording.
    ///
    /// Will fail if the camera is already recording video, the camera isn't in a mode that allows video recording, or if
    /// some other condition prevents video recording to start (not enough space on the camera's storage card, etc).
    func startVideoRecording(_ completionHandler: ErrorableOperationCallback?)

    /// End video recording.
    func endVideoRecording(_ completionHandler: ErrorableOperationCallback?)
}
