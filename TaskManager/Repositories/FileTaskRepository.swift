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
        self.lists = self.store.loadOrDefault(seed)
        self.lists.sort {
            $0.name.localizedCaseInsensitiveCompare($1.name)
                == .orderedAscending
        }
        try? self.store.save(self.lists)  // persist seed on first run
    }

    public func fetchLists() async throws -> [TaskList] { self.lists }

    public func ensureList(named name: String) async throws {
        if !self.lists.contains(where: { $0.name == name }) {
            self.lists.append(TaskList(name: name))
            self.lists.sort {
                $0.name.localizedCaseInsensitiveCompare($1.name)
                    == .orderedAscending
            }
            try? self.store.save(self.lists)
        }
    }

    public func deleteList(named name: String) async throws {
        self.lists.removeAll { $0.name == name }
        try? self.store.save(self.lists)
    }

    public func renameList(from oldName: String, to newName: String)
        async throws
    {
        guard let idx = lists.firstIndex(where: { $0.name == oldName })
        else { throw RepositoryError.listNotFound(oldName) }
        if self.lists
            .contains(where: { $0.name == newName && $0.name != oldName })
        {
            throw RepositoryError.listNameTaken(newName)
        }
        self.lists[idx].name = newName
        self.lists.sort {
            $0.name.localizedCaseInsensitiveCompare($1.name)
                == .orderedAscending
        }
        try? self.store.save(self.lists)
    }

    public func addTask(_ task: BaseTask, to listName: String) async throws {
        guard let idx = lists.firstIndex(where: { $0.name == listName })
        else { throw RepositoryError.listNotFound(listName) }
        self.lists[idx].tasks.append(task)
        try? self.store.save(self.lists)
    }

    public func updateTask(_ task: BaseTask, in listName: String) async throws {
        guard let listIdx = lists.firstIndex(where: { $0.name == listName })
        else { throw RepositoryError.listNotFound(listName) }
        guard
            let taskIdx = lists[listIdx].tasks.firstIndex(where: {
                $0.id == task.id
            })
        else { throw RepositoryError.taskNotFound(task.id) }
        self.lists[listIdx].tasks[taskIdx] = task
        try? self.store.save(self.lists)
    }

    public func removeTask(withId id: TaskID, from listName: String)
        async throws
    {
        guard let listIdx = lists.firstIndex(where: { $0.name == listName })
        else { throw RepositoryError.listNotFound(listName) }
        self.lists[listIdx].tasks.removeAll { $0.id == id }
        try? self.store.save(self.lists)
    }
}
