//
//  RepositoryTests.swift
//  TaskManager
//
//  Created by Soorya Narayanan Sanand on 2/9/2025.
//

import XCTest

@testable import TaskManager

final class RepositoryTests: XCTestCase {

    func test_InMemoryRepository_CRUD_and_errors() async throws {
        let repo = InMemoryTaskRepository(seed: Fixtures.makeSeed())

        // create list
        try await repo.ensureList(named: "Work")
        var lists = try await repo.fetchLists()
        XCTAssertTrue(lists.contains { $0.name == "Work" })

        // add task
        let new = try BaseTask(
            title: "Write report",
            category: .work,
            priority: .high
        )
        try await repo.addTask(new, to: "Work")
        lists = try await repo.fetchLists()
        XCTAssertTrue(
            lists.first(where: { $0.name == "Work" })!.tasks.contains {
                $0.id == new.id
            }
        )

        // update task
        var edited = new
        try edited.rename(to: "Write final report")
        try await repo.updateTask(edited, in: "Work")
        lists = try await repo.fetchLists()
        XCTAssertEqual(
            lists.first(where: { $0.name == "Work" })!.tasks.first(where: {
                $0.id == new.id
            })!.title,
            "Write final report"
        )

        // remove task
        try await repo.removeTask(withId: new.id, from: "Work")
        lists = try await repo.fetchLists()
        XCTAssertNil(
            lists.first(where: { $0.name == "Work" })!.tasks.first(where: {
                $0.id == new.id
            })
        )

        // error paths
        await XCTAssertThrowsErrorAsync(
            try await repo.addTask(new, to: "Missing")
        ) { error in
            guard case RepositoryError.listNotFound(let name) = error else {
                return XCTFail()
            }
            XCTAssertEqual(name, "Missing")
        }
        await XCTAssertThrowsErrorAsync(
            try await repo.updateTask(edited, in: "Missing")
        ) { _ in }
        await XCTAssertThrowsErrorAsync(
            try await repo.removeTask(withId: new.id, from: "Missing")
        ) { _ in }
    }

    func test_RenameList_and_duplicate_error() async throws {
        let repo = InMemoryTaskRepository(seed: [
            TaskList(name: "Inbox"), TaskList(name: "Today"),
        ])
        try await repo.renameList(from: "Inbox", to: "Personal")
        var lists = try await repo.fetchLists()
        XCTAssertTrue(lists.contains { $0.name == "Personal" })
        XCTAssertFalse(lists.contains { $0.name == "Inbox" })

        // duplicate
        await XCTAssertThrowsErrorAsync(
            try await repo.renameList(from: "Personal", to: "Today")
        ) { error in
            guard case RepositoryError.listNameTaken(let name) = error else {
                return XCTFail()
            }
            XCTAssertEqual(name, "Today")
        }
    }
}

private func XCTAssertThrowsErrorAsync<T>(
    _ expression: @autoclosure () async throws -> T,
    _ message: @autoclosure () -> String = "",
    _ errorHandler: (Error) -> Void = { _ in },
    file: StaticString = #filePath,
    line: UInt = #line
) async {
    do {
        _ = try await expression()
        XCTFail("Expected error", file: file, line: line)
    } catch {
        errorHandler(error)
    }
}
