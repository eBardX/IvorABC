// © 2026 John Gary Pusey (see LICENSE.md)

extension ABCMacro {

    // MARK: Internal Nested Types

    // Which flavor of macro a target pattern describes.
    internal enum Kind {
        // The target has no trailing `n` note-slot; it matches a fixed
        // literal symbol sequence.
        case `static`

        // The target ends with a trailing `n` note-slot (optionally
        // followed by a required written length); it matches a literal
        // prefix followed by any note of that length.
        case transposing
    }
}

// MARK: - Equatable

extension ABCMacro.Kind: Equatable {
}

// MARK: - Sendable

extension ABCMacro.Kind: Sendable {
}
