//
//  ErrorBanner.swift
//  TaskManager
//
//  Created by Soorya Narayanan Sanand on 1/9/2025.
//

import SwiftUI

struct ErrorBanner: View {
    let message: String
    var body: some View {
        Text(self.message)
            .font(.footnote)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(8)
            .background(Color.red.opacity(0.9))
    }
}
