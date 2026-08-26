// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing

struct ABCPartTests {
}

// MARK: -

extension ABCPartTests {
    @Test
    func allCasesAreDistinct() {
        let allCases: [ABCPart] = [.a,
                                   .b,
                                   .c,
                                   .d,
                                   .e,
                                   .f,
                                   .g,
                                   .h,
                                   .i,
                                   .j,
                                   .k,
                                   .l,
                                   .m,
                                   .n,
                                   .o,
                                   .p,
                                   .q,
                                   .r,
                                   .s,
                                   .t,
                                   .u,
                                   .v,
                                   .w,
                                   .x,
                                   .y,
                                   .z]

        for i in allCases.indices {
            for j in allCases.indices where i != j {
                #expect(allCases[i] != allCases[j])
            }
        }
    }

    @Test
    func equality() {
        #expect(ABCPart.a == .a)
        #expect(ABCPart.m == .m)
        #expect(ABCPart.z == .z)
    }
}
