import Foundation

/// Filesystem operation types for storage modified observers.
public enum FileSystemModificationOperation: UInt {
    /// The modification was of an unknown type.
    case unknown
    /// File(s) were added to the storage.
    case filesAdded
    /// File(s) were removed from the storage.
    case filesRemoved
}

/// Identifiers for camera slots.
public enum StorageSlot: Int {
    /// The numbering of the storage's slot is unknown.
    case unknown
    /// The storage is in the camera storage slot marked 'Slot 1'.
    case slot1
    /// The storage is in the camera storage slot marked 'Slot 2'.
    case slot2
}

/// A filesystem observation block.
///
/// @param storage The filesystem storage instance that the change occurred on.
/// @param modifiedFolder The folder in which the change occurred.
/// @param operation The operation that occurred.
/// @param affectedItems The items that were added or removed.
public typealias FileStorageFilesModifiedObserver = (_ storage: FileStorage,
                                                     _ modifiedFolder: FileSystemFolderItem?,
                                                     _ operation: FileSystemModificationOperation,
                                                     _ affectedItems: [FileSystemItem]?) -> Void

/// A filesystem observer token. Required to unregister an oberver.
public typealias FileStorageObserverToken = String

/// Represents a file storage container in a camera, such as an SD card.
public protocol FileStorage: AnyObject {

    /// Returns the description of the storage container as reported by the camera.
    var storageDescription: String? { get }

    /// Returns the volume label of the storage container as reported by the camera. Can be `nil`.
    var label: String? { get }

    /// Returns a name string appropriate for display to the user.
    var displayName: String? { get }

    /// Returns the free space of the storage container, in bytes.
    var availableSpace: UInt64 { get }

    /// Returns the capacity of the storage container, in bytes.
    var capacity: UInt64 { get }

    /// The physical slot the file storage object occupies.
    var slot: StorageSlot { get }

    /// Returns `YES` if the storage container allows write access, otherwise `NO`.
    var allowsWrite: Bool { get }

    /// Returns `YES` if the storage container contains images that the camera is incapable of transferring.
    ///
    /// For example, some older Panasonic models will list RAW images, but aren't capable of transferring them. These
    /// images are ignored by CascableCore, but it may lead to user confusion if they're presented with an empty list.
    ///
    /// This property can be useful to provide the user context as to why no images are available.
    var hasInaccessibleImages: Bool { get }

    /// If available, returns the overall progress of the storage device's cataloging progress.
    /// This is not neccessarily tied to any particular `loadChildren` call.
    var catalogProgress: Progress? { get }

    /// Returns the camera associated with this storage.
    var camera: Camera? { get }

    /// Returns the root directory of this storage.
    var rootDirectory: FileSystemFolderItem { get }

    /// Add an observer to the storage's filesystem.

    /// The registered observer block will be called on the main queue.
    ///
    /// @note Changes in directories that haven't had their children loaded at least once will not trigger a notification.
    ///
    /// @param observer The observer block to be called when the filesystem changes.
    /// @return Returns an observer token to be used when removing the observer.
    func addFileSystemObserver(_ observer: @escaping FileStorageFilesModifiedObserver) -> FileStorageObserverToken

    /// Remove an observer to the storage's filesystem.
    ///
    /// @note It is safe for a triggered observer block to remove itself during execution, allowing easy one-shot observations.
    ///
    /// @param observer The existing observer token to remove.
    func removeFileSystemObserver(withToken token: FileStorageObserverToken)
}