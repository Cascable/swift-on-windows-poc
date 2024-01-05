import Foundation

/// This class represents the shutter speed exposure property.
public class ShutterSpeedValue: NSObject, NSCopying, NSSecureCoding, UniversalExposurePropertyValue {

    /// Returns an instance representing a shutter speed of one second.
    public static let oneSecond: ShutterSpeedValue = ShutterSpeedValue(stopsFromASecond: .zero)

    /// Returns an instance representing a shutter speed of 1/250 of a second.
    public static let oneTwoHundredFiftieth: ShutterSpeedValue = ShutterSpeedValue(stopsFromASecond: ExposureStops(decimalValue: -8.0))

    /// Returns a singleton representing a "bulb" (indeterminate) shutter speed you might encounter when working with cameras.
    ///
    /// @warning Most properties and all math methods will raise an exception when called. This value should only be used for
    /// comparison in order to avoid trying to do math with this value when encountered. You can also check against the `isDeterminate` property.
    public static let bulb: ShutterSpeedValue = IndeterminateShutterSpeedValue(name: "BulbValue")

    /// Returns a singleton representing the "automatic" shutter speed you might encounter when working with cameras.
    ///
    /// @warning Most properties and all math methods will raise an exception when called. This value should only be used for
    /// comparison in order to avoid trying to do math with this value when encountered.
    public static let automatic: ShutterSpeedValue = IndeterminateShutterSpeedValue(name: "AutoValue")

    /// Returns an array of values representing the expected shutter speeds between the given values.
    ///
    /// @param low The lower value.
    /// @param high The higher value.
    /// @return Returns an array of shutter speeds between (and including) `low` and `high`.
    public static func shutterSpeeds(between low: ShutterSpeedValue, and high: ShutterSpeedValue) throws -> [ShutterSpeedValue] {

        guard low != high else { return [low] }

        var start = low
        var end = high

        if try low.compare(to: high) != .orderedAscending {
            start = high
            end = low
        }

        var speeds: [ShutterSpeedValue] = [start]
        var lastSpeed: ShutterSpeedValue = start

        repeat {
            lastSpeed = try lastSpeed.valueByAdding(ExposureStops(decimalValue: 1.0))
            speeds.append(lastSpeed)
            if try lastSpeed.compare(to: end) != .orderedAscending { break }
        } while true

        return speeds
    }

    /// Returns the significant fraction integer for the given number of stops from 1 second.
    ///
    /// @param stops The stops from one second.
    /// @return The value.
    public static func significantFraction(for stops: ExposureStops, mathematicallyCorrect: Bool = false) -> UInt {
        if mathematicallyCorrect {
            return UInt(pow(2.0, stops.approximateDecimalValue))
        }

        // In reality, cameras don't use mathematically correct shutter speeds for the given
        // number of stops, because reasons. We'll use Canon rounding here.
        var value: UInt = 1

        for _ in 0..<stops.wholeStopsFromZero {
            if value == 8 {
                value = 15
            } else if value == 60 {
                value = 125
            } else {
                value *= 2
            }
        }

        let fraction = stops.fraction

        if (fraction != .none) {
            if (value == 4000) {
                if (fraction == .oneThird) {
                    value = 5000
                } else if (fraction == .oneHalf) {
                    value = 6000
                } else {
                    value = 6400
                }

            } else if (value == 2000) {
                if (fraction == .oneThird) {
                    value = 2500
                } else if (fraction == .oneHalf) {
                    value = 3000
                } else {
                    value = 3200
                }

            } else if (value == 1000) {
                if (fraction == .oneThird) {
                    value = 1250
                } else if (fraction == .oneHalf) {
                    value = 1500
                } else {
                    value = 1600
                }

            } else if (value == 500) {
                if (fraction == .oneThird) {
                    value = 640
                } else if (fraction == .oneHalf) {
                    value = 750
                } else {
                    value = 800
                }

            } else if (value == 250) {
                if (fraction == .oneThird) {
                    value = 320
                } else if (fraction == .oneHalf) {
                    value = 350
                } else {
                    value = 400
                }

            } else if (value == 125) {
                if (fraction == .oneThird) {
                    value = 160
                } else if (fraction == .oneHalf) {
                    value = 180
                } else {
                    value = 200
                }

            } else if (value == 60) {
                if (fraction == .oneThird) {
                    value = 80
                } else if (fraction == .oneHalf) {
                    value = 90
                } else {
                    value = 100
                }

            } else if (value == 30) {
                if (fraction == .oneThird) {
                    value = 40
                } else if (fraction == .oneHalf) {
                    value = 45
                } else {
                    value = 50
                }

            } else if (value == 15) {
                if (fraction == .oneThird) {
                    value = 20
                } else if (fraction == .oneHalf) {
                    value = 20
                } else {
                    value = 25
                }

            } else if (value == 8) {
                if (fraction == .oneThird) {
                    value = 10
                } else if (fraction == .oneHalf) {
                    value = 10
                } else {
                    value = 13
                }

            } else if (value == 4) {
                if (fraction == .oneThird) {
                    value = 5
                } else if (fraction == .oneHalf) {
                    value = 6
                } else {
                    value = 6
                }

            } else if (value == 2) {
                if (fraction == .oneThird) {
                    value = 3
                } else if (fraction == .oneHalf) {
                    value = 3
                } else {
                    value = 3
                }

            } else if (value == 1) {
                if (fraction == .oneThird) {
                    value = 1
                } else if (fraction == .oneHalf) {
                    value = 1
                } else {
                    value = 1
                }

            } else {
                // Previously unknown values.
                if (fraction == .oneThird) {
                    value += UInt(Double(value) * 0.333333)
                } else if (fraction == .oneHalf) {
                    value += UInt(Double(value) * 0.5)
                } else {
                    value += UInt(Double(value) * 0.666666)
                }
            }
        }

        // Manual correction for extended Sony values.
        if (value == 26666 && fraction == .twoThirds) {
            value = 25600
        } else if (value == 21333 && fraction == .oneThird) {
            value = 20000
        } else if (value == 13333 && fraction == .twoThirds) {
            value = 12800
        } else if (value == 10666 && fraction == .oneThird) {
            value = 10000
        }

        return value
    }

    /// Initializes a new shutter speed value with the given number of stops from one second.
    ///
    /// This is the designated initializer for this class.
    ///
    /// @param stops The stops from one second.
    /// @return Returns the initialized shutter speed value.
    public init(stopsFromASecond: ExposureStops) {
        self.stopsFromASecond = stopsFromASecond
    }

    /// Initializes a new shutter speed value with the given duration.
    ///
    /// @note Initializing a shutter speed value in this way is only reliable with values at whole, half or third stops.
    ///
    /// @param interval The duration of the shutter speed.
    /// @return Returns the initialized shutter speed value.
    public convenience init?(approximateDuration interval: TimeInterval) {
        if interval <= 0.0 { return nil }
        let stops: Double = log(interval)/log(2.0)
        self.init(stopsFromASecond: ExposureStops(decimalValue: stops))
    }

    /// Returns the number of stops from one second of the receiver.
    public let stopsFromASecond: ExposureStops

    /// Returns `YES` if the receiver represents a "bulb" shutter speed, otherwise `NO`.
    public var isBulb: Bool { return false }

    /// Returns the approximate numeric duration of the receiver, in seconds.
    public var approximateTimeInterval: TimeInterval {

        let stops = stopsFromASecond

        if stops.wholeStopsFromZero < 2 {
            // These ranges have trouble as our fractions are integral. Special case these.
            if (stops.wholeStopsFromZero == 0) {
                if (stops.isNegative) {
                    if (stops.fraction == .none) {
                        return 1.0
                    } else if (stops.fraction == .oneThird) {
                        return 0.8
                    } else if (stops.fraction == .oneHalf) {
                        return 0.7
                    } else if (stops.fraction == .twoThirds) {
                        return 0.6
                    }
                } else {
                    if (stops.fraction == .none) {
                        return 1.0
                    } else if (stops.fraction == .oneThird) {
                        return 1.3
                    } else if (stops.fraction == .oneHalf) {
                        return 1.5
                    } else if (stops.fraction == .twoThirds) {
                        return 1.6
                    }
                }
            } else if (stops.wholeStopsFromZero == 1) {
                if (stops.isNegative) {
                    if (stops.fraction == .none) {
                        return 0.5
                    } else if (stops.fraction == .oneThird) {
                        return 0.4
                    } else if (stops.fraction == .oneHalf) {
                        return 0.3
                    } else if (stops.fraction == .twoThirds) {
                        return 0.3
                    }
                } else {
                    if (stops.fraction == .none) {
                        return 2.0
                    } else if (stops.fraction == .oneThird) {
                        return 2.5
                    } else if (stops.fraction == .oneHalf) {
                        return 3.0
                    } else if (stops.fraction == .twoThirds) {
                        return 3.2
                    }
                }
            }
        }

        return Double(upperFractionalValue) / Double(lowerFractionalValue)
    }

    /// Returns a string containing a fractional representation of the receiver.
    ///
    /// This method is not typically appropriate for user-facing text, since for speeds slower
    /// than one second it'll return top-heavy fractions (i.e., 2/1 for two seconds).
    public var fractionalRepresentation: String  {
        return "\(upperFractionalValue)/\(lowerFractionalValue)"
    }

    /// Returns the upper fractional numeric of the receiver. I.e., the "1" in "1/2".
    public var upperFractionalValue: UInt {
        if !self.stopsFromASecond.isNegative {
            return ShutterSpeedValue.significantFraction(for: stopsFromASecond)
        } else {
            return 1
        }
    }

    /// Returns the lower fractional numeric of the receiver. I.e., the "2" in "1/2".
    public var lowerFractionalValue: UInt {
        if !stopsFromASecond.isNegative {
            return 1
        } else {
            return ShutterSpeedValue.significantFraction(for: stopsFromASecond)
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
        return (ShutterSpeedValue(stopsFromASecond: stopsFromASecond.adding(stops)) as! Self)
    }

    /// Compares the receiver to the given value. Throws if the objects aren't of the same type, or
    /// if the receiver's `isDeterminate` property returns false.
    ///
    /// @param value The value to compare to the receiver.
    public func compare(to value: ShutterSpeedValue) throws -> ComparisonResult {
        guard value.isDeterminate else { throw ExposurePropertyComparisonError.containsIndeterminateValue }
        return stopsFromASecond.compare(to: value.stopsFromASecond)
    }

    /// Returns the difference, in stops, from the passed object. Returns `nil` if the objects aren't of the same type, or
    /// if the receiver's `isDeterminate` property returns false.
    ///
    /// @param value The value from which to calculate the stops distance from.
    public func stopsDifference(from value: ShutterSpeedValue) throws -> ExposureStops {
        guard value.isDeterminate else { throw ExposurePropertyComparisonError.containsIndeterminateValue }
        return stopsFromASecond.stopsDifference(from: value.stopsFromASecond)
    }

    /// Returns a string succinctly describing the value. For debug only - not appropriate for user-facing UI.
    public var succinctDescription: String {
        if approximateTimeInterval < 0.3 {
            return fractionalRepresentation
        } else {
            return String(format: "f/%1.1f\"", approximateTimeInterval)
        }
    }

    /// Returns the localized display string for the receiver.
    public var localizedDisplayValue: String? {
        if (self.approximateTimeInterval < 0.3) {
            // Return 1/x representation.
            return String("\(StopKitLocalizedString("OneOver", "UniversalShutterSpeeds"))\(ShutterSpeedValue.significantFraction(for: stopsFromASecond))")
        } else {
            // Return decimal representation.
            return formatter.string(from: NSNumber(value: approximateTimeInterval))
        }
    }

    // MARK: - Internal

    private lazy var formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.usesGroupingSeparator = false
        return formatter
    }()

    public static func == (lhs: ShutterSpeedValue, rhs: ShutterSpeedValue) -> Bool {
        return lhs.stopsFromASecond == rhs.stopsFromASecond
    }

    public class var supportsSecureCoding: Bool { return true }

    public convenience override init() {
        self.init(stopsFromASecond: .zero)
    }

    public required convenience init?(coder: NSCoder) {
        guard coder.containsValue(forKey: "stops") else { return nil }
        guard let stops = coder.decodeObject(of: ExposureStops.self, forKey: "stops") else { return nil }
        self.init(stopsFromASecond: stops)
    }

    public func encode(with coder: NSCoder) {
        coder.encode(stopsFromASecond, forKey: "stops")
    }

    public func copy(with zone: NSZone?) -> Any {
        return ShutterSpeedValue(stopsFromASecond: stopsFromASecond)
    }

    override public func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? ShutterSpeedValue else { return false }
        return self == other
    }

    override public var description: String {
        return succinctDescription
    }
}

public class IndeterminateShutterSpeedValue: ShutterSpeedValue {

    public init(name: String) {
        self.name = name
        super.init(stopsFromASecond: .zero)
    }

    public let name: String

    public static func == (lhs: IndeterminateShutterSpeedValue, rhs: IndeterminateShutterSpeedValue) -> Bool {
        return lhs.name == rhs.name
    }

    public override class var supportsSecureCoding: Bool { return true }

    public override var isDeterminate: Bool { return false }

    public override var isBulb: Bool {
        return name.localizedCaseInsensitiveContains("bulb") || name.localizedCaseInsensitiveContains("livetime")

    }

    public override var approximateTimeInterval: TimeInterval {
        return 0.0
    }

    public override var fractionalRepresentation: String {
        return ""
    }

    public override var lowerFractionalValue: UInt {
        return 0
    }

    public override var upperFractionalValue: UInt {
        return 0
    }

    public override func valueByAdding(_ stops: ExposureStops) throws -> Self {
        throw ExposurePropertyComparisonError.containsIndeterminateValue
    }

    public override func compare(to value: ShutterSpeedValue) throws -> ComparisonResult {
        throw ExposurePropertyComparisonError.containsIndeterminateValue
    }

    public override func stopsDifference(from value: ShutterSpeedValue) throws -> ExposureStops {
        throw ExposurePropertyComparisonError.containsIndeterminateValue
    }

    public override var succinctDescription: String {
        return name
    }

    /// Returns the localized display string for the receiver.
    public override var localizedDisplayValue: String? {
        return StopKitLocalizedString(name, "UniversalShutterSpeeds")
    }

    public required convenience init?(coder: NSCoder) {
        guard let name = coder.decodeObject(of: NSString.self, forKey: "name") as? String else { return nil }
        self.init(name: name)
    }

    public override func encode(with coder: NSCoder) {
        coder.encode(name, forKey: "name")
    }

    public override func copy(with zone: NSZone?) -> Any {
        return self
    }

    public override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? IndeterminateShutterSpeedValue else { return false }
        return self == other
    }

    public override var description: String {
        return succinctDescription
    }

}
