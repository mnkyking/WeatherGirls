import Foundation
import CoreLocation

public struct WeatherService {
    private let apiKey: String

    public enum ServiceError: Error, LocalizedError {
        case missingAPIKey
        case badURL
        case network(underlying: Error)
        case httpStatus(code: Int)
        case api(message: String, code: Int?)
        case decoding(underlying: Error)

        public var errorDescription: String? {
            switch self {
            case .missingAPIKey:
                return "Missing OpenWeather API key. Please set 'OPENWEATHER_API_KEY' in Info.plist."
            case .badURL:
                return "Failed to build a valid URL for the request."
            case .network(let underlying):
                return "Network request failed: \(underlying.localizedDescription)"
            case .httpStatus(let code):
                return "Server responded with status code \(code)."
            case .api(let message, let code):
                if let code { return "OpenWeather error (\(code)): \(message)" } else { return "OpenWeather error: \(message)" }
            case .decoding(let underlying):
                return "Failed to decode response: \(underlying.localizedDescription)"
            }
        }
    }

    private struct OpenWeatherErrorBody: Decodable {
        let cod: String?
        let message: String?
    }

    public init() throws {
        if let key = WeatherService.readAPIKeyFromInfoPlist() {
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
            URLQueryItem(name: "appid", value: apiKey),
            URLQueryItem(name: "units", value: units.rawValue)
        ]
        guard let url = components.url else { throw ServiceError.badURL }
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
                // Try to parse OpenWeather error body
                if let apiError = try? JSONDecoder().decode(OpenWeatherErrorBody.self, from: data), let message = apiError.message {
                    throw ServiceError.api(message: message, code: Int(apiError.cod ?? ""))
                }
                throw ServiceError.httpStatus(code: http.statusCode)
            }
            let decoder = JSONDecoder()
            do {
                let resp = try decoder.decode(OpenWeatherCurrentResponse.self, from: data)
                return resp
            } catch let err {
                throw ServiceError.decoding(underlying: err)
            }
        } catch let err as ServiceError {
            throw err
        } catch let err {
            throw ServiceError.network(underlying: err)
        }
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
            URLQueryItem(name: "appid", value: apiKey),
            URLQueryItem(name: "units", value: units.rawValue)
        ]
        guard let url = components.url else { throw ServiceError.badURL }
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
                if let apiError = try? JSONDecoder().decode(OpenWeatherErrorBody.self, from: data), let message = apiError.message {
                    throw ServiceError.api(message: message, code: Int(apiError.cod ?? ""))
                }
                throw ServiceError.httpStatus(code: http.statusCode)
            }
            let decoder = JSONDecoder()
            do { return try decoder.decode(OpenWeatherForecastResponse.self, from: data) } catch let err { throw ServiceError.decoding(underlying: err) }
        } catch let err as ServiceError {
            throw err
        } catch let err {
            throw ServiceError.network(underlying: err)
        }
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
            URLQueryItem(name: "appid", value: apiKey),
            URLQueryItem(name: "units", value: units.rawValue)
        ]
        guard let url = components.url else { throw ServiceError.badURL }
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
                if let apiError = try? JSONDecoder().decode(OpenWeatherErrorBody.self, from: data), let message = apiError.message {
                    throw ServiceError.api(message: message, code: Int(apiError.cod ?? ""))
                }
                throw ServiceError.httpStatus(code: http.statusCode)
            }
            let decoder = JSONDecoder()
            do { return try decoder.decode(OpenWeatherForecastResponse.self, from: data) } catch let err { throw ServiceError.decoding(underlying: err) }
        } catch let err as ServiceError {
            throw err
        } catch let err {
            throw ServiceError.network(underlying: err)
        }
    }

    private static func readAPIKeyFromInfoPlist() -> String? {
        return Secrets.openWeatherKey
    }
}

