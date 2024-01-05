import Foundation

public class AEResult {

    internal init(autoExposureClipped: Bool) {
        self.autoExposureClipped = autoExposureClipped
        self.shutterSpeed = nil
        self.ISOValue = nil
        self.apertureValue = nil
    }

    /// Returns `YES` if the result is clipped (i.e., the camera couldn't correctly expose for the scene).
    /// Cameras typically flash their autoexposure indicators when this happens.
    public private(set) var autoExposureClipped: Bool

    /// Returns the shutter speed as calculated by the camera's autoexposure, or `nil` if no value was computed.
    public private(set) var shutterSpeed: Any?

    /// Returns the ISO value as calculated by the camera's autoexposure, or `nil` if no value was computed.
    public private(set) var ISOValue: Any?

    /// Returns the aperture value as calculated by the camera's autoexposure, or `nil` if no value was computed.
    public private(set) var apertureValue: Any?
}
