//10/7/25

// ViewModels/GolfGameViewModel+CourtesyGate.swift
import Foundation

extension GolfGameViewModel {
    /// UI gate: only show Courtesy Press options on Hole 18 (after 17 submitted)
    var canShowCourtesyPressUI: Bool {
        return currentHole >= 18
    }
}

