//
//  File.swift
//  GolfScoreApp
// GameError created to give a centralized error center
//  Created by joe stewart on 4/6/25.
//

import Foundation

enum GameError: LocalizedError, Identifiable {
    var id: String { errorDescription ?? "Unknown error" }
    
    case invalidPlayerCount(expected: Int, got: Int)
    case invalidHandicapInput(index: Int)
    case emptyPlayerName

    var errorDescription: String? {
        switch self {
        case .invalidPlayerCount(let expected, let got):
            return "Expected \(expected) players, but got \(got). Please complete all player details."
        case .invalidHandicapInput(let index):
            return "Handicap for player \(index + 1) is invalid. Please enter a valid number."
        case .emptyPlayerName:
            return "Player name cannot be empty."
        }
    }
}

