//
//  Condition.swift
//  WeatherGirls
//
//  Created by Robin Gonzales on 12/27/25.
//

import SwiftUI

struct Condition: View {
    let condition: String?
    var body: some View {
        Text(condition ?? "")
    }
}

#Preview {
    Condition(condition: "cloudy")
}

