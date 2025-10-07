//Updated 9/2/25
//  ScoreCalculator.swift
//
//  ScoreCalculator.swift
//

import Foundation

/// Course-aware calculator.
/// Positive handicap: receives strokes on hardest holes first.
/// Plus handicap (negative): gives strokes back on easiest holes first.
struct ScoreCalculator {
    let course: Course

    /// `currentHole` is 1-based (1...18)
    func calculateNetScore(for player: Player, gross: Int, currentHole: Int) -> Int {
        let ranks = course.holeHandicaps         // [1...18], 1 = hardest, 18 = easiest
        let rank = ranks[currentHole - 1]
        let h = player.handicap.value

        // Base allocation: +N pops (subtract N), -N givebacks (add |N|)
        let pops = popsForHole(handicap: h, holeRank: rank)
        let net = gross - pops
        return net
    }

    /// +N -> subtract N from gross (player receives N pops on this hole)
    /// -N -> add |N| to gross (plus player gives back |N| strokes on this hole)
    private func popsForHole(handicap: Int, holeRank: Int) -> Int {
        if handicap == 0 { return 0 }

        let absH = abs(handicap)
        let cycles = absH / 18     // strokes applied to all holes
        let remainder = absH % 18  // extra strokes to a subset

        if handicap > 0 {
            // Positive: hardest first -> remainder goes to ranks 1...remainder
            let getsRemainder = holeRank <= remainder
            return cycles + (getsRemainder ? 1 : 0)
        } else {
            // Plus (negative): EASIEST first -> ranks 18,17,... down to (19 - remainder)
            let getsRemainder = remainder > 0 && holeRank >= (19 - remainder)
            return -(cycles + (getsRemainder ? 1 : 0))
        }
    }
}
