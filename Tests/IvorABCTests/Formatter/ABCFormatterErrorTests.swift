// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing
import XestiTools

struct ABCFormatterErrorTests {
}

// MARK: -

extension ABCFormatterErrorTests {
    @Test
    func category_isIvorABC() {
        let error = ABCFormatter.Error.notValidated

        #expect(error.category?.description == "IvorABC")
    }

    @Test
    func equality() {
        let a = ABCFormatter.Error.notValidated
        let b = ABCFormatter.Error.notValidated

        #expect(a == b)
    }

    @Test
    func message_notValidated() {
        #expect(ABCFormatter.Error.notValidated.message.contains("validated()"))
    }
}
