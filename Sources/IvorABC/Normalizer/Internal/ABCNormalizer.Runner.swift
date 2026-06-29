// © 2026 John Gary Pusey (see LICENSE.md)

internal import XestiTools

extension ABCNormalizer {

    // MARK: Internal Nested Types

    internal struct Runner {

        // MARK: Internal Initializers

        internal init() {
        }

        // MARK: Private Instance Properties

        private var changes: [Change] = []
        private var currentTuneIndex: Int?
    }
}

// MARK: -

extension ABCNormalizer.Runner {

    // MARK: Internal Instance Methods

    internal mutating func run(_ tunebook: ABCTunebook) -> (ABCTunebook, [ABCNormalizer.Change]) {
        let fileHeader = tunebook.fileHeader.compactMap { _normalizeHeaderEntry($0) }
        let tunes = tunebook.tunes.enumerated().map { index, tune in
            currentTuneIndex = index
            return _normalizeTune(tune)
        }
        let normalized = ABCTunebook(version: .current,
                                     fileHeader: fileHeader,
                                     tunes: tunes,
                                     isNormalized: true,
                                     isValidated: false)

        return (normalized, changes)
    }

    // MARK: Private Instance Methods

    private func _isStaleDirective(_ directive: ABCDirective) -> Bool {
        directive.name == .abcCharset
        || directive.name == .abcVersion
        || (directive.name == .decoration && directive.value == "+")
    }

    private mutating func _normalizeBodyEntry(_ entry: ABCBodyEntry) -> ABCBodyEntry? {
        switch entry {
        case let .directive(directive):
            if _isStaleDirective(directive) {
                changes.append(.droppedDirective(directive, currentTuneIndex))

                return nil
            }

            return entry

        case let .field(field):
            return .field(_normalizeField(field))

        case let .symbols(symbols):
            let normalized = symbols.compactMap { _normalizeSymbol($0) }

            return normalized.isEmpty ? nil : .symbols(normalized)
        }
    }

    private mutating func _normalizeDecoration(_ decoration: ABCDecoration) -> ABCDecoration {
        guard decoration.dialect == .plus
        else { return decoration }

        changes.append(.convertedDecoration(decoration, currentTuneIndex))

        return ABCDecoration(name: decoration.name).require()
    }

    private mutating func _normalizeField(_ field: ABCField) -> ABCField {
        switch field {
        case let .elemskip(elemskip):
            let stringValue = switch elemskip {
            case let .integer(value):
                String(value)

            case let .decimal(value):
                String(value)
            }

            let replacement = ABCField.remark(ABCText(stringValue))

            changes.append(.replacedField(field, replacement, currentTuneIndex))

            return replacement

        case let .information(text):
            let replacement = ABCField.remark(text)

            changes.append(.replacedField(field, replacement, currentTuneIndex))

            return replacement

        case let .symbolLine(symbolLine):
            let normalized = symbolLine.elements.map { element in
                guard case let .decoration(decoration) = element
                else { return element }

                return .decoration(_normalizeDecoration(decoration))
            }

            return .symbolLine(ABCSymbolLine(elements: normalized))

        case let .userDefined(userSymbol):
            guard case let .decoration(decoration) = userSymbol.definition
            else { break }

            return .userDefined(ABCUserSymbol(shorthand: userSymbol.shorthand,
                                              definition: .decoration(_normalizeDecoration(decoration))).require())

        default:
            break
        }

        if case let .tempo(tempo) = field,
           tempo.beatMultiplier != nil {
            changes.append(.clearedBeatMultiplier(tempo, currentTuneIndex))

            return .tempo(ABCTempo(durations: tempo.durations,
                                   rate: tempo.rate,
                                   text: tempo.text).require())
        }

        return field
    }

    private mutating func _normalizeHeaderEntry(_ entry: ABCHeaderEntry) -> ABCHeaderEntry? {
        switch entry {
        case let .directive(directive):
            if _isStaleDirective(directive) {
                changes.append(.droppedDirective(directive, currentTuneIndex))

                return nil
            }

            return entry

        case let .field(field):
            return .field(_normalizeField(field))
        }
    }

    private mutating func _normalizeSymbol(_ symbol: ABCSymbol) -> ABCSymbol? {
        switch symbol {
        case let .decoration(decoration):
            return .decoration(_normalizeDecoration(decoration))

        case let .inlineField(field):
            if case let .instruction(directive) = field,
               _isStaleDirective(directive) {
                changes.append(.droppedDirective(directive, currentTuneIndex))

                return nil
            }

            return .inlineField(_normalizeField(field))

        default:
            return symbol
        }
    }

    private mutating func _normalizeTune(_ tune: ABCTune) -> ABCTune {
        ABCTune(header: tune.header.compactMap { _normalizeHeaderEntry($0) },
                body: tune.body.compactMap { _normalizeBodyEntry($0) }).require()
    }
}
