// © 2026 John Gary Pusey (see LICENSE.md)

import IvorABC
import Testing

struct ABCValidatorErrorTests {
}

// MARK: -

extension ABCValidatorErrorTests {
    @Test
    func equality() {
        #expect(ABCValidator.Error.notNormalized == .notNormalized)
    }

    @Test
    func message_notNormalized() {
        let error = ABCValidator.Error.notNormalized

        #expect(!error.message.isEmpty)
        #expect(error.message.lowercased().contains("normalized"))
    }

    @Test
    func category_notNormalized() {
        #expect(ABCValidator.Error.notNormalized.category != nil)
    }
}
