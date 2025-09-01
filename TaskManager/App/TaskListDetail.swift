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

    var body: some View {
        VStack(spacing: 0) {
            if let error = listsVM.lastError ?? tasksVM.lastError { ErrorBanner(message: error) }
            List {
                if let list = listsVM.lists.first(where: { $0.name == listName }) {
                    ForEach(list.tasks, id: \.id) { task in
                        HStack {
                            Button { Task { await tasksVM.toggleDone(list: listName, task: task); await listsVM.load() } } label: {
                                Image(systemName: task.status == .done ? "checkmark.circle.fill" : "circle")
                            }
                            
                            .buttonStyle(.plain)

                            VStack(alignment: .leading) {
                                Text(task.title).strikethrough(task.status == .done)
                                HStack(spacing: 8) {
                                    Text(task.category.rawValue.capitalized)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)

                                    if let due = task.dueAt {
                                        HStack(spacing: 4) {
                                            Image(systemName: "clock")
                                            Text(due.formatted(date: .abbreviated, time: .shortened))
                                        }
                                        .font(.caption2)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background((due < Date() && task.status != .done) ? Color.red.opacity(0.15) : Color.gray.opacity(0.12))
                                        .clipShape(Capsule())
                                        .foregroundStyle((due < Date() && task.status != .done) ? .red : .secondary)
                                        .accessibilityLabel((due < Date() && task.status != .done) ? "Overdue" : "Due")
                                    }
                                }
                            }
                            
                            Spacer()
                            
                            Text(task.priority.rawValue.capitalized)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        }
                    }
                    .onDelete { indexSet in
                        Task {
                            for idx in indexSet { await tasksVM.remove(list: listName, id: list.tasks[idx].id) }
                            await listsVM.load()
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
                Button { isAddingTask = true } label: { Image(systemName: "plus") }
            }
        }
        .task { await listsVM.load() }
        .sheet(isPresented: $isAddingTask) {
            AddTaskSheet { title, detail, category, priority, due in
                Task {
                    await tasksVM.addTask(to: listName, title: title, detail: detail, category: category, priority: priority, dueAt: due)
                    await listsVM.load()
                }
            }
            .presentationDetents([.medium])
        }
    }
}
