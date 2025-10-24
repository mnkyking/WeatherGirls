//
//  FourDayView.swift
//  WeatherGirls
//
//  Created by Robin Gonzales on 10/23/25.
//

import SwiftUI

struct FourDayView: View {
    @State var forecasts: [WeatherDataModel]
    var body: some View {
        HStack(alignment: .top) {
            ForEach(forecasts) { forecast in
                if #available(macOS 26.0, *) {
                    GlassEffectContainer {
                        ForecastView(forecast: forecast)
                            .padding()
                            .glassEffect()
                    }
                } else {
                    // Fallback on earlier versions
                    ForecastView(forecast: forecast)
                        .padding()
                        .overlay {
                            Rectangle()
                                .stroke(.blue, lineWidth: 12)
                                .cornerRadius(10)
                                .shadow(radius: 3)
                        }
                }
            }
        }
    }
}

#Preview {
    FourDayView(
        forecasts:
            [
                WeatherDataModel(
                    day: "Mon",
                    temperature: "28",
                    icon: "cloud.fill",
                    isFahrenheit: false
                ),
                WeatherDataModel(
                    day: "Tue",
                    temperature: "28",
                    icon: "cloud.rain.fill",
                    isFahrenheit: false
                ),
                WeatherDataModel(
                    day: "Wed",
                    temperature: "28",
                    icon: "sun.max.fill",
                    isFahrenheit: false
                ),
                WeatherDataModel(
                    day: "Thu",
                    temperature: "28",
                    icon: "cloud.fill",
                    isFahrenheit: false
                ),
            ]
    )
}
