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
    
    func addTask(_ task: BaseTask, to listName: String) async throws
    func updateTask(_ task: BaseTask, in listName: String) async throws
    func removeTask(withId id: TaskID, from listName: String) async throws
}

public enum RepositoryError: Error, LocalizedError, Sendable {
    case listNotFound(String)
    case taskNotFound(TaskID)

    public var errorDescription: String? {
        switch self {
        case .listNotFound(let name): return "List not found: \(name)"
        case .taskNotFound(let id): return "Task not found: \(id)"
        }
    }
}
