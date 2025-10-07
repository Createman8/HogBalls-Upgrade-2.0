//updated 9/8/25

import SwiftUI
import AVFoundation

struct ScoreView: View {
    @ObservedObject var viewModel: GolfGameViewModel
    @Binding var path: NavigationPath

    // MARK: - Local UI state
    @State private var scoreInputs: [String] = Array(repeating: "", count: 5)
    @State private var showValidationAlert = false
    @State private var validationMessage = ""
    @State private var showReviewSheet = false
    @State private var showEditPastHole = false
    @State private var showEditPresses = false
    @State private var showRestartConfirm = false
    @FocusState private var focusedField: Int?

    // Optional Hog Balls audio
    @State private var hogSound: AVAudioPlayer?

    private let hogLogoCandidates = ["hogballs_logo", "HogBallsLogo", "HogBalls", "hogballs", "logo_hogballs"]
    private let hogAudioCandidates = ["hogballs", "HogBalls", "hog_balls"]

    // MARK: - Derived

    private var holeIndex: Int { max(0, min(viewModel.currentHole - 1, 17)) }

    private var holeIsSubmitted: Bool {
        viewModel.players.prefix(viewModel.numPlayers).allSatisfy { p in
            p.grossScores[holeIndex] != -1
        }
    }

    private var isScoreFormValid: Bool {
        if holeIsSubmitted { return true }
        for input in scoreInputs.prefix(viewModel.numPlayers) {
            let t = input.trimmingCharacters(in: .whitespacesAndNewlines)
            if t.isEmpty || Int(t) == nil { return false }
        }
        return true
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            mainContent()
            hogOverlayIfNeeded() // returns EmptyView when not needed
        }
        .onAppear { refreshScoreInputsFromModel() }
        // iOS 17+ two-parameter closure form (fixes deprecation)
        .onChange(of: viewModel.currentHole) { _, _ in
            refreshScoreInputsFromModel()
        }
        .toolbar { toolbarContent() }
        .confirmationDialog(
            "Restart round from Hole 1? Players and handicaps will be kept.",
            isPresented: $showRestartConfirm,
            titleVisibility: .visible
        ) {
            Button("Restart Round", role: .destructive) {
                viewModel.restartRoundPreservingPlayers()
                refreshScoreInputsFromModel()
            }
            Button("Cancel", role: .cancel) { }
        }
        .sheet(isPresented: $showReviewSheet) {
            ScoreReviewView(
                viewModel: viewModel,
                grossInputs: $scoreInputs,
                onEdit: { showReviewSheet = false },
                onSubmit: { submitAndScoreTapped() }
            )
        }
        .navigationTitle("Hole \(viewModel.currentHole)")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .alert(isPresented: $showValidationAlert) {
            Alert(title: Text("Invalid Scores"),
                  message: Text(validationMessage),
                  dismissButton: .default(Text("OK")))
        }
    }

    // MARK: - Main sections

    @ViewBuilder
    private func mainContent() -> some View {
        ScrollView {
            VStack(spacing: 12) {
                headerRow()
                inputsGrid()
                actionRow()
                courtesySection()     // Only appears on hole 18
                gamesSection()
                Spacer(minLength: 12)
            }
            .padding(.bottom, 12)
        }
    }

    @ViewBuilder
    private func headerRow() -> some View {
        HStack {
            Text(viewModel.selectedCourse?.name ?? "Course")
                .font(.headline)
            Spacer()
            Text("Tee: \(viewModel.selectedTee)")
        }
        .padding(.horizontal)
    }

    @ViewBuilder
    private func inputsGrid() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(0..<viewModel.numPlayers, id: \.self) { index in
                HStack {
                    Text(viewModel.players.indices.contains(index) ? viewModel.players[index].name : "Player \(index+1)")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    TextField("Gross", text: $scoreInputs[index])
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 70)
                        .textFieldStyle(.roundedBorder)
                        .focused($focusedField, equals: index)
                        .onSubmit { focusNext(after: index) }
                        .submitLabel(index == viewModel.numPlayers - 1 ? .done : .next)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
    }

    @ViewBuilder
    private func actionRow() -> some View {
        HStack(spacing: 12) {
            if holeIsSubmitted {
                Button {
                    showEditPastHole = true
                } label: {
                    Text("Edit Past Hole").frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            } else {
                Button {
                    showReviewSheet = true
                } label: {
                    Text("Review & Submit").frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(!isScoreFormValid)
            }

            Button {
                nextHole()
            } label: {
                Text("Next Hole").frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .disabled(!holeIsSubmitted || viewModel.currentHole >= 18)
        }
        .padding(.horizontal)
    }

    @ViewBuilder
    private func gamesSection() -> some View {
        if !viewModel.games.isEmpty {
            VStack(spacing: 12) {
                ForEach(viewModel.games.indices, id: \.self) { gi in
                    let game = viewModel.games[gi]
                    gameCard(game: game, gameIndex: gi)
                        .padding(.horizontal)
                }
            }
            .padding(.bottom, 8)
        }
    }

    // Courtesy Press prompts — visible ONLY on 18
    @ViewBuilder
    private func courtesySection() -> some View {
        if viewModel.canShowCourtesyPressUI {
            VStack(spacing: 8) {
                ForEach(viewModel.games.indices, id: \.self) { gi in
                    let g = viewModel.games[gi]
                    if g.teamA.aggregatePoints < g.teamB.aggregatePoints, g.backPressUsedTeamA {
                        CourtesyPressPrompt(
                            gameIndex: gi,
                            winningTeam: g.teamB.teamName,
                            losingTeam: g.teamA.teamName,
                            viewModel: viewModel
                        )
                    } else if g.teamB.aggregatePoints < g.teamA.aggregatePoints, g.backPressUsedTeamB {
                        CourtesyPressPrompt(
                            gameIndex: gi,
                            winningTeam: g.teamA.teamName,
                            losingTeam: g.teamB.teamName,
                            viewModel: viewModel
                        )
                    }
                }
            }
            .padding(.horizontal)
        }
    }

    @ViewBuilder
    private func gameCard(game: Game, gameIndex: Int) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("Game \(gameIndex + 1)")
                    .font(.headline)
                Spacer()
                Text("Stake: $\(game.currentPointValue)")
            }
            Text("\(game.teamA.teamName) vs \(game.teamB.teamName)")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack {
                Text("\(game.teamA.teamName): \(game.teamA.aggregatePoints) pts")
                    .foregroundColor(game.teamA.aggregatePoints < 0 ? .red : .primary)
                Spacer()
                Text("\(game.teamB.teamName): \(game.teamB.aggregatePoints) pts")
                    .foregroundColor(game.teamB.aggregatePoints < 0 ? .red : .primary)
            }
        }
        .padding(12)
        .background(Color.gray.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private func toolbarContent() -> some ToolbarContent {
        ToolbarItemGroup(placement: .topBarLeading) {
            Button {
                undoLastHole()
            } label: {
                Label("Undo Last Hole", systemImage: "arrow.uturn.left")
            }
            .disabled(viewModel.currentHole <= 1)

            Button {
                showEditPastHole = true
            } label: {
                Label("Edit Past Hole", systemImage: "pencil.circle")
            }
        }

        ToolbarItem(placement: .topBarTrailing) {
            Menu {
                Button {
                    showEditPresses = true
                } label: {
                    Label("Edit Presses", systemImage: "bolt.circle")
                }
                Button(role: .destructive) {
                    showRestartConfirm = true
                } label: {
                    Label("Restart Round", systemImage: "gobackward")
                }
                Divider()
                Button { path.append(Screen.scorecard) } label: {
                    Label("Score Card", systemImage: "table")
                }
            } label: {
                Image(systemName: "ellipsis.circle").imageScale(.large)
            }
        }
    }

    // MARK: - Hog Balls overlay (safe ViewBuilder)

    @ViewBuilder
    private func hogOverlayIfNeeded() -> some View {
        if viewModel.hogBallsCount > 0 {
            let message: String = {
                switch viewModel.hogBallsCount {
                case 1: return "Hog Balls!"
                case 2: return "Double Hog Balls!"
                case 3: return "Triple Hog Balls!"
                default: return ""
                }
            }()
            if !message.isEmpty {
                HogBallsCelebrationOverlay(text: message, logo: findHogLogo())
                    .onAppear { playHogSoundIfAvailable() }
            }
        }
    }

    // MARK: - Actions

    private func submitAndScoreTapped() {
        guard isScoreFormValid else {
            validationMessage = "Please enter valid gross scores for all players."
            showValidationAlert = true
            return
        }

        // Freeze currently scheduled stakes for this hole (per game)
        let scheduledForGame = viewModel.games.map { $0.currentPointValue }

        // Convert inputs to Ints
        var ints: [Int] = []
        for i in 0..<viewModel.numPlayers {
            let t = scoreInputs[i].trimmingCharacters(in: .whitespacesAndNewlines)
            if let g = Int(t) { ints.append(g) }
        }

        // Score this hole
        viewModel.submitHoleScores(grossScores: ints)

        // Restore scheduled stake into games (if your scoring mutates it)
        for gi in viewModel.games.indices {
            var g = viewModel.games[gi]
            g.currentPointValue = scheduledForGame[gi]
            viewModel.games[gi] = g
        }

        // Persist contributions/stakes and rebuild aggregates
        viewModel.writeContribForHole(viewModel.currentHole)      // in your Aggregation extension
        viewModel.captureStakeForJustScoredHole()                 // single implementation in your project
        viewModel.recomputeAggregatesFromPerHole()                // in your Aggregation/Replay

        // Cleanup UI
        showReviewSheet = false
        for i in 0..<scoreInputs.count { scoreInputs[i] = "" }
    }

    private func nextHole() {
        viewModel.currentHole = min(viewModel.currentHole + 1, 18)
        refreshScoreInputsFromModel()
    }

    private func undoLastHole() {
        guard viewModel.currentHole > 1 else { return }
        let lastHoleIndex = viewModel.currentHole - 2

        // Remove current-hole contributions from aggregates
        for gi in viewModel.games.indices {
            var g = viewModel.games[gi]
            g.teamA.aggregatePoints -= g.currentHoleContributionForTeamA
            g.teamB.aggregatePoints -= g.currentHoleContributionForTeamB
            g.currentHoleContributionForTeamA = 0
            g.currentHoleContributionForTeamB = 0
            viewModel.games[gi] = g
        }

        // Clear player scores for that hole
        for i in 0..<viewModel.players.count {
            viewModel.players[i].grossScores[lastHoleIndex] = -1
            viewModel.players[i].netScores[lastHoleIndex] = 0
        }

        viewModel.currentHole -= 1
        refreshScoreInputsFromModel()
    }

    private func refreshScoreInputsFromModel() {
        let idx = max(0, min(viewModel.currentHole - 1, 17))
        for i in 0..<scoreInputs.count { scoreInputs[i] = "" }
        for i in 0..<viewModel.numPlayers {
            let gross = viewModel.players[i].grossScores[idx]
            if gross >= 0 { scoreInputs[i] = String(gross) }
        }
    }

    private func focusNext(after index: Int) {
        let next = index + 1
        focusedField = (next < viewModel.numPlayers) ? next : nil
    }

    private func loadHogSound() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch { }

        for name in hogAudioCandidates {
            if let url = Bundle.main.url(forResource: name, withExtension: "mp3") {
                do {
                    hogSound = try AVAudioPlayer(contentsOf: url)
                    hogSound?.prepareToPlay()
                    return
                } catch { }
            }
        }
    }

    private func playHogSoundIfAvailable() {
        if hogSound == nil { loadHogSound() }
        hogSound?.play()
    }

    private func findHogLogo() -> UIImage? {
        for name in hogLogoCandidates {
            if let img = UIImage(named: name) { return img }
        }
        return nil
    }
}

// MARK: - Overlay view

private struct HogBallsCelebrationOverlay: View {
    let text: String
    let logo: UIImage?

    var body: some View {
        VStack(spacing: 14) {
            if let logo {
                Image(uiImage: logo)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 180, height: 180)
            }
            Text(text)
                .font(.largeTitle.bold())
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(.thinMaterial, in: Capsule())
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.25).ignoresSafeArea())
        .transition(.opacity)
    }
}

// MARK: - Courtesy prompt (inline; avoids external dependency)
private struct CourtesyPressPrompt: View {
    let gameIndex: Int
    let winningTeam: String
    let losingTeam: String
    @ObservedObject var viewModel: GolfGameViewModel

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading) {
                Text("Courtesy press for \(losingTeam)?")
                    .font(.subheadline.bold())
                Text("Double the stake on 18 vs \(winningTeam).")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Button("Apply") {
                viewModel.grantCourtesyPress(forGameIndex: gameIndex)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(12)
        .background(Color.yellow.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
