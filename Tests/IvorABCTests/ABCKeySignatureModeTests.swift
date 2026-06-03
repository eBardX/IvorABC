// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing

struct ABCKeySignatureModeTests {
}

// MARK: -

extension ABCKeySignatureModeTests {
    @Test
    func allCasesAreDistinct() {
        let allCases: [ABCKeySignature.Mode] = [
            .aeolian, .dorian, .explicit, .ionian, .locrian,
            .lydian, .major, .minor, .mixolydian, .phrygian
        ]

        for i in allCases.indices {
            for j in allCases.indices where i != j {
                #expect(allCases[i] != allCases[j])
            }
        }
    }

    @Test
    func equality() {
        #expect(ABCKeySignature.Mode.major == .major)
        #expect(ABCKeySignature.Mode.minor == .minor)
        #expect(ABCKeySignature.Mode.dorian == .dorian)
        #expect(ABCKeySignature.Mode.mixolydian == .mixolydian)
    }
}
