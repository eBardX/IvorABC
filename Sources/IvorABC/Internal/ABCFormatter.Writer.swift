// © 2026 John Gary Pusey (see LICENSE.md)

internal import Foundation

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
        buffer.append("%abc-\(tunebook.version.major).\(tunebook.version.minor)\n")

        try _writeFileHeaders()

        for (index, tune) in tunebook.tunes.enumerated() {
            if index > 0 {
                buffer.append("\n")
            }

            try _writeTune(tune)
        }

        guard let data = buffer.data(using: .utf8)
        else { throw ABCFormatError.stringConversionFailed }

        return data
    }

    // MARK: Private Instance Methods

    private mutating func _writeDirective(_ directive: ABCDirective) {
        if let content = directive.content {
            buffer.append("%%begin")
            buffer.append(directive.name)

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
            buffer.append(directive.name)
            buffer.append("\n")
        } else {
            buffer.append("%%")
            buffer.append(directive.name)

            if !directive.value.isEmpty {
                buffer.append(" ")
                buffer.append(directive.value)
            }

            buffer.append("\n")
        }
    }

    private mutating func _writeEntry(_ entry: ABCEntry) throws {
        switch entry {
        case let .directive(d):
            _writeDirective(d)

        case let .field(f):
            try _writeField(f)

        case let .symbols(syms):
            try _writeSymbolsLine(syms)
        }
    }

    private mutating func _writeField(_ field: ABCField) throws {
        let (letter, value) = try formatFieldContent(field)

        buffer.append(letter)
        buffer.append(":")
        buffer.append(value)
        buffer.append("\n")

        switch field {
        case let .meter(ts):
            meter = ts

        case let .unitNoteLength(dur):
            unitNoteLength = dur

        default:
            break
        }
    }

    private mutating func _writeFileHeaders() throws {
        for header in tunebook.headers {
            switch header {
            case let .directive(d):
                _writeDirective(d)

            case let .field(f):
                guard f.isValidInFileHeader
                else { throw ABCFormatError.misplacedFileHeaderField(f) }

                try _writeField(f)
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
            if case let .inlineField(.meter(ts)) = symbol {
                meter = ts
            } else if case let .inlineField(.unitNoteLength(dur)) = symbol {
                unitNoteLength = dur
            }

            try line.append(formatSymbol(symbol, unitNoteLength, meter))
        }

        buffer.append(line)
        buffer.append("\n")
    }

    private mutating func _writeTune(_ tune: ABCTune) throws {
        var seenRefNumber = false
        var seenKey = false

        for entry in tune.entries {
            switch entry {
            case .directive:
                break

            case let .field(f):
                if !seenRefNumber {
                    guard case .refNumber = f
                    else { throw ABCFormatError.missingReferenceNumber }

                    seenRefNumber = true
                } else if !seenKey {
                    guard f.isValidInTuneHeader
                    else { throw ABCFormatError.misplacedTuneField(f) }

                    if case .key = f {
                        seenKey = true
                    }
                } else {
                    guard f.isValidInTuneBody
                    else { throw ABCFormatError.misplacedTuneField(f) }
                }

            case .symbols:
                guard seenKey
                else { throw ABCFormatError.missingKeySignature }
            }

            try _writeEntry(entry)
        }
    }
}
