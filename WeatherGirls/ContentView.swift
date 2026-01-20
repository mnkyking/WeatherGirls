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
import GoogleMobileAds
import SpriteKit

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.appTheme) private var appTheme

    private var themedColors: AppColors { appTheme.colors(for: colorScheme) }

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
        "rain",             // 5xx // "drizzle" 3xx // "thunderstor" 2xx
        "snow",             // 6xx
        "fog"               // 7xx
    ]
    
    @State private var artIndex: Int = 0
    @State private var previewBackgroundAsset: String? = nil
    @State private var effectiveWeatherID: Int = 100

    var body: some View {
        ZStack {
            let selectedWeatherID = viewModel.selectedWeatherID
            let bgAssetBase = previewBackgroundAsset ?? viewModel.backgroundAssetName(for: selectedWeatherID)
            // let isNight = WeatherEffectMapping.isNight()
            TimeOfDay()
            // StarfieldBackgroundView(isNight: isNight)
            WeatherParticlesView(
                weatherID: effectiveWeatherID,
                intensity: .background
            )
            .id(effectiveWeatherID)
            .allowsHitTesting(false)
            .accessibilityHidden(true)
            
            BackgroundImage(baseName: bgAssetBase)
                .id(bgAssetBase)
                .allowsHitTesting(false)
                .accessibilityHidden(true)
                .animation(.default, value: bgAssetBase)
            
            WeatherParticlesView(
                weatherID: effectiveWeatherID,
                intensity: .foreground
            )
            .id(effectiveWeatherID)
            .allowsHitTesting(false)
            .accessibilityHidden(true)

            VStack(alignment: .center) {

                // A subtle surface to improve legibility over art
                let adSize = currentOrientationAnchoredAdaptiveBanner(width: 375)
                AdBannerView()
                    .frame(width: adSize.size.width, height: adSize.size.height)
                Spacer()
                let selectedCondition = (viewModel.forecasts[safe: viewModel.selectedIndex] ?? viewModel.forecasts.first)?.condition
                
                WeekView(forecasts: viewModel.forecasts, selectedIndex: $viewModel.selectedIndex, isFahrenheit: viewModel.isFahrenheit)
                
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
                .foregroundStyle(themedColors.primaryText)
                .padding(.horizontal)
                
                UnitToggleView(isFahrenheit: $viewModel.isFahrenheit)
                    .tint(themedColors.accent)
                    .padding([.horizontal, .bottom])
            }
            .task {
                // Request location authorization
                locationManager.requestAuthorization()
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
            .onChange(of: viewModel.forecasts.map { $0.weatherID }) {
                // Forecasts updated (e.g., after refresh or new location); restore API-driven background
                previewBackgroundAsset = nil
            }
            .onChange(of: viewModel.selectedIndex) {
                // User selected a different forecast day; restore API-driven background
                print("selected index \(viewModel.selectedIndex)")
                previewBackgroundAsset = nil
            }
        }
        .tint(themedColors.accentVariant)
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
                    effectiveWeatherID = {
                        if let preview = previewBackgroundAsset {
                            // Map your asset name to a representative OpenWeather ID range
                            switch preview {
                            case "clear": return 800
                            case "partly_cloudy": return 801
                            case "cloudy": return 803
                            case "rain": return 500
                            case "snow": return 600
                            case "fog": return 741
                            default: return viewModel.selectedWeatherID ?? 100
                            }
                        } else {
                            return viewModel.selectedWeatherID ?? 100
                        }
                    }()
                    print("effective weather id \(effectiveWeatherID)")
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
        .appTheme(.vibrant)
}

