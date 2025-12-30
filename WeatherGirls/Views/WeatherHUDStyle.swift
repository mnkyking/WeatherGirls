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
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .font(.headline)
            .foregroundStyle(.secondary)
            .lineLimit(1)
            .truncationMode(.tail)
            .background(.thinMaterial, in: Capsule())
        
    }
}

extension View {
    func weatherHUDStyle() -> some View {
        modifier(WeatherHUDStyle())
    }
}
