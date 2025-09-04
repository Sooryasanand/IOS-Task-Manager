//
//  ContentView.swift
//  TaskManager
//
//  Created by Soorya Narayanan Sanand on 1/9/2025.
//

import Observation
import SwiftUI

@MainActor
struct ContentView: View {
    @State private var listsVM: TaskListViewModel
    @State private var tasksVM: TaskViewModel
    @State private var isAddingList = false
    @State private var renamingListName: String? = nil
    @State private var renameListText: String = ""
    @State private var renameError: String? = nil

    init() {
        let env = ProcessInfo.processInfo.environment
        let filename = env["PERSISTENCE_FILENAME"] ?? "task_lists.json"

        if env["WIPE_PERSISTENCE"] == "1" {
            let store = DiskStore(filename: filename)
            try? FileManager.default.removeItem(at: store.url)
        }

        let repo = FileTaskRepository(filename: filename, seed: Fixtures.makeSeed())
        _listsVM = State(initialValue: TaskListViewModel(repo: repo))
        _tasksVM = State(initialValue: TaskViewModel(repo: repo))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if let error = listsVM.lastError ?? tasksVM.lastError {
                    ErrorBanner(message: error)
                }
                List {
                    Section("Lists") {
                        ForEach(self.listsVM.lists, id: \.name) { list in
                            NavigationLink(value: list.name) {
                                HStack {
                                    Text(list.name)
                                    Spacer()
                                    Text("\(list.tasks.count)")
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .swipeActions(
                                edge: .trailing,
                                allowsFullSwipe: false
                            ) {
                                Button(role: .destructive) {
                                    Task {
                                        await self.listsVM.deleteList(
                                            named: list.name
                                        )
                                        await self.listsVM.load()
                                    }
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }

                                Button {
                                    self.renamingListName = list.name
                                    self.renameListText = list.name
                                } label: {
                                    Label("Rename", systemImage: "pencil")
                                }
                            }
                        }
                        .onDelete { indexSet in
                            Task {
                                for idx in indexSet {
                                    await self.listsVM.deleteList(
                                        named: self.listsVM.lists[idx].name
                                    )
                                }
                                await self.listsVM.load()
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
            .navigationTitle("TaskManager")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        self.isAddingList = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("Add List")
                }
            }
            .task { await self.listsVM.load() }
            .sheet(isPresented: self.$isAddingList) {
                let existing = Set(listsVM.lists.map { $0.name.lowercased() })
                AddListSheet(existingNamesLowercased: existing) { name in
                    Task {
                        _ = await self.listsVM.tryEnsureList(named: name)
                        await self.listsVM.load()
                    }
                }
                .presentationDetents([.height(200)])
            }
            .navigationDestination(for: String.self) { listName in
                TaskListDetail(
                    listName: listName,
                    listsVM: self.listsVM,
                    tasksVM: self.tasksVM
                )
            }
            .sheet(
                isPresented: Binding(
                    get: { self.renamingListName != nil },
                    set: {
                        if !$0 {
                            self.renamingListName = nil
                            self.renameError = nil
                        }
                    }
                )
            ) {
                NavigationStack {
                    Form {
                        TextField("List name", text: self.$renameListText)
                        if let err = renameError {
                            Text(err).font(.footnote).foregroundStyle(.red)
                        }
                    }
                    .navigationTitle("Rename List")
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                self.renamingListName = nil
                                self.renameError = nil
                            }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Save") {
                                guard let old = renamingListName else { return }
                                let trimmed = self.renameListText
                                    .trimmingCharacters(
                                        in: .whitespacesAndNewlines
                                    )
                                if trimmed.isEmpty {
                                    self.renameError =
                                        "List name can’t be empty."
                                    return
                                }

                                let existing = Set(
                                    listsVM.lists.map { $0.name.lowercased() }
                                )
                                if trimmed.lowercased() != old.lowercased(),
                                    existing.contains(trimmed.lowercased())
                                {
                                    self.renameError =
                                        "A list named “\(trimmed)” already exists."
                                    return
                                }
                                Task {
                                    let err = await listsVM.tryRenameList(
                                        from: old,
                                        to: trimmed
                                    )
                                    if let err {
                                        self.renameError = err
                                    } else {
                                        await self.listsVM.load()
                                        self.renamingListName = nil
                                        self.renameError = nil
                                    }
                                }
                            }
                            .disabled(
                                self.renameListText.trimmingCharacters(
                                    in: .whitespacesAndNewlines
                                ).isEmpty
                            )
                        }
                    }
                }
                .presentationDetents([.height(200)])
            }
        }
    }
}
