import Foundation

/// A request builder for OpenWeatherMap's Current Weather Data API.
/// Example endpoint:
/// http://api.openweathermap.org/data/2.5/weather?q=London,uk&APPID=YOUR_API_KEY
public struct OpenWeatherCurrentRequest {
    /// City name, e.g., "London"
    public let city: String
    /// Optional ISO 3166 country code, e.g., "uk" or "US". When provided, query is `city,countryCode`.
    public let countryCode: String?
    /// Your OpenWeatherMap API key.
    public let apiKey: String
    /// Units of measurement. Default is `standard` (Kelvin). Use `metric` for Celsius or `imperial` for Fahrenheit.
    public let units: Units
    /// Language for the response data (e.g., description strings). Default is `en`.
    public let language: String

    public enum Units: String {
        case standard
        case metric
        case imperial
    }

    public init(city: String,
                countryCode: String? = nil,
                apiKey: String,
                units: Units = .standard,
                language: String = "en") {
        self.city = city
        self.countryCode = countryCode
        self.apiKey = apiKey
        self.units = units
        self.language = language
    }

    /// Builds the URL for the request.
    public func makeURL() throws -> URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.openweathermap.org"
        components.path = "/data/2.5/weather"

        let qValue: String
        if let cc = countryCode, !cc.isEmpty {
            qValue = "\(city),\(cc)"
        } else {
            qValue = city
        }

        components.queryItems = [
            URLQueryItem(name: "q", value: qValue),
            URLQueryItem(name: "APPID", value: apiKey),
            URLQueryItem(name: "units", value: units.rawValue),
            URLQueryItem(name: "lang", value: language)
        ]

        guard let url = components.url else {
            throw URLError(.badURL)
        }
        return url
    }

    /// Performs the network call and returns raw Data. You can decode it into your own models.
    /// - Parameter session: URLSession to use. Defaults to `.shared`.
    /// - Returns: Raw response data from the API.
    public func fetch(session: URLSession = .shared) async throws -> Data {
        let url = try makeURL()
        let (data, response) = try await session.data(from: url)
        if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
            throw URLError(.badServerResponse)
        }
        return data
    }
}

// MARK: - Response Models

public struct OpenWeatherCurrentResponse: Decodable {
    public let coord: Coord
    public let weather: [Weather]
    public let base: String?
    public let main: Main
    public let visibility: Int?
    public let wind: Wind?
    public let rain: Rain?
    public let clouds: Clouds?
    public let dt: Int
    public let sys: Sys
    public let timezone: Int?
    public let id: Int
    public let name: String
    public let cod: Int
}

public struct Coord: Decodable {
    public let lon: Double
    public let lat: Double
}

public struct Weather: Decodable {
    public let id: Int
    public let main: String
    public let description: String
    public let icon: String
}

public struct Main: Decodable {
    public let temp: Double
    public let feelsLike: Double
    public let tempMin: Double
    public let tempMax: Double
    public let pressure: Int
    public let humidity: Int
    public let seaLevel: Int?
    public let grndLevel: Int?

    private enum CodingKeys: String, CodingKey {
        case temp
        case feelsLike = "feels_like"
        case tempMin = "temp_min"
        case tempMax = "temp_max"
        case pressure
        case humidity
        case seaLevel = "sea_level"
        case grndLevel = "grnd_level"
    }
}

public struct Wind: Decodable {
    public let speed: Double
    public let deg: Int
    public let gust: Double?
}

public struct Rain: Decodable {
    /// Precipitation volume for the last 1 hour, mm
    public let oneHour: Double?

    private enum CodingKeys: String, CodingKey {
        case oneHour = "1h"
    }
}

public struct Clouds: Decodable {
    public let all: Int
}

public struct Sys: Decodable {
    public let type: Int?
    public let id: Int?
    public let country: String
    public let sunrise: Int
    public let sunset: Int
}

// MARK: - Forecast (5-day / 3-hour) support
public struct OpenWeatherForecastResponse: Decodable {
    public let list: [ForecastEntry]
    public let city: ForecastCity
}

public struct ForecastEntry: Decodable {
    public let dt: Int
    public let main: ForecastMain
    public let weather: [Weather]
}

public struct ForecastMain: Decodable {
    public let temp: Double
    public let tempMin: Double
    public let tempMax: Double

    private enum CodingKeys: String, CodingKey {
        case temp
        case tempMin = "temp_min"
        case tempMax = "temp_max"
    }
}

public struct ForecastCity: Decodable {
    public let name: String
}
