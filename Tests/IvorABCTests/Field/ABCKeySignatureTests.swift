// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing

struct ABCKeySignatureTests {
}

// MARK: -

extension ABCKeySignatureTests {
    @Test
    func equality_clefOnly() {
        let clef = ABCKeySignature.Clef(name: "bass")

        #expect(ABCKeySignature.clefOnly(clef) == .clefOnly(clef))
    }

    @Test
    func equality_empty() {
        #expect(ABCKeySignature.empty == .empty)
    }

    @Test
    func equality_highlandPipes() {
        #expect(ABCKeySignature.highlandPipes == .highlandPipes)
    }

    @Test
    func equality_highlandPipesPreset() {
        #expect(ABCKeySignature.highlandPipesPreset == .highlandPipesPreset)
    }

    @Test
    func equality_standard() {
        let sig = makeKeySignature(.g, .major)

        #expect(sig == makeKeySignature(.g, .major))
    }

    @Test
    func inequality() {
        #expect(ABCKeySignature.empty != .highlandPipes)
        #expect(ABCKeySignature.highlandPipes != .highlandPipesPreset)
        #expect(makeKeySignature(.g, .major) != makeKeySignature(.d, .major))
        #expect(makeKeySignature(.g, .major) != makeKeySignature(.g, .minor))
        #expect(ABCKeySignature.empty != makeKeySignature(.c, .major))
    }
}
