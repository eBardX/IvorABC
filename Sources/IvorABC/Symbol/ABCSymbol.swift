// © 2025–2026 John Gary Pusey (see LICENSE.md)

private import XestiTools

/// A symbol in ABC music notation.
public enum ABCSymbol {
    /// An annotation.
    case annotation(ABCAnnotation)

    /// A bar repeat marker.
    ///
    /// The string is the verbatim ABC bar repeat notation, such as `|:`,
    /// `:|`, `||`, or `|`.
    case barRepeat(String)  // validate ???

    /// A beam-break marker.
    ///
    /// Represents explicit whitespace between symbols in the ABC source.
    /// Notes and chords not separated by a beam-break are beamed together;
    /// those with a beam-break between them start a new beam group.
    case beamBreak

    /// A broken rhythm marker.
    case brokenRhythm(ABCBrokenRhythm)

    /// A chord.
    case chord(ABCChord)

    /// A chord symbol.
    ///
    /// The string is the chord name without the surrounding quotes,
    /// e.g. `Am` or `G7`.
    case chordSymbol(String)    // validate ???

    /// A decoration.
    case decoration(ABCDecoration)

    /// A group of grace notes.
    case graceNotes(ABCGraceNotes)

    /// An inline field.
    case inlineField(ABCField)

    /// A macro call.
    ///
    /// The associated ``ABCMacroCall`` stores the verbatim trigger text for
    /// round-trip fidelity and the pre-parsed expansion for semantic consumers.
    case macroCall(ABCMacroCall)

    /// A note.
    case note(ABCNote)

    /// A voice overlay marker (`&`).
    case overlay

    /// A rest.
    case rest(ABCRest)

    case shorthand(ABCShorthand)

    /// A slur marker.
    case slur(ABCSlur)

    /// A typesetting spacer (`y`).
    ///
    /// The associated `ABCDuration` value is the width of the spacer.
    case spacer(ABCDuration)

    /// A tuplet specification.
    ///
    /// Use ``resolveTuplet(meter:)`` or ``ABCTuplet/resolve(meter:)`` to
    /// obtain the fully resolved `(p, q, r)` values with ABC default rules
    /// applied for any `nil` component.
    case tuplet(ABCTuplet)

    /// A variant ending marker.
    case variantEnding(ABCVariantEnding)
}

// MARK: - Equatable

extension ABCSymbol: Equatable {
}

// MARK: - Sendable

extension ABCSymbol: Sendable {
}
