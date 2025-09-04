//
//  TaskSection.swift
//  TaskManager
//
//  Created by Soorya Narayanan Sanand on 2/9/2025.
//

import Foundation

public enum TaskSection: String, CaseIterable, Sendable {
    case overdue = "Overdue"
    case today = "Today"
    case upcoming = "Upcoming"
    case noDue = "No Due Date"
}

public protocol TaskSortingStrategy {
    func section(for task: BaseTask, reference: Date) -> TaskSection
    func sort(_ tasks: [BaseTask], reference: Date) -> [BaseTask]
}

public struct DefaultTaskSorting: TaskSortingStrategy {
    public init() {}

    public func section(for task: BaseTask, reference: Date) -> TaskSection {
        guard let due = task.dueAt else { return .noDue }
        if due < reference { return .overdue }
        if Calendar.current.isDate(due, inSameDayAs: reference) {
            return .today
        }
        return .upcoming
    }

    public func sort(_ tasks: [BaseTask], reference: Date) -> [BaseTask] {
        tasks.sorted { lhs, rhs in
            if lhs.priority != rhs.priority {
                return lhs.priority > rhs.priority
            }

            switch (lhs.dueAt, rhs.dueAt) {
            case let (l?, r?): return l < r
            case (nil, _?): return false
            case (_?, nil): return true
            default: break
            }

            return lhs.createdAt < rhs.createdAt
        }
    }
}
