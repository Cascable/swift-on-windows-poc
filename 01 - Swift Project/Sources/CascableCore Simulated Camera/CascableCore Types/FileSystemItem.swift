import Foundation

/// File streaming instructions.
public enum FileStreamInstruction: UInt {
    /// Inform CascableCore to continue the streaming operation.
    case `continue`
    /// Inform CascableCore to cancel the streaming operation. This will trigger the operation's completion handler.
    case cancel
}

/// The callback block preflight signature for fetching image previews. This will be called just before an image preview
/// is about to be fetched.
///
/// This can be useful when implementing (example) a scrolling list of thumbnails — if the user is scrolling quickly,
/// you can cancel requests for thumbnails that are no longer onscreen.
///
/// @param item The filesystem item the preview will be fetched for.
/// @return Return `YES` to continue to fetch the preview, otherwise `NO` to cancel.
public typealias PreviewImagePreflight = (_ item: FileSystemItem) -> Bool

/// The callback block signature for a completed or failed image previews.
///
/// @param item The filesystem item the preview is for.
/// @param error If the operation failed, an error object that describes the failure.
/// @param imageData If the operation succeeded, JPEG data for the preview.
public typealias PreviewImageDelivery = (_ item: FileSystemItem, _ error: Error?, _ imageData: Data?) -> Void

/// The callback block preflight signature for fetching image EXIF metadata. This will be called just before the metadata
/// is about to be fetched.
///
/// This can be useful when implementing (example) a scrolling list of iamges — if the user is scrolling quickly,
/// you can cancel metadata requests for images that are no longer onscreen.
///
/// @param item The filesystem item the metadata will be fetched for.
/// @return Return `YES` to continue to fetch the metadata, otherwise `NO` to cancel.
public typealias EXIFPreflight = (_ item: FileSystemItem) -> Bool

/// The callback block signature for a completed or failed image metadata requests.
///
/// @param item The filesystem item the metadata is for.
/// @param error If the operation failed, an error object that describes the failure.
/// @param imageMetadata If the operation succeeded, ImageIO-compatible metadata.
public typealias EXIFDelivery = (_ item: FileSystemItem, _ error: Error?, _ imageMetadata: [String: Any]?) -> Void

/// The callback block preflight signature for streaming files from the camera. This will be called just before the stream
/// is about to begin.
///
/// @param item The filesystem item that will be streamed.
/// @return Return any object to use as a "context" for the operation, including `nil`. This object will be passed to chunk
///         delivery callbacks. For example, you may want to set up a file handle or data storage object here for chunks
///         to be written to later.
public typealias FileStreamPreflight = (_ item: FileSystemItem) -> Any?

/// The callback block signature for data chunk delivery when streaming files from the camera. This will be called multiple
/// times in sequence once an operation starts.
///
/// IMPORTANT: In some circumstances, this delivery block may be invoked with an empty/zero-length chunk of data. Make
/// sure your code handles this case properly. Such a delivery should not be treated as an error, and you should return
/// the desired instruction.
///
/// @param item The filesystem item being streamed.
/// @param chunk The chunk of file data delivered from the camera.
/// @param context The context object returned from the streaming preflight block.
/// @return Return `CBLFileStreamInstructionContinue` to continue the operation and get more chunks, or
///         `CBLFileStreamInstructionCancel` to cancel the operation.
public typealias FileStreamChunkDelivery = (_ item: FileSystemItem, _ chunk: Data, _ context: Any?) -> FileStreamInstruction

/// The callback block signature that will be called when a file streaming operation completes for fails.
///
/// @param item The filesystem item being streamed.
/// @param error If the operation failed (including being cancelled), an error describing the failure.
/// @param context The context object returned from the streaming preflight block.
public typealias FileStreamCompletion = (_ item: FileSystemItem, _ error: Error?, _ context: Any?) -> Void

/// A filesystem item represents a file or folder on the camera's storage.
public protocol FileSystemItem {

    /// Returns `YES` if the item's metadata has been loaded, otherwise `NO`.
    ///
    /// If metadata hasn't been loaded, many properties will return `nil` or zero values.
    var metadataLoaded: Bool { get }

    /// Returns the name of the file.
    var name: String? { get }

    /// Returns the size of the file, or zero for directories or items whose metadata hasn't been loaded.
    var size: UInt? { get }

    /// Returns the internal handle to the file.
    var handle: Any? { get }

    /// Returns `YES` if the file is protected (i.e., cannot be deleted), otherwise `NO`.
    var isProtected: Bool { get }

    /// Returns the creation date of the file, or `nil` for items whose metadata hasn't been loaded.
    var dateCreated: Date? { get }

    /// The item's rating. Follows the IPTC StarRating spec (0 = no rating, otherwise 1-5 stars).
    var rating: Int { get }

    /// Returns the parent item of this file, or `nil` if the receiver represents the root directory.
    var parent: FileSystemFolderItem? { get }

    /// Returns the storage device on which this file is placed.
    var storage: FileStorage? { get }

    /// Returns `YES` if the file is a known image type, else `NO`.
    var isKnownImageType: Bool { get }

    /// Returns `YES` if the file is a know video type, else `NO`.
    var isKnownVideoType: Bool { get }

    /// Permanently removes the file from the device.
    func removeFromDevice(_ completionHandler: ErrorableOperationCallback)

    /// Returns `YES` if removing this item could have side effects — for example, removing one image from a RAW+JPEG pair will also remove the other.
    var removalRemovesPairedItems: Bool { get }

    /// Loads the metadata for the receiver if it hasn't already been loaded.
    ///
    /// If metadata has already been loaded, the callback block will be immediately called with no error.
    ///
    /// @param block The block to trigger after loading completes or fails. Will be called on the main queue.
    func loadMetadata(_ completionHandler: ErrorableOperationCallback)

    /// Fetch the thumbnail of the given file system item.
    ///
    /// @param preflight A block that will be called when the thumbnail is about to be fetched. Return `YES` to allow the
    /// operation to continue, or `NO` to cancel.
    /// @param delivery The block that will be called when the thumbnail has successfully been fetched, or an error occurred.
    func fetchThumbnailWithPreflightBlock(_ preflight: PreviewImagePreflight,
                                        thumbnailDeliveryBlock delivery: PreviewImageDelivery)

    /// Fetch the thumbnail of the given file system item.
    ///
    /// @param preflight A block that will be called when the thumbnail is about to be fetched. Return `YES` to allow the
    /// operation to continue, or `NO` to cancel.
    /// @param delivery The block that will be called when the thumbnail has successfully been fetched, or an error occurred.
    /// @param deliveryQueue The queue on which the delivery block will be called.
    func fetchThumbnailWithPreflightBlock(_ preflight: PreviewImagePreflight,
                                        thumbnailDeliveryBlock delivery: PreviewImageDelivery,
                                        deliveryQueue: DispatchQueue)

    /// Fetch image metadata (EXIF, IPTC, etc) for the given file system item. Only works with known image types.

    /// The returned metadata is in the form of an ImageIO-compatible dictionary. See `CGImageProperties.h` for details.
    ///
    /// @param preflight A block that will be called when the metadata is about to be fetched. Return `YES` to allow the
    /// operation to continue, or `NO` to cancel.
    /// @param delivery The block that will be called when the metadata has successfully been fetched, or an error occurred.
    func fetchEXIFMetadataWithPreflightBlock(_ preflight: EXIFPreflight,
                                            metadataDeliveryBlock delivery: EXIFDelivery)

    /// Fetch image metadata (EXIF, IPTC, etc) for the given file system item. Only works with known image types.
    ///
    /// The returned metadata is in the form of an ImageIO-compatible dictionary. See `CGImageProperties.h` for details.
    ///
    /// @param preflight A block that will be called when the metadata is about to be fetched. Return `YES` to allow the
    /// operation to continue, or `NO` to cancel.
    /// @param delivery The block that will be called when the metadata has successfully been fetched, or an error occurred.
    /// @param deliveryQueue The queue on which the delivery block will be called.
    func fetchEXIFMetadataWithPreflightBlock(_ preflight: EXIFPreflight,
                                            metadataDeliveryBlock delivery: EXIFDelivery,
                                            deliveryQueue: DispatchQueue)

    /// Fetch a preview of the given file system item.
    ///
    /// @param preflight A block that will be called when the preview is about to be fetched. Return `YES` to allow the
    /// operation to continue, or `NO` to cancel.
    /// @param delivery The block that will be called when the preview has successfully been fetched, or an error occurred.
    func fetchPreviewWithPreflightBlock(_ preflight: PreviewImagePreflight,
                                        previewDeliveryBlock delivery: PreviewImageDelivery)

    /// Fetch a preview of the given file system item.
    ///
    /// @param preflight A block that will be called when the preview is about to be fetched. Return `YES` to allow the
    /// operation to continue, or `NO` to cancel.
    /// @param delivery The block that will be called when the preview has successfully been fetched, or an error occurred.
    /// @param deliveryQueue The queue on which the delivery block will be called.
    func fetchPreviewWithPreflightBlock(_ preflight: PreviewImagePreflight,
                                        previewDeliveryBlock delivery: PreviewImageDelivery,
                                        deliveryQueue: DispatchQueue)

    /// Stream a file from the device.
    ///
    /// File streaming takes place in a series of block callbacks — one to allow you to set up any state
    /// required to receive the file data, then a series of delivery callbacks containing chunks of the file,
    /// then a completion callback to allow post-stream cleanup.
    ///
    /// @warning The callback blocks will be executed on the main queue.
    ///
    /// @param preflight Block to be called exactly once before the stream is started. The value returned
    /// here will be passed as the `context` parameter of the `chunkDelivery` and `complete` blocks.
    ///
    /// @param chunkDelivery This block will be called zero or more times in succession to deliver the file's
    /// data. The `context` parameter of this block will contain the value returned in the `preflight` block.
    /// In some circumstances, this block may be invoked with an empty/zero-length chunk of data. Make sure
    /// your code handles this case properly. Such a delivery should not be treated as an error, and you
    /// should return the desired instruction as normal.
    ///
    /// @param complete Block to be called exactly once after the last data chunk has been delivered (if any).
    /// If the stream failed or was cancelled, the `error` parameter will be non-nil and you should delete
    /// anything written to disk as the file won't be complete. The `context` parameter of this block will
    /// contain the value returned in the `preflight` block.
    ///
    /// @returns Returns a progress object that can be use to track the progress of the transfer.
    func streamItemWithPreflightBlock(_ preflight: FileStreamPreflight,
                                    chunkDeliveryBlock chunkDelivery: FileStreamChunkDelivery,
                                    completeBlock complete: FileStreamCompletion) -> Progress

    /// Stream a file from the device.
    ///
    /// File streaming takes place in a series of block callbacks — one to allow you to set up any state
    /// required to receive the file data, then a series of delivery callbacks containing chunks of the file,
    /// then a completion callback to allow post-stream cleanup.
    ///
    /// @param preflight Block to be called exactly once before the stream is started. The value returned
    /// here will be passed as the `context` parameter of the `chunkDelivery` and `complete` blocks.
    ///
    /// @param preflightQueue The queue on which to execute the preflight block.
    ///
    /// @param chunkDelivery This block will be called zero or more times in succession to deliver the file's
    /// data. The `context` parameter of this block will contain the value returned in the `preflight` block.
    /// In some circumstances, this block may be invoked with an empty/zero-length chunk of data. Make sure
    /// your code handles this case properly. Such a delivery should not be treated as an error, and you
    /// should return the desired instruction as normal.
    ///
    /// @param deliveryQueue The queue on which to execute the delivery block.
    ///
    /// @param complete Block to be called exactly once after the last data chunk has been delivered (if any).
    /// If the stream failed or was cancelled, the `error` parameter will be non-nil and you should delete
    /// anything written to disk as the file won't be complete. The `context` parameter of this block will
    /// contain the value returned in the `preflight` block.
    ///
    /// @param completeQueue The queue on which to execute the completion block.
    ///
    /// @returns Returns a progress object that can be use to track the progress of the transfer.
    func streamItemWithPreflightBlock(_ preflight: FileStreamPreflight,
                                    preflightQueue: DispatchQueue,
                                    chunkDeliveryBlock chunkDelivery: FileStreamChunkDelivery,
                                    deliveryQueue: DispatchQueue,
                                    completeBlock complete: FileStreamCompletion,
                                    completeQueue: DispatchQueue) -> Progress
}
