// © 2026 John Gary Pusey (see LICENSE.md)

internal import XestiTools

extension ABCTunebook {

    // MARK: Public Instance Methods

    /// Returns a copy of this tunebook normalized to the current ABC version.
    ///
    /// Normalization is idempotent: calling `normalized()` on an already-normalized
    /// tunebook returns `self` immediately.
    ///
    /// The following conversions are applied:
    /// - ``ABCField/elemskip(_:)`` → ``ABCField/remark(_:)``
    /// - ``ABCField/information(_:)`` → ``ABCField/remark(_:)``
    /// - ``ABCTempo/legacyBeatMultiple`` cleared (durations already resolved)
    /// - `+name+` decorations (``ABCDecoration/Dialect/plus``) → `!name!` (`bang`)
    /// - `%%decoration +` / `I:decoration +` directives dropped
    /// - `%%abc-charset` / `I:abc-charset` directives dropped (stale after decoding)
    /// - `%%abc-version` / `I:abc-version` directives dropped (version is in ``version``)
    ///
    /// - Returns: A new ``ABCTunebook`` whose ``isNormalized`` is `true` and
    ///            ``version`` is ``ABCVersion/current``.
    public func normalized() -> ABCTunebook {
        guard !isNormalized
        else { return self }

        return ABCTunebook(version: .current,
                           fileHeader: fileHeader.compactMap { _normalizeHeaderEntry($0) },
                           tunes: tunes.map { _normalizeTune($0) },
                           isNormalized: true,
                           isValidated: false)
    }
}

// MARK: - Private Functions

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
    guard decoration.dialect == .plus   // ???
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
