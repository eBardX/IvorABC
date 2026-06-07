// © 2026 John Gary Pusey (see LICENSE.md)

public import Foundation

/// A type that formats an ABC tunebook as UTF-8 data.
public struct ABCFormatter {

    // MARK: Public Initializers

    /// Creates a new ABC formatter.
    public init() {
    }
}

// MARK: -

extension ABCFormatter {

    // MARK: Public Instance Methods

    /// Formats the provided tunebook as ABC 2.1-compliant UTF-8 data.
    ///
    /// - Parameter tunebook:   The tunebook to format.
    ///
    /// - Returns:  The UTF-8 encoded ABC representation of the tunebook.
    ///
    /// - Throws:   ``ABCFormatError`` if the tunebook cannot be formatted
    ///             compliantly.
    public func format(_ tunebook: ABCTunebook) throws -> Data {
        var writer = Writer(tunebook: tunebook)

        return try writer.writeTunebook()
    }
}

// MARK: - Sendable

extension ABCFormatter: Sendable {
}
