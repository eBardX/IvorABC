// © 2025–2026 John Gary Pusey (see LICENSE.md)

private import XestiTools

internal struct ABCParseContext {

    // MARK: Internal Initializers

    internal init() {
        self.accidentalsInKey = [:]
        self.decorationDialect = .bang
        self.globalDecorationDialect = .bang
        self.globalDurationFromMeter = nil
        self.globalDurationFromUnitNoteLength = nil
        self.globalIsCompoundMeter = false
        self.globalMacros = [:]
        self.globalUserSymbolDefinitions = [:]
        self.inTune = false
        self.isCompoundMeter = false
        self.tuneMacros = [:]
        self.tuneUserSymbolDefinitions = [:]
    }

    // MARK: Internal Instance Properties

    internal var accidentalsInKey: [ABCPitch.Letter: ABCPitch.Accidental]
    internal var decorationDialect: ABCDecoration.Dialect
    internal var inTune: Bool
    internal var isCompoundMeter: Bool

    internal var baseDuration: ABCDuration {
        durationFromUnitNoteLength ?? durationFromMeter ?? Self.durationEighths
    }

    internal var hasMacros: Bool {
        !globalMacros.isEmpty || !tuneMacros.isEmpty
    }

    // MARK: Private Instance Properties

    // Global (file-header) snapshots: kept in sync with the live fields while
    // !inTune, then held fixed so resetTuneScope() can restore them.
    private var globalDecorationDialect: ABCDecoration.Dialect
    private var globalDurationFromMeter: ABCDuration?
    private var globalDurationFromUnitNoteLength: ABCDuration?
    private var globalIsCompoundMeter: Bool
    private var globalMacros: [String: ABCMacro]
    private var globalUserSymbolDefinitions: [ABCShorthand: ABCUserSymbol.Definition]

    // Live working values for meter/unit-note-length (tune may override these).
    private var durationFromMeter: ABCDuration?
    private var durationFromUnitNoteLength: ABCDuration?
    private var tuneMacros: [String: ABCMacro]
    private var tuneUserSymbolDefinitions: [ABCShorthand: ABCUserSymbol.Definition]
}

// MARK: -

extension ABCParseContext {

    // MARK: Internal Instance Methods

    internal func macro(for trigger: String) -> ABCMacro? {
        tuneMacros[trigger] ?? globalMacros[trigger]
    }

    internal mutating func resetTuneScope() {
        accidentalsInKey = [:]   // K: is never valid in the file header
        decorationDialect = globalDecorationDialect
        durationFromMeter = globalDurationFromMeter
        durationFromUnitNoteLength = globalDurationFromUnitNoteLength
        isCompoundMeter = globalIsCompoundMeter
        tuneMacros = [:]
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

        case let .macro(macro):
            if inTune {
                tuneMacros[macro.trigger] = macro
            } else {
                globalMacros[macro.trigger] = macro
            }

        case let .meter(timeSignature):
            let duration = Self._determineDuration(from: timeSignature)
            let compound = timeSignature.isCompound

            durationFromMeter = duration
            isCompoundMeter = compound

            if !inTune {
                globalDurationFromMeter = duration
                globalIsCompoundMeter = compound
            }

        case let .unitNoteLength(duration):
            durationFromUnitNoteLength = duration
            if !inTune {
                globalDurationFromUnitNoteLength = duration
            }

        case let .userDefined(userSymbol):
            if inTune {
                tuneUserSymbolDefinitions[userSymbol.shorthand] = userSymbol.definition
            } else {
                globalUserSymbolDefinitions[userSymbol.shorthand] = userSymbol.definition
            }

        default:
            break
        }
    }

    internal func userSymbolDefinition(for shorthand: ABCShorthand) -> ABCUserSymbol.Definition? {
        tuneUserSymbolDefinitions[shorthand] ?? globalUserSymbolDefinitions[shorthand]
    }

    // MARK: Private Type Properties

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
