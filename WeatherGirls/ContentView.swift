//
//  ContentView.swift
//  WeatherGirls
//
//  Created by Robin Gonzales on 10/23/25.
//

import SwiftUI
import CoreData
import CoreLocation
import Combine

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>
    
    @StateObject private var viewModel = ForecastViewModel()
    @StateObject private var locationManager = LocationManager()
    
    // Swipe-able art assets derived from weather group codes
    private let weatherArtAssets: [String] = [
        "clear",            // 800
        "partly_cloudy",    // 801-802
        "cloudy",           // 803-804
        "rain",             // 5xx
        "rain", //"drizzle",          // 3xx
        "rain", //"thunderstorm",     // 2xx
        "snow",             // 6xx
        "fog"               // 7xx
    ]
    @State private var artIndex: Int = 0
    @State private var previewBackgroundAsset: String? = nil

    var body: some View {
        ZStack {
            let selectedWeatherID = (viewModel.forecasts[safe: viewModel.selectedIndex] ?? viewModel.forecasts.first)?.weatherID
            let bgAssetBase = previewBackgroundAsset ?? viewModel.backgroundAssetName(for: selectedWeatherID)
            BackgroundImage(baseName: bgAssetBase)
                .ignoresSafeArea()
                .allowsHitTesting(false)
                .accessibilityHidden(true)
            
            VStack(alignment: .leading) {
                UnitToggleView(isFahrenheit: $viewModel.isFahrenheit)
                    .padding()
                Spacer()
                let selectedCondition = (viewModel.forecasts[safe: viewModel.selectedIndex] ?? viewModel.forecasts.first)?.condition
                HStack {
                    Location(
                        currentCity: Binding(
                            get: { viewModel.currentCity.isEmpty ? nil : viewModel.currentCity },
                            set: { newValue in viewModel.currentCity = newValue ?? "" }
                        ),
                        onCityChange: { name in
                            Task {
                                if let name, !name.isEmpty {
                                    await viewModel.fetchWeatherForCity(name)
                                }
                            }
                        }
                    )
                    Spacer()
                    Condition(condition: selectedCondition ?? "")
                }
                .padding()
                
                WeekView(forecasts: viewModel.forecasts, selectedIndex: $viewModel.selectedIndex, isFahrenheit: viewModel.isFahrenheit)
            }
            .task {
                // Request location authorization
                locationManager.requestAuthorization()
            }
            .task {
                // Initial fetch when view appears
                if let location = locationManager.lastLocation {
                    await viewModel.fetchWeatherForLocation(location)
                } else {
                    await viewModel.fetchWeatherForLasVegas()
                }
            }
            .onReceive(locationManager.$authorizationStatus) { status in
                Task {
                    switch status {
                    case .authorizedAlways, .authorizedWhenInUse:
                        // Do nothing, wait for location updates
                        break
                    case .denied, .restricted:
                        await viewModel.fetchWeatherForLasVegas()
                    case .notDetermined:
                        break
                    @unknown default:
                        await viewModel.fetchWeatherForLasVegas()
                    }
                }
            }
            .onReceive(locationManager.$lastLocation.compactMap { $0 }) { location in
                Task {
                    if viewModel.currentCity.isEmpty {
                        await viewModel.fetchWeatherForLocation(location)
                    }
                }
            }
            .onChange(of: viewModel.selectedIndex) { _ in
                // User selected a different forecast day; restore API-driven background
                previewBackgroundAsset = nil
            }
        }
        .refreshable {
            if let location = locationManager.lastLocation {
                await viewModel.fetchWeatherForLocation(location)
                viewModel.currentCity = ""
                previewBackgroundAsset = nil
            } else {
                await viewModel.fetchWeatherForLasVegas()
                viewModel.currentCity = ""
                previewBackgroundAsset = nil
            }
        }
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 20, coordinateSpace: .local)
                .onEnded { value in
                    let threshold: CGFloat = 40
                    let dx = value.translation.width
                    if dx < -threshold {
                        // Swipe right-to-left: increment
                        incrementArtIndex()
                        previewBackgroundAsset = weatherArtAssets[artIndex]
                    } else if dx > threshold {
                        // Swipe left-to-right: decrement
                        decrementArtIndex()
                        previewBackgroundAsset = weatherArtAssets[artIndex]
                    }
                }
        )
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    private func incrementArtIndex() {
        guard !weatherArtAssets.isEmpty else { return }
        artIndex = (artIndex + 1) % weatherArtAssets.count
    }

    private func decrementArtIndex() {
        guard !weatherArtAssets.isEmpty else { return }
        artIndex = (artIndex - 1 + weatherArtAssets.count) % weatherArtAssets.count
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

private extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
