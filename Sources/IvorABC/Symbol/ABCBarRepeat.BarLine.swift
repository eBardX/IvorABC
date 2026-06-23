// © 2026 John Gary Pusey (see LICENSE.md)

extension ABCBarRepeat {

    // MARK: Public Nested Types

    /// A bar or repeat line symbol.
    ///
    /// This is a *semantic* representation: equivalent spellings declared
    /// interchangeable by the ABC v2.1 spec (§4.8) collapse to a single case.
    /// In particular, `::`, `:|:`, and `:||:` all denote `.repeat` with
    /// ``ABCBarRepeat/precedingPlayCount`` and
    /// ``ABCBarRepeat/followingPlayCount`` both equal to `2`.
    public enum BarLine {

        /// A thin-thin double bar line: `||`.
        case double

        /// A thin-thick (final) double bar line: `|]`.
        case end

        /// An invisible bar line: `[|]`.
        case invisible

        /// A bar line with at least one repeat: any form containing a colon.
        ///
        /// The direction and fold of the repeat are encoded in
        /// ``ABCBarRepeat/precedingPlayCount`` and
        /// ``ABCBarRepeat/followingPlayCount``.
        case `repeat`

        /// A plain (thin) bar line: `|`.
        case standard
    }
}

// MARK: - Equatable

extension ABCBarRepeat.BarLine: Equatable {
}

// MARK: - Hashable

extension ABCBarRepeat.BarLine: Hashable {
}

// MARK: - Sendable

extension ABCBarRepeat.BarLine: Sendable {
}
