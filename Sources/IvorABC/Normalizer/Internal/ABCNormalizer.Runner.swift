// © 2026 John Gary Pusey (see LICENSE.md)

internal import XestiTools

extension ABCNormalizer {

    // MARK: Internal Nested Types

    internal struct Runner {

        // MARK: Internal Initializers

        internal init() {
        }

        // MARK: Internal Instance Methods

        internal func run(_ tunebook: ABCTunebook) -> ABCTunebook {
            ABCTunebook(version: .current,
                        fileHeader: tunebook.fileHeader.compactMap { _normalizeHeaderEntry($0) },
                        tunes: tunebook.tunes.map { _normalizeTune($0) },
                        isNormalized: true,
                        isValidated: false)
        }

        // MARK: Private Instance Methods

        private func _isStaleDirective(_ directive: ABCDirective) -> Bool {
            directive.name == .abcCharset
            || directive.name == .abcVersion
            || (directive.name == .decoration && directive.value == "+")    // is this really "stale" ???
        }

        private func _normalizeBodyEntry(_ entry: ABCBodyEntry) -> ABCBodyEntry? {
            switch entry {
            case let .directive(directive):
                return _isStaleDirective(directive) ? nil : entry

            case let .field(field):
                return .field(_normalizeField(field))

            case let .symbols(symbols):
                let normalized = symbols.compactMap { _normalizeSymbol($0) }

                return normalized.isEmpty ? nil : .symbols(normalized)
            }
        }

        private func _normalizeDecoration(_ decoration: ABCDecoration) -> ABCDecoration {
            guard decoration.dialect == .plus
            else { return decoration }

            return ABCDecoration(name: decoration.name,
                                 dialect: .bang).require()
        }

        private func _normalizeField(_ field: ABCField) -> ABCField {
            switch field {
            case let .elemskip(elemskip):
                let stringValue = switch elemskip {
                case let .integer(value):
                    String(value)

                case let .decimal(value):
                    String(value)
                }

                return .remark(ABCText(stringValue))

            case let .information(text):
                return .remark(text)

            case let .symbolLine(symbolLine):
                let normalized = symbolLine.elements.map { element -> ABCSymbolLine.Element in
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
               tempo.legacyBeatMultiple != nil {
                return .tempo(ABCTempo(durations: tempo.durations,
                                       rate: tempo.rate,
                                       text: tempo.text).require())
            }

            return field
        }

        private func _normalizeHeaderEntry(_ entry: ABCHeaderEntry) -> ABCHeaderEntry? {
            switch entry {
            case let .directive(directive):
                _isStaleDirective(directive) ? nil : entry

            case let .field(field):
                    .field(_normalizeField(field))
            }
        }

        private func _normalizeSymbol(_ symbol: ABCSymbol) -> ABCSymbol? {
            switch symbol {
            case let .decoration(decoration):
                return .decoration(_normalizeDecoration(decoration))

            case let .inlineField(field):
                if case let .instruction(directive) = field,
                   _isStaleDirective(directive) {
                    return nil
                }

                return .inlineField(_normalizeField(field))

            default:
                return symbol
            }
        }

        private func _normalizeTune(_ tune: ABCTune) -> ABCTune {
            ABCTune(header: tune.header.compactMap { _normalizeHeaderEntry($0) },
                    body: tune.body.compactMap { _normalizeBodyEntry($0) }).require()
        }
    }
}
