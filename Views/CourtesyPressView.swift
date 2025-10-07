//
//  CourtesyPressView.swift
//  GolfScoreApp
//
//  Created by joe stewart on 3/30/25.
import SwiftUI

struct CourtesyPressView: View {
    let gameIndex: Int
    let winningTeam: String
    let losingTeam: String
    @ObservedObject var viewModel: GolfGameViewModel
    let textColor: Color  // For setting green text.
    @State private var decided = false

    var body: some View {
        if !decided {
            VStack {
                Text("Team \(winningTeam),")
                    .foregroundColor(textColor)
                    .multilineTextAlignment(.center)
                    .padding(.top)
                Text("Do you want to grant a courtesy press to \(losingTeam)?")
                    .foregroundColor(textColor)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 10)
                HStack {
                    Button("Yes") {
                        viewModel.grantCourtesyPress(forGameIndex: gameIndex)
                        decided = true
                    }
                    .padding()
                    Button("No") {
                        decided = true
                    }
                    .padding()
                }
            }
            .background(RoundedRectangle(cornerRadius: 10)
                            .fill(Color.gray.opacity(0.2)))
            .padding()
        }
    }
}

struct CourtesyPressView_Previews: PreviewProvider {
    static var previews: some View {
        CourtesyPressView(
            gameIndex: 0,
            winningTeam: "Team A",
            losingTeam: "Team B",
            viewModel: GolfGameViewModel(),
            textColor: .green
        )
    }
}
