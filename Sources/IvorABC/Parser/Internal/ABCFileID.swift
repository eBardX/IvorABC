// © 2025–2026 John Gary Pusey (see LICENSE.md)

internal struct ABCFileID {

    // MARK: Internal Instance Properties

    internal let version: ABCVersion
}

// MARK: - Equatable

extension ABCFileID: Equatable {
}

// MARK: - Sendable

extension ABCFileID: Sendable {
}
