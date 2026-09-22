// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing
import XestiTools

struct ABCTuneTests {
}

// MARK: -

extension ABCTuneTests {
    @Test
    func equality() {
        let header: [ABCHeaderEntry] = [.field(.tuneTitle("My Tune"))]
        let a = makeTune(header: header)
        let b = makeTune(header: header)

        #expect(a == b)
    }

    @Test
    func inequality() {
        let a = makeTune(header: [.field(.tuneTitle("Tune A"))])
        let b = makeTune(header: [.field(.tuneTitle("Tune B"))])

        #expect(a != b)
    }

    @Test
    func init_emptyHeader_returnsNil() {
        #expect(ABCTune(header: [], body: []) == nil)
    }

    @Test
    func init_storesHeaderAndBody() {
        let header: [ABCHeaderEntry] = [.field(.referenceNumber(ABCReferenceNumber(1))),
                                        .field(.tuneTitle("Test")),
                                        .field(.key(makeKeySignature(.c, .major)))]
        let body: [ABCBodyEntry] = [.field(.tempo(makeTempo(1, 4, 120))),
                                    .symbols([])]
        let tune = makeTune(header: header, body: body)

        #expect(tune.header == header)
        #expect(tune.body == body)
    }
}
