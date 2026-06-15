// © 2026 John Gary Pusey (see LICENSE.md)

/// A variant ending specification in ABC music notation.
public struct ABCVariantEnding {

    // MARK: Public Initializers

    /// Creates a new variant ending with the given ending ranges, or `nil` if
    /// `endings` is empty.
    ///
    /// - Parameter endings: The ending numbers this marker applies to, each a
    ///                      range of consecutive ending numbers. Must not be
    ///                      empty.
    public init?(endings: [ClosedRange<UInt>]) {
        // guard Self._isValid(endings)
        // else { return nil }

        guard !endings.isEmpty
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

// MARK: - Equatable

extension ABCVariantEnding: Equatable {
}

// MARK: - Sendable

extension ABCVariantEnding: Sendable {
}
