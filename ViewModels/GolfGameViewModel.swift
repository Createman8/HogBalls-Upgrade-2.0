// Revised 10/7/25 – fix: let VM handle capture/write/recompute; no extra zeroing
// ViewModels/GolfGameViewModel.swift
// SwiftUI MVVM – fixed first-hole scoring, per-hole capture, and correct 5-player match mapping (12 vs 34, 12 vs 35, 12 vs 45)

// ViewModels/GolfGameViewModel.swift
// Ensures first-hole stake = startingPointValue (no accidental 2x on Hole 1)
// Keeps: team sync, per-hole capture, array-based recompute
// ViewModels/GolfGameViewModel.swift
// Locks Hole 1 stake to startingPointValue, blocks presses on Hole 1,
// keeps team sync + 5-player mapping: 12 vs 34, 12 vs 35, 12 vs 45.

import Foundation
import SwiftUI

final class GolfGameViewModel: ObservableObject {
    // MARK: Setup state
    @Published var numPlayers: Int = 4
    @Published var startingPointValue: Int = 1
    @Published var playerLastNames: [String] = Array(repeating: "", count: 5)
    @Published var playerHandicaps: [String] = Array(repeating: "", count: 5)

    // MARK: Course state
    @Published var courseLibrary = CourseLibrary()
    @Published var selectedCourse: Course? = nil
    @Published var selectedTee: String = "White"

    // MARK: Runtime
    @Published var players: [Player] = []
    @Published var games: [Game] = []
    @Published var currentHole: Int = 1
    @Published var isGameSetupComplete: Bool = false
    @Published var isRoundComplete: Bool = false

    // Per-hole storage (arrays are the source of truth for aggregates)
    @Published var stakesPerHoleByGame: [[Int]] = []     // [game][holeIdx]
    @Published var contribPerHoleAByGame: [[Int]] = []   // [game][holeIdx]
    @Published var contribPerHoleBByGame: [[Int]] = []   // [game][holeIdx]

    // Hog Balls overlay trigger (UI feature)
    @Published var hogBallsCount: Int = 0
    @Published var hogBallsEventID: Int = 0

    // Calculator
    lazy var scoreCalculator: ScoreCalculator = {
        let c = selectedCourse ?? courseLibrary.courses.first!
        return ScoreCalculator(course: c)
    }()

    init() {
        if selectedCourse == nil {
            selectedCourse = courseLibrary.courses.first
            selectedTee = selectedCourse?.defaultTee ?? "White"
        }
    }

    // MARK: Setup

    func setupGame() {
        players.removeAll()
        games.removeAll()
        currentHole = 1
        isRoundComplete = false
        hogBallsCount = 0
        hogBallsEventID = 0

        // Build players
        for i in 0..<numPlayers {
            let name = playerLastNames[i].trimmingCharacters(in: .whitespacesAndNewlines)
            let hcpStr = playerHandicaps[i].trimmingCharacters(in: .whitespacesAndNewlines)
            let handicap = Handicap(hcpStr) ?? Handicap(value: 0)

            var p = Player(name: name.isEmpty ? "Player \(i+1)" : name, handicap: handicap)
            p.grossScores = Array(repeating: -1, count: 18)
            p.netScores   = Array(repeating:  0, count: 18)
            players.append(p)
        }

        // Teams / games
        if players.count == 4 {
            let a = Team(players: [players[0], players[1]])         // 12
            let b = Team(players: [players[2], players[3]])         // 34
            games = [ Game(teamA: a, teamB: b, startingPointValue: startingPointValue) ]
        } else if players.count == 5 {
            let anchor = Team(players: [players[0], players[1]])    // 12
            games = [
                Game(teamA: anchor, teamB: Team(players: [players[2], players[3]]), startingPointValue: startingPointValue), // 12 vs 34
                Game(teamA: anchor, teamB: Team(players: [players[2], players[4]]), startingPointValue: startingPointValue), // 12 vs 35
                Game(teamA: anchor, teamB: Team(players: [players[3], players[4]]), startingPointValue: startingPointValue)  // 12 vs 45
            ]
        }

        // Shape per-hole arrays
        stakesPerHoleByGame   = Array(repeating: Array(repeating: 0, count: 18), count: games.count)
        contribPerHoleAByGame = Array(repeating: Array(repeating: 0, count: 18), count: games.count)
        contribPerHoleBByGame = Array(repeating: Array(repeating: 0, count: 18), count: games.count)

        // Sanity: all games start at startingPointValue
        for gi in games.indices { games[gi].currentPointValue = startingPointValue }

        isGameSetupComplete = true
    }

    // MARK: Utilities

    func calculateNetScore(for player: Player, gross: Int, at hole: Int) -> Int {
        scoreCalculator.calculateNetScore(for: player, gross: gross, currentHole: hole)
    }
    func calculateNetScore(for player: Player, gross: Int) -> Int {
        calculateNetScore(for: player, gross: gross, at: currentHole)
    }

    private func teamLowAndTotal(_ team: Team, holeIdx: Int) -> (low: Int, total: Int) {
        var low = Int.max
        var total = 0
        for p in team.players {
            let g = p.grossScores[holeIdx]
            if g >= 0 {
                let n = p.netScores[holeIdx]
                low = min(low, n)
                total += n
            }
        }
        if low == Int.max { low = 0 }
        return (low, total)
    }

    // MARK: Scoring (sync teams + lock stake on Hole 1)

    func submitHoleScores(grossScores: [Int]) {
        let holeNumber = currentHole
        let holeIdx = max(0, min(17, holeNumber - 1))
        guard grossScores.count >= numPlayers else { return }

        // Write gross + net into master players array
        for i in 0..<numPlayers {
            players[i].grossScores[holeIdx] = grossScores[i]
            players[i].netScores[holeIdx]   = calculateNetScore(for: players[i], gross: grossScores[i], at: holeNumber)
        }

        // 🔑 Keep game teams in sync with master players (Player is a struct)
        syncTeamsForCurrentPlayers()

        // 🔒 Enforce stake = startingPointValue on HOLE 1 (prevents accidental 2×)
        if holeIdx == 0 {
            for gi in games.indices {
                games[gi].currentPointValue = startingPointValue
                // also persist the scheduled stake for Hole 1
                if stakesPerHoleByGame.indices.contains(gi) && stakesPerHoleByGame[gi].indices.contains(0) {
                    stakesPerHoleByGame[gi][0] = startingPointValue
                }
                // no presses considered used on Hole 1
                games[gi].frontPressUsedTeamA = false
                games[gi].frontPressUsedTeamB = false
                games[gi].backPressUsedTeamA  = false
                games[gi].backPressUsedTeamB  = false
            }
        }

        // Score each game (idempotent: we zero previous hole contribs inside)
        for gi in games.indices {
            scoreHole(for: &games[gi], at: holeIdx)
        }

        // Persist stakes & contributions BEFORE advancing
        captureStakeForJustScoredHole()
        writeContribForHole(holeNumber)
        recomputeAggregatesFromPerHole()

        // Advance
        if currentHole < 18 {
            currentHole += 1
        } else {
            isRoundComplete = true
        }
    }

    // Internal so extensions (Replay) can use it
    func scoreHole(for game: inout Game, at holeIdx: Int) {
        // remove previous contribution for idempotency
        game.teamA.aggregatePoints -= game.currentHoleContributionForTeamA
        game.teamB.aggregatePoints -= game.currentHoleContributionForTeamB
        game.currentHoleContributionForTeamA = 0
        game.currentHoleContributionForTeamB = 0

        let mult = game.currentPointValue
        let a = teamLowAndTotal(game.teamA, holeIdx: holeIdx)
        let b = teamLowAndTotal(game.teamB, holeIdx: holeIdx)

        var aLow = 0, bLow = 0
        if a.low < b.low { aLow = 3*mult; bLow = -3*mult }
        else if b.low < a.low { aLow = -3*mult; bLow = 3*mult }

        var aTot = 0, bTot = 0
        if a.total < b.total { aTot = 2*mult; bTot = -2*mult }
        else if b.total < a.total { aTot = -2*mult; bTot = 2*mult }

        let aContrib = aLow + aTot
        let bContrib = bLow + bTot

        game.currentHoleContributionForTeamA = aContrib
        game.currentHoleContributionForTeamB = bContrib
        game.teamA.aggregatePoints += aContrib
        game.teamB.aggregatePoints += bContrib
    }

    // MARK: Presses (block on Hole 1) + courtesy

    func pressForGame(gameIndex: Int) {
        // 🔒 Never allow a press on Hole 1
        guard currentHole > 1 else { return }

        let isFront = currentHole <= 9
        var g = games[gameIndex]

        if g.teamA.aggregatePoints < g.teamB.aggregatePoints {
            if isFront, !g.frontPressUsedTeamA { g.currentPointValue *= 2; g.frontPressUsedTeamA = true }
            if !isFront, !g.backPressUsedTeamA { g.currentPointValue *= 2; g.backPressUsedTeamA = true }
        } else if g.teamB.aggregatePoints < g.teamA.aggregatePoints {
            if isFront, !g.frontPressUsedTeamB { g.currentPointValue *= 2; g.frontPressUsedTeamB = true }
            if !isFront, !g.backPressUsedTeamB { g.currentPointValue *= 2; g.backPressUsedTeamB = true }
        }
        games[gameIndex] = g
    }

    func grantCourtesyPress(forGameIndex index: Int) {
        // courtesy UI already gated in CourtesyGate extension;
        // keep a guard here as well for safety.
        guard currentHole >= 18 else { return }
        var g = games[index]
        g.currentPointValue *= 2
        games[index] = g
    }

    // MARK: Team sync (struct semantics!)

    /// Keep teams’ player arrays synced with `players` so scoring reads fresh values.
    func syncTeamsForCurrentPlayers() {
        guard !players.isEmpty, !games.isEmpty else { return }
        if players.count == 4, games.indices.contains(0) {
            games[0].teamA.players = [players[0], players[1]] // 12
            games[0].teamB.players = [players[2], players[3]] // 34
        } else if players.count == 5, games.count >= 3 {
            let anchor = [players[0], players[1]]             // 12
            games[0].teamA.players = anchor
            games[0].teamB.players = [players[2], players[3]] // 34
            games[1].teamA.players = anchor
            games[1].teamB.players = [players[2], players[4]] // 35
            games[2].teamA.players = anchor
            games[2].teamB.players = [players[3], players[4]] // 45
        }
    }
}
