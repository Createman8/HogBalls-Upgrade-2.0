//
//
//  ScoreReviewView.swift
//  GolfScoreApp
//

import SwiftUI

struct ScoreReviewView: View {
    @ObservedObject var viewModel: GolfGameViewModel

    // Read the live text via Binding so we see exactly what the user typed
    @Binding var grossInputs: [String]

    let onEdit: () -> Void
    let onSubmit: () -> Void

    private var holeNumber: Int { viewModel.currentHole }

    // Parse helpers (do not mutate state)
    private func parsedGross(_ index: Int) -> Int? {
        guard index < viewModel.numPlayers, index < grossInputs.count else { return nil }
        let t = grossInputs[index].trimmingCharacters(in: .whitespacesAndNewlines)
        if let v = Int(t) { return v }
        // Fallback: if text was empty, show any already-saved gross (>= 0)
        if viewModel.players.indices.contains(index) {
            let saved = viewModel.players[index].grossScores[holeNumber - 1]
            return saved >= 0 ? saved : nil
        }
        return nil
    }

    private func previewNet(for index: Int) -> Int? {
        guard
            let gross = parsedGross(index),
            let course = viewModel.selectedCourse,
            viewModel.players.indices.contains(index)
        else { return nil }

        let calc = ScoreCalculator(course: course)
        return calc.calculateNetScore(
            for: viewModel.players[index],
            gross: gross,
            currentHole: holeNumber
        )
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("Review Hole \(holeNumber)")
                    .font(.title3)
                    .padding(.top, 8)

                // Table
                VStack(spacing: 0) {
                    HStack {
                        Text("Player").font(.subheadline.bold()).frame(maxWidth: .infinity, alignment: .leading)
                        Text("Gross").font(.subheadline.bold()).frame(width: 70, alignment: .trailing)
                        Text("Net").font(.subheadline.bold()).frame(width: 70, alignment: .trailing)
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(Color.gray.opacity(0.12))

                    ForEach(0..<viewModel.numPlayers, id: \.self) { i in
                        HStack {
                            Text(playerName(i)).frame(maxWidth: .infinity, alignment: .leading)
                            Text(grossDisplay(i)).frame(width: 70, alignment: .trailing)
                            Text(netDisplay(i)).frame(width: 70, alignment: .trailing)
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(i.isMultiple(of: 2) ? Color.gray.opacity(0.06) : Color.clear)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.horizontal)

                Spacer()

                HStack(spacing: 12) {
                    Button {
                        onEdit()
                    } label: {
                        Text("Edit Gross Scores")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)

                    Button {
                        onSubmit()
                    } label: {
                        Text("Submit Scores")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding(.horizontal)
                .padding(.bottom, 12)
            }
            .navigationTitle("Review Scores")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Helpers

    private func playerName(_ index: Int) -> String {
        guard viewModel.players.indices.contains(index) else { return "Player \(index + 1)" }
        return viewModel.players[index].name
    }

    private func grossDisplay(_ index: Int) -> String {
        if let g = parsedGross(index) { return "\(g)" }
        return "—"
    }

    private func netDisplay(_ index: Int) -> String {
        if let n = previewNet(for: index) { return "\(n)" }
        return "—"
    }
}
