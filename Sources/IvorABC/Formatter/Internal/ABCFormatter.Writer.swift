// © 2026 John Gary Pusey (see LICENSE.md)

internal import Foundation

private import XestiTools

extension ABCFormatter {

    // MARK: Internal Nested Types

    internal struct Writer {

        // MARK: Internal Initializers

        internal init(tunebook: ABCTunebook) {
            self.buffer = ""
            self.tunebook = tunebook
        }

        // MARK: Private Instance Properties

        private let tunebook: ABCTunebook

        private var buffer: String
    }
}

// MARK: -

extension ABCFormatter.Writer {

    // MARK: Internal Instance Methods

    internal mutating func writeTunebook() -> Data {
        let version = tunebook.version.require()

        buffer.append("%abc-\(version.major).\(version.minor)\n")

        _writeFileHeaders()

        for (index, tune) in tunebook.tunes.enumerated() {
            if index > 0 {
                buffer.append("\n")
            }

            _writeTune(tune)
        }

        return buffer.data(using: .utf8).require()
    }

    // MARK: Private Instance Methods

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

    private mutating func _writeField(_ field: ABCField) {
        let (letter, value) = formatField(field)

        buffer.append(letter)
        buffer.append(":")
        buffer.append(value)
        buffer.append("\n")
    }

    private mutating func _writeFileHeaders() {
        for entry in tunebook.fileHeader {
            switch entry {
            case let .directive(directive):
                _writeDirective(directive)

            case let .field(field):
                _writeField(field)
            }
        }
    }

    private mutating func _writeSymbolsLine(_ symbols: [ABCSymbol]) {
        var line = ""

        for symbol in symbols {
            if case .beamBreak = symbol {
                line.append(" ")

                continue
            }

            line.append(formatSymbol(symbol))
        }

        buffer.append(line)
        buffer.append("\n")
    }

    private mutating func _writeTune(_ tune: ABCTune) {
        for entry in tune.header {
            switch entry {
            case let .directive(directive):
                _writeDirective(directive)

            case let .field(field):
                _writeField(field)
            }
        }

        for entry in tune.body {
            switch entry {
            case let .directive(directive):
                _writeDirective(directive)

            case let .field(field):
                _writeField(field)

            case let .symbols(symbols):
                _writeSymbolsLine(symbols)
            }
        }
    }
}
