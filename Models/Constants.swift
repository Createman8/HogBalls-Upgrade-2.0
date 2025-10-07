//
// Models/Constants.swift
import Foundation

let holeAdjustments: [Int: HoleAdjustment] = [
    1:  HoleAdjustment(holeNumber: 1, subtractOneMin: 7,  subtractTwoThreshold: 24, addOneThreshold: -12),
    2:  HoleAdjustment(holeNumber: 2, subtractOneMin: 11, subtractTwoThreshold: 28, addOneThreshold: -8),
    3:  HoleAdjustment(holeNumber: 3, subtractOneMin: 15, subtractTwoThreshold: 32, addOneThreshold: -4),
    4:  HoleAdjustment(holeNumber: 4, subtractOneMin: 3,  subtractTwoThreshold: 20, addOneThreshold: -16),
    5:  HoleAdjustment(holeNumber: 5, subtractOneMin: 13, subtractTwoThreshold: 30, addOneThreshold: -6),
    6:  HoleAdjustment(holeNumber: 6, subtractOneMin: 1,  subtractTwoThreshold: 18, addOneThreshold: -18),
    7:  HoleAdjustment(holeNumber: 7, subtractOneMin: 5,  subtractTwoThreshold: 22, addOneThreshold: -14),
    8:  HoleAdjustment(holeNumber: 8, subtractOneMin: 17, subtractTwoThreshold: 34, addOneThreshold: -2),
    9:  HoleAdjustment(holeNumber: 9, subtractOneMin: 9,  subtractTwoThreshold: 26, addOneThreshold: -10),
    10: HoleAdjustment(holeNumber: 10, subtractOneMin: 6, subtractTwoThreshold: 23, addOneThreshold: -13),
    11: HoleAdjustment(holeNumber: 11, subtractOneMin: 14, subtractTwoThreshold: 31, addOneThreshold: -5),
    12: HoleAdjustment(holeNumber: 12, subtractOneMin: 18, subtractTwoThreshold: 35, addOneThreshold: -1),
    13: HoleAdjustment(holeNumber: 13, subtractOneMin: 4, subtractTwoThreshold: 21, addOneThreshold: -15),
    14: HoleAdjustment(holeNumber: 14, subtractOneMin: 8, subtractTwoThreshold: 25, addOneThreshold: -11),
    15: HoleAdjustment(holeNumber: 15, subtractOneMin: 2, subtractTwoThreshold: 19, addOneThreshold: -17),
    16: HoleAdjustment(holeNumber: 16, subtractOneMin: 12, subtractTwoThreshold: 29, addOneThreshold: -7),
    17: HoleAdjustment(holeNumber: 17, subtractOneMin: 10, subtractTwoThreshold: 27, addOneThreshold: -9),
    18: HoleAdjustment(holeNumber: 18, subtractOneMin: 16, subtractTwoThreshold: 33, addOneThreshold: -3)
]

let fixedHoleHandicaps: [Int] = [7, 11, 15, 3, 13, 1, 5, 17, 9, 6, 14, 18, 4, 8, 2, 12, 10, 16]
