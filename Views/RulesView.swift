//
// Views/RulesView.swift
import SwiftUI

struct RulesView: View {
    var body: some View {
        VStack {
            Text("Rules")
                .font(.largeTitle)
                .padding()
            Text("Low Ball/Low Total is a partner game for 4 or 5 players that awards 5 points per hole (3 pts for low net ball and 2 pts for low net total per team). If there are 4 players, the teams will be Player 1 & 2 vs Player 3 & 4.  If there are 5 players, the teams will be Player 1 & 2 vs Player 3 & 4, Player 1 & 2 vs Player 3 & 5 and Player 1 & 2 vs Player 4 & 5. When a team is losing, they may elect to Press the bet, which doubles the amount of points for that game going forward. Every time a game is pressed it again doubles. Each team has 1 press per game per nine holes.")
                .padding()
            Spacer()
        }
        .navigationTitle("Rules")
    }
}
