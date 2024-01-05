import Foundation

public enum ExposureStopFraction: Int {
    case none = 0
    case oneThird = 1 // 1 << 0
    case oneHalf = 2 // 1 << 1
    case twoThirds = 4 // 1 << 2
}

/// This class represents a vector of exposure stops. Since this is a vector,
/// an instance of this on its own doesn't mean too much.
public class ExposureStops: NSObject, NSCopying, NSSecureCoding {

    public static func == (lhs: ExposureStops, rhs: ExposureStops) -> Bool {
        return lhs.wholeStopsFromZero == rhs.wholeStopsFromZero && lhs.fraction == rhs.fraction &&
            lhs.isNegative == rhs.isNegative
    }

    public static var supportsSecureCoding: Bool { return true }

    /// Returns a zero exposure stop vector.
    static let zero: ExposureStops = .stopsFromDecimalValue(0.0)

    /// Returns a stop vector parsed from the given decimal value.
    ///
    /// @note: Since stops are fractional, the decimal value will be clamped to the closest
    /// sensible fraction.
    ///
    /// @param decimalValue The value to convert to an exposure stop vector.
    /// @return Returns a `CBLExposureStops` object representing the given value.
    class func stopsFromDecimalValue(_ value: Double) -> ExposureStops {
        return ExposureStops(decimalValue: value)
    }

    /// Returns an array of exposure stop vectors between (and including) the given exposure stop vectors.
    ///
    /// Fractions are calculated from the starting value. Whole stops are always included.
    ///
    /// @param from The starting exposure stop vector.
    /// @param to The terminating exposure stop vector.
    /// @param fractions The fractions to include.
    /// @return Returns the array of exposure stops.
    static func stops(between from: ExposureStops, and to: ExposureStops, fractions: Set<ExposureStopFraction>) -> [ExposureStops] {

        var start: ExposureStops = from
        var end: ExposureStops = to

        if from.compare(to: to) != .orderedAscending {
            start = to
            end = from
        }

        let oneStop = ExposureStops(decimalValue: 1.0)
        let thirdStop = ExposureStops(decimalValue: 0.33)
        let halfStop = ExposureStops(decimalValue: 0.5)
        let twoThirdStop = ExposureStops(decimalValue: 0.66)

        var values: [ExposureStops] = [start]

        var lastWholeValue = start
        var lastActualValue = start

        repeat {

            if fractions.contains(.oneThird) {
                lastActualValue = lastWholeValue.adding(thirdStop)
                values.append(lastActualValue)
                if lastActualValue.compare(to: end) != .orderedAscending { break }
            }

            if fractions.contains(.oneHalf) {
                lastActualValue = lastWholeValue.adding(halfStop)
                values.append(lastActualValue)
                if lastActualValue.compare(to: end) != .orderedAscending { break }
            }

            if fractions.contains(.twoThirds) {
                lastActualValue = lastWholeValue.adding(twoThirdStop)
                values.append(lastActualValue)
                if lastActualValue.compare(to: end) != .orderedAscending { break }
            }

            lastWholeValue = lastWholeValue.adding(oneStop)
            lastActualValue = lastWholeValue
            values.append(lastWholeValue)
            if lastActualValue.compare(to: end) != .orderedAscending { break }

        } while true

        return values
    }

    /// Returns an exposure stop object representing the given values.
    ///
    /// This is the designated initializer of this class.
    ///
    /// @param wholeStops The number of whole stops from zero.
    /// @param fraction The fractional value of the stops.
    /// @param negative `YES` if the value is negative, otherwise `NO`.
    /// @return Returns the initialised object.
    public init(wholeStops: UInt, fraction: ExposureStopFraction, isNegative: Bool) {
        self.wholeStopsFromZero = wholeStops
        self.fraction = fraction
        self.isNegative = isNegative
    }

    /// Creates a stop vector parsed from the given decimal value.
    ///
    /// @note: Since stops are fractional, the decimal value will be clamped to the closest
    /// sensible fraction.
    ///
    /// @param decimalValue The value to convert to an exposure stop vector.
    /// @return Returns a `CBLExposureStops` object representing the given value.
    convenience public init(decimalValue value: Double) {
        var decimalValue = value
        let isNegative: Bool = (decimalValue < 0.0)

        if isNegative { decimalValue *= -1 }

        var wholeStops: UInt = UInt(floor(decimalValue))
        decimalValue -= Double(wholeStops)

        var fraction: ExposureStopFraction = .none

        if decimalValue > 0.2 { fraction = .oneThird }
        if decimalValue >= 0.4 { fraction = .oneHalf }
        if decimalValue >= 0.6 { fraction = .twoThirds }
        if decimalValue >= 0.9 {
            fraction = .none
            wholeStops += 1
        }

        self.init(wholeStops: wholeStops, fraction: fraction, isNegative: isNegative)
    }

    public convenience override init() {
        self.init(wholeStops: 0, fraction: .none, isNegative: false)
    }

    public required convenience init?(coder: NSCoder) {
        guard coder.containsValue(forKey: "wholeStops") &&
            coder.containsValue(forKey: "fraction") &&
            coder.containsValue(forKey: "isNegative") else { return nil }

        let rawFraction = coder.decodeInteger(forKey: "fraction")
        guard let fraction = ExposureStopFraction(rawValue: rawFraction) else { return nil }

        self.init(wholeStops: UInt(coder.decodeInteger(forKey: "wholeStops")),
                  fraction: fraction,
                  isNegative: coder.decodeBool(forKey: "isNegative"))
    }

    public func encode(with coder: NSCoder) {
        coder.encode(Int(wholeStopsFromZero), forKey: "wholeStops")
        coder.encode(fraction.rawValue, forKey: "fraction")
        coder.encode(isNegative, forKey: "isNegative")
    }

    public func copy(with zone: NSZone?) -> Any {
        return ExposureStops(wholeStops: wholeStopsFromZero, fraction: fraction, isNegative: isNegative)
    }

    override public func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? ExposureStops else { return false }
        return self == other
    }

    /// Returns `YES` if the receiver represents a negative value, otherwise `NO`.
    public let isNegative: Bool

    /// Returns the whole number of the stops represented by the receiver.
    public let wholeStopsFromZero: UInt

    /// Returns the fractional value of the stops represented by the receiver.
    public let fraction: ExposureStopFraction

    /// Compares two stop values.
    ///
    /// @param other The other value to compare the receiver to.
    /// @return Returns `NSOrderedDescending` if the parameter is less than the receiver, `NSOrderedAscending` if the parameter is greater than
    /// the receiver, or `NSOrderedSame` if the values are equal.
    func compare(to other: ExposureStops) -> ComparisonResult {
        let otherDecimal = other.approximateDecimalValue
        let thisDecimal = approximateDecimalValue

        if otherDecimal < thisDecimal {
            return .orderedDescending
        } else if otherDecimal > thisDecimal {
            return .orderedAscending
        } else {
            return .orderedSame
        }
    }

    /// Returns a string succinctly describing the value. For debug only - not appropriate for user-facing UI.
    var succinctDescription: String {
        let fractionString: String = {
            switch fraction {
            case .none: return ""
            case .oneThird: return " 1/3"
            case .oneHalf: return " 1/2"
            case .twoThirds: return " 2/3"
            }
        }()

        return String(format: "\(isNegative ? "-" : "")\(wholeStopsFromZero)\(fractionString) stops")
    }

    override public var description: String {
        return succinctDescription
    }

    /// Returns a new object containing the result of adding the passed object to the receiver.
    ///
    /// @param stops The stops instance to add to the receiver.
    /// @return Returns the result of the operation.
    func adding(_ stops: ExposureStops) -> ExposureStops {
        return ExposureStops(decimalValue: self.approximateDecimalValue + stops.approximateDecimalValue)
    }

    /// Returns a new object containing the difference in stops between the receiver and the passed value.
    ///
    /// @param stops The object to compare to.
    /// @return Returns a new instance representing the difference between the receiver and `stops`.
    func stopsDifference(from stops: ExposureStops) -> ExposureStops {
        return ExposureStops(decimalValue: self.approximateDecimalValue - stops.approximateDecimalValue)
    }

    /// Returns an approximate decimal representation of the receiver.
    public var approximateDecimalValue: Double {
        var decimalValue: Double = Double(wholeStopsFromZero)
        if fraction == .oneThird { decimalValue += (1.0 / 3.0) }
        if fraction == .oneHalf { decimalValue += (1.0 / 2.0) }
        if fraction == .twoThirds { decimalValue += (2.0 / 3.0) }
        if isNegative { decimalValue *= -1 }
        return decimalValue
    }
}