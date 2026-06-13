// © 2026 John Gary Pusey (see LICENSE.md)

/// An ABC decoration.
///
/// Decorations appear in a tune body as longhand (`!name!`), legacy longhand
/// (`+name+`), or shorthand (a single character such as `~` or `.`). The ``name``
/// property always holds the resolved decoration name. The ``shorthand`` property is
/// non-`nil` only when the decoration was written as a shorthand character. The
/// ``dialect`` property records the active delimiter dialect: ``Dialect/bang`` for
/// `!name!` (the ABC 2.1 default), ``Dialect/plus`` for `+name+` (the legacy
/// form enabled by `I:decoration +`). For shorthand decorations, it reflects the
/// dialect that was active when the decoration was parsed. Both ``shorthand`` and
/// ``dialect`` allow the original notation to be reproduced.
public struct ABCDecoration {

    // MARK: Public Initializers

    /// Creates a new decoration, or `nil` if `name` is empty.
    ///
    /// - Parameter name:      The decoration name (without delimiters), e.g.
    ///                        `"roll"`. Must not be empty.
    /// - Parameter shorthand: The shorthand character, if the decoration was written
    ///                        as a shorthand (e.g. `~`); otherwise `nil`.
    /// - Parameter dialect:   The delimiter dialect in effect; defaults to
    ///                        ``Dialect/bang`` (ABC 2.1 standard).
    public init?(name: String,
                 shorthand: Character? = nil,
                 dialect: Dialect = .bang) {
        guard !name.isEmpty
        else { return nil }

        self.init(name, shorthand, dialect)
    }

    // MARK: Public Instance Properties

    /// The delimiter dialect for this decoration: ``Dialect/bang`` (`!name!`) or
    /// ``Dialect/plus`` (`+name+`). Defaults to ``Dialect/bang`` when constructed
    /// directly rather than parsed.
    public let dialect: Dialect

    /// The decoration name, without delimiters.
    public let name: String

    /// The shorthand character used to write this decoration, or `nil` if it was
    /// written in longhand (`!name!`) or legacy (`+name+`) form.
    public let shorthand: Character?

    // MARK: Internal Initializers

    internal init(_ name: String,
                  _ shorthand: Character?,
                  _ dialect: Dialect) {
        self.dialect = dialect
        self.name = name
        self.shorthand = shorthand
    }
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

    /// Two decorations are equal when their ``name`` and ``shorthand`` match;
    /// ``dialect`` is intentionally excluded because it is a formatting detail
    /// rather than part of the decoration's identity.
    public static func == (lhs: Self,
                           rhs: Self) -> Bool {
        (lhs.name, lhs.shorthand) == (rhs.name, rhs.shorthand)
    }
}

// MARK: - Sendable

extension ABCDecoration: Sendable {
}
