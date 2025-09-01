//
//  TaskViewModel.swift
//  TaskManager
//
//  Created by Soorya Narayanan Sanand on 1/9/2025.
//

import Foundation
import Observation

@Observable
public final class TaskViewModel: @unchecked Sendable {
    private let repo: TaskRepository
    public private(set) var lastError: String? = nil

    public init(repo: TaskRepository) { self.repo = repo }

    @MainActor
    public func addTask(to list: String, title: String, detail: String? = nil, category: TaskCategory = .personal, priority: TaskPriority = .medium, dueAt: Date? = nil) async {
        do {
            var task = try BaseTask(title: title, detail: detail, category: category, priority: priority, dueAt: dueAt)
            try await repo.addTask(task, to: list)
        } catch { self.lastError = error.localizedDescription }
    }

    @MainActor
    public func toggleDone(list: String, task: BaseTask) async {
        do {
            var edited = task
            if task.status == .done { try edited.markInProgress() } else { try edited.markCompleted() }
            try await repo.updateTask(edited, in: list)
        } catch { self.lastError = error.localizedDescription }
    }

    @MainActor
    public func rename(list: String, task: BaseTask, to newTitle: String) async {
        do {
            var edited = task
            try edited.rename(to: newTitle)
            try await repo.updateTask(edited, in: list)
        } catch { self.lastError = error.localizedDescription }
    }

    @MainActor
    public func remove(list: String, id: TaskID) async {
        do { try await repo.removeTask(withId: id, from: list) }
        catch { self.lastError = error.localizedDescription }
    }
}
