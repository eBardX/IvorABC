// © 2026 John Gary Pusey (see LICENSE.md)

/// An ABC decoration.
///
/// Decorations appear in a tune body as longhand (`!name!`), legacy longhand
/// (`+name+`), or shorthand (a single character such as `~` or `.`). The ``name``
/// property always holds the resolved decoration name. The ``shorthand`` property is
/// non-`nil` only when the decoration was written as a shorthand character; the
/// formatter uses it to reproduce the original notation.
public struct ABCDecoration {

    // MARK: Public Initializers

    /// Creates a new decoration.
    ///
    /// - Parameter name:      The decoration name (without delimiters), e.g. `"roll"`.
    /// - Parameter shorthand: The shorthand character, if the decoration was written
    ///                        as a shorthand (e.g. `~`); otherwise `nil`.
    public init(name: String,
                shorthand: Character? = nil) {
        self.name = name
        self.shorthand = shorthand
    }

    // MARK: Public Instance Properties

    /// The decoration name, without delimiters.
    public let name: String

    /// The shorthand character used to write this decoration, or `nil` if it was
    /// written in longhand (`!name!`) or legacy (`+name+`) form.
    public let shorthand: Character?
}

// MARK: - Equatable

extension ABCDecoration: Equatable {
}

// MARK: - Sendable

extension ABCDecoration: Sendable {
}
