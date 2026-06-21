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
                _updateState(&state,
                             from: directive)

            case let .field(field):
                _checkField(field,
                            tuneIndex: nil,
                            state,
                            &issues)

                _updateState(&state,
                             from: field)
            }
        }

        for (tuneIndex, tune) in tunes.enumerated() {
            for entry in tune.header {
                switch entry {
                case let .directive(directive):
                    _updateState(&state,
                                 from: directive)

                case let .field(field):
                    _checkField(field,
                                tuneIndex: tuneIndex,
                                state,
                                &issues)

                    _updateState(&state,
                                 from: field)
                }
            }

            for entry in tune.body {
                switch entry {
                case let .directive(directive):
                    _updateState(&state,
                                 from: directive)

                case let .field(field):
                    _checkField(field,
                                tuneIndex: tuneIndex,
                                state,
                                &issues)

                    _updateState(&state,
                                 from: field)

                case let .symbols(symbols):
                    for symbol in symbols {
                        _checkSymbol(symbol,
                                     tuneIndex: tuneIndex,
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
                              tuneIndex: Int?,
                              _ state: _ValidationState,
                              _ issues: inout [ABCValidationIssue]) {
    if decoration.dialect == .plus, state.activeDialect == .bang {
        issues.append(.plusDialectDecorationWithoutDirective(tuneIndex: tuneIndex))
    } else if decoration.dialect == .bang, state.activeDialect == .plus {
        issues.append(.bangDialectDecorationInPlusMode(tuneIndex: tuneIndex))
    }
}

private func _checkField(_ field: ABCField,
                         tuneIndex: Int?,
                         _ state: _ValidationState,
                         _ issues: inout [ABCValidationIssue]) {
    switch field {
    case let .userDefined(userSymbol):
        if case let .decoration(decoration) = userSymbol.definition {
            _checkDecoration(decoration,
                             tuneIndex: tuneIndex,
                             state,
                             &issues)
        }

    case let .symbolLine(symbolLine):
        for element in symbolLine.elements {
            if case let .decoration(decoration) = element {
                _checkDecoration(decoration,
                                 tuneIndex: tuneIndex,
                                 state,
                                 &issues)
            }
        }

    default:
        break
    }
}

private func _checkMacroCall(_ call: ABCMacroCall,
                             tuneIndex: Int,
                             _ state: _ValidationState,
                             _ issues: inout [ABCValidationIssue]) {
    if !state.definedMacros.contains(where: { _macroTriggerMatches($0.trigger, call.trigger) }) {
        issues.append(.undefinedMacro(tuneIndex: tuneIndex))
    }
}

private func _checkSymbol(_ symbol: ABCSymbol,
                          tuneIndex: Int,
                          _ state: inout _ValidationState,
                          _ issues: inout [ABCValidationIssue]) {
    switch symbol {
    case let .decoration(decoration):
        _checkDecoration(decoration,
                         tuneIndex: tuneIndex,
                         state,
                         &issues)

    case let .inlineField(field):
        _checkField(field,
                    tuneIndex: tuneIndex,
                    state,
                    &issues)
        _updateState(&state, from: field)

    case let .macroCall(call):
        _checkMacroCall(call,
                        tuneIndex: tuneIndex,
                        state,
                        &issues)

    default:
        break
    }
}

private func _macroTriggerMatches(_ pattern: String,
                                  _ trigger: String) -> Bool {
    guard pattern.count == trigger.count
    else { return false }

    return zip(pattern, trigger).allSatisfy { patternChar, triggerChar in
        patternChar == "n" ? "abcdefgABCDEFG".contains(triggerChar) : patternChar == triggerChar
    }
}

private func _updateState(_ state: inout _ValidationState,
                          from directive: ABCDirective) {
    guard directive.name == "decoration"
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
                          from field: ABCField) {
    switch field {
    case let .instruction(directive):
        _updateState(&state, from: directive)

    case let .macro(macro):
        state.definedMacros.append(macro)

    case let .userDefined(userSymbol):
        state.definedUserSymbols.insert(userSymbol.shorthand)

    default:
        break
    }
}

// MARK: - Private Types

private struct _ValidationState {
    var activeDialect: ABCDecoration.Dialect = .bang
    var definedMacros: [ABCMacro] = []
    var definedUserSymbols: Set<ABCShorthand> = []
}
