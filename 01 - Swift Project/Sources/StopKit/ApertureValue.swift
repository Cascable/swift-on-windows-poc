import Foundation

/// This class represents the aperture "f-stops" exposure property.
public class ApertureValue: NSObject, NSCopying, NSSecureCoding, UniversalExposurePropertyValue {

    /// Returns a singleton representing the "automatic" aperture value you might encounter when working with cameras.
    //
    // @warning Most properties and all math methods will raise an exception when called. This value should only be used for
    // comparison in order to avoid trying to do math with this value when encountered.
    public static let automaticAperture: ApertureValue = AutoApertureValue()

    /// Returns an instance representing f/2.8.
    public static let f2Point8: ApertureValue = ApertureValue(stopsFromF8: ExposureStops(decimalValue: 3.0))

    /// Returns an instance representing f/4.0.
    public static let f4: ApertureValue = ApertureValue(stopsFromF8: ExposureStops(decimalValue: 2.0))

    /// Returns an instance representing f/5.6.
    public static let f5Point6: ApertureValue = ApertureValue(stopsFromF8: ExposureStops(decimalValue: 1.0))

    /// Returns an instance representing f/8.
    public static let f8: ApertureValue = ApertureValue(stopsFromF8: .zero)

    /// Returns an instance representing f/11.
    public static let f11: ApertureValue = ApertureValue(stopsFromF8: ExposureStops(decimalValue: -1.0))

    /// Returns an instance representing f/16.
    public static let f16: ApertureValue = ApertureValue(stopsFromF8: ExposureStops(decimalValue: -2.0))

    /// Returns an instance representing f/22.
    public static let f22: ApertureValue = ApertureValue(stopsFromF8: ExposureStops(decimalValue: -3.0))

    /// Returns a new value for the given number of stops from f/8.
    ///
    /// @param stops The stops from f/8.
    /// @return Returns the initialized aperture value.
    public static func withStopsFromF8(_ stops: ExposureStops) -> ApertureValue {
        return ApertureValue(stopsFromF8: stops)
    }

    /// Initializes a new value for the given number of stops from f/8.
    ///
    /// This is the designated initializer for this class.
    ///
    /// @param stops The stops from f/8.
    /// @return Returns the initialized aperture value.
    public init(stopsFromF8 stops: ExposureStops) {
        self.stopsFromF8 = stops
    }

    /// Initializes a new value for the given numeric aperture value.
    ///
    /// @note Initializing an aperture value with this method is only reliable for values in whole, half or third stops.
    ///
    /// @param aperture The numeric value.
    /// @return Returns the initialized aperture value.
    convenience init?(approximateDecimalValue: Double) {
        if (approximateDecimalValue <= 0.0) { return nil }
        let stops: Double = log(approximateDecimalValue / 8.0)/log(sqrt(2.0));
        self.init(stopsFromF8: ExposureStops(decimalValue: stops * -1.0))
    }

    /// Returns the number of stops from f/8 for the receiver.
    public let stopsFromF8: ExposureStops

    /// Returns the approximate numeric value of the receiver.
    public var approximateDecimalValue: Double {

        let fractionalValue: Double = {
            switch stopsFromF8.fraction {
            case .none: return 0.0;
            case .oneThird: return 1.0 / 3.0
            case .oneHalf: return 1.0 / 2.0
            case .twoThirds: return 2.0 / 3.0
            }
        }()

        var value: Double = 8.0

        if stopsFromF8.isNegative {
            value *= (pow(sqrt(2.0), Double(stopsFromF8.wholeStopsFromZero) + fractionalValue))
        } else {
            value /= (pow(sqrt(2.0), Double(stopsFromF8.wholeStopsFromZero) + fractionalValue))
        }

        // Manual tweaks, based on Canon's numbers.
        if value >= 10.0 {
            value = round(value)
        } else {
            value = 0.1 * round(value * 10.0)
        }

        if FloatAlmostEqual(value, 23.0) {
            value = 22.0
        } else if FloatAlmostEqual(value, 1.3) {
            value = 1.2
        } else if FloatAlmostEqual(value, 1.7) {
            value = 1.8
        } else if FloatAlmostEqual(value, 2.4) {
            value = 2.5
        } else if FloatAlmostEqual(value, 3.4) ||
                FloatAlmostEqual(value, 3.6) {
            value = 3.5
        } else if FloatAlmostEqual(value, 4.8) {
            value = 4.5
        } else if FloatAlmostEqual(value, 5.7) {
            value = 5.6
        }

        return value
    }

    // MARK: - UniversalExposurePropertyValue

    /// Returns `YES` if the value is determinate (i.e., isn't 'automatic' or 'bulb').
    public var isDeterminate: Bool { return true }

    /// Returns a new instance of the property, adjusted by the given number of stops.
    ///
    /// @param stops The number of stops to adjust the property by.
    /// @return Returns a new property with the adjustment applied, or `nil` if the receiver's `isDeterminate` property returns false.
    public func valueByAdding(_ stops: ExposureStops) throws -> Self {
        return (ApertureValue(stopsFromF8: stopsFromF8.adding(stops)) as! Self)
    }

    /// Compares the receiver to the given value. Throws if the objects aren't of the same type, or
    /// if the receiver's `isDeterminate` property returns false.
    ///
    /// @param value The value to compare to the receiver.
    public func compare(to value: ApertureValue) throws -> ComparisonResult {
        guard value.isDeterminate else { throw ExposurePropertyComparisonError.containsIndeterminateValue }
        return stopsFromF8.compare(to: value.stopsFromF8)
    }

    /// Returns the difference, in stops, from the passed object. Returns `nil` if the objects aren't of the same type, or
    /// if the receiver's `isDeterminate` property returns false.
    ///
    /// @param value The value from which to calculate the stops distance from.
    public func stopsDifference(from value: ApertureValue) throws -> ExposureStops {
        guard value.isDeterminate else { throw ExposurePropertyComparisonError.containsIndeterminateValue }
        return stopsFromF8.stopsDifference(from: value.stopsFromF8)
    }

    /// Returns a string succinctly describing the value. For debug only - not appropriate for user-facing UI.
    public var succinctDescription: String {
        return String(format: "f/%1.1f", approximateDecimalValue)
    }

    /// Returns the localized display string for the receiver.
    public var localizedDisplayValue: String? {
        return formatter.string(from: NSNumber(value: approximateDecimalValue))
    }

    // MARK: - Internal

    private lazy var formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.usesGroupingSeparator = false
        return formatter
    }()

    public static func == (lhs: ApertureValue, rhs: ApertureValue) -> Bool {
        return lhs.stopsFromF8 == rhs.stopsFromF8
    }

    public class var supportsSecureCoding: Bool { return true }

    public convenience override init() {
        self.init(stopsFromF8: .zero)
    }

    public required convenience init?(coder: NSCoder) {
        guard coder.containsValue(forKey: "stops") else { return nil }
        guard let stops = coder.decodeObject(of: ExposureStops.self, forKey: "stops") else { return nil }
        self.init(stopsFromF8: stops)
    }

    public func encode(with coder: NSCoder) {
        coder.encode(stopsFromF8, forKey: "stops")
    }

    public func copy(with zone: NSZone?) -> Any {
        return ApertureValue(stopsFromF8: stopsFromF8)
    }

    override public func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? ApertureValue else { return false }
        return self == other
    }

    override public var description: String {
        return succinctDescription
    }
}

public class AutoApertureValue: ApertureValue {

    public static func == (lhs: AutoApertureValue, rhs: AutoApertureValue) -> Bool {
        return true
    }

    public override class var supportsSecureCoding: Bool { return true }

    public override var isDeterminate: Bool { return false }

    public override var approximateDecimalValue: Double { return 0.0 }

    public override func valueByAdding(_ stops: ExposureStops) throws -> Self {
        throw ExposurePropertyComparisonError.containsIndeterminateValue
    }

    public override func compare(to value: ApertureValue) throws -> ComparisonResult {
        throw ExposurePropertyComparisonError.containsIndeterminateValue
    }

    public override func stopsDifference(from value: ApertureValue) throws -> ExposureStops {
        throw ExposurePropertyComparisonError.containsIndeterminateValue
    }

    public override var succinctDescription: String {
        return "Automatic"
    }

    /// Returns the localized display string for the receiver.
    public override var localizedDisplayValue: String? {
        return StopKitLocalizedString("AutoValue", "UniversalShutterSpeeds")
    }

    public required convenience init?(coder: NSCoder) {
        guard coder.containsValue(forKey: "placeholder") else { return nil }
        self.init()
    }

    public override func encode(with coder: NSCoder) {
        coder.encode("Auto", forKey: "placeholder")
    }

    public override func copy(with zone: NSZone?) -> Any {
        return self
    }

    public override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? AutoApertureValue else { return false }
        return self == other
    }

    public override var description: String {
        return succinctDescription
    }
}