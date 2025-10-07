//
// Models/Player.swift
import Foundation

struct Player: Identifiable, Hashable {
    let id = UUID()
    var name: String
    var handicap: Handicap
    var grossScores: [Int]
    var netScores: [Int]
    
    init(name: String, handicap: Handicap) {
        self.name = name
        self.handicap = handicap
        self.grossScores = Array(repeating: 0, count: 18)
        self.netScores = Array(repeating: 0, count: 18)
    }
}
