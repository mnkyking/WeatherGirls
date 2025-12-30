//
//  EmptyState.swift
//  WeatherGirls
//
//  Created by Robin Gonzales on 12/25/25.
//

import SwiftUI

struct EmptyState: View {
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "cloud.fill")
            Text("No forecast data")
        }
        .foregroundStyle(.secondary)
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.vertical, 12)
        .accessibilityLabel("No forecast data available")
    }
}

#Preview {
    EmptyState()
}
