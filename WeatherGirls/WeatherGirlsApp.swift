//
//  WeatherGirlsApp.swift
//  WeatherGirls
//
//  Created by Robin Gonzales on 10/23/25.
//

import SwiftUI
import CoreData

@main
struct WeatherGirlsApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
