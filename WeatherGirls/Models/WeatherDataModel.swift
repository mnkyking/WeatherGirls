//
//  WeatherDataModel.swift
//  WeatherGirls
//
//  Created by Robin Gonzales on 10/23/25.
//

import Foundation

struct WeatherDataModel: Identifiable {
    let id: UUID = UUID()
    let day: String
    let temperature: String
    let icon: String
    let isFahrenheit: Bool
    var displayTemperature: String {
        return isFahrenheit ? temperature : "\(Int(Double(temperature)! * 9/5 + 32))°F"
    }
}
