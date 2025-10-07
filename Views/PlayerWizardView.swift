//
//  PlayerWizardView.swift
//  GolfScoreApp
//

import SwiftUI

struct PlayerWizardView: View {
    @ObservedObject var viewModel: GolfGameViewModel
    @Binding var path: NavigationPath
    @State private var currentIndex: Int = 0
    // Modified tuple to include an isNegative flag.
    @State private var playerDetails: [(name: String, handicap: String, isNegative: Bool)]
    @ObservedObject var library = PlayerLibrary()
    
    // New error state.
    @State private var gameError: GameError?

    // Initialize playerDetails based on the number of players from the view model.
    init(viewModel: GolfGameViewModel, path: Binding<NavigationPath>) {
        self.viewModel = viewModel
        self._playerDetails = State(initialValue: Array(repeating: (name: "", handicap: "", isNegative: false), count: viewModel.numPlayers))
        self._path = path
    }
    
    var body: some View {
        VStack {
            Text("Player \(currentIndex + 1) Details")
                .font(.largeTitle)
                .padding()
            
            // Entry for player name using PlayerEntryView.
            PlayerEntryView(playerName: $playerDetails[currentIndex].name, library: library)
            
            // Handicap entry with a toggle button for +/-.
            HStack {
                Button(action: {
                    // Toggle the sign flag.
                    playerDetails[currentIndex].isNegative.toggle()
                    
                    // Update the handicap string accordingly.
                    var trimmed = playerDetails[currentIndex].handicap.trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    // Remove any existing negative sign.
                    if trimmed.hasPrefix("-") {
                        trimmed = String(trimmed.dropFirst())
                    }
                    
                    // Update the displayed string based on the toggle.
                    if playerDetails[currentIndex].isNegative {
                        playerDetails[currentIndex].handicap = "-" + trimmed
                    } else {
                        playerDetails[currentIndex].handicap = trimmed
                    }
                }) {
                    Text(playerDetails[currentIndex].isNegative ? "–" : "+")
                        .font(.title)
                        .frame(width: 44, height: 44)
                        .background(RoundedRectangle(cornerRadius: 5).stroke(Color.gray, lineWidth: 2))
                }
                .padding(.trailing, 8)
                
                TextField("Enter Handicap", text: $playerDetails[currentIndex].handicap)
                    .font(.title)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 2))
                    .keyboardType(.numberPad)
            }
            .padding(.horizontal)
            
            HStack {
                if currentIndex > 0 {
                    Button("Previous") {
                        currentIndex -= 1
                    }
                    .padding()
                }
                
                Spacer()
                
                if currentIndex < playerDetails.count - 1 {
                    Button("Next") {
                        // Validate the current player's details before moving on.
                        guard validateCurrentPlayer() else { return }
                        // Save the current player's name into the library.
                        library.addPlayer(playerDetails[currentIndex].name)
                        currentIndex += 1
                    }
                    .padding()
                } else {
                    Button("Finish") {
                        // Validate the final player's details.
                        guard validateCurrentPlayer() else { return }
                        // Save the final player's name.
                        library.addPlayer(playerDetails[currentIndex].name)
                        
                        // Process handicap values: ensure the sign is correct.
                        viewModel.playerLastNames = playerDetails.map { $0.name }
                        viewModel.playerHandicaps = playerDetails.map { detail in
                            let trimmed = detail.handicap.trimmingCharacters(in: .whitespacesAndNewlines)
                            if detail.isNegative {
                                return trimmed.hasPrefix("-") ? trimmed : "-" + trimmed
                            } else {
                                return trimmed.hasPrefix("-") ? String(trimmed.dropFirst()) : trimmed
                            }
                        }
                        
                        // Debug prints to check array lengths.
                        print("Number of players: \(viewModel.numPlayers)")
                        print("Player names count: \(viewModel.playerLastNames.count)")
                        print("Player handicaps count: \(viewModel.playerHandicaps.count)")
                        
                        // Set up the game so the players array is populated.
                        viewModel.setupGame()
                        
                        // Navigate to the next screen (e.g., Score screen).
                        path.append(Screen.score)
                    }
                    .padding()
                }
            }
        }
        .padding()
        .navigationTitle("Enter Player Details")
        // Bind an alert to gameError to show validation issues.
        .alert(item: $gameError) { error in
            Alert(title: Text("Error"),
                  message: Text(error.errorDescription ?? "Unknown error"),
                  dismissButton: .default(Text("OK")))
        }
    }
    
    /// Validates the current player's details. Returns true if valid; otherwise, sets a gameError and returns false.
    private func validateCurrentPlayer() -> Bool {
        let currentDetail = playerDetails[currentIndex]
        if currentDetail.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            gameError = .emptyPlayerName
            return false
        }
        if currentDetail.handicap.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
            Int(currentDetail.handicap.trimmingCharacters(in: .whitespacesAndNewlines)) == nil {
            gameError = .invalidHandicapInput(index: currentIndex)
            return false
        }
        return true
    }

}

struct PlayerWizardView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerWizardView(viewModel: GolfGameViewModel(), path: .constant(NavigationPath()))
    }
}
