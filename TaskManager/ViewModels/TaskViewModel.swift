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
    public private(set) var lastError: String?
    private var completionTimers: [TaskID: Timer] = [:]

    public init(repo: TaskRepository) { self.repo = repo }

    @MainActor
    public func addTask(
        to list: String,
        title: String,
        detail: String? = nil,
        category: TaskCategory = .personal,
        priority: TaskPriority = .medium,
        dueAt: Date? = nil
    ) async {
        do {
            var task = try BaseTask(title: title, detail: detail, category: category, priority: priority, dueAt: dueAt)
            try await repo.addTask(task, to: list)
        } catch { self.lastError = error.localizedDescription }
    }

    @MainActor
    public func rename(list: String, task: BaseTask, to newTitle: String) async {
        do {
            var edited = task
            try edited.rename(to: newTitle)
            try await self.repo.updateTask(edited, in: list)
        } catch { self.lastError = error.localizedDescription }
    }

    @MainActor
    public func remove(list: String, id: TaskID) async {
        do { try await self.repo.removeTask(withId: id, from: list) }
        catch { self.lastError = error.localizedDescription }
    }
    
    @MainActor
    public func markAsCompleted(list: String, task: BaseTask) async {
        do {
            var edited = task
            edited.markAsCompleted()
            try await self.repo.updateTask(edited, in: list)
            
            // Schedule removal after 10 seconds
            scheduleTaskRemoval(list: list, taskId: task.id, delay: 10.0)
        } catch { self.lastError = error.localizedDescription }
    }
    
    @MainActor
    public func markAsIncomplete(list: String, task: BaseTask) async {
        do {
            var edited = task
            edited.markAsIncomplete()
            try await self.repo.updateTask(edited, in: list)
            
            // Cancel any pending removal timer
            cancelTaskRemoval(taskId: task.id)
        } catch { self.lastError = error.localizedDescription }
    }
    
    private func scheduleTaskRemoval(list: String, taskId: TaskID, delay: TimeInterval) {
        // Cancel any existing timer for this task
        cancelTaskRemoval(taskId: taskId)
        
        let timer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { [weak self] _ in
            Task { @MainActor in
                await self?.remove(list: list, id: taskId)
                self?.completionTimers.removeValue(forKey: taskId)
            }
        }
        completionTimers[taskId] = timer
    }
    
    private func cancelTaskRemoval(taskId: TaskID) {
        completionTimers[taskId]?.invalidate()
        completionTimers.removeValue(forKey: taskId)
    }
}
