import Foundation
import CoreLocation

public struct WeatherService {
    public let apiKey: String

    public enum ServiceError: Error { case missingAPIKey }

    public init(apiKey: String? = nil) throws {
        if let key = apiKey ?? WeatherService.readAPIKeyFromInfoPlist() {
            self.apiKey = key
        } else {
            throw ServiceError.missingAPIKey
        }
    }

    public func fetchCurrentWeather(city: String, countryCode: String? = nil, units: OpenWeatherCurrentRequest.Units = .metric) async throws -> OpenWeatherCurrentResponse {
        let request = OpenWeatherCurrentRequest(city: city, countryCode: countryCode, apiKey: apiKey, units: units)
        let data = try await request.fetch()
        let decoder = JSONDecoder()
        return try decoder.decode(OpenWeatherCurrentResponse.self, from: data)
    }
    
    public func fetchCurrentWeather(latitude: Double, longitude: Double, units: OpenWeatherCurrentRequest.Units = .metric) async throws -> OpenWeatherCurrentResponse {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.openweathermap.org"
        components.path = "/data/2.5/weather"
        components.queryItems = [
            URLQueryItem(name: "lat", value: String(latitude)),
            URLQueryItem(name: "lon", value: String(longitude)),
            URLQueryItem(name: "APPID", value: apiKey),
            URLQueryItem(name: "units", value: units.rawValue)
        ]
        guard let url = components.url else { throw URLError(.badURL) }
        let (data, response) = try await URLSession.shared.data(from: url)
        if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
            throw URLError(.badServerResponse)
        }
        let decoder = JSONDecoder()
        let resp = try decoder.decode(OpenWeatherCurrentResponse.self, from: data)
        return resp
    }

    /// Fetch the 5-day / 3-hour forecast by city name (aggregates to daily)
    public func fetchFiveDayForecast(city: String, countryCode: String? = nil, units: OpenWeatherCurrentRequest.Units = .metric) async throws -> OpenWeatherForecastResponse {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.openweathermap.org"
        components.path = "/data/2.5/forecast"

        let qValue: String
        if let cc = countryCode, !cc.isEmpty { qValue = "\(city),\(cc)" } else { qValue = city }

        components.queryItems = [
            URLQueryItem(name: "q", value: qValue),
            URLQueryItem(name: "APPID", value: apiKey),
            URLQueryItem(name: "units", value: units.rawValue)
        ]
        guard let url = components.url else { throw URLError(.badURL) }
        let (data, response) = try await URLSession.shared.data(from: url)
        if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
            throw URLError(.badServerResponse)
        }
        let decoder = JSONDecoder()
        return try decoder.decode(OpenWeatherForecastResponse.self, from: data)
    }

    /// Fetch the 5-day / 3-hour forecast by coordinates (aggregates to daily)
    public func fetchFiveDayForecast(latitude: Double, longitude: Double, units: OpenWeatherCurrentRequest.Units = .metric) async throws -> OpenWeatherForecastResponse {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.openweathermap.org"
        components.path = "/data/2.5/forecast"
        components.queryItems = [
            URLQueryItem(name: "lat", value: String(latitude)),
            URLQueryItem(name: "lon", value: String(longitude)),
            URLQueryItem(name: "APPID", value: apiKey),
            URLQueryItem(name: "units", value: units.rawValue)
        ]
        guard let url = components.url else { throw URLError(.badURL) }
        let (data, response) = try await URLSession.shared.data(from: url)
        if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
            throw URLError(.badServerResponse)
        }
        let decoder = JSONDecoder()
        return try decoder.decode(OpenWeatherForecastResponse.self, from: data)
    }

    private static func readAPIKeyFromInfoPlist() -> String? {
        return Bundle.main.object(forInfoDictionaryKey: "OpenWeatherAPIKey") as? String
    }
}
