//
//  CourseLibrary.swift
//  GolfScoreApp
//
//  Created by joe stewart on 9/2/25.
//

import Foundation
import Foundation

/// Holds the list of courses available in the app.
/// Ships with a default Bloomington CC so the app works out of the box.
final class CourseLibrary: ObservableObject {
    @Published private(set) var courses: [Course] = []

    init() {
        loadDefaults()
        // If you later add JSON files in a bundled "Courses" folder, you can also call:
        // loadBundledCourses()
    }

    /// Hard-coded starter course (update yardages/pars when you have the real ones).
    func loadDefaults() {
        // Example pars and hole handicap ranks (1 = hardest, 18 = easiest)
        let pars   = [4,4,4,4,4,4,4,3,4, 4,4,3,4,4,5,4,3,5]
        let ranks  = [7,11,15,3,13,1,5,17,9, 6,14,18,4,8,2,12,10,16]

        let holes: [HoleInfo] = (1...18).map { n in
            HoleInfo(
                number: n,
                par: pars[n-1],
                handicap: ranks[n-1],      // 1 = hardest … 18 = easiest
                yardages: [
                    "White": 350,          // placeholder yardages; edit anytime
                    "Blue":  370,
                    "Gold":  330
                ]
            )
        }

        let tees: [TeeSet] = [
            TeeSet(name: "White", rating: 69.5, slope: 125),
            TeeSet(name: "Blue",  rating: 71.2, slope: 130),
            TeeSet(name: "Gold",  rating: 68.0, slope: 120),
        ]

        let bcc = Course(
            name: "Bloomington Country Club",
            holes: holes,
            tees: tees,
            defaultTee: "White"
        )

        self.courses = [bcc]
    }

    // MARK: - Optional: load additional courses from a bundled "Courses" folder

    func loadBundledCourses() {
        guard let urls = Bundle.main.urls(forResourcesWithExtension: "json", subdirectory: "Courses") else { return }
        for url in urls {
            if let course = try? loadCourse(from: url) {
                courses.append(course)
            }
        }
    }

    func loadCourse(from url: URL) throws -> Course {
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(Course.self, from: data)
    }

    func add(_ course: Course) { courses.append(course) }
}
