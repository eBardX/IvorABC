// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing

struct ABCPitchNameTests {
}

// MARK: -

extension ABCPitchNameTests {
    @Test
    func allCasesAreDistinct() {
        let allCases: [ABCPitchName] = [.a,
                                        .aFlat,
                                        .aSharp,
                                        .b,
                                        .bFlat,
                                        .bSharp,
                                        .c,
                                        .cFlat,
                                        .cSharp,
                                        .d,
                                        .dFlat,
                                        .dSharp,
                                        .e,
                                        .eFlat,
                                        .eSharp,
                                        .f,
                                        .fFlat,
                                        .fSharp,
                                        .g,
                                        .gFlat,
                                        .gSharp]

        for i in allCases.indices {
            for j in allCases.indices where i != j {
                #expect(allCases[i] != allCases[j])
            }
        }
    }

    @Test
    func equality() {
        #expect(ABCPitchName.c == .c)
        #expect(ABCPitchName.fSharp == .fSharp)
        #expect(ABCPitchName.bFlat == .bFlat)
    }
}
