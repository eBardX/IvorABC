// © 2025–2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing
import XestiTools

struct ABCParseFunctionsTests {
}

// MARK: -

extension ABCParseFunctionsTests {
    @Test
    func normalize() {
        #expect(IvorABC.normalize("  xyzzy  \\% keep  ") == "xyzzy % keep")
        #expect(IvorABC.normalize("  xyzzy  \\% keep  % ignore  ") == "xyzzy % keep % ignore")
        #expect(IvorABC.normalize("  xyzzy  % ignore  ") == "xyzzy % ignore")
        #expect(IvorABC.normalize("  xyzzy  %ignore \\% keep  ") == "xyzzy %ignore % keep")
    }

    @Test
    func parseLength_failure() {
        #expect(parseLength("") == nil)
        #expect(parseLength("3//2") == nil)
    }

    @Test
    func parseLength_success() {
        #expect(parseLength("/") == makeLength(1, 2))
        #expect(parseLength("//") == makeLength(1, 4))
        #expect(parseLength("///") == makeLength(1, 8))
        #expect(parseLength("/2") == makeLength(1, 2))
        #expect(parseLength("2") == makeLength(2, 1))
        #expect(parseLength("3") == makeLength(3, 1))
        #expect(parseLength("3/") == makeLength(3, 2))
        #expect(parseLength("3/2") == makeLength(3, 2))
        #expect(parseLength("4") == makeLength(4, 1))
        #expect(parseLength("8") == makeLength(8, 1))
    }

    @Test
    func parseRefNumber_failure() {
        #expect(parseReferenceNumber("") == nil)
        #expect(parseReferenceNumber("0") == nil)
    }

    @Test
    func parseRefNumber_success() {
        #expect(parseReferenceNumber("1") == makeReferenceNumber(1))
        #expect(parseReferenceNumber("007") == makeReferenceNumber(7))
        #expect(parseReferenceNumber("5836472") == makeReferenceNumber(5_836_472))
    }

    @Test
    func parseTuplet_failure() {
        #expect(parseTuplet("") == nil)
        #expect(parseTuplet("(3:::") == nil)
    }

    @Test
    func parseTuplet_success() {
        #expect(parseTuplet("(3") == (3, nil, nil))
        #expect(parseTuplet("(3::") == (3, nil, nil))
        #expect(parseTuplet("(3:2") == (3, 2, nil))
        #expect(parseTuplet("(3:2:3") == (3, 2, 3))
        #expect(parseTuplet("(3::2") == (3, nil, 2))
        #expect(parseTuplet("(3:2:2") == (3, 2, 2))
        #expect(parseTuplet("(3:2:4") == (3, 2, 4))
    }

    @Test
    func tidy() {
        #expect(IvorABC.tidy("  xyzzy  \\% keep  ") == "xyzzy  \\% keep")
        #expect(IvorABC.tidy("  xyzzy  \\% keep  % ignore  ") == "xyzzy  \\% keep")
        #expect(IvorABC.tidy("  xyzzy  % ignore  ") == "xyzzy")
        #expect(IvorABC.tidy("  xyzzy  %ignore \\% keep  ") == "xyzzy")
    }

    @Test
    func trim() {
        #expect(IvorABC.trim("  xyzzy  \\% keep  ") == "xyzzy  \\% keep")
        #expect(IvorABC.trim("  xyzzy  \\% keep  % ignore  ") == "xyzzy  \\% keep  % ignore")
        #expect(IvorABC.trim("  xyzzy  % ignore  ") == "xyzzy  % ignore")
        #expect(IvorABC.trim("  xyzzy  %ignore \\% keep  ") == "xyzzy  %ignore \\% keep")
    }

    @Test
    func trimPrefix() {
        #expect(IvorABC.trimPrefix("  xyzzy  \\% keep  ") == "xyzzy  \\% keep  ")
        #expect(IvorABC.trimPrefix("  xyzzy  \\% keep  % ignore  ") == "xyzzy  \\% keep  % ignore  ")
        #expect(IvorABC.trimPrefix("  xyzzy  % ignore  ") == "xyzzy  % ignore  ")
        #expect(IvorABC.trimPrefix("  xyzzy  %ignore \\% keep  ") == "xyzzy  %ignore \\% keep  ")
    }

    @Test
    func trimSuffix() {
        #expect(IvorABC.trimSuffix("  xyzzy  \\% keep  ") == "  xyzzy  \\% keep")
        #expect(IvorABC.trimSuffix("  xyzzy  \\% keep  % ignore  ") == "  xyzzy  \\% keep  % ignore")
        #expect(IvorABC.trimSuffix("  xyzzy  % ignore  ") == "  xyzzy  % ignore")
        #expect(IvorABC.trimSuffix("  xyzzy  %ignore \\% keep  ") == "  xyzzy  %ignore \\% keep")
    }

    @Test
    func uncomment() {
        #expect(IvorABC.uncomment("% this is a comment").isEmpty)
        #expect(IvorABC.uncomment("this is not a comment") == "this is not a comment")
        #expect(IvorABC.uncomment("  xyzzy  \\% keep  ") == "  xyzzy  \\% keep  ")
        #expect(IvorABC.uncomment("  xyzzy  \\% keep  % ignore  ") == "  xyzzy  \\% keep  ")
        #expect(IvorABC.uncomment("  xyzzy  % ignore  ") == "  xyzzy  ")
        #expect(IvorABC.uncomment("  xyzzy  %ignore \\% keep  ") == "  xyzzy  ")
    }
}
