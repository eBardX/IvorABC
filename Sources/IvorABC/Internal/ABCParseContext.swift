// © 2025–2026 John Gary Pusey (see LICENSE.md)

internal struct ABCParseContext {

    // MARK: Internal Initializers

    internal init() {
        self.accidentalsInKey = [:]
        self.isCompoundMeter = false
        self.userSymbolDecorations = [:]
    }

    // MARK: Internal Instance Properties

    internal var accidentalsInKey: [ABCPitch.Letter: ABCPitch.Accidental]
    internal var isCompoundMeter: Bool
    internal var userSymbolDecorations: [Character: String]

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
            accidentalsInKey = keySignature.keyAccidentals

        case let .meter(timeSignature):
            durationFromMeter = Self._determineDuration(from: timeSignature)
            isCompoundMeter = timeSignature.isCompound

        case let .unitNoteLength(duration):
            durationFromUnitNoteLength = duration

        case let .userSymbol(userSymbol):
            let raw = userSymbol.decoration
            let name: String = if raw.count >= 2,
                                  (raw.first == "!" && raw.last == "!") || (raw.first == "+" && raw.last == "+") {
                String(raw.dropFirst().dropLast())
            } else {
                raw
            }

            userSymbolDecorations[userSymbol.symbol] = name

        default:
            break
        }
    }

    // MARK: Private Type Properties

    private static let durationEighths = ABCDuration(numerator: 1,
                                                     denominator: 8,
                                                     reduce: false)

    private static let durationSixteenths = ABCDuration(numerator: 1,
                                                        denominator: 16,
                                                        reduce: false)

    // MARK: Private Type Methods

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
}

// MARK: - Sendable

extension ABCParseContext: Sendable {
}
