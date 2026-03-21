//
//  ViewModifiers.swift
//  WeatherGirls
//
//  Created by Robin Gonzales on 12/25/25.
//

import SwiftUI

// MARK: - Weather HUD Style
struct WeatherHUDStyle: ViewModifier {
    var tintColor: Color?
    
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .font(.headline)
            .foregroundStyle(.secondary)
            .lineLimit(1)
            .truncationMode(.tail)
            .background {
                if let tintColor {
                    Capsule()
                        .fill(tintColor.opacity(0.3))
                        .background(.ultraThinMaterial, in: Capsule())
                } else {
                    Capsule()
                        .fill(.ultraThinMaterial)
                }
            }
    }
}

// MARK: - Weather Info Style
struct WeatherInfoStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.ultraThinMaterial)
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
            )
    }
}

// MARK: - View Extensions
extension View {
    func weatherHUDStyle(tintColor: Color? = nil) -> some View {
        modifier(WeatherHUDStyle(tintColor: tintColor))
    }
    
    func weatherInfoStyle() -> some View {
        modifier(WeatherInfoStyle())
    }
}

