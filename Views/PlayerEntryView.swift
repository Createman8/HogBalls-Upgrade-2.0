//
//  PlayerEntryView.swift
//  GolfScoreApp
//
//  Created by joe stewart on 3/15/25.
//

import SwiftUI

struct PlayerEntryView: View {
    @Binding var playerName: String
    @ObservedObject var library: PlayerLibrary
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Enter Player Name")
                .font(.title2)
                .padding(.bottom, 5)
            
            TextField("Player Name", text: $playerName)
                .font(.title)
                .padding()
                .background(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 2))
            
            // Auto-complete suggestions based on library entries
            if !playerName.isEmpty {
                List {
                    ForEach(library.players.filter { $0.lowercased().contains(playerName.lowercased()) }, id: \.self) { name in
                        Text(name)
                            .onTapGesture {
                                playerName = name
                            }
                    }
                }
                .frame(maxHeight: 150)
            }
        }
        .padding()
    }
}

