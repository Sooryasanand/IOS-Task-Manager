//
//  TaskListProtocol.swift
//  TaskManager
//
//  Created by Soorya Narayanan Sanand on 1/9/2025.
//

import Foundation

public protocol TaskListProtocol: Codable, Sendable {
    associatedtype TaskItem: TaskProtocol
    var name: String { get set }
    var tasks: [TaskItem] { get set }

    mutating func add(_ task: TaskItem)
    mutating func remove(where predicate: (TaskItem) -> Bool)
    mutating func replace(_ task: TaskItem)
    func find(by id: TaskID) -> TaskItem?
    func overdue(referenceDate: Date) -> [TaskItem]
}

extension TaskListProtocol {
    public mutating func add(_ task: TaskItem) { tasks.append(task) }

    public mutating func remove(where predicate: (TaskItem) -> Bool) {
        tasks.removeAll(where: predicate)
    }

    public mutating func replace(_ task: TaskItem) {
        if let idx = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[idx] = task
        }
    }

    public func find(by id: TaskID) -> TaskItem? {
        tasks.first(where: { $0.id == id })
    }

    public func overdue(referenceDate: Date = Date()) -> [TaskItem] {
        tasks.filter { item in
            if let due = item.dueAt {
                return due < referenceDate
            }
            return false
        }
    }
}
