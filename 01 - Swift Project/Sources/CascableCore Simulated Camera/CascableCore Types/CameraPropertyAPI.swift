import Foundation

/// Property identifiers.
public enum PropertyIdentifier: UInt {
    /// The camera's ISO speed setting.
    case isoSpeed
    /// The camera's shutter speed setting.
    case shutterSpeed
    /// The camera's aperture setting.
    case aperture
    /// The camera's exposure compensation setting.
    case exposureCompensation
    /// The camera's battery level. Common values will be of type `CBLPropertyCommonValueBatteryLevel`.
    case batteryLevel
    /// The camera's power source. Common values will be of type `CBLPropertyCommonValuePowerSource`.
    case powerSource
    /// The camera's autofocus system setting (area, face detection, etc). Common values will be of type `CBLPropertyCommonValueAFSystem`.
    case afSystem
    /// The camera's focus mode setting (manual, single, continuous, etc). Common values will be of type `CBLPropertyCommonValueFocusMode`.
    case focusMode
    /// The camera's drive mode setting (single, continuous, timer, etc). Common values will be of type `CBLPropertyCommonValueDriveMode`.
    case driveMode
    /// The camera's autoexposure mode setting (M, P, Tv, Av, etc). Common values will be of type `CBLPropertyCommonValueAutoExposureMode`.
    case autoExposureMode
    /// The camera's in-camera bracketing setting. Common values will be of type `CBLPropertyCommonValueBoolean`.
    case inCameraBracketingEnabled
    /// The camera's mirror lockup enabled setting. Common values will be of type `CBLPropertyCommonValueBoolean`.
    case mirrorLockupEnabled
    /// The camera's current mirror lockup stage. Common values will be of type `CBLPropertyCommonValueMirrorLockupStage`.
    case mirrorLockupStage
    /// Whether the camera is current executing depth-of-field preview. Common values will be of type `CBLPropertyCommonValueBoolean`.
    case dofPreviewEnabled
    /// The camera's reading of how many shots are available on its storage card(s). The common value will be a freeform integer containing the reading.
    case shotsAvailable
    /// The camera's lens status.
    case lensStatus
    /// The camera's "Color Tone" setting.
    case colorTone
    /// The camera's "Art Filter" setting.
    case artFilter
    /// Whether the camera is currently using digital zoom. Common values will be of type `CBLPropertyCommonValueBoolean`.
    case digitalZoom
    /// The camera's white balance setting. Common values will be of type `CBLPropertyCommonValueWhiteBalance`.
    case whiteBalance
    /// The camera's noise reduction setting.
    case noiseReduction
    /// The camera's image quality setting.
    case imageQuality
    /// The camera's light meter status. Common values will be of type `CBLPropertyCommonValueLightMeterStatus`.
    case lightMeterStatus
    /// The camera's current light meter reading. Common values will be of type CBLExposureCompensationValue.
    case lightMeterReading
    /// The camera's exposure metering mode setting.
    case exposureMeteringMode
    /// Whether the camera is ready to take a shot. Common values will be of type `CBLPropertyCommonValueBoolean`.
    case readyForCapture
    /// The target destination for images when connected to a host like CascableCore. Common values will be of type `CBLPropertyCommonValueImageDestination`.
    case imageDestination
    /// The camera's video recording format.
    case videoRecordingFormat
    /// The camera's live view zoom level.
    case liveViewZoomLevel
    case max

    // This needs to be NSNotFound, or UInt.max
    case unknown = 18446744073709551615
}

/// Property categories, which can be useful for grouping properties into sections for the user.
public enum PropertyCategory: Int {
    /// The category of the property is unknown.
    case unknown
    /// Shutter speed, ISO, EV, etc. These properties are guaranteed to conform to `CBLExposureProperty`.
    case exposureSetting
    /// Focus modes, etc — settings that affect how the image is captured.
    case captureSetting
    /// White balance, etc — settings that affect the image.
    case imagingSetting
    /// File format, etc — settings that don't affect the image.
    case configurationSetting
    /// Shots remaining, battery, etc — information about the camera that's usually read-only.
    case information
    /// Video format information. These properties are guaranteed to conform to `CBLVideoFormatProperty`.
    case videoFormat
    /// Live view zoom level information. These properties are guaranteed to conform to `CBLLiveViewZoomLevelPropertyValue`.
    case liveViewZoomLevel
}

/// Option set for identifying the type of change that occurred to a property. For performance reasons, CascableCore
/// may group value and valid values changes into one callback.
public struct PropertyChangeType: OptionSet {
    public let rawValue: UInt
    public init(rawValue: UInt) { self.rawValue = rawValue }

    /// If the option set contains this value, the current value of the property changed.
    public static let value = PropertyChangeType(rawValue: 1 << 0)
    /// If the option set contains this value, the pending value of the property changed.
    public static let pendingValue = PropertyChangeType(rawValue: 1 << 1)
    /// If the option set contains this value, the valid settable values and/or the valueSetType of the property changed.
    public static let validSettableValues = PropertyChangeType(rawValue: 1 << 2)
}

/// Option set identifying how the property can be changed. An empty value means the property is read-only,
/// information about the property has not yet been loaded, or the property isn't supported by the camera.
public struct PropertyValueSetType: OptionSet {
    public let rawValue: Int
    public init(rawValue: Int) { self.rawValue = rawValue }

    /// The property provides a list of values to be set via the `validSettableValues` property, and values can be
    /// set with the `-setValue:…` methods.
    public static let enumeration = PropertyValueSetType(rawValue: 1 << 0)
    /// The property's value can be increased or decreased with the `incrementValue:…` and `decrementValue:…` methods.
    public static let stepping = PropertyValueSetType(rawValue: 1 << 1)
}

/// A property common value. Values will be from one of the appropriate common value enums as defined below.
public typealias PropertyCommonValue = Int

/// If there isn't a common value translation for a property value, APIs will instead return this value.
public let PropertyCommonValueNone: PropertyCommonValue = -1

/// The block callback signature for property observations.
///
/// @param property The property that fired the change.
/// @param type The change type(s) that occurred. See `CBLPropertyChangeType` for details.
public typealias CameraPropertyObservationCallback = (_ property: CameraProperty, _ type: PropertyChangeType) -> Void

/// An object for managing property value change notifications. When you add an observer to a property, store the returned
/// token somewhere in order to keep the observation alive. To remove the observation, you can simply remove all strong
/// references to its token, or explicitly call `invalidate` on it.
public protocol CameraPropertyObservation: AnyObject {
    /// Invalidate the observation. Will also be called on `dealloc`.
    func invalidate()
}

/// An object representing the values for a property on the camera.
public protocol CameraProperty: AnyObject {

    /// The property's category.
    var category: PropertyCategory { get }

    /// The property's identifier.
    var identifier: PropertyIdentifier { get }

    var camera: Camera? { get }

    /// The property's display name.
    var localizedDisplayName: String? { get }

    /// Returns the property's set type. Observable with key-value observing.
    var valueSetType: PropertyValueSetType { get }

    /// The current value of the property. Observable with key-value observing.
    var currentValue: PropertyValue? { get }

    /// Add an observer to the property.
    ///
    /// The observer callback will be called on the main thread when either the `currentValue` or `validSettableValues`
    /// properties change. If possible, these changes will be consolidated into one callback rather than two.
    ///
    /// The returned observation object is _not_ retained by the receiver, and the observation will be invalidated
    /// when the object is deallocated. Make sure you store this token somewhere to keep the observation active.
    ///
    /// @param observerCallback The observer block to be triggered, on the main thread, when changes occur.
    /// @return Returns an object to manage the lifecycle of the observation.
    func addObserver(_ observer: CameraPropertyObservationCallback) -> CameraPropertyObservation

    /// Remove a previously-registered observer from this property. Equivalent to calling `-invalidate` on the observer object.
    ///
    /// @param observer The observer to remove.
    func removeObserver(_ observer: CameraPropertyObservation)

    // -------------
    // @name Property Setting: CBLPropertyValueSetTypeEnumeration
    // -------------

    /// Returns the value currently in the process of being set, if any. Observable with key-value observing. Only valid
    /// if the property's `valueSetType` is `CBLPropertyValueSetTypeEnumeration`.
    var pendingValue: PropertyValue? { get }

    /// The values that are considered valid for this property. Observable with key-value observing. Only valid if the
    /// property's `valueSetType` is `CBLPropertyValueSetTypeEnumeration`.
    var validSettableValues: [PropertyValue]? { get }

    /// Attempt to find a valid settable value for the given common value.
    ///
    /// @param commonValue The common value to find a value for. The intent must match the property identifier.
    /// @return Returns a valid settable value for the given intent, or `nil` if no value matches.
    func validValueMatchingCommonValue(_ commonValue: PropertyCommonValue) -> PropertyValue?

    /// Attempt to set a new value for the property. The value must be in the `validSettableValues` property. As such,
    /// this method is only useable if the property's `valueSetType` contains `CBLPropertyValueSetTypeEnumeration`.
    ///
    /// @param newValue The value to set.
    /// @param queue The queue on which to call the completion handler.
    /// @param completionHandler The completion handler to call when the operation succeeds or fails.
    func setValue(_ newValue: PropertyValue, completionQueue: DispatchQueue, completionHandler: ErrorableOperationCallback)

    /// Attempt to set a new value for the property. The value must be in the `validSettableValues` property. As such,
    /// this method is only useable if the property's `valueSetType` contains `CBLPropertyValueSetTypeEnumeration`.
    ///
    /// @param newValue The value to set.
    /// @param completionHandler The completion handler to call on the main queue when the operation succeeds or fails.
    func setValue(_ newValue: PropertyValue, completionHandler: ErrorableOperationCallback)

    // -------------
    // @name Property Setting: CBLPropertyValueSetTypeStepping
    // -------------

    /// Increment the property's value by one step. Only useable if the property's `valueSetType` contains
    /// `CBLPropertyValueSetTypeStepping`.
    ///
    /// @note If you're constructing a UI in a left-to-right locale (such as English) like this, this method should
    /// be called when the user taps on the right arrow: `[<] f/2.8 [>]`, or the down arrow: `[↑] f/2.8 [↓]`. In other
    /// words, this method is moving the value towards the end of a list of values.
    ///
    /// @param completionHandler The completion handler to call on the main queue when the operation succeeds or fails.
    func incrementValue(completionHandler: ErrorableOperationCallback)

    /// Increment the property's value by one step. Only useable if the property's `valueSetType` contains
    /// `CBLPropertyValueSetTypeStepping`.
    ///
    /// @note If you're constructing a UI in a left-to-right locale (such as English) like this, this method should
    /// be called when the user taps on the right arrow: `[<] f/2.8 [>]`, or the down arrow: `[↑] f/2.8 [↓]`. In other
    /// words, this method is moving the value towards the end of a list of values.
    ///
    /// @param completionQueue The queue on which to call the completion handler.
    /// @param completionHandler The completion handler to call when the operation succeeds or fails.
    func incrementValue(completionQueue: DispatchQueue, completionHandler: ErrorableOperationCallback)

    /// Decrement the property's value by one step. Only useable if the property's `valueSetType` contains
    /// `CBLPropertyValueSetTypeStepping`.
    ///
    /// @note If you're constructing a UI in a left-to-right locale (such as English) like this, this method should
    /// be called when the user taps on the left arrow: `[<] f/2.8 [>]`, or the up arrow: `[↑] f/2.8 [↓]`. In other
    /// words, this method is moving the value towards the beginning of a list of values.
    ///
    /// @param completionHandler The completion handler to call on the main queue when the operation succeeds or fails.
    func decrementValue(completionHandler: ErrorableOperationCallback)

    /// Decrement the property's value by one step. Only useable if the property's `valueSetType` contains
    /// `CBLPropertyValueSetTypeStepping`.
    ///
    /// @note If you're constructing a UI in a left-to-right locale (such as English) like this, this method should
    /// be called when the user taps on the left arrow: `[<] f/2.8 [>]`, or the up arrow: `[↑] f/2.8 [↓]`. In other
    /// words, this method is moving the value towards the beginning of a list of values.
    ///
    /// @param completionQueue The queue on which to call the completion handler.
    /// @param completionHandler The completion handler to call when the operation succeeds or fails.
    func decrementValue(completionQueue: DispatchQueue, completionHandler: ErrorableOperationCallback)
}

/// A property that exposes its values as universal exposure values.
public protocol ExposureProperty: CameraProperty {

    /// Returns the current value as a universal exposure value.
    var currentExposureValue: ExposurePropertyValue? { get }

    /// Returns the valid settable values as an array of universal exposure values.
    var validSettableExposureValues: [ExposurePropertyValue]? { get }

    /// Returns the item value in `validSettableValues` that is considered the "zero" value.
    /// For most properties this will be the first item in the array, but in some (for example,
    /// E.V.) it will be a value somewhere in the middle.
    ///
    /// Values at a lesser index than this value in `validSettableValues` are considered to
    /// be negative. This can be useful when constructing UI.

    /// Guaranteed to return a non-nil value if `validSettableValues` isn't empty.
    var validZeroValue: ExposurePropertyValue? { get }

    /// Returns the value in `validSettableValues` that, when set, will cause the camera to
    /// attempt to derive the value for this property automatically.
    ///
    /// If there is no such value, returns `nil`.
    var validAutomaticValue: ExposurePropertyValue? { get }

    /// Attempt to find a valid settable value for the given exposure value.
    ///
    /// @param exposureValue The exposure value to find a value for. The type must match the property identifier.
    /// @return Returns a valid settable value for the given exposure value, or `nil` if no value matches.
    func validValueMatchingExposureValue(_ exposureValue: UniversalExposurePropertyValue) -> ExposurePropertyValue?
}

/// A property that exposes its values as universal video format description values.
public protocol VideoFormatProperty: CameraProperty {

    /// Returns the current value as a universal video format description value.
    var currentVideoFormatValue: VideoFormatPropertyValue? { get }

    /// Returns the valid settable values as an array of video format description values.
    var validSettableVideoFormatValues: [VideoFormatPropertyValue]? { get }
}

/// A property that exposes its values as universal live view zoom level values.
public protocol LiveViewZoomLevelProperty: CameraProperty {

    /// Returns the current value as a universal live view zoom level value.
    var currentLiveViewZoomLevelValue: LiveViewZoomLevelPropertyValue? { get }

    /// Returns the valid settable values as an array of universal live view zoom level values.
    var validSettableLiveViewZoomValueValues: [LiveViewZoomLevelPropertyValue]? { get }
}

/// A property value. This could either be the current value of a property, or something in the list of values that can be set.
public protocol PropertyValue: AnyObject {

    /// The common value that this value matches, or `CBLPropertyCommonValueNone` if it doesn't match any common value.
    var commonValue: PropertyCommonValue { get }

    /// A localized display value for the value. May be `nil` if the value is unknown to CascableCore and
    /// a display value is not provided by the camera.
    var localizedDisplayValue: String? { get }

    /// A string value for the value. Will always return *something*, but the quality is not guaranteed — particularly
    /// if the value is unknown to CascableCore and a display value is not provided by the camera.
    var stringValue: String { get }

    /// An opaque value representing the property. Not guaranteed to be anything in particular, as this is an internal
    /// implementation detail for each particular camera.
    var opaqueValue: Any { get }
}

/// A property value that exposes its values as universal exposure values.
public protocol ExposurePropertyValue: PropertyValue {

    /// Returns the value as a universal exposure value.
    var exposureValue: UniversalExposurePropertyValue { get }
}

/// Values representing the level of video compression for a `CBLVideoFormatPropertyValue` value. In general,
/// higher values have *more* compression (i.e., smaller file sizes).
public enum VideoFormatCompressionLevel: Int {
    /// The compression level is unavailable.
    case unknown = 0

    /// The video is being compressed with a raw codec.
    case raw = 1

    /// The video is being compressed using a codec that's effectively lossless, such as ProRes.
    case effectivelyLossless = 2

    /// The video is being compressed using a codec designed for editing. This includes codecs like MJPEG, as well
    /// as h264/h265 in ALL-I/XAVC S-I mode.
    case forEditing = 3

    /// The video is being compressed using a codec designed for playback. This includes h264/h265 in Long GOP/IPB/
    /// IPB Standard/XAVC S/XAVC HS mode.
    case normal = 4

    /// The video is being compressed using a codec designed for smaller file sizes. This includes h264/264 in
    /// IPB Light/XAVC L mode.
    case high = 5
}

/// A property value that represents a video format description.
public protocol VideoFormatPropertyValue: PropertyValue {

    /// Returns the video format's frame rate, if available. If not available, returns `NSNotFound`.
    var frameRate: Int { get }

    /// Returns the video format's frame size, in pixels, if available. If not available, returns `CGSizeZero`.
    var frameSize: CGSize { get }

    /// Returns the video format's compression level, if available. If not available, returns `CBLVideoFormatCompressionLevelUnknown`.
    var compressionLevel: VideoFormatCompressionLevel { get }
}

/// A property value that represents a live view zoom level.
public protocol LiveViewZoomLevelPropertyValue: PropertyValue {

    /// Returns `YES` if the value represents a "zoomed in" value, otherwise `NO`.
    var isZoomedIn: Bool { get }

    /// Returns a numeric zoom factor. These values aren't neccessarily consistent between camera manufacturers or even
    /// models, but they will get larger the more zoomed in the value is - it's useful for sorting. There are two special
    /// values: no zoom is `1.0`, and an unknown zoom factor is `0.0`.
    var zoomFactor: Double { get }
}

// MARK: - Common Values

/// Boolean common values.
public enum PropertyCommonValueBoolean: PropertyCommonValue {
    /// The value is equivalent to "false" or "off".
    case `false` = 0
    /// The value is equivalent to "true" or "on".
    case `true` = 1
}

/// Autoexposure mode common values.
public enum PropertyCommonValueAutoExposureMode: PropertyCommonValue {
    /// The value is equivalent to a fully automatic/"green box" mode.
    case fullyAutomatic = 50
    /// The value is equivalent to the P/Program mode.
    case programAuto
    /// The value is equivalent to the Tv/S shutter priority mode.
    case shutterPriority
    /// The value is equivalent to the Av/A aperture priority mode.
    case aperturePriority
    /// The value is equivalent to the M/manual mode.
    case fullyManual
    /// The value is equivalent to the B/bulb mode.
    case bulb
    /// The value is equivalent to a "flexible priority" mode, such as Canon's Fv.
    case flexiblePriority
}

/// White balance common values.
public enum PropertyCommonValueWhiteBalance: PropertyCommonValue {
    /// The value is equivalent to an automatic white balance setting.
    case auto = 100
    /// The value is equivalent to daylight/sunny white balance.
    case daylight
    /// The value is equivalent to shade white balance.
    case shade
    /// The value is equivalent to cloudy white balance.
    case cloudy
    /// The value is equivalent to tungsten white balance.
    case tungsten
    /// The value is equivalent to fluorescent white balance.
    case fluorescent
    /// The value is equivalent to flash white balance.
    case flash
    /// The value is equivalent to a custom white balance.
    case custom
    /// The value is equivalent to a second custom white balance for cameras that support multiple custom values.
    case custom2
    /// The value is equivalent to a third custom white balance for cameras that support multiple custom values.
    case custom3
}

/// Focus mode common values.
public enum PropertyCommonValueFocusMode: PropertyCommonValue {
    /// The value is equivalent to the manual focus mode.
    case manual = 150
    /// The value is equivalent to the single drive focus mode (once focus is acquired, the camera stops focusing).
    case singleDrive
    /// The value is equivalent to the continuous drive focus mode (the camera continually performs autofocus until told to stop).
    case continuousDrive
}

/// Battery level common values.
public enum PropertyCommonValueBatteryLevel: PropertyCommonValue {
    /// The value is equivalent to a full battery.
    case full = 200
    /// The value is equivalent to a 75% full battery.
    case threeQuarters
    /// The value is equivalent to a 50% full battery.
    case half
    /// The value is equivalent to a 25% full battery.
    case oneQuarter
    /// The value is equivalent to an empty battery. Typically the camera is flashing a red battery symbol at this point.
    case empty
}

/// Power source common values.
public enum PropertyCommonValuePowerSource: PropertyCommonValue {
    /// The value is equivalent to a battery power source.
    case battery = 210
    /// The value is equivalent to a mains or external power source.
    case mainsPower
}

/// Light meter common values.
public enum PropertyCommonValueLightMeterStatus: PropertyCommonValue {
    /// The value is equivalent to the camera's light meter not being in use.
    case notInUse = 250
    /// The value is equivalent to the camera's light meter being operational and providing a valid reading.
    case validReading
    /// The value is equivalent to the camera's light meter being operational but the reading is outside valid bounds
    /// (for example, the current settings will produce an image completely over- or under-exposed.
    case beyondBounds
}

/// Mirror lockup common values.
public enum PropertyCommonValueMirrorLockupStage: PropertyCommonValue {
    /// The value is equivalent to the camera's mirror lockup feature being disabled.
    case disabled = 300
    /// The value is equivalent to the camera's mirror lockup feature being enabled and ready to operate.
    case ready
    /// The value is equivalent to the camera's mirror being flipped up and waiting for a shot.
    case mirrorUpBeforeShot
}

/// Autofocus system common values.
public enum PropertyCommonValueAFSystem: PropertyCommonValue {
    /// The value is equivalent to using a "traditional" off-sensor array of autofocus points for autofocus.
    case viewfinderAFPoints = 350
    /// The value is equivalent to using a single area on the sensor for autofocus.
    case singleArea
    /// The value is equivalent to using multiple areas on the sensor for autofocus.
    case multipleAreas
    /// The value is equivalent to using face-detection for autofocus.
    case faceDetection
    /// The value is equivalent to using a single small point on the sensor for autofocus.
    case singlePoint
    /// The value is equivalent to using a single point on the sensor for autofocus, then tracking the subject from that
    /// point while autofocus is active.
    case singlePointTracking
}

/// Drive mode common values.
public enum PropertyCommonValueDriveMode: PropertyCommonValue {
    /// The value is equivalent to a single shot drive mode.
    case singleShot = 400
    /// The value is equivalent to a single shot, electronic first-curtain drive mode. Often called quiet, vibration
    /// reduction, VR, etc.
    case singleShotElectronicFirstCurtain
    /// The value is equivalent to a single shot, electronic shutter drive mode. Often called silent, S, etc.
    case singleElectronic

    /// The value is equivalent to a continous/multi-shot shot drive mode.
    case continuous
    /// The value is equivalent to a continous/multi-shot shot, electronic first-curtain drive mode.
    case continuousElectronicFirstCurtain
    /// The value is equivalent to a continous/multi-shot shot, electronic shutter drive mode.
    case continuousElectronic

    /// The value is equivalent to a low-speed continous/multi-shot shot drive mode on cameras that have multiple levels
    /// of speed for their continuous shooting.
    case continuousLowSpeed
    /// The value is equivalent to a medium-speed continous/multi-shot shot drive mode on cameras that have multiple levels
    /// of speed for their continuous shooting.
    case continuousMediumSpeed
    /// The value is equivalent to a high-speed continous/multi-shot shot drive mode on cameras that have multiple levels
    /// of speed for their continuous shooting.
    case continuousHighSpeed

    /// The value is equivalent to a short duration timer drive mode, usually 2-3 seconds or so.
    case timerShort
    /// The value is equivalent to a long duration timer drive mode, usually 10 seconds or so.
    case timerLong
    /// The value is equivalent to a timer drive mode with a custom duration set by the user.
    case timerCustomDuration
    /// The value is equivalent to a timer drive mode, that takes a burst of shots at the end.
    case timerWithContinuousShooting
}

/// Image destination setting common values.
public enum PropertyCommonValueImageDestination: PropertyCommonValue {
    /// Images will be saved to the camera storage only.
    case camera = 501
    /// Images will be saved to the connected host (i.e., the CascableCore client) and *not* camera storage.
    case connectedHost = 502
    /// Images will be saved to both camera storage and the connected host (i.e., the CascableCore client).
    case cameraAndHost = 503
}
