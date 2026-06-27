// © 2026 John Gary Pusey (see LICENSE.md)

internal import Foundation

private import XestiTools

extension ABCFormatter {

    // MARK: Internal Nested Types

    internal struct Writer {

        // MARK: Internal Initializers

        internal init(tunebook: ABCTunebook) {
            self.buffer = ""
            self.meter = nil
            self.tunebook = tunebook
            self.unitNoteLength = nil
        }

        // MARK: Private Instance Properties

        private let tunebook: ABCTunebook

        private var buffer: String
        private var meter: ABCTimeSignature?
        private var unitNoteLength: ABCDuration?
    }
}

// MARK: -

extension ABCFormatter.Writer {

    // MARK: Internal Instance Methods

    internal mutating func writeTunebook() throws -> Data {
        guard let version = tunebook.version,
              version == ABCVersion.current
        else { throw ABCFormatter.Error.unsupportedVersion(tunebook.version) }

        buffer.append("%abc-\(version.major).\(version.minor)\n")

        try _writeFileHeaders()

        let autoRefs = _computeAutoReferenceNumbers()

        for (index, tune) in tunebook.tunes.enumerated() {
            if index > 0 {
                buffer.append("\n")
            }

            try _writeTune(tune, autoRefs[index])
        }

        guard let data = buffer.data(using: .utf8)
        else { throw ABCFormatter.Error.stringConversionFailed }

        return data
    }

    // MARK: Private Instance Methods

    private func _computeAutoReferenceNumbers() -> [Int: ABCReferenceNumber] {
        var usedNumbers = Set<UInt>()

        for tune in tunebook.tunes {
            for entry in tune.header {
                if case let .field(.referenceNumber(rn)) = entry {
                    usedNumbers.insert(rn.uintValue)
                }
            }
        }

        var result: [Int: ABCReferenceNumber] = [:]
        var nextCandidate: UInt = 1

        for (index, tune) in tunebook.tunes.enumerated() {
            let hasRefNumber = tune.header.contains {
                if case .field(.referenceNumber) = $0 {
                    return true
                }

                return false
            }

            guard !hasRefNumber
            else { continue }

            while usedNumbers.contains(nextCandidate) {
                nextCandidate += 1
            }

            result[index] = ABCReferenceNumber(nextCandidate)

            usedNumbers.insert(nextCandidate)

            nextCandidate += 1
        }

        return result
    }

    private mutating func _writeDirective(_ directive: ABCDirective) {
        if let content = directive.content {
            buffer.append("%%begin")
            buffer.append(directive.name.stringValue)

            if !directive.value.isEmpty {
                buffer.append(" ")
                buffer.append(directive.value)
            }

            buffer.append("\n")

            for line in content {
                buffer.append(line)
                buffer.append("\n")
            }

            buffer.append("%%end")
            buffer.append(directive.name.stringValue)
            buffer.append("\n")
        } else {
            buffer.append("%%")
            buffer.append(directive.name.stringValue)

            if !directive.value.isEmpty {
                buffer.append(" ")
                buffer.append(directive.value)
            }

            buffer.append("\n")
        }
    }

    private mutating func _writeField(_ field: ABCField) throws {
        let (letter, value) = try formatField(field)

        buffer.append(letter)
        buffer.append(":")
        buffer.append(value)
        buffer.append("\n")

        switch field {
        case let .meter(timeSignature):
            meter = timeSignature

        case let .unitNoteLength(duration):
            unitNoteLength = duration

        default:
            break
        }
    }

    private mutating func _writeFileHeaders() throws {
        for entry in tunebook.fileHeader {
            switch entry {
            case let .directive(directive):
                _writeDirective(directive)

            case let .field(field):
                guard field.isValidInFileHeader
                else { throw ABCFormatter.Error.misplacedFileHeaderField(field) }

                try _writeField(field)
            }
        }
    }

    private mutating func _writeSymbolsLine(_ symbols: [ABCSymbol]) throws {
        var line = ""

        for symbol in symbols {
            if case .beamBreak = symbol {
                line.append(" ")

                continue
            }

            // Keep duration state current for inline fields within the line.
            if case let .inlineField(.meter(timeSignature)) = symbol {
                meter = timeSignature
            } else if case let .inlineField(.unitNoteLength(duration)) = symbol {
                unitNoteLength = duration
            }

            try line.append(formatSymbol(symbol, unitNoteLength, meter))
        }

        buffer.append(line)
        buffer.append("\n")
    }

    private mutating func _writeTune(_ tune: ABCTune,
                                     _ autoReferenceNumber: ABCReferenceNumber?) throws {
        var seenReferenceNumber = false

        if let refereneceNumber = autoReferenceNumber {
            try _writeField(.referenceNumber(refereneceNumber))

            seenReferenceNumber = true
        }

        for entry in tune.header {
            switch entry {
            case let .directive(directive):
                _writeDirective(directive)

            case let .field(field):
                if !seenReferenceNumber {
                    guard case .referenceNumber = field
                    else { throw ABCFormatter.Error.missingReferenceNumber }

                    seenReferenceNumber = true
                } else {
                    guard field.isValidInTuneHeader
                    else { throw ABCFormatter.Error.misplacedTuneField(field) }
                }

                try _writeField(field)
            }
        }

        for entry in tune.body {
            switch entry {
            case let .directive(directive):
                _writeDirective(directive)

            case let .field(field):
                guard field.isValidInTuneBody
                else { throw ABCFormatter.Error.misplacedTuneField(field) }

                try _writeField(field)

            case let .symbols(symbols):
                try _writeSymbolsLine(symbols)
            }
        }
    }
}
