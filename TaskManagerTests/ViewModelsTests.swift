//
//  ViewModelsTests.swift
//  TaskManager
//
//  Created by Soorya Narayanan Sanand on 2/9/2025.
//

import XCTest

@testable import TaskManager

final class ViewModelsTests: XCTestCase {

    func test_TaskListVM_load_and_ensureList() async {
        let repo = InMemoryTaskRepository(seed: Fixtures.makeSeed())
        let vm = TaskListViewModel(repo: repo)

        await vm.load()
        XCTAssertGreaterThan(vm.lists.count, 0)

        await vm.ensureList(named: "Errands")
        XCTAssertTrue(vm.lists.contains { $0.name == "Errands" })
    }

    func test_TaskVM_add_rename_remove() async throws {
        let repo = InMemoryTaskRepository(seed: [TaskList(name: "Errands")])
        let listsVM = TaskListViewModel(repo: repo)
        let tasksVM = TaskViewModel(repo: repo)

        await tasksVM.addTask(
            to: "Errands",
            title: "Pick up parcel",
            category: .personal,
            priority: .medium
        )
        await listsVM.load()
        var errands = listsVM.lists.first(where: { $0.name == "Errands" })!
        XCTAssertTrue(errands.tasks.contains { $0.title == "Pick up parcel" })

        // rename
        let renamedTo = "Pick up package"
        await tasksVM.rename(
            list: "Errands",
            task: errands.tasks.first!,
            to: renamedTo
        )
        await listsVM.load()
        XCTAssertEqual(
            listsVM.lists.first(where: { $0.name == "Errands" })!.tasks.first!
                .title,
            renamedTo
        )

        // remove
        let id = listsVM.lists.first(where: { $0.name == "Errands" })!.tasks
            .first!.id
        await tasksVM.remove(list: "Errands", id: id)
        await listsVM.load()
        XCTAssertNil(
            listsVM.lists.first(where: { $0.name == "Errands" })!.tasks.first(
                where: { $0.id == id })
        )
    }
    
    func test_TaskVM_markAsCompleted_and_Incomplete() async throws {
        let repo = InMemoryTaskRepository(seed: [TaskList(name: "Test")])
        let listsVM = TaskListViewModel(repo: repo)
        let tasksVM = TaskViewModel(repo: repo)

        // Add a task
        await tasksVM.addTask(
            to: "Test",
            title: "Test Task",
            category: .personal,
            priority: .medium
        )
        await listsVM.load()
        var testList = listsVM.lists.first(where: { $0.name == "Test" })!
        let task = testList.tasks.first!
        XCTAssertFalse(task.completed)
        XCTAssertNil(task.completedAt)

        // Mark as completed
        await tasksVM.markAsCompleted(list: "Test", task: task)
        await listsVM.load()
        testList = listsVM.lists.first(where: { $0.name == "Test" })!
        let completedTask = testList.tasks.first!
        XCTAssertTrue(completedTask.completed)
        XCTAssertNotNil(completedTask.completedAt)

        // Mark as incomplete
        await tasksVM.markAsIncomplete(list: "Test", task: completedTask)
        await listsVM.load()
        testList = listsVM.lists.first(where: { $0.name == "Test" })!
        let incompleteTask = testList.tasks.first!
        XCTAssertFalse(incompleteTask.completed)
        XCTAssertNil(incompleteTask.completedAt)
    }
}
