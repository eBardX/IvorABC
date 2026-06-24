// © 2025–2026 John Gary Pusey (see LICENSE.md)

private import XestiTools

internal struct ABCParseContext {

    // MARK: Internal Initializers

    internal init() {
        self.accidentalsInKey = [:]
        self.decorationDialect = .bang
        self.globalDeassignedShorthands = []
        self.globalDecorationDialect = .bang
        self.globalDurationFromMeter = nil
        self.globalDurationFromUnitNoteLength = nil
        self.globalIsCompoundMeter = false
        self.globalUserSymbolDefinitions = Self.defaultUserSymbolDefinitions
        self.inTune = false
        self.isCompoundMeter = false
        self.tuneDeassignedShorthands = []
        self.tuneDurationFromMeter = nil
        self.tuneDurationFromUnitNoteLength = nil
        self.tuneUserSymbolDefinitions = [:]
    }

    // MARK: Internal Instance Properties

    internal var accidentalsInKey: [ABCPitch.Letter: ABCPitch.Accidental]
    internal var decorationDialect: ABCDecoration.Dialect
    internal var inTune: Bool
    internal var isCompoundMeter: Bool

    internal var baseDuration: ABCDuration {
        tuneDurationFromUnitNoteLength ?? tuneDurationFromMeter ?? Self.durationEighths
    }

    // MARK: Private Instance Properties

    private var globalDeassignedShorthands: Set<ABCShorthand>
    private var globalDecorationDialect: ABCDecoration.Dialect
    private var globalDurationFromMeter: ABCDuration?
    private var globalDurationFromUnitNoteLength: ABCDuration?
    private var globalIsCompoundMeter: Bool
    private var globalUserSymbolDefinitions: [ABCShorthand: ABCUserSymbol.Definition]
    private var tuneDeassignedShorthands: Set<ABCShorthand>
    private var tuneDurationFromMeter: ABCDuration?
    private var tuneDurationFromUnitNoteLength: ABCDuration?
    private var tuneUserSymbolDefinitions: [ABCShorthand: ABCUserSymbol.Definition]
}

// MARK: -

extension ABCParseContext {

    // MARK: Internal Instance Methods

    internal func isShorthandDeassigned(_ shorthand: ABCShorthand) -> Bool {
        guard !tuneDeassignedShorthands.contains(shorthand)
        else { return true }

        guard tuneUserSymbolDefinitions[shorthand] == nil
        else { return false }

        return globalDeassignedShorthands.contains(shorthand)
    }

    internal mutating func resetTuneScope() {
        accidentalsInKey = [:]   // K: is never valid in the file header
        decorationDialect = globalDecorationDialect
        tuneDurationFromMeter = globalDurationFromMeter
        tuneDurationFromUnitNoteLength = globalDurationFromUnitNoteLength
        isCompoundMeter = globalIsCompoundMeter
        tuneDeassignedShorthands = []
        tuneUserSymbolDefinitions = [:]
    }

    internal mutating func update(with directive: ABCDirective) {
        guard directive.name == .decoration
        else { return }

        switch directive.value {
        case "!":
            decorationDialect = .bang

            if !inTune {
                globalDecorationDialect = .bang
            }

        case "+":
            decorationDialect = .plus

            if !inTune {
                globalDecorationDialect = .plus
            }

        default:
            break
        }
    }

    internal mutating func update(with field: ABCField) {
        switch field {
        case let .instruction(directive):
            update(with: directive)

        case let .key(keySignature):
            accidentalsInKey = keySignature.accidentals

        case let .meter(timeSignature):
            let duration = Self._determineDuration(from: timeSignature)
            let compound = timeSignature.isCompound

            tuneDurationFromMeter = duration
            isCompoundMeter = compound

            if !inTune {
                globalDurationFromMeter = duration
                globalIsCompoundMeter = compound
            }

        case let .unitNoteLength(duration):
            tuneDurationFromUnitNoteLength = duration
            if !inTune {
                globalDurationFromUnitNoteLength = duration
            }

        case let .userDefined(userSymbol):
            if let definition = userSymbol.definition {
                if inTune {
                    tuneUserSymbolDefinitions[userSymbol.shorthand] = definition

                    tuneDeassignedShorthands.remove(userSymbol.shorthand)
                } else {
                    globalUserSymbolDefinitions[userSymbol.shorthand] = definition

                    globalDeassignedShorthands.remove(userSymbol.shorthand)
                }
            } else {
                if inTune {
                    tuneDeassignedShorthands.insert(userSymbol.shorthand)

                    tuneUserSymbolDefinitions[userSymbol.shorthand] = nil
                } else {
                    globalDeassignedShorthands.insert(userSymbol.shorthand)

                    globalUserSymbolDefinitions[userSymbol.shorthand] = nil
                }
            }

        default:
            break
        }
    }

    internal func userSymbolDefinition(for shorthand: ABCShorthand) -> ABCUserSymbol.Definition? {
        if tuneDeassignedShorthands.contains(shorthand) {
            return nil
        }

        if let def = tuneUserSymbolDefinitions[shorthand] {
            return def
        }

        if globalDeassignedShorthands.contains(shorthand) {
            return nil
        }

        return globalUserSymbolDefinitions[shorthand]
    }

    // MARK: Private Type Properties

    private static let defaultUserSymbolDefinitions: [ABCShorthand: ABCUserSymbol.Definition] = {
        func def(_ name: String) -> ABCUserSymbol.Definition {
            .decoration(ABCDecoration(name: ABCDecoration.Name(name)).require())
        }

        return [.hUpper: def("fermata"),
                .lUpper: def("accent"),
                .mUpper: def("lowermordent"),
                .oUpper: def("coda"),
                .pUpper: def("uppermordent"),
                .sUpper: def("segno"),
                .tilde: def("roll"),
                .tUpper: def("trill"),
                .uLower: def("upbow"),
                .vLower: def("downbow")]
    }()

    private static let durationEighths = ABCDuration(numerator: 1,
                                                     denominator: 8).require()
    private static let durationSixteenths = ABCDuration(numerator: 1,
                                                        denominator: 16).require()

    // MARK: Private Type Methods

    private static func _determineDuration(from timeSignature: ABCTimeSignature) -> ABCDuration {
        switch timeSignature {
        case let .standard(fraction):
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
