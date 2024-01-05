import Foundation

/// Represents a folder on a camera's storage device.
public protocol FileSystemFolderItem: FileSystemItem {

    /// Returns an array of child objects, if the folder has been loaded.
    ///
    /// @note For performance and memory reasons, storage objects to not automatically load the contents
    /// of any of its child folders - you need to iterate the filesystem in a manner that best fits your application.
    var children: [FileSystemItem]? { get }

    /// Returns `true` if this item has successfully loaded its children (even if it has no children), otherwise `false`.
    ///
    /// @note For performance and memory reasons, storage objects to not automatically load the contents
    /// of any of its child folders - you need to iterate the filesystem in a manner that best fits your application.
    var childrenLoaded: Bool { get }

    /// Returns `true` if this item is currently in the process of loading its children.
    var childrenLoading: Bool { get }

    /// Attempt to load the item's children.
    ///
    /// @note For performance and memory reasons, storage objects to not automatically load the contents
    /// of any of its child folders - you need to iterate the filesystem in a manner that best fits your application.
    ///
    /// @param callback The callback to trigger when the operation succeeds (or fails).
    func loadChildren(_ completionHandler: @escaping ErrorableOperationCallback)
}
