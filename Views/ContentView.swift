//updated with new changes 9/2/25
//  ContentView.swift
//  GolfScoreApp
//

//
//  ContentView.swift
//  GolfScoreApp
//

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = GolfGameViewModel()
    @State var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            StartupView(path: $path)
                .navigationDestination(for: Screen.self) { screen in
                    switch screen {
                    case .startup:
                        StartupView(path: $path)

                    case .setup:
                        SetupView(viewModel: viewModel, path: $path)

                    case .playerWizard:
                        PlayerWizardView(viewModel: viewModel, path: $path)

                    case .score:
                        ScoreView(viewModel: viewModel, path: $path)

                    case .review:
                        PlayerScoreReviewView(viewModel: viewModel, path: $path)

                    case .result:
                        HoleResultView(
                            viewModel: viewModel,
                            completedHole: viewModel.currentHole,
                            path: $path
                        )

                    case .summary:
                        SummaryView(viewModel: viewModel, path: $path)

                    case .scorecard:
                        ScoreCardView(viewModel: viewModel)

                    case .finalTally:
                        FinalTallyView(viewModel: viewModel, path: $path)

                    case .rules:
                        RulesView()

                    case .instructions:
                        InstructionsView()
                    }
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
