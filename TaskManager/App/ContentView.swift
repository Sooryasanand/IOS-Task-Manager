//
//  ContentView.swift
//  TaskManager
//
//  Created by Soorya Narayanan Sanand on 1/9/2025.
//

import SwiftUI
import Observation

@MainActor
struct ContentView: View {
// Single shared repo for the app lifetime
    private let repo = InMemoryTaskRepository(seed: Fixtures.makeSeed())

    @State private var listsVM: TaskListViewModel
    @State private var tasksVM: TaskViewModel
    @State private var isAddingList = false

    init() {
        let repo = InMemoryTaskRepository(seed: Fixtures.makeSeed())
        _listsVM = State(initialValue: TaskListViewModel(repo: repo))
        _tasksVM = State(initialValue: TaskViewModel(repo: repo))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if let error = listsVM.lastError ?? tasksVM.lastError { ErrorBanner(message: error) }
                List {
                    Section("Lists") {
                        ForEach(listsVM.lists, id: \.name) { list in
                            NavigationLink(value: list.name) {
                                HStack {
                                    Text(list.name)
                                    Spacer()
                                    Text("\(list.tasks.count)")
                                    .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .onDelete { indexSet in
                            Task {
                                for idx in indexSet { await listsVM.deleteList(named: listsVM.lists[idx].name) }
                                await listsVM.load()
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
            .navigationTitle("TaskManager")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { isAddingList = true } label: { Image(systemName: "plus") }
                    .accessibilityLabel("Add List")
                }
            }
            .task { await listsVM.load() }
            .sheet(isPresented: $isAddingList) {
                AddListSheet { name in
                    Task { await listsVM.ensureList(named: name) }
                }
                .presentationDetents([.height(200)])
            }
            .navigationDestination(for: String.self) { listName in
                TaskListDetail(listName: listName, listsVM: listsVM, tasksVM: tasksVM)
            }
        }
    }
}
