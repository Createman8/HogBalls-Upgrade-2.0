//// Views/HoleResultView.swift
///
import SwiftUI

struct HoleResultView: View {
    @ObservedObject var viewModel: GolfGameViewModel
    let completedHole: Int
    @Binding var path: NavigationPath

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Results for Hole \(completedHole)")
                    .font(.largeTitle.bold())
                    .frame(maxWidth: .infinity, alignment: .leading)

                // One compact card per game
                ForEach(viewModel.games.indices, id: \.self) { gi in
                    GameResultCard(game: viewModel.games[gi],
                                   gameIndex: gi,
                                   completedHole: completedHole)
                        .padding(.horizontal)
                }

                // Navigation
                if viewModel.currentHole >= 18 {
                    Button {
                        path.append(Screen.finalTally)
                    } label: {
                        Text("Final Tally")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.horizontal)
                } else {
                    Button {
                        // Advance to next hole and return to scoring
                        viewModel.currentHole = min(viewModel.currentHole + 1, 18)
                        path.append(Screen.score)
                    } label: {
                        Text("Next Hole")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .padding(.horizontal)
                }
            }
            .padding(.vertical, 16)
        }
        .navigationTitle("Hole \(completedHole) Results")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Small, explicit subview keeps type-checking fast
private struct GameResultCard: View {
    let game: Game
    let gameIndex: Int
    let completedHole: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Game \(gameIndex + 1)")
                    .font(.headline)
                Spacer()
                Text("Stake: $\(game.currentPointValue)")
                    .font(.subheadline)
            }

            Text("\(game.teamA.teamName) vs \(game.teamB.teamName)")
                .foregroundStyle(.secondary)

            // Per-hole contribution shown plainly
            HStack {
                Text("\(game.teamA.teamName): \(game.currentHoleContributionForTeamA) pts on hole \(completedHole)")
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("\(game.teamB.teamName): \(game.currentHoleContributionForTeamB) pts")
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .font(.subheadline)

            Divider().padding(.vertical, 4)

            // Aggregates
            HStack {
                Text("Total \(game.teamA.teamName): \(game.teamA.aggregatePoints) pts")
                    .foregroundColor(game.teamA.aggregatePoints < 0 ? .red : .primary)
                Spacer()
                Text("Total \(game.teamB.teamName): \(game.teamB.aggregatePoints) pts")
                    .foregroundColor(game.teamB.aggregatePoints < 0 ? .red : .primary)
            }
            .font(.subheadline)
        }
        .padding(12)
        .background(Color.gray.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    HoleResultView(
        viewModel: GolfGameViewModel(),
        completedHole: 17,
        path: .constant(NavigationPath())
    )
}
