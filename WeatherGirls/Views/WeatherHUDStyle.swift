//
//  WeatherHUDStyle.swift
//  WeatherGirls
//
//  Created by Assistant on 12/27/25.
//

import SwiftUI

struct WeatherHUDStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.headline)
            .foregroundStyle(.secondary)
            .lineLimit(1)
            .truncationMode(.tail)
    }
}

extension View {
    func weatherHUDStyle() -> some View {
        modifier(WeatherHUDStyle())
    }
}
