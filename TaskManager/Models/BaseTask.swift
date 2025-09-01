//
//  BaseTask.swift
//  TaskManager
//
//  Created by Soorya Narayanan Sanand on 1/9/2025.
//

import Foundation

public struct BaseTask: TaskProtocol {
    public let id: TaskID
    public var title: String
    public var detail: String?
    public var category: TaskCategory
    public var priority: TaskPriority
    public var status: TaskStatus
    public let createdAt: Date
    public var updatedAt: Date
    public var dueAt: Date?

    public init(id: TaskID = UUID(),
                title: String,
                detail: String? = nil,
                category: TaskCategory = .personal,
                priority: TaskPriority = .medium,
                status: TaskStatus = .todo,
                createdAt: Date = Date(),
                updatedAt: Date = Date(),
                dueAt: Date? = nil) throws {
        guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw TaskError.emptyTitle
        }
        self.id = id
        self.title = title
        self.detail = detail
        self.category = category
        self.priority = priority
        self.status = status
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        if let dueAt {
            try Self.validateDue(createdAt: createdAt, dueAt: dueAt)
        }
        self.dueAt = dueAt
    }
}

public extension BaseTask {
    static func validateDue(createdAt: Date, dueAt: Date) throws {
        if dueAt < createdAt { throw TaskError.invalidDueDate }
    }

    mutating func markCompleted() throws {
        guard status != .done else { throw TaskError.alreadyCompleted }
        status = .done
        updatedAt = Date()
    }

    mutating func markInProgress() throws {
        status = .inProgress
        updatedAt = Date()
    }

    mutating func rename(to newTitle: String) throws {
        let trimmed = newTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { throw TaskError.emptyTitle }
        title = trimmed
        updatedAt = Date()
    }

    mutating func reschedule(dueAt newDate: Date?) throws {
        if let newDate {
            try Self.validateDue(createdAt: createdAt, dueAt: newDate)
        }
        dueAt = newDate
        updatedAt = Date()
    }
}
