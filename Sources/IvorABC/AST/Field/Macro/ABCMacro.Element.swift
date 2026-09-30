// © 2026 John Gary Pusey (see LICENSE.md)

extension ABCMacro {

    // MARK: Internal Nested Types

    // One element of a pre-parsed transposing-macro replacement template.
    internal enum Element {
        // A note-slot in the replacement, referring to the matched note
        // transposed diatonically by `diatonicOffset` scale steps (`0` for
        // the `n` placeholder itself), with the given written length.
        case placeholder(diatonicOffset: Int, length: ABCLength)

        case symbol(ABCSymbol)
    }
}

// MARK: - Equatable

extension ABCMacro.Element: Equatable {
}

// MARK: - Sendable

extension ABCMacro.Element: Sendable {
}
