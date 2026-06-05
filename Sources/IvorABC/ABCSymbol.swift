// © 2025–2026 John Gary Pusey (see LICENSE.md)

private import XestiTools

/// A symbol in ABC music notation.
public enum ABCSymbol {
    /// An annotation.
    case annotation(String)

    /// A bar repeat marker.
    case barRepeat(String)

    /// A broken rhythm marker.
    case brokenRhythm(String)

    /// A chord.
    ///
    /// The associated `[ABCNote]` value holds the notes in the chord. The
    /// `ABCDuration` value is the chord-level duration (i.e. the duration
    /// written after the closing `]`). The `Bool` value indicates whether the
    /// chord is tied to the next chord or note.
    case chord([ABCNote], ABCDuration, Bool)

    /// A chord symbol.
    case chordSymbol(String)

    /// A decoration.
    case decoration(String)

    /// A group of grace notes.
    ///
    /// The associated `Bool` value indicates whether the grace note group has
    /// a slash (acciaccatura).
    case graceNotes(Bool, [ABCNote])

    /// An inline field.
    case inlineField(ABCField)

    /// A note.
    case note(ABCNote)

    /// A voice overlay marker (`&`).
    case overlay

    /// A rest.
    case rest(ABCRest)

    /// A slur marker.
    case slur(String)

    /// A typesetting spacer (`y`).
    ///
    /// The associated `ABCDuration` value is the width of the spacer.
    case spacer(ABCDuration)

    /// A tuplet specification.
    ///
    /// The three associated `UInt` values correspond to the `p`, `q`, and `r`
    /// components of the ABC tuplet notation `(p:q:r`.
    case tuplet(UInt, UInt, UInt)

    /// A variant ending marker.
    case variantEnding(String)
}

// MARK: - Equatable

extension ABCSymbol: Equatable {
}

// MARK: - Sendable

extension ABCSymbol: Sendable {
}
