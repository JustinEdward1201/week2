import SwiftUI

struct ContentView: View {
    // The parent owns the arrays. Child views edit the same data through @Binding.
    @State private var computers = Computer.samples
    @State private var students = Student.samples

    var body: some View {
        TabView {
            ComputerLabView(computers: $computers)
                .tabItem { Label("Computer Lab", systemImage: "desktopcomputer") }
            StudentListView(students: $students)
                .tabItem { Label("Students", systemImage: "person.3.fill") }
        }
    }
}

#Preview {
    ContentView()
}
