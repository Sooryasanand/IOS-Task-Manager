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
    public let createdAt: Date
    public var updatedAt: Date
    public var dueAt: Date?
    public var completed: Bool
    public var completedAt: Date?

    public init(
        id: TaskID = UUID(),
        title: String,
        detail: String? = nil,
        category: TaskCategory = .personal,
        priority: TaskPriority = .medium,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        dueAt: Date? = nil,
        completed: Bool = false,
        completedAt: Date? = nil
    ) throws {
        guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        else {
            throw TaskError.emptyTitle
        }
        self.id = id
        self.title = title
        self.detail = detail
        self.category = category
        self.priority = priority
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.completed = completed
        self.completedAt = completedAt
        if let dueAt {
            try Self.validateDue(createdAt: createdAt, dueAt: dueAt)
        }
        self.dueAt = dueAt
    }
}

extension BaseTask {
    public static func validateDue(createdAt: Date, dueAt: Date) throws {
        if dueAt < createdAt { throw TaskError.invalidDueDate }
    }

    public mutating func rename(to newTitle: String) throws {
        let trimmed = newTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { throw TaskError.emptyTitle }
        self.title = trimmed
        self.updatedAt = Date()
    }

    public mutating func reschedule(dueAt newDate: Date?) throws {
        if let newDate {
            try Self.validateDue(createdAt: self.createdAt, dueAt: newDate)
        }
        self.dueAt = newDate
        self.updatedAt = Date()
    }
}
