// © 2026 John Gary Pusey (see LICENSE.md)

internal import XestiTools

extension ABCNormalizer {

    // MARK: Internal Nested Types

    internal struct Editor {

        // MARK: Internal Initializers

        internal init(tunebook: ABCTunebook) {
            self.changes = []
            self.tunebook = tunebook
        }

        // MARK: Private Instance Properties

        private let tunebook: ABCTunebook

        private var changes: [Change] = []

        // The active unit-note-length scope, tracked while walking so that a
        // deprecated C-form tempo (``ABCTempo/beatMultiplier``) can be resolved
        // against the `L:`/`M:` in effect at its position.
        private var meter: ABCTimeSignature?
        private var unitNoteLength: ABCLength?
    }
}

// MARK: -

extension ABCNormalizer.Editor {

    // MARK: Internal Instance Methods

    internal mutating func editTunebook() -> (ABCTunebook, [ABCNormalizer.Change]) {
        let fileHeader = _editFileHeader(tunebook.fileHeader)

        // `L:`/`M:` declared in the file header carry forward as each tune's
        // starting scope.
        let fileUnitNoteLength = unitNoteLength
        let fileMeter = meter

        var tunes: [ABCTune] = []

        for (index, tune) in tunebook.tunes.enumerated() {
            unitNoteLength = fileUnitNoteLength
            meter = fileMeter

            tunes.append(_editTune(tune, index))
        }

        let normalized = ABCTunebook(version: .current,
                                     fileHeader: fileHeader,
                                     tunes: tunes,
                                     isNormalized: true,
                                     isValidated: false)

        return (normalized, changes)
    }

    // MARK: Private Instance Methods

    private mutating func _editBodyEntry(_ entry: ABCBodyEntry,
                                         _ index: Int?) -> ABCBodyEntry? {
        switch entry {
        case let .directive(directive):
            guard directive.needsNormalization
            else { return entry }

            changes.append(.removedDirective(directive, index))

            return nil

        case let .field(field):
            return .field(_editField(field, index))

        case let .symbols(symbols):
            let normalized = symbols.compactMap { _editSymbol($0, index) }

            return normalized.isEmpty ? nil : .symbols(normalized)
        }
    }

    private mutating func _editDecoration(_ decoration: ABCDecoration,
                                          _ index: Int?) -> ABCDecoration {
        guard decoration.needsNormalization
        else { return decoration }

        changes.append(.convertedDecoration(decoration, index))

        return ABCDecoration(name: decoration.name).require()
    }

    private mutating func _editField(_ field: ABCField,
                                     _ index: Int?) -> ABCField {
        switch field {
        case let .meter(timeSignature):
            meter = timeSignature

        case let .unitNoteLength(length):
            unitNoteLength = length

        default:
            break
        }

        switch field {
        case let .elemskip(elemskip):
            let stringValue = switch elemskip {
            case let .integer(value):
                String(value)

            case let .decimal(value):
                String(value)
            }

            let replacement = ABCField.remark(ABCText(stringValue))

            changes.append(.replacedField(field, replacement, index))

            return replacement

        case let .information(text):
            let replacement = ABCField.remark(text)

            changes.append(.replacedField(field, replacement, index))

            return replacement

        case let .symbolLine(symbolLine):
            let normalized = symbolLine.elements.map { element in
                guard case let .decoration(decoration) = element
                else { return element }

                return .decoration(_editDecoration(decoration, index))
            }

            return .symbolLine(ABCSymbolLine(elements: normalized))

        case let .userDefined(userSymbol):
            guard case let .decoration(decoration) = userSymbol.definition
            else { break }

            return .userDefined(ABCUserSymbol(shorthand: userSymbol.shorthand,
                                              definition: .decoration(_editDecoration(decoration, index))).require())

        default:
            break
        }

        if case let .tempo(tempo) = field,
           let multiplier = tempo.beatMultiplier {
            changes.append(.clearedBeatMultiplier(tempo, index))

            let base = _effectiveUnitNoteLength()
            let beat = ABCLength(numerator: base.numerator * multiplier,
                                 denominator: base.denominator) ?? base

            return .tempo(ABCTempo(lengths: [beat],
                                   rate: tempo.rate,
                                   text: tempo.text).require())
        }

        return field
    }

    private mutating func _editFileHeader(_ fileHeader: [ABCHeaderEntry]) -> [ABCHeaderEntry] {
        fileHeader.compactMap { _editHeaderEntry($0, nil) }
    }

    private mutating func _editHeaderEntry(_ entry: ABCHeaderEntry,
                                           _ index: Int?) -> ABCHeaderEntry? {
        switch entry {
        case let .directive(directive):
            guard directive.needsNormalization
            else { return entry }

            changes.append(.removedDirective(directive, index))

            return nil

        case let .field(field):
            return .field(_editField(field, index))
        }
    }

    private mutating func _editSymbol(_ symbol: ABCSymbol,
                                      _ index: Int?) -> ABCSymbol? {
        switch symbol {
        case let .decoration(decoration):
            return .decoration(_editDecoration(decoration, index))

        case let .inlineField(field):
            guard case let .instruction(directive) = field,
                  directive.needsNormalization
            else { return .inlineField(_editField(field, index)) }

            changes.append(.removedDirective(directive, index))

            return nil

        default:
            return symbol
        }
    }

    private mutating func _editTune(_ tune: ABCTune,
                                    _ index: Int) -> ABCTune {
        ABCTune(header: _editTuneHeader(tune.header, index),
                body: _editTuneBody(tune.body, index)).require()
    }

    private mutating func _editTuneBody(_ body: [ABCBodyEntry],
                                        _ index: Int) -> [ABCBodyEntry] {
        body.compactMap { _editBodyEntry($0, index) }
    }

    private mutating func _editTuneHeader(_ header: [ABCHeaderEntry],
                                          _ index: Int) -> [ABCHeaderEntry] {
        header.compactMap { _editHeaderEntry($0, index) }
    }

    private func _effectiveUnitNoteLength() -> ABCLength {
        if let unitNoteLength {
            return unitNoteLength
        }

        if let meter {
            return _unitNoteLength(from: meter)
        }

        return ABCLength(numerator: 1,
                         denominator: 8).require()
    }

    private func _unitNoteLength(from meter: ABCTimeSignature) -> ABCLength {
        if case let .standard(standard) = meter,
           standard.doubleValue < 0.75 {
            return ABCLength(numerator: 1,
                             denominator: 16).require()
        }

        return ABCLength(numerator: 1,
                         denominator: 8).require()
    }
}
