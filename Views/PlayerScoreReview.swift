// 9/25/25
// Views/PlayerScoreReviewView.swift

import SwiftUI
import Foundation

struct PlayerScoreReviewView: View {
    @ObservedObject var viewModel: GolfGameViewModel
    @Binding var path: NavigationPath

    var body: some View {
        VStack {
            Text("Review Scores for Hole \(viewModel.currentHole)")
                .font(.headline)
                .padding()
            List {
                ForEach(0..<viewModel.players.count, id: \.self) { i in
                    let gross = viewModel.players[i].grossScores[viewModel.currentHole - 1]
                    let net = viewModel.calculateNetScore(for: viewModel.players[i], gross: gross)
                    HStack {
                        Text("\(viewModel.players[i].name):")
                        Spacer()
                        Text("Gross: \(gross), Net: \(net)")
                    }
                }
            }
            HStack {
                Button("Edit Scores") { path.removeLast() }
                    .padding()
                Spacer()
                Button("Submit Scores") { path.append(Screen.result) }
                    .padding()
            }
        }
        .navigationTitle("Review Hole \(viewModel.currentHole)")
    }
}

