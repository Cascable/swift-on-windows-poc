import Foundation

/// This class represents the exposure compensation property.
public class ExposureCompensationValue: NSObject, NSCopying, NSSecureCoding, UniversalExposurePropertyValue {

    /// Returns an exposure compensation value of zero.
    public static let zeroEV: ExposureCompensationValue = ExposureCompensationValue(stopsFromZeroEV: .zero)

    /// Returns an exposure compensation value for the given number of stops from zero.
    ///
    /// @param stops The number of stops from zero EV to initialise the new value with.
    public static func withStopsFromZeroEV(_ stops: ExposureStops) -> ExposureCompensationValue {
        return ExposureCompensationValue(stopsFromZeroEV: stops)
    }

    /// Initializes an exposure compensation value for the given number of stops from zero.
    ///
    /// @param stops The number of stops from zero EV to initialise the new value with.
    public init(stopsFromZeroEV: ExposureStops) {
        self.stopsFromZeroEV = stopsFromZeroEV
    }

    /// Returns the number of stops from zero of the receiver.
    public let stopsFromZeroEV: ExposureStops

    // MARK: - UniversalExposurePropertyValue

    /// Returns `YES` if the value is determinate (i.e., isn't 'automatic' or 'bulb'). */
    public var isDeterminate: Bool { return true }

    /// Returns a new instance of the property, adjusted by the given number of stops.
    ///
    /// @param stops The number of stops to adjust the property by.
    /// @return Returns a new property with the adjustment applied, or `nil` if the receiver's `isDeterminate` property returns false.
    public func valueByAdding(_ stops: ExposureStops) throws -> Self {
        return (ExposureCompensationValue(stopsFromZeroEV: stopsFromZeroEV.adding(stops)) as! Self)
    }

    /// Compares the receiver to the given value. Throws if the objects aren't of the same type, or
    /// if the receiver's `isDeterminate` property returns false.
    ///
    /// @param value The value to compare to the receiver.
    public func compare(to value: ExposureCompensationValue) throws -> ComparisonResult {
        guard value.isDeterminate else { throw ExposurePropertyComparisonError.containsIndeterminateValue }
        return stopsFromZeroEV.compare(to: value.stopsFromZeroEV)
    }

    /// Returns the difference, in stops, from the passed object. Returns `nil` if the objects aren't of the same type, or
    /// if the receiver's `isDeterminate` property returns false.
    ///
    /// @param value The value from which to calculate the stops distance from.
    public func stopsDifference(from value: ExposureCompensationValue) throws -> ExposureStops {
        guard value.isDeterminate else { throw ExposurePropertyComparisonError.containsIndeterminateValue }
        return stopsFromZeroEV.stopsDifference(from: value.stopsFromZeroEV)
    }

    /// Returns a string succinctly describing the value. For debug only - not appropriate for user-facing UI.
    public var succinctDescription: String {
        let fractionString: String = {
            switch stopsFromZeroEV.fraction {
            case .none: return ""
            case .oneThird: return " 1/3"
            case .oneHalf: return " 1/2"
            case .twoThirds: return " 2/3"
            }
        }()

        return String(format: "\(stopsFromZeroEV.isNegative ? "-" : "")\(stopsFromZeroEV.wholeStopsFromZero)\(fractionString) EV")
    }

    /// Returns the localized display string for the receiver.
    public var localizedDisplayValue: String? {
        let fractionString: String = {
            switch stopsFromZeroEV.fraction {
            case .none: return ""
            case .oneThird: return StopKitLocalizedString("TwoThirdsFraction", "UniversalExposureCompensations")
            case .oneHalf: return StopKitLocalizedString("OneHalfFraction", "UniversalExposureCompensations")
            case .twoThirds: return StopKitLocalizedString("TwoThirdsFraction", "UniversalExposureCompensations")
            }
        }()

        let numberString: String = {
            if stopsFromZeroEV.wholeStopsFromZero != 0 || (stopsFromZeroEV.wholeStopsFromZero == 0 && stopsFromZeroEV.fraction == .none) {
                return formatter.string(from: NSNumber(value: stopsFromZeroEV.wholeStopsFromZero)) ?? "\(stopsFromZeroEV.wholeStopsFromZero)"
            } else {
                return ""
            }
        }()

        let signString: String = {
            if stopsFromZeroEV.wholeStopsFromZero == 0 && stopsFromZeroEV.fraction == .none {
                return ""
            } else {
                return stopsFromZeroEV.isNegative ? "-" : "+"
            }
        }()

        return "\(signString)\(numberString)\(fractionString)"
    }

    // MARK: - Internal

    public static func == (lhs: ExposureCompensationValue, rhs: ExposureCompensationValue) -> Bool {
        return lhs.stopsFromZeroEV == rhs.stopsFromZeroEV
    }

    public static var supportsSecureCoding: Bool { return true }

    public convenience override init() {
        self.init(stopsFromZeroEV: .zero)
    }

    public required convenience init?(coder: NSCoder) {
        guard coder.containsValue(forKey: "stops") else { return nil }
        guard let stops = coder.decodeObject(of: ExposureStops.self, forKey: "stops") else { return nil }
        self.init(stopsFromZeroEV: stops)
    }

    public func encode(with coder: NSCoder) {
        coder.encode(stopsFromZeroEV, forKey: "stops")
    }

    public func copy(with zone: NSZone?) -> Any {
        return ExposureCompensationValue(stopsFromZeroEV: stopsFromZeroEV)
    }

    override public func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? ExposureCompensationValue else { return false }
        return self == other
    }

    override public var description: String {
        return succinctDescription
    }

    private lazy var formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.usesGroupingSeparator = false
        return formatter
    }()

}