// © 2026 John Gary Pusey (see LICENSE.md)

/// A mutable context for resolving the effective accidental of a note,
/// accounting for the active key signature and accidentals set earlier
/// in the current bar.
///
/// Usage mirrors ``ABCSymbol/resolveTuplet(meter:)``: create a context
/// for the current key signature, call ``resolveAccidental(for:)`` to
/// query a note's effective accidental, ``update(with:)`` after each note
/// to record any written accidental into the bar state, and ``reset()``
/// whenever a bar line is crossed.
///
/// ```swift
/// var ctx = ABCAccidentalContext(keySignature: .standard(.g, .major, [], nil))
///
/// for symbol in symbols {
///     switch symbol {
///     case let .note(note):
///         let acc = ctx.resolveAccidental(for: note)
///         ctx.update(with: note)
///         // use acc …
///     case .barRepeat:
///         ctx.reset()
///     default:
///         break
///     }
/// }
/// ```
public struct ABCAccidentalContext {

    // MARK: Public Initializers

    /// Creates a new context for the given key signature.
    ///
    /// - Parameter keySignature: The active key signature, or `nil` to assume
    ///                           no key (equivalent to C major / no accidentals).
    public init(keySignature: ABCKeySignature? = nil) {
        self.barAccidentals = [:]
        self.keyAccidentals = keySignature?.keyAccidentals ?? [:]
    }

    // MARK: Public Instance Methods

    /// Clears all bar-level accidentals.
    ///
    /// Call this whenever a bar line is crossed.
    public mutating func reset() {
        barAccidentals.removeAll()
    }

    /// Returns the effective accidental for `note`, applying bar-level and
    /// key-level accidentals according to the ABC 2.1 propagation rules.
    ///
    /// Resolution order:
    /// 1. If the note has an explicitly written accidental, that value is used
    ///    and will propagate to all subsequent notes of the same pitch letter
    ///    within the bar (after calling ``update(with:)``).
    /// 2. If an accidental was set earlier in the bar for the same pitch letter,
    ///    that value is used.
    /// 3. If the key signature implies an accidental for the pitch letter, that
    ///    value is used.
    /// 4. Otherwise `.natural` is returned.
    ///
    /// - Parameter note: The note whose effective accidental is to be resolved.
    ///
    /// - Returns: The effective ``ABCPitch/Accidental`` for the note.
    public func resolveAccidental(for note: ABCNote) -> ABCPitch.Accidental {
        if note.pitch.accidental != .omitted {
            return note.pitch.accidental
        }

        let letter = note.pitch.letter

        if let barAcc = barAccidentals[letter] {
            return barAcc
        }

        return keyAccidentals[letter] ?? .natural
    }

    /// Records any written accidental on `note` into the bar state so that it
    /// propagates to all subsequent notes of the same pitch letter.
    ///
    /// Call this after ``resolveAccidental(for:)`` for every note processed.
    ///
    /// - Parameter note: The note just processed.
    public mutating func update(with note: ABCNote) {
        let acc = note.pitch.accidental

        guard acc != .omitted
        else { return }

        barAccidentals[note.pitch.letter] = acc
    }

    // MARK: Private Instance Properties

    private var barAccidentals: [ABCPitch.Letter: ABCPitch.Accidental]
    private let keyAccidentals: [ABCPitch.Letter: ABCPitch.Accidental]
}

// MARK: - Sendable

extension ABCAccidentalContext: Sendable {
}
