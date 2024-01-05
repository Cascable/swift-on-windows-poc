//
//  SimulatedCamera.swift
//  Cascable
//
//  Created by Daniel Kennett on 21/07/16.
//  Copyright © 2016 Cascable AB. All rights reserved.
//

import Foundation
import StopKit
import CascableCoreAPI

#if canImport(UniformTypeIdentifiers)
import UniformTypeIdentifiers
#endif

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
internal extension NSImage {
    func jpegData(compressionQuality: CGFloat) -> Data? {
        guard let imageTiffData = tiffRepresentation, let imageRep = NSBitmapImageRep(data: imageTiffData) else {
            return nil
        }
        let imageProps: [NSBitmapImageRep.PropertyKey: Any] = [NSBitmapImageRep.PropertyKey.compressionFactor: compressionQuality]
        return imageRep.representation(using: NSBitmapImageRep.FileType.jpeg, properties: imageProps)
    }
}
#endif

internal class SimulatedCameraAuthenticationContext: NSObject, CameraAuthenticationContext {

    let type: CameraAuthenticationType
    let simulatedAuth: SimulatedAuthentication
    let previousSubmissionRejected: Bool
    let authenticationIdentifier: String
    let cancellationHandler: () -> Void
    let submitSuccessHandler: (Bool) -> Void

    init(identifier: String, simulatedAuthType: SimulatedAuthentication,
         isRetry: Bool = false, cancellationHandler: @escaping () -> Void,
         submitSuccessHandler: @escaping (Bool) -> Void) {
        self.cancellationHandler = cancellationHandler
        self.submitSuccessHandler = submitSuccessHandler
        self.previousSubmissionRejected = isRetry
        self.authenticationIdentifier = identifier
        self.simulatedAuth = simulatedAuthType

        switch simulatedAuth {
        case .none: type = .interactWithCamera
        case .pairOnCamera: type = .interactWithCamera
        case .userNameAndPassword(_, _): type = .usernameAndPassword
        case .fourDigitCode(_): type = .fourDigitNumericCode
        }
    }

    override var description: String {
        let typeString: String = {
            switch simulatedAuth {
            case .none: return ".none"
            case .pairOnCamera: return ".pairOnCamera"
            case .userNameAndPassword(_, _): return ".userNameAndPassword"
            case .fourDigitCode(_): return ".fourDigitCode"
            }
        }()

        return "\(super.description): \(typeString)"
    }

    func submitCancellation() {
        cancellationHandler()
    }

    func submitUserName(_ userName: String, password: String) {
        guard case .userNameAndPassword(let targetUser, let targetPassword) = simulatedAuth else { return }
        submitSuccessHandler(userName == targetUser && password == targetPassword)
    }

    func submitNumericCode(_ code: String) {
        guard case .fourDigitCode(let targetCode) = simulatedAuth else { return }
        submitSuccessHandler(code == targetCode)
    }
}

internal class SimulatedVideoTimerValue: NSObject, VideoTimerValue {
    internal init(type: VideoTimerType, value: TimeInterval) {
        self.type = type
        self.value = value
    }

    let type: VideoTimerType
    let value: TimeInterval

    func copy(with zone: NSZone? = nil) -> Any {
        return SimulatedVideoTimerValue(type: type, value: value)
    }
}

class SimulatedCameraInfo: NSObject, DeviceInfo, CameraDiscoveryService {

    init(configuration: SimulatedCameraConfiguration, clientName: String, transport: CameraTransport) {
        self.manufacturer = configuration.manufacturer
        self.model = configuration.model
        self.modelName = configuration.model
        self.serialNumber = configuration.identifier
        self.cameraSerialNumber = configuration.identifier
        self.cameraId = configuration.identifier
        self.transport = transport
        self.clientName = clientName

        if transport == .network {
            hostName = "localhost"
            #if os(Windows)
            ipv4Address = "127.0.0.1"
            #else
            if let interface = NetworkConfigurationHelper.suggestedInterfaceForCameraCommunication() {
                ipv4Address = NetworkConfigurationHelper.ipAddress(ofInterface: interface)
            } else {
                ipv4Address = nil
            }
            #endif
        } else {
            hostName = nil
            ipv4Address = nil
        }
    }

    let transport: CameraTransport
    let manufacturer: String?
    let model: String?
    let modelName: String?
    let version: String? = "1.0"
    let serialNumber: String?
    let cameraSerialNumber: String?
    let cameraId: String?
    let ipv4Address: String?
    let hostName: String?
    let clientName: String
    let port = 0

    let serviceHasBeenResolved = true
    let metadataHasBeenResolved = true

    weak var delegate: CameraDiscoveryServiceDelegate?

    func forceRemoval() {
        if let delegate = delegate {
            delegate.serviceShouldBeForciblyRemoved(self)
        }
    }

    func resolve(_ block: @escaping CameraDiscoveryServiceResolveCallback, queue blockQueue: DispatchQueue) {
        blockQueue.async {
            block(self, nil)
        }
    }

    func resolveMetadata(_ block: @escaping CameraDiscoveryMetadataResolveCallback, queue blockQueue: DispatchQueue) {
        blockQueue.async {
            block(self, nil)
        }
    }
}

class SimulatedConnectionWarning: NSObject, ConnectionWarning {
    let type: ConnectionWarningType
    let category: ConnectionWarningCategory

    init(category: ConnectionWarningCategory, type: ConnectionWarningType) {
        self.type = type
        self.category = category
    }
}

class SimulatedLiveViewFrame: NSObject, NSCopying, LiveViewFrame {

    init(with imageData: Data, of size: CGSize, decodeImage: Bool) {
        self.rawPixelData = imageData
        self.rawPixelSize = size
        self.rawPixelCropRect = CGRect(origin: .zero, size: size)
        self.aspect = size
        self.imageFrameInAspect = CGRect(origin: .zero, size: size)
        if decodeImage {
            image = PlatformImageType(data: imageData)
        } else {
            image = nil
        }
    }

    var image: PlatformImageType?
    var rawPixelData: Data
    var aspect: CGSize
    var rawPixelSize: CGSize
    var rawPixelCropRect: CGRect
    var imageFrameInAspect: CGRect
    let minimumCropSize: CGSize = .zero

    var dateProduced: Date = Date()
    var brightnessHistogramPlane: [Any]? = nil
    var redHistogramPlane: [Any]? = nil
    var greenHistogramPlane: [Any]? = nil
    var blueHistogramPlane: [Any]? = nil
    var orientation = LiveViewFrameOrientation.landscape
    var rollAngle: CGFloat = 0.0
    var rawPixelFormat: LiveViewFramePixelFormat { return .JPEG }
    var afAreas: [LiveViewAFArea]? = nil
    var zoomPreviewRect: CGRect = CGRect.zero
    var isZoomedIn: Bool = false
    var zoomRectOffset = CGPoint.zero

/*
    lazy var rawPixelFormatDescription: CMFormatDescription = {
        var format: CMFormatDescription? = nil
        let _ = CMVideoFormatDescriptionCreate(allocator: kCFAllocatorDefault, codecType: kCMVideoCodecType_JPEG,
                                               width: Int32(rawPixelSize.width), height: Int32(rawPixelSize.height),
                                               extensions: nil, formatDescriptionOut: &format)
        return format!
    }()
    */

    func translateSubRectOfAspect(_ liveViewRect: CGRect, toSubRectOf targetContainer: CGRect) -> CGRect {
        return liveViewRect
    }

    func pointInAspectTranslated(from point: CGPoint, in container: CGRect) -> CGPoint {
        return point
    }

    func translatePointInAspect(_ liveViewPoint: CGPoint, toPointIn targetContainer: CGRect) -> CGPoint {
        return liveViewPoint
    }

    func copy(with zone: NSZone?) -> Any {
        return self
    }

}

class SimulatedCameraInitiatedTransfer: NSObject, CameraInitiatedTransferRequest {

    init(transferring data: Data, connectionSpeed: SimulatedConnectionSpeed) {
        transferProgress = Progress(totalUnitCount: 0)
        transferProgress.completedUnitCount = 0
        transferProgress.isCancellable = false
        transferProgress.isPausable = false
        self.connectionSpeed = connectionSpeed
        self.dataToTransfer = data
    }

    let dataToTransfer: Data
    let connectionSpeed: SimulatedConnectionSpeed
    let isValid: Bool = true
    let fileNameHint: String? = nil
    let isOnlyDestinationForImage: Bool = true
    let executionRequiredToClearBuffer: Bool = false
    let availableRepresentations: CameraInitiatedTransferRepresentation = [.preview]

    func canProvide(_ representation: CameraInitiatedTransferRepresentation) -> Bool {
        return availableRepresentations.contains(representation)
    }

    dynamic private(set) var transferState: CameraInitiatedTransferState = .notStarted
    dynamic private(set) var transferProgress: Progress

    func executeTransfer(for representations: CameraInitiatedTransferRepresentation,
                         completionHandler: @escaping CameraInitiatedTransferCompletionHandler) {
        executeTransfer(for: representations, completionQueue: .main, completionHandler: completionHandler)
    }

    func executeTransfer(for representations: CameraInitiatedTransferRepresentation,
                         completionQueue: DispatchQueue,
                         completionHandler: @escaping CameraInitiatedTransferCompletionHandler) {

        transferState = .inProgress

        completionQueue.asyncAfter(deadline: DispatchTime.now() + connectionSpeed.largeOperationDuration) {
            self.transferState = .complete
            completionHandler(SimulatedCameraInitiatedTransferResult(jpegData: self.dataToTransfer), nil)
        }
    }
}

class SimulatedCameraInitiatedTransferResult: NSObject, CameraInitiatedTransferResult {

    let jpegData: Data

    init(jpegData: Data) {
        self.jpegData = jpegData
    }

    let isOnlyDestinationForImage: Bool = false
    let availableRepresentations: CameraInitiatedTransferRepresentation = .preview
    let fileNameHint: String? = nil

    func contains(_ representation: CameraInitiatedTransferRepresentation) -> Bool {
        return availableRepresentations.contains(representation)
    }

    func suggestedFileNameExtension(for representation: CameraInitiatedTransferRepresentation) -> String? {
        guard representation == .preview else { return nil }
        return "JPG"
    }

    func uti(for representation: CameraInitiatedTransferRepresentation) -> String? {
        guard representation == .preview else { return nil }
        #if os(Windows)
        return "public.jpeg"
        #else
        if #available(iOS 14, macCatalyst 14.0, macOS 11.0, *) {
            return UTType.jpeg.identifier
        } else {
            return kUTTypeJPEG as String
        }
        #endif
    }

    func write(_ representation: CameraInitiatedTransferRepresentation,
               to destinationUrl: URL,
               completionHandler: @escaping ErrorableOperationCallback) {
        guard representation == .preview else {
            completionHandler(NSError(cblErrorCode: .invalidInput))
            return
        }

        do {
            try FileManager.default.createDirectory(at: destinationUrl.deletingLastPathComponent(),
                                                    withIntermediateDirectories: true)
            try jpegData.write(to: destinationUrl, options: [.atomic])
            completionHandler(nil)
        } catch {
            completionHandler(error)
        }
    }

    func generateData(for representation: CameraInitiatedTransferRepresentation, completionHandler: @escaping (Data?, Error?) -> Void) {
        guard representation == .preview else {
            completionHandler(nil, NSError(cblErrorCode: .invalidInput))
            return
        }
        completionHandler(jpegData, nil)
    }

    func generatePreviewImage(completionHandler: @escaping (PlatformImageType?, Error?) -> Void) {
        guard availableRepresentations.contains(.preview) else {
            completionHandler(nil, NSError(cblErrorCode: .noThumbnail))
            return
        }
        let image = PlatformImageType(data: jpegData)
        completionHandler(image, nil)
    }
}

protocol SimulatedCameraDelegate: AnyObject {
    func simulatedCameraDidDisconnect(_ camera: SimulatedCamera)
}

class SimulatedCamera: NSObject, Camera {

    init(configuration: SimulatedCameraConfiguration, clientName: String, transport: CameraTransport) {
        let info = SimulatedCameraInfo(configuration: configuration, clientName: clientName, transport: transport)
        self.deviceInfo = info
        self.service = info
        self.cameraTransport = transport
        self.configuration = configuration
    }

    weak var simulatedCameraDelegate: SimulatedCameraDelegate?

    let friendlyIdentifier: String? = "se.cascable.simulated-camera"

    dynamic var connected: Bool = false

    let deviceInfo: DeviceInfo?
    let service: CameraDiscoveryService
    let cameraTransport: CameraTransport
    let configuration: SimulatedCameraConfiguration

    let cameraFamily = SimulatedCameraFamily

    var friendlyDisplayName: String? {
        get {
            return deviceInfo?.model
        }
    }

    dynamic var connectionState = ConnectionState.notConnected {
        didSet {
            connected = (connectionState == .connected)
        }
    }

    var disconnectionWasExpected: Bool = false

    var connectionWarnings: [ConnectionWarning]? = [ConnectionWarning]()

    func connect(authenticationRequestCallback: @escaping CameraAuthenticationRequestBlock,
                 authenticationResolvedCallback: @escaping CameraAuthenticationResolvedBlock,
                 completionCallback callback: @escaping ConnectionCompleteCallback) {
        connect(flags: nil, authenticationRequestCallback: authenticationRequestCallback,
                authenticationResolvedCallback: authenticationResolvedCallback,
                completionCallback: callback)
    }

    func connect(flags: [String : Any]?, authenticationRequestCallback: @escaping CameraAuthenticationRequestBlock,
                 authenticationResolvedCallback: @escaping CameraAuthenticationResolvedBlock,
                 completionCallback callback: @escaping ConnectionCompleteCallback) {

        if connectionState != .notConnected {
            callback(nil, nil)
            return
        }

        connectionState = .connectionInProgress
        let loadingPropertiesTime: TimeInterval = (configuration.connectionSpeed.smallOperationDuration * 20.0)
        var didCancelAuth: Bool = false

        let completeConnection = {
            guard !didCancelAuth else { return }
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + loadingPropertiesTime) {

                //self.willChangeValue(for: \.knownPropertyIdentifiers)
                let bundle = Bundle.forLocalizations

                self.immediatelySetValue(of: .batteryLevel,
                                         to: .init(commonValue: PropertyCommonValueBatteryLevel.full.rawValue,
                                                   localizedDisplayValue: "100%"))
                self.immediatelySetValue(of: .powerSource,
                                         to:  .init(commonValue: PropertyCommonValuePowerSource.mainsPower.rawValue,
                                                    localizedDisplayValue: bundle.localizedString(forKey: "ExternalPower", value: nil, table: "SonyPTPPowerSources")))

                self.immediatelySetValue(of: .shotsAvailable, to: .init(commonValue: 100, localizedDisplayValue: "100"))

                let focusModes = self.createFocusModeValues()
                self.immediatelySetValue(of: .focusMode, to: focusModes.defaultValue, in: focusModes.validValues)

                let afSystems = self.createAFSystemValues()
                self.immediatelySetValue(of: .afSystem, to: afSystems.defaultValue, in: afSystems.validValues)

                let driveModes = self.createDriveModeValues()
                self.immediatelySetValue(of: .driveMode, to: driveModes.defaultValue, in: driveModes.validValues)

                let whiteBalances = self.createWhiteBalanceValues()
                self.immediatelySetValue(of: .whiteBalance, to: whiteBalances.defaultValue, in: whiteBalances.validValues)

                let aeModes = self.createAEModeValues()
                self.immediatelySetValue(of: .autoExposureMode, to: aeModes.defaultValue, in: aeModes.validValues)

                let ISOs = [ISOValue.automaticISO, ISOValue.iso100, ISOValue.iso200, ISOValue.iso400, ISOValue.iso800, ISOValue.iso1600]
                self.immediatelySetValue(of: .isoSpeed, to: SimulatedExposurePropertyValue(ISOValue.iso100),
                                         in: ISOs.map({ SimulatedExposurePropertyValue($0) }))

                self.handleChangeOfAutoExposureMode()

                // We need to observe the AE mode to adjust available exposure settings.
                self.aeModeObserver = self.property(with: .autoExposureMode).addObserver({ [weak self] _, type in
                    guard type.contains(.value) else { return }
                    self?.handleChangeOfAutoExposureMode()
                })

                //self.didChangeValue(for: \.knownPropertyIdentifiers)

                var warnings: [SimulatedConnectionWarning]? = nil
                if let cameraSyncValue = flags?[CBLConnectionFlagSyncCameraClockToSystemClock] as? NSNumber {
                    if cameraSyncValue.boolValue {
                        warnings = [SimulatedConnectionWarning(category: .misc, type: .clockSyncNotSupported)]
                    }
                }

                if let url = self.configuration.storageFileSystemRoot {
                    self.storageDevices = [SimulatedCameraStorage(camera: self, rootFolder: url)]
                    switch self.configuration.fileSystemAccess {
                    case .alongsideRemoteShooting:
                        self.currentCommandCategories = [.stillsShooting, .filesystemAccess]
                    case .exclusivelyOfRemoteShooting:
                        self.currentCommandCategories = .stillsShooting
                    }
                } else {
                    self.currentCommandCategories = .stillsShooting
                }

                self.connectionWarnings = warnings
                self.connectionState = .connected
                callback(nil, warnings)
            }
        }

        if case .none = configuration.connectionAuthentication {
            completeConnection()
            return
        }

        var canAcceptAuthSubmission: Bool = true

        let cancel = {
            guard canAcceptAuthSubmission else { return }
            canAcceptAuthSubmission = false
            authenticationResolvedCallback()
            didCancelAuth = true
            self.connectionState = .notConnected
            callback(NSError(cblErrorCode: .cancelledByUser), nil)
        }

        let initialContext = SimulatedCameraAuthenticationContext(identifier: configuration.identifier,
                                                                  simulatedAuthType: configuration.connectionAuthentication,
                                                                  isRetry: false,
                                                                  cancellationHandler: cancel,
                                                                  submitSuccessHandler: { success in
            guard canAcceptAuthSubmission else { return }
            canAcceptAuthSubmission = false
            authenticationResolvedCallback()
            if success {
                completeConnection()
            } else {
                let retryContext = SimulatedCameraAuthenticationContext(identifier: self.configuration.identifier,
                                                                        simulatedAuthType: self.configuration.connectionAuthentication,
                                                                        isRetry: true,
                                                                        cancellationHandler: cancel,
                                                                        submitSuccessHandler: { retrySuccess in
                    guard canAcceptAuthSubmission else { return }
                    canAcceptAuthSubmission = false
                    authenticationResolvedCallback()
                    if retrySuccess {
                        completeConnection()
                    } else {
                        callback(NSError(cblErrorCode: .connectionAuthenticationFailed), nil)
                    }
                })

                DispatchQueue.main.asyncAfter(deadline: .now() + self.configuration.connectionSpeed.smallOperationDuration) {
                    canAcceptAuthSubmission = true
                    authenticationRequestCallback(retryContext)
                }
            }
        })

        DispatchQueue.main.asyncAfter(deadline: .now() + configuration.connectionSpeed.smallOperationDuration) {
            canAcceptAuthSubmission = true
            authenticationRequestCallback(initialContext)
        }

        // If the authentication is an on-camera pair, simulate the user accepting on the camera after a few seconds.
        if case .pairOnCamera = configuration.connectionAuthentication {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                guard canAcceptAuthSubmission else { return }
                canAcceptAuthSubmission = false
                authenticationResolvedCallback()
                completeConnection()
            }
        }
    }

    func disconnect(withFlags flags: [String : Any]?, completionCallback callback: ErrorableOperationCallback?, callbackQueue queue: DispatchQueue?) {
        disconnect(callback, callbackQueue: queue)
    }

    func disconnect(_ callback: ErrorableOperationCallback?, callbackQueue queue: DispatchQueue?) {

        if connectionState == .notConnected {
            callback?(nil)
            return
        }

        connectionState = .disconnectionInProgress
        let queue = queue ?? .main

        endStream(on: queue) { error in
            self.disconnectionWasExpected = true
            let time: Double = self.configuration.connectionSpeed.mediumOperationDuration
            queue.asyncAfter(deadline: DispatchTime.now() + time) {
                self.endSimulatedVideoRecording()
                self.connectionState = .notConnected
                callback?(nil)
                self.simulatedCameraDelegate?.simulatedCameraDidDisconnect(self)
                self.disconnectionWasExpected = false
            }
        }
    }

    let supportedFunctionality: SupportedFunctionality = [.remoteControlWithoutLiveView, .depthOfFieldPreview, .videoRecording,
                                                          .shutterHalfPress, .exposureControl, .cameraInitiatedTransfer]

    func supportsFunctionality(_ functionality: SupportedFunctionality) -> Bool {
        return supportedFunctionality.contains(functionality)
    }

    private(set) dynamic var currentCommandCategories: AvailableCommandCategory = [.stillsShooting]

    func currentCommandCategoriesContains(_ category: AvailableCommandCategory) -> Bool {
        return currentCommandCategories.contains(category)
    }

    private var supportedCommandCategories: [AvailableCommandCategory] {
        if (storageDevices ?? []).isEmpty {
            return [[.stillsShooting], [.videoRecording]]
        } else {
            switch configuration.fileSystemAccess {
            case .alongsideRemoteShooting:
                return [[.stillsShooting, .filesystemAccess], [.videoRecording, .filesystemAccess]]
            case .exclusivelyOfRemoteShooting:
                return [[.stillsShooting], [.videoRecording], [.filesystemAccess]]
            }
        }
    }

    func supportsCommandCategories(_ categories: AvailableCommandCategory) -> Bool {
        return supportedCommandCategories.contains(categories)
    }

    func setCurrentCommandCategories(_ categories: AvailableCommandCategory, completionCallback block: @escaping ErrorableOperationCallback) {
        if supportsCommandCategories(categories) {
            guard !currentCommandCategoriesContains(categories) else {
                block(nil)
                return
            }

            let switchDuration = configuration.connectionSpeed.largeOperationDuration
            let changeCategories = {
                self.currentCommandCategories = categories
                block(nil)
            }

            // This is a bit sneaky - rather than chaining it in, we just perform it with a shorter duration than the switch.
            if isRecordingVideo, !categories.contains(.videoRecording) {
                DispatchQueue.main.asyncAfter(deadline: .now() + configuration.connectionSpeed.smallOperationDuration) {
                    self.endSimulatedVideoRecording()
                }
            }

            if (!categories.contains(.stillsShooting) && !categories.contains(.videoRecording)) && liveViewStreamActive {
                endStream(handler: { _ in
                    DispatchQueue.main.asyncAfter(deadline: .now() + switchDuration, execute: changeCategories)
                })
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + switchDuration, execute: changeCategories)
            }

        } else {
            block(NSError(cblErrorCode: .incorrectCommandCategory))
        }
    }

    let autoexposureResult: AEResult? = nil

    func updateClock(to date: Date, completionCallback block: ErrorableOperationCallback? = nil) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + configuration.connectionSpeed.mediumOperationDuration) {
            block?(nil)
        }
    }

    //MARK: - Live View

    dynamic var liveViewStreamActive: Bool = false
    private var terminationHandler: LiveViewTerminationHandler?
    private var lvDelivery: LiveViewFrameDelivery?
    private var lvDeliveryQueue: DispatchQueue?
    private var liveViewDeliveryTimer: Timer?

    func setLiveViewCrop(_ cropRect: CGRect, completionCallback block: ErrorableOperationCallback? = nil) {
        block?(NSError(cblErrorCode: .notAvailable))
    }

    func resetLiveViewCrop(_ block: ErrorableOperationCallback? = nil) {
        block?(NSError(cblErrorCode: .notAvailable))
    }

    func setLiveViewZoomCenterPoint(_ centerPoint: CGPoint, completionCallback block: ErrorableOperationCallback? = nil) {
        block?(NSError(cblErrorCode: .notAvailable))
    }

    private func resetLiveViewState(reason: LiveViewTerminationReason) {
        liveViewDeliveryTimer?.invalidate()
        liveViewDeliveryTimer = nil
        lvDelivery = nil
        lvDeliveryQueue = nil
        terminationHandler?(reason, nil)
        terminationHandler = nil
        liveViewStreamActive = false
    }

    func beginStream(delivery: @escaping LiveViewFrameDelivery, deliveryQueue: DispatchQueue?, terminationHandler: @escaping LiveViewTerminationHandler) {
        beginStream(delivery: delivery, deliveryQueue: deliveryQueue, options: nil, terminationHandler: terminationHandler)
    }

    struct LiveViewFrameData {
        let data: Data
        let size: CGSize
    }

    func beginStream(delivery: @escaping LiveViewFrameDelivery, deliveryQueue: DispatchQueue?, options: [String : Any]? = nil, terminationHandler: @escaping LiveViewTerminationHandler) {

        guard currentCommandCategoriesContains(.stillsShooting) || currentCommandCategoriesContains(.videoRecording) else {
            terminationHandler(.failed, NSError(cblErrorCode: .incorrectCommandCategory))
            return
        }

        if liveViewStreamActive {
            terminationHandler(.alreadyStreaming, nil)
            return
        }

        let imageUrls = configuration.liveViewImageFrames
        let operationDuration = configuration.connectionSpeed.largeOperationDuration

        // Off the main queue to load the files.
        DispatchQueue.global(qos: .userInitiated).async {

            let frames: [LiveViewFrameData] = imageUrls.compactMap({ url in
                #if os(Windows)
                // We don't have Core Graphics on Windows. TODO: Find an alternative.
                guard let imageData = try? Data(contentsOf: url) else { return nil }
                let width: Int = 864
                let height: Int = 576
                #else
                guard let imageData = try? Data(contentsOf: url),
                      let source = CGImageSourceCreateWithData(imageData as CFData, nil),
                      let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [String : AnyObject] else {
                    return nil
                }

                guard let width = (properties[kCGImagePropertyPixelWidth as String] as? NSNumber)?.intValue,
                      let height = (properties[kCGImagePropertyPixelHeight as String] as? NSNumber)?.intValue else {
                    return nil
                }
                #endif

                return LiveViewFrameData(data: imageData, size: CGSize(width: width, height: height))
            })

            // Back onto the main queue to set up state and schedule the timer.
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + operationDuration) {

                guard !frames.isEmpty else {
                    terminationHandler(.failed, NSError(cblErrorCode: .invalidInput))
                    return
                }

                let queue = deliveryQueue ?? .main
                self.lvDelivery = delivery
                self.lvDeliveryQueue = queue
                self.terminationHandler = terminationHandler
                self.liveViewStreamActive = true

                let shouldSkipDecodingImages = options?[CBLLiveViewOptionSkipImageDecoding] as? Bool ?? false
                self.shouldDecodeLiveViewImages = !shouldSkipDecodingImages

                var frameIndex: Int = 0

                self.hasReceivedLiveViewFrameReadySignal = true
                let timer = Timer(timeInterval: 1.0 / 30.0, repeats: true, block: { timer in
                    guard self.hasReceivedLiveViewFrameReadySignal else { return }
                    let queue = self.lvDeliveryQueue ?? .main
                    guard let delivery = self.lvDelivery else { return }
                    self.hasReceivedLiveViewFrameReadySignal = false
                    let frame = frames[frameIndex]
                    let decodeFrame = self.shouldDecodeLiveViewImages
                    frameIndex += 1
                    if frameIndex >= frames.count { frameIndex = 0 }

                    // We should make the frame off the main thread in case we need to decode the image.
                    DispatchQueue.global(qos: .userInitiated).async {
                        let simulatedFrame = SimulatedLiveViewFrame(with: frame.data, of: frame.size, decodeImage: decodeFrame)
                        //…but actually deliver the frame on the queue we're asked to.
                        queue.async { delivery(simulatedFrame, { self.hasReceivedLiveViewFrameReadySignal = true }) }
                    }
                })

                self.liveViewDeliveryTimer = timer
                RunLoop.main.add(timer, forMode: .common)
            }
        }
    }

    private var hasReceivedLiveViewFrameReadySignal: Bool = false
    private var shouldDecodeLiveViewImages: Bool = false

    func applyStreamOptions(_ options: [String : Any] = [:]) {
        let shouldSkipDecodingImages = options[CBLLiveViewOptionSkipImageDecoding] as? Bool ?? false
        shouldDecodeLiveViewImages = !shouldSkipDecodingImages
    }

    func endStream() {
        endStream(handler: nil)
    }

    private func endStream(on callbackQueue: DispatchQueue = .main, handler: ErrorableOperationCallback?) {
        let time: Double = configuration.connectionSpeed.largeOperationDuration
        callbackQueue.asyncAfter(deadline: DispatchTime.now() + time) {
            self.resetLiveViewState(reason: .endedNormally)
            handler?(nil)
        }
    }

    // MARK: - Modern Property API

    var knownPropertyIdentifiers: [NSNumber] {
        return propertyStore.keys.map({ NSNumber(value: $0.rawValue) })
    }

    func property(with identifier: PropertyIdentifier) -> CameraProperty {
        if let store = propertyStore[identifier] { return store }
        let propertyType: PropertyValueSetType = {
            guard identifier.category == .exposureSetting else { return .enumeration }
            return (configuration.exposurePropertyType == .enumerated ? .enumeration : .stepping)
        }()
        let newStore = SimulatedCameraProperty.create(for: identifier, named: localizedDisplayName(forProperty: identifier),
                                                      valueSetType: propertyType, on: self)
        propertyStore[identifier] = newStore
        return newStore
    }

    func populatedProperties(in category: PropertyCategory) -> [CameraProperty] {
        return category.propertyIdentifiers.compactMap({ property(with: $0) }).filter({ $0.currentValue != nil })
    }

    // MARK: - Property Internal

    private var propertyStore = [PropertyIdentifier : SimulatedCameraProperty]()
    //{
        //willSet { willChangeValue(for: \.knownPropertyIdentifiers) }
        //didSet { didChangeValue(for: \.knownPropertyIdentifiers) }
    //}

    private func immediatelySetValue(of identifier: PropertyIdentifier, to value: SimulatedPropertyValue?,
                                     in settableValues: [SimulatedPropertyValue]? = nil) {
        let property = property(with: identifier) as? SimulatedCameraProperty
        if let settableValues {
            property?.immediatelySetValue(to: value, in: settableValues)
        } else {
            property?.immediatelySetValue(to: value)
        }
    }

    private var aeModeObserver: CameraPropertyObservation? = nil

    private func handleChangeOfAutoExposureMode() {

        let exposureMode = PropertyCommonValueAutoExposureMode(rawValue: property(with: .autoExposureMode).currentValue?.commonValue ??
                                                               PropertyCommonValueAutoExposureMode.programAuto.rawValue) ?? .programAuto

        // If the existing value for a property is valid for the new values, keep it. Otherwise, use the default value.
        func valueToSet(for property: CameraProperty, from newValues: PropertyValuesWithSuggestedDefault) -> SimulatedPropertyValue? {
            guard let exposureProperty = property as? ExposureProperty else { return newValues.defaultValue }
            guard let existing = exposureProperty.currentExposureValue else { return newValues.defaultValue }
            guard let valid = newValues.validValues as? [ExposurePropertyValue] else { return newValues.defaultValue }
            if valid.contains(where: { $0.exposureValue.isEqual(existing.exposureValue) }) {
                return existing as? SimulatedPropertyValue
            } else {
                return newValues.defaultValue
            }
        }

        let evValues = createExposureCompensationValues(for: exposureMode)
        immediatelySetValue(of: .exposureCompensation,
                            to: valueToSet(for: property(with: .exposureCompensation), from: evValues),
                            in: evValues.validValues)

        do {
            let apertureValues = try createApertureValues(for: exposureMode)
            immediatelySetValue(of: .aperture,
                                to: valueToSet(for: property(with: .aperture), from: apertureValues),
                                in: apertureValues.validValues)
        } catch {}

        do {
            let shutterValues = try createShutterSpeedValues(for: exposureMode)
            immediatelySetValue(of: .shutterSpeed,
                                to: valueToSet(for: property(with: .shutterSpeed), from: shutterValues),
                                in: shutterValues.validValues)
        } catch {}
    }

    //MARK: - Storage

    dynamic var storageDevices: [FileStorage]? = nil

    // MARK: - AF

    let focusInfo: FocusInfo? = nil

    func setActiveAutoFocusPoint(_ point: FocusPoint, completionCallback block: ErrorableOperationCallback?) {
        block?(NSError(domain: CascableCoreErrorDomain, code: Int(CascableCoreErrorCode.notAvailable.rawValue), userInfo: nil))
    }

    let supportsTouchAF: Bool = false

    func touchAF(at center: CGPoint, completionCallback block: ErrorableOperationCallback?) {
        block?(NSError(domain: CascableCoreErrorDomain, code: Int(CascableCoreErrorCode.notAvailable.rawValue), userInfo: nil))
    }

    func driveFocus(amount: FocusDriveAmount, direction: FocusDriveDirection, completionCallback callback: ErrorableOperationCallback? = nil) {
        callback?(NSError(cblErrorCode: .notAvailable))
    }

    // MARK: - Engaging AF & Shutter

    dynamic var autoFocusEngaged: Bool = false

    func engageAutoFocus(_ block: ErrorableOperationCallback?) {
        guard currentCommandCategoriesContains(.stillsShooting) else {
            block?(NSError(cblErrorCode: .incorrectCommandCategory))
            return
        }

        if (autoFocusEngaged) {
            block?(nil)
            return
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + configuration.connectionSpeed.largeOperationDuration) {
            self.autoFocusEngaged = true
            block?(nil)
        }
    }

    func disengageAutoFocus(_ block: ErrorableOperationCallback?) {
        guard currentCommandCategoriesContains(.stillsShooting) else {
            block?(NSError(cblErrorCode: .incorrectCommandCategory))
            return
        }

        if (!autoFocusEngaged) {
            block?(nil)
            return
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + configuration.connectionSpeed.smallOperationDuration) {
            self.autoFocusEngaged = false
            block?(nil)
        }
    }

    dynamic var shutterEngaged: Bool = false

    func engageShutter(_ block: ErrorableOperationCallback?) {
        guard currentCommandCategoriesContains(.stillsShooting) else {
            block?(NSError(cblErrorCode: .incorrectCommandCategory))
            return
        }

        if (shutterEngaged) {
            block?(nil)
            return
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + configuration.connectionSpeed.largeOperationDuration) {
            self.shutterEngaged = true
            block?(nil)
        }
    }

    func disengageShutter(_ block: ErrorableOperationCallback?) {
        guard currentCommandCategoriesContains(.stillsShooting) else {
            block?(NSError(cblErrorCode: .incorrectCommandCategory))
            return
        }

        if (!shutterEngaged) {
            block?(nil)
            return
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + configuration.connectionSpeed.smallOperationDuration) {
            self.shutterEngaged = false
            block?(nil)

            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
                self.triggerShotPreview()
            }
        }
    }

    func invokeOneShotShutterExplicitlyEngagingAutoFocus(_ triggerAutoFocus: Bool, completionCallback block: ErrorableOperationCallback?) {
        guard currentCommandCategoriesContains(.stillsShooting) else {
            block?(NSError(cblErrorCode: .incorrectCommandCategory))
            return
        }

        DispatchQueue.main.async {
            block?(nil)

            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
                self.triggerShotPreview()
            }
        }
    }

    //MARK: - Video

    dynamic private(set) var isRecordingVideo: Bool = false
    dynamic private(set) var currentVideoTimerValue: VideoTimerValue? = nil

    func startVideoRecording(_ completionHandler: ErrorableOperationCallback? = nil) {
        guard !isRecordingVideo else {
            completionHandler?(NSError(cblErrorCode: .videoRecordingInProgress))
            return
        }

        guard currentCommandCategoriesContains(.videoRecording) else {
            completionHandler?(NSError(cblErrorCode: .incorrectCommandCategory))
            return
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + configuration.connectionSpeed.largeOperationDuration) {
            self.startSimulatedVideoRecording()
            completionHandler?(nil)
        }
    }

    func endVideoRecording(_ completionHandler: ErrorableOperationCallback? = nil) {
        guard currentCommandCategoriesContains(.videoRecording) else {
            completionHandler?(NSError(cblErrorCode: .incorrectCommandCategory))
            return
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + configuration.connectionSpeed.largeOperationDuration) {
            self.endSimulatedVideoRecording()
            completionHandler?(nil)
        }
    }

    private var videoRecordingTimer: Timer? = nil

    private func startSimulatedVideoRecording() {
        endSimulatedVideoRecording()

        let recordingStartDate = Date()
        let timer = Timer(timeInterval: 1.0, repeats: true, block: { [weak self] _ in
            guard let self, self.isRecordingVideo else { return }
            let now = Date()
            let interval = now.timeIntervalSince(recordingStartDate).rounded()
            self.currentVideoTimerValue = SimulatedVideoTimerValue(type: .countingUp, value: interval)
        })
        RunLoop.main.add(timer, forMode: .common)
        videoRecordingTimer = timer
        currentVideoTimerValue = SimulatedVideoTimerValue(type: .countingUp, value: 0.0)
        isRecordingVideo = true
    }

    private func endSimulatedVideoRecording() {
        videoRecordingTimer?.invalidate()
        videoRecordingTimer = nil
        currentVideoTimerValue = nil
        isRecordingVideo = false
    }

    //MARK: - Camera-Initiated Transfers

    var transferHandlers = [String: CameraInitiatedTransferRequestHandler]()

    func addCameraInitiatedTransferHandler(_ handler: @escaping CameraInitiatedTransferRequestHandler) -> String {
        let token = UUID().uuidString
        transferHandlers[token] = handler
        return token
    }

    func removeCameraInitiatedTransferHandler(with token: String) {
        transferHandlers.removeValue(forKey: token)
    }

    func triggerShotPreview() {
        guard let imageUrl = configuration.liveViewImageFrames.first else { return }
        guard let imageData = try? Data(contentsOf: imageUrl) else { return }
        let shotPreviewDelivery = SimulatedCameraInitiatedTransfer(transferring: imageData,
                                                                   connectionSpeed: configuration.connectionSpeed)
        for (_, handler) in transferHandlers {
            handler(shotPreviewDelivery)
        }
    }
}
