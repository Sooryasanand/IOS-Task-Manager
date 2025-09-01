//
//  AddTaskSheet.swift
//  TaskManager
//
//  Created by Soorya Narayanan Sanand on 1/9/2025.
//

import SwiftUI

struct AddTaskSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title: String = ""
    @State private var detail: String = ""
    @State private var category: TaskCategory = .personal
    @State private var priority: TaskPriority = .medium
    @State private var dueAt: Date? = nil

    var onCreate: (String, String?, TaskCategory, TaskPriority, Date?) -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section { TextField("Title", text: $title) }
                Section("Details") { TextField("Optional detail", text: $detail) }
                Section("Meta") {
                    Picker("Category", selection: $category) {
                        ForEach(TaskCategory.allCases, id: \.self) { Text($0.rawValue.capitalized).tag($0) }
                    }
                    Picker("Priority", selection: $priority) {
                        ForEach(TaskPriority.allCases, id: \.self) { Text($0.rawValue.capitalized).tag($0) }
                    }
                    Toggle("Has due date", isOn: Binding(get: { dueAt != nil }, set: { has in dueAt = has ? Date().addingTimeInterval(3600) : nil }))
                    if let due = dueAt {
                        DatePicker("Due", selection: Binding(get: { due }, set: { dueAt = $0 }), displayedComponents: [.date, .hourAndMinute])
                    }
                }
            }
            .navigationTitle("New Task")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") { onCreate(title, detail.isEmpty ? nil : detail, category, priority, dueAt); dismiss() }
                        .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}
