//
//  WeatherDataModel.swift
//  WeatherGirls
//
//  Created by Robin Gonzales on 10/23/25.
//

import Foundation

struct WeatherDataModel: Identifiable, Codable {
    let id: UUID = UUID()
    let day: String
    let temperature: String
    let openWeatherIconCode: String?
    let weatherID: Int?
    let isFahrenheit: Bool
    let condition: String
    
    var sfSymbolName: String {
        ForecastViewModel.mapIcon(from: openWeatherIconCode)
    }
    
    var displayTemperature: String {
        // If temperature string already includes units, just return it
        if temperature.contains("°") { return temperature }
        if let value = Double(temperature) {
            if isFahrenheit {
                return "\(Int(value))°F"
            } else {
                let f = Int((value * 9/5) + 32)
                return "\(f)°F"
            }
        }
        return temperature
    }
}

