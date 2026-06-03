// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing

struct ABCPitchAccidentalTests {
}

// MARK: -

extension ABCPitchAccidentalTests {
    @Test
    func allCasesAreDistinct() {
        let allCases: [ABCPitch.Accidental] = [
            .doubleFlat, .flat, .natural, .sharp, .doubleSharp
        ]

        for i in allCases.indices {
            for j in allCases.indices where i != j {
                #expect(allCases[i] != allCases[j])
            }
        }
    }

    @Test
    func equality() {
        #expect(ABCPitch.Accidental.natural == .natural)
        #expect(ABCPitch.Accidental.sharp == .sharp)
        #expect(ABCPitch.Accidental.flat == .flat)
        #expect(ABCPitch.Accidental.doubleSharp == .doubleSharp)
        #expect(ABCPitch.Accidental.doubleFlat == .doubleFlat)
    }
}
