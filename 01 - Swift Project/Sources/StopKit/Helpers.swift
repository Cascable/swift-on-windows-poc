import Foundation

internal func StopKitLocalizedString(_ key: String, _ table: String) -> String {
    return Bundle.module.localizedString(forKey: key, value: nil, table: table)
}

internal let StandardFloatWiggleRoom: Double = 0.0000001

internal func FloatAlmostEqual(_ x: Double, _ y: Double, delta: Double = StandardFloatWiggleRoom) -> Bool {
    return fabs(x - y) <= delta
}
