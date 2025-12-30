//
//  ViewModifiers.swift
//  WeatherGirls
//
//  Created by Robin Gonzales on 12/25/25.
//

import Foundation
import SwiftUI

struct WeatherSymbolStyle: ViewModifier {
    var size: CGFloat
    func body(content: Content) -> some View {
        content
            .symbolRenderingMode(.palette)
            .foregroundStyle(.tertiary, .secondary, .quaternary)
            .font(.system(size: size))
    }
}

extension View {
    func weatherSymbolStyle(size: CGFloat = 100) -> some View {
        self.modifier(WeatherSymbolStyle(size: size))
    }
}
