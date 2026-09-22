// © 2026 John Gary Pusey (see LICENSE.md)

/// A value from an ABC 1.6 `E:` (elemskip) field.
///
/// The value sets the `\elemskip` TeX dimension used by `abc2mtex` to control
/// horizontal note spacing on a staff. It may be an integer or a decimal.
///
/// See §10.1 (“Outdated information field syntax”) of the ABC 2.1 standard.
public enum ABCElemskip {
    /// A decimal spacing value.
    case decimal(Double)

    /// An integer spacing value.
    case integer(Int)
}

// MARK: - Equatable

extension ABCElemskip: Equatable {
}

// MARK: - Sendable

extension ABCElemskip: Sendable {
}
