// © 2026 John Gary Pusey (see LICENSE.md)

import Foundation
@testable import IvorABC
import Testing

struct ABCParserTests {
}

// MARK: -

extension ABCParserTests {
    @Test
    func test_parseEmptyTunebook() throws {
        let input = "%abc-2.1\n"
        let data = Data(input.utf8)
        let parser = ABCParser()

        let tunebook = try parser.parse(data)

        #expect(tunebook.version.major == 2)
        #expect(tunebook.version.minor == 1)
        #expect(tunebook.headers.isEmpty)
        #expect(tunebook.tunes.isEmpty)
    }

    @Test
    func test_parseInvalidUTF8Throws() {
        let data = Data([0xFF, 0xFE])
        let parser = ABCParser()

        #expect(throws: ABCParseError.self) {
            try parser.parse(data)
        }
    }

    @Test
    func test_parseMissingFileIDThrows() {
        let input = "X:1\nT:Test\nK:C\nabc\n"
        let data = Data(input.utf8)
        let parser = ABCParser()

        #expect(throws: ABCParseError.self) {
            try parser.parse(data)
        }
    }

    @Test
    func test_parseMinimalTune() throws {
        let input = "%abc-2.1\n\nX:1\nT:Test Tune\nK:C\nCDEF|GABc|\n"
        let data = Data(input.utf8)
        let parser = ABCParser()

        let tunebook = try parser.parse(data)

        #expect(tunebook.tunes.count == 1)

        let tune = tunebook.tunes[0]

        #expect(!tune.entries.isEmpty)
    }

    @Test
    func test_parseMultipleTunes() throws {
        let input = "%abc-2.1\n\nX:1\nT:First\nK:C\nCDEF|\n\nX:2\nT:Second\nK:G\nGABc|\n"
        let data = Data(input.utf8)
        let parser = ABCParser()

        let tunebook = try parser.parse(data)

        #expect(tunebook.tunes.count == 2)
    }

    @Test
    func test_parseTunebookWithFileHeaders() throws {
        let input = "%abc-2.1\nM:4/4\nL:1/8\n\nX:1\nT:Test\nK:C\nCDEF|\n"
        let data = Data(input.utf8)
        let parser = ABCParser()

        let tunebook = try parser.parse(data)

        #expect(tunebook.headers.count == 2)
        #expect(tunebook.tunes.count == 1)
    }

    @Test
    func test_parseTuneWithDirective() throws {
        let input = "%abc-2.1\n\nX:1\nT:Test\n%%pagewidth 21cm\nK:C\nCDEF|\n"
        let data = Data(input.utf8)
        let parser = ABCParser()

        let tunebook = try parser.parse(data)

        #expect(tunebook.tunes.count == 1)
    }

    @Test
    func test_parseUnsupportedVersionThrows() {
        let input = "%abc-3.0\nX:1\nT:Test\nK:C\nabc\n"
        let data = Data(input.utf8)
        let parser = ABCParser()

        #expect(throws: ABCParseError.self) {
            try parser.parse(data)
        }
    }
}
