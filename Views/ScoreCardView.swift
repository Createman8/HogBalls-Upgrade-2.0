//Updated 9/6/25
///
//
//  ScoreCardView.swift
//  GolfScoreApp
//

import SwiftUI

struct ScoreCardView: View {
    @ObservedObject var viewModel: GolfGameViewModel

    // Layout
    private let holeColWidth: CGFloat = 120
    private let playerColWidth: CGFloat = 88
    private let rowHeight: CGFloat = 44

    // Styling
    private let headerBG  = Color.black.opacity(0.9)
    private let headerFG  = Color.white
    private let cellStroke = Color.white.opacity(0.55)
    private let subtotalBG = Color(.sRGB, red: 0.45, green: 0.37, blue: 0.15, opacity: 0.85) // warm gold
    private let tableBorder = Color.white.opacity(0.35)
    private let bodyFG = Color.white
    private let altRowBG = Color.black.opacity(0.55)
    private let baseRowBG = Color.black.opacity(0.35)

    private let frontRange = 0..<9
    private let backRange  = 9..<18

    var body: some View {
        ScrollView([.vertical, .horizontal]) {
            VStack(spacing: 0) {
                // Header row
                HStack(spacing: 0) {
                    headerCell("Hole", width: holeColWidth)

                    ForEach(0..<viewModel.numPlayers, id: \.self) { i in
                        let title = playerName(i)
                        headerCell(title, width: playerColWidth)
                    }
                }
                .background(headerBG)

                // Hole rows 1–9
                ForEach(frontRange, id: \.self) { idx in
                    holeRow(holeIndex: idx)
                        .background(idx.isMultiple(of: 2) ? baseRowBG : altRowBG)
                }

                // Front subtotal
                subtotalRow(label: "Front", range: frontRange)
                    .background(subtotalBG)

                // Hole rows 10–18
                ForEach(backRange, id: \.self) { idx in
                    holeRow(holeIndex: idx)
                        .background(idx.isMultiple(of: 2) ? baseRowBG : altRowBG)
                }

                // Back subtotal
                subtotalRow(label: "Back", range: backRange)
                    .background(subtotalBG)

                // Grand total
                totalRow(label: "Total", front: frontRange, back: backRange)
                    .background(subtotalBG.opacity(0.95))
            }
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(tableBorder, lineWidth: 0.8)
            )
            .padding(.horizontal, 12)
            .padding(.vertical, 12)
        }
        .background(Color.black.ignoresSafeArea())
        .navigationTitle("Score Card")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Rows

    private func holeRow(holeIndex idx: Int) -> some View {
        HStack(spacing: 0) {
            // Left: hole label (add handicap here later if you want)
            bodyCell("Hole #\(idx + 1)", width: holeColWidth, height: rowHeight, weight: .bold, align: .leading)

            // One cell per player: "gross/net"
            ForEach(0..<viewModel.numPlayers, id: \.self) { pIndex in
                let display = grossNetString(playerIndex: pIndex, holeIdx: idx)
                bodyCell(display, width: playerColWidth, height: rowHeight, align: .center)
            }
        }
        .overlay(Rectangle().stroke(cellStroke, lineWidth: 0.6))
    }

    private func subtotalRow(label: String, range: Range<Int>) -> some View {
        HStack(spacing: 0) {
            bodyCell(label, width: holeColWidth, height: rowHeight, weight: .bold, align: .leading)

            ForEach(0..<viewModel.numPlayers, id: \.self) { pIndex in
                let (g, n) = subtotalForPlayer(pIndex, range: range)
                let text = (g != nil || n != nil) ? "\(g ?? 0)/\(n ?? 0)" : "—"
                bodyCell(text, width: playerColWidth, height: rowHeight, weight: .semibold, align: .center)
            }
        }
        .overlay(Rectangle().stroke(cellStroke, lineWidth: 0.6))
    }

    private func totalRow(label: String, front: Range<Int>, back: Range<Int>) -> some View {
        HStack(spacing: 0) {
            bodyCell(label, width: holeColWidth, height: rowHeight, weight: .bold, align: .leading)

            ForEach(0..<viewModel.numPlayers, id: \.self) { pIndex in
                let (gF, nF) = subtotalForPlayer(pIndex, range: front)
                let (gB, nB) = subtotalForPlayer(pIndex, range: back)
                let gTot = (gF ?? 0) + (gB ?? 0)
                let nTot = (nF ?? 0) + (nB ?? 0)
                let any = (gF != nil || nF != nil || gB != nil || nB != nil)
                let text = any ? "\(gTot)/\(nTot)" : "—"
                bodyCell(text, width: playerColWidth, height: rowHeight, weight: .bold, align: .center)
            }
        }
        .overlay(Rectangle().stroke(cellStroke, lineWidth: 0.6))
    }

    // MARK: - Cells

    private enum Weight { case regular, semibold, bold }

    private func headerCell(_ text: String, width: CGFloat) -> some View {
        Text(text)
            .font(.headline.weight(.bold))
            .foregroundStyle(headerFG)
            .frame(width: width, height: rowHeight)
            .overlay(Rectangle().stroke(cellStroke, lineWidth: 0.8))
    }

    private func bodyCell(_ text: String,
                          width: CGFloat,
                          height: CGFloat,
                          weight: Weight = .regular,
                          align: Alignment = .center) -> some View {
        let font: Font = {
            switch weight {
            case .regular:  return .title3.weight(.regular)
            case .semibold: return .title3.weight(.semibold)
            case .bold:     return .title3.weight(.bold)
            }
        }()

        return Text(text)
            .font(font)
            .foregroundStyle(bodyFG)
            .minimumScaleFactor(0.6)
            .lineLimit(1)
            .monospacedDigit()
            .frame(width: width, height: height, alignment: align)
    }

    // MARK: - Helpers

    private func playerName(_ index: Int) -> String {
        guard viewModel.players.indices.contains(index) else { return "Player \(index + 1)" }
        return viewModel.players[index].name
    }

    private func grossNetString(playerIndex: Int, holeIdx: Int) -> String {
        guard viewModel.players.indices.contains(playerIndex) else { return "—" }
        let p = viewModel.players[playerIndex]
        let g = p.grossScores[holeIdx]
        if g < 0 { return "—" }
        let n = p.netScores[holeIdx]
        return "\(g)/\(n)"
    }

    /// Returns (gross subtotal, net subtotal) for a player in a hole range.
    /// Gross ignores -1 (no score). Net included only when there is a real gross.
    private func subtotalForPlayer(_ playerIndex: Int, range: Range<Int>) -> (Int?, Int?) {
        guard viewModel.players.indices.contains(playerIndex) else { return (nil, nil) }
        let p = viewModel.players[playerIndex]

        var any = false
        var gSum = 0
        var nSum = 0

        for idx in range {
            let g = p.grossScores[idx]
            if g >= 0 {
                any = true
                gSum += g
                nSum += p.netScores[idx]
            }
        }
        return any ? (gSum, nSum) : (nil, nil)
    }
}


