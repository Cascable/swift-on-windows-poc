import Foundation

/// Defines the orientation of the image of the live view frame. If rotating the image,
/// the focal points etc should be rotated too.
public enum LiveViewFrameOrientation: UInt {
    /// The image is "normal" landscape - no translation is required.
    case landscape = 0
    /// The camera is rotated 90° to the right.
    case portraitRight = 1
    /// The camera is rotated 90° to the left.
    case portraitLeft = 2
    /// The camera is rotated 180°.
    case landscapeUpsideDown = 4
}

/// Defines the format of the pixel data of a live view frame.
public enum LiveViewFramePixelFormat: UInt {
    /// The live view frame's pixel data is a fully-formed JPEG image.
    case jpeg = 0
    /// The live view frame's pixel data is a pixel buffer.
    case rawPixelBuffer = 1
}

/// Represents an autofocus area in a camera's focus aspect. Typically rendered as a rectangle on top of the live view image.
public protocol LiveViewAFArea {

    /// Returns `YES` if the AF area is focused, otherwise `NO`.
    var focused: Bool { get }

    /// Returns `YES` if the AF area is active, otherwise `NO`.
    var active: Bool { get }

    /// Returns the area of the receiver, relative to the parent live view frame's aspect.
    var rect: CGRect { get }
}

/// Represents a single frame of a streaming live view image, along with any associated metadata.
public protocol LiveViewFrame: AnyObject {

    /// Returns the date and time at which this frame was generated.
    var dateProduced: Date { get }

    /// Returns the logical orientation of the frame.
    var orientation: LiveViewFrameOrientation { get }

    /// Returns the angle as detected by the camera's gyros, if available.
    /// 0.0 is perfectly level in the "normal" landscape orientation. Range is 0-359.9°.
    var rollAngle: CGFloat { get }

    /// Returns the raw image data for the frame. See the `rawPixelFormat` and `rawPixelFormatDescription` properties
    /// for detailed information on the pixel format.
    ///
    /// It may be necessary to crop this image to avoid black bars. See `rawImageCropRect`.
    var rawPixelData: Data { get }

    /// Returns the broad pixel format of the data in the `rawPixelData` property. If the value is a raw pixel buffer, see
    /// the `rawPixelFormatDescription` for additional details.
    var rawPixelFormat: LiveViewFramePixelFormat { get }

    // TODO: Make a cross-platform implementation of this.
    /// Returns the detailed pixel format of the data in the `rawPixelData` property.
    //@property (nonatomic, readonly, nonnull) __attribute__((NSObject)) CMFormatDescriptionRef rawPixelFormatDescription;

    /// Returns the size of the image contained in the `rawPixelData` property, in pixels.
    var rawPixelSize: CGSize { get }

    /// Returns the rectangle with which to crop the image contained in `rawPixelData` to avoid black bars.
    var rawPixelCropRect: CGRect { get }

    /// Returns an NSImage or UIImage for this live view frame. Any required pixel format conversion and cropping will be
    /// applied for you. Due to this, the pixel size of this image may be different to the value of `rawPixelSize`.
    var image: PlatformImageType? { get }

    /// Returns the aspect in which the live view coordinate system is mapped.
    /// All geometric values returns by this class are relative to this property.
    var aspect: CGSize { get }

    /// Returns the areas defining the frame's focusing rectangles, or an empty array if no focusing rectangles are available.
    var afAreas: [LiveViewAFArea]? { get }

    /// Returns the rect defining the zoom preview rectangle (that is, a preview of the part of the image that will be seen
    /// if live view is zoomed in), or `CGRectZero` if this isn't available.
    var zoomPreviewRect: CGRect { get }

    /// Returns the smallest crop size supported by the live view stream, or `CGRectZero` if not available.
    var minimumCropSize: CGSize { get }

    /// Defines rect of this frame's image relative to the aspect. When zoomed out, this will typically be the a rectangle
    /// the same size as the frame's aspect with a zero origin. When zoomed in, this defines a subrect inside that aspect
    /// that defines where the zoomed-in image is compared to the whole frame.
    var imageFrameInAspect: CGRect { get }

    /// Returns `YES` if the live view frame is "zoomed in" (that is, the `imageFrameInAspect` property is smaller than `aspect`.
    var isZoomedIn: Bool { get }

    /// Translates the given rect inside the receiver's aspect to a rect inside the target container. Useful for
    /// translating live view rects into views, for example.
    ///
    /// @param liveViewRect The rect inside the receiver's aspect.
    /// @param targetContainer The rect defining the bounds of the target container.
    /// @return The rect representing `liveViewRect` inside `targetContainer`.
    func translateSubRectOfAspect(_ liveViewRect: CGRect, toSubRectOf targetContainer: CGRect) -> CGRect

    /// Translates the given point inside the receiver's aspect to a point inside the target container. Useful for
    /// translating live view points into views, for example.
    ///
    /// @param liveViewPoint The pont inside the receiver's aspect.
    /// @param targetContainer The rect defining the bounds of the target container.
    /// @return The point representing `liveViewPoint` inside `targetContainer`.
    func translatePointInASpect(_ liveViewPoint: CGPoint, toPointIn targetContainer: CGRect) -> CGPoint

    /// Translates the given point inside the given rect into a point inside the receiver's aspect. Useful for
    /// translating a point in a view into the live view aspect, for example.
    ///
    /// @param point The pont to translate.
    /// @param container The rect defining the bounds of the container containing `point`.
    /// @return The point representing `point` inside the receiver's aspect.
    func pointInAspectTranslated(from point: CGPoint, in container: CGRect) -> CGPoint
}
