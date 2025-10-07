//
// Views/InstructionsView.swift
import SwiftUI

struct InstructionsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Select # of players 4 or 5, select Tees, select starting point value (default is $1). Enter players – Note Player 1 & 2 will be teammates vs all others. Enter handicap based on Tees selected. – Note that the + is for handicaps 0–36, - is for all sub-par handicaps. Start game and enter only GROSS scores throughout the game, review the scores and edit if necessary before submitting. The results page will display the results of the last hole and the cumulative team scores. Presses, if available, will be listed below and must be selected before you go to the next hole. After hole 18, see the Final Tally for team and individual point totals. From the summary page you can view the scorecard at any time for gross and net scores for all players.")
                .font(.body)
                .padding(.horizontal, 10)
            Spacer()
        }
        .padding(.bottom, 10)
        .navigationTitle("Instructions")
    }
}
