//updated 9/8 to allow hole changes
// Views/EditPastHoleView.swift
// Simple, reliable past-hole editor compatible with the current ViewModel APIs.

import SwiftUI
import Foundation

struct EditPastHoleView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: GolfGameViewModel

    @State private var holeIndex: Int = 0            // 0-based hole index being edited
    @State private var grossInputs: [String] = Array(repeating: "", count: 5)

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                pickerRow()
                inputsGrid()

                HStack(spacing: 12) {
                    Button("Cancel") { dismiss() }
                        .buttonStyle(.bordered)

                    Button("Save") { saveEdits() }
                        .buttonStyle(.borderedProminent)
                }
                .padding(.horizontal)
            }
            .navigationTitle("Edit Past Hole")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                // Initialize to previous hole if currentHole > 1
                holeIndex = max(0, min(17, viewModel.currentHole - 2))
                loadGrossInputs()
            }
        }
    }

    @ViewBuilder
    private func pickerRow() -> some View {
        HStack {
            Text("Hole")
            Spacer()
            Picker("Hole", selection: $holeIndex) {
                ForEach(0..<18, id: \.self) { i in
                    Text("Hole \(i + 1)").tag(i)
                }
            }
            .pickerStyle(.menu)
            .onChange(of: holeIndex) { _, _ in
                loadGrossInputs()
            }
        }
        .padding(.horizontal)
    }

    @ViewBuilder
    private func inputsGrid() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(0..<viewModel.numPlayers, id: \.self) { i in
                HStack {
                    Text(playerName(i))
                        .frame(maxWidth: .infinity, alignment: .leading)

                    TextField("Gross",
                              text: Binding(
                                get: { grossInputs[i] },
                                set: { grossInputs[i] = $0 }
                              ))
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 70)
                    .textFieldStyle(.roundedBorder)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
    }

    private func playerName(_ index: Int) -> String {
        guard viewModel.players.indices.contains(index) else { return "Player \(index + 1)" }
        return viewModel.players[index].name
    }

    private func loadGrossInputs() {
        for i in 0..<grossInputs.count { grossInputs[i] = "" }
        for i in 0..<viewModel.numPlayers where viewModel.players.indices.contains(i) {
            let g = viewModel.players[i].grossScores[holeIndex]
            if g >= 0 { grossInputs[i] = String(g) }
        }
    }

    private func saveEdits() {
        // Write edited gross scores back to the model for this holeIndex
        for i in 0..<viewModel.numPlayers where viewModel.players.indices.contains(i) {
            let t = grossInputs[i].trimmingCharacters(in: .whitespacesAndNewlines)
            if let g = Int(t) {
                viewModel.players[i].grossScores[holeIndex] = g
            } else {
                // Treat empty/invalid as "no score entered"
                viewModel.players[i].grossScores[holeIndex] = -1
                viewModel.players[i].netScores[holeIndex] = 0
            }
        }

        // Rebuild nets, contributions, stakes, and aggregates deterministically
        viewModel.applyEditedHoleRecalcForward()

        dismiss()
    }
}

