// © 2025–2026 John Gary Pusey (see LICENSE.md)

/// An ABC voice specification.
public struct ABCVoice {

    // MARK: Public Initializers

    /// Creates a new voice specification with the provided identifier, clef,
    /// and properties, or `nil` if any property key is empty.
    ///
    /// - Parameter id:         The identifier of the voice.
    /// - Parameter clef:       Optional clef and transposition properties.
    ///                         Defaults to `nil`.
    /// - Parameter properties: A dictionary of named properties for the voice.
    ///                         All keys must be non-empty.
    public init?(id: ID,
                 clef: ABCClef? = nil,
                 properties: [String: String] = [:]) {
        guard Self._isValid(id, clef, properties)
        else { return nil }

        self.clef = clef
        self.id = id
        self.properties = properties
    }

    // MARK: Public Instance Properties

    /// Optional clef and transposition properties.
    public let clef: ABCClef?

    /// The identifier of this voice.
    public let id: ID

    /// A dictionary of named properties for this voice.
    public let properties: [String: String]
}

// MARK: -

extension ABCVoice {

    // MARK: Public Instance Properties

    /// The name of this voice, or `nil` if not specified.
    public var name: String? {
        properties["name"] ?? properties["nm"]
    }

    /// The subname (abbreviated name) of this voice, or `nil` if not
    /// specified.
    public var subname: String? {
        properties["subname"] ?? properties["sname"] ?? properties["snm"]
    }

    // MARK: Private Type Methods

    private static func _isValid(_ id: ID,
                                 _ clef: ABCClef?,
                                 _ properties: [String: String]) -> Bool {
        properties.keys.allSatisfy { !$0.isEmpty }
    }
}

// MARK: - Equatable

extension ABCVoice: Equatable {
}

// MARK: - Sendable

extension ABCVoice: Sendable {
}
