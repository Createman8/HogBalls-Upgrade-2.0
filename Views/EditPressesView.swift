//
//  EditPressesView.swift
//  GolfScoreApp
//
//  Created by joe stewart on 9/7/25.
//  
import SwiftUI

struct EditPressesView: View {
    @ObservedObject var viewModel: GolfGameViewModel
    let onClose: () -> Void

    @State private var selections: [GamePressEditor] = []

    struct GamePressEditor: Identifiable {
        let id = UUID()
        let gameIndex: Int
        var frontA: Int?     // 1...9
        var frontB: Int?
        var backA: Int?      // 10...18
        var backB: Int?
        var courtesy: Courtesy
        enum Courtesy: String, CaseIterable, Identifiable {
            case none = "None", teamA = "Team A", teamB = "Team B"
            var id: String { rawValue }
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                ForEach(selections.indices, id: \.self) { i in
                    let gi = selections[i].gameIndex
                    Section(header: Text("Game \(gi + 1)")) {

                        // Front/back pickers are UI-only right now (we ignore them on Save).
                        pressRow(label: "Front press – Team A",
                                 selection: $selections[i].frontA,
                                 range: 1...9)
                        pressRow(label: "Front press – Team B",
                                 selection: $selections[i].frontB,
                                 range: 1...9)
                        pressRow(label: "Back press – Team A",
                                 selection: $selections[i].backA,
                                 range: 10...18)
                        pressRow(label: "Back press – Team B",
                                 selection: $selections[i].backB,
                                 range: 10...18)

                        // Courtesy picker is gated until AFTER 17 is submitted (i.e., on hole 18).
                        if viewModel.canShowCourtesyPressUI {
                            Picker("18th-hole courtesy", selection: $selections[i].courtesy) {
                                ForEach(GamePressEditor.Courtesy.allCases) { c in
                                    Text(c.rawValue).tag(c)
                                }
                            }
                        } else {
                            HStack {
                                Text("18th-hole courtesy")
                                Spacer()
                                Text("Available on 18").foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Edit Presses")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { onClose() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        applyAndReplay()
                        onClose()
                    }
                }
            }
            .onAppear { bootstrapFromCurrentSchedule() }
        }
    }

    // MARK: - Rows

    @ViewBuilder
    private func pressRow(label: String, selection: Binding<Int?>, range: ClosedRange<Int>) -> some View {
        HStack {
            Text(label)
            Spacer()
            Picker("", selection: selection) {
                Text("—").tag(Int?.none)
                ForEach(Array(range), id: \.self) { hole in
                    Text("\(hole)").tag(Int?.some(hole))
                }
            }
            .pickerStyle(.menu)
        }
    }

    // MARK: - Bootstrap from current model

    private func jumpHoles(range: Range<Int>) -> [Int] {
        guard viewModel.currentHole > 1 else { return [] }
        let justScored = viewModel.currentHole - 1   // 1-based
        let justIdx = justScored - 1                 // 0-based
        var jumps: [Int] = []
        for gi in viewModel.games.indices {
            let stakes = viewModel.stakesPerHoleByGame[gi]
            for idx in range {
                if idx <= justIdx,
                   idx > 0,
                   stakes.indices.contains(idx),
                   stakes.indices.contains(idx - 1),
                   stakes[idx] > stakes[idx-1] {
                    jumps.append(idx + 1) // back to 1-based
                }
            }
        }
        return Array(Set(jumps)).sorted()
    }

    private func bootstrapFromCurrentSchedule() {
        selections.removeAll()

        for gi in viewModel.games.indices {
            let frontJumps = jumpHoles(range: 0..<9)   // holes 1–9
            let backJumps  = jumpHoles(range: 9..<18)  // holes 10–18

            let g = viewModel.games[gi]
            var frontA: Int? = nil
            var frontB: Int? = nil
            var backA: Int?  = nil
            var backB: Int?  = nil
            var courtesy: GamePressEditor.Courtesy = .none

            if g.frontPressUsedTeamA, let first = frontJumps.first { frontA = first }
            if g.frontPressUsedTeamB {
                if frontJumps.count >= 2 { frontB = frontJumps.last }
                else if let first = frontJumps.first, frontA == nil { frontB = first }
            }
            if g.backPressUsedTeamA, let first = backJumps.first { backA = first }
            if g.backPressUsedTeamB {
                if backJumps.count >= 2 { backB = backJumps.last }
                else if let first = backJumps.first, backA == nil { backB = first }
            }

            // Courtesy cannot be inferred reliably; default to .none.
            if viewModel.canShowCourtesyPressUI {
                courtesy = .none
            }

            selections.append(.init(gameIndex: gi,
                                    frontA: frontA, frontB: frontB,
                                    backA: backA, backB: backB,
                                    courtesy: courtesy))
        }
    }

    // MARK: - Apply (Courtesy only for now)

    private func applyAndReplay() {
        for s in selections {
            // Map the editor's courtesy to the VM PressSelection type (explicit mapping fixes the closure error)
            let mappedCourtesy: PressSelection.Courtesy?
            switch s.courtesy {
            case .none:  mappedCourtesy = nil
            case .teamA: mappedCourtesy = .teamA
            case .teamB: mappedCourtesy = .teamB
            }

            let selection = PressSelection(
                gameIndex: s.gameIndex,
                frontPressHoleA: s.frontA,
                frontPressHoleB: s.frontB,
                backPressHoleA: s.backA,
                backPressHoleB: s.backB,
                courtesy18: mappedCourtesy
            )

            viewModel.applyManualPressSchedule(forGameIndex: s.gameIndex, selection: selection)
        }
    }
}
