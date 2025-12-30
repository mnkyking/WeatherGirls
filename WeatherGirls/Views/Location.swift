//
//  Location.swift
//  WeatherGirls
//
//  Created by Robin Gonzales on 12/25/25.
//

import SwiftUI

struct Location: View {
    @Binding var currentCity: String?
    var onCityChange: (String?) -> Void = { _ in }
    @State private var showingCitySheet: Bool = false
    @State private var cityQuery: String = ""
    
    var body: some View {
        HStack(spacing: 12) {
            Button {
                showingCitySheet = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "location.circle.fill")
                        .imageScale(.large)
                    Text(currentCity ?? "Use my location")
                }
                .weatherHUDStyle()
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Choose city or use current location")
        }
        .sheet(isPresented: $showingCitySheet) {
            CityEntrySheet(cityQuery: $cityQuery, currentCity: $currentCity) { submitted in
                // Update currentCity when user submits
                currentCity = submitted.isEmpty ? nil : submitted
                onCityChange(currentCity)
                showingCitySheet = false
            } onCancel: {
                showingCitySheet = false
            }
        }
    }
}

#Preview {
    Location(currentCity: .constant(nil), onCityChange: { _ in })
}
