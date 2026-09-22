# IvorABC

An ABC Notation parser, normalizer, validator, and formatter.

[![Swift 6.3](https://img.shields.io/badge/Swift-6.3-orange.svg)](https://swift.org)
[![Platforms](https://img.shields.io/badge/platforms-iOS%20%7C%20macOS-lightgrey.svg)](https://developer.apple.com)
[![SwiftPM](https://img.shields.io/badge/SwiftPM-compatible-brightgreen.svg)](https://swift.org/package-manager/)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/eBardX/IvorABC/blob/main/LICENSE.md)

* [Overview](#overview)
* [Requirements](#requirements)
* [Installation](#installation)
    * [Swift Package Manager](#spm_installation)
* [Quick Start](#quick_start)
* [Documentation](#documentation)
* [Reference Documentation](#reference_documentation)
* [Credits](#credits)
* [License](#license)

## <a name="overview">Overview</a>

The IvorABC framework provides an [ABC Notation][abc] parser, normalizer,
validator, and formatter written in Swift. It targets [ABC standard v2.1][abcspec] with a
strict-concurrency-ready, value-type API.

IvorABC turns ABC text into a typed, round-trippable abstract syntax tree
(`ABCTunebook` → `ABCTune` → `ABCHeaderEntry` / `ABCBodyEntry` → `ABCField` /
`ABCSymbol`) and back to text.

Everything flows through a small, explicit pipeline of four value types, each
with a no-argument initializer:

 Stage     | Type            | Input → Output
:-----     |:----            |:--------------
 Parse     | `ABCParser`     | `Data` → `ABCTunebook`
 Normalize | `ABCNormalizer` | `ABCTunebook` → `ABCTunebook` (ABC 2.1)
 Validate  | `ABCValidator`  | `ABCTunebook` → validated `ABCTunebook`
 Format    | `ABCFormatter`  | `ABCTunebook` → `Data`

The pipeline is gated by two flags on `ABCTunebook`: a tunebook must be
normalized before it can be validated, and validated before it can be formatted.
See the [usage guide][guide] for a full walkthrough of the API.

## <a name="requirements">Requirements</a>

* iOS 18.0+ / macOS 15.0+
* Swift 6.3 toolchain
* Swift 6 language mode

## <a name="installation">Installation</a>

### <a name="spm_installation">Swift Package Manager</a>

IvorABC is distributed exclusively through the [Swift Package Manager][spm].

To add IvorABC to a Swift package, add it to the `dependencies` in your
`Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/eBardX/IvorABC.git",
             .upToNextMajor(from: "2.0.0"))
]
```

Then add `IvorABC` to the dependencies of any target that uses it:

```swift
.target(name: "MyTarget",
        dependencies: [.product(name: "IvorABC",
                                package: "IvorABC")])
```

To add IvorABC to an Xcode project, choose **File ▸ Add Package Dependencies…**
and enter the repository URL:

```
https://github.com/eBardX/IvorABC.git
```

IvorABC depends on [XestiTokens][xestitokens] and [XestiTools][xestitools]; the
Swift Package Manager resolves both automatically.

## <a name="quick_start">Quick Start</a>

Take ABC text from `Data` all the way to a playback-ready realization:

```swift
import Foundation
import IvorABC

let data = try Data(contentsOf: url)

// 1. Parse ABC text into a typed AST.
let (parsed, diagnostics) = try ABCParser().parse(data)

// 2. Normalize legacy / deprecated constructs to ABC 2.1.
let (normalized, changes) = ABCNormalizer().normalize(parsed)

// 3. Validate against the ABC 2.1 specification.
let (validated, issues) = try ABCValidator().validate(normalized)

guard issues.isEmpty
else { issues.forEach { print($0.message) }; return }

// 4. Format back to ABC 2.1-compliant text…
let output = try ABCFormatter().format(validated)
```

Each stage is independent, so you can stop at the AST, round-trip through the
formatter, or continue on to a resolved realization. For the complete story — the AST
and realization models, resolver options, and error handling — see the
[usage guide][guide].

## <a name="documentation">Documentation</a>

* [Using IvorABC][guide] — a guide to using the public API, published as part of
  the DocC documentation.
* Every public declaration carries a DocC comment, with references to the
  relevant sections of the [ABC 2.1 standard][abcspec].

## <a name="reference_documentation">Reference Documentation</a>

Full [reference documentation][refdoc] is available courtesy of [DocC][docc].

## <a name="credits">Credits</a>

John Gary Pusey (ebardx@gmail.com)

## <a name="license">License</a>

IvorABC is available under [the MIT license][license].

[abc]:          https://abcnotation.com
[abcspec]:      https://abcnotation.com/wiki/abc:standard:v2.1
[docc]:         https://www.swift.org/documentation/docc/
[guide]:        https://eBardX.github.io/ivor-packages-docs/documentation/ivorabc/usingivorabc
[license]:      https://github.com/eBardX/IvorABC/blob/main/LICENSE.md
[refdoc]:       https://eBardX.github.io/ivor-packages-docs/documentation/ivorabc
[spm]:          https://swift.org/package-manager/
[xestitokens]:  https://github.com/eBardX/XestiTokens
[xestitools]:   https://github.com/eBardX/XestiTools
