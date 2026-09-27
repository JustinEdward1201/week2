import Foundation

// Slides 11–14: a struct keeps each computer's information together.
struct Computer: Identifiable {
    let id = UUID()
    var name: String
    var location: String
    var isAvailable: Bool

    static let samples = [
        Computer(name: "PC01", location: "Lab A", isAvailable: true),
        Computer(name: "PC02", location: "Lab A", isAvailable: true),
        Computer(name: "PC03", location: "Lab B", isAvailable: false),
        Computer(name: "PC04", location: "Lab B", isAvailable: true),
        Computer(name: "PC05", location: "Lab C", isAvailable: true)
    ]

    static func validationMessage(name: String, location: String, computers: [Computer]) -> String? {
        let name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { return "Enter a computer name." }
        guard !location.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return "Enter a location."
        }
        guard !computers.contains(where: { $0.name.caseInsensitiveCompare(name) == .orderedSame }) else {
            return "A computer with this name already exists."
        }
        return nil
    }
}
