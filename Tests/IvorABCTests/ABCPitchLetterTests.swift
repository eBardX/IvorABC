// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing

struct ABCPitchLetterTests {
}

// MARK: -

extension ABCPitchLetterTests {
    @Test
    func allCasesAreDistinct() {
        let allCases: [ABCPitch.Letter] = [.a, .b, .c, .d, .e, .f, .g]

        for i in allCases.indices {
            for j in allCases.indices where i != j {
                #expect(allCases[i] != allCases[j])
            }
        }
    }

    @Test
    func equality() {
        #expect(ABCPitch.Letter.a == .a)
        #expect(ABCPitch.Letter.b == .b)
        #expect(ABCPitch.Letter.c == .c)
        #expect(ABCPitch.Letter.d == .d)
        #expect(ABCPitch.Letter.e == .e)
        #expect(ABCPitch.Letter.f == .f)
        #expect(ABCPitch.Letter.g == .g)
    }
}
