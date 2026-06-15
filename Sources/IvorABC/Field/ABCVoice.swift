// © 2025–2026 John Gary Pusey (see LICENSE.md)

/// An ABC voice specification.
public struct ABCVoice {

    // MARK: Public Initializers

    /// Creates a new voice specification with the provided identifier and
    /// properties.
    ///
    /// - Parameter id:         The identifier of the voice.
    /// - Parameter properties: A dictionary of named properties for the voice.
    public init(id: String,
                properties: [String: String]) {
        self.id = id                    // validate?
        self.properties = properties
    }

    // MARK: Public Instance Properties

    /// The identifier of this voice.
    public let id: String

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
}

// MARK: - Equatable

extension ABCVoice: Equatable {
}

// MARK: - Sendable

extension ABCVoice: Sendable {
}
