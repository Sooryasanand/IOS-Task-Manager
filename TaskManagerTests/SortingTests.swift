//
//  SortingTests.swift
//  TaskManager
//
//  Created by Soorya Narayanan Sanand on 2/9/2025.
//

import XCTest

@testable import TaskManager

final class SortingTests: XCTestCase {

    func test_Sectioning_and_Sort_order() throws {
        let sorting = DefaultTaskSorting()
        let now = Date()

        let createdBeforeDue = now.addingTimeInterval(-7200)

        let overdue = try BaseTask(
            title: "Overdue",
            priority: .medium,
            createdAt: createdBeforeDue,
            dueAt: now.addingTimeInterval(-3600)
        )

        let todayHigh = try BaseTask(
            title: "Today High",
            priority: .high,
            dueAt: now.addingTimeInterval(1800)
        )
        let todayLow = try BaseTask(
            title: "Today Low",
            priority: .low,
            dueAt: now.addingTimeInterval(7200)
        )
        let upcomingCritical = try BaseTask(
            title: "Future Critical",
            priority: .critical,
            dueAt: now.addingTimeInterval(3 * 86400)
        )
        let noDue = try BaseTask(title: "No Due", priority: .medium, dueAt: nil)

        XCTAssertEqual(sorting.section(for: overdue, reference: now), .overdue)
        XCTAssertEqual(sorting.section(for: todayHigh, reference: now), .today)
        XCTAssertEqual(
            sorting.section(for: upcomingCritical, reference: now),
            .upcoming
        )
        XCTAssertEqual(sorting.section(for: noDue, reference: now), .noDue)

        // Sort assertions within one bucket (e.g., "today")
        let sortedToday = sorting.sort([todayLow, todayHigh], reference: now)
        XCTAssertEqual(sortedToday.first?.title, "Today High")  // higher priority first
    }
}
