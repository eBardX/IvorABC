// © 2026 John Gary Pusey (see LICENSE.md)

import IvorABC
import Testing

struct ABCValidationErrorTests {
}

// MARK: -

extension ABCValidationErrorTests {
    @Test
    func equality() {
        #expect(ABCValidationError.notNormalized == .notNormalized)
    }

    @Test
    func message_notNormalized() {
        let error = ABCValidationError.notNormalized

        #expect(!error.message.isEmpty)
        #expect(error.message.lowercased().contains("normalized"))
    }

    @Test
    func category_notNormalized() {
        #expect(ABCValidationError.notNormalized.category != nil)
    }
}
