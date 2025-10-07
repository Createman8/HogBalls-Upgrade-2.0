//
// Models/Game.swift
import Foundation

struct Game: Identifiable {
    let id = UUID()
    var teamA: Team
    var teamB: Team
    var currentPointValue: Int
    var frontPressUsedTeamA: Bool
    var frontPressUsedTeamB: Bool
    var backPressUsedTeamA: Bool
    var backPressUsedTeamB: Bool
    var currentHoleContributionForTeamA: Int = 0
    var currentHoleContributionForTeamB: Int = 0
    
    init(teamA: Team, teamB: Team, startingPointValue: Int) {
        self.teamA = teamA
        self.teamB = teamB
        self.currentPointValue = startingPointValue
        self.frontPressUsedTeamA = false
        self.frontPressUsedTeamB = false
        self.backPressUsedTeamA = false
        self.backPressUsedTeamB = false
    }
}
