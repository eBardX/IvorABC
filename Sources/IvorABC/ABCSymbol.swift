// © 2025–2026 John Gary Pusey (see LICENSE.md)

private import XestiTools

/// A symbol in ABC music notation.
public enum ABCSymbol {
    /// An annotation.
    ///
    /// The string includes the positioning prefix (`^`, `_`, `@`, `<`, or
    /// `>`) but not the surrounding quotes.
    case annotation(String)

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
    ///
    /// The associated `[ABCNote]` value holds the notes in the chord. The
    /// `ABCDuration` value is the chord-level duration (i.e. the duration
    /// written after the closing `]`). The `Bool` value indicates whether the
    /// chord is tied to the next chord or note.
    case chord([ABCNote], ABCDuration, Bool)

    /// A chord symbol.
    ///
    /// The string is the chord name without the surrounding quotes,
    /// e.g. `Am` or `G7`.
    case chordSymbol(String)

    /// A decoration.
    case decoration(ABCDecoration)

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
    ///
    /// The string is `(` for a slur begin or `)` for a slur end.
    case slur(String)

    /// A typesetting spacer (`y`).
    ///
    /// The associated `ABCDuration` value is the width of the spacer.
    case spacer(ABCDuration)

    /// A tuplet specification.
    ///
    /// The first associated `UInt` is `p` (the number of notes in the tuplet
    /// group). The second and third are `q` (the beat count) and `r` (the
    /// number of notes affected), both `nil` when not explicitly written in
    /// the source. Use ``resolveTuplet(meter:)`` to obtain the fully resolved
    /// values with ABC default rules applied.
    case tuplet(UInt, UInt?, UInt?)

    /// A variant ending marker.
    ///
    /// The string is the verbatim ABC variant ending notation, such as
    /// `|1` or `|2,3`.
    case variantEnding(String)
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
    /// - Parameters:
    ///   - left:   The written duration of the note before the marker.
    ///   - right:  The written duration of the note after the marker.
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

    /// Returns the fully resolved `(p, q, r)` components of a `.tuplet`
    /// symbol with ABC default rules applied for any `nil` component.
    ///
    /// `r` defaults to `p`. `q` defaults based on `p` and whether `meter`
    /// is a compound meter: 3 when `p` is 2, 4, or 8; 2 when `p` is 3 or
    /// 6; otherwise 3 in compound meter or 2 in simple meter.
    ///
    /// - Parameter meter:  The current time signature, used to resolve a
    ///                     `nil` `q` value for non-standard tuplet sizes.
    ///                     Pass `nil` or omit to assume simple meter.
    ///
    /// - Returns:  The resolved `(p, q, r)` tuple, or `nil` if the symbol
    ///             is not a `.tuplet`.
    public func resolveTuplet(meter: ABCTimeSignature? = nil) -> (p: UInt, q: UInt, r: UInt)? {
        guard case let .tuplet(p, q, r) = self
        else { return nil }

        return (p,
                q ?? Self._defaultQ(p: p,
                                    isCompound: meter?.isCompound ?? false),
                r ?? p)
    }

    // MARK: Private Type Methods

    private static func _defaultQ(p: UInt,
                                  isCompound: Bool) -> UInt {
        switch p {
        case 2,
             4,
             8:
            3

        case 3,
             6:
            2

        default:
            isCompound ? 3 : 2
        }
    }
}

// MARK: - Equatable

extension ABCSymbol: Equatable {
}

// MARK: - Sendable

extension ABCSymbol: Sendable {
}
