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
    case barRepeat(String)

    /// A beam-break marker.
    ///
    /// Represents explicit whitespace between symbols in the ABC source.
    /// Notes and chords not separated by a beam-break are beamed together;
    /// those with a beam-break between them start a new beam group.
    case beamBreak

    /// A broken rhythm marker.
    ///
    /// The string is the verbatim ABC broken rhythm notation: one to three
    /// `>` or `<` characters.
    case brokenRhythm(String)

    /// A chord.
    case chord(ABCChord)

    /// A chord symbol.
    ///
    /// The string is the chord name without the surrounding quotes,
    /// e.g. `Am` or `G7`.
    case chordSymbol(String)

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

    /// A slur marker.
    ///
    /// The string is `(` for a slur begin or `)` for a slur end.
    case slur(String)

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

// MARK: -

extension ABCSymbol {

    // MARK: Public Instance Methods

    /// Returns the effective durations of the notes immediately before and
    /// after a `.brokenRhythm` symbol.
    ///
    /// Pass the written `ABCDuration` of the note before the marker as `left`
    /// and the note after as `right`. The returned tuple contains the
    /// corresponding effective durations.
    ///
    /// For `n` `>` characters, the left note is lengthened by a factor of
    /// `(2^(n+1)−1) / 2^n` and the right note shortened by `1 / 2^n`
    /// (e.g. `>`: ×3/2 and ×1/2; `>>`: ×7/4 and ×1/4). `<` reverses the
    /// two sides.
    ///
    /// - Parameter left:   The written duration of the note before the marker.
    /// - Parameter right:  The written duration of the note after the marker.
    ///
    /// - Returns:  The effective `(left, right)` durations, or `nil` if the
    ///             symbol is not a `.brokenRhythm`.
    public func resolveBrokenRhythm(left: ABCDuration,
                                    right: ABCDuration) -> (left: ABCDuration, right: ABCDuration)? {
        guard case let .brokenRhythm(s) = self,
              let first = s.first
        else { return nil }

        let n = s.count
        let multDen = UInt(1) << n
        let longNum = (UInt(1) << (n + 1)) - 1

        func long(_ d: ABCDuration) -> ABCDuration {
            ABCFraction(numerator: d.numerator * longNum,
                        denominator: d.denominator * multDen,
                        reduce: true)
        }

        func short(_ d: ABCDuration) -> ABCDuration {
            ABCFraction(numerator: d.numerator,
                        denominator: d.denominator * multDen,
                        reduce: true)
        }

        return first == ">" ? (left: long(left), right: short(right))
                            : (left: short(left), right: long(right))
    }
}

// MARK: - Equatable

extension ABCSymbol: Equatable {
}

// MARK: - Sendable

extension ABCSymbol: Sendable {
}
