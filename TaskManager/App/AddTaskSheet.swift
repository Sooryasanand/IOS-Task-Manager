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

    private var trimmedTitle: String {
        self.title.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    private var titleError: String? {
        self.trimmedTitle.isEmpty ? "Title can’t be empty." : nil
    }
    private var dueError: String? {
        if let d = dueAt, d < Date() { return "Due date can’t be in the past." }
        return nil
    }

    private var hasErrors: Bool {
        self.titleError != nil || self.dueError != nil
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Title", text: self.$title)
                    if let err = titleError {
                        Text(err).font(.footnote).foregroundStyle(.red)
                    }
                }

                Section("Details") {
                    TextField("Optional detail", text: self.$detail)
                }

                Section("Meta") {
                    Picker("Category", selection: self.$category) {
                        ForEach(TaskCategory.allCases, id: \.self) {
                            Text($0.rawValue.capitalized).tag($0)
                        }
                    }
                    Picker("Priority", selection: self.$priority) {
                        ForEach(TaskPriority.allCases, id: \.self) {
                            Text($0.rawValue.capitalized).tag($0)
                        }
                    }

                    Toggle(
                        "Has due date",
                        isOn: Binding(
                            get: { self.dueAt != nil },
                            set: { has in
                                self.dueAt =
                                    has ? Date().addingTimeInterval(3600) : nil
                            }
                        )
                    )

                    if let due = dueAt {
                        DatePicker(
                            "Due",
                            selection: Binding(
                                get: { due },
                                set: { self.dueAt = $0 }
                            ),
                            in: Date()...,
                            displayedComponents: [.date, .hourAndMinute]
                        )
                        if let err = dueError {
                            Text(err).font(.footnote).foregroundStyle(.red)
                        }
                    }
                }
            }
            .navigationTitle("New Task")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { self.dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        self.onCreate(
                            self.trimmedTitle,
                            self.detail.isEmpty ? nil : self.detail,
                            self.category,
                            self.priority,
                            self.dueAt
                        )
                        self.dismiss()
                    }
                    .disabled(self.hasErrors)
                }
            }
        }
    }
}
