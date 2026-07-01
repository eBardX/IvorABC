# IvorABC

A pure syntactic ABC Notation parser and formatter.

## <a name="overview">Overview</a>

The IvorABC framework provides an [ABC Notation](https://abcnotation.com)
parser and formatter written in Swift. It targets [ABC standard
v2.1](https://abcnotation.com/wiki/abc:standard:v2.1).

IvorABC is a **syntactic** library. It turns ABC text into a typed AST
(`ABCTunebook` → `ABCTune` → `ABCEntry` → `ABCSymbol` / `ABCField`) and back,
with full round-trip fidelity. It does **not** interpret the music: pitch
spelling, accidental propagation, tuplet timing, playback, and rendering are
left to the consumer. Where the standard defines useful but interpretation-
dependent helpers, IvorABC exposes them as opt-in utilities
(`ABCAccidentalContext`, `ABCTuplet.resolve(meter:)`,
`ABCSymbol.resolveBrokenRhythm(left:right:)`) rather than applying them
automatically.

### Parsing

`ABCParser` decodes UTF-8 text into an `ABCTunebook`. By default it enforces
strict conformance to ABC 2.1 and throws `ABCParseError` on any deviation. For
real-world files that bend the spec, pass `.lenient` to recover silently and
collect `ABCDiagnostic` values describing each repair:

```swift
// Strict (default)
let tunebook = try ABCParser().parse(data)

// Lenient — recovers from common deviations and reports what was repaired
let (tunebook, diagnostics) = try ABCParser(strictness: .lenient)
                                            .parseWithDiagnostics(data)
```

### Formatting

`ABCFormatter` encodes an `ABCTunebook` back to UTF-8 data. It validates the
model at format time and throws `ABCFormatError` if it detects a structurally
incorrect in-memory model (e.g. a chord with no notes, a zero-numerator
note length, or a non-power-of-two unit note length denominator). Tunes that lack
an `X:` reference number are assigned one automatically — the lowest unused
positive integer, skipping any numbers already present elsewhere in the
tunebook:

```swift
let data = try ABCFormatter().format(tunebook)
```

## <a name="reference_documentation">Reference Documentation</a>

Full [reference documentation][refdoc] is available courtesy of [DocC][docc].

## <a name="credits">Credits</a>

John Gary Pusey (ebardx@gmail.com)

## <a name="license">License</a>

IvorABC is available under [the MIT license][license].

[docc]:     https://www.swift.org/documentation/docc/
[license]:  https://github.com/eBardX/IvorABC/blob/main/LICENSE.md
[refdoc]:   https://eBardX.github.io/ivor-packages-docs/documentation/ivorabc
