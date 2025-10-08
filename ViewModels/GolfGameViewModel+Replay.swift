// Trying to get hole edit cleaner
//  GolfGameViewModel+Replay.swift
//  GolfScoreApp
//
//  Created by joe stewart on 10/7/25.
// ViewModels/GolfGameViewModel+Replay.swift
// Also forces first-hole stake to startingPointValue during replay, just like live play.
// ViewModels/GolfGameViewModel+Replay.swift
// During replay, also lock Hole 1 stake to startingPointValue before scoring.

import Foundation

extension GolfGameViewModel {

    /// Back-compat for older callers (used by Edit Past Hole, etc.)
    func applyEditedHoleRecalcForward() {
        replayEntireRound()
    }

    /// Deterministic rebuild: recompute nets for entered holes,
    /// sync teams, score per hole, persist stake/contrib, rebuild aggregates.
    func replayEntireRound() {
        guard !games.isEmpty else { return }

        // Ensure arrays exist & zero live aggregates (helpers live in +Aggregation / +PressSchedule)
        // localEnsurePerHoleStorage + localClearPerHoleArraysAndAggregates were inlined previously;
        // if you still have them in a separate file, call them here instead.
        // For safety, just zero the live contributions:
        for gi in games.indices {
            games[gi].teamA.aggregatePoints = 0
            games[gi].teamB.aggregatePoints = 0
            games[gi].currentHoleContributionForTeamA = 0
            games[gi].currentHoleContributionForTeamB = 0
        }

        // Replay each hole that has at least one gross score
        for holeIdx in 0..<18 {
            var anyGross = false
            for i in 0..<numPlayers where players.indices.contains(i) {
                if players[i].grossScores.indices.contains(holeIdx),
                   players[i].grossScores[holeIdx] >= 0 {
                    anyGross = true; break
                }
            }
            if !anyGross { continue }

            currentHole = holeIdx + 1

            // Recompute nets for this hole
            for i in 0..<numPlayers where players.indices.contains(i) {
                let g = players[i].grossScores[holeIdx]
                players[i].netScores[holeIdx] = (g >= 0) ? calculateNetScore(for: players[i], gross: g, at: currentHole) : 0
            }

            // Sync teams so games see fresh values
            syncTeamsForCurrentPlayers()

            // 🔒 Enforce stake = startingPointValue on HOLE 1 in replay too
            if holeIdx == 0 {
                for gi in games.indices {
                    games[gi].currentPointValue = startingPointValue
                    if stakesPerHoleByGame.indices.contains(gi) && stakesPerHoleByGame[gi].indices.contains(0) {
                        stakesPerHoleByGame[gi][0] = startingPointValue
                    }
                    games[gi].frontPressUsedTeamA = false
                    games[gi].frontPressUsedTeamB = false
                    games[gi].backPressUsedTeamA  = false
                    games[gi].backPressUsedTeamB  = false
                }
            }

            // Score this hole for each game
            for gi in games.indices { scoreHole(for: &games[gi], at: holeIdx) }

            // Persist stake & contributions
            captureStakeForJustScoredHole()
            writeContribForHole(currentHole)
        }

        // Rebuild aggregates from per-hole arrays
        recomputeAggregatesFromPerHole()

        // Advance currentHole to first unentered
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
}
