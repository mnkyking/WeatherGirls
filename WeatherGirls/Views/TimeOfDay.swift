//
//  TimeOfDay.swift
//  WeatherGirls
//
//  Created by Robin Gonzales on 1/17/26.
//

import SwiftUI

struct TimeOfDay: View {
    
    // MARK: - Time of day gradient support
    private enum TimeOfDay {
        case sunrise, noon, sunset, midnight
    }

    private var currentTimeOfDay: TimeOfDay {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<9: return .sunrise
        case 9..<16: return .noon
        case 16..<20: return .sunset
        default: return .midnight
        }
    }

    private var timeOfDayGradient: some View {
        let gradient: Gradient
        switch currentTimeOfDay {
        case .sunrise:
            gradient = Gradient(colors: [
                Color(red: 0.98, green: 0.78, blue: 0.48), // warm light
                Color(red: 0.99, green: 0.59, blue: 0.52), // peach
                Color(red: 0.50, green: 0.70, blue: 0.95)  // soft blue
            ])
        case .noon:
            gradient = Gradient(colors: [
                Color(red: 0.62, green: 0.85, blue: 1.00), // sky
                Color(red: 0.33, green: 0.67, blue: 0.98)
            ])
        case .sunset:
            gradient = Gradient(colors: [
                Color(red: 0.99, green: 0.49, blue: 0.38), // orange
                Color(red: 0.73, green: 0.24, blue: 0.53), // magenta
                Color(red: 0.15, green: 0.19, blue: 0.38)  // deep blue
            ])
        case .midnight:
            gradient = Gradient(colors: [
                Color(red: 0.02, green: 0.05, blue: 0.12), // near black
                Color(red: 0.05, green: 0.10, blue: 0.22)
            ])
        }
        return LinearGradient(gradient: gradient, startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()
    }
    var body: some View {
        timeOfDayGradient
    }
}

#Preview {
    TimeOfDay()
}
