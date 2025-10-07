//
// Models/Team.swift
import Foundation

struct Team: Identifiable {
    let id = UUID()
    var players: [Player]
    var teamName: String
    var aggregatePoints: Int
    
    init(players: [Player]) {
        self.players = players
        self.teamName = players.map { $0.name }.joined(separator: " & ")
        self.aggregatePoints = 0
    }
}
