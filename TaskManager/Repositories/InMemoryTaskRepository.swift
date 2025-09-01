//
//  InMemoryTaskRepository.swift
//  TaskManager
//
//  Created by Soorya Narayanan Sanand on 1/9/2025.
//


public actor InMemoryTaskRepository: TaskRepository {
    private var lists: [TaskList]

    public init(seed: [TaskList] = []) {
        // keep unique by name
        let dedup = Dictionary(grouping: seed, by: { $0.name })
            .compactMap { $0.value.first }
            .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        self.lists = dedup
    }

    public func fetchLists() async throws -> [TaskList] {
        lists
    }

    public func ensureList(named name: String) async throws {
        if !lists.contains(where: { $0.name == name }) {
            lists.append(TaskList(name: name))
            lists.sort { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        }
    }

    public func deleteList(named name: String) async throws {
        lists.removeAll { $0.name == name }
    }

    public func addTask(_ task: BaseTask, to listName: String) async throws {
        guard let idx = lists.firstIndex(where: { $0.name == listName }) else { throw RepositoryError.listNotFound(listName) }
        lists[idx].tasks.append(task)
    }

    public func updateTask(_ task: BaseTask, in listName: String) async throws {
        guard let listIdx = lists.firstIndex(where: { $0.name == listName }) else { throw RepositoryError.listNotFound(listName) }
        guard let taskIdx = lists[listIdx].tasks.firstIndex(where: { $0.id == task.id }) else { throw RepositoryError.taskNotFound(task.id) }
        lists[listIdx].tasks[taskIdx] = task
    }

    public func removeTask(withId id: TaskID, from listName: String) async throws {
        guard let listIdx = lists.firstIndex(where: { $0.name == listName }) else { throw RepositoryError.listNotFound(listName) }
        lists[listIdx].tasks.removeAll { $0.id == id }
    }
}
