// © 2026 John Gary Pusey (see LICENSE.md)

internal struct ABCValidator {

    // MARK: Internal Initializers

    internal init() {
        self.issues = []
        self.state = State()
    }

    // MARK: Internal Instance Methods

    internal mutating func validate(_ tunebook: ABCTunebook) -> [ABCValidationIssue] {
        issues = []
        state = State()

        for header in tunebook.fileHeader {
            switch header {
            case let .directive(directive):
                _checkForLegacyDirective(directive, nil)
                _updateState(directive)

            case let .field(field):
                _checkField(field, nil)
                _checkForLegacyField(field, nil)
                _updateState(field)
            }
        }

        for (tuneIndex, tune) in tunebook.tunes.enumerated() {
            state.resetTuneScope()

            for entry in tune.header {
                switch entry {
                case let .directive(directive):
                    _checkForLegacyDirective(directive, tuneIndex)
                    _updateState(directive)

                case let .field(field):
                    _checkField(field, tuneIndex)
                    _checkForLegacyField(field, tuneIndex)
                    _updateState(field, true)
                }
            }

            for entry in tune.body {
                switch entry {
                case let .directive(directive):
                    _checkForLegacyDirective(directive, tuneIndex)
                    _updateState(directive)

                case let .field(field):
                    _checkField(field, tuneIndex)
                    _checkForLegacyField(field, tuneIndex)
                    _updateState(field, true)

                case let .symbols(symbols):
                    for symbol in symbols {
                        _checkSymbol(symbol, tuneIndex)
                    }
                }
            }
        }

        return issues
    }

    // MARK: Private Instance Properties

    private var issues: [ABCValidationIssue]
    private var state: State
}

// MARK: -

extension ABCValidator {

    // MARK: Private Instance Methods

    private mutating func _checkDecoration(_ decoration: ABCDecoration,
                                           _ tuneIndex: Int?) {
        if decoration.dialect == .plus, state.activeDialect == .bang {
            issues.append(.plusDialectDecorationWithoutDirective(tuneIndex: tuneIndex))
        } else if decoration.dialect == .bang, state.activeDialect == .plus {
            issues.append(.bangDialectDecorationInPlusMode(tuneIndex: tuneIndex))
        }
    }

    private mutating func _checkField(_ field: ABCField,
                                      _ tuneIndex: Int?) {
        switch field {
        case let .userDefined(userSymbol):
            if let definition = userSymbol.definition,
               case let .decoration(decoration) = definition {
                _checkDecoration(decoration, tuneIndex)
            }

        case let .symbolLine(symbolLine):
            for element in symbolLine.elements {
                if case let .decoration(decoration) = element {
                    _checkDecoration(decoration, tuneIndex)
                }
            }

        default:
            break
        }
    }

    private mutating func _checkForLegacyDirective(_ directive: ABCDirective,
                                                   _ tuneIndex: Int?) {
        if directive.name == .abcCharset {
            issues.append(.legacyCharsetDirective(tuneIndex: tuneIndex))
        } else if directive.name == .abcVersion {
            issues.append(.legacyVersionDirective(tuneIndex: tuneIndex))
        } else if directive.name == .decoration, directive.value == "+" {
            issues.append(.legacyDecorationDirective(tuneIndex: tuneIndex))
        }
    }

    private mutating func _checkForLegacyField(_ field: ABCField,
                                               _ tuneIndex: Int?) {
        switch field {
        case .elemskip:
            issues.append(.legacyElemskipField(tuneIndex: tuneIndex))

        case .information:
            issues.append(.legacyInformationField(tuneIndex: tuneIndex))

        case let .tempo(tempo) where tempo.legacyBeatMultiple != nil:
            issues.append(.legacyTempoForm(tuneIndex: tuneIndex))

        case let .instruction(directive):
            _checkForLegacyDirective(directive, tuneIndex)

        default:
            break
        }
    }

    private mutating func _checkSymbol(_ symbol: ABCSymbol,
                                       _ tuneIndex: Int) {
        switch symbol {
        case let .decoration(decoration):
            _checkDecoration(decoration, tuneIndex)

        case let .inlineField(field):
            _checkField(field, tuneIndex)
            _checkForLegacyField(field, tuneIndex)
            _updateState(field, true)

        case let .shorthand(shorthand):
            if shorthand != .dot, !state.isShorthandDefined(shorthand) {
                issues.append(.undefinedUserSymbol(tuneIndex: tuneIndex))
            }

        default:
            break
        }
    }

    private mutating func _updateState(_ directive: ABCDirective) {
        guard directive.name == .decoration
        else { return }

        switch directive.value {
        case "!":
            state.activeDialect = .bang

        case "+":
            state.activeDialect = .plus

        default:
            break
        }
    }

    private mutating func _updateState(_ field: ABCField,
                                       _ inTune: Bool = false) {
        switch field {
        case let .instruction(directive):
            _updateState(directive)

        case let .userDefined(userSymbol):
            if userSymbol.definition != nil {
                if inTune {
                    state.tuneDefinedShorthands.insert(userSymbol.shorthand)
                    state.tuneDeassignedShorthands.remove(userSymbol.shorthand)
                } else {
                    state.globalDefinedShorthands.insert(userSymbol.shorthand)
                    state.globalDeassignedShorthands.remove(userSymbol.shorthand)
                }
            } else {
                if inTune {
                    state.tuneDeassignedShorthands.insert(userSymbol.shorthand)
                    state.tuneDefinedShorthands.remove(userSymbol.shorthand)
                } else {
                    state.globalDeassignedShorthands.insert(userSymbol.shorthand)
                    state.globalDefinedShorthands.remove(userSymbol.shorthand)
                }
            }

        default:
            break
        }
    }
}
