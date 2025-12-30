//
//  CityEntrySheet.swift
//  WeatherGirls
//
//  Created by Robin Gonzales on 12/23/25.
//

import SwiftUI

struct CityEntrySheet: View {
    @Binding var cityQuery: String
    @Binding var currentCity: String?
    var onSubmit: (String) -> Void
    var onCancel: () -> Void

    @FocusState private var focused: Bool

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Text("Enter a city")
                    .font(.headline)
                TextField("City name", text: $cityQuery)
                    .textInputAutocapitalization(.words)
                    .autocorrectionDisabled()
                    .focused($focused)
                    .textFieldStyle(.roundedBorder)
            }
            .padding(16)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(.white.opacity(0.15))
            )
            .padding()
            .navigationTitle("Choose Location")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { onCancel() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        onSubmit(cityQuery.trimmingCharacters(in: .whitespacesAndNewlines))
                        cityQuery = ""
                    }
                    .disabled(cityQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .background(
            LinearGradient(colors: [Color.black.opacity(0.2), Color.black.opacity(0.05)], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
        )
        .onAppear { focused = true }
    }
}

#Preview("City Entry Sheet") {
    struct Wrapper: View {
        @State var cityQuery: String = "San Francisco"
        @State var currentCity: String? = "San Francisco"
        var body: some View {
            CityEntrySheet(
                cityQuery: $cityQuery,
                currentCity: $currentCity,
                onSubmit: { _ in },
                onCancel: {}
            )
        }
    }
    return Wrapper()
}
