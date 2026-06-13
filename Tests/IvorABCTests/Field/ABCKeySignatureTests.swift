// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing

struct ABCKeySignatureTests {
}

// MARK: -

extension ABCKeySignatureTests {
    @Test
    func equality_clefOnly() {
        let clef = ABCClef(name: "bass")

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
        let sig = ABCKeySignature.standard(.g, .major, [], nil)

        #expect(sig == .standard(.g, .major, [], nil))
    }

    @Test
    func inequality() {
        #expect(ABCKeySignature.empty != .highlandPipes)
        #expect(ABCKeySignature.highlandPipes != .highlandPipesPreset)
        #expect(ABCKeySignature.standard(.g, .major, [], nil) != .standard(.d, .major, [], nil))
        #expect(ABCKeySignature.standard(.g, .major, [], nil) != .standard(.g, .minor, [], nil))
        #expect(ABCKeySignature.empty != .standard(.c, .major, [], nil))
    }
}
