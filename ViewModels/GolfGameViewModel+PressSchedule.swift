//
//  GolfGameViewModel+PressSchedule.swift
// ViewModels/GolfGameViewModel+PressSchedule.swift
// Clean version: NO captureStakeForJustScoredHole() here (it's in +Aggregation)

import Foundation

extension GolfGameViewModel {

    // MARK: - Scheduled stake helpers (non-overlapping with +Aggregation)

    /// Returns the stake that was scheduled/snapshotted for a given game at a given hole index (0-based).
    /// Falls back to the game's currentPointValue if out of range.
    func scheduledStake(forGameIndex gi: Int, holeIndex idx: Int) -> Int {
        guard
            stakesPerHoleByGame.indices.contains(gi),
            stakesPerHoleByGame[gi].indices.contains(idx)
        else {
            return games.indices.contains(gi) ? games[gi].currentPointValue : startingPointValue
        }
        return stakesPerHoleByGame[gi][idx]
    }

    /// Sets (overwrites) the scheduled stake for a game at a specific hole index (0-based).
    /// Safe-guards array shapes to exactly 18 holes.
    func setScheduledStake(_ value: Int, forGameIndex gi: Int, holeIndex idx: Int) {
        guard games.indices.contains(gi) else { return }

        // Ensure outer shape
        if stakesPerHoleByGame.count != games.count {
            stakesPerHoleByGame = Array(repeating: Array(repeating: 0, count: 18), count: games.count)
        }
        // Ensure inner shape
        for g in games.indices where stakesPerHoleByGame[g].count != 18 {
            stakesPerHoleByGame[g] = Array(repeating: 0, count: 18)
        }
        let i = max(0, min(17, idx))
        stakesPerHoleByGame[gi][i] = value
    }

    // MARK: - Press scheduling notes
    // Actual press application happens live via:
    //   - pressForGame(gameIndex:)
    //   - grantCourtesyPress(forGameIndex:)
    // Snapshotting the stake for the just-scored hole is handled in:
    //   - captureStakeForJustScoredHole()  (defined in GolfGameViewModel+Aggregation.swift)
    //
    // If you later build a manual press editor that prewrites stakes for future holes,
    // use setScheduledStake(_:forGameIndex:holeIndex:) above to store those values.
}

