// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing
import XestiTools

struct ABCKeySignatureStandardTests {
}

// MARK: -

extension ABCKeySignatureStandardTests {
    @Test
    func equality() {
        let a = ABCKeySignature.Standard(tonic: .c, mode: .major)
        let b = ABCKeySignature.Standard(tonic: .c, mode: .major)

        #expect(a == b)
    }

    @Test
    func inequality_differentMode() {
        let a = ABCKeySignature.Standard(tonic: .c, mode: .major)
        let b = ABCKeySignature.Standard(tonic: .c, mode: .minor)

        #expect(a != b)
    }

    @Test
    func inequality_differentTonic() {
        let a = ABCKeySignature.Standard(tonic: .c, mode: .major)
        let b = ABCKeySignature.Standard(tonic: .d, mode: .major)

        #expect(a != b)
    }

    @Test
    func init_allowsExplicitModeForAnyTonic() {
        let standard = ABCKeySignature.Standard(tonic: .cSharp, mode: .explicit)

        #expect(standard != nil)
    }

    @Test
    func init_nilForDuplicateExtraAccidentalLetters() {
        let standard = ABCKeySignature.Standard(tonic: .d,
                                                mode: .major,
                                                extraAccidentals: [makePitch(.f, .sharp, 4),
                                                                   makePitch(.f, .natural, 4)])

        #expect(standard == nil)
    }

    @Test
    func init_nilForOmittedAccidentalInExtraAccidentals() {
        let standard = ABCKeySignature.Standard(tonic: .d,
                                                mode: .major,
                                                extraAccidentals: [makePitch(.f, .omitted, 4)])

        #expect(standard == nil)
    }

    @Test
    func init_nilForUnrecognizedTonicModeCombination() {
        let standard = ABCKeySignature.Standard(tonic: .fFlat, mode: .lydian)

        #expect(standard != nil)

        let invalid = ABCKeySignature.Standard(tonic: .fFlat, mode: .minor)

        #expect(invalid == nil)
    }

    @Test
    func init_storesProperties() {
        let clef = ABCClef(name: .treble)
        let standard = ABCKeySignature.Standard(tonic: .g,
                                                mode: .major,
                                                extraAccidentals: [makePitch(.f, .sharp, 4)],
                                                clef: clef)

        #expect(standard?.tonic == .g)
        #expect(standard?.mode == .major)
        #expect(standard?.extraAccidentals == [makePitch(.f, .sharp, 4)])
        #expect(standard?.clef == clef)
    }

    @Test
    func init_storesPropertiesWithDefaults() {
        let standard = ABCKeySignature.Standard(tonic: .c, mode: .major)

        #expect(standard?.extraAccidentals.isEmpty == true)
        #expect(standard?.clef == nil)
    }
}
