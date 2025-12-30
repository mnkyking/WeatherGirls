import Foundation

struct WeatherDataLoader {
    enum LoaderError: Error { case fileNotFound, decodeFailed }

    static func loadFromBundle(named fileName: String = "MockWeatherData") async throws -> [WeatherDataModel] {
        let bundle = Bundle.main
        guard let url = bundle.url(forResource: fileName, withExtension: "json") else {
            throw LoaderError.fileNotFound
        }
        let (data, _) = try await URLSession.shared.data(from: url)
        let decoder = JSONDecoder()
        return try decoder.decode([WeatherDataModel].self, from: data)
    }
}
