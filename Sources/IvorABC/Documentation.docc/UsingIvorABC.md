# Using IvorABC

Take ABC notation from text to a validated syntax tree, and back to text.

## Overview

IvorABC exposes four processing types. Each is a `Sendable` value type with a
no-argument initializer and a single primary method:

 Type              | Method                | Result
:----              |:------                |:------
 ``ABCParser``     | `parse(_:)`           | `(ABCTunebook, [ABCParser.Diagnostic])`
 ``ABCNormalizer`` | `normalize(_:)`       | `(ABCTunebook, [ABCNormalizer.Change])`
 ``ABCValidator``  | `validate(_:)`        | `(ABCTunebook, [ABCValidator.Issue])`
 ``ABCFormatter``  | `format(_:)`          | `Data`

An ``ABCTunebook`` carries two Boolean state flags that enforce the order of the
pipeline:

- **`isNormalized`** — `validate(_:)` throws unless this is `true`.
- **`isValidated`** — `format(_:)` throws unless this is `true`.

So the canonical order is **parse → normalize → validate → format**:

```swift
let (parsed, diagnostics) = try ABCParser().parse(data)
let (normalized, changes) = ABCNormalizer().normalize(parsed)
let (validated, issues)   = try ABCValidator().validate(normalized)

guard issues.isEmpty
else { /* handle issues */ return }

let text = try ABCFormatter().format(validated)
```

Both `normalize(_:)` and `validate(_:)` are idempotent — calling them on a
tunebook that is already normalized or validated returns it unchanged — so it is
always safe to run the full pipeline.

## Parsing

``ABCParser`` decodes UTF-8 `Data` into an ``ABCTunebook``:

```swift
let (tunebook, diagnostics) = try ABCParser().parse(data)
```

The parser chooses its own parse policy from the version declared in the input:
**strict** for files that declare ABC 2.1 or later, and **loose** for everything
else (including unversioned files). In loose mode it recovers from common
deviations rather than failing, and reports each recovery — along with any
deprecated forms accepted in either mode — as an ``ABCParser/Diagnostic``.
Diagnostics are always returned, never thrown; each has a human-readable
`message`:

```swift
for diagnostic in diagnostics {
    print(diagnostic.message)
}
```

Diagnostics cover recoverable situations such as a deprecated tempo form
(`Q:120`), a duplicate `%%abc-charset`, an unrecognized character set, a
malformed version string, or a skipped unrecognizable line.

Unrecoverable problems are thrown as an ``ABCParser/Error``, for example
`.invalidField(_:_:)`, `.invalidKeySignature(_:)`, `.orphanedContinuation`,
`.unmatchedBeginDirective(_:)`, or `.missingTunes`. Like all IvorABC errors it
conforms to `EnhancedError` and provides a `message`:

```swift
do {
    let (tunebook, _) = try ABCParser().parse(data)
} catch let error as ABCParser.Error {
    print(error.message)
}
```

## Normalizing

``ABCNormalizer`` upgrades legacy and deprecated constructs to their ABC 2.1
equivalents, returning a new tunebook whose `isNormalized` flag is `true` and
whose `version` is `ABCVersion.current`, together with a list of the changes it
applied:

```swift
let (normalized, changes) = ABCNormalizer().normalize(tunebook)

for change in changes {
    print(change.message)          // what was changed
    print(change.tuneIndex ?? -1)  // which tune, or nil for the file header
}
```

Normalization performs conversions such as:

- `E:` (elemskip) and legacy `I:` (information) fields → `r:` (remark).
- Deprecated C-form tempos (`Q:C=rate`) resolved against the active `L:`/`M:`.
- `+name+` decorations → the standard `!name!` form.
- Dropping stale directives (`%%abc-charset`, `%%abc-version`, `%%decoration
  +`).

Each ``ABCNormalizer/Change`` case (`clearedBeatMultiplier`,
`convertedDecoration`, `removedDirective`, `replacedField`) carries the affected
value, so you can present a precise change log rather than just a count.

## Validating

``ABCValidator`` checks a **normalized** tunebook against the ABC 2.1
specification:

```swift
let (validated, issues) = try ABCValidator().validate(normalized)

if issues.isEmpty {
    // `validated.isValidated` is now true.
} else {
    issues.forEach { print($0.message) }
}
```

- If the tunebook has not been normalized, `validate(_:)` throws
  `ABCValidator.Error.notNormalized`.
- If any issues are found, the returned tunebook is the **input unchanged** (its
  `isValidated` flag stays `false`). Fix the issues and validate again.
- Only when the issues array is empty does the returned tunebook have
  `isValidated == true` — the prerequisite for formatting and resolving.

Each ``ABCValidator/Issue`` describes a specific conformance problem — a missing
or misplaced `X:` / `T:` / `K:` field, an inline field used where it is not
allowed, more than one chord symbol or grace-note group on a single note, or a
shorthand decoration with no defining `U:` field — and exposes both a `message`
and a `tuneIndex`.

## Formatting

``ABCFormatter`` serializes a **validated** tunebook back to ABC 2.1-compliant
UTF-8 `Data`:

```swift
let data = try ABCFormatter().format(validated)
```

If the tunebook has not been validated, `format(_:)` throws
`ABCFormatter.Error.notValidated`. Because the model is validated first,
formatting itself does not fail on content — round-tripping `parse → normalize →
validate → format` reproduces a specification-compliant document.

## The AST model

The syntactic model is a tree of value types:

```
ABCTunebook
├─ version:    ABCVersion?
├─ fileHeader: [ABCHeaderEntry]
└─ tunes:      [ABCTune]
   ├─ header: [ABCHeaderEntry]   // .directive | .field
   └─ body:   [ABCBodyEntry]     // .directive | .field | .symbols([ABCSymbol])
```

- ``ABCField`` is an enum with one case per ABC information/tune field
  (`.tuneTitle`, `.key`, `.meter`, `.tempo`, `.voice`, …). Each case’s payload
  is a dedicated, fully-typed value (e.g. `.key(ABCKeySignature)`).
- ``ABCSymbol`` is an enum covering everything that can appear in a line of
  music: `.note`, `.chord`, `.rest`, `.barLine`, `.decoration`, `.tuplet`,
  `.slur`, `.chordSymbol`, `.inlineField`, and so on.

Leaf values are wrapped in small validating types — for instance ``ABCText``,
``ABCReferenceNumber``, ``ABCVoice/ID``, and ``ABCClef/Name`` — each of which
exposes an `isValid(_:)` check and a failable initializer that returns `nil`
for out-of-range input. Others, like ``ABCLength``, validate internally in a
failable initializer without a public `isValid(_:)` check. All AST types are
`Equatable` and `Sendable`.

``ABCTunebook`` equality compares `version`, `fileHeader`, and `tunes` only;
the `isNormalized` and `isValidated` flags are metadata and are excluded.

## Building a tunebook programmatically

You can construct the AST directly rather than parsing text. Leaf initializers
are failable, returning `nil` when their validity constraints are not met:

```swift
let refNumber = ABCReferenceNumber(uintValue: 1)!
let title     = ABCText(stringValue: "Cooley's")!
let key       = ABCKeySignature.standard(.init(tonic: .e,
                                               mode: .dorian)!)

let header: [ABCHeaderEntry] = [
    .field(.referenceNumber(refNumber)),  // X:1
    .field(.tuneTitle(title)),            // T:Cooley's
    .field(.key(key)),                    // K:Edor
]

let tune     = ABCTune(header: header,
                       body: [])!
let tunebook = ABCTunebook(fileHeader: [],
                           tunes: [tune])!
```

A directly-constructed tunebook has `isNormalized == false` and `isValidated ==
false`, so you must run it through the normalizer and validator before
formatting or resolving.

## Error handling

Thrown errors conform to `EnhancedError` (from
[XestiTools](https://github.com/eBardX/XestiTools)): each has a `category` of
`"IvorABC"` and a human-readable `message`.

 Type                   | Thrown by
:----                   |:---------
 ``ABCParser/Error``    | `ABCParser.parse(_:)`
 ``ABCValidator/Error`` | `ABCValidator.validate(_:)`
 ``ABCFormatter/Error`` | `ABCFormatter.format(_:)`

Non-fatal results are returned rather than thrown, and each also provides a
`message`:

 Type                     | Returned by     | Also
:----                     |:-----------     |:-----
 ``ABCParser/Diagnostic`` | `parse(_:)`     | recovery/deprecation notices
 ``ABCNormalizer/Change`` | `normalize(_:)` | `tuneIndex`
 ``ABCValidator/Issue``   | `validate(_:)`  | `tuneIndex`

## Concurrency

IvorABC is built for Swift 6 strict concurrency. Every public type — the four
processing types and the entire AST — is a `Sendable` value type, so instances
can be freely shared across tasks and actor boundaries. The processing types
hold no mutable state, so a single ``ABCParser``, ``ABCNormalizer``,
``ABCValidator``, or ``ABCFormatter`` instance can be reused for any number of
concurrent operations.
