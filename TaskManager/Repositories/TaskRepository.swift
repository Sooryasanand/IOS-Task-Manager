//
//  TaskRepository.swift
//  TaskManager
//
//  Created by Soorya Narayanan Sanand on 1/9/2025.
//

import Foundation

public protocol TaskRepository: Sendable {
    func fetchLists() async throws -> [TaskList]
    func ensureList(named name: String) async throws
    func deleteList(named name: String) async throws
    func renameList(from oldName: String, to newName: String) async throws

    func addTask(_ task: BaseTask, to listName: String) async throws
    func updateTask(_ task: BaseTask, in listName: String) async throws
    func removeTask(withId id: TaskID, from listName: String) async throws
}

public enum RepositoryError: Error, LocalizedError, Sendable {
    case listNotFound(String)
    case taskNotFound(TaskID)
    case listNameTaken(String)

    public var errorDescription: String? {
        switch self {
        case let .listNotFound(name): "List not found: \(name)"
        case let .taskNotFound(id): "Task not found: \(id)"
        case let .listNameTaken(name): "A list named “\(name)” already exists."
        }
    }
}
