//
//  TaskRepository.swift
//  TaskManager
//
//  Created by Soorya Narayanan Sanand on 1/9/2025.
//


import Foundation

public protocol TaskRepository: Sendable {
    
/// Return all lists (shallow copy) in alphabetical order
func fetchLists() async throws -> [TaskList]
    
/// Create a new list if missing (idempotent by name)
func ensureList(named name: String) async throws
    
/// Delete a list by exact name
func deleteList(named name: String) async throws

/// Add a task to a list
func addTask(_ task: BaseTask, to listName: String) async throws
    
/// Replace a task in a list (by id)
func updateTask(_ task: BaseTask, in listName: String) async throws
    
/// Remove a task by id from a list
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
