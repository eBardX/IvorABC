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

    /// Creates a new decoration with the ``Dialect/bang`` dialect, or `nil` if
    /// `name` fails forthcoming validation.
    ///
    /// - Parameter name: The decoration name (without delimiters), e.g.
    ///                   `ABCDecoration.Name("roll")`.
    public init?(name: Name) {
        self.init(name: name,
                  dialect: .bang)
    }

    // MARK: Public Instance Properties

    /// The delimiter dialect for this decoration: ``Dialect/bang`` (`!name!`) or
    /// ``Dialect/plus`` (`+name+`). Always ``Dialect/bang`` for directly-constructed
    /// decorations; may be ``Dialect/plus`` for decorations produced by the parser.
    public let dialect: Dialect

    /// The decoration name, without delimiters.
    public let name: Name
}

// MARK: -

extension ABCDecoration {

    // MARK: Internal Initializers

    internal init?(name: Name,
                   dialect: Dialect) {
        guard Self._isValid(name, dialect)
        else { return nil }

        self.dialect = dialect
        self.name = name
    }

    // MARK: Internal Instance Properties

    // A Boolean value indicating whether this decoration uses a legacy dialect
    // that ``ABCNormalizer`` rewrites when normalizing to the current ABC version.
    internal var needsNormalization: Bool {
        dialect == .plus
    }

    // MARK: Private Type Methods

    private static func _isValid(_ name: Name,
                                 _ dialect: Dialect) -> Bool {
        // `!+!` is ok, `+++` is not
        dialect == .bang || !name.stringValue.contains("+")
    }
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
