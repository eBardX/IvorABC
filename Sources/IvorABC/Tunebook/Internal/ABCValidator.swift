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
                _updateState(directive)

            case let .field(field):
                if !field.isValidInFileHeader {
                    issues.append(.misplacedFileHeaderField(field))
                }

                _updateState(field)
            }
        }

        for (tuneIndex, tune) in tunebook.tunes.enumerated() {
            state.resetTuneScope()

            _validateTune(tune, tuneIndex)
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

    private mutating func _validateTune(_ tune: ABCTune,
                                        _ tuneIndex: Int) {
        let tuneHasReferenceNumber = tune.header.contains {
            if case .field(.referenceNumber) = $0 {
                return true
            }

            return false
        }

        if !tuneHasReferenceNumber {
            issues.append(.missingReferenceNumber(tuneIndex: tuneIndex))
        }

        var seenReferenceNumber = !tuneHasReferenceNumber

        for entry in tune.header {
            switch entry {
            case let .directive(directive):
                _updateState(directive)

            case let .field(field):
                if !seenReferenceNumber {
                    if case .referenceNumber = field {
                        seenReferenceNumber = true
                    } else {
                        issues.append(.misplacedReferenceNumber(tuneIndex: tuneIndex))

                        seenReferenceNumber = true
                    }
                }

                if !field.isValidInTuneHeader {
                    issues.append(.misplacedTuneField(field, tuneIndex: tuneIndex))
                }

                _updateState(field, true)
            }
        }

        for entry in tune.body {
            switch entry {
            case let .directive(directive):
                _updateState(directive)

            case let .field(field):
                if !field.isValidInTuneBody {
                    issues.append(.misplacedTuneField(field, tuneIndex: tuneIndex))
                }

                _updateState(field, true)

            case let .symbols(symbols):
                for symbol in symbols {
                    _checkSymbol(symbol, tuneIndex)
                }
            }
        }
    }

    private mutating func _checkSymbol(_ symbol: ABCSymbol,
                                       _ tuneIndex: Int) {
        switch symbol {
        case let .inlineField(field):
            _updateState(field, true)

        case let .shorthand(shorthand):
            if shorthand != .dot,
               !state.isShorthandDefined(shorthand) {
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
