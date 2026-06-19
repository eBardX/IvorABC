// © 2026 John Gary Pusey (see LICENSE.md)

internal import XestiTools

extension ABCTunebook {

    // MARK: Public Instance Methods

    /// Returns a copy of this tunebook upgraded to the current ABC version.
    ///
    /// For ABC 2.0 and 2.1 tunebooks, the migration is lossless — only the
    /// ``version`` property changes.
    ///
    /// For ABC 1.6 tunebooks, ``ABCField/elemskip(_:)`` and
    /// ``ABCField/information(_:)`` fields are converted to
    /// ``ABCField/remark(_:)`` so the text is preserved in valid 2.1. Tempo
    /// fields whose
    /// ``ABCTempo/legacyBeatMultiple`` is set have that flag cleared (the
    /// `durations` array already holds the resolved beat).
    ///
    /// - Returns: A new ``ABCTunebook`` whose ``version`` is ``ABCVersion/current``.
    public func migrate() -> ABCTunebook {
        ABCTunebook(version: ABCVersion.current,
                    headers: headers.map { _migrateHeader($0) },
                    tunes: tunes.map { _migrateTune($0) }).require()
    }
}

// MARK: - Private Functions

private func _migrateField(_ field: ABCField) -> ABCField {
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
                               text: tempo.text))
    }

    return field
}

private func _migrateSymbol(_ symbol: ABCSymbol) -> ABCSymbol {
    if case let .inlineField(field) = symbol {
        .inlineField(_migrateField(field))
    } else {
        symbol
    }
}

private func _migrateEntry(_ entry: ABCEntry) -> ABCEntry {
    switch entry {
    case let .field(field):
        .field(_migrateField(field))

    case let .symbols(symbols):
        .symbols(symbols.map { _migrateSymbol($0) })

    default:
        entry
    }
}

private func _migrateHeader(_ header: ABCHeader) -> ABCHeader {
    if case let .field(field) = header {
        return .field(_migrateField(field))
    }

    return header
}

private func _migrateTune(_ tune: ABCTune) -> ABCTune {
    ABCTune(entries: tune.entries.map { _migrateEntry($0) }).require()
}
