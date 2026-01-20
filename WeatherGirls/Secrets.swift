import Foundation

enum Secrets {
    /// OpenWeather API key loaded from Info.plist (key: "OPENWEATHER_API_KEY").
    /// Returns an empty string if the key is missing. Prefer to inject via build settings.
    static var openWeatherKey: String {
        Bundle.main.object(forInfoDictionaryKey: "OPENWEATHER_API_KEY") as? String ?? ""
    }
}

// Usage example elsewhere in the app:
// let key = Secrets.openWeatherKey
// assert(!key.isEmpty, "Missing OPENWEATHER_API_KEY in Info.plist or build settings")
