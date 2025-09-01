//
//  TaskTypes.swift
//  TaskManager
//
//  Created by Soorya Narayanan Sanand on 1/9/2025.
//

import Foundation

public enum TaskCategory: String, Codable, CaseIterable, Sendable {
    case personal, work, shopping, study, other
}

public enum TaskPriority: String, Codable, CaseIterable, Comparable, Sendable {
    case low, medium, high, critical

    private var weight: Int {
        switch self {
        case .low: 0;
        case .medium: 1;
        case .high: 2;
        case .critical: 3
        }
    }
    
    public static func < (lhs: TaskPriority, rhs: TaskPriority) -> Bool {
        lhs.weight < rhs.weight
    }
}

public enum TaskStatus: String, Codable, CaseIterable, Sendable {
    case todo, inProgress, done
}
