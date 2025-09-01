//
//  AddListSheet.swift
//  TaskManager
//
//  Created by Soorya Narayanan Sanand on 1/9/2025.
//

import SwiftUI

struct AddListSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name: String = ""
    var onCreate: (String) -> Void

    var body: some View {
        NavigationStack {
            Form { TextField("List name", text: $name) }
            .navigationTitle("New List")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") { onCreate(name); dismiss() }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}
