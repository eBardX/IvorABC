// © 2025–2026 John Gary Pusey (see LICENSE.md)

/// An ABC key signature.
public enum ABCKeySignature {
    /// A clef-only specification (no tonic), e.g., `K:clef=treble`.
    case clefOnly(Clef)

    /// An empty (key-less) key signature.
    case empty

    /// A Highland pipes key signature with no accidentals (`K:HP`).
    case highlandPipes

    /// A Highland pipes key signature with preset accidentals F♯, C♯, G♯ (`K:Hp`).
    case highlandPipesPreset

    /// A standard key signature with the specified tonic, mode, accidentals,
    /// and optional clef properties.
    case standard(Standard)
}

// MARK: -

extension ABCKeySignature {

    // MARK: Public Nested Types

    /// A type alias for ``ABCPitch`` used to represent accidentals in a key
    /// signature.
    public typealias Accidental = ABCPitch

    // MARK: Public Instance Properties

    /// The accidentals implied by this key signature, keyed by pitch letter.
    ///
    /// Combines the accidentals from the tonic and mode with any
    /// ``Standard/extraAccidentals`` (e.g., `K:D Phr ^f`). Does not
    /// include bar-level accidentals set by notes during the piece — use
    /// ``ABCAccidentalContext`` to track those.
    public var accidentals: [ABCPitch.Letter: ABCPitch.Accidental] {
        var result = baseAccidentals

        if case let .standard(std) = self {
            for pitch in std.extraAccidentals where pitch.accidental != .omitted {
                result[pitch.letter] = pitch.accidental
            }
        }

        return result
    }

    // MARK: Private Type Properties

    private static let standardAccidentals: [Int: [ABCPitch.Letter: ABCPitch.Accidental]] =
        [-7: [.a: .flat, .b: .flat, .c: .flat, .d: .flat, .e: .flat, .f: .flat, .g: .flat],
         -6: [.a: .flat, .b: .flat, .c: .flat, .d: .flat, .e: .flat, .g: .flat],
         -5: [.a: .flat, .b: .flat, .d: .flat, .e: .flat, .g: .flat],
         -4: [.a: .flat, .b: .flat, .d: .flat, .e: .flat],
         -3: [.a: .flat, .b: .flat, .e: .flat],
         -2: [.b: .flat, .e: .flat],
         -1: [.b: .flat],
         0: [:],
         1: [.f: .sharp],
         2: [.c: .sharp, .f: .sharp],
         3: [.c: .sharp, .f: .sharp, .g: .sharp],
         4: [.c: .sharp, .d: .sharp, .f: .sharp, .g: .sharp],
         5: [.a: .sharp, .c: .sharp, .d: .sharp, .f: .sharp, .g: .sharp],
         6: [.a: .sharp, .c: .sharp, .d: .sharp, .e: .sharp, .f: .sharp, .g: .sharp],
         7: [.a: .sharp, .b: .sharp, .c: .sharp, .d: .sharp, .e: .sharp, .f: .sharp, .g: .sharp]]

    // MARK: Private Instance Properties

    private var baseAccidentals: [ABCPitch.Letter: ABCPitch.Accidental] {
        switch self {
        case .clefOnly,
             .empty,
             .highlandPipes:
            return [:]

        case .highlandPipesPreset:
            return [.c: .sharp,
                    .f: .sharp,
                    .g: .natural]

        case let .standard(standard):
            let emode = Mode.effectiveMode(for: standard.mode)

            guard let count = Standard.accidentalCounts[standard.tonic]?[emode]
            else { return [:] }

            return Self.standardAccidentals[count] ?? [:]
        }
    }
}

// MARK: - Equatable

extension ABCKeySignature: Equatable {
}

// MARK: - Sendable

extension ABCKeySignature: Sendable {
}
