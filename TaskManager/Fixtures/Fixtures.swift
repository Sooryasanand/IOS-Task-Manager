//
//  Fixtures.swift
//  TaskManager
//
//  Created by Soorya Narayanan Sanand on 1/9/2025.
//


public enum Fixtures {
    public static func makeSeed() -> [TaskList] {
        var today = TaskList(name: "Today")
        var inbox = TaskList(name: "Inbox")
        var shopping = TaskList(name: "Shopping")
        do {
            var t1 = try BaseTask(title: "Email supplier", category: .work, priority: .high)
            try t1.markInProgress()
            let t2 = try BaseTask(title: "Study POP principles", category: .study, priority: .medium)
            let t3 = try BaseTask(title: "Buy milk", category: .shopping, priority: .low)
            today.add(t1)
            inbox.add(t2)
            shopping.add(t3)
        } catch {
            // In fixtures we ignore errors; tests cover logic
        }
        return [today, inbox, shopping]
    }
}
