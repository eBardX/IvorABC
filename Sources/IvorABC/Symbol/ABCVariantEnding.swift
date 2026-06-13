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
        guard !endings.isEmpty  // other validation?
        else { return nil }

        self.init(endings)
    }

    // MARK: Public Instance Properties

    /// The ending numbers this marker applies to.
    ///
    /// Each element is a range of consecutive ending numbers, e.g. `1...1`
    /// for a single ending or `1...3` for endings 1 through 3.
    public let endings: [ClosedRange<UInt>]

    // MARK: Internal Initializers

    /// Creates a new variant ending without validating `endings`.
    /// The caller is responsible for ensuring `endings` is non-empty.
    internal init(_ endings: [ClosedRange<UInt>]) {
        self.endings = endings
    }
}

// MARK: -

extension ABCVariantEnding {

    // MARK: Internal Computed Properties

    internal var stringValue: String {
        "[" + endings.map { r in
            r.lowerBound == r.upperBound
                ? "\(r.lowerBound)"
                : "\(r.lowerBound)-\(r.upperBound)"
        }.joined(separator: ",")
    }

    // MARK: Internal Initializers

    /// Parses a variant ending from the ABC token text (e.g. `[1` or
    /// `[2,3` or `[1-3`).
    internal init?(stringValue: some StringProtocol) {
        guard stringValue.hasPrefix("[")
        else { return nil }

        var ranges: [ClosedRange<UInt>] = []

        for part in stringValue.dropFirst().split(separator: ",") {
            if let dashIdx = part.firstIndex(of: "-") {
                guard let lo = UInt(part[..<dashIdx]),
                      let hi = UInt(part[part.index(after: dashIdx)...])
                else { return nil }

                ranges.append(lo...hi)
            } else {
                guard let n = UInt(part)
                else { return nil }

                ranges.append(n...n)
            }
        }

        guard !ranges.isEmpty
        else { return nil }

        self.init(ranges)
    }
}

// MARK: - Equatable

extension ABCVariantEnding: Equatable {
}

// MARK: - Sendable

extension ABCVariantEnding: Sendable {
}
