import Foundation

/// This class represents the aperture "f-stops" exposure property.
public class ISOValue: NSObject, NSCopying, NSSecureCoding, UniversalExposurePropertyValue {

    /// Returns an instance representing ISO 100.
    public static let iso100: ISOValue = ISOValue(stopsFromISO100: .zero)

    /// Returns an instance representing ISO 200.
    public static let iso200: ISOValue = ISOValue(stopsFromISO100: ExposureStops(decimalValue: 1.0))

    /// Returns an instance representing ISO 400.
    public static let iso400: ISOValue = ISOValue(stopsFromISO100: ExposureStops(decimalValue: 2.0))

    /// Returns an instance representing ISO 800.
    public static let iso800: ISOValue = ISOValue(stopsFromISO100: ExposureStops(decimalValue: 3.0))

    /// Returns an instance representing ISO 1600.
    public static let iso1600: ISOValue = ISOValue(stopsFromISO100: ExposureStops(decimalValue: 4.0))

    /// Returns a singleton representing the "automatic" ISO value you might encounter when working with cameras.
    ///
    /// @warning Most properties and all math methods will raise an exception when called. This value should only be used for
    /// comparison in order to avoid trying to do math with this value when encountered.
    public static let automaticISO: ISOValue = AutoISOValue()

    /// Returns a new ISO value for the given number of stops from ISO 100.
    ///
    /// @param stops The stops from ISO 100.
    /// @return Returns the initialized ISO value.
    static func withStopsFromISO100(_ stops: ExposureStops) -> ISOValue {
        return ISOValue(stopsFromISO100: stops)
    }

    /// Initialized a new ISO value for the given number of stops from ISO 100.
    ///
    /// This is the designated initializer for this class.
    ///
    /// @param stops The stops from ISO 100.
    /// @return Returns the initialized ISO value.
    public init(stopsFromISO100: ExposureStops) {
        self.stopsFromISO100 = stopsFromISO100
    }

    /// Returns a new ISO value for the give numeric value.
    ///
    /// @note Initializing an ISO value this way only works reliably for values exactly in whole, third or half stop values.
    ///
    /// @param iso The ISO value.
    /// @return Returns the initialized ISO value.
    public convenience init?(numericISOValue iso: UInt) {
        if (iso == 0) { return nil }
        var value: Double = Double(iso) / 100.0
        value = log(value)/log(2.0)
        self.init(stopsFromISO100: ExposureStops(decimalValue: value))
    }

    /// Returns the number of stops from ISO 100 of the receiver.
    public let stopsFromISO100: ExposureStops

    /// Returns an approximate numeric ISO value for the receiver.
    public var numericISOValue: UInt {

        var value: Double = 100

        if stopsFromISO100.isNegative {
            value /= pow(2.0, Double(stopsFromISO100.wholeStopsFromZero))
        } else {
            value *= pow(2.0, Double(stopsFromISO100.wholeStopsFromZero))
        }

        let fractionalValue: Double = {
            switch stopsFromISO100.fraction {
            case .none: return 0.0
            case .oneThird: return 1.0 / 3.0
            case .oneHalf: return 1.0 / 2.0
            case .twoThirds: return 2.0 / 3.0
            }
        }()

        if stopsFromISO100.isNegative {
            value -= (value * fractionalValue)
        } else {
            value += (value * fractionalValue)
        }

        if let adjustedValue = isoAdjustments[UInt(value)] {
            return adjustedValue
        } else {
            return UInt(value)
        }
    }

    // MARK: - UniversalExposurePropertyValue

    /// Returns `YES` if the value is determinate (i.e., isn't 'automatic' or 'bulb').
    public var isDeterminate: Bool { return true }

    /// Returns a new instance of the property, adjusted by the given number of stops.
    ///
    /// @param stops The number of stops to adjust the property by.
    /// @return Returns a new property with the adjustment applied, or `nil` if the receiver's `isDeterminate` property returns false.
    public func valueByAdding(_ stops: ExposureStops) throws -> Self {
        return (ISOValue(stopsFromISO100: stopsFromISO100.adding(stops)) as! Self)
    }

    /// Compares the receiver to the given value. Throws if the objects aren't of the same type, or
    /// if the receiver's `isDeterminate` property returns false.
    ///
    /// @param value The value to compare to the receiver.
    public func compare(to value: ISOValue) throws -> ComparisonResult {
        guard value.isDeterminate else { throw ExposurePropertyComparisonError.containsIndeterminateValue }
        return stopsFromISO100.compare(to: value.stopsFromISO100)
    }

    /// Returns the difference, in stops, from the passed object. Returns `nil` if the objects aren't of the same type, or
    /// if the receiver's `isDeterminate` property returns false.
    ///
    /// @param value The value from which to calculate the stops distance from.
    public func stopsDifference(from value: ISOValue) throws -> ExposureStops {
        guard value.isDeterminate else { throw ExposurePropertyComparisonError.containsIndeterminateValue }
        return stopsFromISO100.stopsDifference(from: value.stopsFromISO100)
    }

    /// Returns a string succinctly describing the value. For debug only - not appropriate for user-facing UI.
    public var succinctDescription: String {
        return String(format: "ISO %u", numericISOValue)
    }

    /// Returns the localized display string for the receiver.
    public var localizedDisplayValue: String? {
        return formatter.string(from: NSNumber(value: numericISOValue))
    }

    // MARK: - Internal

    private lazy var formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.usesGroupingSeparator = false
        return formatter
    }()

    public static func == (lhs: ISOValue, rhs: ISOValue) -> Bool {
        return lhs.stopsFromISO100 == rhs.stopsFromISO100
    }

    public class var supportsSecureCoding: Bool { return true }

    public convenience override init() {
        self.init(stopsFromISO100: .zero)
    }

    public required convenience init?(coder: NSCoder) {
        guard coder.containsValue(forKey: "stops") else { return nil }
        guard let stops = coder.decodeObject(of: ExposureStops.self, forKey: "stops") else { return nil }
        self.init(stopsFromISO100: stops)
    }

    public func encode(with coder: NSCoder) {
        coder.encode(stopsFromISO100, forKey: "stops")
    }

    public func copy(with zone: NSZone?) -> Any {
        return ISOValue(stopsFromISO100: stopsFromISO100)
    }

    override public func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? ISOValue else { return false }
        return self == other
    }

    override public var description: String {
        return succinctDescription
    }

    // Adjustments from accurate to display values based on industry standards.
    private let isoAdjustments: [UInt: UInt] = [
        33: 64,
        66: 80,
        133: 125,
        150: 140,
        166: 160,
        266: 250,
        300: 280,
        333: 320,
        533: 500,
        600: 560,
        666: 640,
        1066: 1000,
        1200: 1100,
        1333: 1250,
        2133: 2000,
        2400: 2200,
        2666: 2500,
        4266: 4000,
        4800: 4500,
        5333: 5000,
        8533: 8000,
        9600: 9000,
        10666: 10000,
        17066: 16000,
        19200: 18000,
        21333: 20000,
        34133: 32000,
        42666: 40000,
        68266: 64000,
        85333: 80000
    ]
}

public class AutoISOValue: ISOValue {

    public static func == (lhs: AutoISOValue, rhs: AutoISOValue) -> Bool {
        return true
    }

    public override class var supportsSecureCoding: Bool { return true }

    public override var isDeterminate: Bool { return false }

    public override var numericISOValue: UInt { return 0 }

    public override func valueByAdding(_ stops: ExposureStops) throws -> Self {
        throw ExposurePropertyComparisonError.containsIndeterminateValue
    }

    public override func compare(to value: ISOValue) throws -> ComparisonResult {
        throw ExposurePropertyComparisonError.containsIndeterminateValue
    }

    public override func stopsDifference(from value: ISOValue) throws -> ExposureStops {
        throw ExposurePropertyComparisonError.containsIndeterminateValue
    }

    public override var succinctDescription: String {
        return "Automatic"
    }

    /// Returns the localized display string for the receiver.
    public override var localizedDisplayValue: String? {
        return StopKitLocalizedString("AutoValue", "UniversalISOValues")
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
        guard let other = object as? AutoISOValue else { return false }
        return self == other
    }

    public override var description: String {
        return succinctDescription
    }
}
