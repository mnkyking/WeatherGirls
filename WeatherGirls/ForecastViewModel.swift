import Foundation
import CoreLocation

@MainActor
class ForecastViewModel: ObservableObject {
    @Published var forecasts: [WeatherDataModel] = []
    @Published var selectedIndex: Int = 0
    @Published var isFahrenheit: Bool = false
    @Published var currentCity: String = ""
    @Published var isLoading: Bool = false
    
    var weatherService: WeatherService?
    
    func fetchWeatherForLasVegas() async {
        let lasVegasCoords = CLLocationCoordinate2D(latitude: 36.1699, longitude: -115.1398)
        await fetchWeatherForLocation(lasVegasCoords)
    }
    
    func fetchWeatherForCity(_ cityName: String) async {
        guard let service = weatherService else { return }
        isLoading = true
        do {
            let forecastResponse = try await service.getForecast(cityName: cityName)
            currentCity = cityName
            forecasts = decodeToForecastModels(from: forecastResponse)
        } catch {
            print("Error fetching weather for city \(cityName): \(error)")
        }
        isLoading = false
    }
    
    func fetchWeatherForLocation(_ location: CLLocationCoordinate2D) async {
        guard let service = weatherService else { return }
        isLoading = true
        do {
            let forecastResponse = try await service.getForecast(
                latitude: location.latitude,
                longitude: location.longitude
            )
            currentCity = forecastResponse.city.name
            forecasts = decodeToForecastModels(from: forecastResponse)
        } catch {
            print("Error fetching weather for location \(location): \(error)")
        }
        isLoading = false
    }
    
    func decodeToForecastModels(from response: OpenWeatherForecastResponse) -> [WeatherDataModel] {
        var models: [WeatherDataModel] = []
        
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        let weekdaySymbols = dateFormatter.shortWeekdaySymbols ?? []
        
        var lastDay: Date?
        var maxTemp: Double = -1000.0
        var conditionDescription: String = ""
        var iconCode: String = ""
        var dayLabel: String = ""
        
        let isF = isFahrenheit
        
        for (index, forecast) in response.list.enumerated() {
            let date = Date(timeIntervalSince1970: TimeInterval(forecast.dt))
            let day = calendar.startOfDay(for: date)
            let temp = isF ? forecast.main.temp * 9/5 - 459.67 : forecast.main.temp - 273.15
            
            if lastDay == nil {
                lastDay = day
                maxTemp = temp
                conditionDescription = forecast.weather.first?.main ?? ""
                iconCode = forecast.weather.first?.icon ?? ""
                dayLabel = day == calendar.startOfDay(for: Date()) ? "Today" : (weekdaySymbols[calendar.component(.weekday, from: day) - 1])
            }
            
            if day != lastDay {
                let iconName = Self.mapIcon(from: iconCode)
                let model = WeatherDataModel(
                    temperature: Int(maxTemp.rounded()),
                    condition: conditionDescription,
                    day: dayLabel,
                    icon: iconName
                )
                models.append(model)
                
                lastDay = day
                maxTemp = temp
                conditionDescription = forecast.weather.first?.main ?? ""
                iconCode = forecast.weather.first?.icon ?? ""
                dayLabel = day == calendar.startOfDay(for: Date()) ? "Today" : (weekdaySymbols[calendar.component(.weekday, from: day) - 1])
            } else {
                if temp > maxTemp {
                    maxTemp = temp
                    conditionDescription = forecast.weather.first?.main ?? conditionDescription
                    iconCode = forecast.weather.first?.icon ?? iconCode
                }
            }
            
            if index == response.list.count - 1 {
                let iconName = Self.mapIcon(from: iconCode)
                let model = WeatherDataModel(
                    temperature: Int(maxTemp.rounded()),
                    condition: conditionDescription,
                    day: dayLabel,
                    icon: iconName
                )
                models.append(model)
            }
            
            if models.count == 5 {
                break
            }
        }
        
        return models
    }
    
    static func mapIcon(from iconCode: String) -> String {
        switch iconCode {
        case "01d": return "sun.max.fill"
        case "01n": return "moon.fill"
        case "02d": return "cloud.sun.fill"
        case "02n": return "cloud.moon.fill"
        case "03d", "03n": return "cloud.fill"
        case "04d", "04n": return "smoke.fill"
        case "09d", "09n": return "cloud.drizzle.fill"
        case "10d", "10n": return "cloud.rain.fill"
        case "11d", "11n": return "cloud.bolt.fill"
        case "13d", "13n": return "snow"
        case "50d", "50n": return "cloud.fog.fill"
        default: return "questionmark"
        }
    }
}
