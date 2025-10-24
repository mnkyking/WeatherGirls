//
//  ForecastView.swift
//  WeatherGirls
//
//  Created by Robin Gonzales on 10/23/25.
//

import SwiftUI

struct ForecastView: View {
    @State var forecast: WeatherDataModel
    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                Text(forecast.day)
                Text(forecast.displayTemperature)
            }
            .padding(.bottom, 2)
            Image(systemName: forecast.icon)
                .font(.largeTitle)
                .padding(.init(top: 2, leading: 0, bottom: 2, trailing: 0))
        }
    }
}

#Preview {
    ForecastView(
        forecast: WeatherDataModel(
            day: "Monday",
            temperature: "28",
            icon: "cloud.fill",
            isFahrenheit: false
        )
    )
}
