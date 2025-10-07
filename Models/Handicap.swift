//
import Foundation

struct Handicap: Equatable, Comparable, CustomStringConvertible, Hashable {
    let value: Int

    // Returns true if the handicap is non-negative.
    var isPositive: Bool {
        return value >= 0
    }

    // Returns true if the handicap is negative.
    var isNegative: Bool {
        return value < 0
    }

    // Conform to Comparable so you can compare two handicaps.
    static func < (lhs: Handicap, rhs: Handicap) -> Bool {
        return lhs.value < rhs.value
    }

    // Conform to CustomStringConvertible for easier printing.
    var description: String {
        return "\(value)"
    }

    // Designated initializer.
    init(value: Int) {
        self.value = value
    }

    // Failable initializer to create a Handicap from a string.
    init?(_ string: String) {
        let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let intValue = Int(trimmed) else { return nil }
        self.value = intValue
    }
}
