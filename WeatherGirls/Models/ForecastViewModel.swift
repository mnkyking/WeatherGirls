import SwiftUI
import CoreLocation
import Combine

@MainActor class ForecastViewModel: ObservableObject {
    @Published var forecasts: [WeatherDataModel] = []
    @Published var selectedIndex: Int = 0
    @Published var isFahrenheit: Bool = false
    @Published var currentCity: String = ""
    @Published var isLoading: Bool = false

    private let weatherService: WeatherService? = try? WeatherService()

    func fetchWeatherForLasVegas() async {
        guard !isLoading else { return }
        guard let service = weatherService else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            let units: OpenWeatherCurrentRequest.Units = isFahrenheit ? .imperial : .metric
            let response = try await service.fetchFiveDayForecast(city: "Las Vegas", countryCode: "US", units: units)
            forecasts = decodeToForecastModels(from: response)
            currentCity = response.city.name
        } catch {
            print("Weather fetch error: \(error)")
        }
    }

    func fetchWeatherForCity(_ cityName: String) async {
        guard !isLoading else { return }
        guard let service = weatherService else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            let units: OpenWeatherCurrentRequest.Units = isFahrenheit ? .imperial : .metric
            let response = try await service.fetchFiveDayForecast(city: cityName, countryCode: nil, units: units)
            forecasts = decodeToForecastModels(from: response)
            currentCity = response.city.name
        } catch {
            print("Weather fetch error: \(error)")
        }
    }

    func fetchWeatherForLocation(_ location: CLLocation) async {
        guard !isLoading else { return }
        guard let service = weatherService else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            let units: OpenWeatherCurrentRequest.Units = isFahrenheit ? .imperial : .metric
            let response = try await service.fetchFiveDayForecast(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude, units: units)
            forecasts = decodeToForecastModels(from: response)
            currentCity = response.city.name
        } catch {
            print("Weather fetch error: \(error)")
        }
    }

    func decodeToForecastModels(from response: OpenWeatherForecastResponse) -> [WeatherDataModel] {
        let calendar = Calendar.current
        let groupedByDay = Dictionary(grouping: response.list) { entry -> Date in
            return calendar.startOfDay(for: Date(timeIntervalSince1970: TimeInterval(entry.dt)))
        }
        let sortedDays = groupedByDay.keys.sorted()
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        let shortWeekdays = dateFormatter.shortWeekdaySymbols ?? []

        var models: [WeatherDataModel] = []

        for (index, day) in sortedDays.prefix(5).enumerated() {
            guard let entries = groupedByDay[day], !entries.isEmpty else { continue }
            let maxTemp: Double = entries.map { $0.main.tempMax != 0 ? $0.main.tempMax : $0.main.temp }.max() ?? 0
            let rep = entries[0]
            let iconCode = rep.weather.first?.icon ?? ""
            let condition = rep.weather.first?.description.capitalized ?? "—"
            let dayLabel = index == 0 ? "Today" : shortWeekdays[(calendar.component(.weekday, from: day) - 1) % shortWeekdays.count]

            let model = WeatherDataModel(
                day: dayLabel,
                temperature: String(Int(round(maxTemp))),
                openWeatherIconCode: iconCode,
                isFahrenheit: isFahrenheit,
                condition: condition
            )
            models.append(model)
        }

        return models
    }

    static func mapIcon(from openWeatherIcon: String?) -> String {
        switch openWeatherIcon {
        case let code? where code.hasPrefix("01"):
            return "sun.max.fill"
        case let code? where code.hasPrefix("02"):
            return "cloud.sun.fill"
        case let code? where code.hasPrefix("03"):
            return "cloud.fill"
        case let code? where code.hasPrefix("04"):
            return "smoke.fill"
        case let code? where code.hasPrefix("09"):
            return "cloud.drizzle.fill"
        case let code? where code.hasPrefix("10"):
            return "cloud.rain.fill"
        case let code? where code.hasPrefix("11"):
            return "cloud.bolt.rain.fill"
        case let code? where code.hasPrefix("13"):
            return "snowflake"
        case let code? where code.hasPrefix("50"):
            return "cloud.fog.fill"
        default:
            return "cloud"
        }
    }
}
