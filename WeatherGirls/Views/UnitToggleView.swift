//
//  UnitToggleView.swift
//  WeatherGirls
//
//  Created by Robin Gonzales on 12/23/25.
//

import SwiftUI

struct UnitToggleView: View {
    @Binding var isFahrenheit: Bool

    var body: some View {
        HStack {
            Image(systemName: isFahrenheit ? "f.circle.fill" : "c.circle.fill")
                .font(.title2)
            Toggle(isOn: $isFahrenheit) {
                Text(isFahrenheit ? "Fahrenheit" : "Celsius")
            }
            .toggleStyle(.switch)
        }
        .weatherHUDStyle()
    }
}

#Preview {
    StatefulPreviewWrapper(false) { binding in
        UnitToggleView(isFahrenheit: binding)
            .padding()
    }
}

// Helper to preview bindings
struct StatefulPreviewWrapper<Value, Content: View>: View {
    @State private var value: Value
    private let content: (Binding<Value>) -> Content

    init(_ value: Value, content: @escaping (Binding<Value>) -> Content) {
        _value = State(initialValue: value)
        self.content = content
    }

    var body: some View {
        content($value)
    }
}

