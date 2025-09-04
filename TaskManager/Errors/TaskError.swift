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

    public var errorDescription: String? {
        switch self {
        case .emptyTitle: "Title cannot be empty."
        case .invalidDueDate: "Due date cannot be earlier than creation date."
        }
    }
}
