// © 2025–2026 John Gary Pusey (see LICENSE.md)

/// An ABC time signature.
public enum ABCTimeSignature {
    /// Common time (4/4).
    case common

    /// A complex time signature with a compound numerator, e.g. `M:(2+3+2)/8`.
    case complex(AdditiveMeter)

    /// Cut time (2/2).
    case cut

    /// An empty time signature.
    case empty

    /// A standard time signature expressed as a fraction.
    case standard(StandardMeter)
}

// MARK: -

extension ABCTimeSignature {

    // MARK: Public Instance Properties

    /// A Boolean value indicating whether this time signature is a compound
    /// meter (i.e. beats subdivide into three), such as 6/8, 9/8, 12/8, or 15/8.
    public var isCompound: Bool {
        guard case let .standard(meter) = self
        else { return false }

        return meter.numerator > 3 && meter.numerator.isMultiple(of: 3)
    }
}

// MARK: - Equatable

extension ABCTimeSignature: Equatable {
}

// MARK: - Sendable

extension ABCTimeSignature: Sendable {
}
