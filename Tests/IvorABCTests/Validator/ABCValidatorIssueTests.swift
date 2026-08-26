// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import Testing

struct ABCValidatorIssueTests {
}

// MARK: -

extension ABCValidatorIssueTests {
    @Test
    func equality() {
        #expect(ABCValidator.Issue.missingKey(1) == .missingKey(1))
    }

    @Test
    func inequality_differentTuneIndex() {
        #expect(ABCValidator.Issue.missingKey(1) != .missingKey(2))
    }

    @Test
    func message_invalidInlineField() {
        let issue = ABCValidator.Issue.invalidInlineField(.part(.a), 0)

        #expect(issue.message.contains("Tune 0"))
        #expect(issue.message.contains("inline"))
    }

    @Test
    func message_misplacedFileHeaderField() {
        let issue = ABCValidator.Issue.misplacedFileHeaderField(.part(.a))

        #expect(issue.message.contains("file header"))
    }

    @Test
    func message_undefinedUserSymbol_fileHeader() {
        let issue = ABCValidator.Issue.undefinedUserSymbol(nil)

        #expect(issue.message.contains("The file header"))
    }

    @Test
    func message_undefinedUserSymbol_tune() {
        let issue = ABCValidator.Issue.undefinedUserSymbol(2)

        #expect(issue.message.contains("Tune 2"))
    }

    @Test
    func tuneIndex_forEachTuneScopedCase() {
        #expect(ABCValidator.Issue.invalidInlineField(.part(.a), 1).tuneIndex == 1)
        #expect(ABCValidator.Issue.misplacedKey(1).tuneIndex == 1)
        #expect(ABCValidator.Issue.misplacedReferenceNumber(1).tuneIndex == 1)
        #expect(ABCValidator.Issue.misplacedTuneBodyField(.part(.a), 1).tuneIndex == 1)
        #expect(ABCValidator.Issue.misplacedTuneHeaderField(.part(.a), 1).tuneIndex == 1)
        #expect(ABCValidator.Issue.misplacedTuneTitle(1).tuneIndex == 1)
        #expect(ABCValidator.Issue.missingKey(1).tuneIndex == 1)
        #expect(ABCValidator.Issue.missingReferenceNumber(1).tuneIndex == 1)
        #expect(ABCValidator.Issue.missingTuneTitle(1).tuneIndex == 1)
        #expect(ABCValidator.Issue.multipleChordSymbols(1).tuneIndex == 1)
        #expect(ABCValidator.Issue.multipleGraceNotes(1).tuneIndex == 1)
        #expect(ABCValidator.Issue.undefinedUserSymbol(1).tuneIndex == 1)
    }

    @Test
    func tuneIndex_nilForFileHeaderCase() {
        #expect(ABCValidator.Issue.misplacedFileHeaderField(.part(.a)).tuneIndex == nil)
    }

    @Test
    func tuneIndex_nilForUndefinedUserSymbolInFileHeader() {
        #expect(ABCValidator.Issue.undefinedUserSymbol(nil).tuneIndex == nil)
    }
}
