import Foundation

/// Represents an individual focus point.
public protocol FocusPoint {

    /// Returns whether the point is active or not — that is, whether the camera will use the point for autofocus.
    var active: Bool { get }

    /// Returns whether the point currently has focus.
    var hasFocus: Bool { get }

    /// Returns the rect defining this point within the parent's aspect.
    var pointRect: CGRect { get }
}

/// Represents an autofocus state of the camera.
public protocol FocusInfo {

    /// Returns the aspect of the autofocus, typically representing the area of the viewfinder.
    var aspect: CGSize { get }

    /// Returns an array of `CBLFocusPoint` instances that define the autofocus cluster.
    var points: [FocusPoint]? { get }

    /// Translates the given AF point's rect to a rect inside the target container. Useful for
    /// translating AF point rects into views, for example.
    ///
    /// @param point The AF point to translate.
    /// @param targetContainer The rect defining the bounds of the target container.
    /// @return The rect representing `point` inside `targetContainer`.
    func translateRectOfPoint(_ point: FocusPoint, toSubRectOf targetContainer: CGRect) -> CGRect
}