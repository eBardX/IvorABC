// swift-tools-version: 6.3

// © 2025–2026 John Gary Pusey (see LICENSE.md)

import PackageDescription

let swiftSettings: [SwiftSetting] = [.defaultIsolation(nil),
                                     .enableUpcomingFeature("ExistentialAny"),
                                     .enableUpcomingFeature("ImmutableWeakCaptures"),
                                     .enableUpcomingFeature("InferIsolatedConformances"),
                                     .enableUpcomingFeature("InternalImportsByDefault"),
                                     .enableUpcomingFeature("MemberImportVisibility"),
                                     .enableUpcomingFeature("NonisolatedNonsendingByDefault")]

let package = Package(name: "IvorABC",
                      platforms: [.iOS(.v18),
                                  .macOS(.v15)],
                      products: [.library(name: "IvorABC",
                                          targets: ["IvorABC"])],
                      dependencies: [.package(url: "https://github.com/eBardX/XestiTokens.git",
                                              .upToNextMajor(from: "1.1.0")),
                                     .package(url: "https://github.com/eBardX/XestiTools.git",
                                              .upToNextMajor(from: "9.0.0"))],
                      targets: [.target(name: "IvorABC",
                                        dependencies: [.product(name: "XestiTokens",
                                                                package: "XestiTokens"),
                                                       .product(name: "XestiTools",
                                                                package: "XestiTools")],
                                        swiftSettings: swiftSettings),
                                .testTarget(name: "IvorABCTests",
                                            dependencies: [.target(name: "IvorABC"),
                                                           .product(name: "XestiTokens",
                                                                    package: "XestiTokens"),
                                                           .product(name: "XestiTools",
                                                                    package: "XestiTools")],
                                            swiftSettings: swiftSettings)],
                      swiftLanguageModes: [.v6])
