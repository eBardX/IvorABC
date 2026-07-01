// © 2026 John Gary Pusey (see LICENSE.md)

public import Foundation

private import XestiTools

/// A parser for ABC notation.
///
/// The parser derives its parse policy automatically from the declared
/// version in the input: strict when the file declares ABC 2.1 or later, loose
/// otherwise (including unversioned files). ``Diagnostic`` values emitted during
/// loose recovery or for deprecated forms accepted in all stances are always
/// included in the result.
public struct ABCParser {

    // MARK: Public Initializers

    /// Creates a new ABC parser.
    public init() {
    }
}

// MARK: -

extension ABCParser {

    // MARK: Public Instance Methods

    /// Parses ABC notation data and returns the resulting tunebook along
    /// with any diagnostic messages produced during parsing.
    ///
    /// - Parameter data: The ABC notation data to parse.
    ///
    /// - Returns:  A tuple containing the ``ABCTunebook`` parsed from `data`
    ///             and an array of ``Diagnostic`` values describing any
    ///             recoveries or deprecated forms encountered.
    ///
    /// - Throws:   ``Error`` if the data cannot be parsed.
    public func parse(_ data: Data) throws -> (ABCTunebook, [Diagnostic]) {
        var reader = Reader(data: data)

        return try reader.readTunebook()
    }
}
