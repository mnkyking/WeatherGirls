import Foundation

struct WeatherDataLoader {
    enum LoaderError: Error { case fileNotFound, decodeFailed }

    static func loadFromBundle(named fileName: String = "MockWeatherData") throws -> [WeatherDataModel] {
        let bundle = Bundle.main
        guard let url = bundle.url(forResource: fileName, withExtension: "json") else {
            throw LoaderError.fileNotFound
        }
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        return try decoder.decode([WeatherDataModel].self, from: data)
    }
}
