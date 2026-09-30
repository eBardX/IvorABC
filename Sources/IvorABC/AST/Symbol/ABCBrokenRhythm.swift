// © 2026 John Gary Pusey (see LICENSE.md)

/// A broken rhythm marker in ABC notation.
///
/// The six cases correspond to the one, two, or three `>` or `<` characters
/// that can appear between two notes. For `n` `>` characters the left note is
/// lengthened and the right note shortened; `<` characters reverse the two
/// sides.
///
/// See §4.4 (“Broken rhythm”) of the ABC 2.1 standard.
public enum ABCBrokenRhythm {
    /// A single `>`: left note dotted, right note halved.
    case dotted

    /// A double `>>`: left note double-dotted, right note quartered.
    case doubleDotted

    /// A single `<`: left note halved, right note dotted.
    case reverseDotted

    /// A double `<<`: left note quartered, right note double-dotted.
    case reverseDoubleDotted

    /// A triple `<<<`: left note divided by 8, right note triple-dotted.
    case reverseTripleDotted

    /// A triple `>>>`: left note triple-dotted, right note divided by 8.
    case tripleDotted
}

// MARK: -

extension ABCBrokenRhythm {

    // MARK: Internal Instance Properties

    internal var factor: Int {
        switch self {
        case .dotted,
             .reverseDotted:
            1

        case .doubleDotted,
             .reverseDoubleDotted:
            2

        case .reverseTripleDotted,
             .tripleDotted:
            3
        }
    }
}

// MARK: - Equatable

extension ABCBrokenRhythm: Equatable {
}

// MARK: - Sendable

extension ABCBrokenRhythm: Sendable {
}
