import Foundation

/// Representations of an image.
public struct CameraInitiatedTransferRepresentation: OptionSet {
    public let rawValue: Int
    public init(rawValue: Int) { self.rawValue = rawValue }

    /// A reduced size/quality preview representation of the image, usually in JPEG or HEIC format.
    public static let preview = CameraInitiatedTransferRepresentation(rawValue: 1 << 0)
    /// The original image file.
    public static let original = CameraInitiatedTransferRepresentation(rawValue: 1 << 1)
}

/// States that a camera-initiated transfer can be in.
public enum CameraInitiatedTransferState: Int {
    /// The transfer has not yet started.
    case notStarted
    /// The transfer is in progress.
    case inProgress
    /// The transfer has completed.
    case complete
}

/// The block callback signature for handling the result of a request to execute a camera-initiated transfer, containing
/// either the result of the transfer, or an error describing the failure.
public typealias CameraInitiatedTransferCompletionHandler = (CameraInitiatedTransferResult?, Error?) -> Void

/// A camera-initiated transfer is a request from a camera to transfer an image file (or at least, a representation of
/// one such as a preview) to the connected host. This typically happens soon after a shot is taken, and can allow the
/// previewing and transferring of images even if the camera currently doesn't allow access to its storage.
///
/// Camera-initiated transfers can be time-sensitive as the camera moves on to newer images or flushes buffers — they
/// should be dealt with expediently.
///
/// In some cases, the camera-initiated transfer to the host may be the _only_ destination for an image. Commonly
/// referred to as "tethered shooting" (or at least a variant of it), the camera might not attempt (or not be able to)
/// save the image to its own storage. If this is the case, not correctly handling a camera-initiated transfer will
/// case data loss. Check the `-isOnlyDestinationForImage` property — if that returns `YES`, not transferring and
/// saving the original representation of the image will cause it to be lost.
public protocol CameraInitiatedTransferRequest {

    /// Returns `YES` if the transfer request is still valid, otherwise `NO`. Transfers will time out after some amount
    /// of time.
    var isValid: Bool { get }

    /// Returns `YES` if not executing this camera-initiated transfer may cause data loss. For example, a camera
    /// set to only save images to the connected host would set this to `YES`.
    var isOnlyDestinationForImage: Bool { get }

    /// Returns `YES` if not executing this camera-initiated transfer will "clog up" the camera's transfer buffer. This
    /// can return `YES` independently of the `isOnlyDestinationForImage` property. Not executing transfers that have this
    /// property set will stop delivery of further transfers.
    var executionRequiredToClearBuffer: Bool { get }

    /// Returns the source image's file name, if available. Not guaranteed to exactly match the name on the camera's storage.
    /// This value may not be available until the transfer completes (or at all) — see `CBLCameraInitiatedTransferResult`.
    var fileNameHint: String? { get }

    /// Returns an option set of the representations available for this transfer.
    ///
    /// Common combinations are preview-only, or preview and original.
    var availableRepresentations: CameraInitiatedTransferRepresentation { get }

    /// Returns `YES` if the receiver can provide the given representation, otherwise `NO`.
    func canProvideRepresentation(_ representation: CameraInitiatedTransferRepresentation) -> Bool

    /// Returns the state of the transfer. A camera-initiated transfer can only be performed once.
    var transferState: CameraInitiatedTransferState { get }

    /// Returns the progress of the transfer, if available. While this property is marked `nonnull` for binding purposes,
    /// the values in the returned progress object are only meaningful when the transfer is in progress.
    ///
    /// Not all cameras provide progress information — in these cases, the progress will remain indeterminate.
    var transferProgress: Progress { get }

    /// Execute the camera-initiated transfer if it's still valid.
    ///
    /// If possible, CascableCore will optimise the transfer to reduce the amount of data transferred (and therefore time
    /// needed). For example, if a camera-initiated transfer request has both the preview and original representations
    /// available, CascableCore may perform a partial transfer if only the preview representation is requested. This is
    /// particularly useful if, for example, you want to show previews of RAW images.
    ///
    /// @warning A camera-initiated transfer can only be performed once.
    ///
    /// @param representations The representations to transfer from the camera. Must be present in the
    ///                        `availableRepresentations` property.
    /// @param completionHandler The completion handler, to be called on the main queue, when the transfer succeeds or fails.
    func executeTransfer(for representations: CameraInitiatedTransferRepresentation,
                        completionHandler: CameraInitiatedTransferCompletionHandler)

    /// Execute the camera-initiated transfer if it's still valid.
    ///
    /// If possible, CascableCore will optimise the transfer to reduce the amount of data transferred (and therefore time
    /// needed). For example, if a camera-initiated transfer request has both the preview and original representations
    /// available, CascableCore may perform a partial transfer if only the preview representation is requested. This is
    /// particularly useful if, for example, you want to show previews of RAW images.
    ///
    /// @warning A camera-initiated transfer can only be performed once.
    ///
    /// @param representations The representations to transfer from the camera. Must be present in the
    ///                        `availableRepresentations` property.
    /// @param completionQueue The queue on which to deliver the completion handler.
    /// @param completionHandler The completion handler to be calle when the transfer succeeds or fails.
    func executeTransfer(for representations: CameraInitiatedTransferRepresentation,
                        completionQueue: DispatchQueue,
                        completionHandler: CameraInitiatedTransferCompletionHandler)
}

/// The result of a camera-initiated transfer.
///
/// Result objects are stored entirely locally, and as such are not under the time pressure that the intial camera-
/// initiated transfer object is. However, they can be fairly resource heavy (especially when the transfer is of a
/// RAW image) so it's recommended that they are dealt with reasonably quickly.
///
/// How this object manages its resources is an implementation detail, and any buffers of cache files it creates will
/// be cleaned up when the object is deallocated. To take ownership of the transfer result, use the appropriate methods
/// to extract representations into RAM or to disk.
public protocol CameraInitiatedTransferResult {

    /// The representations available in this transfer result.
    var availableRepresentations: CameraInitiatedTransferRepresentation { get }

    /// Returns `YES` if the receiver can provide the given representation, otherwise `NO`.
    func containsRepresentation(_ representation: CameraInitiatedTransferRepresentation) -> Bool

    /// Returns `YES` if not saving the contents of this result may cause data loss. For example, a camera
    /// set to only save images to the connected host would set this to `YES`.
    var isOnlyDestinationForImage: Bool { get }

    /// A file name hint for the original representation of the image, if available.
    var fileNameHint: String? { get }

    /// Returns a suggested file name extension for the given representation or `nil` if the representation isn't available.
    ///
    /// To match camera conventions, extensions will be uppercase ("JPG", "CR3", "ARW", "HEIC", etc).
    ///
    /// @warning You must only pass a single representation to this method, otherwise `nil` will be returned.
    ///
    /// @note This method is guaranteed to return a valid value as long as the representation is available. This can be
    ///       useful if the `fileNameHint` property is `nil` and you need to write a representation to disk.
    func suggestedFileNameExtension(for representation: CameraInitiatedTransferRepresentation) -> String?

    /// Returns the type UTI for the given representation, or `nil` if the representation isn't available.
    ///
    /// @warning You must only pass a single representation to this method, otherwise `nil` will be returned.
    ///
    /// @note This method may fall back to returning `kUTTypeData` if the representation is in a RAW image format
    /// not recognised by the operating system.
    func uti(for representation: CameraInitiatedTransferRepresentation) -> String?

    /// Write the given representation to disk.
    ///
    /// @warning You must only pass a single representation to this method, otherwise an error will be returned.
    ///
    /// @param representation The representation to write.
    /// @param destinationUrl The URL at which to write the representation. CascableCore will attempt to create the parent
    ///                       directory tree if it isn't already present.
    /// @param completionHandler The completion handler, called on the main queue, when the operation succeeds or fails.
    func write(_ representation: CameraInitiatedTransferRepresentation, to url: URL, completionHandler: ErrorableOperationCallback)

    /// Retrieve the given representation as an in-memory data object.
    ///
    /// @warning You must only pass a single representation to this method, otherwise an error will be returned.
    ///
    /// @warning This operation may fail if the representation is large enough to risk crashes due to high memory usage.
    ///          If this happens, the resulting error will have the code `CBLErrorCodeObjectTooLarge`.
    ///
    /// @param representation The representation to retrieve.
    /// @param completionHandler The completion handler, called on the main queue, when the operation succeeds or fails.
    func generateData(for representation: CameraInitiatedTransferRepresentation,
                    completionHandler: @escaping (Data?, Error?) -> Void)

    /// Generate an image from the preview representation.
    ///
    /// @note This method requires that the result contains the `CBLCameraInitiatedTransferRepresentationPreview`
    ///       representation.
    ///
    /// @param completionHandler The completion handler, called on the main queue, when the operation succeeds or fails.
    func generatePreviewImage(completionHandler: @escaping (PlatformImageType?, Error?) -> Void)
}
