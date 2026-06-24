// © 2026 John Gary Pusey (see LICENSE.md)

extension ABCTunebook {

    // MARK: Public Instance Methods

    /// Validates this tunebook against the ABC specification and returns
    /// any issues found.
    ///
    /// Error-severity issues indicate structural violations that will cause
    /// ``ABCFormatter`` to emit invalid ABC. Warning-severity issues indicate
    /// deviations from "should" rules in the specification that may cause
    /// interoperability problems.
    ///
    /// - Returns: An array of ``ABCValidationIssue`` values. An empty array
    ///            means the tunebook is fully conformant.
    public func validate() -> [ABCValidationIssue] {
        var issues: [ABCValidationIssue] = []
        var state = _ValidationState()

        for header in fileHeader {
            switch header {
            case let .directive(directive):
                _updateState(&state, directive)

            case let .field(field):
                _checkField(field,
                            nil,
                            state,
                            &issues)

                _updateState(&state, field)
            }
        }

        for (tuneIndex, tune) in tunes.enumerated() {
            state.resetTuneScope()

            for entry in tune.header {
                switch entry {
                case let .directive(directive):
                    _updateState(&state, directive)

                case let .field(field):
                    _checkField(field,
                                tuneIndex,
                                state,
                                &issues)

                    _updateState(&state, field, true)
                }
            }

            for entry in tune.body {
                switch entry {
                case let .directive(directive):
                    _updateState(&state, directive)

                case let .field(field):
                    _checkField(field,
                                tuneIndex,
                                state,
                                &issues)

                    _updateState(&state, field, true)

                case let .symbols(symbols):
                    for symbol in symbols {
                        _checkSymbol(symbol,
                                     tuneIndex,
                                     &state,
                                     &issues)
                    }
                }
            }
        }

        return issues
    }
}

// MARK: - Private Functions

private func _checkDecoration(_ decoration: ABCDecoration,
                              _ tuneIndex: Int?,
                              _ state: _ValidationState,
                              _ issues: inout [ABCValidationIssue]) {
    if decoration.dialect == .plus, state.activeDialect == .bang {
        issues.append(.plusDialectDecorationWithoutDirective(tuneIndex: tuneIndex))
    } else if decoration.dialect == .bang, state.activeDialect == .plus {
        issues.append(.bangDialectDecorationInPlusMode(tuneIndex: tuneIndex))
    }
}

private func _checkField(_ field: ABCField,
                         _ tuneIndex: Int?,
                         _ state: _ValidationState,
                         _ issues: inout [ABCValidationIssue]) {
    switch field {
    case let .userDefined(userSymbol):
        if let definition = userSymbol.definition,
           case let .decoration(decoration) = definition {
            _checkDecoration(decoration,
                             tuneIndex,
                             state,
                             &issues)
        }

    case let .symbolLine(symbolLine):
        for element in symbolLine.elements {
            if case let .decoration(decoration) = element {
                _checkDecoration(decoration,
                                 tuneIndex,
                                 state,
                                 &issues)
            }
        }

    default:
        break
    }
}

private func _checkSymbol(_ symbol: ABCSymbol,
                          _ tuneIndex: Int,
                          _ state: inout _ValidationState,
                          _ issues: inout [ABCValidationIssue]) {
    switch symbol {
    case let .decoration(decoration):
        _checkDecoration(decoration,
                         tuneIndex,
                         state,
                         &issues)

    case let .inlineField(field):
        _checkField(field,
                    tuneIndex,
                    state,
                    &issues)
        _updateState(&state, field, true)

    case let .shorthand(shorthand):
        if shorthand != .dot, !state.isShorthandDefined(shorthand) {
            issues.append(.undefinedUserSymbol(tuneIndex: tuneIndex))
        }

    default:
        break
    }
}

private func _updateState(_ state: inout _ValidationState,
                          _ directive: ABCDirective) {
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

private func _updateState(_ state: inout _ValidationState,
                          _ field: ABCField,
                          _ inTune: Bool = false) {
    switch field {
    case let .instruction(directive):
        _updateState(&state, directive)

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

// MARK: - Private Types

private struct _ValidationState {
    var activeDialect: ABCDecoration.Dialect = .bang
    var globalDefinedShorthands: Set<ABCShorthand> = [.tilde,
                                                      .hUpper,
                                                      .lUpper,
                                                      .mUpper,
                                                      .oUpper,
                                                      .pUpper,
                                                      .sUpper,
                                                      .tUpper,
                                                      .uLower,
                                                      .vLower]
    var globalDeassignedShorthands: Set<ABCShorthand> = []
    var tuneDefinedShorthands: Set<ABCShorthand> = []
    var tuneDeassignedShorthands: Set<ABCShorthand> = []

    func isShorthandDefined(_ shorthand: ABCShorthand) -> Bool {
        if tuneDeassignedShorthands.contains(shorthand) {
            return false
        }

        if tuneDefinedShorthands.contains(shorthand) {
            return true
        }

        if globalDeassignedShorthands.contains(shorthand) {
            return false
        }

        return globalDefinedShorthands.contains(shorthand)
    }

    mutating func resetTuneScope() {
        tuneDefinedShorthands = []
        tuneDeassignedShorthands = []
    }
}
