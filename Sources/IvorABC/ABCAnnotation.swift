// © 2026 John Gary Pusey (see LICENSE.md)

/// An annotation in ABC music notation.
public struct ABCAnnotation {

    // MARK: Public Instance Properties

    /// The position of the annotation relative to the staff.
    public let position: Position

    /// The annotation text, without the surrounding quotes or positioning prefix.
    public let text: String

    // MARK: Public Initializers

    public init(position: Position,
                text: String) {
        self.position = position
        self.text = text
    }
}

// MARK: -

extension ABCAnnotation {

    // MARK: Internal Initializers

    /// Parses an annotation from the verbatim content between the quotes, which
    /// must begin with a valid positioning prefix character.
    internal init?(stringValue: some StringProtocol) {
        guard let first = stringValue.first,
              let pos = Position(prefix: first)
        else { return nil }

        self.position = pos
        self.text = String(stringValue.dropFirst())
    }

    // MARK: Internal Instance Properties

    internal var stringValue: String {
        String(position.prefix) + text
    }
}

// MARK: - Equatable

extension ABCAnnotation: Equatable {
}

// MARK: - Sendable

extension ABCAnnotation: Sendable {
}
