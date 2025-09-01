//
//  TaskError.swift
//  TaskManager
//
//  Created by Soorya Narayanan Sanand on 1/9/2025.
//

import Foundation

public enum TaskError: Error, LocalizedError, Sendable {
    case emptyTitle
    case invalidDueDate
    case alreadyCompleted

    public var errorDescription: String? {
        switch self {
        case .emptyTitle: return "Title cannot be empty."
        case .invalidDueDate: return "Due date cannot be earlier than creation date."
        case .alreadyCompleted: return "Task is already completed."
        }
    }
}
