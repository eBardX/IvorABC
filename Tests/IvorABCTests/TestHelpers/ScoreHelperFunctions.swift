// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorABC
import XestiTools

// MARK: - Factory Functions

func makeScoreAttachments(_ decorations: [ABCDecoration] = [],
                          _ annotations: [ABCAnnotation] = [],
                          _ graceNotes: ABCScoreGraceNotes? = nil,
                          _ chordSymbol: ABCChordSymbol? = nil) -> ABCScoreAttachments {
    ABCScoreAttachments(decorations: decorations,
                        annotations: annotations,
                        graceNotes: graceNotes,
                        chordSymbol: chordSymbol)
}

func makeScoreChord(_ notes: [ABCScoreNote],
                    _ duration: ABCScoreDuration,
                    _ tie: ABCTie? = nil) -> ABCScoreChord {
    ABCScoreChord(notes: notes,
                  duration: duration,
                  tie: tie).require()
}

func makeScoreDuration(_ numerator: UInt,
                       _ denominator: UInt = 1) -> ABCScoreDuration {
    ABCScoreDuration(numerator: numerator,
                     denominator: denominator).require()
}

func makeScoreGraceNotes(_ notes: [ABCScoreNote],
                         _ isSlashed: Bool) -> ABCScoreGraceNotes {
    ABCScoreGraceNotes(notes: notes,
                       isSlashed: isSlashed).require()
}

func makeScoreNote(_ pitch: ABCPitch,
                   _ duration: ABCScoreDuration,
                   _ tie: ABCTie? = nil,
                   slurStart: Bool = false,
                   slurEnd: Bool = false) -> ABCScoreNote {
    ABCScoreNote(pitch: pitch,
                 duration: duration,
                 tie: tie,
                 slurStart: slurStart,
                 slurEnd: slurEnd).require()
}

func makeScoreRest(_ duration: ABCScoreDuration,
                   _ isInvisible: Bool = false) -> ABCScoreRest {
    ABCScoreRest(duration: duration,
                 isInvisible: isInvisible)
}
