//
//  ContentView.swift
//  WeatherGirls
//
//  Created by Robin Gonzales on 10/23/25.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>
    
    @State var weatherData: [WeatherDataModel]

    var body: some View {
        ZStack {
            Image(systemName: "sun.max.circle")
                .symbolRenderingMode(.palette)
                .foregroundStyle(.tertiary, .secondary, .quaternary)
                .font(.system(size: 100))
            VStack(alignment: .leading) {
                Spacer()
                VStack {
                    ForecastView(forecast: weatherData[0])
                }
                FourDayView(forecasts: weatherData)
            }
            .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
        }
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
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

#Preview {
    ContentView(
        weatherData:
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
                WeatherDataModel(
                    day: "Fri",
                    temperature: "28",
                    icon: "cloud.fill",
                    isFahrenheit: false
                )
            ]
    ).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
