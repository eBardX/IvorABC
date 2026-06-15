// © 2025–2026 John Gary Pusey (see LICENSE.md)

/// An ABC reference number.
public struct ABCRefNumber {    // UIntRepresentable ???

    // MARK: Public Initializers

    /// Creates a new reference number with the provided unsigned integer value.
    ///
    /// - Parameter uintValue: The unsigned integer value of the reference
    ///                        number.
    public init(uintValue: UInt) {
        self.uintValue = uintValue
    }

    // MARK: Public Instance Properties

    /// The unsigned integer value of this reference number.
    public let uintValue: UInt
}

// MARK: - Equatable

extension ABCRefNumber: Equatable {
}

// MARK: - Sendable

extension ABCRefNumber: Sendable {
}
