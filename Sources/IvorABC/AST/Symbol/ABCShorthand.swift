// © 2026 John Gary Pusey (see LICENSE.md)

/// A shorthand character used in the tune body of ABC notation.
///
/// The character `.` has a fixed meaning (staccato mark), while `~`, `H`–`W`,
/// and `h`–`w` are redefinable symbols (§4.16) that can be assigned via the
/// `U:` field to represent a decoration or annotation.
public enum ABCShorthand {
    /// The shorthand character `.`.
    case dot

    /// The shorthand character `h`.
    case hLower

    /// The shorthand character `H`.
    case hUpper

    /// The shorthand character `i`.
    case iLower

    /// The shorthand character `I`.
    case iUpper

    /// The shorthand character `j`.
    case jLower

    /// The shorthand character `J`.
    case jUpper

    /// The shorthand character `k`.
    case kLower

    /// The shorthand character `K`.
    case kUpper

    /// The shorthand character `l`.
    case lLower

    /// The shorthand character `L`.
    case lUpper

    /// The shorthand character `m`.
    case mLower

    /// The shorthand character `M`.
    case mUpper

    /// The shorthand character `n`.
    case nLower

    /// The shorthand character `N`.
    case nUpper

    /// The shorthand character `o`.
    case oLower

    /// The shorthand character `O`.
    case oUpper

    /// The shorthand character `p`.
    case pLower

    /// The shorthand character `P`.
    case pUpper

    /// The shorthand character `q`.
    case qLower

    /// The shorthand character `Q`.
    case qUpper

    /// The shorthand character `r`.
    case rLower

    /// The shorthand character `R`.
    case rUpper

    /// The shorthand character `s`.
    case sLower

    /// The shorthand character `S`.
    case sUpper

    /// The shorthand character `~`.
    case tilde

    /// The shorthand character `t`.
    case tLower

    /// The shorthand character `T`.
    case tUpper

    /// The shorthand character `u`.
    case uLower

    /// The shorthand character `U`.
    case uUpper

    /// The shorthand character `v`.
    case vLower

    /// The shorthand character `V`.
    case vUpper

    /// The shorthand character `w`.
    case wLower

    /// The shorthand character `W`.
    case wUpper
}

// MARK: - Equatable

extension ABCShorthand: Equatable {
}

// MARK: - Sendable

extension ABCShorthand: Sendable {
}
