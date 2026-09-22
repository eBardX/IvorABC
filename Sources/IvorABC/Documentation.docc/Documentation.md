# ``IvorABC``

@Metadata {
    @PageColor(blue)
}

An ABC Notation parser, normalizer, validator, and formatter.

## Overview

The IvorABC framework provides an [ABC Notation](https://abcnotation.com)
parser, normalizer, validator, and formatter written in Swift. It targets [ABC standard
v2.1](https://abcnotation.com/wiki/abc:standard:v2.1) with a
strict-concurrency-ready, value-type API.

IvorABC turns ABC text into a typed, round-trippable abstract syntax tree
(``ABCTunebook`` → ``ABCTune`` → ``ABCHeaderEntry`` / ``ABCBodyEntry`` →
``ABCField`` / ``ABCSymbol``) and back to text.

### The pipeline

Everything flows through a small, explicit pipeline of four value types, each a
`Sendable` value type with a no-argument initializer:

 Stage     | Type              | Input → Output
:-----     |:----              |:--------------
 Parse     | ``ABCParser``     | `Data` → ``ABCTunebook``
 Normalize | ``ABCNormalizer`` | ``ABCTunebook`` → ``ABCTunebook`` (ABC 2.1)
 Validate  | ``ABCValidator``  | ``ABCTunebook`` → validated ``ABCTunebook``
 Format    | ``ABCFormatter``  | ``ABCTunebook`` → `Data`

An ``ABCTunebook`` carries two Boolean state flags that enforce the order of the
pipeline: a tunebook must be normalized before it can be validated, and
validated before it can be formatted. Both normalization and
validation are idempotent, so it is always safe to run the full pipeline:

```swift
import Foundation
import IvorABC

let data = try Data(contentsOf: url)

let (parsed, diagnostics) = try ABCParser().parse(data)
let (normalized, changes) = ABCNormalizer().normalize(parsed)
let (validated, issues)   = try ABCValidator().validate(normalized)

guard issues.isEmpty
else { issues.forEach { print($0.message) }; return }

let output       = try ABCFormatter().format(validated)     // back to ABC
```

See <doc:UsingIvorABC> for a full guide to each stage, the models, and error
handling.

## Topics

### Guides

- <doc:UsingIvorABC>

### Processing

- ``ABCParser``
- ``ABCNormalizer``
- ``ABCValidator``
- ``ABCFormatter``

### Tunebooks

- ``ABCTunebook``
- ``ABCTune``
- ``ABCHeaderEntry``
- ``ABCBodyEntry``
- ``ABCVersion``
- ``ABCReferenceNumber``

### Fields

- ``ABCField``
- ``ABCText``
- ``ABCKeySignature``
- ``ABCTimeSignature``
- ``ABCTempo``
- ``ABCLength``
- ``ABCVoice``
- ``ABCClef``
- ``ABCPart``
- ``ABCPartSequence``
- ``ABCDirective``
- ``ABCMacro``
- ``ABCUserSymbol``
- ``ABCShorthand``
- ``ABCSymbolLine``
- ``ABCAlignedWords``
- ``ABCElemskip``

### Music symbols

- ``ABCSymbol``
- ``ABCNote``
- ``ABCChord``
- ``ABCRest``
- ``ABCPitch``
- ``ABCPitchName``
- ``ABCBarLine``
- ``ABCBrokenRhythm``
- ``ABCTie``
- ``ABCSlur``
- ``ABCTuplet``
- ``ABCGraceNotes``
- ``ABCDecoration``
- ``ABCAnnotation``
- ``ABCChordSymbol``
- ``ABCVariantEnding``
