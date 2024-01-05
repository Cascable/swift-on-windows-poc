//
//  CBLSimulatedCamera+FileSystem.swift
//  Cascable Transfer
//
//  Created by Daniel Kennett on 2018-10-04.
//  Copyright © 2018 Cascable AB. All rights reserved.
//

import Foundation
import CascableCore

class SimulatedCameraStorage: NSObject, FileStorage {

    let rootUrl: URL
    let configuration: SimulatedCameraConfiguration
    weak var camera: Camera?
    var catalogProgress: Progress? = nil

    init(camera: SimulatedCamera, rootFolder: URL) {
        self.camera = camera
        configuration = camera.configuration
        rootUrl = rootFolder
    }

    lazy var rootDirectory: FileSystemFolderItem = {
        return SimulatedCameraFolder(url: rootUrl, parent: nil, on: self)
    }()

    // MARK: - Filesystem Properties

    private func resourceValues() -> URLResourceValues? {
        let keys: Set<URLResourceKey> = [.volumeAvailableCapacityKey, .volumeTotalCapacityKey, .isWritableKey, .volumeLocalizedNameKey]
        return try? rootUrl.resourceValues(forKeys: keys)
    }

    var storageDescription: String? { return displayName }
    var label: String? { return displayName }
    var displayName: String? { return "Storage" }
    var availableSpace: UInt64 { return UInt64(resourceValues()?.volumeAvailableCapacity ?? 0) }
    var capacity: UInt64 { return UInt64(resourceValues()?.volumeTotalCapacity ?? 0) }
    var allowsWrite: Bool { return resourceValues()?.isWritable ?? false }
    var hasInaccessibleImages: Bool { return false }
    var slot: StorageSlot { return .unknown }

    // MARK: - Observers

    func addFileSystemObserver(_ observer: @escaping FileStorageFilesModifiedObserver) -> String {
        return UUID().uuidString
    }

    func removeFileSystemObserver(withToken observer: String) {

    }
}

class SimulatedCameraFolder: NSObject, FileSystemFolderItem {

    init(url: URL, parent: FileSystemFolderItem?, on storage: SimulatedCameraStorage) {
        self.storage = storage
        self.parent = parent
        self.handle = url
        self.url = url
        self.configuration = storage.configuration
    }

    // State

    let configuration: SimulatedCameraConfiguration
    var parent: FileSystemFolderItem?
    var handle: Any?
    var url: URL
    weak var storage: FileStorage?
    var rating: Int = 0

    // Filesystem State

    private func resourceValues() -> URLResourceValues? {
        let keys: Set<URLResourceKey> = [.isWritableKey, .creationDateKey, .nameKey]
        return try? url.resourceValues(forKeys: keys)
    }

    var name: String? { return resourceValues()?.name }
    var size: UInt { return 0 }
    var isProtected: Bool { return resourceValues()?.isWritable ?? true }
    var dateCreated: Date? { return resourceValues()?.creationDate }

    var isKnownImageType: Bool { return false }
    var isKnownVideoType: Bool { return false }

    // Loading children

    var children: [FileSystemItem]? = nil
    var childrenLoaded: Bool = false
    var childrenLoading: Bool = false

    func loadChildren(_ callback: @escaping ErrorableOperationCallback) {
        guard let storage = storage as? SimulatedCameraStorage, let camera = storage.camera else {
            callback(NSError(cblErrorCode: .notConnected))
            return
        }

        guard camera.currentCommandCategoriesContains(.filesystemAccess) else {
            callback(NSError(cblErrorCode: .incorrectCommandCategory))
            return
        }

        let urlToEnumerate = url
        childrenLoading = true
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + configuration.connectionSpeed.mediumOperationDuration) {
            guard let enumerator = FileManager.default.enumerator(at: urlToEnumerate,
                                                                  includingPropertiesForKeys: [.isDirectoryKey],
                                                                  options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants, .skipsPackageDescendants],
                                                                  errorHandler: nil) else
            {
                DispatchQueue.main.async {
                    self.childrenLoading = false
                    callback(NSError(cblErrorCode: .deviceBusy))
                }
                return
            }

            var newChildren: [FileSystemItem] = []
            for case let fileUrl as URL in enumerator {
                guard let properties = try? fileUrl.resourceValues(forKeys: [.isDirectoryKey]) else { continue }
                if properties.isDirectory ?? false {
                    newChildren.append(SimulatedCameraFolder(url: fileUrl, parent: self, on: storage))
                } else {
                    newChildren.append(SimulatedCameraFile(url: fileUrl, parent: self, on: storage))
                }
            }

            DispatchQueue.main.async {
                self.children = newChildren
                self.childrenLoaded = true
                self.childrenLoading = false
                callback(nil)
            }
        }
    }

    // Deleting

    func removeFromDevice(_ block: @escaping ErrorableOperationCallback) {
        block(NSError(cblErrorCode: .notAvailable))
    }

    var removalRemovesPairedItems: Bool { return false }

    // Streaming

    var metadataLoaded: Bool { return true }

    func loadMetadata(_ block: @escaping ErrorableOperationCallback) {
        block(nil)
    }

    func fetchThumbnail(preflightBlock preflight: @escaping PreviewImagePreflight, thumbnailDeliveryBlock delivery: @escaping PreviewImageDelivery) {
        fetchThumbnail(preflightBlock: preflight, thumbnailDeliveryBlock: delivery, deliveryQueue: .main)
    }

    func fetchThumbnail(preflightBlock preflight: @escaping PreviewImagePreflight, thumbnailDeliveryBlock delivery: @escaping PreviewImageDelivery, deliveryQueue: DispatchQueue) {
        let result = preflight(self)
        deliveryQueue.async {
            delivery(self, NSError(cblErrorCode: result ? .cancelledByUser : .notAvailable), nil)
        }
    }

    func fetchEXIFMetadata(preflightBlock preflight: @escaping EXIFPreflight, metadataDeliveryBlock delivery: @escaping EXIFDelivery) {
        fetchEXIFMetadata(preflightBlock: preflight, metadataDeliveryBlock: delivery, deliveryQueue: .main)
    }

    func fetchEXIFMetadata(preflightBlock preflight: @escaping EXIFPreflight, metadataDeliveryBlock delivery: @escaping EXIFDelivery, deliveryQueue: DispatchQueue) {
        let result = preflight(self)
        deliveryQueue.async {
            delivery(self, NSError(cblErrorCode: result ? .cancelledByUser : .notAvailable), nil)
        }
    }

    func fetchPreview(preflightBlock preflight: @escaping PreviewImagePreflight, previewDeliveryBlock delivery: @escaping PreviewImageDelivery) {
        fetchPreview(preflightBlock: preflight, previewDeliveryBlock: delivery, deliveryQueue: .main)
    }

    func fetchPreview(preflightBlock preflight: @escaping PreviewImagePreflight, previewDeliveryBlock delivery: @escaping PreviewImageDelivery, deliveryQueue: DispatchQueue) {
        let result = preflight(self)
        deliveryQueue.async {
            delivery(self, NSError(cblErrorCode: result ? .cancelledByUser : .notAvailable), nil)
        }
    }

    func streamItem(preflightBlock preflight: @escaping FileStreamPreflight, chunkDeliveryBlock chunkDelivery: @escaping FileStreamChunkDelivery, complete: @escaping FileStreamCompletion) -> Progress {
        return streamItem(preflightBlock: preflight, preflightQueue: .main, chunkDeliveryBlock: chunkDelivery, deliveryQueue: .main, complete: complete, complete: .main)
    }

    func streamItem(preflightBlock preflight: @escaping FileStreamPreflight, preflightQueue: DispatchQueue, chunkDeliveryBlock chunkDelivery: @escaping FileStreamChunkDelivery, deliveryQueue: DispatchQueue, complete: @escaping FileStreamCompletion, complete completeQueue: DispatchQueue) -> Progress {

        preflightQueue.async {
            let context = preflight(self)
            deliveryQueue.async {
                complete(self, NSError(cblErrorCode: .notAvailable), context)
            }
        }

        let progress = Progress(totalUnitCount: 0)
        progress.isCancellable = false
        progress.isPausable = false
        progress.kind = .file
        return progress
    }
}

class SimulatedCameraFile: NSObject, FileSystemItem {

    init(url: URL, parent: FileSystemFolderItem?, on storage: SimulatedCameraStorage) {
        self.storage = storage
        self.parent = parent
        self.handle = url
        self.url = url
        self.configuration = storage.configuration
        super.init()
        dateCreated = resourceValues()?.creationDate
    }

    let configuration: SimulatedCameraConfiguration
    var parent: FileSystemFolderItem?
    var handle: Any?
    var url: URL
    weak var storage: FileStorage?
    var rating: Int = 0

    // Filesystem State

    private func resourceValues() -> URLResourceValues? {
        let keys: Set<URLResourceKey> = [.isWritableKey, .creationDateKey, .nameKey, .fileSizeKey]
        return try? url.resourceValues(forKeys: keys)
    }

    var name: String? { return resourceValues()?.name }
    var size: UInt { return UInt(resourceValues()?.fileSize ?? 0) }
    var isProtected: Bool { return resourceValues()?.isWritable ?? true }
    var dateCreated: Date?

    let childrenLoading: Bool = false
    let childrenLoaded: Bool = false

    var isKnownImageType: Bool {
        let pathExtension = url.pathExtension.lowercased()
        return ["png", "jpg", "jpeg", "crw", "raw", "cr2", "cr3", "nef", "nrw", "arw", "orf", "rw2", "raf"].contains(pathExtension)
    }

    var isKnownVideoType: Bool {
        let pathExtension = url.pathExtension.lowercased()
        return ["mov", "mp4", "m4v", "mkv"].contains(pathExtension)
    }

    // Removal

    var removalRemovesPairedItems: Bool = false

    func removeFromDevice(_ block: @escaping ErrorableOperationCallback) {
        block(NSError(cblErrorCode: .notAvailable))
    }

    // Loading metadata

    var metadataLoaded: Bool = true
    func loadMetadata(_ block: @escaping ErrorableOperationCallback) {
        // No-op.
        block(nil)
    }

    // Streaming

    func fetchThumbnail(preflightBlock preflight: @escaping PreviewImagePreflight, thumbnailDeliveryBlock delivery: @escaping PreviewImageDelivery) {
        fetchThumbnail(preflightBlock: preflight, thumbnailDeliveryBlock: delivery, deliveryQueue: .main)
    }

    func fetchThumbnail(preflightBlock preflight: @escaping PreviewImagePreflight, thumbnailDeliveryBlock delivery: @escaping PreviewImageDelivery, deliveryQueue: DispatchQueue) {
        let result = preflight(self)

        guard let storage, let camera = storage.camera else {
            deliveryQueue.async { delivery(self, NSError(cblErrorCode: .notConnected), nil) }
            return
        }

        guard camera.currentCommandCategoriesContains(.filesystemAccess) else {
            deliveryQueue.async { delivery(self, NSError(cblErrorCode: .incorrectCommandCategory), nil) }
            return
        }

        if result {
            DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + configuration.connectionSpeed.mediumOperationDuration) {
                let thumbnail = self.loadThumbnailFromImageAtURL(self.url, maxSize: 300.0)
                deliveryQueue.async {
                    delivery(self, thumbnail == nil ? NSError(cblErrorCode: .noThumbnail) : nil, thumbnail)
                }
            }
        } else {
            deliveryQueue.async {
                delivery(self, NSError(cblErrorCode: .cancelledByUser), nil)
            }
        }
    }

    func fetchEXIFMetadata(preflightBlock preflight: @escaping EXIFPreflight, metadataDeliveryBlock delivery: @escaping EXIFDelivery) {
        fetchEXIFMetadata(preflightBlock: preflight, metadataDeliveryBlock: delivery, deliveryQueue: .main)
    }

    func fetchEXIFMetadata(preflightBlock preflight: @escaping EXIFPreflight, metadataDeliveryBlock delivery: @escaping EXIFDelivery, deliveryQueue: DispatchQueue) {
        let fileExtension = url.pathExtension
        let result = preflight(self)

        guard let storage, let camera = storage.camera else {
            deliveryQueue.async { delivery(self, NSError(cblErrorCode: .notConnected), nil) }
            return
        }

        guard camera.currentCommandCategoriesContains(.filesystemAccess) else {
            deliveryQueue.async { delivery(self, NSError(cblErrorCode: .incorrectCommandCategory), nil) }
            return
        }

        if result {
            DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + configuration.connectionSpeed.mediumOperationDuration) {
                #if os(Windows)
                deliveryQueue.async {
                    // We don't have Core Graphics on Windows. TODO: Find an alternative.
                    delivery(self, NSError(cblErrorCode: .notAvailable), nil)
                }
                #else
                var metadata: [String: Any]? = nil
                if let data = try? Data(contentsOf: self.url) {
                    if fileExtension.caseInsensitiveCompare("jpg") == .orderedSame || fileExtension.caseInsensitiveCompare("jpeg") == .orderedSame {
                        metadata = RAWImageDescription.metadata(inJPEGHeader: data)

                    } else if fileExtension.caseInsensitiveCompare("cr3") == .orderedSame {
                        metadata = ImageMetadataHelperCR3.metadata(inCR3Data: data) as? [String: Any]

                    } else {
                        // Probably another RAW.
                        let descriptions = RAWImageDescription.imageDescriptions(inRAWHeaders: data) ?? []
                        for description in descriptions {
                            if metadata == nil && (description.isValidImage || description.isMetadataOnly) {
                                if let descMetadata = description.additionalMetadata, descMetadata.count > 0 {
                                    metadata = descMetadata as? [String: Any]
                                }
                            }
                        }
                    }
                }
                deliveryQueue.async {
                    delivery(self, metadata == nil ? NSError(cblErrorCode: .noMetadata) : nil, metadata)
                }
                #endif
            }
        } else {
            deliveryQueue.async {
                delivery(self, NSError(cblErrorCode: .cancelledByUser), nil)
            }
        }
    }

    func fetchPreview(preflightBlock preflight: @escaping PreviewImagePreflight, previewDeliveryBlock delivery: @escaping PreviewImageDelivery) {
        fetchPreview(preflightBlock: preflight, previewDeliveryBlock: delivery, deliveryQueue: .main)
    }

    func fetchPreview(preflightBlock preflight: @escaping PreviewImagePreflight, previewDeliveryBlock delivery: @escaping PreviewImageDelivery, deliveryQueue: DispatchQueue) {
        let result = preflight(self)

        guard let storage, let camera = storage.camera else {
            deliveryQueue.async { delivery(self, NSError(cblErrorCode: .notConnected), nil) }
            return
        }

        guard camera.currentCommandCategoriesContains(.filesystemAccess) else {
            deliveryQueue.async { delivery(self, NSError(cblErrorCode: .incorrectCommandCategory), nil) }
            return
        }

        if result {
            DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + configuration.connectionSpeed.mediumOperationDuration) {
                let thumbnail = self.loadThumbnailFromImageAtURL(self.url, maxSize: 1200.0)
                deliveryQueue.async {
                    delivery(self, thumbnail == nil ? NSError(cblErrorCode: .noThumbnail) : nil, thumbnail)
                }
            }
        } else {
            deliveryQueue.async {
                delivery(self, NSError(cblErrorCode: .cancelledByUser), nil)
            }
        }
    }

    func streamItem(preflightBlock preflight: @escaping FileStreamPreflight, chunkDeliveryBlock chunkDelivery: @escaping FileStreamChunkDelivery, complete: @escaping FileStreamCompletion) -> Progress {
        return streamItem(preflightBlock: preflight, preflightQueue: .main, chunkDeliveryBlock: chunkDelivery, deliveryQueue: .main, complete: complete, complete: .main)
    }

    func streamItem(preflightBlock preflight: @escaping FileStreamPreflight, preflightQueue: DispatchQueue, chunkDeliveryBlock chunkDelivery: @escaping FileStreamChunkDelivery, deliveryQueue: DispatchQueue, complete: @escaping FileStreamCompletion, complete completeQueue: DispatchQueue) -> Progress {

        let progress = Progress(totalUnitCount: 0)
        progress.isCancellable = false
        progress.isPausable = false
        progress.kind = .file

        preflightQueue.async {
            let context = preflight(self)

            guard let storage = self.storage, let camera = storage.camera else {
                completeQueue.async { complete(self, NSError(cblErrorCode: .notConnected), context) }
                return
            }

            guard camera.currentCommandCategoriesContains(.filesystemAccess) else {
                completeQueue.async { complete(self, NSError(cblErrorCode: .incorrectCommandCategory), context) }
                return
            }

            guard let handle = try? FileHandle(forReadingFrom: self.url) else {
                completeQueue.async {
                    complete(self, NSError(cblErrorCode: .notAvailable), context)
                }
                return
            }

            let length = Int(handle.seekToEndOfFile())
            handle.seek(toFileOffset: 0)
            DispatchQueue.main.async { progress.completedUnitCount = Int64(length) }

            self.recursivelyDeliver(from: handle, of: length, progress: progress, context: context, to: chunkDelivery,
                                    on: deliveryQueue, then: { error in
                handle.closeFile()
                completeQueue.asyncAfter(deadline: .now() + self.configuration.connectionSpeed.smallOperationDuration) {
                    complete(self, error, context)
                }
            })
        }

        return progress
    }

    private func recursivelyDeliver(from fileHandle: FileHandle, of length: Int, progress: Progress, context: Any?, to chunkDelivery: @escaping FileStreamChunkDelivery, on deliveryQueue: DispatchQueue, then completionHandler: @escaping ((Error?) -> ())) {

        let thisChunk = fileHandle.readData(ofLength: 1024 * 1024)
        let wasLast = fileHandle.offsetInFile >= length

        deliveryQueue.asyncAfter(deadline: .now() + configuration.connectionSpeed.largeOperationDuration) {
            let result = chunkDelivery(self, thisChunk, context)
            let bytesRead = thisChunk.count
            if result == .continue { DispatchQueue.main.async { progress.totalUnitCount = Int64(bytesRead) } }
            if wasLast {
                completionHandler(nil)
            } else if result == .cancel {
                completionHandler(NSError(cblErrorCode: .cancelledByUser))
            } else {
                self.recursivelyDeliver(from: fileHandle, of: length, progress: progress, context: context,
                                        to: chunkDelivery, on: deliveryQueue, then: completionHandler)
            }
        }
    }

    // Helpers

    func loadThumbnailFromImageAtURL(_ url: URL, maxSize: CGFloat) -> Data? {
        // We don't have Core Graphics on Windows. TODO: Find an alternative.
        #if !os(Windows)
        let options: [NSObject : Any] = [
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceThumbnailMaxPixelSize: maxSize
        ]

        if let imageSource = CGImageSourceCreateWithURL(url as CFURL, nil),
            let thumbnail = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, options as CFDictionary) {
            let finalThumbnail = PlatformImageType(cgImage: thumbnail, size: CGSize.zero)
            return finalThumbnail.jpegData(compressionQuality: 0.8)
        }
        #endif

        // We should really try to manually extract the thumbnail.
        return nil
    }
}

#if canImport(UIKit)
extension UIImage {

    convenience init(cgImage: CGImage, size: CGSize) {
        self.init(cgImage: cgImage)
    }

}
#endif
