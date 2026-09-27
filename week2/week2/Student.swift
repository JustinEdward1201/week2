import Foundation

// Slides 17–20 use a String ID and a GPA on a 0–10 scale.
struct Student: Identifiable, Equatable {
    var id: String
    var name: String
    var gpa: Double

    static let samples = [
        Student(id: "S001", name: "An", gpa: 8.5),
        Student(id: "S002", name: "Binh", gpa: 9.0),
        Student(id: "S003", name: "Chi", gpa: 7.8),
        Student(id: "S004", name: "Duy", gpa: 9.2),
        Student(id: "S005", name: "Lan", gpa: 8.0)
    ]

    static func validationMessage(id: String, name: String, gpaText: String,
                                  students: [Student], editingID: String? = nil) -> String? {
        let id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !id.isEmpty else { return "Enter a student ID." }
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return "Enter a student name."
        }
        guard let gpa = parseGPA(gpaText), gpa.isFinite, (0...10).contains(gpa) else {
            return "Enter a GPA between 0 and 10."
        }
        guard !students.contains(where: {
            $0.id != editingID && $0.id.caseInsensitiveCompare(id) == .orderedSame
        }) else { return "A student with this ID already exists." }
        return nil
    }

    static func parseGPA(_ text: String) -> Double? {
        Double(text.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: ",", with: "."))
    }
}

// These operations leave the original array's order intact until a user edits it.
extension Array where Element == Student {
    func matching(_ query: String, highGPAOnly: Bool = false, sortedByGPA: Bool = false) -> [Student] {
        let query = query.trimmingCharacters(in: .whitespacesAndNewlines)
        let result = filter { student in
            (query.isEmpty || student.name.localizedCaseInsensitiveContains(query)
                || student.id.localizedCaseInsensitiveContains(query))
                && (!highGPAOnly || student.gpa >= 8.0)
        }
        return sortedByGPA ? result.sorted {
            $0.gpa == $1.gpa ? $0.id < $1.id : $0.gpa > $1.gpa
        } : result
    }

    var highestGPAStudents: [Student] {
        guard let highest = map(\.gpa).max() else { return [] }
        return filter { $0.gpa == highest }
    }
}
