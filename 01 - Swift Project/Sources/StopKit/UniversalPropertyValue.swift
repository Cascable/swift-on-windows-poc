import Foundation

/// An object-based camera property value that can be used across camera types.
public protocol UniversalPropertyValue {

    /// Returns a string succinctly describing the value. For debug only - not appropriate for user-facing UI.
    var succinctDescription: String { get }

    /// Returns the localized display string for the receiver.
    var localizedDisplayValue: String? { get }

    /// Returns `true` if the receiver is equal to the given object, otherwise `false`.
    func isEqual(_ object: Any?) -> Bool
}

public enum ExposurePropertyComparisonError: Error {
    case containsIndeterminateValue
    case notSameTypes
}

/// Properties that represent exposure properties should implement this protocol. */
public protocol UniversalExposurePropertyValue: UniversalPropertyValue {

    /// Returns `YES` if the value is determinate (i.e., isn't 'automatic' or 'bulb'). */
    var isDeterminate: Bool { get }

    /// Returns a new instance of the property, adjusted by the given number of stops.
    ///
    /// @param stops The number of stops to adjust the property by.
    /// @return Returns a new property with the adjustment applied, or `nil` if the receiver's `isDeterminate` property returns false.
    func valueByAdding(_ stops: ExposureStops) throws -> Self

    /// Compares the receiver to the given value. Throws if the objects aren't of the same type, or
    /// if the receiver's `isDeterminate` property returns false.
    ///
    /// @param value The value to compare to the receiver.
    func compare(to value: Self) throws -> ComparisonResult

    /// Returns the difference, in stops, from the passed object. Returns `nil` if the objects aren't of the same type, or
    /// if the receiver's `isDeterminate` property returns false.
    ///
    /// @param value The value from which to calculate the stops distance from.
    func stopsDifference(from value: Self) throws -> ExposureStops
}
