//
// Views/SummaryView.swift
import SwiftUI

struct SummaryView: View {
    @ObservedObject var viewModel: GolfGameViewModel
    @Binding var path: NavigationPath
    
    var body: some View {
        VStack {
            Text("Round Summary")
                .font(.largeTitle)
                .padding()
            List {
                ForEach(0..<viewModel.games.count, id: \.self) { i in
                    let game = viewModel.games[i]
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Game \(i+1): \(game.teamA.teamName) vs \(game.teamB.teamName)")
                        HStack {
                            Text("\(game.teamA.teamName): \(game.teamA.aggregatePoints) pts")
                                .foregroundColor(game.teamA.aggregatePoints < 0 ? .red : .primary)
                            Spacer()
                            Text("\(game.teamB.teamName): \(game.teamB.aggregatePoints) pts")
                                .foregroundColor(game.teamB.aggregatePoints < 0 ? .red : .primary)
                        }
                        .padding(24)
                        .frame(maxWidth: .infinity)
                        .background(RoundedRectangle(cornerRadius: 16).stroke(Color.gray, lineWidth: 3))
                    }
                    .id("summary-game-\(i)")
                }
            }
            List {
                ForEach(viewModel.players, id: \.id) { player in
                    let totalGross = player.grossScores.reduce(0, +)
                    Text("\(player.name): Total Gross Score: \(totalGross)")
                        .id("summary-player-\(player.id)")
                }
            }
            Button(action: {
                path.append(Screen.scorecard)
            }) {
                Text("View Score Card")
            }
            .padding()
        }
        .navigationTitle("Summary")
    }
}
