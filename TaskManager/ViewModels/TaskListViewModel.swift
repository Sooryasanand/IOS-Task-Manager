//
//  TaskListViewModel.swift
//  TaskManager
//
//  Created by Soorya Narayanan Sanand on 1/9/2025.
//


import Foundation
import Observation

@Observable
public final class TaskListViewModel: @unchecked Sendable {
    private let repo: TaskRepository
    public private(set) var lists: [TaskList] = []
    public private(set) var lastError: String? = nil

    public init(repo: TaskRepository) {
        self.repo = repo
    }

    @MainActor
    public func load() async {
        do { self.lists = try await repo.fetchLists() }
        catch { self.lastError = error.localizedDescription }
    }

    @MainActor
    public func ensureList(named name: String) async {
        do {
        try await repo.ensureList(named: name)
        self.lists = try await repo.fetchLists()
        } catch { self.lastError = error.localizedDescription }
    }

    @MainActor
    public func deleteList(named name: String) async {
        do {
            try await repo.deleteList(named: name)
            self.lists = try await repo.fetchLists()
        } catch { self.lastError = error.localizedDescription }
    }
}
