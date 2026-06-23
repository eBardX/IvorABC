// © 2026 John Gary Pusey (see LICENSE.md)

/// A variant ending specification in ABC music notation.
public struct ABCVariantEnding {

    // MARK: Public Initializers

    /// Creates a new variant ending with the given ending ranges, or `nil` if
    /// `endings` is empty or contains an ending number of zero.
    ///
    /// - Parameter endings: The ending numbers this marker applies to, each a
    ///                      range of consecutive ending numbers. Must not be
    ///                      empty, and every ending number must be at least 1.
    public init?(endings: [ClosedRange<UInt>]) {
        guard Self._isValid(endings)
        else { return nil }

        self.endings = endings
    }

    // MARK: Public Instance Properties

    /// The ending numbers this marker applies to.
    ///
    /// Each element is a range of consecutive ending numbers, e.g. `1...1`
    /// for a single ending or `1...3` for endings 1 through 3.
    public let endings: [ClosedRange<UInt>]
}

// MARK: -

extension ABCVariantEnding {

    // MARK: Private Type Methods

    private static func _isValid(_ endings: [ClosedRange<UInt>]) -> Bool {
        // Ending numbers are 1-based (§4.9, §4.10), so zero is not a valid
        // ending. A `ClosedRange` guarantees its upper bound is at least its
        // lower bound, so checking the lower bound suffices.
        !endings.isEmpty && endings.allSatisfy { $0.lowerBound > 0 }
    }
}

// MARK: - Equatable

extension ABCVariantEnding: Equatable {
}

// MARK: - Sendable

extension ABCVariantEnding: Sendable {
}
