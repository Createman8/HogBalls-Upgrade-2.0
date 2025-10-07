// Trying to get hole edit cleaner
//  GolfGameViewModel+Replay.swift
//  GolfScoreApp
//
//  Created by joe stewart on 10/7/25.
// ViewModels/GolfGameViewModel+Replay.swift
// Also forces first-hole stake to startingPointValue during replay, just like live play.

import Foundation

extension GolfGameViewModel {

    /// Back-compat for older callers
    func applyEditedHoleRecalcForward() {
        replayEntireRound()
    }

    /// Deterministic round rebuild from gross scores.
    func replayEntireRound() {
        guard !games.isEmpty else { return }

        localEnsurePerHoleStorage()
        localClearPerHoleArraysAndAggregates()

        for holeIdx in 0..<18 {
            // Skip unentered holes
            var anyGross = false
            for i in 0..<numPlayers where players.indices.contains(i) {
                if players[i].grossScores.indices.contains(holeIdx),
                   players[i].grossScores[holeIdx] >= 0 {
                    anyGross = true; break
                }
            }
            if !anyGross { continue }

            currentHole = holeIdx + 1

            // Recompute nets for players with gross on this hole
            for i in 0..<numPlayers where players.indices.contains(i) {
                let g = players[i].grossScores[holeIdx]
                players[i].netScores[holeIdx] = (g >= 0) ? calculateNetScore(for: players[i], gross: g, at: currentHole) : 0
            }

            // 🔑 Sync teams for fresh values
            syncTeamsForCurrentPlayers()

            // 🔒 Stake sanity on FIRST hole of replay as well
            if holeIdx == 0 {
                for gi in games.indices { games[gi].currentPointValue = startingPointValue }
            }

            // Score each game for this hole
            for gi in games.indices { scoreHole(for: &games[gi], at: holeIdx) }

            // Persist stake & contributions for this hole
            captureStakeForJustScoredHole()
            writeContribForHole(currentHole)
        }

        // Rebuild aggregates strictly from arrays
        recomputeAggregatesFromPerHole()

        // Set currentHole to first unscored (or 18)
        var firstUnscored: Int? = nil
        outer: for h in 0..<18 {
            for i in 0..<numPlayers where players.indices.contains(i) {
                if players[i].grossScores[h] < 0 { firstUnscored = h; break outer }
            }
        }
        if let idx = firstUnscored {
            currentHole = idx + 1
            isRoundComplete = false
        } else {
            currentHole = 18
            isRoundComplete = true
        }
    }

    // MARK: - Local helpers

    private func localEnsurePerHoleStorage() {
        if stakesPerHoleByGame.count != games.count {
            stakesPerHoleByGame = Array(repeating: Array(repeating: 0, count: 18), count: games.count)
        }
        for gi in games.indices where stakesPerHoleByGame[gi].count != 18 {
            stakesPerHoleByGame[gi] = Array(repeating: 0, count: 18)
        }
        if contribPerHoleAByGame.count != games.count {
            contribPerHoleAByGame = Array(repeating: Array(repeating: 0, count: 18), count: games.count)
        }
        if contribPerHoleBByGame.count != games.count {
            contribPerHoleBByGame = Array(repeating: Array(repeating: 0, count: 18), count: games.count)
        }
        for gi in games.indices {
            if contribPerHoleAByGame[gi].count != 18 { contribPerHoleAByGame[gi] = Array(repeating: 0, count: 18) }
            if contribPerHoleBByGame[gi].count != 18 { contribPerHoleBByGame[gi] = Array(repeating: 0, count: 18) }
        }
    }

    private func localClearPerHoleArraysAndAggregates() {
        for gi in games.indices {
            for h in 0..<18 {
                stakesPerHoleByGame[gi][h] = 0
                contribPerHoleAByGame[gi][h] = 0
                contribPerHoleBByGame[gi][h] = 0
            }
            games[gi].teamA.aggregatePoints = 0
            games[gi].teamB.aggregatePoints = 0
            games[gi].currentHoleContributionForTeamA = 0
            games[gi].currentHoleContributionForTeamB = 0
        }
    }
}
