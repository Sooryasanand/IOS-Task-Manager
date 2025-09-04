//
//  TaskListDetail.swift
//  TaskManager
//
//  Created by Soorya Narayanan Sanand on 1/9/2025.
//

import SwiftUI

@MainActor
struct TaskListDetail: View {
    let listName: String
    @State var listsVM: TaskListViewModel
    @State var tasksVM: TaskViewModel

    @State private var isAddingTask = false
    @State private var renamingTask: BaseTask? = nil
    @State private var renameTaskText: String = ""

    @State private var searchText: String = ""

    private let sorting = DefaultTaskSorting()

    var body: some View {
        VStack(spacing: 0) {
            if let error = listsVM.lastError ?? tasksVM.lastError {
                ErrorBanner(message: error)
            }

            List {
                if let list = listsVM.lists.first(where: { $0.name == listName }
                ) {
                    let filtered = applyFilters(
                        to: list.tasks,
                        search: searchText
                    )
                    let reference = Date()
                    
                    let completedTasks = filtered.filter { $0.completed }
                    let incompleteTasks = filtered.filter { !$0.completed }
                    
                    let grouped = Dictionary(grouping: incompleteTasks) {
                        sorting.section(for: $0, reference: reference)
                    }

                    ForEach(
                        [TaskSection.overdue, .today, .upcoming, .noDue],
                        id: \.self
                    ) { section in
                        let inSection = sorting.sort(
                            grouped[section] ?? [],
                            reference: reference
                        )
                        if !inSection.isEmpty {
                            Section(section.rawValue) {
                                ForEach(inSection, id: \.id) { task in
                                    row(for: task, in: listName)
                                }
                            }
                        }
                    }
                    
                    if !completedTasks.isEmpty {
                        Section("Completed") {
                            ForEach(completedTasks.sorted(by: { $0.completedAt ?? $0.updatedAt > $1.completedAt ?? $1.updatedAt }), id: \.id) { task in
                                row(for: task, in: listName)
                            }
                        }
                    }
                } else {
                    Text("List not found")
                }
            }
            .listStyle(.insetGrouped)
        }
        .navigationTitle(listName)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isAddingTask = true
                } label: {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("Add Task")
            }
        }
        .task { await listsVM.load() }
        .searchable(
            text: $searchText,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: "Search tasks"
        )
        .autocorrectionDisabled()
        .textInputAutocapitalization(.never)
        .sheet(isPresented: $isAddingTask) {
            AddTaskSheet { title, detail, category, priority, due in
                Task {
                    await tasksVM.addTask(
                        to: listName,
                        title: title,
                        detail: detail,
                        category: category,
                        priority: priority,
                        dueAt: due
                    )
                    await listsVM.load()
                }
            }
            .presentationDetents([.medium])
        }
        .sheet(
            isPresented: Binding(
                get: { renamingTask != nil },
                set: { if !$0 { renamingTask = nil } }
            )
        ) {
            NavigationStack {
                Form { TextField("Task title", text: $renameTaskText) }
                    .navigationTitle("Rename Task")
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") { renamingTask = nil }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Save") {
                                guard let task = renamingTask else { return }
                                let trimmed = renameTaskText.trimmingCharacters(
                                    in: .whitespacesAndNewlines
                                )
                                guard !trimmed.isEmpty else { return }
                                Task {
                                    await tasksVM.rename(
                                        list: listName,
                                        task: task,
                                        to: trimmed
                                    )
                                    await listsVM.load()
                                    renamingTask = nil
                                }
                            }
                            .disabled(
                                renameTaskText.trimmingCharacters(
                                    in: .whitespacesAndNewlines
                                ).isEmpty
                            )
                        }
                    }
            }
            .presentationDetents([.height(200)])
        }
    }

    private func applyFilters(
        to tasks: [BaseTask],
        search: String
    ) -> [BaseTask] {
        let trimmed = search.trimmingCharacters(in: .whitespacesAndNewlines)
        return tasks.filter { t in
            if trimmed.isEmpty { return true }
            let q = trimmed.lowercased()
            let titleHit = t.title.lowercased().contains(q)
            let detailHit = t.detail?.lowercased().contains(q) ?? false
            return titleHit || detailHit
        }
    }

    @ViewBuilder
    private func row(for task: BaseTask, in listName: String) -> some View {
        HStack {
            Button(action: {
                Task {
                    if task.completed {
                        await tasksVM.markAsIncomplete(list: listName, task: task)
                    } else {
                        await tasksVM.markAsCompleted(list: listName, task: task)
                    }
                    await listsVM.load()
                }
            }) {
                Image(systemName: task.completed ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(task.completed ? .green : .gray)
                    .font(.title2)
            }
            .buttonStyle(PlainButtonStyle())
            
            VStack(alignment: .leading, spacing: 2) {
                Text(task.title)
                    .strikethrough(task.completed)
                    .foregroundColor(task.completed ? .secondary : .primary)

                HStack(spacing: 8) {
                    Text(task.category.rawValue.capitalized)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    if let due = task.dueAt {
                        HStack(spacing: 4) {
                            Image(systemName: "clock")
                            Text(
                                due.formatted(
                                    date: .abbreviated,
                                    time: .shortened
                                )
                            )
                        }
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            due < Date()
                                ? Color.red.opacity(0.15)
                                : Color.gray.opacity(0.12)
                        )
                        .clipShape(Capsule())
                        .foregroundStyle(
                            due < Date()
                                ? .red : .secondary
                        )
                    }
                }
            }

            Spacer()

            Text(task.priority.rawValue.capitalized)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .opacity(task.completed ? 0.6 : 1.0)
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive) {
                Task {
                    await tasksVM.remove(list: listName, id: task.id)
                    await listsVM.load()
                }
            } label: {
                Label("Delete", systemImage: "trash")
            }

            Button {
                renamingTask = task
                renameTaskText = task.title
            } label: {
                Label("Rename", systemImage: "pencil")
            }
        }
    }
}
