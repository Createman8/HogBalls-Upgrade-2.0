//
//  GolfGameViewModel+PressEditorApply.swift
//  GolfScoreApp
//
//  Created by joe stewart on 9/8/25.
//

import Foundation

// Lightweight selection model the editor can pass to the VM.
// NOTE: For now we only honor `courtesy18` and ignore the front/back fields.
struct PressSelection {
    enum Courtesy { case teamA, teamB }
    let gameIndex: Int
    let frontPressHoleA: Int?
    let frontPressHoleB: Int?
    let backPressHoleA: Int?
    let backPressHoleB: Int?
    let courtesy18: Courtesy?
}

extension GolfGameViewModel {
    /// Adapter used by EditPressesView's "Save".
    /// CURRENT BEHAVIOR: Applies Courtesy Press on 18 (if allowed). Ignores front/back picks.
    func applyManualPressSchedule(forGameIndex index: Int, selection: PressSelection) {
        guard index >= 0 && index < games.count else { return }

        // Courtesy press: only allow after 17 has been submitted (i.e., when current hole is 18).
        if canShowCourtesyPressUI, selection.courtesy18 != nil {
            grantCourtesyPress(forGameIndex: index)
        }

        // If you want us to fully support front/back scheduling + round replay,
        // we can expand this function to rebuild the stake schedule and call your replay pipeline.
    }
}

