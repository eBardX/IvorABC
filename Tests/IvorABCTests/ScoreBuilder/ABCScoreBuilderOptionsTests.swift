// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing

struct ABCScoreBuilderOptionsTests {
}

// MARK: -

extension ABCScoreBuilderOptionsTests {
    @Test
    func empty_containsNoOptions() {
        let options: ABCScoreBuilder.Options = []

        #expect(!options.contains(.ignoreErrors))
        #expect(!options.contains(.optimizeForPlayback))
        #expect(!options.contains(.stripDirectives))
    }

    @Test
    func union_combinesOptions() {
        let options: ABCScoreBuilder.Options = [.ignoreErrors, .stripDirectives]

        #expect(options.contains(.ignoreErrors))
        #expect(options.contains(.stripDirectives))
        #expect(!options.contains(.optimizeForPlayback))
    }
}
