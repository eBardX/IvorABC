// © 2026 John Gary Pusey (see LICENSE.md)

extension ABCParser {

    // MARK: Internal Nested Types

    internal struct Policy {

        // MARK: Internal Initializers

        internal init(version: ABCVersion?) {
            self.iFieldIsFreeText = (version == .v1_6)
            self.mode = if let version,
                           version >= .v2_1 {
                .strict
            } else {
                .loose
            }
        }

        // MARK: Internal Instance Properties

        internal let iFieldIsFreeText: Bool
        internal let mode: Mode
    }
}

// MARK: - Sendable

extension ABCParser.Policy: Sendable {
}
