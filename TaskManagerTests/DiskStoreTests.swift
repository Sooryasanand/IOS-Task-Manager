//
//  DiskStoreTests.swift
//  TaskManager
//
//  Created by Soorya Narayanan Sanand on 2/9/2025.
//

import XCTest

@testable import TaskManager

final class DiskStoreTests: XCTestCase {

    func test_DiskStore_roundTrip_save_load() throws {
        let tmp = FileManager.default.temporaryDirectory.appendingPathComponent(
            UUID().uuidString,
            isDirectory: true
        )
        try FileManager.default.createDirectory(
            at: tmp,
            withIntermediateDirectories: true
        )

        let store = DiskStore(filename: "lists.json", directory: tmp)

        // build simple payload (2 lists, a few tasks)
        var l1 = TaskList(name: "A")
        var l2 = TaskList(name: "B")
        l1.add(try BaseTask(title: "T1"))
        l1.add(
            try BaseTask(title: "T2", dueAt: Date().addingTimeInterval(3600))
        )
        l2.add(try BaseTask(title: "T3", category: .work))

        let payload = [l1, l2]
        try store.save(payload)

        let loaded: [TaskList] = try store.load([TaskList].self)
        XCTAssertEqual(loaded.count, 2)
        XCTAssertEqual(Set(loaded.map { $0.name }), Set(["A", "B"]))
        let a = loaded.first(where: { $0.name == "A" })!
        XCTAssertEqual(a.tasks.count, 2)
        XCTAssertTrue(a.tasks.contains { $0.title == "T1" })
        XCTAssertTrue(a.tasks.contains { $0.title == "T2" })
    }

    func test_DiskStore_load_missing_throws_notFound() {
        let tmp = FileManager.default.temporaryDirectory.appendingPathComponent(
            UUID().uuidString,
            isDirectory: true
        )
        let store = DiskStore(filename: "missing.json", directory: tmp)

        XCTAssertThrowsError(try store.load([TaskList].self)) { error in
            guard let e = error as? DiskStore.StoreError, case .notFound = e
            else { return XCTFail() }
        }
    }
}
