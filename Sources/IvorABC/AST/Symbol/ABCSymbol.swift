// © 2025–2026 John Gary Pusey (see LICENSE.md)

private import XestiTools

/// A symbol in ABC music notation.
///
/// See §4 (“The tune body”) of the ABC 2.1 standard.
public enum ABCSymbol {
    /// An annotation (§4.19).
    case annotation(ABCAnnotation)

    /// A bar line marker (§4.8).
    case barLine(ABCBarLine)

    /// A beam-break marker (§4.7).
    ///
    /// Represents explicit whitespace between symbols in the ABC source.
    /// Notes and chords not separated by a beam-break are beamed together;
    /// those with a beam-break between them start a new beam group.
    case beamBreak

    /// A broken rhythm marker (§4.4).
    case brokenRhythm(ABCBrokenRhythm)

    /// A chord (§4.17).
    case chord(ABCChord)

    /// A chord symbol (§4.18).
    case chordSymbol(ABCChordSymbol)

    /// A decoration (§4.14).
    case decoration(ABCDecoration)

    /// A group of grace notes (§4.12).
    case graceNotes(ABCGraceNotes)

    /// An inline field (§3.2).
    case inlineField(ABCField)

    /// A note (§4.1).
    case note(ABCNote)

    /// A voice overlay marker (`&`, §7.4).
    case overlay

    /// A rest (§4.5).
    case rest(ABCRest)

    /// A redefinable shorthand character (§4.16).
    case shorthand(ABCShorthand)

    /// A slur marker (§4.11).
    case slur(ABCSlur)

    /// A typesetting spacer (`y`, §6.1.2).
    ///
    /// The associated ``ABCLength`` value is the written length of the spacer (a
    /// multiplier of the unit note length). A length modifier on `y` is not part
    /// of the ABC 2.1 spec but is widely supported as an extension.
    case spacer(ABCLength)

    /// A tuplet specification (§4.13).
    case tuplet(ABCTuplet)

    /// A variant ending marker (§4.10).
    case variantEnding(ABCVariantEnding)
}

// MARK: - Equatable

extension ABCSymbol: Equatable {
}

// MARK: - Sendable

extension ABCSymbol: Sendable {
}
