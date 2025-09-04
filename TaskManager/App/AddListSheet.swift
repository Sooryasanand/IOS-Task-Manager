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

    let existingNamesLowercased: Set<String>
    var onCreate: (String) -> Void

    private var trimmed: String {
        self.name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var errorText: String? {
        if self.trimmed.isEmpty { return "List name can’t be empty." }
        if self.existingNamesLowercased
            .contains(self.trimmed.lowercased())
        {
            return "A list with this name already exists."
        }
        return nil
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField("List name", text: self.$name)
                if let err = errorText {
                    Text(err)
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .accessibilityLabel("Validation error: \(err)")
                }
            }
            .navigationTitle("New List")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { self.dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        self.onCreate(self.trimmed)
                        self.dismiss()
                    }
                    .disabled(self.errorText != nil)
                }
            }
        }
    }
}
