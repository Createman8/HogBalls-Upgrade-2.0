// 10/07/25

/// ViewModels/GolfGameViewModel+Reset.swift
// Restart round while preserving players, handicaps, course, and starting stake.

import Foundation

extension GolfGameViewModel {

    /// Clears the current round (scores, aggregates, presses, per-hole arrays),
    /// but keeps players, handicaps, course, and starting stake.
    func restartRoundPreservingPlayers() {
        // Reset per-player scores
        for i in players.indices {
            players[i].grossScores = Array(repeating: -1, count: 18)
            players[i].netScores   = Array(repeating:  0, count: 18)
        }

        // Reset game state (points, stake, press flags, per-hole contributions)
        for gi in games.indices {
            games[gi].teamA.aggregatePoints = 0
            games[gi].teamB.aggregatePoints = 0
            games[gi].currentPointValue = startingPointValue

            games[gi].frontPressUsedTeamA = false
            games[gi].frontPressUsedTeamB = false
            games[gi].backPressUsedTeamA  = false
            games[gi].backPressUsedTeamB  = false

            games[gi].currentHoleContributionForTeamA = 0
            games[gi].currentHoleContributionForTeamB = 0
        }

        // Ensure and clear the per-hole storage arrays
        ensurePerHoleStorage()
        for gi in games.indices {
            for h in 0..<18 {
                stakesPerHoleByGame[gi][h]       = 0
                contribPerHoleAByGame[gi][h]     = 0
                contribPerHoleBByGame[gi][h]     = 0
            }
        }

        // Round flags
        currentHole = 1
        isRoundComplete = false

        // Reset Hog Balls overlay counters
        hogBallsCount = 0
        hogBallsEventID = 0
    }

    // MARK: - Helper (internal so other extensions may call it)
    func ensurePerHoleStorage() {
        if stakesPerHoleByGame.count != games.count {
            stakesPerHoleByGame = Array(repeating: Array(repeating: 0, count: 18), count: games.count)
        }
        if contribPerHoleAByGame.count != games.count {
            contribPerHoleAByGame = Array(repeating: Array(repeating: 0, count: 18), count: games.count)
        }
        if contribPerHoleBByGame.count != games.count {
            contribPerHoleBByGame = Array(repeating: Array(repeating: 0, count: 18), count: games.count)
        }
        for gi in games.indices {
            if stakesPerHoleByGame[gi].count != 18 {
                stakesPerHoleByGame[gi] = Array(repeating: 0, count: 18)
            }
            if contribPerHoleAByGame[gi].count != 18 {
                contribPerHoleAByGame[gi] = Array(repeating: 0, count: 18)
            }
            if contribPerHoleBByGame[gi].count != 18 {
                contribPerHoleBByGame[gi] = Array(repeating: 0, count: 18)
            }
        }
    }
}
