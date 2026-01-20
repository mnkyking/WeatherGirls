//
//  WeatherGirlsApp.swift
//  WeatherGirls
//
//  Created by Robin Gonzales on 10/23/25.
//

import SwiftUI
import CoreData
import FirebaseCore
import GoogleMobileAds


class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Use Firebase library to configure APIs.
        FirebaseApp.configure()
        
        // Initialize the Google Mobile Ads SDK.
        MobileAds.shared.start { status in
            print("[MobileAds] Initialization complete")
            // Print adapter statuses
            let adapterStatuses = status.adapterStatusesByClassName
            for (className, adapterStatus) in adapterStatuses {
                let stateString: String
                switch adapterStatus.state {
                case .ready: stateString = "ready"
                case .notReady: stateString = "notReady"
                @unknown default: stateString = "unknown"
                }
                let desc = "[MobileAds] Adapter: \(className) state=\(stateString) latency=\(adapterStatus.latency) description=\(adapterStatus.description)"
                print(desc)
            }
        }
        return true
    }
}

@main
struct WeatherGirlsApp: App {
    let persistenceController = PersistenceController.shared
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

