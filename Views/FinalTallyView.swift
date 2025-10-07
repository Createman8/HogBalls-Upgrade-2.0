//
//  FinalTallyView.swift
//  GolfScoreApp
//

import SwiftUI

struct FinalTallyView: View {
    @ObservedObject var viewModel: GolfGameViewModel
    @Binding var path: NavigationPath
    
    var individualPointTotals: [UUID: Double] {
        var totals: [UUID: Double] = [:]
        for game in viewModel.games {
            for player in game.teamA.players {
                totals[player.id, default: 0] += Double(game.teamA.aggregatePoints)
            }
            for player in game.teamB.players {
                totals[player.id, default: 0] += Double(game.teamB.aggregatePoints)
            }
        }
        return totals
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("Final Tally")
                    .font(.largeTitle)
                    .padding()
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
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(RoundedRectangle(cornerRadius: 20).stroke(Color.gray, lineWidth: 3))
                    }
                    .padding(.horizontal)
                }
                VStack(alignment: .leading) {
                    Text("Individual Point Totals")
                        .font(.title2)
                        .padding(.bottom, 8)
                    ForEach(viewModel.players, id: \.id) { player in
                        let points = individualPointTotals[player.id] ?? 0
                        Text("\(player.name): \(points, specifier: "%.1f") pts")
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(RoundedRectangle(cornerRadius: 20).stroke(Color.gray, lineWidth: 3))
                .padding(.horizontal)
                
                // Score Card Button
                Button(action: {
                    path.append(Screen.scorecard)
                }) {
                    Text("View Score Card")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding()
            }
        }
        .navigationTitle("Final Tally")
    }
}

struct FinalTallyView_Previews: PreviewProvider {
    static var previews: some View {
        FinalTallyView(viewModel: GolfGameViewModel(), path: .constant(NavigationPath()))
    }
}
