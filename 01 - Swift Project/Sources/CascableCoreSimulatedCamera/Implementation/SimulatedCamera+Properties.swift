//
//  SimulatedCamera+Properties.swift
//  CascableCore Simulated Camera Plugin
//
//  Created by Daniel Kennett (Cascable) on 2023-12-04.
//  Copyright © 2023 Cascable AB. All rights reserved.
//

import Foundation
import StopKit
import CascableCoreAPI

// MARK: - Property Identifier and Category Mapping
// Note: This should be in our "CascableCore+Swift" API. It's also in the Phase One target.

internal extension PropertyIdentifier {
    static var allCases: [PropertyIdentifier] = {
        return (0..<PropertyIdentifier.max.rawValue).compactMap { PropertyIdentifier(rawValue: $0) }
    }()
}

internal extension PropertyCategory {

    /// Returns the property identifiers that are contained within this category.
    var propertyIdentifiers: [PropertyIdentifier] {
        // TODO: This is inefficient.
        return PropertyIdentifier.allCases.filter({ $0.category == self })
    }
}

internal extension PropertyIdentifier {

    /// Returns the category that the property identifier belongs to.
    var category: PropertyCategory {
        switch self {
        case .isoSpeed, .shutterSpeed, .aperture, .exposureCompensation, .lightMeterReading:
            return .exposureSetting

        case .afSystem, .focusMode, .driveMode, .mirrorLockupEnabled, .mirrorLockupStage, .digitalZoom:
            return .captureSetting

        case .whiteBalance, .colorTone, .artFilter, .autoExposureMode, .exposureMeteringMode:
            return .imagingSetting

        case .inCameraBracketingEnabled, .noiseReduction, .imageQuality, .imageDestination:
            return .configurationSetting

        case .batteryLevel, .powerSource, .shotsAvailable, .lensStatus, .lightMeterStatus, .dofPreviewEnabled, .readyForCapture:
            return .information

        case .videoRecordingFormat:
            return .videoFormat

        case .liveViewZoomLevel:
            return .liveViewZoomLevel

        case .max, .unknown:
            return .unknown
        }
    }
}

// MARK: - Observation Token

internal class SimulatedCameraPropertyObserverToken: NSObject, CameraPropertyObservation {

    static func == (lhs: SimulatedCameraPropertyObserverToken, rhs: SimulatedCameraPropertyObserverToken) -> Bool {
        return lhs.internalToken == rhs.internalToken
    }

    init(observing property: CameraProperty) {
        self.property = property
        self.internalToken = UUID().uuidString
    }

    override var hash: Int {
        return internalToken.hash
    }

    override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? SimulatedCameraPropertyObserverToken else { return false }
        return internalToken == other.internalToken
    }

    private(set) internal var internalToken: String
    private(set) weak var property: CameraProperty?

    func invalidate() {
        property?.removeObserver(self)
        property = nil
    }

    deinit {
        invalidate()
    }
}

// MARK: - Property Base

internal class SimulatedCameraProperty: NSObject, CameraProperty {

    internal class func create(for identifier: PropertyIdentifier, named name: String, valueSetType: PropertyValueSetType,
                               on camera: SimulatedCamera) -> SimulatedCameraProperty {
        switch identifier.category {
        case .captureSetting, .configurationSetting, .imagingSetting, .information, .unknown:
            return SimulatedCameraProperty(identifier: identifier, camera: camera, localizedDisplayName: name,
                                           valueSetType: valueSetType, currentValue: nil, validSettableValues: nil)

        case .exposureSetting:
            return SimulatedExposureProperty(identifier: identifier, camera: camera, localizedDisplayName: name,
                                             valueSetType: valueSetType, currentValue: nil, validSettableValues: nil)
        case .videoFormat:
            return SimulatedVideoFormatProperty(identifier: identifier, camera: camera, localizedDisplayName: name,
                                                valueSetType: valueSetType, currentValue: nil, validSettableValues: nil)
        case .liveViewZoomLevel:
            return SimulatedLiveViewZoomLevelProperty(identifier: identifier, camera: camera, localizedDisplayName: name,
                                                      valueSetType: valueSetType, currentValue: nil, validSettableValues: nil)
        }
    }

    fileprivate init(identifier: PropertyIdentifier, camera: SimulatedCamera,
                 localizedDisplayName: String, valueSetType: PropertyValueSetType,
                 currentValue: PropertyValue? = nil,
                 validSettableValues: [PropertyValue]? = nil) {
        self.identifier = identifier
        self.camera = camera
        self.connectionSpeed = camera.configuration.connectionSpeed
        self.localizedDisplayName = localizedDisplayName
        self.valueSetType = (validSettableValues?.isEmpty == false) ? valueSetType : []
        self.settableSetType = valueSetType
        self.currentValue = currentValue
        self.validSettableValues = validSettableValues
    }

    // MARK: - Public API

    private(set) var camera: Camera?

    let identifier: PropertyIdentifier
    var category: PropertyCategory { return identifier.category }
    let localizedDisplayName: String?

    private let settableSetType: PropertyValueSetType
    dynamic private(set) var valueSetType: PropertyValueSetType
    dynamic private(set) var currentValue: PropertyValue?
    dynamic private(set) var pendingValue: PropertyValue?
    dynamic private(set) var validSettableValues: [PropertyValue]?

    func addObserver(_ observerCallback: @escaping CameraPropertyObservationCallback) -> CameraPropertyObservation {
        let token = SimulatedCameraPropertyObserverToken(observing: self)
        observerStorage[token.internalToken] = observerCallback
        return token
    }

    func removeObserver(_ observer: CameraPropertyObservation) {
        guard let token = observer as? SimulatedCameraPropertyObserverToken else { return }
        observerStorage.removeValue(forKey: token.internalToken)
    }

    func validValue(matchingCommonValue commonValue: PropertyCommonValue) -> PropertyValue? {
        return validSettableValues?.first(where: { $0.commonValue == commonValue })
    }

    func setValue(_ newValue: PropertyValue, completionHandler: @escaping ErrorableOperationCallback) {
        setValue(newValue, completionQueue: .main, completionHandler: completionHandler)
    }

    func setValue(_ newValue: PropertyValue, completionQueue queue: DispatchQueue, completionHandler: @escaping ErrorableOperationCallback) {
        guard let camera else {
            queue.async { completionHandler(NSError(cblErrorCode: .notConnected)) }
            return
        }

        guard camera.currentCommandCategoriesContains(.stillsShooting) || camera.currentCommandCategoriesContains(.videoRecording) else {
            queue.async { completionHandler(NSError(cblErrorCode: .incorrectCommandCategory)) }
            return
        }

        guard settableSetType.contains(.enumeration) else {
            queue.async { completionHandler(NSError(cblErrorCode: .notAvailable)) }
            return
        }

        let effectiveSettableValues: [PropertyValue] = (validSettableValues ?? [])

        guard effectiveSettableValues.contains(where: { $0.isEqual(newValue) }) else {
            queue.asyncAfter(deadline: .now() + connectionSpeed.smallOperationDuration) {
                completionHandler(NSError(cblErrorCode: .invalidPropertyValue))
            }
            return
        }

        pendingValue = newValue
        notifyObservers(type: .pendingValue)

        DispatchQueue.main.asyncAfter(deadline: .now() + connectionSpeed.smallOperationDuration) {

            self.pendingValue = nil
            self.notifyObservers(type: .pendingValue)

            self.currentValue = newValue
            self.notifyObservers(type: .value)

            queue.async { completionHandler(nil) }
        }
    }

    func incrementValue(completionHandler: @escaping ErrorableOperationCallback) {
        incrementValue(completionQueue: .main, completionHandler: completionHandler)
    }

    func incrementValue(completionQueue: DispatchQueue, completionHandler: @escaping ErrorableOperationCallback) {
        guard let camera else {
            completionQueue.async { completionHandler(NSError(cblErrorCode: .notConnected)) }
            return
        }

        guard camera.currentCommandCategoriesContains(.stillsShooting) || camera.currentCommandCategoriesContains(.videoRecording) else {
            completionQueue.async { completionHandler(NSError(cblErrorCode: .incorrectCommandCategory)) }
            return
        }

        guard settableSetType.contains(.stepping) else {
            completionQueue.async { completionHandler(NSError(cblErrorCode: .notAvailable)) }
            return
        }

        guard let validSettableValues, !validSettableValues.isEmpty, let currentValue,
              let currentIndex = validSettableValues.firstIndex(where: { $0.isEqual(currentValue) }) else {
            completionQueue.async { completionHandler(NSError(cblErrorCode: .notAvailable)) }
            return
        }

        var nextIndex = currentIndex + 1
        if nextIndex >= validSettableValues.endIndex { nextIndex = validSettableValues.endIndex - 1 }
        let nextValue = validSettableValues[nextIndex]

        DispatchQueue.main.asyncAfter(deadline: .now() + connectionSpeed.smallOperationDuration) {
            self.currentValue = nextValue
            self.notifyObservers(type: .value)
            completionQueue.async { completionHandler(nil) }
        }
    }

    func decrementValue(completionHandler: @escaping ErrorableOperationCallback) {
        decrementValue(completionQueue: .main, completionHandler: completionHandler)
    }

    func decrementValue(completionQueue: DispatchQueue, completionHandler: @escaping ErrorableOperationCallback) {
        guard let camera else {
            completionQueue.async { completionHandler(NSError(cblErrorCode: .notConnected)) }
            return
        }

        guard camera.currentCommandCategoriesContains(.stillsShooting) || camera.currentCommandCategoriesContains(.videoRecording) else {
            completionQueue.async { completionHandler(NSError(cblErrorCode: .incorrectCommandCategory)) }
            return
        }

        guard settableSetType.contains(.stepping) else {
            completionQueue.async { completionHandler(NSError(cblErrorCode: .notAvailable)) }
            return
        }

        guard let validSettableValues, !validSettableValues.isEmpty, let currentValue,
              let currentIndex = validSettableValues.firstIndex(where: { $0.isEqual(currentValue) }) else {
            completionQueue.async { completionHandler(NSError(cblErrorCode: .notAvailable)) }
            return
        }

        var previousIndex = currentIndex - 1
        if previousIndex < 0 { previousIndex = 0 }
        let previousValue = validSettableValues[previousIndex]

        DispatchQueue.main.asyncAfter(deadline: .now() + connectionSpeed.smallOperationDuration) {
            self.currentValue = previousValue
            self.notifyObservers(type: .value)
            completionQueue.async { completionHandler(nil) }
        }
    }

    // MARK: - Internal

    internal func immediatelySetValue(to newValue: PropertyValue?) {
        let currentChanged = {
            guard let currentValue, let newValue else { return (currentValue == nil) != (newValue == nil) }
            return !currentValue.isEqual(newValue)
        }()

        if currentChanged {
            currentValue = newValue
            notifyObservers(type: .value)
        }
    }

    internal func immediatelySetValue(to newValue: PropertyValue?, in newSettableValues: [PropertyValue]) {
        var changes: PropertyChangeType = []
        let currentChanged = {
            guard let currentValue, let newValue else { return (currentValue == nil) != (newValue == nil) }
            return !currentValue.isEqual(newValue)
        }()

        let settableValuesChanged = {
            guard let validSettableValues else { return true }
            guard validSettableValues.count == newSettableValues.count else { return true }

            return zip(validSettableValues, newSettableValues).contains(where: { !$0.isEqual($1) })
        }()

        if currentChanged {
            changes.insert(.value)
            currentValue = newValue
        }

        if settableValuesChanged {
            changes.insert(.validSettableValues)
            validSettableValues = newSettableValues
            valueSetType = (newSettableValues.isEmpty ? [] : settableSetType)
        }

        if !changes.isEmpty { notifyObservers(type: changes) }
    }

    private let connectionSpeed: SimulatedConnectionSpeed
    private var observerStorage = [String: CameraPropertyObservationCallback]()

    private func notifyObservers(type: PropertyChangeType) {
        observerStorage.values.forEach({ $0(self, type) })
    }
}

// MARK: - Property Variants

// This subclass implements the ExposureProperty protocol.
internal class SimulatedExposureProperty: SimulatedCameraProperty, ExposureProperty {

    class func keyPathsForValuesAffectingCurrentExposureValue() -> Set<String> { return ["currentValue"] }
    var currentExposureValue: ExposurePropertyValue? {
        return currentValue as? ExposurePropertyValue
    }

    class func keyPathsForValuesAffectingValidSettableExposureValues() -> Set<String> { return ["validSettableValues"] }
    var validSettableExposureValues: [ExposurePropertyValue]? {
        return validSettableValues?.compactMap({ $0 as? ExposurePropertyValue })
    }

    class func keyPathsForValuesAffectingValidZeroValue() -> Set<String> { return ["validSettableValues"] }
    var validZeroValue: ExposurePropertyValue? {
        if identifier == .exposureCompensation {
            let zeroEV = ExposureCompensationValue.zeroEV
            if let matching = validSettableExposureValues?.first(where: { $0.exposureValue.isEqual(zeroEV) }) {
                return matching
            }
        }

        return validSettableExposureValues?.first
    }

    class func keyPathsForValuesAffectingValidAutomaticValue() -> Set<String> { return ["validSettableValues"] }
    var validAutomaticValue: ExposurePropertyValue? {
        if identifier == .isoSpeed || identifier == .aperture {
            return validSettableExposureValues?.first(where: { !$0.exposureValue.isDeterminate })
        } else if identifier == .shutterSpeed {
            return validSettableExposureValues?.first(where: {
                guard let shutter = $0.exposureValue as? ShutterSpeedValue else { return false }
                return !shutter.isDeterminate && !shutter.isBulb
            })
        }
        return nil
    }

    func validValue(matchingExposureValue exposureValue: any UniversalExposurePropertyValue) -> ExposurePropertyValue? {
        return validSettableExposureValues?.first(where: { $0.exposureValue.isEqual(exposureValue) })
    }
}

// This subclass implements the VideoFormatProperty protocol.
class SimulatedVideoFormatProperty: SimulatedCameraProperty, VideoFormatProperty {

    class func keyPathsForValuesAffectingCurrentVideoFormatValue() -> Set<String> { return ["currentValue"] }
    var currentVideoFormatValue: VideoFormatPropertyValue? {
        return currentValue as? VideoFormatPropertyValue
    }

    class func keyPathsForValuesAffectingValidSettableVideoFormatValues() -> Set<String> { return ["validSettableValues"] }
    var validSettableVideoFormatValues: [VideoFormatPropertyValue]? {
        return validSettableValues?.compactMap({ $0 as? VideoFormatPropertyValue })
    }
}

// This subclass implements the LiveViewZoomLevelProperty protocol.
class SimulatedLiveViewZoomLevelProperty: SimulatedCameraProperty, LiveViewZoomLevelProperty {

    class func keyPathsForValuesAffectingCurrentLiveViewZoomLevelValue() -> Set<String> { return ["currentValue"] }
    var currentLiveViewZoomLevelValue: LiveViewZoomLevelPropertyValue? {
        return currentValue as? LiveViewZoomLevelPropertyValue
    }

    class func keyPathsForValuesAffectingValidSettableLiveViewZoomLevelValues() -> Set<String> { return ["validSettableValues"] }
    var validSettableLiveViewZoomLevelValues: [LiveViewZoomLevelPropertyValue]? {
        return validSettableValues?.compactMap({ $0 as? LiveViewZoomLevelPropertyValue })
    }
}

// MARK: - Property Values

internal class SimulatedPropertyValue: NSObject, PropertyValue {

    init(commonValue: PropertyCommonValue, localizedDisplayValue: String) {
        self.commonValue = commonValue
        self.stringValue = localizedDisplayValue
    }

    override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? SimulatedPropertyValue else { return false }
        return other.stringValue == self.stringValue && other.commonValue == self.commonValue
    }

    override var description: String {
        return "\(super.description): \(stringValue)"
    }

    let commonValue: PropertyCommonValue
    let stringValue: String

    var localizedDisplayValue: String? { return stringValue }
    var opaqueValue: Any { return self }
}

internal class SimulatedExposurePropertyValue: SimulatedPropertyValue, ExposurePropertyValue {

    init(_ exposureValue: any UniversalExposurePropertyValue) {
        self.exposureValue = exposureValue
        super.init(commonValue: PropertyCommonValueNone,
                   localizedDisplayValue: exposureValue.localizedDisplayValue ?? exposureValue.succinctDescription)
    }

    override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? SimulatedExposurePropertyValue else { return false }
        return other.exposureValue.isEqual(self.exposureValue)
    }

    let exposureValue: any UniversalExposurePropertyValue
}

internal class SimulatedVideoFormatPropertyValue: SimulatedPropertyValue, VideoFormatPropertyValue {

    init(frameRate: Int, frameSize: CGSize, compressionLevel: VideoFormatCompressionLevel) {
        self.frameRate = frameRate
        self.frameSize = frameSize
        self.compressionLevel = compressionLevel
        super.init(commonValue: PropertyCommonValueNone, localizedDisplayValue: "\(Int(frameSize.width))x\(Int(frameSize.height)) @ \(frameRate) fps")
    }

    override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? SimulatedVideoFormatPropertyValue else { return false }
        return other.frameRate == self.frameRate && other.frameSize == self.frameSize && other.compressionLevel == self.compressionLevel
    }

    let frameRate: Int
    let frameSize: CGSize
    let compressionLevel: VideoFormatCompressionLevel
}

internal class SimulatedLiveViewzoomLevelPropertyValue: SimulatedPropertyValue, LiveViewZoomLevelPropertyValue {

    init(isZoomedIn: Bool, zoomFactor: Double) {
        self.isZoomedIn = isZoomedIn
        self.zoomFactor = zoomFactor
        super.init(commonValue: PropertyCommonValueNone, localizedDisplayValue: isZoomedIn ? "\(zoomFactor)x" : "Off")
    }

    override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? SimulatedLiveViewzoomLevelPropertyValue else { return false }
        return other.isZoomedIn == self.isZoomedIn && other.zoomFactor == self.zoomFactor
    }

    let isZoomedIn: Bool
    let zoomFactor: Double
}
