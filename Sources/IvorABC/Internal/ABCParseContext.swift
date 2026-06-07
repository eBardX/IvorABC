// © 2025–2026 John Gary Pusey (see LICENSE.md)

internal struct ABCParseContext {

    // MARK: Internal Initializers

    internal init() {
        self.accidentalsInKey = [:]
        self.definedUserSymbols = []
        self.isCompoundMeter = false
    }

    // MARK: Internal Instance Properties

    internal var accidentalsInKey: [ABCPitch.Letter: ABCPitch.Accidental]
    internal var definedUserSymbols: Set<Character>
    internal var isCompoundMeter: Bool

    internal var baseDuration: ABCDuration {
        durationFromUnitNoteLength ?? durationFromMeter ?? Self.durationEighths
    }

    // MARK: Private Instance Properties

    private var durationFromMeter: ABCDuration?
    private var durationFromUnitNoteLength: ABCDuration?
}

// MARK: -

extension ABCParseContext {

    // MARK: Internal Instance Methods

    internal mutating func update(with field: ABCField) {
        switch field {
        case let .key(keySignature):
            accidentalsInKey = Self._determineAccidentals(in: keySignature)

        case let .meter(timeSignature):
            durationFromMeter = Self._determineDuration(from: timeSignature)
            isCompoundMeter = timeSignature.isCompound

        case let .unitNoteLength(duration):
            durationFromUnitNoteLength = duration

        case let .userSymbol(userSymbol):
            definedUserSymbols.insert(userSymbol.symbol)

        default:
            break
        }
    }

    // MARK: Private Type Properties

    private static let accidentalCounts: [ABCKeySignature.Tonic: [ABCKeySignature.Mode: Int]] = [.a: [.dorian: 1,
                                                                                                      .locrian: -2,
                                                                                                      .lydian: 4,
                                                                                                      .major: 3,
                                                                                                      .minor: 0,
                                                                                                      .mixolydian: 2,
                                                                                                      .phrygian: -1],
                                                                                                 .aFlat: [.dorian: -6,
                                                                                                          .lydian: -3,
                                                                                                          .major: -4,
                                                                                                          .minor: -7,
                                                                                                          .mixolydian: -5],
                                                                                                 .aSharp: [.locrian: 5,
                                                                                                           .minor: 7,
                                                                                                           .phrygian: 6],
                                                                                                 .b: [.dorian: 3,
                                                                                                      .locrian: 0,
                                                                                                      .lydian: 6,
                                                                                                      .major: 5,
                                                                                                      .minor: 2,
                                                                                                      .mixolydian: 4,
                                                                                                      .phrygian: 1],
                                                                                                 .bFlat: [.dorian: -4,
                                                                                                          .locrian: -7,
                                                                                                          .lydian: -1,
                                                                                                          .major: -2,
                                                                                                          .minor: -5,
                                                                                                          .mixolydian: -3,
                                                                                                          .phrygian: -6],
                                                                                                 .bSharp: [.locrian: 7],
                                                                                                 .c: [.dorian: -2,
                                                                                                      .locrian: -5,
                                                                                                      .lydian: 1,
                                                                                                      .major: 0,
                                                                                                      .minor: -3,
                                                                                                      .mixolydian: -1,
                                                                                                      .phrygian: -4],
                                                                                                 .cFlat: [.lydian: -6,
                                                                                                          .major: -7],
                                                                                                 .cSharp: [.dorian: 5,
                                                                                                           .locrian: 2,
                                                                                                           .major: 7,
                                                                                                           .minor: 4,
                                                                                                           .mixolydian: 6,
                                                                                                           .phrygian: 3],
                                                                                                 .d: [.dorian: 0,
                                                                                                      .locrian: -3,
                                                                                                      .lydian: 3,
                                                                                                      .major: 2,
                                                                                                      .minor: -1,
                                                                                                      .mixolydian: 1,
                                                                                                      .phrygian: -2],
                                                                                                 .dFlat: [.dorian: -7,
                                                                                                          .lydian: -4,
                                                                                                          .major: -5,
                                                                                                          .mixolydian: -6],
                                                                                                 .dSharp: [.dorian: 7,
                                                                                                           .locrian: 4,
                                                                                                           .minor: 6,
                                                                                                           .phrygian: 5],
                                                                                                 .e: [.dorian: 2,
                                                                                                      .locrian: -1,
                                                                                                      .lydian: 5,
                                                                                                      .major: 4,
                                                                                                      .minor: 1,
                                                                                                      .mixolydian: 3,
                                                                                                      .phrygian: 0],
                                                                                                 .eFlat: [.dorian: -5,
                                                                                                          .lydian: -2,
                                                                                                          .major: -3,
                                                                                                          .minor: -6,
                                                                                                          .mixolydian: -4,
                                                                                                          .phrygian: -7],
                                                                                                 .eSharp: [.locrian: 6,
                                                                                                           .phrygian: 7],
                                                                                                 .f: [.dorian: -3,
                                                                                                      .locrian: -6,
                                                                                                      .lydian: 0,
                                                                                                      .major: -1,
                                                                                                      .minor: -4,
                                                                                                      .mixolydian: -2,
                                                                                                      .phrygian: -5],
                                                                                                 .fFlat: [.lydian: -7],
                                                                                                 .fSharp: [.dorian: 4,
                                                                                                           .locrian: 1,
                                                                                                           .lydian: 7,
                                                                                                           .major: 6,
                                                                                                           .minor: 3,
                                                                                                           .mixolydian: 5,
                                                                                                           .phrygian: 2],
                                                                                                 .g: [.dorian: -1,
                                                                                                      .locrian: -4,
                                                                                                      .lydian: 2,
                                                                                                      .major: 1,
                                                                                                      .minor: -2,
                                                                                                      .mixolydian: 0,
                                                                                                      .phrygian: -3],
                                                                                                 .gFlat: [.lydian: -5,
                                                                                                          .major: -6,
                                                                                                          .mixolydian: -7],
                                                                                                 .gSharp: [.dorian: 6,
                                                                                                           .locrian: 3,
                                                                                                           .minor: 5,
                                                                                                           .mixolydian: 7,
                                                                                                           .phrygian: 4]]

    private static let accidentals: [Int: [ABCPitch.Letter: ABCPitch.Accidental]] = [-7: [.a: .flat,
                                                                                          .b: .flat,
                                                                                          .c: .flat,
                                                                                          .d: .flat,
                                                                                          .e: .flat,
                                                                                          .f: .flat,
                                                                                          .g: .flat],
                                                                                     -6: [.a: .flat,
                                                                                          .b: .flat,
                                                                                          .c: .flat,
                                                                                          .d: .flat,
                                                                                          .e: .flat,
                                                                                          .g: .flat],
                                                                                     -5: [.a: .flat,
                                                                                          .b: .flat,
                                                                                          .d: .flat,
                                                                                          .e: .flat,
                                                                                          .g: .flat],
                                                                                     -4: [.a: .flat,
                                                                                          .b: .flat,
                                                                                          .d: .flat,
                                                                                          .e: .flat],
                                                                                     -3: [.a: .flat,
                                                                                          .b: .flat,
                                                                                          .e: .flat],
                                                                                     -2: [.b: .flat,
                                                                                          .e: .flat],
                                                                                     -1: [.b: .flat],
                                                                                     0: [:],
                                                                                     1: [.f: .sharp],
                                                                                     2: [.c: .sharp,
                                                                                         .f: .sharp],
                                                                                     3: [.c: .sharp,
                                                                                         .f: .sharp,
                                                                                         .g: .sharp],
                                                                                     4: [.c: .sharp,
                                                                                         .d: .sharp,
                                                                                         .f: .sharp,
                                                                                         .g: .sharp],
                                                                                     5: [.a: .sharp,
                                                                                         .c: .sharp,
                                                                                         .d: .sharp,
                                                                                         .f: .sharp,
                                                                                         .g: .sharp],
                                                                                     6: [.a: .sharp,
                                                                                         .c: .sharp,
                                                                                         .d: .sharp,
                                                                                         .e: .sharp,
                                                                                         .f: .sharp,
                                                                                         .g: .sharp],
                                                                                     7: [.a: .sharp,
                                                                                         .b: .sharp,
                                                                                         .c: .sharp,
                                                                                         .d: .sharp,
                                                                                         .e: .sharp,
                                                                                         .f: .sharp,
                                                                                         .g: .sharp]]

    private static let durationEighths = ABCDuration(numerator: 1,
                                                     denominator: 8,
                                                     reduce: false)

    private static let durationSixteenths = ABCDuration(numerator: 1,
                                                        denominator: 16,
                                                        reduce: false)

    // MARK: Private Type Methods

    private static func _determineAccidentals(in keySignature: ABCKeySignature) -> [ABCPitch.Letter: ABCPitch.Accidental] {
        var accidentals = _determineBaseAccidentals(in: keySignature)

        switch keySignature {
        case let .standard(_, _, pitches, _):
            for pitch in pitches {
                accidentals[pitch.letter] = pitch.accidental
            }

        default:
            break
        }

        return accidentals
    }

    private static func _determineBaseAccidentals(in keySignature: ABCKeySignature) -> [ABCPitch.Letter: ABCPitch.Accidental] {
        switch keySignature {
        case .empty:
            return [:]

        case .highlandPipes:
            return [:]

        case .highlandPipesPreset:
            return [.c: .sharp,
                    .f: .sharp,
                    .g: .natural]

        case .clefOnly:
            return [:]

        case let .standard(tonic, mode, _, _):
            guard let emode = _determineEffectiveMode(for: mode),
                  let count = accidentalCounts[tonic]?[emode]
            else { return [:] }

            return accidentals[count] ?? [:]
        }
    }

    private static func _determineDuration(from timeSignature: ABCTimeSignature) -> ABCDuration {
        switch timeSignature {
        case let .explicit(fraction):
            if Double(fraction.numerator) / Double(fraction.denominator) < 0.75 {
                durationSixteenths
            } else {
                durationEighths
            }

        default:
            durationEighths
        }
    }

    private static func _determineEffectiveMode(for mode: ABCKeySignature.Mode) -> ABCKeySignature.Mode? {
        switch mode {
        case .aeolian:
            .minor

        case .explicit:
            nil

        case .ionian:
            .major

        default:
            mode
        }
    }
}

// MARK: - Sendable

extension ABCParseContext: Sendable {
}
