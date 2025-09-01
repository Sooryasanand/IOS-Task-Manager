//
//  FileTaskRepository.swift
//  TaskManager
//
//  Created by Soorya Narayanan Sanand on 1/9/2025.
//

import Foundation

public actor FileTaskRepository: TaskRepository {
    private var lists: [TaskList]
    private let store: DiskStore

    public init(filename: String = "task_lists.json", seed: [TaskList] = []) {
        self.store = DiskStore(filename: filename)
        self.lists = store.loadOrDefault(seed)
        self.lists.sort { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        try? store.save(self.lists) // persist seed on first run
    }

    public func fetchLists() async throws -> [TaskList] { lists }

    public func ensureList(named name: String) async throws {
        if !lists.contains(where: { $0.name == name }) {
            lists.append(TaskList(name: name))
            lists.sort { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
            try? store.save(lists)
        }
    }

    public func deleteList(named name: String) async throws {
        lists.removeAll { $0.name == name }
        try? store.save(lists)
    }

    public func addTask(_ task: BaseTask, to listName: String) async throws {
        guard let idx = lists.firstIndex(where: { $0.name == listName }) else { throw RepositoryError.listNotFound(listName) }
        lists[idx].tasks.append(task)
        try? store.save(lists)
    }

    public func updateTask(_ task: BaseTask, in listName: String) async throws {
        guard let listIdx = lists.firstIndex(where: { $0.name == listName }) else { throw RepositoryError.listNotFound(listName) }
        guard let taskIdx = lists[listIdx].tasks.firstIndex(where: { $0.id == task.id }) else { throw RepositoryError.taskNotFound(task.id) }
        lists[listIdx].tasks[taskIdx] = task
        try? store.save(lists)
    }

    public func removeTask(withId id: TaskID, from listName: String) async throws {
        guard let listIdx = lists.firstIndex(where: { $0.name == listName }) else { throw RepositoryError.listNotFound(listName) }
        lists[listIdx].tasks.removeAll { $0.id == id }
        try? store.save(lists)
    }
}
