//
//  TaskList.swift
//  TaskManager
//
//  Created by Soorya Narayanan Sanand on 1/9/2025.
//

import Foundation

public struct TaskList: TaskListProtocol {
    public var name: String
    public var tasks: [BaseTask]

    public init(name: String, tasks: [BaseTask] = []) {
        self.name = name
        self.tasks = tasks
    }
}
