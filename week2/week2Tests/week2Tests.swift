import Testing
@testable import week2

@MainActor
struct week2Tests {
    @Test func computerSampleDataAndValidation() {
        let computers = Computer.samples
        #expect(computers.count == 5)
        #expect(computers.filter { $0.isAvailable }.count == 4)
        #expect(Computer.validationMessage(name: " pc01 ", location: "Lab B", computers: computers) != nil)
        #expect(Computer.validationMessage(name: " \n", location: "Lab A", computers: computers) != nil)
        #expect(Computer.validationMessage(name: "PC06", location: " ", computers: computers) != nil)
        #expect(Computer.validationMessage(name: "PC06", location: "Lab C", computers: computers) == nil)
    }

    @Test func studentSearchFilterAndSort() {
        let students = Student.samples
        #expect(students.matching(" s003 ").map(\.name) == ["Chi"])
        #expect(students.matching("BINH").map(\.id) == ["S002"])
        #expect(students.matching("missing").isEmpty)
        #expect(students.matching("", highGPAOnly: true).map(\.id) == ["S001", "S002", "S004", "S005"])
        #expect(students.matching("", sortedByGPA: true).map(\.id) == ["S004", "S002", "S001", "S005", "S003"])
        #expect(students.map(\.id) == ["S001", "S002", "S003", "S004", "S005"])
    }

    @Test func highestGPAHandlesEmptyAndTiedScores() {
        #expect([Student]().highestGPAStudents.isEmpty)
        let students = [Student(id: "A", name: "An", gpa: 9),
                        Student(id: "B", name: "Binh", gpa: 8),
                        Student(id: "C", name: "Chi", gpa: 9)]
        #expect(students.highestGPAStudents.map(\.id) == ["A", "C"])
    }

    @Test func studentInputValidation() {
        for invalid in ["", "abc", "nan", "inf", "-1", "10.1"] {
            #expect(Student.validationMessage(id: "S006", name: "Mai", gpaText: invalid,
                                              students: Student.samples) != nil)
        }
        for valid in ["0", "10", "8.5", "8,5"] {
            #expect(Student.validationMessage(id: "S006", name: "Mai", gpaText: valid,
                                              students: Student.samples) == nil)
        }
        #expect(Student.validationMessage(id: " s001 ", name: "Mai", gpaText: "8",
                                          students: Student.samples) != nil)
        #expect(Student.validationMessage(id: "S001", name: "An", gpaText: "9.2",
                                          students: Student.samples, editingID: "S001") == nil)
        #expect(Student.validationMessage(id: " ", name: "An", gpaText: "8", students: []) != nil)
        #expect(Student.validationMessage(id: "S006", name: " ", gpaText: "8", students: []) != nil)
    }
}
