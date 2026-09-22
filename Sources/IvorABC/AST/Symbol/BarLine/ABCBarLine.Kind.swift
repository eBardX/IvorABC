// © 2026 John Gary Pusey (see LICENSE.md)

extension ABCBarLine {

    // MARK: Public Nested Types

    /// The kind of bar line.
    ///
    /// This is a *semantic* representation: equivalent spellings declared
    /// interchangeable by the ABC v2.1 spec (§4.8) collapse to a single case.
    /// In particular, `::`, `:|:`, and `:||:` all denote `.repeat` with
    /// ``ABCBarLine/precedingPlayCount`` and
    /// ``ABCBarLine/followingPlayCount`` both equal to `2`.
    public enum Kind {

        /// A thin-thin double bar line: `||`.
        case double

        /// A thin-thick (final) double bar line: `|]`.
        case end

        /// An invisible bar line: `[|]`.
        case invisible

        /// A bar line with at least one repeat: any form containing a colon.
        ///
        /// The direction and fold of the repeat are encoded in
        /// ``ABCBarLine/precedingPlayCount`` and
        /// ``ABCBarLine/followingPlayCount``.
        case `repeat`

        /// A plain (thin) bar line: `|`.
        case standard
    }
}

// MARK: - Equatable

extension ABCBarLine.Kind: Equatable {
}

// MARK: - Hashable

extension ABCBarLine.Kind: Hashable {
}

// MARK: - Sendable

extension ABCBarLine.Kind: Sendable {
}
