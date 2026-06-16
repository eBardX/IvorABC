// © 2026 John Gary Pusey (see LICENSE.md)

/// An ABC decoration.
///
/// Decorations appear in a tune body as longhand (`!name!`) or legacy longhand
/// (`+name+`). The ``name`` property holds the decoration name without delimiters.
/// The ``dialect`` property records the active delimiter dialect: ``Dialect/bang``
/// for `!name!` (the ABC 2.1 default), ``Dialect/plus`` for `+name+` (the legacy
/// form enabled by `I:decoration +`).
public struct ABCDecoration {

    // MARK: Public Initializers

    /// Creates a new decoration, or `nil` if `name` is empty.
    ///
    /// - Parameter name:    The decoration name (without delimiters), e.g. `"roll"`.
    ///                      Must not be empty.
    /// - Parameter dialect: The delimiter dialect in effect; defaults to
    ///                      ``Dialect/bang`` (ABC 2.1 standard).
    public init?(name: String,
                 dialect: Dialect = .bang) {
        guard !name.isEmpty
        else { return nil }

        self.dialect = dialect
        self.name = name
    }

    // MARK: Public Instance Properties

    /// The delimiter dialect for this decoration: ``Dialect/bang`` (`!name!`) or
    /// ``Dialect/plus`` (`+name+`). Defaults to ``Dialect/bang`` when constructed
    /// directly rather than parsed.
    public let dialect: Dialect

    /// The decoration name, without delimiters.
    public let name: String             // ABCDecoration.Name (StringRepresentable) ???
}

// MARK: -

extension ABCDecoration {

    // MARK: Internal Type Properties

    // The shorthand characters that are pre-defined by the ABC specification
    // and do not require a `U:` field definition.
    internal static let builtinShorthands: Set<Character> = [".",
                                                             "~",
                                                             "H",
                                                             "L",
                                                             "M",
                                                             "O",
                                                             "P",
                                                             "S",
                                                             "T",
                                                             "u",
                                                             "v"]
}

// MARK: - Equatable

extension ABCDecoration: Equatable {

    // MARK: Public Type Methods

    /// Two decorations are equal when their ``name`` values match; ``dialect`` is
    /// intentionally excluded because it is a formatting detail rather than part of
    /// the decoration's identity.
    public static func == (lhs: Self,
                           rhs: Self) -> Bool {
        lhs.name == rhs.name
    }
}

// MARK: - Sendable

extension ABCDecoration: Sendable {
}
