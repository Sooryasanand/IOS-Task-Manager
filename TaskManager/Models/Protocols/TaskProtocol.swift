//
//  TaskProtocol.swift
//  TaskManager
//
//  Created by Soorya Narayanan Sanand on 1/9/2025.
//

import Foundation

public typealias TaskID = UUID

public protocol TaskProtocol: Identifiable, Codable, Equatable, Sendable where ID == TaskID {
    var id: TaskID { get }
    var title: String { get set }
    var detail: String? { get set }
    var category: TaskCategory { get set }
    var priority: TaskPriority { get set }
    var status: TaskStatus { get set }
    var createdAt: Date { get }
    var updatedAt: Date { get set }
    var dueAt: Date? { get set }

    mutating func markCompleted() throws
    mutating func markInProgress() throws
    mutating func rename(to newTitle: String) throws
    mutating func reschedule(dueAt newDate: Date?) throws
    mutating func setPriority(_ newPriority: TaskPriority)
}

public extension TaskProtocol {
    mutating func setPriority(_ newPriority: TaskPriority) {
        self.priority = newPriority;
        self.updatedAt = Date()
    }
}
