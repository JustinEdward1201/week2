import SwiftUI

struct ComputerLabView: View {
    @Binding var computers: [Computer]

    private enum Route: Hashable { case add, check, statistics }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Label("Manage computers easily", systemImage: "desktopcomputer")
                        .font(.headline)
                        .foregroundStyle(.blue)
                }
                Section("Computers") {
                    if computers.isEmpty {
                        Text("No computers yet. Tap Add Computer to get started.")
                            .foregroundStyle(.secondary)
                    }
                    ForEach(computers) { computer in
                        ComputerRow(computer: computer)
                    }
                    .onDelete { computers.remove(atOffsets: $0) }
                }
                Section {
                    NavigationLink(value: Route.add) {
                        Label("Add Computer", systemImage: "plus.circle.fill")
                    }
                    NavigationLink(value: Route.check) {
                        Label("Check Computer", systemImage: "magnifyingglass")
                    }
                    NavigationLink(value: Route.statistics) {
                        Label("Statistics", systemImage: "chart.bar.fill")
                    }
                } footer: {
                    Text("Total computers: \(computers.count)")
                        .accessibilityIdentifier("computerTotal")
                }
            }
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .add: AddComputerView(computers: $computers)
                case .check: CheckComputerView(computers: computers)
                case .statistics: StatisticsView(computers: computers)
                }
            }
            .navigationTitle("Computer Lab")
            .toolbar { EditButton().disabled(computers.isEmpty) }
        }
    }
}

struct ComputerRow: View {
    let computer: Computer

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "desktopcomputer")
                .foregroundStyle(.blue)
            VStack(alignment: .leading) {
                Text(computer.name).font(.headline)
                Text(computer.location).font(.subheadline).foregroundStyle(.secondary)
            }
            Spacer()
            Label(computer.isAvailable ? "Available" : "In Use",
                  systemImage: computer.isAvailable ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.caption)
                .foregroundStyle(computer.isAvailable ? .green : .red)
        }
    }
}

struct AddComputerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var computers: [Computer]
    @State private var computerName = ""
    @State private var location = "Lab A"
    @State private var isAvailable = true

    private var validationMessage: String? {
        Computer.validationMessage(name: computerName, location: location, computers: computers)
    }

    var body: some View {
        Form {
            Section("Computer details") {
                TextField("Computer name (e.g. PC06)", text: $computerName)
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled()
                    .accessibilityIdentifier("computerName")
                TextField("Location (e.g. Lab A)", text: $location)
                    .accessibilityIdentifier("computerLocation")
                Toggle("Available", isOn: $isAvailable)
            }
            Section {
                Button("Add") {
                    guard validationMessage == nil else { return }
                    // append adds a new element and updates the parent's list and count.
                    computers.append(Computer(
                        name: computerName.trimmingCharacters(in: .whitespacesAndNewlines),
                        location: location.trimmingCharacters(in: .whitespacesAndNewlines),
                        isAvailable: isAvailable
                    ))
                    dismiss()
                }
                .disabled(validationMessage != nil)
                .accessibilityIdentifier("saveComputer")
            } footer: {
                if let validationMessage { Text(validationMessage) }
            }
        }
        .navigationTitle("Add Computer")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct CheckComputerView: View {
    let computers: [Computer]
    @State private var name = ""
    @State private var checkedName: String?

    var body: some View {
        Form {
            Section("Find a computer") {
                TextField("Computer name (e.g. PC03)", text: $name)
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled()
                    .accessibilityIdentifier("checkComputerName")
                    .onChange(of: name) { checkedName = nil }
                Button("Check") {
                    checkedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
                }
                .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            if let checkedName {
                Section("Result") {
                    // contains(where:) searches an array of structs by name.
                    let exists = computers.contains {
                        $0.name.caseInsensitiveCompare(checkedName) == .orderedSame
                    }
                    Label(exists ? "\(checkedName) is in the lab!" : "\(checkedName) is not in the lab!",
                          systemImage: exists ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundStyle(exists ? .green : .red)
                        .accessibilityIdentifier("computerSearchResult")
                }
            }
        }
        .navigationTitle("Check Computer")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct StatisticsView: View {
    let computers: [Computer]

    var body: some View {
        List {
            Section("Summary") {
                LabeledContent("Total Computers", value: "\(computers.count)")
                LabeledContent("Available", value: "\(computers.filter { $0.isAvailable }.count)")
                LabeledContent("In Use", value: "\(computers.filter { !$0.isAvailable }.count)")
            }
            Section("Computer List") {
                if computers.isEmpty { Text("No computers in the lab.") }
                ForEach(computers) { ComputerRow(computer: $0) }
            }
        }
        .navigationTitle("Statistics")
        .navigationBarTitleDisplayMode(.inline)
    }
}
