// ViewModels/GolfGameViewModel+Aggregation.swift
// Deterministic per-hole storage → aggregates derived ONLY from arrays
// 10/7/25
// ViewModels/GolfGameViewModel+Aggregation.swift
// Single source of truth for per-hole capture & aggregate rebuild

import Foundation

extension GolfGameViewModel {

    /// Persist the stake that applied to the hole just scored.
    /// Assumes submitHoleScores called this BEFORE advancing currentHole.
    func captureStakeForJustScoredHole() {
        let idx = max(0, min(17, currentHole - 1))
        guard !games.isEmpty else { return }

        // Ensure outer shape
        if stakesPerHoleByGame.count != games.count {
            stakesPerHoleByGame = Array(repeating: Array(repeating: 0, count: 18), count: games.count)
        }
        // Ensure inner shape
        for gi in games.indices where stakesPerHoleByGame[gi].count != 18 {
            stakesPerHoleByGame[gi] = Array(repeating: 0, count: 18)
        }

        for gi in games.indices {
            stakesPerHoleByGame[gi][idx] = games[gi].currentPointValue
        }
    }

    /// Persist the per-hole contribution for the hole just scored.
    /// Pass the 1-based hole number from submitHoleScores.
    func writeContribForHole(_ holeNumber: Int) {
        let idx = max(0, min(17, holeNumber - 1))
        guard !games.isEmpty else { return }

        // Ensure outer shape
        if contribPerHoleAByGame.count != games.count {
            contribPerHoleAByGame = Array(repeating: Array(repeating: 0, count: 18), count: games.count)
        }
        if contribPerHoleBByGame.count != games.count {
            contribPerHoleBByGame = Array(repeating: Array(repeating: 0, count: 18), count: games.count)
        }
        // Ensure inner shape
        for gi in games.indices {
            if contribPerHoleAByGame[gi].count != 18 { contribPerHoleAByGame[gi] = Array(repeating: 0, count: 18) }
            if contribPerHoleBByGame[gi].count != 18 { contribPerHoleBByGame[gi] = Array(repeating: 0, count: 18) }
        }

        for gi in games.indices {
            contribPerHoleAByGame[gi][idx] = games[gi].currentHoleContributionForTeamA
            contribPerHoleBByGame[gi][idx] = games[gi].currentHoleContributionForTeamB
        }
    }

    /// Rebuild aggregates strictly from per-hole arrays.
    /// Prevents “vanishing points” after hole 1 and keeps edits idempotent.
    func recomputeAggregatesFromPerHole() {
        guard !games.isEmpty else { return }

        for gi in games.indices {
            var totalA = 0
            var totalB = 0

            if contribPerHoleAByGame.indices.contains(gi) {
                for v in contribPerHoleAByGame[gi] { totalA += v }
            }
            if contribPerHoleBByGame.indices.contains(gi) {
                for v in contribPerHoleBByGame[gi] { totalB += v }
            }

            games[gi].teamA.aggregatePoints = totalA
            games[gi].teamB.aggregatePoints = totalB
        }
    }
}
