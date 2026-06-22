// © 2026 John Gary Pusey (see LICENSE.md)

/// A part label marking the start of a named section in an ABC tune body.
///
/// An ``ABCField/part(_:)`` field in the tune body — e.g., `P:A` — carries
/// a single `ABCPart` value. The 26 cases correspond to the uppercase ASCII
/// letters `A`–`Z`.
///
/// For the tune _header_ form of the `P:` field, see ``ABCPartSequence``.
public enum ABCPart {

    // MARK: Public Cases

    /// Part label A.
    case a

    /// Part label B.
    case b

    /// Part label C.
    case c

    /// Part label D.
    case d

    /// Part label E.
    case e

    /// Part label F.
    case f

    /// Part label G.
    case g

    /// Part label H.
    case h

    /// Part label I.
    case i

    /// Part label J.
    case j

    /// Part label K.
    case k

    /// Part label L.
    case l

    /// Part label M.
    case m

    /// Part label N.
    case n

    /// Part label O.
    case o

    /// Part label P.
    case p

    /// Part label Q.
    case q

    /// Part label R.
    case r

    /// Part label S.
    case s

    /// Part label T.
    case t

    /// Part label U.
    case u

    /// Part label V.
    case v

    /// Part label W.
    case w

    /// Part label X.
    case x

    /// Part label Y.
    case y

    /// Part label Z.
    case z
}

// MARK: - Equatable

extension ABCPart: Equatable {
}

// MARK: - Sendable

extension ABCPart: Sendable {
}
