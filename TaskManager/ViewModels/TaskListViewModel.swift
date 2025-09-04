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
    public private(set) var lastError: String?

    public init(repo: TaskRepository) {
        self.repo = repo
    }

    @MainActor
    public func load() async {
        do { self.lists = try await self.repo.fetchLists() } catch {
            self.lastError = error.localizedDescription
        }
    }

    @MainActor
    public func ensureList(named name: String) async {
        do {
            try await self.repo.ensureList(named: name)
            self.lists = try await self.repo.fetchLists()
        } catch { self.lastError = error.localizedDescription }
    }

    @MainActor
    public func deleteList(named name: String) async {
        do {
            try await self.repo.deleteList(named: name)
            self.lists = try await self.repo.fetchLists()
        } catch { self.lastError = error.localizedDescription }
    }

    @MainActor
    public func renameList(from oldName: String, to newName: String) async {
        do {
            try await self.repo.renameList(from: oldName, to: newName)
            self.lists = try await self.repo.fetchLists()
        } catch { self.lastError = error.localizedDescription }
    }

    @MainActor
    public func tryRenameList(from oldName: String, to newName: String) async
        -> String?
    {
        do {
            try await self.repo.renameList(from: oldName, to: newName)
            self.lists = try await self.repo.fetchLists()
            return nil
        } catch {
            let msg =
                (error as? LocalizedError)?.errorDescription
                ?? error.localizedDescription
            self.lastError = msg
            return msg
        }
    }

    @MainActor
    public func tryEnsureList(named name: String) async -> String? {
        do {
            try await self.repo.ensureList(named: name)
            self.lists = try await self.repo.fetchLists()
            return nil
        } catch {
            let msg =
                (error as? LocalizedError)?.errorDescription
                ?? error.localizedDescription
            self.lastError = msg
            return msg
        }
    }
}
