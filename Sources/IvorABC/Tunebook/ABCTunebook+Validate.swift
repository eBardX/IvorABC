// © 2026 John Gary Pusey (see LICENSE.md)

extension ABCTunebook {

    // MARK: Public Instance Methods

    /// Validates this tunebook against the ABC specification and returns
    /// any issues found.
    ///
    /// - Throws: ``ABCValidationError/notNormalized`` if ``isNormalized`` is
    ///           `false`. Call ``normalized()`` before calling this method.
    ///
    /// - Returns: A tuple of the validated tunebook and an array of
    ///            ``ABCValidationIssue`` values. The tunebook in the tuple is a
    ///            copy of `self` with ``isValidated`` set to `true` when no
    ///            error-severity issues are found; otherwise `self` is returned
    ///            unchanged (re-validating after fixing issues is required).
    ///            An empty issues array means the tunebook is fully conformant.
    public func validated() throws -> (ABCTunebook, [ABCValidationIssue]) {
        guard isNormalized
        else { throw ABCValidationError.notNormalized }

        guard !isValidated
        else { return (self, []) }

        var issues: [ABCValidationIssue] = []
        var state = _ValidationState()

        for header in fileHeader {
            switch header {
            case let .directive(directive):
                _checkForLegacyDirective(directive, nil, &issues)
                _updateState(&state, directive)

            case let .field(field):
                _checkField(field,
                            nil,
                            state,
                            &issues)
                _checkForLegacyField(field, nil, &issues)
                _updateState(&state, field)
            }
        }

        for (tuneIndex, tune) in tunes.enumerated() {
            state.resetTuneScope()

            for entry in tune.header {
                switch entry {
                case let .directive(directive):
                    _checkForLegacyDirective(directive, tuneIndex, &issues)
                    _updateState(&state, directive)

                case let .field(field):
                    _checkField(field,
                                tuneIndex,
                                state,
                                &issues)
                    _checkForLegacyField(field, tuneIndex, &issues)
                    _updateState(&state, field, true)
                }
            }

            for entry in tune.body {
                switch entry {
                case let .directive(directive):
                    _checkForLegacyDirective(directive, tuneIndex, &issues)
                    _updateState(&state, directive)

                case let .field(field):
                    _checkField(field,
                                tuneIndex,
                                state,
                                &issues)
                    _checkForLegacyField(field, tuneIndex, &issues)
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

        let hasErrors = issues.contains { $0.severity == .error }

        if hasErrors {
            return (self, issues)
        }

        return (ABCTunebook(version: version,
                            fileHeader: fileHeader,
                            tunes: tunes,
                            isNormalized: isNormalized,
                            isValidated: true), issues)
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
        _checkForLegacyField(field, tuneIndex, &issues)
        _updateState(&state, field, true)

    case let .shorthand(shorthand):
        if shorthand != .dot, !state.isShorthandDefined(shorthand) {
            issues.append(.undefinedUserSymbol(tuneIndex: tuneIndex))
        }

    default:
        break
    }
}

private func _checkForLegacyDirective(_ directive: ABCDirective,
                                      _ tuneIndex: Int?,
                                      _ issues: inout [ABCValidationIssue]) {
    if directive.name == .abcCharset {
        issues.append(.legacyCharsetDirective(tuneIndex: tuneIndex))
    } else if directive.name == .abcVersion {
        issues.append(.legacyVersionDirective(tuneIndex: tuneIndex))
    } else if directive.name == .decoration, directive.value == "+" {
        issues.append(.legacyDecorationDirective(tuneIndex: tuneIndex))
    }
}

private func _checkForLegacyField(_ field: ABCField,
                                  _ tuneIndex: Int?,
                                  _ issues: inout [ABCValidationIssue]) {
    switch field {
    case .elemskip:
        issues.append(.legacyElemskipField(tuneIndex: tuneIndex))

    case .information:
        issues.append(.legacyInformationField(tuneIndex: tuneIndex))

    case let .tempo(tempo) where tempo.legacyBeatMultiple != nil:
        issues.append(.legacyTempoForm(tuneIndex: tuneIndex))

    case let .instruction(directive):
        _checkForLegacyDirective(directive, tuneIndex, &issues)

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
    var globalDeassignedShorthands: Set<ABCShorthand> = []
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
    var tuneDeassignedShorthands: Set<ABCShorthand> = []
    var tuneDefinedShorthands: Set<ABCShorthand> = []

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
        tuneDeassignedShorthands = []
        tuneDefinedShorthands = []
    }
}
