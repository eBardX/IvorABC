// © 2026 John Gary Pusey (see LICENSE.md)

extension ABCDecoration {

    // MARK: Public Nested Types

    /// The decoration delimiter dialect.
    ///
    /// ABC 2.1 uses `!…!` as the standard delimiter. The `+…+` form is a
    /// legacy dialect activated by the `I:decoration +` directive (§12.1.2).
    public enum Dialect {

        // MARK: Public Cases

        /// The `!…!` delimiter form, which is the default in ABC 2.1.
        case bang

        /// The `+…+` delimiter form, which requires `I:decoration +`.
        case plus
    }
}

// MARK: - Equatable

extension ABCDecoration.Dialect: Equatable {
}

// MARK: - Sendable

extension ABCDecoration.Dialect: Sendable {
}
