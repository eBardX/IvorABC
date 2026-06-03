// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing

struct ABCKeySignatureTonicTests {
}

// MARK: -

extension ABCKeySignatureTonicTests {
    @Test
    func allCasesAreDistinct() {
        let allCases: [ABCKeySignature.Tonic] = [
            .a, .aFlat, .aSharp,
            .b, .bFlat, .bSharp,
            .c, .cFlat, .cSharp,
            .d, .dFlat, .dSharp,
            .e, .eFlat, .eSharp,
            .f, .fFlat, .fSharp,
            .g, .gFlat, .gSharp
        ]

        for i in allCases.indices {
            for j in allCases.indices where i != j {
                #expect(allCases[i] != allCases[j])
            }
        }
    }

    @Test
    func equality() {
        #expect(ABCKeySignature.Tonic.c == .c)
        #expect(ABCKeySignature.Tonic.gSharp == .gSharp)
        #expect(ABCKeySignature.Tonic.bFlat == .bFlat)
    }
}
