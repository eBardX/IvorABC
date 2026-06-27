// © 2026 John Gary Pusey (see LICENSE.md)

import CoreFoundation
import Foundation

// MARK: Internal Type Aliases

internal typealias PreprocessResult = (lines: [Substring], version: ABCVersion?, diagnostics: [ABCParser.Diagnostic])

// MARK: Internal Functions

internal func joinContinuationLines(_ rawLines: [Substring]) -> [Substring] {
    var result: [Substring] = []
    var pending: String?

    for line in rawLines {
        let stripped = String(trimSuffix(uncomment(line)))

        let isFieldLine = (stripped.first?.isABCLetter == true || stripped.first == "+")
                          && stripped.dropFirst().first == ":"

        if isFieldLine {
            if let buf = pending {
                result.append(Substring(buf))
                pending = nil
            }

            let fieldText = stripped.hasSuffix("\\")
                            ? String(stripped.dropLast())
                            : String(stripped)

            result.append(Substring(fieldText))
        } else if stripped.hasSuffix("\\") {
            pending = (pending ?? "") + stripped.dropLast()
        } else if let buf = pending {
            result.append(Substring(buf + String(line)))
            pending = nil
        } else {
            result.append(line)
        }
    }

    if let buf = pending {
        result.append(Substring(buf))
    }

    return result
}

internal func preprocess(_ data: Data,
                         strictness: ABCParser.Strictness = .strict) throws -> PreprocessResult {
    let (strippedData, hadUTF8BOM, hadOtherBOM) = _stripBOM(data)

    var diagnostics: [ABCParser.Diagnostic] = []

    if hadOtherBOM {
        diagnostics.append(.ignoredByteOrderMark)
    }

    guard !strippedData.isEmpty
    else { return ([], nil, diagnostics) }

    let provisional = _provisionalDecode(strippedData)

    let rawLines = provisional.split(separator: /\n|(?:\r\n?)/,
                                     omittingEmptySubsequences: false)

    let prescan = _preScanLines(rawLines)
    let version = prescan.fileIDVersion ?? prescan.directiveVersion

    if let raw = prescan.fileIDRawVersionString {
        diagnostics.append(.malformedVersion(raw))
    } else if prescan.fileIDVersion == nil,
              let raw = prescan.directiveRawVersionString {
        diagnostics.append(.malformedVersion(raw))
    }

    if let version,
       !ABCVersion.supported.contains(version) {
        diagnostics.append(.unrecognizedVersion(version))
    }

    let encoding = _resolveCharset(hadUTF8BOM: hadUTF8BOM,
                                   charsetName: prescan.charsetName,
                                   duplicateCharsetNames: prescan.duplicateCharsetNames,
                                   version: version,
                                   diagnostics: &diagnostics)

    let finalString: String

    if encoding == .isoLatin1 {
        finalString = provisional
    } else if let decoded = String(data: strippedData, encoding: encoding) {
        finalString = decoded
    } else {
        guard strictness != .strict
        else { throw ABCParser.Error.dataConversionFailed }

        diagnostics.append(.invalidUTF8)
        finalString = provisional
    }

    var bodyLines = if finalString != provisional {
        finalString.split(separator: /\n|(?:\r\n?)/,
                          omittingEmptySubsequences: false)
    } else {
        rawLines
    }

    if bodyLines.first?.hasPrefix("%abc") == true {
        bodyLines = Array(bodyLines.dropFirst())
    }

    return (joinContinuationLines(bodyLines), version, diagnostics)
}

// MARK: Private Types

private struct _PreScanResult {
    init() {
        self.charsetName = nil
        self.directiveRawVersionString = nil
        self.directiveVersion = nil
        self.duplicateCharsetNames = []
        self.fileIDRawVersionString = nil
        self.fileIDVersion = nil
    }

    var charsetName: String?
    var directiveRawVersionString: String?
    var directiveVersion: ABCVersion?
    var duplicateCharsetNames: [String]
    var fileIDRawVersionString: String?
    var fileIDVersion: ABCVersion?
}

// MARK: Private Functions

private func _cfStringEncoding(_ rawValue: UInt32) -> String.Encoding {
    String.Encoding(rawValue: CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(rawValue)))
}

private func _handleDirectiveContent(_ line: Substring,
                                     _ result: inout _PreScanResult) {
    if line.hasPrefix("%%") {
        _parseDirectiveContent(line.dropFirst(2), &result)
    } else if line.first == "I", line.dropFirst().first == ":" {
        _parseDirectiveContent(line.dropFirst(2), &result)
    }
}

private func _isHeaderLine(_ line: Substring) -> Bool {
    if line.isEmpty || line.allSatisfy({ $0.isABCWhitespace }) {
        return true
    }

    if line.hasPrefix("%") {
        return true
    }

    if line.first?.isABCLetter == true || line.first == "+",
       line.dropFirst().first == ":" {
        return true
    }

    return false
}

private func _normalizeCharsetName(_ name: String) -> String {
    name.lowercased().filter { $0.isABCAlphanumeric }
}

private func _parseDirectiveContent(_ rest: Substring,
                                    _ result: inout _PreScanResult) {
    let trimmed = rest.drop { $0.isABCWhitespace }

    let nameSlice = trimmed.prefix { !$0.isABCWhitespace }
    let name = String(nameSlice)
    let afterName = trimmed.dropFirst(nameSlice.count).drop { $0.isABCWhitespace }
    let valueSlice = afterName.prefix { !$0.isABCWhitespace }
    let value = String(valueSlice)

    switch name {
    case "abc-version":
        if result.directiveVersion == nil {
            if let parsed = _parseVersionString(Substring(value)) {
                result.directiveVersion = parsed
            } else if !value.isEmpty,
                      result.directiveRawVersionString == nil {
                result.directiveRawVersionString = value
            }
        }

    case "abc-charset":
        if !value.isEmpty {
            if result.charsetName == nil {
                result.charsetName = value
            } else {
                result.duplicateCharsetNames.append(value)
            }
        }

    default:
        break
    }
}

private func _parseVersionString(_ str: Substring) -> ABCVersion? {
    let parts = str.split(separator: ".",
                          maxSplits: 1,
                          omittingEmptySubsequences: false)

    guard parts.count == 2,
          let major = UInt(parts[0]),
          let minor = UInt(parts[1])
    else { return nil }

    return ABCVersion(major: major, minor: minor)
}

private func _preScanLines(_ lines: [Substring]) -> _PreScanResult {
    var result = _PreScanResult()

    for (index, line) in lines.enumerated() {
        guard _isHeaderLine(line)
        else { break }

        if index == 0, line.hasPrefix("%abc-") {
            let versionStr = line.dropFirst(5).prefix { !$0.isABCWhitespace && $0 != "%" }

            if let parsed = _parseVersionString(versionStr) {
                result.fileIDVersion = parsed
            } else {
                result.fileIDRawVersionString = String(versionStr)
            }
        }

        _handleDirectiveContent(line, &result)
    }

    return result
}

private func _provisionalDecode(_ data: Data) -> String {
    String(data: data, encoding: .isoLatin1) ?? ""
}

private func _resolveCharset(hadUTF8BOM: Bool,
                             charsetName: String?,
                             duplicateCharsetNames: [String],
                             version: ABCVersion?,
                             diagnostics: inout [ABCParser.Diagnostic]) -> String.Encoding {
    if hadUTF8BOM {
        if let name = charsetName {
            diagnostics.append(.duplicateCharset(name))
        }

        for dupName in duplicateCharsetNames {
            diagnostics.append(.duplicateCharset(dupName))
        }

        return .utf8
    }

    if let name = charsetName {
        let normalized = _normalizeCharsetName(name)
        let encoding: String.Encoding

        if let found = _swiftEncoding(for: normalized) {
            encoding = found
        } else {
            diagnostics.append(.unrecognizedCharset(name))
            encoding = .isoLatin1
        }

        for dupName in duplicateCharsetNames {
            diagnostics.append(.duplicateCharset(dupName))
        }

        return encoding
    }

    if let version,
       version >= ABCVersion(major: 2,
                             minor: 1) {
        return .utf8
    }

    return .isoLatin1
}

private func _stripBOM(_ data: Data) -> (data: Data, hadUTF8BOM: Bool, hadOtherBOM: Bool) {
    let prefix = [UInt8](data.prefix(4))

    if prefix.count >= 4,
       prefix[0] == 0x00,
       prefix[1] == 0x00,
       prefix[2] == 0xfe,
       prefix[3] == 0xff {
        return (data.dropFirst(4), false, true)
    }

    if prefix.count >= 4,
       prefix[0] == 0xff,
       prefix[1] == 0xfe,
       prefix[2] == 0x00,
       prefix[3] == 0x00 {
        return (data.dropFirst(4), false, true)
    }

    if prefix.count >= 3,
       prefix[0] == 0xef,
       prefix[1] == 0xbb,
       prefix[2] == 0xbf {
        return (data.dropFirst(3), true, false)
    }

    if prefix.count >= 2,
       prefix[0] == 0xfe,
       prefix[1] == 0xff {
        return (data.dropFirst(2), false, true)
    }

    if prefix.count >= 2,
       prefix[0] == 0xff,
       prefix[1] == 0xfe {
        return (data.dropFirst(2), false, true)
    }

    return (data, false, false)
}

private func _swiftEncoding(for normalized: String) -> String.Encoding? {
    switch normalized {
    case "88591",
         "iso88591",
         "latin1":
        .isoLatin1

    case "88592",
         "iso88592",
         "latin2":
        .isoLatin2

    case "ascii",
         "usascii":
        .ascii

    case "iso885910",
         "latin6":
        _cfStringEncoding(0x020a)  // kCFStringEncodingISOLatin6

    case "iso88593":
        _cfStringEncoding(0x0203)  // kCFStringEncodingISOLatin3

    case "iso88594":
        _cfStringEncoding(0x0204)  // kCFStringEncodingISOLatin4

    case "iso88595":
        _cfStringEncoding(0x0205)  // kCFStringEncodingISOLatinCyrillic

    case "iso88596":
        _cfStringEncoding(0x0206)  // kCFStringEncodingISOLatinArabic

    case "iso88597":
        _cfStringEncoding(0x0207)  // kCFStringEncodingISOLatinGreek

    case "iso88598":
        _cfStringEncoding(0x0208)  // kCFStringEncodingISOLatinHebrew

    case "iso88599",
         "latin5":
        _cfStringEncoding(0x0209)  // kCFStringEncodingISOLatin5

    case "utf8":
        .utf8

    default:
        nil
    }
}
