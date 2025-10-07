//This version should be the hogballs logo on entry, Hog Balls overlay, courtesy press
// Tested ok, needs a few different cards to review 3/30
// Saved as Hog Balls 3 on 1TB Hardrive before the changes making on 4/6 for error handling and
// Back score verification
// Oct 7, 2025 changes for audio, back button and press fixes.
//
// Views/StartupView.swift
import SwiftUI




struct StartupView: View {
    @Binding var path: NavigationPath
    
    var body: some View {
        VStack(spacing: 20) {
            Image("BCC")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 320)
            Text("5 Point Low Ball/Low Total Game")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            HStack(spacing: 20) {
                NavigationLink("Rules", value: Screen.rules)
                    .buttonStyle(.borderedProminent)
                NavigationLink("Instructions", value: Screen.instructions)
                    .buttonStyle(.borderedProminent)
                NavigationLink("Next", value: Screen.setup)
                    .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack {
                    Spacer().frame(height: 52)
                    Text("Hog")
                        .font(.system(size: 42))
                        .fontWeight(.bold)
                    Text("Balls")
                        .font(.system(size: 42))
                        .fontWeight(.bold)
                }
                .multilineTextAlignment(.center)
            }
        }
    }
}
