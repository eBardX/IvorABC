// © 2026 John Gary Pusey (see LICENSE.md)

extension ABCParser.Policy {

    // MARK: Internal Nested Types

    internal enum Mode {
        case loose
        case strict
    }
}

// MARK: - Sendable

extension ABCParser.Policy.Mode: Sendable {
}
