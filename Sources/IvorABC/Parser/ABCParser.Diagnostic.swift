// © 2026 John Gary Pusey (see LICENSE.md)

extension ABCParser {

    // MARK: Public Nested Types

    /// A diagnostic message produced by ``ABCParser`` when parsing in lenient mode.
    public enum Diagnostic {
        /// A deprecated field was accepted in loose parsing stance. The
        /// associated value is the field that was accepted.
        case deprecatedField(ABCField)

        /// A `Q:` field used a deprecated tempo form — either a bare-integer
        /// (e.g. `Q:120`) or the `Q:C=rate` / `Q:Cn=rate` beat-unit form. The
        /// associated value is the tempo that was parsed from the deprecated form.
        case deprecatedTempo(ABCTempo)

        /// A subsequent `%%abc-charset` or `I:abc-charset` directive was ignored
        /// because an earlier directive (or a UTF-8 BOM) already established the
        /// character encoding. The associated value is the charset name that was
        /// ignored.
        case duplicateCharset(String)

        /// The input began with a non-UTF-8 byte order mark; the BOM was stripped
        /// and the content is treated as ISO-8859-1.
        case ignoredByteOrderMark

        /// The declared encoding could not decode the file content; the content
        /// was re-decoded as ISO-8859-1.
        case invalidUTF8

        /// The version string in a `%abc-M.m`, `%%abc-version`, or `I:abc-version`
        /// line could not be parsed as a valid `M.m` version number. The associated
        /// value is the raw version string that was encountered.
        case malformedVersion(String)

        /// A field appeared outside its permitted tune header or body section and
        /// was skipped. The associated value is the field that was skipped.
        case misplacedField(ABCField)

        /// A tune had no ``ABCField/key(_:)`` field terminating its header; the
        /// tune body was started at the first music symbols line.
        case missingKeyField

        /// A `%%abc-charset` or `I:abc-charset` directive named a charset that is
        /// not recognized; the content is treated as ISO-8859-1. The associated
        /// value is the unrecognized charset name.
        case unrecognizedCharset(String)

        /// A line could not be parsed and was skipped. The associated value is
        /// the text of the skipped line.
        case unrecognizedLine(String)

        /// The file identifier or `%%abc-version` directive declared a version not
        /// known to the parser; parsing continued with the declared version. The
        /// associated value is the version that was declared. This diagnostic is
        /// emitted regardless of strictness mode.
        case unrecognizedVersion(ABCVersion)
    }
}

// MARK: -

extension ABCParser.Diagnostic {

    // MARK: Public Instance Properties

    /// A human-readable description of this diagnostic.
    public var message: String {
        switch self {
        case let .deprecatedField(field):
            "Deprecated field '\(field)' accepted in loose parsing stance"

        case let .deprecatedTempo(tempo):
            "Deprecated tempo form; rate '\(tempo.rate.map { "\($0)" } ?? "unspecified")' was accepted"

        case let .duplicateCharset(name):
            "Charset '\(name)' was ignored; an earlier charset directive takes precedence"

        case .ignoredByteOrderMark:
            "Non-UTF-8 byte order mark was ignored; treating content as ISO-8859-1"

        case .invalidUTF8:
            "Declared encoding could not decode the file content; falling back to ISO-8859-1"

        case let .malformedVersion(raw):
            "Malformed version string '\(raw)'; version is treated as unspecified"

        case let .misplacedField(field):
            "Misplaced field '\(field)' was skipped"

        case .missingKeyField:
            "Tune has no K: field; tune body assumed to start at first music line"

        case let .unrecognizedCharset(name):
            "Unrecognized charset '\(name)'; falling back to ISO-8859-1"

        case let .unrecognizedLine(line):
            "Unrecognized line skipped: '\(line)'"

        case let .unrecognizedVersion(version):
            "Unrecognized ABC version \(version.major).\(version.minor); parsing continued with declared version"
        }
    }
}

// MARK: - Equatable

extension ABCParser.Diagnostic: Equatable {
}

// MARK: - Sendable

extension ABCParser.Diagnostic: Sendable {
}
