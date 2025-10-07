// Views/SetupView.swift 9/25/25
// Simplified bindings (faster type-check), adds Foundation for trimming

import SwiftUI
import Foundation

struct SetupView: View {
    @ObservedObject var viewModel: GolfGameViewModel
    @Binding var path: NavigationPath
    @State private var gameError: GameError?
    @State private var localErrorMessage: String?

    // Local selections to avoid heavy Picker binding expressions
    @State private var localSelectedCourse: Course?
    @State private var localSelectedTee: String = "White"

    private var isGameSettingsValid: Bool {
        viewModel.numPlayers == 4 || viewModel.numPlayers == 5
    }

    var body: some View {
        Form {
            // Course selection
            Section(header: Text("Course")) {
                Picker("Course", selection: $localSelectedCourse) {
                    ForEach(viewModel.courseLibrary.courses) { course in
                        Text(course.name).tag(Optional(course))
                    }
                }

                if let course = localSelectedCourse {
                    Picker("Tee", selection: $localSelectedTee) {
                        ForEach(course.tees, id: \.name) { tee in
                            Text(tee.name).tag(tee.name)
                        }
                    }
                } else {
                    Text("Select a course").foregroundColor(.secondary)
                }
            }

            // Game settings
            Section(header: Text("Game Settings")) {
                Picker("Number of Players", selection: $viewModel.numPlayers) {
                    Text("4 Players").tag(4)
                    Text("5 Players").tag(5)
                }
                .pickerStyle(.segmented)

                Stepper("Starting Point Value: \(viewModel.startingPointValue)",
                        value: $viewModel.startingPointValue,
                        in: 1...100)
            }

            // Player entry
            Section(header: Text("Player Details")) {
                ForEach(0..<viewModel.numPlayers, id: \.self) { i in
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Player \(i + 1)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        HStack(spacing: 12) {
                            TextField("Last name", text: $viewModel.playerLastNames[i])
                                .textFieldStyle(.roundedBorder)
                                .frame(maxWidth: 220)

                            TextField("Handicap", text: $viewModel.playerHandicaps[i])
                                .keyboardType(.numbersAndPunctuation)
                                .textFieldStyle(.roundedBorder)
                                .frame(width: 110)
                        }
                    }
                    .padding(.vertical, 4)
                }

                NavigationLink("Open Player Wizard (optional)", value: Screen.playerWizard)
                    .font(.headline)
            }

            // Start
            Section {
                Button {
                    startGameTapped()
                } label: {
                    HStack { Spacer(); Text("Start Game").font(.headline); Spacer() }
                }
                .buttonStyle(.borderedProminent)
                .disabled(!isGameSettingsValid)
            } footer: {
                if !isGameSettingsValid {
                    Text("Select either 4 or 5 players to continue.").foregroundColor(.red)
                } else {
                    Text("Select a course, choose a tee, and complete player info.")
                        .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle("Setup")
        .onAppear {
            // Bootstrap locals
            if localSelectedCourse == nil {
                localSelectedCourse = viewModel.selectedCourse ?? viewModel.courseLibrary.courses.first
            }
            localSelectedTee = viewModel.selectedTee
        }
        .onChange(of: localSelectedCourse) { new in
            viewModel.selectedCourse = new
            viewModel.selectedTee = new?.defaultTee ?? "White"
            localSelectedTee = viewModel.selectedTee
        }
        .onChange(of: localSelectedTee) { new in
            viewModel.selectedTee = new
        }
        .alert(item: $gameError) { error in
            Alert(title: Text("Error"),
                  message: Text(error.errorDescription ?? "Unknown error"),
                  dismissButton: .default(Text("OK")))
        }
        .alert("Error",
               isPresented: Binding(get: { localErrorMessage != nil }, set: { if !$0 { localErrorMessage = nil } })) {
            Button("OK", role: .cancel) { localErrorMessage = nil }
        } message: {
            Text(localErrorMessage ?? "")
        }
    }

    // MARK: - Actions

    private func startGameTapped() {
        guard isGameSettingsValid else {
            gameError = .invalidPlayerCount(expected: 4, got: viewModel.numPlayers)
            return
        }
        guard viewModel.selectedCourse != nil else {
            localErrorMessage = "Please select a course."
            return
        }
        if let err = validatePlayers() {
            gameError = err
            return
        }
        viewModel.setupGame()
        path.append(Screen.score)
    }

    private func validatePlayers() -> GameError? {
        for i in 0..<viewModel.numPlayers {
            let name = viewModel.playerLastNames[i].trimmingCharacters(in: .whitespacesAndNewlines)
            if name.isEmpty { return .emptyPlayerName }
            let h = viewModel.playerHandicaps[i].trimmingCharacters(in: .whitespacesAndNewlines)
            guard Handicap(h) != nil else { return .invalidHandicapInput(index: i) }
        }
        return nil
    }
}

struct SetupView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SetupView(viewModel: GolfGameViewModel(),
                      path: .constant(NavigationPath()))
        }
    }
}

