import SwiftUI

struct StudentListView: View {
    @Binding var students: [Student]
    @State private var searchText = ""
    @State private var highGPAOnly = false
    @State private var sortedByGPA = false

    private enum Route: Hashable { case add, edit(String), statistics }

    private var visibleStudents: [Student] {
        students.matching(searchText, highGPAOnly: highGPAOnly, sortedByGPA: sortedByGPA)
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Label("A better class, a brighter tomorrow", systemImage: "person.3.fill")
                        .foregroundStyle(.blue)
                    Toggle("GPA ≥ 8.0 only", isOn: $highGPAOnly)
                        .accessibilityIdentifier("highGPAOnly")
                    Toggle("Sort by GPA (highest first)", isOn: $sortedByGPA)
                }
                Section {
                    if visibleStudents.isEmpty {
                        Text(students.isEmpty ? "No students yet. Add your first student." : "No matching students.")
                            .foregroundStyle(.secondary)
                    }
                    ForEach(visibleStudents) { student in
                        NavigationLink(value: Route.edit(student.id)) {
                            StudentRow(student: student)
                        }
                        .accessibilityIdentifier("student-\(student.id)")
                    }
                    .onDelete(perform: removeStudents)
                } header: {
                    Text("Students (\(visibleStudents.count) shown)")
                } footer: {
                    Text("Total students: \(students.count)")
                        .accessibilityIdentifier("studentTotal")
                }
                Section {
                    NavigationLink(value: Route.add) {
                        Label("Add Student", systemImage: "plus.circle.fill")
                    }
                    NavigationLink(value: Route.statistics) {
                        Label("Student Statistics", systemImage: "chart.bar.fill")
                    }
                }
            }
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .add: StudentEditorView(students: $students)
                case .edit(let id):
                    if let student = students.first(where: { $0.id == id }) {
                        StudentEditorView(students: $students, student: student)
                    }
                case .statistics: StudentStatisticsView(students: students)
                }
            }
            .navigationTitle("Student Manager")
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always),
                        prompt: "Search by name or ID")
            .toolbar { EditButton().disabled(students.isEmpty) }
        }
    }

    private func removeStudents(at offsets: IndexSet) {
        // Filtered/sorted row offsets differ from the source array: delete by ID.
        let ids = offsets.map { visibleStudents[$0].id }
        students.removeAll { ids.contains($0.id) }
    }
}

struct StudentRow: View {
    let student: Student

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "person.crop.circle.fill")
                .font(.title2)
                .foregroundStyle(.blue)
            VStack(alignment: .leading) {
                Text(student.name).font(.headline)
                Text(student.id).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            Text("GPA: \(student.gpa.formatted(.number.precision(.fractionLength(1...2))))")
                .font(.subheadline)
        }
    }
}

struct StudentEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var students: [Student]
    private let editingID: String?
    @State private var studentID: String
    @State private var name: String
    @State private var gpaText: String
    @State private var confirmingDelete = false

    init(students: Binding<[Student]>, student: Student? = nil) {
        _students = students
        editingID = student?.id
        _studentID = State(initialValue: student?.id ?? "")
        _name = State(initialValue: student?.name ?? "")
        _gpaText = State(initialValue: student.map { String($0.gpa) } ?? "")
    }

    private var validationMessage: String? {
        Student.validationMessage(id: studentID, name: name, gpaText: gpaText,
                                  students: students, editingID: editingID)
    }

    var body: some View {
        Form {
            Section("Student details") {
                TextField("Student ID (e.g. S006)", text: $studentID)
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled()
                    .disabled(editingID != nil)
                    .accessibilityIdentifier("studentID")
                TextField("Name", text: $name)
                    .textInputAutocapitalization(.words)
                    .accessibilityIdentifier("studentName")
                TextField("GPA (0–10)", text: $gpaText)
                    .keyboardType(.decimalPad)
                    .accessibilityIdentifier("studentGPA")
            }
            Section {
                Button(editingID == nil ? "Add Student" : "Save Changes", action: save)
                    .disabled(validationMessage != nil)
                    .accessibilityIdentifier("saveStudent")
            } footer: {
                if let validationMessage { Text(validationMessage) }
            }
            if editingID != nil {
                Section {
                    Button("Remove Student", role: .destructive) { confirmingDelete = true }
                }
            }
        }
        .navigationTitle(editingID == nil ? "Add Student" : "Edit Student")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog("Remove this student?", isPresented: $confirmingDelete, titleVisibility: .visible) {
            Button("Remove Student", role: .destructive) {
                students.removeAll { $0.id == editingID }
                dismiss()
            }
        }
    }

    private func save() {
        guard validationMessage == nil, let gpa = Student.parseGPA(gpaText) else { return }
        let student = Student(
            id: studentID.trimmingCharacters(in: .whitespacesAndNewlines),
            name: name.trimmingCharacters(in: .whitespacesAndNewlines), gpa: gpa
        )
        if let editingID {
            // firstIndex locates the original element even when the list was sorted.
            guard let index = students.firstIndex(where: { $0.id == editingID }) else { return }
            students[index] = student
        } else {
            students.append(student)
        }
        dismiss()
    }
}

struct StudentStatisticsView: View {
    let students: [Student]

    var body: some View {
        List {
            Section("Summary") {
                LabeledContent("Total Students", value: "\(students.count)")
                if !students.isEmpty {
                    let average = students.reduce(0) { $0 + $1.gpa } / Double(students.count)
                    LabeledContent("Average GPA", value: average.formatted(.number.precision(.fractionLength(2))))
                }
            }
            Section("Highest GPA") {
                if students.isEmpty { Text("No students yet.") }
                ForEach(students.highestGPAStudents) { StudentRow(student: $0) }
            }
            Section("GPA ≥ 8.0") {
                let qualifying = students.matching("", highGPAOnly: true, sortedByGPA: true)
                if qualifying.isEmpty { Text("No students with GPA ≥ 8.0.") }
                ForEach(qualifying) { StudentRow(student: $0) }
            }
        }
        .navigationTitle("Student Statistics")
        .navigationBarTitleDisplayMode(.inline)
    }
}
