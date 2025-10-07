//
//  PlayerLibrary.swift
//  GolfScoreApp
//
//  Created by joe stewart on 3/15/25.
//

import Foundation
import Combine

class PlayerLibrary: ObservableObject {
    @Published var players: [String] = []
    
    init() {
        // Load saved names from UserDefaults
        if let saved = UserDefaults.standard.array(forKey: "PlayerLibrary") as? [String] {
            players = saved
        }
    }
    
    func addPlayer(_ name: String) {
        // Add the name only if it's not already in the library
        if !players.contains(name) {
            players.append(name)
            UserDefaults.standard.set(players, forKey: "PlayerLibrary")
        }
    }
}

