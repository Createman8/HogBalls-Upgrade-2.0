//
//  Course.swift
//  GolfScoreApp
//
//  Created by joe stewart on 9/2/25.
//

import Foundation
import Foundation

struct HoleInfo: Codable, Hashable {
    let number: Int            // 1...18
    let par: Int               // 3/4/5
    let handicap: Int          // 1...18 (1 = hardest)
    let yardages: [String:Int] // tee name -> yards
}

struct TeeSet: Codable, Hashable {
    let name: String
    let rating: Double?
    let slope: Int?
}

struct Course: Codable, Hashable, Identifiable {
    let id: UUID
    let name: String
    let holes: [HoleInfo]
    let tees: [TeeSet]
    let defaultTee: String

    init(id: UUID = UUID(), name: String, holes: [HoleInfo], tees: [TeeSet], defaultTee: String) {
        self.id = id
        self.name = name
        self.holes = holes
        self.tees = tees
        self.defaultTee = defaultTee
    }

    /// 1-based hole handicap array (index 0 == hole 1)
    var holeHandicaps: [Int] {
        holes.sorted { $0.number < $1.number }.map { $0.handicap }
    }

    var parFront: Int { holes.filter { $0.number <= 9  }.reduce(0) { $0 + $1.par } }
    var parBack:  Int { holes.filter { $0.number >= 10 }.reduce(0) { $0 + $1.par } }
    var parTotal: Int { parFront + parBack }
}
